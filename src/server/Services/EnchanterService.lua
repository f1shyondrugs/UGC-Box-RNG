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
		Remotes.ShowFloatingNotification:FireClient(player, "Auto-enchanting session already active.", "Error")
		return
	end
	
	-- Verify gamepass ownership
	if not checkAutoEnchanterGamepass(player) then
		Remotes.ShowFloatingNotification:FireClient(player, "You need the Auto-Enchanter gamepass to use this feature!", "Error")
		return
	end
	
	-- Verify item ownership
	if not itemInstance or not itemInstance.Parent or itemInstance.Parent.Parent ~= player then
		return
	end
	
	-- Verify target mutators
	if not targetMutators or #targetMutators == 0 then
		Remotes.ShowFloatingNotification:FireClient(player, "Please select at least one target mutator.", "Error")
		return
	end
	
	-- Get item information
	local itemName = itemInstance:GetAttribute("ItemName") or itemInstance.Name
	local itemConfig = GameConfig.Items[itemName]
	if not itemConfig then
		Remotes.ShowFloatingNotification:FireClient(player, "Invalid item configuration.", "Error")
		return
	end
	
	-- Check if already has target mutators
	if itemHasTargetMutators(itemInstance, targetMutators, stopOnHigher, matchAnyMode) then
		Remotes.ShowFloatingNotification:FireClient(player, "Item already has the target mutators!", "Success")
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
	Remotes.ShowFloatingNotification:FireClient(player, "Auto-enchanting started! Target: " .. table.concat(targetMutators, " + "), "Success")
	
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
		Remotes.ShowFloatingNotification:FireClient(player, "Auto-enchanting stopped. Attempts: " .. session.attempts .. ", Total spent: " .. session.totalSpent .. " R$", "Info")
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
			Remotes.ShowFloatingNotification:FireClient(player, "Auto-enchanting stopped: Item no longer exists.", "Error")
			stopAutoEnchanting(player)
			return
		end
		
		-- Check if already has target mutators
		if itemHasTargetMutators(session.itemInstance, session.targetMutators, session.stopOnHigher, session.matchAnyMode) then
			Remotes.ShowFloatingNotification:FireClient(player, "🎉 Auto-enchanting SUCCESS! Got target mutators: " .. table.concat(session.targetMutators, " + "), "Success")
			stopAutoEnchanting(player)
			return
		end
		
		-- Get item config
		local itemName = session.itemInstance:GetAttribute("ItemName") or session.itemInstance.Name
		local itemConfig = GameConfig.Items[itemName]
		if not itemConfig then
			Remotes.ShowFloatingNotification:FireClient(player, "Auto-enchanting stopped: Invalid item configuration.", "Error")
			stopAutoEnchanting(player)
			return
		end
		
		-- Calculate cost
		local cost = calculateSingleItemValue(session.itemInstance, itemConfig)
		local currentRobux = player:GetAttribute("RobuxValue") or 0
		
		-- Check if player can afford
		if currentRobux < cost then
			Remotes.ShowFloatingNotification:FireClient(player, "Auto-enchanting stopped: Not enough R$. Need " .. cost .. " R$", "Error")
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
			Remotes.ShowFloatingNotification:FireClient(player, "Target achieved!", "Success")
			-- Send a final "stopped" event to the client to update the UI
			Remotes.AutoEnchantingProgress:FireClient(player, false, session.attempts, session.totalSpent, "Target achieved!", newMutatorNames)
			break
		end
		
		-- Check if player can afford the next roll
		if currentRobux < cost then
			Remotes.ShowFloatingNotification:FireClient(player, "Not enough money to continue auto-enchanting.", "Error")
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
	print("[EnchanterService] onEnchanterPromptTriggered called for", player.Name)
	
	-- Check if enchanter is unlocked
	local RebirthService = require(script.Parent.RebirthService)
	local isUnlocked = RebirthService.IsFeatureUnlocked(player, "Enchanter")
	print("[EnchanterService] Enchanter unlocked for", player.Name, ":", isUnlocked)
	
	if not isUnlocked then
		Remotes.ShowFloatingNotification:FireClient(player, "Enchanter unlocks at Rebirth 4!", "Error")
		print("[EnchanterService] Enchanter is locked for", player.Name)
		return
	end
	
	-- Check if player has an inventory
	local inventory = player:FindFirstChild("Inventory")
	if not inventory then
		Remotes.ShowFloatingNotification:FireClient(player, "Inventory not found.", "Error")
		print("[EnchanterService] No inventory found for", player.Name)
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
	
	print("[EnchanterService] Found", #availableItems, "items in inventory for", player.Name)
	
	if #availableItems == 0 then
		Remotes.ShowFloatingNotification:FireClient(player, "You need at least one item to use the Enchanter!", "Error")
		print("[EnchanterService] No items found for", player.Name)
		return
	end
	
	-- Open the enchanter GUI with all available items
	Remotes.OpenEnchanter:FireClient(player, availableItems)
	print("[EnchanterService] Opening enchanter for", player.Name, "with", #availableItems, "items")
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
		Remotes.ShowFloatingNotification:FireClient(player, "You don't have enough R$ to reroll this item's mutators! Cost: " .. cost, "Error")
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
		Remotes.ShowFloatingNotification:FireClient(player, "✨ Mutators rerolled! New mutators: " .. mutationText, "Success")
	else
		Remotes.ShowFloatingNotification:FireClient(player, "Mutators rerolled! No new mutators this time.", "Info")
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

-- Save original build to ReplicatedStorage
local function saveOriginalBuild()
	local enchantingArea = workspace:FindFirstChild("EnchantingArea")
	if not enchantingArea then
		print("[EnchanterService] EnchantingArea not found, cannot save original build")
		return
	end
	
	-- Create ReplicatedStorage folder for original builds if it doesn't exist
	local originalBuilds = ReplicatedStorage:FindFirstChild("OriginalBuilds")
	if not originalBuilds then
		originalBuilds = Instance.new("Folder")
		originalBuilds.Name = "OriginalBuilds"
		originalBuilds.Parent = ReplicatedStorage
		print("[EnchanterService] Created OriginalBuilds folder")
	end
	
	-- Remove existing saved build if it exists
	local existingBuild = originalBuilds:FindFirstChild("EnchantingArea")
	if existingBuild then
		existingBuild:Destroy()
		print("[EnchanterService] Removed existing saved EnchantingArea build")
	end
	
	-- Clone and save the original build
	local originalBuild = enchantingArea:Clone()
	originalBuild.Name = "EnchantingArea"
	originalBuild.Parent = originalBuilds
	
	print("[EnchanterService] Saved original EnchantingArea build to ReplicatedStorage")
end

-- Save Collection build to ReplicatedStorage
local function saveCollectionBuild()
	local collectionArea = workspace:FindFirstChild("Collection")
	if not collectionArea then
		print("[EnchanterService] Collection area not found, cannot save original build")
		return
	end
	
	-- Create ReplicatedStorage folder for original builds if it doesn't exist
	local originalBuilds = ReplicatedStorage:FindFirstChild("OriginalBuilds")
	if not originalBuilds then
		originalBuilds = Instance.new("Folder")
		originalBuilds.Name = "OriginalBuilds"
		originalBuilds.Parent = ReplicatedStorage
		print("[EnchanterService] Created OriginalBuilds folder")
	end
	
	-- Remove existing saved build if it exists
	local existingBuild = originalBuilds:FindFirstChild("Collection")
	if existingBuild then
		existingBuild:Destroy()
		print("[EnchanterService] Removed existing saved Collection build")
	end
	
	-- Clone and save the original build
	local originalBuild = collectionArea:Clone()
	originalBuild.Name = "Collection"
	originalBuild.Parent = originalBuilds
	
	print("[EnchanterService] Saved original Collection build to ReplicatedStorage")
end

-- Function to update enchanter visual appearance based on player unlock status
local function updateEnchanterVisual(player)
	local RebirthService = require(script.Parent.RebirthService)
	local isUnlocked = RebirthService.IsFeatureUnlocked(player, "Enchanter")
	
	if isUnlocked then
		prompt.ActionText = "Use Enchanter"
		prompt.ObjectText = "Item Enchanter"
		enchanterMain.Color = Color3.fromRGB(150, 100, 255) -- Normal purple
		if pointLight then
			pointLight.Color = Color3.fromRGB(150, 100, 255)
		end
	else
		prompt.ActionText = "Unlocks On Rebirth 4"
		prompt.ObjectText = "Item Enchanter (Locked)"
		enchanterMain.Color = Color3.fromRGB(50, 50, 50) -- Dark gray
		if pointLight then
			pointLight.Color = Color3.fromRGB(50, 50, 50)
		end
	end
	
	-- Paint EnchantingArea parts (client-side will handle this, but we can send a signal)
	Remotes.UpdateEnchanterVisual:FireClient(player, isUnlocked)
end

-- Setup the ProximityPrompt in the workspace
local function setupEnchanterPrompt()
	print("[EnchanterService] Setting up enchanter prompt...")
	
	-- Create ProximityPrompts folder if it doesn't exist
	local promptsFolder = workspace:FindFirstChild("ProximityPrompts")
	if not promptsFolder then
		promptsFolder = Instance.new("Folder")
		promptsFolder.Name = "ProximityPrompts"
		promptsFolder.Parent = workspace
		print("[EnchanterService] Created ProximityPrompts folder")
	else
		print("[EnchanterService] ProximityPrompts folder already exists")
	end
	
	-- Check if EnchanterMain already exists
	local enchanterMain = promptsFolder:FindFirstChild("EnchanterMain")
	if not enchanterMain then
		print("[EnchanterService] Creating EnchanterMain part...")
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
		
		print("[EnchanterService] Created EnchanterMain part at position:", enchanterMain.Position)
	else
		print("[EnchanterService] EnchanterMain part already exists at position:", enchanterMain.Position)
		-- Ensure pointLight exists
		local pointLight = enchanterMain:FindFirstChild("PointLight")
		if not pointLight then
			pointLight = Instance.new("PointLight")
			pointLight.Color = Color3.fromRGB(150, 100, 255)
			pointLight.Brightness = 2
			pointLight.Range = 15
			pointLight.Parent = enchanterMain
			print("[EnchanterService] Added missing PointLight to EnchanterMain")
		end
	end
	
	-- Create or update the ProximityPrompt
	local existingPrompt = enchanterMain:FindFirstChildOfClass("ProximityPrompt")
	if existingPrompt then
		print("[EnchanterService] Removing existing ProximityPrompt...")
		existingPrompt:Destroy()
		print("[EnchanterService] Removed existing ProximityPrompt")
	end
	
	print("[EnchanterService] Creating new ProximityPrompt...")
	-- Create new ProximityPrompt with error handling
	local success, prompt = pcall(function()
		local newPrompt = Instance.new("ProximityPrompt")
		newPrompt.ActionText = "Use Enchanter"
		newPrompt.ObjectText = "Item Enchanter"
		newPrompt.KeyboardKeyCode = Enum.KeyCode.E
		newPrompt.RequiresLineOfSight = false
		newPrompt.MaxActivationDistance = 8
		newPrompt.HoldDuration = 0
		newPrompt.Parent = enchanterMain
		return newPrompt
	end)
	
	if not success then
		warn("[EnchanterService] Failed to create ProximityPrompt:", prompt)
		return
	end
	
	print("[EnchanterService] Created new ProximityPrompt successfully")
	print("[EnchanterService] Prompt properties - ActionText:", prompt.ActionText, "ObjectText:", prompt.ObjectText)
	
	-- Ensure pointLight exists
	local pointLight = enchanterMain:FindFirstChild("PointLight")
	if not pointLight then
		print("[EnchanterService] Creating PointLight...")
		pointLight = Instance.new("PointLight")
		pointLight.Color = Color3.fromRGB(150, 100, 255)
		pointLight.Brightness = 2
		pointLight.Range = 15
		pointLight.Parent = enchanterMain
		print("[EnchanterService] Created PointLight")
	end
	
	print("[EnchanterService] Connecting ProximityPrompt trigger...")
	-- Connect the prompt trigger with error handling
	local success, err = pcall(function()
		prompt.Triggered:Connect(function(player)
			print("[EnchanterService] Enchanter prompt triggered by", player.Name)
			onEnchanterPromptTriggered(player, enchanterMain)
		end)
	end)
	
	if not success then
		warn("[EnchanterService] Failed to connect ProximityPrompt trigger:", err)
	else
		print("[EnchanterService] Successfully connected ProximityPrompt trigger")
	end
	
	-- Function to update enchanter visual appearance based on player unlock status
	local function updateEnchanterVisual(player)
		local RebirthService = require(script.Parent.RebirthService)
		local isUnlocked = RebirthService.IsFeatureUnlocked(player, "Enchanter")
		
		if isUnlocked then
			prompt.ActionText = "Use Enchanter"
			prompt.ObjectText = "Item Enchanter"
			enchanterMain.Color = Color3.fromRGB(150, 100, 255) -- Normal purple
			if pointLight then
				pointLight.Color = Color3.fromRGB(150, 100, 255)
			end
		else
			prompt.ActionText = "Unlocks On Rebirth 4"
			prompt.ObjectText = "Item Enchanter (Locked)"
			enchanterMain.Color = Color3.fromRGB(50, 50, 50) -- Dark gray
			if pointLight then
				pointLight.Color = Color3.fromRGB(50, 50, 50)
			end
		end
		
		-- Paint EnchantingArea parts (client-side will handle this, but we can send a signal)
		Remotes.UpdateEnchanterVisual:FireClient(player, isUnlocked)
	end
	
	-- Update visual for all players initially
	print("[EnchanterService] Updating visual for all players...")
	for _, player in pairs(Players:GetPlayers()) do
		updateEnchanterVisual(player)
	end
	
	-- Update visual when new players join
	Players.PlayerAdded:Connect(function(player)
		task.wait(1) -- Wait for player data to load
		updateEnchanterVisual(player)
	end)
	
	-- Verify the prompt was created successfully
	task.wait(0.1) -- Small delay to ensure everything is set up
	local verifyPrompt = enchanterMain:FindFirstChildOfClass("ProximityPrompt")
	if verifyPrompt then
		print("[EnchanterService] ✓ ProximityPrompt verified and ready at position:", enchanterMain.Position)
		print("[EnchanterService] Final verification - Prompt exists:", verifyPrompt ~= nil)
		print("[EnchanterService] Prompt ActionText:", verifyPrompt.ActionText)
		print("[EnchanterService] Prompt ObjectText:", verifyPrompt.ObjectText)
		print("[EnchanterService] Prompt Parent:", verifyPrompt.Parent.Name)
	else
		warn("[EnchanterService] ✗ ProximityPrompt verification failed!")
		warn("[EnchanterService] EnchanterMain children:", enchanterMain:GetChildren())
	end
end

-- Monitor and recreate ProximityPrompt if needed
local function monitorProximityPrompt()
	task.spawn(function()
		while task.wait(5) do -- Check every 5 seconds
			local promptsFolder = workspace:FindFirstChild("ProximityPrompts")
			if promptsFolder then
				local enchanterMain = promptsFolder:FindFirstChild("EnchanterMain")
				if enchanterMain then
					local prompt = enchanterMain:FindFirstChildOfClass("ProximityPrompt")
					if not prompt then
						print("[EnchanterService] ProximityPrompt missing, recreating...")
						setupEnchanterPrompt()
					end
				else
					print("[EnchanterService] EnchanterMain missing, recreating...")
					setupEnchanterPrompt()
				end
			else
				print("[EnchanterService] ProximityPrompts folder missing, recreating...")
				setupEnchanterPrompt()
			end
		end
	end)
end

-- Expose setupEnchanterPrompt for external use
EnchanterService.SetupPrompt = setupEnchanterPrompt

-- Test function to verify ProximityPrompt exists
local function testProximityPrompt()
	print("[EnchanterService] Testing ProximityPrompt existence...")
	
	local promptsFolder = workspace:FindFirstChild("ProximityPrompts")
	if not promptsFolder then
		warn("[EnchanterService] ✗ ProximityPrompts folder not found!")
		return false
	end
	
	local enchanterMain = promptsFolder:FindFirstChild("EnchanterMain")
	if not enchanterMain then
		warn("[EnchanterService] ✗ EnchanterMain part not found!")
		return false
	end
	
	local prompt = enchanterMain:FindFirstChildOfClass("ProximityPrompt")
	if not prompt then
		warn("[EnchanterService] ✗ ProximityPrompt not found!")
		return false
	end
	
	print("[EnchanterService] ✓ ProximityPrompt test passed!")
	print("[EnchanterService] Prompt details:")
	print("  - ActionText:", prompt.ActionText)
	print("  - ObjectText:", prompt.ObjectText)
	print("  - MaxActivationDistance:", prompt.MaxActivationDistance)
	print("  - Parent:", prompt.Parent.Name)
	print("  - Position:", enchanterMain.Position)
	
	return true
end

function EnchanterService.Start()
	print("[EnchanterService] Starting EnchanterService...")
	
	-- Save original builds first
	saveOriginalBuild()
	saveCollectionBuild()
	
	-- Setup the ProximityPrompt
	setupEnchanterPrompt()
	
	-- Start monitoring the ProximityPrompt
	monitorProximityPrompt()
	
	-- Test the ProximityPrompt after a short delay
	task.wait(1)
	testProximityPrompt()
	
	-- Verify the prompt was created
	local promptsFolder = workspace:FindFirstChild("ProximityPrompts")
	if promptsFolder then
		local enchanterMain = promptsFolder:FindFirstChild("EnchanterMain")
		if enchanterMain then
			local prompt = enchanterMain:FindFirstChildOfClass("ProximityPrompt")
			if prompt then
				print("[EnchanterService] ✓ ProximityPrompt successfully created")
			else
				print("[EnchanterService] ✗ ProximityPrompt not found!")
			end
		else
			print("[EnchanterService] ✗ EnchanterMain part not found!")
		end
	else
		print("[EnchanterService] ✗ ProximityPrompts folder not found!")
	end
	
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
	Remotes.RecreateEnchanterPrompt.OnServerEvent:Connect(function(player)
		print("[EnchanterService] Recreating ProximityPrompt at request of", player.Name)
		setupEnchanterPrompt()
	end)
	
	print("[EnchanterService] Started successfully!")
end

-- Clean up auto-enchanting sessions when players leave
Players.PlayerRemoving:Connect(function(player)
	if activeAutoEnchantSessions[player.UserId] then
		activeAutoEnchantSessions[player.UserId] = nil
	end
end)

return EnchanterService 