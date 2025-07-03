-- Server-side service for handling Auto-Sell gamepass verification

local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Remotes = require(Shared.Remotes.Remotes)
local GameConfig = require(Shared.Modules.GameConfig)

local AutoSellService = {}

-- Check if player owns the Auto-Sell gamepass
local function checkAutoSellGamepass(player)
	for _, id in ipairs(GameConfig.GamepassWhitelist or {}) do
		if player.UserId == id then
			return true
		end
	end
	
	local success, ownsGamepass = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, GameConfig.AutoSellGamepassId)
	end)
	
	if success then
		return ownsGamepass
	else
		warn("Failed to check Auto-Sell gamepass for player:", player.Name)
		return false
	end
end

function AutoSellService.Start()
	print("[AutoSellService] Starting...")
	
	-- Handle gamepass check requests
	Remotes.CheckAutoSellGamepass.OnServerInvoke = function(player)
		return checkAutoSellGamepass(player)
	end
	
	print("[AutoSellService] Started successfully!")
end

return AutoSellService 