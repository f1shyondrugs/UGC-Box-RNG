local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage.Shared
local GameConfig = require(Shared.Modules.GameConfig)
local Remotes = require(Shared.Remotes.Remotes)
local ItemValueCalculator = require(Shared.Modules.ItemValueCalculator)

local InventoryService = {}

-- Import PlayerDataService to update RAP and trigger saves
local PlayerDataService = require(script.Parent.PlayerDataService)
local AvatarService = require(Shared.Services.AvatarService)

local function sellItem(player: Player, itemToSell: Instance)
	local inventory = player:FindFirstChild("Inventory")
	if not inventory or not itemToSell or itemToSell.Parent ~= inventory then
		warn("Player " .. player.Name .. " tried to sell an invalid item instance.")
		return
	end
	
	-- Do not allow selling a locked item or equipped item.
	if itemToSell:GetAttribute("Locked") then
		Remotes.Notify:FireClient(player, "You cannot sell a locked item.", "Error")
		return
	end
	
	if AvatarService.IsItemEquipped(player, itemToSell) then
		Remotes.Notify:FireClient(player, "You cannot sell an equipped item.", "Error")
		return
	end

	-- Get the actual item name from attribute (UUID system)
	local itemName = itemToSell:GetAttribute("ItemName") or itemToSell.Name
	local itemConfig = GameConfig.Items[itemName]
	if not itemConfig then
		warn("Player " .. player.Name .. " tried to sell an item with no config: " .. itemName)
		return
	end

	local mutationConfigs = ItemValueCalculator.GetMutationConfigs(itemToSell)
	local size = itemToSell:GetAttribute("Size") or 1
	local sellPrice = ItemValueCalculator.GetValue(itemConfig, mutationConfigs, size)

	itemToSell:Destroy()

	-- Update the raw attribute value
	local currentRobux = player:GetAttribute("RobuxValue") or 0
	player:SetAttribute("RobuxValue", currentRobux + sellPrice)
	
	-- Also update the StringValue for display consistency
	local leaderstats = player:FindFirstChild("leaderstats")
	local robux = leaderstats and leaderstats:FindFirstChild("R$")
	if robux then
		local NumberFormatter = require(game.ReplicatedStorage.Shared.Modules.NumberFormatter)
		robux.Value = NumberFormatter.FormatCurrency(currentRobux + sellPrice)
	end
	
	-- Update player's RAP and trigger a save
	PlayerDataService.UpdatePlayerRAP(player)
	PlayerDataService.Save(player)
end

local function sellAllItems(player: Player)
	local inventory = player:FindFirstChild("Inventory")
	if not inventory or #inventory:GetChildren() == 0 then return end

	local totalSellPrice = 0
	local itemsSold = 0
	for _, itemToSell in ipairs(inventory:GetChildren()) do
		-- Don't sell locked or equipped items
		if not itemToSell:GetAttribute("Locked") and not AvatarService.IsItemEquipped(player, itemToSell) then
			-- Get the actual item name from attribute (UUID system)
			local itemName = itemToSell:GetAttribute("ItemName") or itemToSell.Name
			local itemConfig = GameConfig.Items[itemName]
			
			if itemConfig then
				local mutationConfigs = ItemValueCalculator.GetMutationConfigs(itemToSell)
				local size = itemToSell:GetAttribute("Size") or 1
				totalSellPrice = totalSellPrice + ItemValueCalculator.GetValue(itemConfig, mutationConfigs, size)
				itemsSold = itemsSold + 1
				itemToSell:Destroy()
			end
		end
	end
	
	-- Give the player the R$ for the items that were actually sold
	-- Update the raw attribute value
	local currentRobux = player:GetAttribute("RobuxValue") or 0
	player:SetAttribute("RobuxValue", currentRobux + totalSellPrice)
	
	-- Also update the StringValue for display consistency
	local leaderstats = player:FindFirstChild("leaderstats")
	local robux = leaderstats and leaderstats:FindFirstChild("R$")
	if robux then
		local NumberFormatter = require(game.ReplicatedStorage.Shared.Modules.NumberFormatter)
		robux.Value = NumberFormatter.FormatCurrency(currentRobux + totalSellPrice)
	end
	
	-- Update player's RAP and trigger a save
	PlayerDataService.UpdatePlayerRAP(player)
	PlayerDataService.Save(player)
	
	-- Notify player of the sale
	if itemsSold > 0 then
		Remotes.Notify:FireClient(player, "Sold " .. itemsSold .. " items for " .. ItemValueCalculator.GetFormattedValue({Value = totalSellPrice}, nil, 1), "Success")
	else
		Remotes.Notify:FireClient(player, "No items to sell (all locked/equipped or none available)", "Info")
	end
end

local function sellUnlockedItems(player: Player)
	local inventory = player:FindFirstChild("Inventory")
	if not inventory or #inventory:GetChildren() == 0 then return end

	local totalSellPrice = 0
	local itemsSold = 0
	for _, itemToSell in ipairs(inventory:GetChildren()) do
		-- Only sell unlocked and unequipped items
		if not itemToSell:GetAttribute("Locked") and not AvatarService.IsItemEquipped(player, itemToSell) then
			-- Get the actual item name from attribute (UUID system)
			local itemName = itemToSell:GetAttribute("ItemName") or itemToSell.Name
			local itemConfig = GameConfig.Items[itemName]
			
			if itemConfig then
				local mutationConfigs = ItemValueCalculator.GetMutationConfigs(itemToSell)
				local size = itemToSell:GetAttribute("Size") or 1
				totalSellPrice = totalSellPrice + ItemValueCalculator.GetValue(itemConfig, mutationConfigs, size)
				itemsSold = itemsSold + 1
				itemToSell:Destroy()
			end
		end
	end
	
	-- Give the player the R$ for the items that were actually sold
	-- Update the raw attribute value
	local currentRobux = player:GetAttribute("RobuxValue") or 0
	player:SetAttribute("RobuxValue", currentRobux + totalSellPrice)
	
	-- Also update the StringValue for display consistency
	local leaderstats = player:FindFirstChild("leaderstats")
	local robux = leaderstats and leaderstats:FindFirstChild("R$")
	if robux then
		local NumberFormatter = require(game.ReplicatedStorage.Shared.Modules.NumberFormatter)
		robux.Value = NumberFormatter.FormatCurrency(currentRobux + totalSellPrice)
	end
	
	-- Update player's RAP and trigger a save
	PlayerDataService.UpdatePlayerRAP(player)
	PlayerDataService.Save(player)
	
	-- Notify player of the sale
	if itemsSold > 0 then
		Remotes.Notify:FireClient(player, "Sold " .. itemsSold .. " unlocked items for " .. ItemValueCalculator.GetFormattedValue({Value = totalSellPrice}, nil, 1), "Success")
	else
		Remotes.Notify:FireClient(player, "No unlocked items to sell", "Info")
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
	Remotes.SellUnlockedItems.OnServerEvent:Connect(sellUnlockedItems)
	Remotes.ToggleItemLock.OnServerEvent:Connect(toggleItemLock)
end

return InventoryService 