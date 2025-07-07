local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local PlayerDataService = require(script.Parent.PlayerDataService)

local Shared = ReplicatedStorage.Shared
local GameConfig = require(Shared.Modules.GameConfig)
local Remotes = require(Shared.Remotes.Remotes)
local Box = require(Shared.Modules.Box)
local ItemValueCalculator = require(Shared.Modules.ItemValueCalculator)

local BoxService = {}

local DEFAULT_MAX_BOXES = 1
local DEFAULT_INVENTORY_LIMIT = 50
local activeBoxes = {} -- boxPart -> Box object
local playerBoxCount = {} -- player.UserId -> number
local playerFreeCrateCooldowns = {} -- player.UserId -> last claim tick()
local autoSellSettings = {} -- player.UserId -> settings table

-- Define UUID generator at the top to ensure it's available for functions below
local function generateUUID()
	return HttpService:GenerateGUID(false)
end

local function getBoxesFolder()
	local boxesFolder = Workspace:FindFirstChild("Boxes")
	if not boxesFolder then
		boxesFolder = Instance.new("Folder")
		boxesFolder.Name = "Boxes"
		boxesFolder.Parent = Workspace
	end
	return boxesFolder
end

-- Pre-create the folder on startup
getBoxesFolder()

local function requestBox(player: Player, boxType: string)
	print("[BoxService] requestBox called for player: " .. player.Name .. ", boxType: " .. tostring(boxType))
	-- Default to StarterCrate if no type specified
	boxType = boxType or "StarterCrate"
	
	local boxConfig = GameConfig.Boxes[boxType]
	if not boxConfig then
		print("[BoxService] Error: Invalid crate type for player: " .. player.Name .. ", type: " .. tostring(boxType))
		Remotes.ShowFloatingNotification:FireClient(player, "Invalid crate type!", "Error")
		return
	end

	-- Get player's max boxes from upgrade system
	local UpgradeService = require(script.Parent.UpgradeService)
	local maxBoxes = UpgradeService.GetPlayerMaxBoxes(player)
	print("[BoxService] Player " .. player.Name .. " has " .. (playerBoxCount[player.UserId] or 0) .. " active boxes, max: " .. maxBoxes)
	if (playerBoxCount[player.UserId] or 0) >= maxBoxes then
		print("[BoxService] Error: Player " .. player.Name .. " has too many active boxes.")
		Remotes.ShowFloatingNotification:FireClient(player, "You can only have " .. maxBoxes .. " boxes out at a time!", "Error")
		return
	end

	-- Check for cost or cooldown
	if boxConfig.Price > 0 then
		local currentRobux = player:GetAttribute("RobuxValue") or 0
		print("[BoxService] Player " .. player.Name .. " has R$" .. currentRobux .. ", crate price: R$" .. boxConfig.Price)

		if currentRobux < boxConfig.Price then
			print("[BoxService] Error: Not enough R$ for player: " .. player.Name)
			Remotes.ShowFloatingNotification:FireClient(player, "Not enough R$! Need " .. boxConfig.Price .. " R$", "Error")
			return
		end
		
		-- Update the raw attribute value
		player:SetAttribute("RobuxValue", currentRobux - boxConfig.Price)
		
		-- Also update the StringValue for display consistency
		local leaderstats = player:FindFirstChild("leaderstats")
		local robux = leaderstats and leaderstats:FindFirstChild("R$")
		if robux then
			local NumberFormatter = require(game.ReplicatedStorage.Shared.Modules.NumberFormatter)
			robux.Value = NumberFormatter.FormatNumber(currentRobux - boxConfig.Price)
		end
	else -- This is a free crate, check cooldown
		print("[BoxService] Free crate request for player: " .. player.Name .. ", cooldown: " .. boxConfig.Cooldown)
		local cooldown = boxConfig.Cooldown or 60
		local lastClaim = playerFreeCrateCooldowns[player.UserId]
		
		if lastClaim and (tick() - lastClaim < cooldown) then
			local remaining = math.ceil(cooldown - (tick() - lastClaim))
			print("[BoxService] Error: Free crate on cooldown for player: " .. player.Name .. ", remaining: " .. remaining .. "s")
			Remotes.ShowFloatingNotification:FireClient(player, "Free crate is on cooldown for " .. remaining .. "s", "Error")
			return
		end
		
		playerFreeCrateCooldowns[player.UserId] = tick()
		Remotes.StartFreeCrateCooldown:FireClient(player, cooldown)
		print("[BoxService] Free crate cooldown started for player: " .. player.Name)
	end

	local character = player.Character
	if not character or not character.PrimaryPart then
		print("[BoxService] Error: Player character or PrimaryPart not found for player: " .. player.Name)
		return
	end
	
	-- Increment Boxes Opened stat
	local currentBoxesOpened = player:GetAttribute("BoxesOpenedValue") or 0
	player:SetAttribute("BoxesOpenedValue", currentBoxesOpened + 1)
	print("[BoxService] Boxes Opened stat incremented for player: " .. player.Name .. ", new value: " .. (currentBoxesOpened + 1))
	
	-- Also update the StringValue for display consistency
	local leaderstats = player:FindFirstChild("leaderstats")
	local boxesOpenedStat = leaderstats and leaderstats:FindFirstChild("Boxes Opened")
	if boxesOpenedStat then
		local NumberFormatter = require(game.ReplicatedStorage.Shared.Modules.NumberFormatter)
		boxesOpenedStat.Value = NumberFormatter.FormatCount(currentBoxesOpened + 1)
	end

	-- New Spawning Logic to prevent stacking
	local spawnPosition
	local attempts = 0
	local rootCf = character.PrimaryPart.CFrame
	
	while attempts < 10 do
		attempts = attempts + 1
		local angle = math.random() * 2 * math.pi
		local radius = 6 + math.random() * 3 -- A circle between 6 and 9 studs
		local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
		local potentialPosition = rootCf.Position + offset

		local isSpotClear = true
		for boxPart,_ in pairs(activeBoxes) do
			if (boxPart.Position - potentialPosition).Magnitude < 4 then -- Box size is 4
				isSpotClear = false
				break
			end
		end

		if isSpotClear then
			spawnPosition = potentialPosition
			break
		end
	end
	
	-- Fallback if no spot was found, place it in front with some jitter
	if not spawnPosition then
		spawnPosition = (rootCf * CFrame.new(math.random(-5, 5), 0, -8)).Position
		print("[BoxService] No clear spawn spot found, using fallback position.")
	end
	print("[BoxService] Attempting to spawn box at: " .. tostring(spawnPosition))

	-- Add a vertical offset to make it fall from the sky
	local spawnInTheAir = spawnPosition + Vector3.new(0, 50, 0)

	local box = Box.new(player, boxType)
	box:SetParent(getBoxesFolder()) 
	box:SetPosition(spawnInTheAir)
	
	-- Store the box type on the part
	box.Part:SetAttribute("BoxType", boxType)
	
	-- Simulate the fall with a tween for reliability and style
	local fallTweenInfo = TweenInfo.new(
		1.2, -- Duration of the fall
		Enum.EasingStyle.Bounce, -- Gives a nice landing effect
		Enum.EasingDirection.Out
	)
	local fallTween = TweenService:Create(box.Part, fallTweenInfo, {Position = spawnPosition})

	-- Create the fade-in tween
	local fadeTweenInfo = TweenInfo.new(
		0.4, -- Made this faster
		Enum.EasingStyle.Linear
	)
	local fadeTween = TweenService:Create(box.Part, fadeTweenInfo, {Transparency = 0})

	-- Play both animations at the same time
	fallTween:Play()
	fadeTween:Play()

	fallTween.Completed:Connect(function()
		box.Part.CanCollide = true -- Give it a hitbox after it lands
		Remotes.BoxLanded:FireClient(player, box.Part)
		print("[BoxService] Box landed and BoxLanded remote fired for player: " .. player.Name)
	end)

	activeBoxes[box.Part] = box
	playerBoxCount[player.UserId] = (playerBoxCount[player.UserId] or 0) + 1
	Remotes.UpdateBoxCount:FireClient(player, playerBoxCount[player.UserId])
	print("[BoxService] Box successfully spawned and added to activeBoxes. Total boxes for player " .. player.Name .. ": " .. playerBoxCount[player.UserId])
end

local function openBox(player: Player, boxPart: BasePart)
	local box = activeBoxes[boxPart]
	if not box or box.Part ~= boxPart then
		return
	end
	
	-- Check if this box is already being opened (prevent double opening)
	if boxPart:GetAttribute("IsOpening") then
		return -- Box is already being processed
	end
	
	-- Check if inventory is full BEFORE disabling prompt (using upgrade system)
	local inventory = player:FindFirstChild("Inventory")
	if not inventory then return end
	
	local UpgradeService = require(script.Parent.UpgradeService)
	local inventoryLimit = UpgradeService.GetPlayerInventoryLimit(player)
	
	if #inventory:GetChildren() >= inventoryLimit then
		-- Show floating error text above the crate but keep prompt enabled
		local message = "Inventory Full!\n(" .. #inventory:GetChildren() .. "/" .. inventoryLimit .. ")"
		Remotes.ShowFloatingError:FireClient(player, boxPart.Position, message)
		return
	end
	
	-- Only now mark the box as being opened and disable prompt (inventory has space)
	boxPart:SetAttribute("IsOpening", true)
	
	-- Find and properly disable the prompt to prevent any further interactions
	local prompt = boxPart:FindFirstChildOfClass("ProximityPrompt")
	if prompt then
		prompt.Enabled = false
		prompt.MaxActivationDistance = 0
		prompt.RequiresLineOfSight = true
		prompt.ActionText = ""
		prompt.ObjectText = ""
	end

	local ownerId = boxPart:GetAttribute("Owner")
	if ownerId ~= player.UserId then
		return
	end

	-- Get the box type and config
	local boxType = boxPart:GetAttribute("BoxType") or "StarterCrate"
	local boxConfig = GameConfig.Boxes[boxType]
	if not boxConfig then
		boxConfig = GameConfig.Boxes["StarterCrate"] -- Fallback
	end

	-- Luck Boosts: Premium membership + Extra Lucky + ULTRA Lucky gamepasses
	local baseLuckBoost = 0

	local isPremium = player.MembershipType == Enum.MembershipType.Premium
	if isPremium then
		baseLuckBoost = baseLuckBoost + 0.1 -- 10% boost
	end

	local ownsExtraLucky, ownsUltraLucky = false, false

	-- Whitelisted developer IDs automatically own the passes
	for _, id in ipairs(GameConfig.GamepassWhitelist or {}) do
		if id == player.UserId then
			ownsExtraLucky = true
			ownsUltraLucky = true
			break
		end
	end

	if not ownsExtraLucky then
		local success, result = pcall(function()
			return MarketplaceService:UserOwnsGamePassAsync(player.UserId, GameConfig.ExtraLuckyGamepassId)
		end)
		ownsExtraLucky = success and result or false
	end

	if not ownsUltraLucky then
		local success, result = pcall(function()
			return MarketplaceService:UserOwnsGamePassAsync(player.UserId, GameConfig.UltraLuckyGamepassId)
		end)
		ownsUltraLucky = success and result or false
	end

	if ownsExtraLucky then baseLuckBoost = baseLuckBoost + 0.25 end -- 25% boost
	if ownsUltraLucky then baseLuckBoost = baseLuckBoost + 0.4 end -- 40% boost
	
	-- Apply rebirth luck bonus
	local RebirthService = require(script.Parent.RebirthService)
	local rebirthLuckMultiplier = RebirthService.GetPlayerLuckMultiplier(player)
	baseLuckBoost = baseLuckBoost + (rebirthLuckMultiplier - 1) -- Convert multiplier to additive bonus

	-- Determine reward using a more robust method for fractional chances
	local rewardItemName = nil
	local totalChance = 0
	for _, chance in pairs(boxConfig.Rewards) do
		totalChance = totalChance + chance
	end

	local adjustedRewards = {}
	if baseLuckBoost > 0 then
		for itemName, chance in pairs(boxConfig.Rewards) do
			adjustedRewards[itemName] = chance * (1 + baseLuckBoost)
		end
	else
		adjustedRewards = boxConfig.Rewards
	end

	-- Recalculate totalChance for adjusted rewards
	totalChance = 0
	for _, chance in pairs(adjustedRewards) do
		totalChance = totalChance + chance
	end

	if totalChance > 0 then
		local randomNumber = math.random() * totalChance
		local cumulativeChance = 0
		
		-- Create a sorted array for deterministic reward selection
		local rewardsArray = {}
		for name, chance in pairs(adjustedRewards) do
			table.insert(rewardsArray, {name = name, chance = chance})
		end
		table.sort(rewardsArray, function(a,b) return a.name < b.name end)

		for _, rewardData in ipairs(rewardsArray) do
			cumulativeChance = cumulativeChance + rewardData.chance
			if randomNumber <= cumulativeChance then
				rewardItemName = rewardData.name
				break
			end
		end
	end

	if rewardItemName then
		local size = 1 -- Default to 1
		local mutations = {}

		local inventory = player:FindFirstChild("Inventory")
		if inventory then
			-- New, corrected mutation roll logic - now supports multiple mutations
			
			-- 1. Create a sorted list of mutations, rarest first
			local sortedMutations = {}
			for name, data in pairs(GameConfig.Mutations) do
				table.insert(sortedMutations, {name = name, chance = data.Chance})
			end
			table.sort(sortedMutations, function(a, b)
				return a.chance < b.chance
			end)
	
			-- 2. Roll for each mutation independently - items can now get multiple mutations
			for _, mutationInfo in ipairs(sortedMutations) do
				-- Roll a decimal between 0 and 100 to support fractional chances
				local roll = math.random() * 100
				if roll <= mutationInfo.chance then
					table.insert(mutations, mutationInfo.name)
				end
			end
			
			-- Generate Size with a weighted distribution for better control
			local sizeRanges = {
				-- Common Tiers
				{min = 0.8, max = 1.2, weight = 50},   -- ~50% chance
				{min = 1.2, max = 2.0, weight = 30},   -- ~30% chance
				{min = 2.0, max = 3.0, weight = 12},   -- ~12% chance
				-- Rare Tiers
				{min = 3.0, max = 5.0, weight = 5},    -- ~5% chance
				{min = 5.0, max = 10.0, weight = 2},   -- ~2% chance
				-- Epic & Legendary Tiers
				{min = 10.0, max = 25.0, weight = 0.7},  -- ~0.7% chance
				{min = 25.0, max = 75.0, weight = 0.2},  -- ~0.2% chance
				-- Mythical & Godly Tiers
				{min = 75.0, max = 200.0, weight = 0.07}, -- ~0.07% chance
				{min = 200.0, max = 1000.0, weight = 0.02999}, -- ~0.03% chance
				-- Secret Tiers
				{min = 1000.0, max = 10000.0, weight = 0.00001} -- ~0.00001% chance
			}
			
			local totalWeight = 0
			for _, range in ipairs(sizeRanges) do
				totalWeight = totalWeight + range.weight
			end
			
			local roll = math.random() * totalWeight
			local selectedRange
			
			local cumulativeWeight = 0
			for _, range in ipairs(sizeRanges) do
				cumulativeWeight = cumulativeWeight + range.weight
				if roll <= cumulativeWeight then
					selectedRange = range
					break
				end
			end
			
			if selectedRange then
				-- Generate a random float within the selected range
				size = selectedRange.min + (math.random() * (selectedRange.max - selectedRange.min))
				size = math.floor(size * 100) / 100 -- Round to 2 decimal places
			end

			-- Store reward info on the box part for granting when floating text appears
			boxPart:SetAttribute("RewardItem", rewardItemName)
			boxPart:SetAttribute("RewardSize", size)
			if #mutations > 0 then
				-- Store mutations as a JSON string to support multiple mutations
				boxPart:SetAttribute("RewardMutations", HttpService:JSONEncode(mutations))
			end

			-- Save player data (inventory update will happen when floating text appears)
			PlayerDataService.Save(player)
		else
			-- Inventory might be full now, notify the player.
			Remotes.ShowFloatingNotification:FireClient(player, "Inventory is full! Reward was lost.", "Error")
		end

		-- Fire animation to the box opener
		Remotes.PlayAnimation:FireClient(player, boxPart, rewardItemName, mutations, size, player.UserId, true)
		
		-- Fire animation to all other players (they'll decide whether to show it based on settings)
		for _, otherPlayer in pairs(game.Players:GetPlayers()) do
			if otherPlayer ~= player then
				Remotes.PlayAnimation:FireClient(otherPlayer, boxPart, rewardItemName, mutations, size, player.UserId, false)
			end
		end
	else
		-- This should not happen if chances are configured correctly, but as a fallback,
		-- we MUST clean up the box properly to prevent ghost boxes.
		Remotes.ShowFloatingNotification:FireClient(player, "Crate Error", "Error") -- Let the player know something went wrong
		
		local box = activeBoxes[boxPart]
		if box then
			box:Destroy()
		end

		activeBoxes[boxPart] = nil
		playerBoxCount[player.UserId] = (playerBoxCount[player.UserId] or 1) - 1
		Remotes.UpdateBoxCount:FireClient(player, playerBoxCount[player.UserId])
	end
end

local function onAnimationComplete(player: Player, boxPart: BasePart)
	-- If the boxPart doesn't exist anymore, we can't do anything.
	if not boxPart or not boxPart.Parent then return end

	-- It's crucial to remove the box from tracking IMMEDIATELY
	-- to prevent race conditions if multiple animations complete at once.
	local box = activeBoxes[boxPart]
	if not box then
		-- This could mean the animation completed for a box that was already cleaned up
		-- (e.g., player disconnected). It's safe to just stop here.
		return
	end

	-- Grant the item when floating text appears (this function is now called when text starts)
	local rewardItemName = boxPart:GetAttribute("RewardItem")
	if rewardItemName then
		local inventory = player:FindFirstChild("Inventory")
		if inventory then
			local item = Instance.new("StringValue")
			-- Generate unique UUID for the item
			local itemUUID = generateUUID()
			item.Name = itemUUID
			
			-- Store the original item name as an attribute
			item:SetAttribute("ItemName", rewardItemName)
			item:SetAttribute("Size", boxPart:GetAttribute("RewardSize"))

			local mutationsJson = boxPart:GetAttribute("RewardMutations")
			local mutations = {}
			if mutationsJson then
				local HttpService = game:GetService("HttpService")
				local success, decodedMutations = pcall(function()
					return HttpService:JSONDecode(mutationsJson)
				end)
				if success and decodedMutations then
					mutations = decodedMutations
				end
			end
			
			if #mutations > 0 then
				-- Store mutations as a JSON string to support multiple mutations
				item:SetAttribute("Mutations", HttpService:JSONEncode(mutations))
				-- Keep backward compatibility with single Mutation attribute for existing code
				item:SetAttribute("Mutation", mutations[1])
			end

			-- Add the item to inventory when floating text appears
			item.Parent = inventory

			-- Update the player's collection with the new item
			PlayerDataService.UpdatePlayerCollection(player)

			-- Save the player's data immediately after they receive an item
			PlayerDataService.Save(player)

			-- Check auto-sell
			local settings = autoSellSettings[player.UserId]
			if settings and settings.autoSellEnabled then
				local mutationConfigs = ItemValueCalculator.GetMutationConfigs(item)
				local size = item:GetAttribute("Size") or 1
				local itemConfig = GameConfig.Items[item:GetAttribute("ItemName")]
				local value = ItemValueCalculator.GetValue(itemConfig, mutationConfigs, size)
				local shouldSell = false
				if value < (settings.valueThreshold or 0) then shouldSell = true end
				if shouldSell then
					local InventoryService = require(script.Parent.InventoryService)
					InventoryService.SellItemForBoxService(player, item)
				end
			end
		else
			-- This should rarely happen, but log it for debugging
			warn("Player " .. player.Name .. " inventory not found when granting reward")
		end
	end

	-- Un-track the box and schedule cleanup after floating text finishes
	activeBoxes[boxPart] = nil
	playerBoxCount[player.UserId] = (playerBoxCount[player.UserId] or 1) - 1
	Remotes.UpdateBoxCount:FireClient(player, playerBoxCount[player.UserId])

	-- Destroy the box after a delay to let floating text finish
	task.delay(4.5, function()
		if box and box.Part and box.Part.Parent then
			box:Destroy()
		end
	end)
end

function BoxService.Start()
	Remotes.RequestBox.OnServerEvent:Connect(requestBox)
	Remotes.RequestOpen.OnServerEvent:Connect(openBox)
	Remotes.AnimationComplete.OnServerEvent:Connect(onAnimationComplete)
	
	game:GetService("Players").PlayerRemoving:Connect(function(player)
		playerBoxCount[player.UserId] = nil -- Clear their box count
		for boxPart, box in pairs(activeBoxes) do
			if boxPart:GetAttribute("Owner") == player.UserId then
				box:Destroy()
				activeBoxes[boxPart] = nil
			end
		end
	end)

	Players.PlayerAdded:Connect(function(player)
		local settings = PlayerDataService.GetAutoSettings(player.UserId)
		if settings then
			autoSellSettings[player.UserId] = settings
		end
	end)

	Remotes.UpdateAutoSellSettings.OnServerEvent:Connect(function(player, settings)
		autoSellSettings[player.UserId] = settings
		local PlayerDataService = require(script.Parent.PlayerDataService)
		PlayerDataService.SetAutoSettings(player.UserId, settings)
	end)

	Remotes.GetAutoSettings.OnServerInvoke = function(player)
		return autoSellSettings[player.UserId] or {}
	end
end

return BoxService