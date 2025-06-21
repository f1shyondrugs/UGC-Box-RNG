local AvatarService = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(script.Parent.Parent.Modules.GameConfig)

-- Maps asset types to HumanoidDescription properties
local ASSET_TYPE_MAP = {
    ["Hat"] = "HatAccessory",
    ["Hair"] = "HairAccessory", 
    ["Face"] = "FaceAccessory",
    ["Neck"] = "NeckAccessory",
    ["Shoulders"] = "ShouldersAccessory",
    ["Front"] = "FrontAccessory",
    ["Back"] = "BackAccessory",
    ["Waist"] = "WaistAccessory",
    ["Shirt"] = "Shirt",
    ["Pants"] = "Pants",
    ["Shoes"] = "ShoesAccessory",
    ["TShirt"] = "TShirt"
}

-- Store each player's state
local equippedItems = {} -- [userId] = { [assetType] = assetId }
local baseDescriptions = {} -- [userId] = HumanoidDescription

function AvatarService.GetEquippedItems(player)
    return equippedItems[player.UserId] or {}
end

function AvatarService.StoreBaseDescription(player)
    if baseDescriptions[player.UserId] then return end -- Already stored

    local success, desc = pcall(function()
        return Players:GetHumanoidDescriptionFromUserId(player.UserId)
    end)
    if success and desc then
        baseDescriptions[player.UserId] = desc
    else
        warn("Could not get base HumanoidDescription for " .. player.Name .. ". Error: " .. tostring(desc))
    end
end

function AvatarService.EquipItem(player, itemName)
    local itemConfig = GameConfig.Items[itemName]
    if not itemConfig or not itemConfig.AssetId or not itemConfig.Type then
        warn("Invalid item config for:", itemName)
        return false
    end
    
    local userId = player.UserId
    if not equippedItems[userId] then
        equippedItems[userId] = {}
    end
    
    -- Store the equipped item
    equippedItems[userId][itemConfig.Type] = itemConfig.AssetId
    
    -- Apply to character if it exists
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        AvatarService.ApplyToCharacter(player)
    end
    
    return true
end

function AvatarService.UnequipItem(player, itemType)
    local userId = player.UserId
    if not equippedItems[userId] or not equippedItems[userId][itemType] then
        return false
    end
    
    -- Remove the equipped item
    equippedItems[userId][itemType] = nil
    
    -- Apply to character if it exists
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        AvatarService.ApplyToCharacter(player)
    end
    
    return true
end

function AvatarService.ApplyToCharacter(player)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    local userId = player.UserId
    local baseDesc = baseDescriptions[userId]

    if not baseDesc then
        AvatarService.StoreBaseDescription(player)
        baseDesc = baseDescriptions[userId]
        if not baseDesc then
            warn("Cannot apply character items: No base description found for " .. player.Name)
            return
        end
    end
    
    -- Clone the base description to create a new one to apply.
    -- This preserves the player's original avatar from the website.
    local newDesc = baseDesc:Clone()

    local playerEquipped = equippedItems[userId] or {}
    
    -- Layer the in-game equipped items on top of the base avatar
    for itemType, assetId in pairs(playerEquipped) do
        local descProperty = ASSET_TYPE_MAP[itemType]
        if descProperty and newDesc[descProperty] ~= nil then
            -- This will overwrite any item from the website in the same slot
            newDesc[descProperty] = assetId
        end
    end
    
    -- Apply the updated description
    humanoid:ApplyDescription(newDesc)
end

function AvatarService.OnPlayerAdded(player)
    -- Initialize equipped items for new player
    equippedItems[player.UserId] = {}
    
    -- Store the player's website avatar when they join
    AvatarService.StoreBaseDescription(player)
    
    -- Apply items when character spawns
    player.CharacterAdded:Connect(function(character)
        task.wait(1) 
        AvatarService.ApplyToCharacter(player)
    end)
end

function AvatarService.OnPlayerRemoving(player)
    -- Clean up player data
    equippedItems[player.UserId] = nil
    baseDescriptions[player.UserId] = nil
end

-- Initialize for players already in game
for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(AvatarService.OnPlayerAdded, player)
end

-- Connect events
Players.PlayerAdded:Connect(AvatarService.OnPlayerAdded)
Players.PlayerRemoving:Connect(AvatarService.OnPlayerRemoving)

return AvatarService 