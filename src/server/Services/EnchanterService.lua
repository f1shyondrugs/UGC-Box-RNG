local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")

local Shared = ReplicatedStorage.Shared
local GameConfig = require(Shared.Modules.GameConfig)
local Remotes = require(Shared.Remotes.Remotes)
local ItemValueCalculator = require(Shared.Modules.ItemValueCalculator)

local EnchanterService = {}

-- Import PlayerDataService for saving data
local PlayerDataService = require(script.Parent.PlayerDataService)

-- Track active auto-enchanting sessions
local activeAutoEnchantSessions = {} -- player.UserId -> {itemInstance, targetMutators, isRunning}

-- Create a ranked lookup table for mutations based on chance
local sortedMutationsList = {}
for name, data in pairs(GameConfig.Mutations) do
	table.insert(sortedMutationsList, { name = name, chance = data.Chance })
end
-- Sort from highest chance (common) to lowest chance (rare)
table.sort(sortedMutationsList, function(a, b)
	return a.chance > b.chance
end)

local mutationRanks = {}
for i, mutationInfo in ipairs(sortedMutationsList) do
	mutationRanks[mutationInfo.name] = i
end

-- Helper function to calculate a single item's value
local function calculateSingleItemValue(itemInstance, itemConfig)
	local mutationConfigs = ItemValueCalculator.GetMutationConfigs(itemInstance)
	local size = itemInstance:GetAttribute("Size") or 1
	return ItemValueCalculator.GetValue(itemConfig, mutationConfigs, size)
end

-- Check if player owns the Auto-Enchanter gamepass
local function checkAutoEnchanterGamepass(player)
	-- Check whitelist first
	for _, whitelistedId in ipairs(GameConfig.GamepassWhitelist or {}) do
		if player.UserId == whitelistedId then
			return true -- Grant access if in whitelist
		end
	end

	local success, ownsGamepass = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, GameConfig.AutoEnchanterGamepassId)
	end)
	
	if success then
		return ownsGamepass
	else
		warn("Failed to check gamepass ownership for player " .. player.Name)
		return false
	end
end

-- Check if an item has the desired mutators (or higher if the flag is set)
local function itemHasTargetMutators(itemInstance, targetMutators, stopOnHigher, matchAnyMode)
	local currentMutators = ItemValueCalculator.GetMutationNames(itemInstance)
	local currentMutatorsSet = {}
	for _, mutatorName in ipairs(currentMutators) do
		currentMutatorsSet[mutatorName] = true
	end
	
	if #targetMutators == 0 then return false end

	if matchAnyMode then
		-- OR logic: stop if any target mutator is present
		for _, targetMutator in ipairs(targetMutators) do
			if currentMutatorsSet[targetMutator] then
				return true
			end
		end
	else
		-- AND logic: stop only if all target mutators are present
		local allTargetsFound = true
		for _, targetMutator in ipairs(targetMutators) do
			if not currentMutatorsSet[targetMutator] then
				allTargetsFound = false
				break
			end
		end
		if allTargetsFound then
			return true
		end
	end

	if not stopOnHigher then
		return false
	end

	-- If "or higher" is enabled, check rarity levels of mutations
	local highestTargetRank = 0
	for _, mutatorName in ipairs(targetMutators) do
		highestTargetRank = math.max(highestTargetRank, mutationRanks[mutatorName] or 0)
	end

	local highestCurrentRank = 0
	for _, mutatorName in ipairs(currentMutators) do
		highestCurrentRank = math.max(highestCurrentRank, mutationRanks[mutatorName] or 0)
	end

	if highestCurrentRank > highestTargetRank then
		return true -- Success, we got something better
	end

	return false -- Still haven't met the condition
end

-- Start auto-enchanting for a player
function EnchanterService:startAutoEnchanting(player, itemInstance, targetMutators, stopOnHigher, matchAnyMode)
	if activeAutoEnchantSessions[player.UserId] then
		Remotes.Notify:FireClient(player, "Auto-enchanting session already active.", "Error")
		return
	end
	
	-- Verify gamepass ownership
	if not checkAutoEnchanterGamepass(player) then
		Remotes.Notify:FireClient(player, "You need the Auto-Enchanter gamepass to use this feature!", "Error")
		return
	end
	
	-- Verify item ownership
	if not itemInstance or not itemInstance.Parent or itemInstance.Parent.Parent ~= player then
		return
	end
	
	-- Verify target mutators
	if not targetMutators or #targetMutators == 0 then
		Remotes.Notify:FireClient(player, "Please select at least one target mutator.", "Error")
		return
	end
	
	-- Get item information
	local itemName = itemInstance:GetAttribute("ItemName") or itemInstance.Name
	local itemConfig = GameConfig.Items[itemName]
	if not itemConfig then
		Remotes.Notify:FireClient(player, "Invalid item configuration.", "Error")
		return
	end
	
	-- Check if already has target mutators
	if itemHasTargetMutators(itemInstance, targetMutators, stopOnHigher, matchAnyMode) then
		Remotes.Notify:FireClient(player, "Item already has the target mutators!", "Success")
		return
	end
	
	-- Start auto-enchanting session
	activeAutoEnchantSessions[player.UserId] = {
		player = player,
		itemInstance = itemInstance,
		targetMutators = targetMutators,
		stopOnHigher = stopOnHigher,
		matchAnyMode = matchAnyMode,
		isRunning = true,
		startTime = tick(),
		attempts = 0,
		totalSpent = 0
	}
	
	-- Notify client
	Remotes.Notify:FireClient(player, "Auto-enchanting started! Target: " .. table.concat(targetMutators, " + "), "Success")
	
	-- Start the auto-enchanting loop
	task.spawn(function()
		autoEnchantLoop(player, itemInstance, targetMutators, stopOnHigher, matchAnyMode)
	end)
end

-- Stop auto-enchanting for a player
local function stopAutoEnchanting(player)
	local session = activeAutoEnchantSessions[player.UserId]
	if session then
		session.isRunning = false
		activeAutoEnchantSessions[player.UserId] = nil
		Remotes.Notify:FireClient(player, "Auto-enchanting stopped. Attempts: " .. session.attempts .. ", Total spent: " .. session.totalSpent .. " R$", "Info")
		Remotes.AutoEnchantingProgress:FireClient(player, false, session.attempts, session.totalSpent, "")
	end
end

-- Auto-enchanting loop
function autoEnchantLoop(player, itemInstance, targetMutators, stopOnHigher, matchAnyMode)
	local session = activeAutoEnchantSessions[player.UserId]
	if not session then return end
	
	while session.isRunning do
		-- Check if item still exists
		if not session.itemInstance or not session.itemInstance.Parent then
			Remotes.Notify:FireClient(player, "Auto-enchanting stopped: Item no longer exists.", "Error")
			stopAutoEnchanting(player)
			return
		end
		
		-- Check if already has target mutators
		if itemHasTargetMutators(session.itemInstance, session.targetMutators, session.stopOnHigher, session.matchAnyMode) then
			Remotes.Notify:FireClient(player, "🎉 Auto-enchanting SUCCESS! Got target mutators: " .. table.concat(session.targetMutators, " + "), "Success")
			stopAutoEnchanting(player)
			return
		end
		
		-- Get item config
		local itemName = session.itemInstance:GetAttribute("ItemName") or session.itemInstance.Name
		local itemConfig = GameConfig.Items[itemName]
		if not itemConfig then
			Remotes.Notify:FireClient(player, "Auto-enchanting stopped: Invalid item configuration.", "Error")
			stopAutoEnchanting(player)
			return
		end
		
		-- Calculate cost
		local cost = calculateSingleItemValue(session.itemInstance, itemConfig)
		local currentRobux = player:GetAttribute("RobuxValue") or 0
		
		-- Check if player can afford
		if currentRobux < cost then
			Remotes.Notify:FireClient(player, "Auto-enchanting stopped: Not enough R$. Need " .. cost .. " R$", "Error")
			stopAutoEnchanting(player)
			return
		end
		
		-- Perform reroll (similar to existing rerollMutators function)
		PlayerDataService.UpdatePlayerRobux(player, currentRobux - cost)
		session.attempts = session.attempts + 1
		session.totalSpent = session.totalSpent + cost
		
		-- Generate new mutators
		local newMutations = {}
		local sortedMutations = {}
		for name, data in pairs(GameConfig.Mutations) do
			table.insert(sortedMutations, {name = name, chance = data.Chance})
		end
		table.sort(sortedMutations, function(a, b)
			return a.chance < b.chance
		end)

		-- Roll for each mutation independently
		for _, mutationInfo in ipairs(sortedMutations) do
			local roll = math.random() * 100
			if roll <= mutationInfo.chance then
				table.insert(newMutations, mutationInfo.name)
			end
		end
		
		-- Apply new mutations
		if #newMutations > 0 then
			session.itemInstance:SetAttribute("Mutations", HttpService:JSONEncode(newMutations))
			session.itemInstance:SetAttribute("Mutation", newMutations[1])
		else
			session.itemInstance:SetAttribute("Mutations", nil)
			session.itemInstance:SetAttribute("Mutation", nil)
		end
		
		-- Update player's RAP
		PlayerDataService.UpdatePlayerRAP(player)
		
		-- Send progress update
		local progressText = "Attempt #" .. session.attempts .. " | Spent: " .. session.totalSpent .. " R$"
		local newMutatorNames = {}
		for _, mutation in ipairs(newMutations) do
			table.insert(newMutatorNames, mutation)
		end
		Remotes.AutoEnchantingProgress:FireClient(player, true, session.attempts, session.totalSpent, progressText, newMutatorNames)
		
		-- Check if target is met
		if itemHasTargetMutators(session.itemInstance, session.targetMutators, session.stopOnHigher, session.matchAnyMode) then
			Remotes.Notify:FireClient(player, "Target achieved!", "Success")
			-- Send a final "stopped" event to the client to update the UI
			Remotes.AutoEnchantingProgress:FireClient(player, false, session.attempts, session.totalSpent, "Target achieved!", newMutatorNames)
			break
		end
		
		-- Check if player can afford the next roll
		if currentRobux < cost then
			Remotes.Notify:FireClient(player, "Not enough money to continue auto-enchanting.", "Error")
			-- Send a final "stopped" event
			Remotes.AutoEnchantingProgress:FireClient(player, false, session.attempts, session.totalSpent, "Stopped: Not enough money.")
			break
		end
		
		task.wait(0.2) -- Small delay between attempts
	end

	-- Clean up the session after the loop is finished
	activeAutoEnchantSessions[player.UserId] = nil
end

-- Handle ProximityPrompt trigger
local function onEnchanterPromptTriggered(player, promptPart)
	-- Check if player has an inventory
	local inventory = player:FindFirstChild("Inventory")
	if not inventory then
		Remotes.Notify:FireClient(player, "Inventory not found.", "Error")
		return
	end
	
	-- Get all items from inventory
	local availableItems = {}
	for _, itemInstance in pairs(inventory:GetChildren()) do
		if itemInstance:IsA("StringValue") then
			local itemName = itemInstance:GetAttribute("ItemName") or itemInstance.Name
			local itemConfig = GameConfig.Items[itemName]
			if itemConfig then
				table.insert(availableItems, {
					itemName = itemName,
					itemConfig = itemConfig,
					itemInstance = itemInstance,
					value = calculateSingleItemValue(itemInstance, itemConfig)
				})
			end
		end
	end
	
	if #availableItems == 0 then
		Remotes.Notify:FireClient(player, "You need at least one item to use the Enchanter!", "Error")
		return
	end
	
	-- Open the enchanter GUI with all available items
	Remotes.OpenEnchanter:FireClient(player, availableItems)
end

-- Get enchanter data for a specific item
local function getEnchanterData(player, itemInstance)
	local inventory = player:FindFirstChild("Inventory")
	if not inventory or not itemInstance or itemInstance.Parent ~= inventory then
		warn("Player " .. player.Name .. " tried to get enchanter data for invalid item.")
		return nil
	end
	
	-- Get item information
	local itemName = itemInstance:GetAttribute("ItemName") or itemInstance.Name
	local itemConfig = GameConfig.Items[itemName]
	if not itemConfig then
		warn("Item config not found for: " .. itemName)
		return nil
	end
	
	return {
		itemName = itemName,
		itemConfig = itemConfig,
		itemInstance = itemInstance
	}
end

-- Reroll mutators for an item
local function rerollMutators(player, itemInstance)
	local inventory = player:FindFirstChild("Inventory")
	if not inventory or not itemInstance or itemInstance.Parent ~= inventory then
		warn("Player " .. player.Name .. " tried to reroll mutators for invalid item.")
		return
	end
	
	-- Get item information
	local itemName = itemInstance:GetAttribute("ItemName") or itemInstance.Name
	local itemConfig = GameConfig.Items[itemName]
	if not itemConfig then
		warn("Item config not found for: " .. itemName)
		return
	end
	
	-- Use item value as reroll cost
	local cost = calculateSingleItemValue(itemInstance, itemConfig)
	local currentRobux = player:GetAttribute("RobuxValue") or 0
	
	if currentRobux < cost then
		Remotes.Notify:FireClient(player, "You don't have enough R$ to reroll this item's mutators! Cost: " .. cost, "Error")
		return
	end
	
	-- Deduct money
	PlayerDataService.UpdatePlayerRobux(player, currentRobux - cost)
	
	-- Generate new mutators using the same system as box opening
	local newMutations = {}
	
	-- Create a sorted list of mutations, rarest first (same as in BoxService)
	local sortedMutations = {}
	for name, data in pairs(GameConfig.Mutations) do
		table.insert(sortedMutations, {name = name, chance = data.Chance})
	end
	table.sort(sortedMutations, function(a, b)
		return a.chance < b.chance
	end)

	-- Roll for each mutation independently - items can get multiple mutations
	for _, mutationInfo in ipairs(sortedMutations) do
		-- Roll a decimal between 0 and 100 to support fractional chances
		local roll = math.random() * 100
		if roll <= mutationInfo.chance then
			table.insert(newMutations, mutationInfo.name)
		end
	end
	
	-- Apply new mutations to item
	if #newMutations > 0 then
		-- Store mutations as a JSON string to support multiple mutations
		itemInstance:SetAttribute("Mutations", HttpService:JSONEncode(newMutations))
		-- Also store first mutation for backward compatibility
		itemInstance:SetAttribute("Mutation", newMutations[1])
	else
		-- Remove mutations if none rolled
		itemInstance:SetAttribute("Mutations", nil)
		itemInstance:SetAttribute("Mutation", nil)
	end
	
	-- Update player's RAP since item value may have changed
	PlayerDataService.UpdatePlayerRAP(player)
	
	-- Save player data
	PlayerDataService.Save(player)
	
	-- Notify player of success
	if #newMutations > 0 then
		local mutationText = table.concat(newMutations, ", ")
		Remotes.Notify:FireClient(player, "✨ Mutators rerolled! New mutators: " .. mutationText, "Success")
	else
		Remotes.Notify:FireClient(player, "Mutators rerolled! No new mutators this time.", "Info")
	end
	
	-- Close the enchanter GUI and reopen with updated item
	task.wait(0.5) -- Small delay to let the notification show
	Remotes.OpenEnchanter:FireClient(player, itemInstance)
end

-- Get mutator probabilities for info display
local function getMutatorProbabilities(player)
	-- Return a copy of the mutations table for client display
	local probabilities = {}
	for mutatorName, mutatorConfig in pairs(GameConfig.Mutations) do
		probabilities[mutatorName] = {
			Chance = mutatorConfig.Chance,
			ValueMultiplier = mutatorConfig.ValueMultiplier,
			Color = mutatorConfig.Color
		}
	end
	return probabilities
end

-- Setup the ProximityPrompt in the workspace
local function setupEnchanterPrompt()
	-- Create ProximityPrompts folder if it doesn't exist
	local promptsFolder = workspace:FindFirstChild("ProximityPrompts")
	if not promptsFolder then
		promptsFolder = Instance.new("Folder")
		promptsFolder.Name = "ProximityPrompts"
		promptsFolder.Parent = workspace
	end
	
	-- Check if EnchanterMain already exists
	local enchanterMain = promptsFolder:FindFirstChild("EnchanterMain")
	if not enchanterMain then
		-- Create the EnchanterMain part
		enchanterMain = Instance.new("Part")
		enchanterMain.Name = "EnchanterMain"
		enchanterMain.Size = Vector3.new(6, 8, 6)
		enchanterMain.Position = Vector3.new(25, 4, 0) -- Position it somewhere in the world
		enchanterMain.Anchored = true
		enchanterMain.Material = Enum.Material.Neon
		enchanterMain.Color = Color3.fromRGB(150, 100, 255) -- Purple color for enchanter
		enchanterMain.Shape = Enum.PartType.Block
		enchanterMain.Parent = promptsFolder
		
		-- Add a glowing effect
		local pointLight = Instance.new("PointLight")
		pointLight.Color = Color3.fromRGB(150, 100, 255)
		pointLight.Brightness = 2
		pointLight.Range = 15
		pointLight.Parent = enchanterMain
	end
	
	-- Create or update the ProximityPrompt
	local existingPrompt = enchanterMain:FindFirstChildOfClass("ProximityPrompt")
	if existingPrompt then
		existingPrompt:Destroy()
	end
	
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Use Enchanter"
	prompt.ObjectText = "Item Enchanter"
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.RequiresLineOfSight = false
	prompt.MaxActivationDistance = 8
	prompt.Parent = enchanterMain
	
	-- Connect the prompt trigger
	prompt.Triggered:Connect(function(player)
		onEnchanterPromptTriggered(player, enchanterMain)
	end)
	
	print("[EnchanterService] Enchanter ProximityPrompt setup at position:", enchanterMain.Position)
end

function EnchanterService.Start()
	-- Setup the ProximityPrompt
	setupEnchanterPrompt()
	
	-- Connect remote events
	Remotes.GetEnchanterData.OnServerInvoke = getEnchanterData
	Remotes.RerollMutators.OnServerEvent:Connect(rerollMutators)
	Remotes.GetMutatorProbabilities.OnServerInvoke = getMutatorProbabilities
	
	-- Connect auto-enchanter remote events
	Remotes.CheckAutoEnchanterGamepass.OnServerInvoke = checkAutoEnchanterGamepass
	Remotes.StartAutoEnchanting.OnServerEvent:Connect(function(player, itemInstance, targetMutators, stopOnHigher, matchAnyMode)
		EnchanterService:startAutoEnchanting(player, itemInstance, targetMutators, stopOnHigher, matchAnyMode)
	end)
	Remotes.StopAutoEnchanting.OnServerEvent:Connect(stopAutoEnchanting)
	
	print("[EnchanterService] Started successfully!")
end

-- Clean up auto-enchanting sessions when players leave
Players.PlayerRemoving:Connect(function(player)
	if activeAutoEnchantSessions[player.UserId] then
		activeAutoEnchantSessions[player.UserId] = nil
	end
end)

return EnchanterService 