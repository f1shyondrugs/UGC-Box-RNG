-- AutoOpenService.lua
-- Server-side service for handling Auto-Open gamepass verification

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Remotes = require(Shared.Remotes.Remotes)
local GameConfig = require(Shared.Modules.GameConfig)

local AutoOpenService = {}

-- Check if player owns the Auto-Open gamepass
local function checkAutoOpenGamepass(player)
	-- Whitelist bypass
	for _, id in ipairs(GameConfig.GamepassWhitelist or {}) do
		if player.UserId == id then
			return true
		end
	end
	
	local success, owns = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, GameConfig.AutoOpenGamepassId)
	end)
	
	if success then
		return owns
	else
		warn("Failed to check Auto-Open gamepass for player:", player.Name)
		return false
	end
end

-- Initialize the service
function AutoOpenService.Initialize()
	-- Handle gamepass check requests
	Remotes.CheckAutoOpenGamepass.OnServerInvoke = function(player)
		return checkAutoOpenGamepass(player)
	end
	
	print("AutoOpenService initialized")
end

return AutoOpenService 