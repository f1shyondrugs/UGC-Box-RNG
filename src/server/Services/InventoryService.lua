local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage.Shared
local GameConfig = require(Shared.Modules.GameConfig)
local Remotes = require(Shared.Remotes.Remotes)
local ItemValueCalculator = require(Shared.Modules.ItemValueCalculator)

local InventoryService = {}

-- Import PlayerDataService to update RAP and trigger saves
local PlayerDataService = require(script.Parent.PlayerDataService)

local function sellItem(player: Player, itemToSell: Instance)
	local inventory = player:FindFirstChild("Inventory")
	if not inventory or not itemToSell or itemToSell.Parent ~= inventory then
		warn("Player " .. player.Name .. " tried to sell an invalid item instance.")
		return
	end
	
	-- Do not allow selling a locked item.
	if itemToSell:GetAttribute("Locked") then
		Remotes.Notify:FireClient(player, "You cannot sell a locked item.", "Error")
		return
	end

	local itemName = itemToSell.Name
	local itemConfig = GameConfig.Items[itemName]
	if not itemConfig then
		warn("Player " .. player.Name .. " tried to sell an item with no config: " .. itemName)
		return
	end

	local mutationName = itemToSell:GetAttribute("Mutation")
	local mutationConfig = mutationName and GameConfig.Mutations[mutationName]
	local size = itemToSell:GetAttribute("Size") or 1
	local sellPrice = ItemValueCalculator.GetValue(itemConfig, mutationConfig, size)

	itemToSell:Destroy()

	local leaderstats = player:FindFirstChild("leaderstats")
	local robux = leaderstats and leaderstats:FindFirstChild("R$")
	if robux then
		robux.Value = robux.Value + sellPrice
	end
	
	-- Update player's RAP and trigger a save
	PlayerDataService.UpdatePlayerRAP(player)
	PlayerDataService.Save(player)
end

local function sellAllItems(player: Player)
	local inventory = player:FindFirstChild("Inventory")
	local equippedItemsFolder = player:FindFirstChild("EquippedItems")
	if not inventory or #inventory:GetChildren() == 0 then return end
	
	-- Create a lookup table for equipped asset IDs for faster checking
	local equippedAssetIds = {}
	if equippedItemsFolder then
		for _, equippedItemSlot in ipairs(equippedItemsFolder:GetChildren()) do
			if equippedItemSlot:IsA("StringValue") then
				equippedAssetIds[equippedItemSlot.Value] = true
			end
		end
	end

	local totalSellPrice = 0
	local itemsSold = 0
	for _, itemToSell in ipairs(inventory:GetChildren()) do
		-- Don't sell locked items
		if not itemToSell:GetAttribute("Locked") then
			local itemName = itemToSell.Name
			local itemConfig = GameConfig.Items[itemName]
			
			-- Check if the item is equipped
			local isEquipped = false
			if itemConfig and itemConfig.AssetId then
				isEquipped = equippedAssetIds[tostring(itemConfig.AssetId)] or false
			end
			
			if itemConfig and not isEquipped then
				local mutationName = itemToSell:GetAttribute("Mutation")
				local mutationConfig = mutationName and GameConfig.Mutations[mutationName]
				local size = itemToSell:GetAttribute("Size") or 1
				totalSellPrice = totalSellPrice + ItemValueCalculator.GetValue(itemConfig, mutationConfig, size)
				itemsSold = itemsSold + 1
				itemToSell:Destroy()
			end
		end
	end
	
	-- Give the player the R$ for the items that were actually sold
	local leaderstats = player:FindFirstChild("leaderstats")
	local robux = leaderstats and leaderstats:FindFirstChild("R$")
	if robux then
		robux.Value = robux.Value + totalSellPrice
	end
	
	-- Update player's RAP and trigger a save
	PlayerDataService.UpdatePlayerRAP(player)
	PlayerDataService.Save(player)
	
	-- Notify player of the sale
	if itemsSold > 0 then
		Remotes.Notify:FireClient(player, "Sold " .. itemsSold .. " items for " .. ItemValueCalculator.GetFormattedValue({Value = totalSellPrice}, nil, 1), "Success")
	else
		Remotes.Notify:FireClient(player, "No items to sell (all locked or none available)", "Info")
	end
end

local function toggleItemLock(player: Player, itemToToggle: Instance)
	local inventory = player:FindFirstChild("Inventory")
	if not inventory or not itemToToggle or itemToToggle.Parent ~= inventory then
		return -- Invalid request
	end
	
	local currentState = itemToToggle:GetAttribute("Locked") or false
	itemToToggle:SetAttribute("Locked", not currentState)
end

function InventoryService.Start()
	Remotes.SellItem.OnServerEvent:Connect(sellItem)
	Remotes.SellAllItems.OnServerEvent:Connect(sellAllItems)
	Remotes.ToggleItemLock.OnServerEvent:Connect(toggleItemLock)
end

return InventoryService 