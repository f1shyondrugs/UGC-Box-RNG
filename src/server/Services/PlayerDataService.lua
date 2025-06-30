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

local DataService = {}

local updateQueue = {}
local isUpdating = false
local DEBOUNCE_INTERVAL = 5 -- seconds

-- Batch loading configuration
local INVENTORY_BATCH_SIZE = 20 -- Process inventory items in batches of 20

local function processUpdateQueue()
	if isUpdating then return end
	isUpdating = true

	local playersToUpdate = {}
	for userId, player in pairs(updateQueue) do
		table.insert(playersToUpdate, player)
	end
	updateQueue = {} -- Clear the queue

	if #playersToUpdate > 0 then
		print("Processing leaderboard updates for " .. #playersToUpdate .. " players.")
		for _, player in ipairs(playersToUpdate) do
			task.spawn(function() -- Make leaderboard updates async to prevent blocking
				-- Use the player attribute for the leaderboard ranking
				local rapValue = player:GetAttribute("RAPValue") or 0
				local success, err = pcall(function()
					rapLeaderboardStore:SetAsync(tostring(player.UserId), rapValue)
				end)
				if not success then
					warn("Failed to update RAP for " .. player.Name .. " in leaderboard: " .. tostring(err))
				end
			end)
		end
	end

	isUpdating = false
end

-- Start the debouncer loop
task.spawn(function()
	while true do
		task.wait(DEBOUNCE_INTERVAL)
		processUpdateQueue()
	end
end)

-- Import AvatarService for equipped items (will be required after it's created)
local AvatarService

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

local function updatePlayerRAP(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return end
	
	-- Calculate the new RAP value
	local totalRAP = calculatePlayerRAP(player)
	
	-- Update the player attribute
	player:SetAttribute("RAPValue", totalRAP)
	
	-- Update the formatted display
	local rapDisplay = leaderstats:FindFirstChild("RAP")
	if rapDisplay then
		rapDisplay.Value = NumberFormatter.FormatNumber(totalRAP)
	end
	
	-- Queue the leaderboard update instead of calling directly
	updateQueue[player.UserId] = player
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
end

-- Optimized inventory loading function
local function loadInventoryBatch(inventory, itemDataList, startIndex, batchSize)
	local endIndex = math.min(startIndex + batchSize - 1, #itemDataList)
	
	for i = startIndex, endIndex do
		local itemData = itemDataList[i]
		local item = Instance.new("StringValue")
		
		-- Use UUID if available, otherwise fall back to legacy name-based system
		if itemData.uuid then
			item.Name = itemData.uuid
			item:SetAttribute("ItemName", itemData.name)
		else
			-- Legacy support: generate UUID for old items
			local HttpService = game:GetService("HttpService")
			local uuid = HttpService:GenerateGUID(false)
			item.Name = uuid
			item:SetAttribute("ItemName", itemData.name)
		end
		
		item:SetAttribute("Size", itemData.size)
		if itemData.mutations then
			-- New multiple mutations format
			local HttpService = game:GetService("HttpService")
			item:SetAttribute("Mutations", HttpService:JSONEncode(itemData.mutations))
			-- Keep backward compatibility with single Mutation attribute
			item:SetAttribute("Mutation", itemData.mutations[1])
		elseif itemData.mutation then
			-- Legacy single mutation format
			item:SetAttribute("Mutation", itemData.mutation)
			-- Also store in new format for consistency
			local HttpService = game:GetService("HttpService")
			item:SetAttribute("Mutations", HttpService:JSONEncode({itemData.mutation}))
		end
		if itemData.locked then
			item:SetAttribute("Locked", itemData.locked)
		end
		item.Parent = inventory
	end
	
	return endIndex >= #itemDataList
end

local function onPlayerAdded(player: Player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	-- Create inventory folder
	local inventory = Instance.new("Folder")
	inventory.Name = "Inventory"
	inventory.Parent = player

	-- Use formatted StringValues for all stats
	local robux = createFormattedRobuxStat(player, leaderstats, GameConfig.Currency.StartingAmount)
	local boxesOpened = createFormattedBoxesStat(player, leaderstats, 0)
	createFormattedRAPStat(player, leaderstats, 0)

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
			
			-- Load inventory in batches to prevent lag
			if data.inventory and #data.inventory > 0 then
				print(string.format("Loading %d inventory items for %s in batches...", #data.inventory, player.Name))
				
				local currentIndex = 1
				local function loadNextBatch()
					if currentIndex > #data.inventory then
						-- All inventory loaded, now load other systems
						print("Inventory loading complete for " .. player.Name)
						
						-- Load upgrade data
						local UpgradeService = require(script.Parent.UpgradeService)
						if data.upgrades then
							for upgradeId, level in pairs(data.upgrades) do
								UpgradeService.SetPlayerUpgradeLevel(player, upgradeId, level)
							end
						end
						
						-- Load settings data
						if data.settings then
							-- Store settings in player object for quick access
							player:SetAttribute("GameSettings", game:GetService("HttpService"):JSONEncode(data.settings))
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
						
						-- Signal client that inventory loading is complete
						Remotes.InventoryLoadComplete:FireClient(player)
						
						print("Player data fully loaded for " .. player.Name)
						return
					end
					
					-- Load batch
					local isComplete = loadInventoryBatch(inventory, data.inventory, currentIndex, INVENTORY_BATCH_SIZE)
					currentIndex = currentIndex + INVENTORY_BATCH_SIZE
					
					if not isComplete then
						-- Schedule next batch
						task.wait(0.1) -- Small delay between batches
						loadNextBatch()
					else
						-- Complete loading
						loadNextBatch()
					end
				end
				
				loadNextBatch()
			else
				-- No inventory to load, proceed immediately
				-- Calculate and set RAP
				updatePlayerRAP(player)
				
				-- Update collection with existing inventory items
				DataService.UpdatePlayerCollection(player)
				
				-- Signal client that inventory loading is complete (even though there were no items)
				Remotes.InventoryLoadComplete:FireClient(player)
				
				print("Player data loaded for " .. player.Name)
			end
		else
			-- New player or data load failed
			updatePlayerRobux(player, GameConfig.Currency.StartingAmount)
			updatePlayerBoxesOpened(player, 0)
			player:SetAttribute("RAPValue", 0)
			
			-- Signal client that inventory loading is complete (new player, no items to load)
			Remotes.InventoryLoadComplete:FireClient(player)
			
			print("No data found for " .. player.Name .. ". Creating new profile.")
			if err then
				warn("Error loading data for " .. player.Name .. ": " .. tostring(err))
			end
		end
	end)
	
	-- Connect to inventory changes to update RAP
	inventory.ChildAdded:Connect(function()
		task.wait(0.1) -- Small delay to ensure attributes are set
		updatePlayerRAP(player)
		DataService.UpdatePlayerCollection(player) -- Update collection when new items are added
	end)
	
	inventory.ChildRemoved:Connect(function()
		updatePlayerRAP(player)
		-- Don't remove from collection when items are sold/removed - keep discovery history
	end)
end

local function saveData(player: Player)
	if not player or not player.Parent then 
		warn("saveData called for an invalid player.")
		return 
	end

	local key = "Player_" .. player.UserId
	
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
	
	-- Save settings data
	local settingsJson = player:GetAttribute("GameSettings")
	if settingsJson then
		local success, settings = pcall(function()
			return game:GetService("HttpService"):JSONDecode(settingsJson)
		end)
		if success and settings then
			dataToSave.settings = settings
		end
	end

	-- Retry logic for DataStore operations
	local attempts = 0
	local success = false
	while not success and attempts < 3 do
		attempts = attempts + 1
		local ok, err = pcall(function()
			playerDataStore:SetAsync(key, dataToSave)
		end)

		success = ok
		if not success then
			warn("Failed to save data for " .. player.Name .. " (Attempt " .. attempts .. "): " .. tostring(err))
			if attempts < 3 then
				task.wait(2) -- Wait before retrying
			end
		end
	end

	if success then
		print("Player data saved for " .. player.Name)
	else
		warn("FATAL: Could not save data for " .. player.Name .. " after 3 attempts.")
	end
end

local function onPlayerRemoving(player: Player)
	print("PlayerRemoving event fired for: " .. player.Name)
	-- No need to save here, as data is saved on item changes, but we'll keep it as a fallback.
	saveData(player)
end

function DataService.Start()
	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoving)

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

	-- Save data on server shutdown
	game:BindToClose(function()
		print("BindToClose triggered. Saving data for all players.")
		if #Players:GetPlayers() > 0 then
			for _, player in ipairs(Players:GetPlayers()) do
				saveData(player)
			end
			-- Allow more time for saving before shutdown
			task.wait(10) 
		end
	end)

	-- Start a more frequent auto-save loop
	task.spawn(function()
		while task.wait(60) do -- Save every 60 seconds
			for _, player in ipairs(Players:GetPlayers()) do
				-- Use a coroutine to prevent one player's save from blocking others
				task.spawn(saveData, player)
			end
		end
	end)
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

-- Expose function for other services to trigger a save
function DataService.Save(player)
	task.spawn(saveData, player)
end

-- Add function for upgrade service to save upgrade data
function DataService.SaveUpgradeData(player, upgradeData)
	-- This will be called by UpgradeService when upgrades change
	-- The actual saving will happen during the regular save cycle
	-- But we can trigger an immediate save if needed for upgrades
	task.spawn(saveData, player)
end

-- Collection datastore for tracking discovered items
local collectionDataStore = DataStoreService:GetDataStore("PlayerCollections_V1")

-- Function to update player's collection based on current inventory
function DataService.UpdatePlayerCollection(player)
	local inventory = player:FindFirstChild("Inventory")
	if not inventory then return end
	
	task.spawn(function()
		local userId = player.UserId
		local collectionKey = "collection_" .. userId
		
		-- Load existing collection
		local existingCollection = {}
		local success, data = pcall(function()
			return collectionDataStore:GetAsync(collectionKey)
		end)
		
		if success and data then
			existingCollection = data
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
			local saveSuccess, err = pcall(function()
				collectionDataStore:SetAsync(collectionKey, existingCollection)
			end)
			
			if not saveSuccess then
				warn("Failed to save collection data for " .. player.Name .. ": " .. tostring(err))
			end
		end
	end)
end

-- Function to get player's collection data
function DataService.GetPlayerCollection(player)
	local userId = player.UserId
	local collectionKey = "collection_" .. userId
	
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
	-- Get current settings
	local currentSettings = DataService.GetPlayerSettings(player)
	
	-- Update the specific setting
	currentSettings[settingId] = value
	
	-- Save back to player attribute
	local HttpService = game:GetService("HttpService")
	player:SetAttribute("GameSettings", HttpService:JSONEncode(currentSettings))
	
	-- Trigger immediate save to DataStore
	task.spawn(saveData, player)
	
	print("Saved setting '" .. settingId .. "' = " .. tostring(value) .. " for " .. player.Name)
end

return DataService 