local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Services = script.Parent.Services
local Shared = ReplicatedStorage.Shared

-- Require all services
local ConfigVerifierService = require(Services:WaitForChild("ConfigVerifierService"))
local UGCPreloaderService = require(Services:WaitForChild("UGCPreloaderService"))
local PlayerDataService = require(Services:WaitForChild("PlayerDataService"))
local BoxService = require(Services:WaitForChild("BoxService"))
local InventoryService = require(Services:WaitForChild("InventoryService"))
local CollisionService = require(Services:WaitForChild("CollisionService"))
local AdminService = require(Services:WaitForChild("AdminService"))
local AvatarService = require(Services:WaitForChild("AvatarService"))
local AssetPreviewService = require(Services:WaitForChild("AssetPreviewService"))
local LeaderboardService = require(Services:WaitForChild("LeaderboardService"))
local BoxesLeaderboardService = require(Services:WaitForChild("BoxesLeaderboardService"))
local UpgradeService = require(Services:WaitForChild("UpgradeService"))
local EnchanterService = require(Services:WaitForChild("EnchanterService"))
local AutoOpenService = require(Services:WaitForChild("AutoOpenService"))
local AutoSellService = require(Services:WaitForChild("AutoSellService"))
local InfiniteStorageService = require(Services:WaitForChild("InfiniteStorageService"))
local RebirthService = require(Services:WaitForChild("RebirthService"))
local DiscordLoggingService = require(Services:WaitForChild("DiscordLoggingService"))
-- local other services will be added here

-- Start Services
ConfigVerifierService.Start() -- Start first to verify config
UGCPreloaderService.Start() -- Start early to preload UGC items
PlayerDataService.Start()
UpgradeService.Init() -- Initialize upgrade system before other services that depend on it
BoxService.Start()
CollisionService.Start()
InventoryService.Start()
AdminService.Start() -- Start the new service
AvatarService.Start() -- Start the avatar service
AssetPreviewService.Start() -- Start the asset preview service
LeaderboardService.Start()
BoxesLeaderboardService.Start()
EnchanterService.Start()
AutoOpenService.Initialize()
AutoSellService.Start()
InfiniteStorageService.Start()
RebirthService.Init()
DiscordLoggingService.Start()
-- other services will be started here 