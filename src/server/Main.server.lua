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
-- local other services will be added here

-- Start Services
ConfigVerifierService.Start() -- Start first to verify config
UGCPreloaderService.Start() -- Start early to preload UGC items
BoxService.Start()
CollisionService.Start()
InventoryService.Start()
PlayerDataService.Start()
AdminService.Start() -- Start the new service
AvatarService.Start() -- Start the avatar service
AssetPreviewService.Start() -- Start the asset preview service
LeaderboardService.Start()
-- other services will be started here 