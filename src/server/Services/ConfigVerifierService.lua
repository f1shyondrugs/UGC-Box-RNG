local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.Modules.GameConfig)
local ConfigVerifierService = {}

-- This service now only VERIFIES the config, it does not modify it in memory.
-- The `Type` field in GameConfig is the source of truth for accessory slots.
function ConfigVerifierService.Start()
    task.spawn(function()
        print("Starting GameConfig verification...")
        
        for itemName, itemConfig in pairs(GameConfig.Items) do
            if not itemConfig.AssetId then
                warn(`Item '{itemName}' is missing an AssetId. Skipping verification.`)
                continue
            end

            local success, productInfo = pcall(function()
                return MarketplaceService:GetProductInfo(itemConfig.AssetId, Enum.InfoType.Asset)
            end)

            if not success or not productInfo then
                warn(`Failed to get product info for item '{itemName}' (ID: {itemConfig.AssetId}). Error: {tostring(productInfo)}`)
                continue
            end
            
            local assetTypeId = productInfo.AssetTypeId
            
            if not assetTypeId then
                 warn(`Could not determine AssetTypeId for item '{itemName}' (ID: {itemConfig.AssetId}). Skipping.`)
                 continue
            end

            -- Verification logic
            local isClassicShirt = (assetTypeId == Enum.AssetType.Shirt.Value)
            local isClassicPants = (assetTypeId == Enum.AssetType.Pants.Value)
            
            if isClassicShirt and itemConfig.Type ~= "Shirt" then
                warn(`CONFIG ERROR for '{itemName}': AssetId {itemConfig.AssetId} is a classic Shirt, but Type is set to '{itemConfig.Type}'. It should be 'Shirt'.`)
            end
            
            if isClassicPants and itemConfig.Type ~= "Pants" then
                 warn(`CONFIG ERROR for '{itemName}': AssetId {itemConfig.AssetId} is a classic Pants, but Type is set to '{itemConfig.Type}'. It should be 'Pants'.`)
            end

            -- Safely check if the asset is an accessory
            local isAccessory = false
            if typeof(productInfo.AssetType) == "string" then
                isAccessory = (string.find(productInfo.AssetType, "Accessory") ~= nil)
            end

            if isAccessory and (itemConfig.Type == "Shirt" or itemConfig.Type == "Pants") then
                warn(`CONFIG ERROR for '{itemName}': AssetId {itemConfig.AssetId} is an Accessory ({productInfo.AssetType}), but Type is set to '{itemConfig.Type}'. It should be an accessory type like 'Hat', 'Shoulders', etc.`)
            end
            
            -- Add a small delay to avoid hitting rate limits
            task.wait(0.1)
        end
        
        print("GameConfig verification complete.")
    end)
end

return ConfigVerifierService 