local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Services = ServerScriptService.Server.Services
local Shared = ReplicatedStorage.Shared

-- Require all services
local PlayerDataService = require(Services.PlayerDataService)
local BoxService = require(Services.BoxService)
local InventoryService = require(Services.InventoryService)
local CollisionService = require(Services.CollisionService)
local AdminService = require(Services.AdminService)
-- local other services will be added here

-- Start Services
BoxService.Start()
CollisionService.Start()
InventoryService.Start()
PlayerDataService.Start()
AdminService.Start() -- Start the new service
-- other services will be started here 