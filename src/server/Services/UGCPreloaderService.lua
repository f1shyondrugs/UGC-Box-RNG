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

-- Batch loading configuration
local BATCH_SIZE = 5 -- Load 5 items at a time
local BATCH_DELAY = 0.5 -- Wait 0.5 seconds between batches

function UGCPreloaderService.Start()
	print("Starting UGC Preloader Service...")
	
	-- Convert items to array for batch processing
	local itemsToLoad = {}
	for itemName, itemConfig in pairs(GameConfig.Items) do
		if itemConfig.AssetId then
			table.insert(itemsToLoad, {name = itemName, config = itemConfig})
		end
	end
	
	local totalItems = #itemsToLoad
	local loadedCount = 0
	local failedCount = 0
	
	print(string.format("🔄 Starting batch loading of %d UGC items (%d per batch)", totalItems, BATCH_SIZE))
	
	-- Process items in batches
	task.spawn(function()
		for i = 1, totalItems, BATCH_SIZE do
			local batchEnd = math.min(i + BATCH_SIZE - 1, totalItems)
			local batchItems = {}
			
			-- Prepare batch
			for j = i, batchEnd do
				table.insert(batchItems, itemsToLoad[j])
			end
			
			-- Load batch in parallel
			local batchCoroutines = {}
			for _, itemData in ipairs(batchItems) do
				local coro = coroutine.create(function()
					local itemName = itemData.name
					local itemConfig = itemData.config
					
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
						else
							failedCount = failedCount + 1
							warn(string.format("❌ No accessory found in asset for: %s (ID: %s)", itemName, tostring(itemConfig.AssetId)))
						end
						
						asset:Destroy() -- Clean up the original asset
					else
						failedCount = failedCount + 1
						warn(string.format("❌ Failed to load UGC: %s (ID: %s) - %s", itemName, tostring(itemConfig.AssetId), tostring(asset)))
					end
				end)
				
				table.insert(batchCoroutines, coro)
			end
			
			-- Run batch
			for _, coro in ipairs(batchCoroutines) do
				coroutine.resume(coro)
			end
			
			-- Wait for batch to complete
			local allComplete = false
			while not allComplete do
				allComplete = true
				for _, coro in ipairs(batchCoroutines) do
					if coroutine.status(coro) ~= "dead" then
						allComplete = false
						break
					end
				end
				if not allComplete then
					task.wait(0.1)
				end
			end
			
			print(string.format("📦 Batch %d-%d complete (%d/%d total)", i, batchEnd, loadedCount + failedCount, totalItems))
			
			-- Delay between batches to prevent overwhelming the system
			if batchEnd < totalItems then
				task.wait(BATCH_DELAY)
			end
		end
		
		loadingComplete = true
		print(string.format("🎯 UGC Preloading Complete! ✅ %d loaded, ❌ %d failed, 📦 %d total", loadedCount, failedCount, totalItems))
	end)
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