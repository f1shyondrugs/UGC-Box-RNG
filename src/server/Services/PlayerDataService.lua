local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Import modules
local Shared = ReplicatedStorage.Shared
local GameConfig = require(Shared.Modules.GameConfig)
local ItemValueCalculator = require(Shared.Modules.ItemValueCalculator)

-- It's good practice to have a unique key for your datastore
-- and to version it in case you change the data structure later.
local playerDataStore = DataStoreService:GetDataStore("PlayerData_UGC_V1")
local rapLeaderboardStore = DataStoreService:GetOrderedDataStore("RAPLeaderboard_V1")

local DataService = {}

local updateQueue = {}
local isUpdating = false
local DEBOUNCE_INTERVAL = 5 -- seconds

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
			local leaderstats = player:FindFirstChild("leaderstats")
			if leaderstats then
				local rapStat = leaderstats:FindFirstChild("RAP")
				if rapStat then
					local success, err = pcall(function()
						rapLeaderboardStore:SetAsync(tostring(player.UserId), rapStat.Value)
					end)
					if not success then
						warn("Failed to update RAP for " .. player.Name .. " in leaderboard: " .. tostring(err))
					end
				end
			end
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
			local mutationName = item:GetAttribute("Mutation")
			local mutationConfig = mutationName and GameConfig.Mutations[mutationName] or nil
			local size = item:GetAttribute("Size") or 1
			
			table.insert(inventoryData, {
				ItemName = itemName,
				ItemConfig = itemConfig,
				MutationConfig = mutationConfig,
				Size = size
			})
		end
	end
	
	return ItemValueCalculator.CalculateRAP(inventoryData)
end

local function updatePlayerRAP(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return end
	
	local rapStat = leaderstats:FindFirstChild("RAP")
	if rapStat then
		local totalRAP = calculatePlayerRAP(player)
		rapStat.Value = totalRAP
		
		-- Queue the leaderboard update instead of calling directly
		updateQueue[player.UserId] = player
	end
end

local function onPlayerAdded(player: Player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local robux = Instance.new("IntValue")
	robux.Name = "R$"
	robux.Parent = leaderstats

	local rap = Instance.new("IntValue")
	rap.Name = "RAP"
	rap.Parent = leaderstats

	local boxesOpened = Instance.new("IntValue")
	boxesOpened.Name = "Boxes Opened"
	boxesOpened.Parent = leaderstats

	local inventory = Instance.new("Folder")
	inventory.Name = "Inventory"
	inventory.Parent = player

	local userId = player.UserId
	local key = "Player_" .. userId

	local data
	local success, err = pcall(function()
		data = playerDataStore:GetAsync(key)
	end)

	if success and data then
		-- Player has data, load it
		robux.Value = data.robux or GameConfig.Currency.StartingAmount
		boxesOpened.Value = data.boxesOpened or 0
		
		if data.inventory then
			for _, itemData in ipairs(data.inventory) do
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
				if itemData.mutation then
					item:SetAttribute("Mutation", itemData.mutation)
				end
				if itemData.locked then
					item:SetAttribute("Locked", itemData.locked)
				end
				item.Parent = inventory
			end
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
		
		print("Player data loaded for " .. player.Name)
	else
		-- New player or data load failed
		robux.Value = GameConfig.Currency.StartingAmount
		boxesOpened.Value = 0
		rap.Value = 0
		print("No data found for " .. player.Name .. ". Creating new profile.")
		if err then
			warn("Error loading data for " .. player.Name .. ": " .. tostring(err))
		end
	end
	
	-- Connect to inventory changes to update RAP
	inventory.ChildAdded:Connect(function()
		task.wait(0.1) -- Small delay to ensure attributes are set
		updatePlayerRAP(player)
	end)
	
	inventory.ChildRemoved:Connect(function()
		updatePlayerRAP(player)
	end)
end

local function saveData(player: Player)
	if not player or not player.Parent then 
		warn("saveData called for an invalid player.")
		return 
	end

	local key = "Player_" .. player.UserId
	
	-- Create the data table in one go
	local leaderstats = player:FindFirstChild("leaderstats")
	local inventory = player:FindFirstChild("Inventory")
	
	local dataToSave = {
		robux = leaderstats and leaderstats:FindFirstChild("R$") and leaderstats["R$"].Value or 0,
		boxesOpened = leaderstats and leaderstats:FindFirstChild("Boxes Opened") and leaderstats["Boxes Opened"].Value or 0,
		inventory = {},
		equippedItems = {},
	}

	if inventory then
		for _, item in ipairs(inventory:GetChildren()) do
			table.insert(dataToSave.inventory, {
				uuid = item.Name, -- Save the UUID as the unique identifier
				name = item:GetAttribute("ItemName") or item.Name, -- ItemName attribute or legacy fallback
				size = item:GetAttribute("Size"),
				mutation = item:GetAttribute("Mutation"),
				locked = item:GetAttribute("Locked")
			})
		end
	end
	
	-- Save equipped items
	if not AvatarService then
		AvatarService = require(script.Parent.AvatarService)
	end
	-- Use the shared service to get a clean, savable table of equipped items
	local SharedAvatarService = require(game.ReplicatedStorage.Shared.Services.AvatarService)
	dataToSave.equippedItems = SharedAvatarService.GetSerializableEquippedItems(player)

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

	-- Save data on server shutdown
	game:BindToClose(function()
		print("BindToClose triggered. Saving data for all players.")
		if #Players:GetPlayers() > 0 then
			for _, player in ipairs(Players:GetPlayers()) do
				saveData(player)
			end
			-- Allow some time for saving before shutdown
			task.wait(3) 
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

-- Expose function for other services to trigger a save
function DataService.Save(player)
	task.spawn(saveData, player)
end

return DataService 