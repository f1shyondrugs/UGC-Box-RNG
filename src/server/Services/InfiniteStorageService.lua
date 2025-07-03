-- Server-side service for handling Infinite Storage gamepass verification

local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Remotes = require(Shared.Remotes.Remotes)
local GameConfig = require(Shared.Modules.GameConfig)

local InfiniteStorageService = {}

-- Check if player owns the Infinite Storage gamepass
local function checkInfiniteStorageGamepass(player)
	-- Whitelist bypass
	for _, id in ipairs(GameConfig.GamepassWhitelist or {}) do
		if player.UserId == id then
			return true
		end
	end
	
	local success, ownsGamepass = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, GameConfig.InfiniteStorageGamepassId)
	end)
	
	if success then
		return ownsGamepass
	else
		warn("Failed to check Infinite Storage gamepass for player:", player.Name)
		return false
	end
end

function InfiniteStorageService.Start()
	print("[InfiniteStorageService] Starting...")
	
	-- Handle gamepass check requests
	Remotes.CheckInfiniteStorageGamepass.OnServerInvoke = function(player)
		return checkInfiniteStorageGamepass(player)
	end
	
	print("[InfiniteStorageService] Started successfully!")
end

return InfiniteStorageService 