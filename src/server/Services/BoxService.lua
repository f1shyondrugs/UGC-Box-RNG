local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local PlayerDataService = require(script.Parent.PlayerDataService)

local Shared = ReplicatedStorage.Shared
local GameConfig = require(Shared.Modules.GameConfig)
local Remotes = require(Shared.Remotes.Remotes)
local Box = require(Shared.Modules.Box)

local BoxService = {}

local MAX_BOXES = 4
local INVENTORY_LIMIT = 50
local activeBoxes = {} -- boxPart -> Box object
local playerBoxCount = {} -- player.UserId -> number
local playerFreeCrateCooldowns = {} -- player.UserId -> last claim tick()

local function getBoxesFolder()
	local boxesFolder = Workspace:FindFirstChild("Boxes")
	if not boxesFolder then
		boxesFolder = Instance.new("Folder")
		boxesFolder.Name = "Boxes"
		boxesFolder.Parent = Workspace
	end
	return boxesFolder
end

local function requestBox(player: Player, boxType: string)
	-- Default to StarterCrate if no type specified
	boxType = boxType or "StarterCrate"
	
	local boxConfig = GameConfig.Boxes[boxType]
	if not boxConfig then
		Remotes.Notify:FireClient(player, "Invalid crate type!", "Error")
		return
	end

	if (playerBoxCount[player.UserId] or 0) >= MAX_BOXES then
		Remotes.Notify:FireClient(player, "You can only have 4 boxes out at a time!", "Error")
		return
	end

	-- Check for cost or cooldown
	if boxConfig.Price > 0 then
		local leaderstats = player:FindFirstChild("leaderstats")
		local robux = leaderstats and leaderstats:FindFirstChild("R$")

		if not robux or robux.Value < boxConfig.Price then
			Remotes.Notify:FireClient(player, "Not enough R$! Need " .. boxConfig.Price .. " R$", "Error")
			return
		end
		
		robux.Value = robux.Value - boxConfig.Price
	else -- This is a free crate, check cooldown
		local cooldown = boxConfig.Cooldown or 60
		local lastClaim = playerFreeCrateCooldowns[player.UserId]
		
		if lastClaim and (tick() - lastClaim < cooldown) then
			local remaining = math.ceil(cooldown - (tick() - lastClaim))
			Remotes.Notify:FireClient(player, "Free crate is on cooldown for " .. remaining .. "s", "Error")
			return
		end
		
		playerFreeCrateCooldowns[player.UserId] = tick()
		Remotes.StartFreeCrateCooldown:FireClient(player, cooldown)
	end

	local character = player.Character
	if not character or not character.PrimaryPart then
		return
	end
	
	-- Increment Boxes Opened stat
	local leaderstats = player:FindFirstChild("leaderstats")
	local boxesOpenedStat = leaderstats:FindFirstChild("Boxes Opened")
	if boxesOpenedStat then
		boxesOpenedStat.Value = boxesOpenedStat.Value + 1
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
	end

	-- Add a vertical offset to make it fall from the sky
	local spawnInTheAir = spawnPosition + Vector3.new(0, 50, 0)

	local box = Box.new(player)
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
		Remotes.BoxLanded:FireClient(player)
	end)

	activeBoxes[box.Part] = box
	playerBoxCount[player.UserId] = (playerBoxCount[player.UserId] or 0) + 1
	Remotes.UpdateBoxCount:FireClient(player, playerBoxCount[player.UserId])
end

local function openBox(player: Player, boxPart: Part)
	local box = activeBoxes[boxPart]
	if not box or box.Part ~= boxPart then
		return
	end
	
	-- Disable the prompt immediately to prevent double-opening
	local prompt = boxPart:FindFirstChildOfClass("ProximityPrompt")
	if prompt then
		prompt.Enabled = false
	end

	-- Check if inventory is full before opening
	local inventory = player:FindFirstChild("Inventory")
	if not inventory then return end
	if #inventory:GetChildren() >= INVENTORY_LIMIT then
		Remotes.Notify:FireClient(player, "Your inventory is full! (50/50)", "Error")
		return
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

	-- Determine reward using a more robust method for fractional chances
	local rewardItemName = nil
	local totalChance = 0
	for _, chance in pairs(boxConfig.Rewards) do
		totalChance = totalChance + chance
	end

	if totalChance > 0 then
		local randomNumber = math.random() * totalChance
		local cumulativeChance = 0
		
		-- Create a sorted array for deterministic reward selection
		local rewardsArray = {}
		for name, chance in pairs(boxConfig.Rewards) do
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
		local mutationName = nil
		local size = 1 -- Default to 1

		local inventory = player:FindFirstChild("Inventory")
		if inventory then
			-- New, corrected mutation roll logic
			
			-- 1. Create a sorted list of mutations, rarest first
			local sortedMutations = {}
			for name, data in pairs(GameConfig.Mutations) do
				table.insert(sortedMutations, {name = name, chance = data.Chance})
			end
			table.sort(sortedMutations, function(a, b)
				return a.chance < b.chance
			end)
	
			-- 2. Roll for each mutation, starting with the rarest
			for _, mutationInfo in ipairs(sortedMutations) do
				local roll = math.random(1, 100)
				if roll <= mutationInfo.chance then
					mutationName = mutationInfo.name
					break -- Award the first successful roll and stop
				end
			end
			
			-- Generate Size
			size = 0.5 + math.floor(math.pow(math.random(), 225) * 499950) / 100
			
			-- Store the reward on the box part instead of awarding it immediately
			boxPart:SetAttribute("RewardItem", rewardItemName)
			boxPart:SetAttribute("RewardSize", size)
			if mutationName then
				boxPart:SetAttribute("RewardMutation", mutationName)
			end

			-- Save the player's data immediately after they receive an item
			PlayerDataService.Save(player)
		else
			-- Inventory might be full now, notify the player.
			Remotes.Notify:FireClient(player, "Inventory is full! Reward was lost.", "Error")
		end

		Remotes.PlayAnimation:FireClient(player, boxPart, rewardItemName, mutationName, size)
	else
		-- This should not happen if chances are configured correctly, but as a fallback,
		-- we MUST clean up the box properly to prevent ghost boxes.
		Remotes.Notify:FireClient(player, "Crate Error", "Error") -- Let the player know something went wrong
		
		local box = activeBoxes[boxPart]
		if box then
			box:Destroy()
		end

		activeBoxes[boxPart] = nil
		playerBoxCount[player.UserId] = (playerBoxCount[player.UserId] or 1) - 1
		Remotes.UpdateBoxCount:FireClient(player, playerBoxCount[player.UserId])
	end
end

local function onAnimationComplete(player: Player, boxPart: Part)
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

	-- Un-track the box now.
	activeBoxes[boxPart] = nil
	playerBoxCount[player.UserId] = (playerBoxCount[player.UserId] or 1) - 1
	Remotes.UpdateBoxCount:FireClient(player, playerBoxCount[player.UserId])

	-- Grant the item before destroying the box
	local rewardItemName = boxPart:GetAttribute("RewardItem")
	if rewardItemName then
		local inventory = player:FindFirstChild("Inventory")
		if inventory and #inventory:GetChildren() < INVENTORY_LIMIT then
			local item = Instance.new("StringValue")
			item.Name = rewardItemName
			item.Parent = inventory
			item:SetAttribute("Size", boxPart:GetAttribute("RewardSize"))

			local mutationName = boxPart:GetAttribute("RewardMutation")
			if mutationName then
				item:SetAttribute("Mutation", mutationName)
			end

			-- Save the player's data immediately after they receive an item
			PlayerDataService.Save(player)
		else
			-- Inventory might be full now, notify the player.
			Remotes.Notify:FireClient(player, "Inventory is full! Reward was lost.", "Error")
		end
	end

	-- Finally, clean up the box instance.
	box:Destroy()
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
end

return BoxService 