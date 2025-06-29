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
		playerUpgrades[player.UserId] = {}
		
		-- Initialize all upgrades to level 0
		for upgradeId, _ in pairs(UpgradeConfig.Upgrades) do
			playerUpgrades[player.UserId][upgradeId] = 0
		end
		
		-- Send initial upgrade values to client
		task.spawn(function()
			task.wait(2) -- Wait for client to initialize
			local maxBoxes = UpgradeService.GetPlayerMaxBoxes(player)
			local cooldown = UpgradeService.GetPlayerCooldown(player)
			Remotes.MaxBoxesUpdated:FireClient(player, maxBoxes)
			Remotes.CooldownUpdated:FireClient(player, cooldown)
		end)
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
end

-- Get all player upgrades
function UpgradeService.GetPlayerUpgrades(player)
	initializePlayerUpgrades(player)
	return playerUpgrades[player.UserId]
end

-- Calculate current inventory limit based on upgrade level
function UpgradeService.GetPlayerInventoryLimit(player)
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
		Remotes.Notify:FireClient(player, "Invalid upgrade!", "Error")
		return
	end
	
	local currentLevel = UpgradeService.GetPlayerUpgradeLevel(player, upgradeId)
	
	-- Check if already at max level
	if UpgradeConfig.IsMaxLevel(upgradeId, currentLevel) then
		Remotes.Notify:FireClient(player, "Upgrade already at max level!", "Error")
		return
	end
	
	-- Calculate cost
	local cost = UpgradeConfig.GetUpgradeCost(upgradeId, currentLevel)
	if not cost then
		Remotes.Notify:FireClient(player, "Upgrade already at max level!", "Error")
		return
	end
	
	-- Check if player has enough money
	local currentRobux = player:GetAttribute("RobuxValue") or 0
	
	if currentRobux < cost then
		Remotes.Notify:FireClient(player, "Not enough R$! Need " .. cost .. " R$", "Error")
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
	Remotes.Notify:FireClient(player, upgradeName .. " upgraded to level " .. newLevel .. "!", "Success")
	
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
	
	-- Initialize existing players
	for _, player in pairs(Players:GetPlayers()) do
		initializePlayerUpgrades(player)
	end
	
	-- Handle new players
	Players.PlayerAdded:Connect(initializePlayerUpgrades)
end

-- Clean up when player leaves
Players.PlayerRemoving:Connect(function(player)
	if playerUpgrades[player.UserId] then
		playerUpgrades[player.UserId] = nil
	end
end)

return UpgradeService 