local AvatarService = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local GameConfig = require(Shared.Modules.GameConfig)
local Remotes = require(Shared.Remotes.Remotes)

-- Import the shared AvatarService
local SharedAvatarService = require(ReplicatedStorage.Shared.Services.AvatarService)

-- Import PlayerDataService for saving equipped items
local PlayerDataService = require(script.Parent.PlayerDataService)

local function equipItem(player, itemName)
    -- Check if player owns the item
    local inventory = player:FindFirstChild("Inventory")
    if not inventory then
        Remotes.Notify:FireClient(player, "Inventory not found.", "Error")
        return
    end
    
    local itemInstance = inventory:FindFirstChild(itemName)
    if not itemInstance then
        Remotes.Notify:FireClient(player, "You don't own this item.", "Error")
        return
    end
    
    -- Check if item is locked
    if itemInstance:GetAttribute("Locked") then
        Remotes.Notify:FireClient(player, "Cannot equip a locked item.", "Error")
        return
    end
    
    -- Equip the item
    local success = SharedAvatarService.EquipItem(player, itemName)
    if success then
        Remotes.Notify:FireClient(player, "Equipped " .. itemName, "Success")
        -- PlayerDataService.Save(player) -- REMOVED: Saving on every equip is too frequent
    else
        Remotes.Notify:FireClient(player, "Failed to equip item.", "Error")
    end
end

local function unequipItem(player, itemType)
    local success = SharedAvatarService.UnequipItem(player, itemType)
    if success then
        Remotes.Notify:FireClient(player, "Unequipped " .. itemType .. " item", "Success")
        -- PlayerDataService.Save(player) -- REMOVED: Saving on every unequip is too frequent
    else
        Remotes.Notify:FireClient(player, "Failed to unequip item.", "Error")
    end
end

local function getEquippedItems(player)
    return SharedAvatarService.GetEquippedItems(player)
end

function AvatarService.Start()
    -- Connect remote events
    Remotes.EquipItem.OnServerEvent:Connect(equipItem)
    Remotes.UnequipItem.OnServerEvent:Connect(unequipItem)
    Remotes.GetEquippedItems.OnServerInvoke = getEquippedItems
    
    print("AvatarService started.")
end

-- Export functions for other services to use
AvatarService.EquipItem = equipItem
AvatarService.UnequipItem = unequipItem
AvatarService.GetEquippedItems = getEquippedItems

return AvatarService 