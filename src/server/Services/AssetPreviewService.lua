local AssetPreviewService = {}

local InsertService = game:GetService("InsertService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Remotes = require(Shared.Remotes.Remotes)

-- Cache loaded assets to avoid repeated loading
local assetCache = {}
local previewContainer = Instance.new("Folder")
previewContainer.Name = "AssetPreviews"
previewContainer.Parent = ReplicatedStorage

function AssetPreviewService.Start()
	-- Handle asset loading requests from clients
	Remotes.LoadAssetForPreview.OnServerInvoke = function(player, assetId)
		if not assetId or type(assetId) ~= "number" then
			warn("Invalid assetId provided for preview:", assetId)
			return nil
		end
		
		-- Check cache first
		if assetCache[assetId] then
			-- print("Returning cached asset:", assetId)
			return assetCache[assetId]
		end
		
		-- Try to load the asset
		local success, asset = pcall(function()
			return InsertService:LoadAsset(assetId)
		end)
		
		if success and asset then
			-- print("Successfully loaded asset:", assetId)
			
			-- Clean up any scripts from the asset for security
			for _, descendant in pairs(asset:GetDescendants()) do
				if descendant:IsA("Script") or descendant:IsA("LocalScript") or descendant:IsA("ModuleScript") then
					descendant:Destroy()
				-- Make sure all parts are anchored for stable preview
				elseif descendant:IsA("BasePart") then
					descendant.Anchored = true
				end
			end
			
			-- Parent to the preview container so client can see it
			asset.Name = tostring(assetId)
			asset.Parent = previewContainer
			
			-- Cache the asset
			assetCache[assetId] = asset
			
			return asset
		else
			warn("Failed to load asset:", assetId, asset)
			return nil
		end
	end
	
	print("AssetPreviewService started")
end

return AssetPreviewService 