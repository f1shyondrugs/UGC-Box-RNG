local UGCPreloaderService = {}

local InsertService = game:GetService("InsertService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local GameConfig = require(Shared.Modules.GameConfig)

-- Create a folder to store all preloaded UGC items
local ugcFolder = Instance.new("Folder")
ugcFolder.Name = "PreloadedUGC"
ugcFolder.Parent = ReplicatedStorage

local preloadedItems = {}
local loadingComplete = false

function UGCPreloaderService.Start()
	print("Starting UGC Preloader Service...")
	
	-- Count total items for progress tracking
	local totalItems = 0
	for _, _ in pairs(GameConfig.Items) do
		totalItems = totalItems + 1
	end
	
	local loadedCount = 0
	local failedCount = 0
	
	-- Load all UGC items
	for itemName, itemConfig in pairs(GameConfig.Items) do
		if itemConfig.AssetId then
			-- Use spawn to load items in parallel for faster startup
			task.spawn(function()
				local success, asset = pcall(function()
					return InsertService:LoadAsset(itemConfig.AssetId)
				end)
				
				if success and asset then
					-- Look for an Accessory in the loaded asset
					local accessory = asset:FindFirstChildOfClass("Accessory")
					if not accessory then
						-- Sometimes the accessory is nested deeper
						for _, child in ipairs(asset:GetDescendants()) do
							if child:IsA("Accessory") then
								accessory = child
								break
							end
						end
					end
					
					if accessory then
						-- Clean up scripts for security
						for _, descendant in pairs(accessory:GetDescendants()) do
							if descendant:IsA("Script") or descendant:IsA("LocalScript") or descendant:IsA("ModuleScript") then
								descendant:Destroy()
							end
						end
						
						-- Store the accessory
						accessory.Name = itemName
						accessory.Parent = ugcFolder
						preloadedItems[itemName] = accessory
						
						loadedCount = loadedCount + 1
						print(string.format("✅ Loaded UGC: %s (%d/%d)", itemName, loadedCount + failedCount, totalItems))
					else
						failedCount = failedCount + 1
						warn(string.format("❌ No accessory found in asset for: %s (ID: %s) (%d/%d)", itemName, tostring(itemConfig.AssetId), loadedCount + failedCount, totalItems))
					end
					
					asset:Destroy() -- Clean up the original asset
				else
					failedCount = failedCount + 1
					warn(string.format("❌ Failed to load UGC: %s (ID: %s) - %s (%d/%d)", itemName, tostring(itemConfig.AssetId), tostring(asset), loadedCount + failedCount, totalItems))
				end
				
				-- Check if all items have been processed
				if loadedCount + failedCount >= totalItems then
					loadingComplete = true
					print(string.format("🎯 UGC Preloading Complete! ✅ %d loaded, ❌ %d failed, 📦 %d total", loadedCount, failedCount, totalItems))
				end
			end)
		else
			failedCount = failedCount + 1
			warn(string.format("❌ No AssetId for item: %s (%d/%d)", itemName, loadedCount + failedCount, totalItems))
			
			-- Check if all items have been processed
			if loadedCount + failedCount >= totalItems then
				loadingComplete = true
				print(string.format("🎯 UGC Preloading Complete! ✅ %d loaded, ❌ %d failed, 📦 %d total", loadedCount, failedCount, totalItems))
			end
		end
	end
end

-- Function for other services to get a preloaded UGC item
function UGCPreloaderService.GetPreloadedItem(itemName)
	return preloadedItems[itemName]
end

-- Function to check if preloading is complete
function UGCPreloaderService.IsLoadingComplete()
	return loadingComplete
end

-- Function to get the UGC folder
function UGCPreloaderService.GetUGCFolder()
	return ugcFolder
end

return UGCPreloaderService 