local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local UpgradeConfig = require(Shared.Modules.UpgradeConfig)
local Remotes = require(Shared.Remotes.Remotes)

local UpgradeService = {}

-- Store player upgrade levels in memory
local playerUpgrades = {} -- player.UserId -> {upgradeId -> level}

-- Initialize player upgrades
local function initializePlayerUpgrades(player)
	if not playerUpgrades[player.UserId] then
		print("[UPGRADE DEBUG] Initializing upgrades for " .. player.Name)
		playerUpgrades[player.UserId] = {}
		
		-- Initialize all upgrades to level 0 (this will be overridden by loaded data)
		for upgradeId, _ in pairs(UpgradeConfig.Upgrades) do
			playerUpgrades[player.UserId][upgradeId] = 0
		end
		
		print("[UPGRADE DEBUG] Initialized upgrades to 0 for " .. player.Name)
		
		-- Send initial upgrade values to client (delay to allow data loading)
		task.spawn(function()
			task.wait(3) -- Wait longer for data to load
			local maxBoxes = UpgradeService.GetPlayerMaxBoxes(player)
			local cooldown = UpgradeService.GetPlayerCooldown(player)
			Remotes.MaxBoxesUpdated:FireClient(player, maxBoxes)
			Remotes.CooldownUpdated:FireClient(player, cooldown)
			print("[UPGRADE DEBUG] Sent initial upgrade values to " .. player.Name .. " - Max boxes: " .. maxBoxes .. ", Cooldown: " .. cooldown)
		end)
	else
		print("[UPGRADE DEBUG] Upgrades already initialized for " .. player.Name)
	end
end

-- Get player upgrade level
function UpgradeService.GetPlayerUpgradeLevel(player, upgradeId)
	initializePlayerUpgrades(player)
	return playerUpgrades[player.UserId][upgradeId] or 0
end

-- Set player upgrade level
function UpgradeService.SetPlayerUpgradeLevel(player, upgradeId, level)
	initializePlayerUpgrades(player)
	playerUpgrades[player.UserId][upgradeId] = level
	print("[UPGRADE DEBUG] Set " .. upgradeId .. " to level " .. level .. " for " .. player.Name)
end

-- Get all player upgrades
function UpgradeService.GetPlayerUpgrades(player)
	initializePlayerUpgrades(player)
	local upgrades = playerUpgrades[player.UserId]
	print("[UPGRADE DEBUG] Getting upgrades for " .. player.Name .. ":", game:GetService("HttpService"):JSONEncode(upgrades))
	return upgrades
end

-- Calculate current inventory limit based on upgrade level
function UpgradeService.GetPlayerInventoryLimit(player)
	-- Check if player has Infinite Storage gamepass
	local GameConfig = require(Shared.Modules.GameConfig)
	
	-- Check whitelist first
	for _, id in ipairs(GameConfig.GamepassWhitelist or {}) do
		if player.UserId == id then
			return 999999 -- Effectively infinite for whitelisted users
		end
	end
	
	-- Check gamepass ownership
	local MarketplaceService = game:GetService("MarketplaceService")
	local success, ownsGamepass = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, GameConfig.InfiniteStorageGamepassId)
	end)
	
	if success and ownsGamepass then
		return 999999 -- Effectively infinite
	end
	
	-- Regular upgrade-based limit
	local upgradeLevel = UpgradeService.GetPlayerUpgradeLevel(player, "InventorySlots")
	local upgrade = UpgradeConfig.Upgrades.InventorySlots
	return upgrade.BaseValue + (upgradeLevel * upgrade.ValuePerLevel)
end

-- Calculate current max boxes based on upgrade level
function UpgradeService.GetPlayerMaxBoxes(player)
	local upgradeLevel = UpgradeService.GetPlayerUpgradeLevel(player, "MultiCrateOpening")
	local upgrade = UpgradeConfig.Upgrades.MultiCrateOpening
	return upgrade.BaseValue + upgradeLevel
end

-- Calculate current cooldown based on upgrade level
function UpgradeService.GetPlayerCooldown(player)
	local upgradeLevel = UpgradeService.GetPlayerUpgradeLevel(player, "FasterCooldowns")
	local upgrade = UpgradeConfig.Upgrades.FasterCooldowns
	local cooldown = upgrade.BaseValue + (upgradeLevel * upgrade.ValuePerLevel)
	return math.max(0.1, cooldown) -- Minimum 0.1 seconds
end

-- Handle upgrade purchase
local function handleUpgradePurchase(player, upgradeId)
	local upgrade = UpgradeConfig.Upgrades[upgradeId]
	if not upgrade then
		Remotes.ShowFloatingNotification:FireClient(player, "Invalid upgrade!", "Error")
		return
	end
	
	local currentLevel = UpgradeService.GetPlayerUpgradeLevel(player, upgradeId)
	
	-- Check if already at max level
	if UpgradeConfig.IsMaxLevel(upgradeId, currentLevel) then
		Remotes.ShowFloatingNotification:FireClient(player, "Upgrade already at max level!", "Error")
		return
	end
	
	-- Calculate cost
	local cost = UpgradeConfig.GetUpgradeCost(upgradeId, currentLevel)
	if not cost then
		Remotes.ShowFloatingNotification:FireClient(player, "Upgrade already at max level!", "Error")
		return
	end
	
	-- Check if player has enough money
	local currentRobux = player:GetAttribute("RobuxValue") or 0
	
	if currentRobux < cost then
		Remotes.ShowFloatingNotification:FireClient(player, "Not enough R$! Need " .. cost .. " R$", "Error")
		return
	end
	
	-- Deduct cost and upgrade
	-- Update the raw attribute value
	player:SetAttribute("RobuxValue", currentRobux - cost)
	
	-- Also update the StringValue for display consistency
	local leaderstats = player:FindFirstChild("leaderstats")
	local robux = leaderstats and leaderstats:FindFirstChild("R$")
	if robux then
		local NumberFormatter = require(game.ReplicatedStorage.Shared.Modules.NumberFormatter)
		robux.Value = NumberFormatter.FormatNumber(currentRobux - cost)
	end
	UpgradeService.SetPlayerUpgradeLevel(player, upgradeId, currentLevel + 1)
	
	-- Notify player of successful upgrade
	local newLevel = currentLevel + 1
	local upgradeName = upgrade.Name
	Remotes.ShowFloatingNotification:FireClient(player, upgradeName .. " upgraded to level " .. newLevel .. "!", "Success")
	
	-- Send updated upgrade data to client
	Remotes.UpgradeUpdated:FireClient(player, upgradeId, newLevel)
	
	-- Update affected systems
	if upgradeId == "MultiCrateOpening" then
		-- Update max boxes for this player
		local newMaxBoxes = UpgradeService.GetPlayerMaxBoxes(player)
		Remotes.MaxBoxesUpdated:FireClient(player, newMaxBoxes)
	elseif upgradeId == "FasterCooldowns" then
		-- Update cooldown for this player
		local newCooldown = UpgradeService.GetPlayerCooldown(player)
		Remotes.CooldownUpdated:FireClient(player, newCooldown)
	end
	
	-- Save upgrade data (will be handled by existing PlayerDataService)
	print("[UPGRADE DEBUG] Triggering save for " .. player.Name .. " after purchasing " .. upgradeId .. " (new level: " .. newLevel .. ")")
	print("[UPGRADE DEBUG] Current player upgrades:", game:GetService("HttpService"):JSONEncode(playerUpgrades[player.UserId]))
	
	local PlayerDataService = require(script.Parent.PlayerDataService)
	PlayerDataService.SaveUpgradeData(player, playerUpgrades[player.UserId])
end

-- Get upgrade data for client
local function getUpgradeData(player)
	initializePlayerUpgrades(player)
	
	local upgradeData = {}
	for upgradeId, level in pairs(playerUpgrades[player.UserId]) do
		local upgrade = UpgradeConfig.Upgrades[upgradeId]
		if upgrade then
			upgradeData[upgradeId] = {
				level = level,
				cost = UpgradeConfig.GetUpgradeCost(upgradeId, level),
				effects = UpgradeConfig.GetUpgradeEffects(upgradeId, level),
				isMaxLevel = UpgradeConfig.IsMaxLevel(upgradeId, level)
			}
		end
	end
	
	return upgradeData
end

-- Initialize service
function UpgradeService.Init()
	-- Connect remote events
	Remotes.PurchaseUpgrade.OnServerEvent:Connect(handleUpgradePurchase)
	Remotes.GetUpgradeData.OnServerInvoke = getUpgradeData
	
	-- DON'T auto-initialize players here - let PlayerDataService handle it after loading
	-- The upgrade system will be initialized when data is loaded or when first accessed
	print("[UPGRADE DEBUG] UpgradeService initialized - waiting for PlayerDataService to trigger initialization")
end

-- Clean up when player leaves
Players.PlayerRemoving:Connect(function(player)
	if playerUpgrades[player.UserId] then
		playerUpgrades[player.UserId] = nil
	end
end)

return UpgradeService 