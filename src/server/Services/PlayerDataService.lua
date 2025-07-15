local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Import modules
local Shared = ReplicatedStorage.Shared
local GameConfig = require(Shared.Modules.GameConfig)
local ItemValueCalculator = require(Shared.Modules.ItemValueCalculator)
local NumberFormatter = require(Shared.Modules.NumberFormatter)
local Remotes = require(Shared.Remotes.Remotes)

-- It's good practice to have a unique key for your datastore
-- and to version it in case you change the data structure later.
local playerDataStore = DataStoreService:GetDataStore("PlayerData_UGC_V1")
local rapLeaderboardStore = DataStoreService:GetOrderedDataStore("RAPLeaderboard_V1")
local boxesLeaderboardStore = DataStoreService:GetOrderedDataStore("BoxesLeaderboard_V1")
local autoSettingsStore = DataStoreService:GetDataStore("AutoSettings")

local DataService = {}
local autoSettingsCache = autoSettingsCache or {}

-- PERFORMANCE OPTIMIZATION: Throttling and caching systems
local rapUpdateQueue = {}
local boxesUpdateQueue = {}
local rapUpdateCooldowns = {} -- player.UserId -> last update time
local rapCache = {} -- player.UserId -> cached RAP value
local isUpdating = false
local isUpdatingBoxes = false
local DEBOUNCE_INTERVAL = 5 -- Reduced from 10 to 5 seconds for more frequent updates
local RAP_UPDATE_COOLDOWN = 1 -- Reduced from 3 to 1 second for more frequent RAP updates
local SAVE_COOLDOWN = 3 -- Reduced from 5 to 3 seconds for more frequent saves
local lastSaveTimes = {} -- player.UserId -> last save time

-- Collection and save throttling
local collectionUpdateQueue = {}
local saveQueue = {}
local collectionUpdateCooldowns = {} -- player.UserId -> last collection update time
local COLLECTION_UPDATE_COOLDOWN = 5 -- Reduced from 10 to 5 seconds for more frequent collection updates

-- OPTIMIZED: Instant inventory loading configuration
local INVENTORY_BATCH_SIZE = 1000 -- Process inventory items in much larger batches for speed
local INSTANT_LOADING = true -- Enable instant loading for better performance

-- OPTIMIZED: Cache RAP calculations to avoid expensive recalculations
local function calculatePlayerRAP(player)
	local inventory = player:FindFirstChild("Inventory")
	if not inventory then return 0, 0 end
	
	local inventoryData = {}
	for _, item in ipairs(inventory:GetChildren()) do
		-- Get the actual item name from attribute (UUID system)
		local itemName = item:GetAttribute("ItemName") or item.Name
		local itemConfig = GameConfig.Items[itemName]
		if itemConfig then
			local mutationConfigs = ItemValueCalculator.GetMutationConfigs(item)
			local size = item:GetAttribute("Size") or 1
			
			table.insert(inventoryData, {
				ItemName = itemName,
				ItemConfig = itemConfig,
				MutationConfigs = mutationConfigs,
				Size = size
			})
		end
	end
	
	return ItemValueCalculator.CalculateRAP(inventoryData)
end

-- OPTIMIZED: Throttled RAP updates
local function updatePlayerRAP(player)
	local userId = player.UserId
	local currentTime = tick()
	
	-- Check if we're in cooldown for this player
	local lastUpdate = rapUpdateCooldowns[userId]
	if lastUpdate and (currentTime - lastUpdate) < RAP_UPDATE_COOLDOWN then
		return -- Skip update if in cooldown
	end
	
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return end
	
	-- Calculate the new RAP value
	local totalRAP = calculatePlayerRAP(player)
	
	-- Cache the RAP value
	rapCache[userId] = totalRAP
	rapUpdateCooldowns[userId] = currentTime
	
	-- Update the player attribute
	player:SetAttribute("RAPValue", totalRAP)
	
	-- Update the formatted display
	local rapDisplay = leaderstats:FindFirstChild("RAP")
	if rapDisplay then
		rapDisplay.Value = NumberFormatter.FormatNumber(totalRAP)
	end
	
	-- Queue the leaderboard update instead of calling directly
	rapUpdateQueue[userId] = player
end

-- OPTIMIZED: Ultra-fast inventory loading function
local function loadInventoryBatch(inventory, itemDataList, startIndex, batchSize)
	local endIndex = math.min(startIndex + batchSize - 1, #itemDataList)
	local HttpService = game:GetService("HttpService")
	
	-- Pre-allocate all items to avoid repeated Instance.new calls
	local itemsToAdd = {}
	
	for i = startIndex, endIndex do
		local itemData = itemDataList[i]
		local item = Instance.new("StringValue")
		
		-- Use UUID if available, otherwise fall back to legacy name-based system
		if itemData.uuid then
			item.Name = itemData.uuid
			item:SetAttribute("ItemName", itemData.name)
		else
			-- Legacy support: generate UUID for old items
			local uuid = HttpService:GenerateGUID(false)
			item.Name = uuid
			item:SetAttribute("ItemName", itemData.name)
		end
		
		item:SetAttribute("Size", itemData.size)
		if itemData.mutations then
			-- New multiple mutations format
			item:SetAttribute("Mutations", HttpService:JSONEncode(itemData.mutations))
			-- Keep backward compatibility with single Mutation attribute
			item:SetAttribute("Mutation", itemData.mutations[1])
		elseif itemData.mutation then
			-- Legacy single mutation format
			item:SetAttribute("Mutation", itemData.mutation)
			-- Also store in new format for consistency
			item:SetAttribute("Mutations", HttpService:JSONEncode({itemData.mutation}))
		end
		if itemData.locked then
			item:SetAttribute("Locked", itemData.locked)
		end
		
		-- Add to batch instead of setting parent immediately
		table.insert(itemsToAdd, item)
	end
	
	-- Bulk add all items to inventory at once
	for _, item in ipairs(itemsToAdd) do
		item.Parent = inventory
	end
	
		return endIndex >= #itemDataList
end

-- When updating R$ or Boxes Opened, update both the attribute and the StringValue
local function updatePlayerRobux(player, value)
	player:SetAttribute("RobuxValue", value)
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local robuxNumber = leaderstats:FindFirstChild("R$")
		if robuxNumber then
			robuxNumber.Value = NumberFormatter.FormatNumber(value)
		end
		local robuxDisplay = leaderstats:FindFirstChild("R$ Display")
		if robuxDisplay then
			robuxDisplay.Value = NumberFormatter.FormatNumber(value)
		end
	end
end

local function updatePlayerBoxesOpened(player, value)
	player:SetAttribute("BoxesOpenedValue", value)
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local boxesOpened = leaderstats:FindFirstChild("Boxes Opened")
		if boxesOpened then
			boxesOpened.Value = NumberFormatter.FormatCount(value)
		end
	end
	
	-- Queue the boxes leaderboard update
	boxesUpdateQueue[player.UserId] = player
end

local function updatePlayerRebirths(player, value)
	player:SetAttribute("RebirthsValue", value)
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local rebirths = leaderstats:FindFirstChild("Rebirths")
		if rebirths then
			rebirths.Value = tostring(value)
		end
	end
end

-- Import AvatarService for equipped items (will be required after it's created)
local AvatarService


-- Custom StringValue for formatted Rebirths display
local function createFormattedRebirthsStat(player, leaderstats, initialValue)
	player:SetAttribute("RebirthsValue", initialValue)
	local rebirthsDisplay = Instance.new("StringValue")
	rebirthsDisplay.Name = "Rebirths"
	rebirthsDisplay.Value = tostring(initialValue)
	rebirthsDisplay.Parent = leaderstats
	return rebirthsDisplay
end

-- Custom StringValue for formatted RAP display
local function createFormattedRAPStat(player, leaderstats, initialValue)
	-- Store the numeric value as a player attribute (hidden from leaderboard)
	player:SetAttribute("RAPValue", initialValue)
	
	-- Create only a StringValue for the formatted display in leaderboard
	local rapDisplay = Instance.new("StringValue")
	rapDisplay.Name = "RAP"
	rapDisplay.Value = NumberFormatter.FormatNumber(initialValue)
	rapDisplay.Parent = leaderstats
	
	return rapDisplay
end

-- Custom StringValue for formatted R$ display
local function createFormattedRobuxStat(player, leaderstats, initialValue)
	player:SetAttribute("RobuxValue", initialValue)
	local robuxDisplay = Instance.new("StringValue")
	robuxDisplay.Name = "R$"
	robuxDisplay.Value = NumberFormatter.FormatNumber(initialValue)
	robuxDisplay.Parent = leaderstats
	return robuxDisplay
end

-- Custom StringValue for formatted Boxes Opened display
local function createFormattedBoxesStat(player, leaderstats, initialValue)
	player:SetAttribute("BoxesOpenedValue", initialValue)
	local boxesDisplay = Instance.new("StringValue")
	boxesDisplay.Name = "Boxes Opened"
	boxesDisplay.Value = NumberFormatter.FormatCount(initialValue)
	boxesDisplay.Parent = leaderstats
	return boxesDisplay
end

-- OPTIMIZED: Process leaderboard updates with throttling
	local function processUpdateQueue()
		if isUpdating then return end
		isUpdating = true
		
		-- Process RAP updates more frequently
		for userId, player in pairs(rapUpdateQueue) do
			if player and player.Parent and player.UserId then
				local currentTime = tick()
				local lastUpdate = rapUpdateCooldowns[userId]
				if not lastUpdate or (currentTime - lastUpdate) >= RAP_UPDATE_COOLDOWN then
					updatePlayerRAP(player)
					rapUpdateCooldowns[userId] = currentTime
				end
			end
		end

	local playersToUpdate = {}
	for userId, player in pairs(rapUpdateQueue) do
		-- Validate player is still in the game before adding to process list
		if player and player.Parent and player.UserId then
			local stillInGame = false
			for _, activePlayer in ipairs(Players:GetPlayers()) do
				if activePlayer == player then
					stillInGame = true
					break
				end
			end
			if stillInGame then
		table.insert(playersToUpdate, player)
			else
				-- Remove from queue if player is no longer in game
				rapUpdateQueue[userId] = nil
			end
		else
			-- Remove invalid player from queue
			rapUpdateQueue[userId] = nil
		end
	end
	rapUpdateQueue = {} -- Clear the queue

	if #playersToUpdate > 0 then
		print("Processing RAP leaderboard updates for " .. #playersToUpdate .. " players.")
		for _, player in ipairs(playersToUpdate) do
			task.spawn(function() -- Make leaderboard updates async to prevent blocking
				-- Use the player attribute for the leaderboard ranking
				local rapValue = player:GetAttribute("RAPValue") or 0
				local success, err = pcall(function()
					rapLeaderboardStore:SetAsync(tostring(player.UserId), rapValue)
				end)
				if not success then
					warn("Failed to update RAP for " .. (player.Name or "Unknown") .. " in leaderboard: " .. tostring(err))
				end
			end)
		end
	end

	isUpdating = false
end

local function processBoxesUpdateQueue()
	if isUpdatingBoxes then return end
	isUpdatingBoxes = true

	local playersToUpdate = {}
	for userId, player in pairs(boxesUpdateQueue) do
		-- Validate player is still in the game before adding to process list
		if player and player.Parent and player.UserId then
			local stillInGame = false
			for _, activePlayer in ipairs(Players:GetPlayers()) do
				if activePlayer == player then
					stillInGame = true
					break
				end
			end
			if stillInGame then
		table.insert(playersToUpdate, player)
			else
				-- Remove from queue if player is no longer in game
				boxesUpdateQueue[userId] = nil
			end
		else
			-- Remove invalid player from queue
			boxesUpdateQueue[userId] = nil
		end
	end
	boxesUpdateQueue = {} -- Clear the queue

	if #playersToUpdate > 0 then
		print("Processing boxes leaderboard updates for " .. #playersToUpdate .. " players.")
		for _, player in ipairs(playersToUpdate) do
			task.spawn(function() -- Make leaderboard updates async to prevent blocking
				-- Use the player attribute for the leaderboard ranking
				local boxesValue = player:GetAttribute("BoxesOpenedValue") or 0
				local success, err = pcall(function()
					boxesLeaderboardStore:SetAsync(tostring(player.UserId), boxesValue)
				end)
				if not success then
					warn("Failed to update boxes for " .. (player.Name or "Unknown") .. " in leaderboard: " .. tostring(err))
				end
			end)
		end
	end

	isUpdatingBoxes = false
end

local function saveData(player: Player)
	-- Enhanced player validation
	if not player or not player.Parent or not player.UserId then 
		warn("saveData called for an invalid player.")
		return 
	end
	
	-- Check if player is still in the game
	local playerStillExists = false
	for _, existingPlayer in ipairs(Players:GetPlayers()) do
		if existingPlayer == player then
			playerStillExists = true
			break
		end
	end
	
	-- If player left, we can still save using their cached data, but need to be more careful
	if not playerStillExists then
		print("Player " .. (player.Name or "Unknown") .. " has left, performing final save...")
	end

	local userId = player.UserId
	local currentTime = tick()
	
	-- Check if we're in cooldown for this player (skip for force saves)
	local lastSave = lastSaveTimes[userId]
	if lastSave and (currentTime - lastSave) < SAVE_COOLDOWN then
		print("Skipping save for " .. player.Name .. " - in cooldown")
		return -- Skip save if in cooldown
	end
	
	local key = "Player_" .. userId
	
	-- Create the data table in one go
	-- Use raw attribute values instead of formatted StringValues
	local robuxValue = player:GetAttribute("RobuxValue") or 0
	local boxesOpenedValue = player:GetAttribute("BoxesOpenedValue") or 0
	local leaderstats = player:FindFirstChild("leaderstats")
	local inventory = player:FindFirstChild("Inventory")
	
	local dataToSave = {
		robux = robuxValue,
		boxesOpened = boxesOpenedValue,
		inventory = {},
		equippedItems = {},
	}

	if inventory then
		for _, item in ipairs(inventory:GetChildren()) do
			local itemData = {
				uuid = item.Name, -- Save the UUID as the unique identifier
				name = item:GetAttribute("ItemName") or item.Name, -- ItemName attribute or legacy fallback
				size = item:GetAttribute("Size"),
				locked = item:GetAttribute("Locked")
			}
			
			-- Save mutations in new format if available, fall back to old format
			local mutationsJson = item:GetAttribute("Mutations")
			if mutationsJson then
				local HttpService = game:GetService("HttpService")
				local success, mutations = pcall(function()
					return HttpService:JSONDecode(mutationsJson)
				end)
				if success and mutations then
					itemData.mutations = mutations
					-- Also save first mutation for backward compatibility
					itemData.mutation = mutations[1]
				end
			else
				-- Legacy single mutation format
				local singleMutation = item:GetAttribute("Mutation")
				if singleMutation then
					itemData.mutation = singleMutation
				end
			end
			
			table.insert(dataToSave.inventory, itemData)
		end
	end
	
	-- Save equipped items
	if not AvatarService then
		AvatarService = require(script.Parent.AvatarService)
	end
	-- Use the shared service to get a clean, savable table of equipped items
	local SharedAvatarService = require(game.ReplicatedStorage.Shared.Services.AvatarService)
	dataToSave.equippedItems = SharedAvatarService.GetSerializableEquippedItems(player)
	
	-- Save upgrade data
	local UpgradeService = require(script.Parent.UpgradeService)
	dataToSave.upgrades = UpgradeService.GetPlayerUpgrades(player)
	print("[SAVE DEBUG] Upgrades for " .. player.Name .. ":", game:GetService("HttpService"):JSONEncode(dataToSave.upgrades or {}))
	
	-- Save rebirth data
	local RebirthService = require(script.Parent.RebirthService)
	dataToSave.rebirths = RebirthService.GetPlayerRebirthsForSave(player)
	print("[SAVE DEBUG] Rebirths for " .. player.Name .. ":", game:GetService("HttpService"):JSONEncode(dataToSave.rebirths or {}))
	
	-- Save settings data
	local settingsJson = player:GetAttribute("GameSettings")
	if settingsJson then
		local success, settings = pcall(function()
			return game:GetService("HttpService"):JSONDecode(settingsJson)
		end)
		if success and settings then
			dataToSave.settings = settings
			print("[SAVE DEBUG] Settings for " .. player.Name .. ":", settingsJson)
		else
			print("[SAVE DEBUG] Failed to decode settings for " .. player.Name .. ":", settingsJson)
		end
	else
		print("[SAVE DEBUG] No settings attribute found for " .. player.Name)
	end

	-- Save auto-settings data (auto-open, auto-sell, auto-enchanter settings)
	local autoSettings = DataService.GetAutoSettings(player.UserId)
	if autoSettings then
		dataToSave.autoSettings = autoSettings
		print("[SAVE DEBUG] Auto-settings for " .. player.Name .. ":", game:GetService("HttpService"):JSONEncode(autoSettings))
	else
		print("[SAVE DEBUG] No auto-settings found for " .. player.Name)
	end

	-- Save selected crate data
	local selectedCrateJson = player:GetAttribute("SelectedCrate")
	if selectedCrateJson then
		local success, selectedCrate = pcall(function()
			return game:GetService("HttpService"):JSONDecode(selectedCrateJson)
		end)
		if success and selectedCrate then
			dataToSave.selectedCrate = selectedCrate
			print("[SAVE DEBUG] Selected crate for " .. player.Name .. ":", game:GetService("HttpService"):JSONEncode(selectedCrate))
		else
			print("[SAVE DEBUG] Failed to decode selected crate for " .. player.Name .. ":", selectedCrateJson)
		end
	else
		print("[SAVE DEBUG] No selected crate attribute found for " .. player.Name)
	end

	-- Save RAP value
	local rapValue = player:GetAttribute("RAPValue") or 0
	dataToSave.rapValue = rapValue
	print("[SAVE DEBUG] RAP value for " .. player.Name .. ":", rapValue)

	-- Save rebirths value
	local rebirthsValue = player:GetAttribute("RebirthsValue") or 0
	dataToSave.rebirthsValue = rebirthsValue
	print("[SAVE DEBUG] Rebirths value for " .. player.Name .. ":", rebirthsValue)

	-- Save collection data
	local collectionData = DataService.GetPlayerCollection(player)
	if collectionData then
		dataToSave.collection = collectionData
		print("[SAVE DEBUG] Collection data for " .. player.Name .. ":", game:GetService("HttpService"):JSONEncode(collectionData))
	else
		print("[SAVE DEBUG] No collection data found for " .. player.Name)
	end

	-- Save leaderboard data
	local rapValue = player:GetAttribute("RAPValue") or 0
	local boxesValue = player:GetAttribute("BoxesOpenedValue") or 0
	dataToSave.leaderboardData = {
		rapValue = rapValue,
		boxesValue = boxesValue
	}
	print("[SAVE DEBUG] Leaderboard data for " .. player.Name .. ":", game:GetService("HttpService"):JSONEncode(dataToSave.leaderboardData))

	-- Save tutorial completion status
	local TutorialService = require(script.Parent.TutorialService)
	dataToSave.tutorialCompleted = TutorialService.HasCompletedTutorial(player)
	print("[SAVE DEBUG] Tutorial completion for " .. player.Name .. ":", dataToSave.tutorialCompleted)

	-- Debug: Print complete save structure
	print("[SAVE DEBUG] Complete save data for " .. player.Name .. ":")
	print("  - Robux:", dataToSave.robux)
	print("  - Boxes Opened:", dataToSave.boxesOpened)
	print("  - RAP Value:", dataToSave.rapValue)
	print("  - Rebirths Value:", dataToSave.rebirthsValue)
	print("  - Inventory Items:", #(dataToSave.inventory or {}))
	print("  - Equipped Items:", game:GetService("HttpService"):JSONEncode(dataToSave.equippedItems or {}))
	print("  - Upgrades:", game:GetService("HttpService"):JSONEncode(dataToSave.upgrades or {}))
	print("  - Rebirths:", game:GetService("HttpService"):JSONEncode(dataToSave.rebirths or {}))
	print("  - Settings:", game:GetService("HttpService"):JSONEncode(dataToSave.settings or {}))
	print("  - Auto-Settings:", game:GetService("HttpService"):JSONEncode(dataToSave.autoSettings or {}))
	print("  - Collection:", game:GetService("HttpService"):JSONEncode(dataToSave.collection or {}))
	print("  - Leaderboard Data:", game:GetService("HttpService"):JSONEncode(dataToSave.leaderboardData or {}))
	print("  - Tutorial Completed:", dataToSave.tutorialCompleted)

	-- Retry logic for DataStore operations
	if not playerDataStore then
		warn("Player datastore is nil, cannot save data for " .. player.Name)
		return
	end
	
	local attempts = 0
	local success = false
	while not success and attempts < 3 do
		attempts = attempts + 1
		local ok, err = pcall(function()
			if attempts == 1 then -- Only log on first attempt to avoid spam
				local keys = {}
				for k, _ in pairs(dataToSave) do table.insert(keys, k) end
				print("[SAVE DEBUG] Saving to DataStore for " .. player.Name .. " with keys:", table.concat(keys, ", "))
			end
			playerDataStore:SetAsync(key, dataToSave)
		end)

		success = ok
		if not success then
			warn("Failed to save data for " .. player.Name .. " (Attempt " .. attempts .. "): " .. tostring(err))
			if attempts < 3 then
				task.wait(1) -- Reduced wait time from 2 to 1 second
			end
		end
	end

	if success then
		-- Also update leaderboard stores
		local rapValue = player:GetAttribute("RAPValue") or 0
		local boxesValue = player:GetAttribute("BoxesOpenedValue") or 0
		
		-- Update RAP leaderboard
		if rapLeaderboardStore then
			pcall(function()
				rapLeaderboardStore:SetAsync(tostring(player.UserId), rapValue)
			end)
		end
		
		-- Update boxes leaderboard
		if boxesLeaderboardStore then
			pcall(function()
				boxesLeaderboardStore:SetAsync(tostring(player.UserId), boxesValue)
			end)
		end
		
		-- Update collection datastore
		if collectionDataStore then
			local collectionData = DataService.GetPlayerCollection(player)
			if collectionData then
				local collectionKey = "collection_" .. player.UserId
				pcall(function()
					collectionDataStore:SetAsync(collectionKey, collectionData)
				end)
			end
		end
		
		-- Update auto-settings datastore
		if autoSettingsStore then
			local autoSettings = DataService.GetAutoSettings(player.UserId)
			if autoSettings then
				pcall(function()
					autoSettingsStore:SetAsync(tostring(player.UserId), autoSettings)
				end)
			end
		end
		
		lastSaveTimes[userId] = currentTime -- Update last save time
		print("Player data saved for " .. player.Name)
	else
		warn("FATAL: Could not save data for " .. player.Name .. " after 3 attempts.")
	end
end

-- OPTIMIZED: Process save queue with throttling
local function processSaveQueue()
	local playersToSave = {}
	for userId, player in pairs(saveQueue) do
		-- Validate player is still in the game before adding to process list
		if player and player.Parent and player.UserId then
			local stillInGame = false
			for _, activePlayer in ipairs(Players:GetPlayers()) do
				if activePlayer == player then
					stillInGame = true
					break
				end
			end
			if stillInGame then
				table.insert(playersToSave, player)
			else
				-- Remove from queue if player is no longer in game
				saveQueue[userId] = nil
			end
		else
			-- Remove invalid player from queue
			saveQueue[userId] = nil
		end
	end
	saveQueue = {} -- Clear the queue
	
	if #playersToSave > 0 then
		print("Processing save queue for " .. #playersToSave .. " players.")
		for _, player in ipairs(playersToSave) do
			task.spawn(function()
				saveData(player)
			end)
		end
	end
end

-- Internal function to update player's collection based on current inventory
local function UpdatePlayerCollectionInternal(player)
	local inventory = player:FindFirstChild("Inventory")
	if not inventory then return end
	
	local userId = player.UserId
	local currentTime = tick()
	
	-- Check if we're in cooldown for this player
	local lastCollectionUpdate = collectionUpdateCooldowns[userId]
	if lastCollectionUpdate and (currentTime - lastCollectionUpdate) < COLLECTION_UPDATE_COOLDOWN then
		return -- Skip update if in cooldown
	end
	
	task.spawn(function()
		local userId = player.UserId
		local collectionKey = "collection_" .. userId
		
		-- Load existing collection
		local existingCollection = {}
		if collectionDataStore then
			local success, data = pcall(function()
				return collectionDataStore:GetAsync(collectionKey)
			end)
			
			if success and data then
				existingCollection = data
			end
		else
			warn("Collection datastore is nil, cannot load collection for " .. player.Name)
		end
		
		-- Update collection with current inventory
		local hasUpdates = false
		for _, item in ipairs(inventory:GetChildren()) do
			local itemName = item:GetAttribute("ItemName")
			local itemConfig = GameConfig.Items[itemName]
			
			if itemConfig then
				local size = item:GetAttribute("Size") or 1
				local mutations = {}
				
				-- Get mutations
				local mutationsJson = item:GetAttribute("Mutations")
				if mutationsJson then
					local HttpService = game:GetService("HttpService")
					local decodeSuccess, decodedMutations = pcall(function()
						return HttpService:JSONDecode(mutationsJson)
					end)
					if decodeSuccess and decodedMutations then
						mutations = decodedMutations
					end
				else
					local singleMutation = item:GetAttribute("Mutation")
					if singleMutation then
						mutations = {singleMutation}
					end
				end
				
				-- Initialize item collection if not exists
				if not existingCollection[itemName] then
					existingCollection[itemName] = {
						Discovered = true,
						MaxSize = size,
						Mutations = {}
					}
					hasUpdates = true
				else
					-- Update max size if current item is larger
					if size > existingCollection[itemName].MaxSize then
						existingCollection[itemName].MaxSize = size
						hasUpdates = true
					end
				end
				
				-- Track mutations discovered
				for _, mutationName in ipairs(mutations) do
					if not existingCollection[itemName].Mutations[mutationName] then
						existingCollection[itemName].Mutations[mutationName] = true
						hasUpdates = true
					end
				end
				
				-- Track if item was found without mutations
				if #mutations == 0 then
					if not existingCollection[itemName].Mutations["None"] then
						existingCollection[itemName].Mutations["None"] = true
						hasUpdates = true
					end
				end
			end
		end
		
		-- Save updated collection if there are changes
		if hasUpdates then
			-- Collection data is now saved through the main saveData function
			-- Queue a save to ensure collection data is persisted
			saveQueue[player.UserId] = player
			print("Collection updated for " .. player.Name .. " - queued for save")
		end
		collectionUpdateCooldowns[userId] = currentTime -- Update last collection update time
	end)
end

-- OPTIMIZED: Process collection updates with throttling
local function processCollectionQueue()
	local playersToUpdate = {}
	for userId, player in pairs(collectionUpdateQueue) do
		-- Validate player is still in the game before adding to process list
		if player and player.Parent and player.UserId then
			local stillInGame = false
			for _, activePlayer in ipairs(Players:GetPlayers()) do
				if activePlayer == player then
					stillInGame = true
					break
				end
			end
			if stillInGame then
				table.insert(playersToUpdate, player)
			else
				-- Remove from queue if player is no longer in game
				collectionUpdateQueue[userId] = nil
			end
		else
			-- Remove invalid player from queue
			collectionUpdateQueue[userId] = nil
		end
	end
	collectionUpdateQueue = {} -- Clear the queue
	
	if #playersToUpdate > 0 and collectionDataStore then
		print("Processing collection updates for " .. #playersToUpdate .. " players.")
		for _, player in ipairs(playersToUpdate) do
			task.spawn(function()
				-- Call the actual collection update function directly
				UpdatePlayerCollectionInternal(player)
			end)
		end
	end
end

-- Start the debouncer loop with better performance
task.spawn(function()
	while true do
		task.wait(2) -- Reduced from DEBOUNCE_INTERVAL to 2 seconds for more frequent updates
		-- processUpdateQueue() -- REMOVED: RAP leaderboard updates now handled in saveData
		-- processBoxesUpdateQueue() -- REMOVED: Boxes leaderboard updates now handled in saveData
		processSaveQueue()
		processCollectionQueue()
	end
end)

local function onPlayerAdded(player: Player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	-- Create inventory folder
	local inventory = Instance.new("Folder")
	inventory.Name = "Inventory"
	inventory.Parent = player

	-- Set loading flag to prevent saves during initial loading
	player:SetAttribute("IsLoadingInventory", true)

	-- Use formatted StringValues for all stats
	local robux = createFormattedRobuxStat(player, leaderstats, GameConfig.Currency.StartingAmount)
	local boxesOpened = createFormattedBoxesStat(player, leaderstats, 0)
	createFormattedRAPStat(player, leaderstats, 0)
	createFormattedRebirthsStat(player, leaderstats, 0)

	local userId = player.UserId
	local key = "Player_" .. userId

	-- Load data asynchronously
	task.spawn(function()
		local data
		local success, err = pcall(function()
			data = playerDataStore:GetAsync(key)
		end)

		if success and data then
			-- Player has data, load it
			updatePlayerRobux(player, data.robux or GameConfig.Currency.StartingAmount)
			updatePlayerBoxesOpened(player, data.boxesOpened or 0)
			
			-- OPTIMIZED: Load inventory instantly for better performance
			if data.inventory and #data.inventory > 0 then
				print(string.format("Loading %d inventory items for %s instantly...", #data.inventory, player.Name))
				
				-- Load all inventory items instantly in one go
				loadInventoryBatch(inventory, data.inventory, 1, #data.inventory)
				
						print("Inventory loading complete for " .. player.Name)
						
						-- Load upgrade data
						local UpgradeService = require(script.Parent.UpgradeService)
						local UpgradeConfig = require(game.ReplicatedStorage.Shared.Modules.UpgradeConfig)
						if data.upgrades then
							print("[LOAD DEBUG] Loading upgrades for " .. player.Name .. ":", game:GetService("HttpService"):JSONEncode(data.upgrades))
							local missingUpgrades = {}
							for upgradeId, level in pairs(data.upgrades) do
								UpgradeService.SetPlayerUpgradeLevel(player, upgradeId, level)
								print("[LOAD DEBUG] Set upgrade " .. upgradeId .. " to level " .. level .. " for " .. player.Name)
							end
							-- Ensure all upgrade IDs are present
							for upgradeId, _ in pairs(UpgradeConfig.Upgrades) do
								if data.upgrades[upgradeId] == nil then
									UpgradeService.SetPlayerUpgradeLevel(player, upgradeId, 0)
									table.insert(missingUpgrades, upgradeId)
								end
							end
							if #missingUpgrades > 0 then
								warn("[LOAD WARNING] Some upgrades missing for " .. player.Name .. ": " .. table.concat(missingUpgrades, ", "))
							end
						else
							print("[LOAD DEBUG] No upgrades data found for " .. player.Name .. " - will initialize to defaults")
							-- Initialize with defaults since no saved data exists
							local UpgradeConfig = require(game.ReplicatedStorage.Shared.Modules.UpgradeConfig)
							for upgradeId, _ in pairs(UpgradeConfig.Upgrades) do
								UpgradeService.SetPlayerUpgradeLevel(player, upgradeId, 0)
							end
						end
						
						-- Load settings data
						if data.settings then
							-- Store settings in player object for quick access
							local settingsJson = game:GetService("HttpService"):JSONEncode(data.settings)
							player:SetAttribute("GameSettings", settingsJson)
							print("[LOAD DEBUG] Loaded settings for " .. player.Name .. ":", settingsJson)
						else
							print("[LOAD DEBUG] No settings data found for " .. player.Name)
						end
						
						-- Load rebirth data
						local RebirthService = require(script.Parent.RebirthService)
						if data.rebirths then
							RebirthService.LoadPlayerRebirthsFromSave(player, data.rebirths)
							print("[LOAD DEBUG] Loaded rebirths for " .. player.Name .. ":", game:GetService("HttpService"):JSONEncode(data.rebirths))
							-- Update rebirths leaderstat
							DataService.UpdatePlayerRebirths(player, data.rebirths.currentRebirth or 0)
						else
							print("[LOAD DEBUG] No rebirth data found for " .. player.Name)
							-- Initialize rebirths to 0
							DataService.UpdatePlayerRebirths(player, 0)
						end

										-- Load auto-settings data
				if data.autoSettings then
					DataService.SetAutoSettings(player.UserId, data.autoSettings)
					print("[LOAD DEBUG] Loaded auto-settings for " .. player.Name .. ":", game:GetService("HttpService"):JSONEncode(data.autoSettings))
				else
					print("[LOAD DEBUG] No auto-settings found for " .. player.Name)
				end

				-- Load selected crate data
				if data.selectedCrate then
					local selectedCrateJson = game:GetService("HttpService"):JSONEncode(data.selectedCrate)
					player:SetAttribute("SelectedCrate", selectedCrateJson)
					print("[LOAD DEBUG] Loaded selected crate for " .. player.Name .. ":", game:GetService("HttpService"):JSONEncode(data.selectedCrate))
				else
					print("[LOAD DEBUG] No selected crate data found for " .. player.Name)
				end

						-- Load RAP value
						if data.rapValue then
							player:SetAttribute("RAPValue", data.rapValue)
							print("[LOAD DEBUG] Loaded RAP value for " .. player.Name .. ":", data.rapValue)
						else
							print("[LOAD DEBUG] No RAP value found for " .. player.Name .. " - will calculate")
						end

						-- Load rebirths value
						if data.rebirthsValue then
							player:SetAttribute("RebirthsValue", data.rebirthsValue)
							print("[LOAD DEBUG] Loaded rebirths value for " .. player.Name .. ":", data.rebirthsValue)
						else
							print("[LOAD DEBUG] No rebirths value found for " .. player.Name .. " - will calculate")
						end

										-- Load collection data
				if data.collection then
					-- Collection data is stored separately, so we just log it
					print("[LOAD DEBUG] Collection data found for " .. player.Name .. ":", game:GetService("HttpService"):JSONEncode(data.collection))
				else
					print("[LOAD DEBUG] No collection data found for " .. player.Name)
				end

				-- Load leaderboard data
				if data.leaderboardData then
					-- Update leaderboard stores with saved data
					if rapLeaderboardStore then
						pcall(function()
							rapLeaderboardStore:SetAsync(tostring(player.UserId), data.leaderboardData.rapValue or 0)
						end)
					end
					if boxesLeaderboardStore then
						pcall(function()
							boxesLeaderboardStore:SetAsync(tostring(player.UserId), data.leaderboardData.boxesValue or 0)
						end)
					end
					print("[LOAD DEBUG] Loaded leaderboard data for " .. player.Name .. ":", game:GetService("HttpService"):JSONEncode(data.leaderboardData))
				else
					print("[LOAD DEBUG] No leaderboard data found for " .. player.Name)
				end

				-- Load tutorial completion status
				if data.tutorialCompleted ~= nil then
					local TutorialService = require(script.Parent.TutorialService)
					TutorialService.SetTutorialCompletion(player, data.tutorialCompleted)
					print("[LOAD DEBUG] Loaded tutorial completion for " .. player.Name .. ": " .. tostring(data.tutorialCompleted))
				else
					print("[LOAD DEBUG] No tutorial completion data found for " .. player.Name)
				end
						
						-- Load equipped items
						if data.equippedItems then
							-- Apply equipped items after character spawns
							local function onCharacterAdded()
								task.wait(1) -- Wait for character to load
								-- Lazy load AvatarService to avoid circular dependencies
								if not AvatarService then
									AvatarService = require(script.Parent.AvatarService)
								end
								
								for itemType, itemUUID in pairs(data.equippedItems) do
									-- Find the item instance by UUID in player's inventory
									local inventory = player:FindFirstChild("Inventory")
									if inventory then
										local itemInstance = inventory:FindFirstChild(itemUUID)
										if itemInstance then
											local itemName = itemInstance:GetAttribute("ItemName") or itemInstance.Name
											-- Use the shared service directly to avoid circular dependency
											local SharedAvatarService = require(game.ReplicatedStorage.Shared.Services.AvatarService)
											SharedAvatarService.EquipItem(player, itemName, itemUUID)
										end
									end
								end
							end
							
							if player.Character then
								onCharacterAdded()
							else
								player.CharacterAdded:Connect(onCharacterAdded)
							end
						end
						
						-- Calculate and set RAP
						updatePlayerRAP(player)
						
						-- Update collection with existing inventory items
						DataService.UpdatePlayerCollection(player)
						
						-- Mark loading as complete to enable saves
						player:SetAttribute("IsLoadingInventory", false)
						
						-- Signal client that inventory loading is complete
						Remotes.InventoryLoadComplete:FireClient(player)
						
						print("Player data fully loaded for " .. player.Name)
						return
			else
				-- No inventory to load, but still load other data
				
				-- Load upgrade data
				local UpgradeService = require(script.Parent.UpgradeService)
				local UpgradeConfig = require(game.ReplicatedStorage.Shared.Modules.UpgradeConfig)
				if data.upgrades then
					print("[LOAD DEBUG] Loading upgrades for " .. player.Name .. " (no inventory):", game:GetService("HttpService"):JSONEncode(data.upgrades))
					local missingUpgrades = {}
					for upgradeId, level in pairs(data.upgrades) do
						UpgradeService.SetPlayerUpgradeLevel(player, upgradeId, level)
						print("[LOAD DEBUG] Set upgrade " .. upgradeId .. " to level " .. level .. " for " .. player.Name)
					end
					-- Ensure all upgrade IDs are present
					for upgradeId, _ in pairs(UpgradeConfig.Upgrades) do
						if data.upgrades[upgradeId] == nil then
							UpgradeService.SetPlayerUpgradeLevel(player, upgradeId, 0)
							table.insert(missingUpgrades, upgradeId)
						end
					end
					if #missingUpgrades > 0 then
						warn("[LOAD WARNING] Some upgrades missing for " .. player.Name .. " (no inventory): " .. table.concat(missingUpgrades, ", "))
					end
				else
					print("[LOAD DEBUG] No upgrades data found for " .. player.Name .. " (no inventory) - will initialize to defaults")
					-- Initialize with defaults since no saved data exists
					local UpgradeConfig = require(game.ReplicatedStorage.Shared.Modules.UpgradeConfig)
					for upgradeId, _ in pairs(UpgradeConfig.Upgrades) do
						UpgradeService.SetPlayerUpgradeLevel(player, upgradeId, 0)
					end
				end
				
				-- Load settings data
				if data.settings then
					-- Store settings in player object for quick access
					local settingsJson = game:GetService("HttpService"):JSONEncode(data.settings)
					player:SetAttribute("GameSettings", settingsJson)
					print("[LOAD DEBUG] Loaded settings for " .. player.Name .. " (no inventory):", settingsJson)
				else
					print("[LOAD DEBUG] No settings data found for " .. player.Name .. " (no inventory)")
				end
				
				-- Load rebirth data
				local RebirthService = require(script.Parent.RebirthService)
				if data.rebirths then
					RebirthService.LoadPlayerRebirthsFromSave(player, data.rebirths)
					print("[LOAD DEBUG] Loaded rebirths for " .. player.Name .. " (no inventory):", game:GetService("HttpService"):JSONEncode(data.rebirths))
					-- Update rebirths leaderstat
					DataService.UpdatePlayerRebirths(player, data.rebirths.currentRebirth or 0)
				else
					print("[LOAD DEBUG] No rebirth data found for " .. player.Name .. " (no inventory)")
					-- Initialize rebirths to 0
					DataService.UpdatePlayerRebirths(player, 0)
				end

				-- Load auto-settings data
				if data.autoSettings then
					DataService.SetAutoSettings(player.UserId, data.autoSettings)
					print("[LOAD DEBUG] Loaded auto-settings for " .. player.Name .. " (no inventory):", game:GetService("HttpService"):JSONEncode(data.autoSettings))
				else
					print("[LOAD DEBUG] No auto-settings found for " .. player.Name .. " (no inventory)")
				end

				-- Load selected crate data
				if data.selectedCrate then
					local selectedCrateJson = game:GetService("HttpService"):JSONEncode(data.selectedCrate)
					player:SetAttribute("SelectedCrate", selectedCrateJson)
					print("[LOAD DEBUG] Loaded selected crate for " .. player.Name .. " (no inventory):", game:GetService("HttpService"):JSONEncode(data.selectedCrate))
				else
					print("[LOAD DEBUG] No selected crate data found for " .. player.Name .. " (no inventory)")
				end

				-- Load RAP value
				if data.rapValue then
					player:SetAttribute("RAPValue", data.rapValue)
					print("[LOAD DEBUG] Loaded RAP value for " .. player.Name .. " (no inventory):", data.rapValue)
				else
					print("[LOAD DEBUG] No RAP value found for " .. player.Name .. " (no inventory) - will calculate")
				end

				-- Load rebirths value
				if data.rebirthsValue then
					player:SetAttribute("RebirthsValue", data.rebirthsValue)
					print("[LOAD DEBUG] Loaded rebirths value for " .. player.Name .. " (no inventory):", data.rebirthsValue)
				else
					print("[LOAD DEBUG] No rebirths value found for " .. player.Name .. " (no inventory) - will calculate")
				end

				-- Load collection data
				if data.collection then
					-- Collection data is stored separately, so we just log it
					print("[LOAD DEBUG] Collection data found for " .. player.Name .. " (no inventory):", game:GetService("HttpService"):JSONEncode(data.collection))
				else
					print("[LOAD DEBUG] No collection data found for " .. player.Name .. " (no inventory)")
				end

				-- Load leaderboard data
				if data.leaderboardData then
					-- Update leaderboard stores with saved data
					if rapLeaderboardStore then
						pcall(function()
							rapLeaderboardStore:SetAsync(tostring(player.UserId), data.leaderboardData.rapValue or 0)
						end)
					end
					if boxesLeaderboardStore then
						pcall(function()
							boxesLeaderboardStore:SetAsync(tostring(player.UserId), data.leaderboardData.boxesValue or 0)
						end)
					end
					print("[LOAD DEBUG] Loaded leaderboard data for " .. player.Name .. " (no inventory):", game:GetService("HttpService"):JSONEncode(data.leaderboardData))
				else
					print("[LOAD DEBUG] No leaderboard data found for " .. player.Name .. " (no inventory)")
				end

				-- Load tutorial completion status
				if data.tutorialCompleted ~= nil then
					local TutorialService = require(script.Parent.TutorialService)
					TutorialService.SetTutorialCompletion(player, data.tutorialCompleted)
					print("[LOAD DEBUG] Loaded tutorial completion for " .. player.Name .. " (no inventory): " .. tostring(data.tutorialCompleted))
				else
					print("[LOAD DEBUG] No tutorial completion data found for " .. player.Name .. " (no inventory)")
				end
				
				-- Calculate and set RAP
				updatePlayerRAP(player)
				
				-- Update collection with existing inventory items
				DataService.UpdatePlayerCollection(player)
				
				-- Mark loading as complete to enable saves
				player:SetAttribute("IsLoadingInventory", false)
				
				-- Signal client that inventory loading is complete (even though there were no items)
				Remotes.InventoryLoadComplete:FireClient(player)
				
				print("Player data loaded for " .. player.Name)
			end
		else
			-- New player or data load failed
			updatePlayerRobux(player, GameConfig.Currency.StartingAmount)
			updatePlayerBoxesOpened(player, 0)
			player:SetAttribute("RAPValue", 0)
			player:SetAttribute("RebirthsValue", 0)
			
			-- Initialize upgrades for new player
			print("[LOAD DEBUG] New player - initializing default upgrades for " .. player.Name)
			local UpgradeService = require(script.Parent.UpgradeService)
			local UpgradeConfig = require(game.ReplicatedStorage.Shared.Modules.UpgradeConfig)
			for upgradeId, _ in pairs(UpgradeConfig.Upgrades) do
				UpgradeService.SetPlayerUpgradeLevel(player, upgradeId, 0)
			end
			
			-- Initialize rebirths for new player
			local RebirthService = require(script.Parent.RebirthService)
			DataService.UpdatePlayerRebirths(player, 0)
			
			-- Initialize auto-settings for new player (empty/default settings)
			DataService.SetAutoSettings(player.UserId, {})
			
			-- Mark loading as complete to enable saves
			player:SetAttribute("IsLoadingInventory", false)
			
			-- Signal client that inventory loading is complete (new player, no items to load)
			Remotes.InventoryLoadComplete:FireClient(player)
			
			print("No data found for " .. player.Name .. ". Creating new profile.")
			if err then
				warn("Error loading data for " .. player.Name .. ": " .. tostring(err))
			end
		end
	end)
	
	-- OPTIMIZED: Connect to inventory changes with throttling
	inventory.ChildAdded:Connect(function(item)
		task.wait(0.05) -- Reduced delay for more responsive updates
		updatePlayerRAP(player)
		
		-- Only trigger save if not in initial loading phase
		local isLoading = player:GetAttribute("IsLoadingInventory")
		if not isLoading then
			-- Queue collection update and save instead of immediate execution
			collectionUpdateQueue[player.UserId] = player
			saveQueue[player.UserId] = player
			
			local itemName = item:GetAttribute("ItemName") or item.Name
			print("Item added to " .. player.Name .. "'s inventory: " .. itemName .. " - Queued for save")
		end
	end)
	
	inventory.ChildRemoved:Connect(function(item)
		updatePlayerRAP(player)
		-- Don't remove from collection when items are sold/removed - keep discovery history
		
		-- Only trigger save if not in initial loading phase
		local isLoading = player:GetAttribute("IsLoadingInventory")
		if not isLoading then
			-- Queue save instead of immediate execution
			saveQueue[player.UserId] = player
			
			local itemName = item:GetAttribute("ItemName") or item.Name
			print("Item removed from " .. player.Name .. "'s inventory: " .. itemName .. " - Queued for save")
		end
	end)
	
	-- Listen for item attribute changes (mutations, size changes, etc.) to update RAP immediately
	inventory.ChildAdded:Connect(function(item)
		-- Connect to attribute changes for this specific item
		item:GetAttributeChangedSignal("Mutations"):Connect(function()
			updatePlayerRAP(player)
		end)
		item:GetAttributeChangedSignal("Mutation"):Connect(function()
			updatePlayerRAP(player)
		end)
		item:GetAttributeChangedSignal("Size"):Connect(function()
			updatePlayerRAP(player)
		end)
	end)
end





function DataService.Start()
	Players.PlayerAdded:Connect(onPlayerAdded)
	
		-- Use the standard Roblox PlayerRemoving event
	game.Players.PlayerRemoving:Connect(function(player)
		-- Validate player before proceeding
		if not player or not player.UserId then
			warn("Invalid player object in PlayerRemoving event")
			return
		end
		
		local userId = player.UserId
		local playerName = player.Name or "Unknown"
		
		print("PlayerRemoving event fired for: " .. playerName .. " - Performing comprehensive save...")
		
		-- Check if player has pending saves in queue and process them immediately
		if saveQueue[userId] then
			print("Player " .. playerName .. " has pending saves in queue - processing immediately...")
			-- Force save any pending queue items
			local success = pcall(function()
				saveData(player)
			end)
			if success then
				print("Successfully saved pending queue data for " .. playerName)
			else
				warn("Failed to save pending queue data for " .. playerName)
			end
		end
		
		-- Check if player has pending collection updates in queue
		if collectionUpdateQueue[userId] and collectionDataStore then
			print("Player " .. playerName .. " has pending collection updates in queue - processing immediately...")
			pcall(function()
				UpdatePlayerCollectionInternal(player)
			end)
		end
		
		-- Check if player has pending RAP updates in queue
		if rapUpdateQueue[userId] then
			print("Player " .. playerName .. " has pending RAP updates in queue - processing immediately...")
			pcall(function()
				updatePlayerRAP(player)
			end)
		end
		
		-- IMMEDIATELY remove from all queues to prevent further processing
		rapUpdateQueue[userId] = nil
		saveQueue[userId] = nil
		collectionUpdateQueue[userId] = nil
		
		-- Clean up loading flag safely
		pcall(function()
	player:SetAttribute("IsLoadingInventory", nil)
		end)
		
		-- Clear cooldowns to allow immediate saves
		lastSaveTimes[userId] = nil
		rapUpdateCooldowns[userId] = nil
		collectionUpdateCooldowns[userId] = nil
		
		-- Force update all calculated values before saving (with error handling)
		pcall(function()
	updatePlayerRAP(player)
		end)
		
		-- Only update collection if datastore is available
		if collectionDataStore then
			pcall(function()
				UpdatePlayerCollectionInternal(player)
			end)
		end
	
	-- Ensure upgrades are included in the save (handled by saveData function automatically)
	-- The saveData function already calls UpgradeService.GetPlayerUpgrades internally
	
	-- Force multiple saves to ensure data persistence
		local saveAttempts = 1 -- Reduced to 1 attempt to avoid delays during leaving
	for i = 1, saveAttempts do
			local success = pcall(function()
		saveData(player)
			end)
			
			if not success then
				warn("Failed to save data for " .. playerName .. " on attempt " .. i)
			else
				print("Successfully saved data for " .. playerName .. " on attempt " .. i)
				break -- Exit early on success
		end
	end
	
		-- Final cleanup of all data related to this player
		lastSaveTimes[userId] = nil
		rapUpdateCooldowns[userId] = nil
		collectionUpdateCooldowns[userId] = nil
		rapCache[userId] = nil
		rapUpdateQueue[userId] = nil
		saveQueue[userId] = nil
		collectionUpdateQueue[userId] = nil
		
		print("Comprehensive save completed for: " .. playerName)
	end)

	-- Handle players who might already be in the game when the script runs
	for _, player in ipairs(Players:GetPlayers()) do
		task.spawn(onPlayerAdded, player)
	end

	-- Connect remote functions
	Remotes.GetPlayerCollection.OnServerInvoke = function(player)
		return DataService.GetPlayerCollection(player)
	end
	
	-- Connect settings remotes
	Remotes.SaveSetting.OnServerEvent:Connect(function(player, settingId, value)
		DataService.SavePlayerSetting(player, settingId, value)
	end)
	
	Remotes.GetPlayerSettings.OnServerInvoke = function(player)
		return DataService.GetPlayerSettings(player)
	end

	-- Connect selected crate remotes
	Remotes.SaveSelectedCrate.OnServerEvent:Connect(function(player, selectedCrate)
		DataService.SetSelectedCrate(player, selectedCrate)
	end)
	
	Remotes.GetSelectedCrate.OnServerInvoke = function(player)
		local selectedCrateJson = player:GetAttribute("SelectedCrate")
		if selectedCrateJson then
			local success, selectedCrate = pcall(function()
				return game:GetService("HttpService"):JSONDecode(selectedCrateJson)
			end)
			if success and selectedCrate then
				return selectedCrate
			end
		end
		return "FreeCrate" -- Default fallback
	end

	-- Save data on server shutdown with enhanced safety
	game:BindToClose(function()
		print("BindToClose triggered. Performing emergency save for all players...")
		local activePlayers = Players:GetPlayers()
		
		if #activePlayers > 0 then
			print("Emergency saving data for " .. #activePlayers .. " players...")
			
			-- Clear all cooldowns to allow immediate saves
			for _, player in ipairs(activePlayers) do
				if player and player.UserId then
					lastSaveTimes[player.UserId] = nil
					rapUpdateCooldowns[player.UserId] = nil
					collectionUpdateCooldowns[player.UserId] = nil
				end
			end
			
			-- Force update all calculated values before shutdown (with error handling)
			for _, player in ipairs(activePlayers) do
				if player and player.UserId then
					pcall(function()
				updatePlayerRAP(player)
					end)
					pcall(function()
						UpdatePlayerCollectionInternal(player)
					end)
				end
			end
			
			-- Multiple save attempts for all players
			for attempt = 1, 2 do
				print("Shutdown save attempt " .. attempt .. " of 2...")
							for _, player in ipairs(activePlayers) do
					if player and player.UserId then
				task.spawn(function()
							pcall(function()
					saveData(player)
							end)
				end)
			end
				end
				task.wait(2) -- Wait for saves to complete
			end
			
			-- Final wait to ensure all saves complete
			print("Waiting for final save completion...")
			task.wait(3)
			print("Emergency shutdown save completed.")
		else
			print("No active players to save during shutdown.")
		end
	end)

	-- OPTIMIZED: Auto-save with throttling
	task.spawn(function()
		while task.wait(30) do -- Reduced frequency from 60 to 30 seconds for more frequent auto-saves
			print("Auto-save triggered for all players...")
			for _, player in ipairs(Players:GetPlayers()) do
				-- Queue players for save instead of immediate execution
				saveQueue[player.UserId] = player
				-- Only update RAP for players who haven't been updated recently
				local lastRapUpdate = rapUpdateCooldowns[player.UserId]
				if not lastRapUpdate or (tick() - lastRapUpdate) >= RAP_UPDATE_COOLDOWN then
					updatePlayerRAP(player)
				end
			end
		end
	end)
	
	-- OPTIMIZED: Emergency save system with throttling
	local function setupEmergencySaves()
		-- Save when player's money changes significantly
		Players.PlayerAdded:Connect(function(player)
			local lastSaveTime = tick()
			local lastRobux = 0
			
			player:GetAttributeChangedSignal("RobuxValue"):Connect(function()
				local currentRobux = player:GetAttribute("RobuxValue") or 0
				local robuxDifference = math.abs(currentRobux - lastRobux)
				local timeSinceLastSave = tick() - lastSaveTime
				
				-- Save if significant money change AND enough time has passed
				if robuxDifference >= 2000 and timeSinceLastSave >= 15 then -- Reduced threshold and time for more frequent saves
					lastSaveTime = tick()
					lastRobux = currentRobux
					-- Queue save instead of immediate execution
					saveQueue[player.UserId] = player
					print("Emergency save queued for " .. player.Name .. " (R$ change: " .. robuxDifference .. ")")
				end
			end)
		end)
	end
	
	setupEmergencySaves()
end

-- Expose function for other services to update RAP
function DataService.UpdatePlayerRAP(player)
	updatePlayerRAP(player)
end

-- Expose function for other services to update R$
function DataService.UpdatePlayerRobux(player, value)
	updatePlayerRobux(player, value)
end

-- Expose function for other services to update Boxes Opened
function DataService.UpdatePlayerBoxesOpened(player, value)
	updatePlayerBoxesOpened(player, value)
end

function DataService.UpdatePlayerRebirths(player, value)
	updatePlayerRebirths(player, value)
end

-- OPTIMIZED: Expose function for other services to trigger a save (throttled)
function DataService.Save(player)
	-- Queue save instead of immediate execution
	saveQueue[player.UserId] = player
end

-- Add function for upgrade service to save upgrade data (throttled)
function DataService.SaveUpgradeData(player, upgradeData)
	-- Queue save instead of immediate execution
	saveQueue[player.UserId] = player
end

-- Force save function for critical operations (bypasses throttling)
function DataService.ForceSave(player)
	-- Temporarily remove from cooldown and force save
	lastSaveTimes[player.UserId] = nil
	task.spawn(function()
		saveData(player)
	end)
end

-- Force process all queues for a player (useful for debugging or manual saves)
function DataService.ForceProcessAllQueues(player)
	if not player or not player.UserId then
		warn("Invalid player for ForceProcessAllQueues")
		return
	end
	
		local userId = player.UserId
	local playerName = player.Name or "Unknown"
	
	print("Force processing all queues for " .. playerName)
	
	-- Clear all cooldowns
	lastSaveTimes[userId] = nil
	rapUpdateCooldowns[userId] = nil
	collectionUpdateCooldowns[userId] = nil
	
	-- Process save queue
	if saveQueue[userId] then
		print("Processing save queue for " .. playerName)
		pcall(function()
			saveData(player)
		end)
		saveQueue[userId] = nil
	end
	
	-- Process collection queue
	if collectionUpdateQueue[userId] and collectionDataStore then
		print("Processing collection queue for " .. playerName)
		pcall(function()
			UpdatePlayerCollectionInternal(player)
		end)
		collectionUpdateQueue[userId] = nil
	end
	
	-- Process RAP queue
	if rapUpdateQueue[userId] then
		print("Processing RAP queue for " .. playerName)
		pcall(function()
			updatePlayerRAP(player)
		end)
		rapUpdateQueue[userId] = nil
	end
	
	-- Process boxes queue
	if boxesUpdateQueue[userId] then
		print("Processing boxes queue for " .. playerName)
		-- This will be handled by the next queue processing cycle
		-- We don't clear it here to let the normal system handle it
	end
	
	print("Force queue processing completed for " .. playerName)
end

-- Collection datastore for tracking discovered items
local collectionDataStore
pcall(function()
	collectionDataStore = DataStoreService:GetDataStore("PlayerCollections_V1")
end)

if not collectionDataStore then
	warn("Failed to initialize collection datastore - collection features will be disabled")
end



-- Expose function for other services to update collection
function DataService.UpdatePlayerCollection(player)
	UpdatePlayerCollectionInternal(player)
end

-- Function to get player's collection data
function DataService.GetPlayerCollection(player)
	local userId = player.UserId
	local collectionKey = "collection_" .. userId
	
	if not collectionDataStore then
		warn("Collection datastore is nil, returning empty collection for " .. player.Name)
		return {}
	end
	
	local success, data = pcall(function()
		return collectionDataStore:GetAsync(collectionKey)
	end)
	
	if success and data then
		return data
	else
		return {}
	end
end

-- Function to give a specific item to a player (for admin commands)
function DataService.GiveItem(player, itemName, mutations, size)
	local inventory = player:FindFirstChild("Inventory")
	if not inventory then
		warn("Could not find inventory for " .. player.Name)
		return nil
	end

	local itemConfig = GameConfig.Items[itemName]
	if not itemConfig then
		warn("Attempted to give invalid item: " .. itemName)
		return nil
	end

	local HttpService = game:GetService("HttpService")

	local item = Instance.new("StringValue")
	item.Name = HttpService:GenerateGUID(false) -- Unique ID for the item instance
	item:SetAttribute("ItemName", itemName)
	item:SetAttribute("Size", size or 1.0) -- Use provided size or default to 1.0
	
	if mutations and #mutations > 0 then
		item:SetAttribute("Mutations", HttpService:JSONEncode(mutations))
		item:SetAttribute("Mutation", mutations[1]) -- For backward compatibility
	end
	
	item.Parent = inventory
	
	return item
end

-- Manual force save function for admin use (bypasses all throttling)
function DataService.ManualForceSave(player)
	print("Manual force save requested for: " .. player.Name)
	-- Temporarily remove from cooldowns
	lastSaveTimes[player.UserId] = nil
	rapUpdateCooldowns[player.UserId] = nil
	collectionUpdateCooldowns[player.UserId] = nil
	
	updatePlayerRAP(player)
	UpdatePlayerCollectionInternal(player)
	
	-- Multiple save attempts for reliability
	for i = 1, 2 do
		saveData(player)
		if i < 2 then task.wait(0.5) end
	end
	
	print("Manual force save completed for: " .. player.Name)
	return true
end

-- Save all players function for admin use
function DataService.SaveAllPlayers()
	print("Manual force save requested for ALL players")
	local activePlayers = Players:GetPlayers()
	
	for _, player in ipairs(activePlayers) do
		task.spawn(function()
			DataService.ManualForceSave(player)
		end)
	end
	
	print("Manual force save completed for " .. #activePlayers .. " players")
	return #activePlayers
end

-- Settings management functions
function DataService.GetPlayerSettings(player)
	local settingsJson = player:GetAttribute("GameSettings")
	if settingsJson then
		local success, settings = pcall(function()
			return game:GetService("HttpService"):JSONDecode(settingsJson)
		end)
		if success and settings then
			return settings
		end
	end
	return {} -- Return empty table if no settings found
end

function DataService.SavePlayerSetting(player, settingId, value)
	print("[SETTINGS DEBUG] Saving setting '" .. settingId .. "' = " .. tostring(value) .. " for " .. player.Name)
	
	-- Get current settings
	local currentSettings = DataService.GetPlayerSettings(player)
	print("[SETTINGS DEBUG] Current settings before update:", game:GetService("HttpService"):JSONEncode(currentSettings))
	
	-- Update the specific setting
	currentSettings[settingId] = value
	
	-- Save back to player attribute
	local HttpService = game:GetService("HttpService")
	local newSettingsJson = HttpService:JSONEncode(currentSettings)
	player:SetAttribute("GameSettings", newSettingsJson)
	print("[SETTINGS DEBUG] New settings JSON:", newSettingsJson)
	
	-- Queue save instead of immediate execution
	saveQueue[player.UserId] = player
	
	print("[SETTINGS DEBUG] Queued save for " .. player.Name)
end

function DataService.GetAutoSettings(userId)
	local success, data = pcall(function()
		return autoSettingsStore:GetAsync(tostring(userId))
	end)
	if success and data then
		return data
	end
	return nil
end

function DataService.SetAutoSettings(userId, settings)
	autoSettingsCache[userId] = settings
	local player = Players:GetPlayerByUserId(userId)
	if player then
		saveQueue[userId] = player
		print("[AUTO-SETTINGS] Updated cache and queued save for " .. player.Name .. " after auto-settings update.")
	end
end

function DataService.SetSelectedCrate(player, selectedCrate)
	-- Save selected crate to player attribute for persistence
	if player and player.UserId then
		local HttpService = game:GetService("HttpService")
		local selectedCrateJson = HttpService:JSONEncode(selectedCrate)
		player:SetAttribute("SelectedCrate", selectedCrateJson)
		
		-- Queue save to ensure data is persisted
		saveQueue[player.UserId] = player
		print("[SELECTED CRATE DEBUG] Saved selected crate for " .. player.Name .. ":", game:GetService("HttpService"):JSONEncode(selectedCrate))
	end
end

-- Reset player data function for admin use
function DataService.ResetPlayerData(player)
	print("Resetting player data for: " .. player.Name)
	
	
	-- Clear inventory
	local inventory = player:FindFirstChild("Inventory")
	if inventory then
		for _, item in ipairs(inventory:GetChildren()) do
			item:Destroy()
		end
		print("Cleared inventory for " .. player.Name)
	end
	
	-- Reset money to starting amount
	local startingMoney = GameConfig.Currency.StartingAmount or 500
	updatePlayerRobux(player, startingMoney)
	
	-- Reset boxes opened
	updatePlayerBoxesOpened(player, 0)
	
	-- Reset rebirths
	updatePlayerRebirths(player, 0)
	
	-- Clear player attributes
	player:SetAttribute("RAPValue", 0)
	player:SetAttribute("GameSettings", "{}")
	
	-- Clear leaderstats
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local rapStat = leaderstats:FindFirstChild("RAP")
		if rapStat then
			rapStat.Value = "0"
		end
		
		local rapDisplay = leaderstats:FindFirstChild("RAP Display")
		if rapDisplay then
			rapDisplay.Value = "0"
		end
	end
	
	-- Reset rebirth data in RebirthService
	local RebirthService = require(script.Parent.RebirthService)
	if RebirthService then
		-- Reset rebirth level to 0
		RebirthService.SetPlayerRebirthLevel(player, 0)
		
		-- Reset unlocked crates to default
		local defaultCrates = {"FreeCrate", "StarterCrate", "PremiumCrate"}
		RebirthService.SetPlayerUnlockedCrates(player, defaultCrates)
		
		-- Reset unlocked features to empty
		RebirthService.SetPlayerUnlockedFeatures(player, {})
		
		print("Reset rebirth data for " .. player.Name)
		
		-- Force save rebirth data immediately
		local rebirthData = RebirthService.GetPlayerRebirthsForSave(player)
		print("Saving reset rebirth data:", game:GetService("HttpService"):JSONEncode(rebirthData))
	end
	
	-- Clear all cooldowns and queues for this player
	local userId = player.UserId
	lastSaveTimes[userId] = nil
	rapUpdateCooldowns[userId] = nil
	collectionUpdateCooldowns[userId] = nil
	rapCache[userId] = nil
	saveQueue[userId] = nil
	collectionUpdateQueue[userId] = nil
	rapUpdateQueue[userId] = nil
	boxesUpdateQueue[userId] = nil
	
	-- Force save the reset data
	DataService.ManualForceSave(player)
	
	print("Successfully reset data for " .. player.Name)
	return true
end

return DataService 