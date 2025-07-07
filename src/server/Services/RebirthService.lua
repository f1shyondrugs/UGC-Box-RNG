local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local GameConfig = require(Shared.Modules.GameConfig)
local Remotes = require(Shared.Remotes.Remotes)

local RebirthService = {}

-- Store player rebirth data in memory
local playerRebirthData = {} -- player.UserId -> {currentRebirth, luckBonus, unlockedCrates}

-- Initialize player rebirth data
local function initializePlayerRebirthData(player)
	if not playerRebirthData[player.UserId] then
		playerRebirthData[player.UserId] = {
			currentRebirth = 0,
			luckBonus = 0,
			unlockedCrates = {"FreeCrate", "StarterCrate", "PremiumCrate"} -- Default unlocked crates
		}
	end
end

-- Get player rebirth data
function RebirthService.GetPlayerRebirthData(player)
	initializePlayerRebirthData(player)
	return playerRebirthData[player.UserId]
end

-- Set player rebirth level
function RebirthService.SetPlayerRebirthLevel(player, rebirthLevel)
	initializePlayerRebirthData(player)
	playerRebirthData[player.UserId].currentRebirth = rebirthLevel
	
	-- Calculate luck bonus
	local totalLuckBonus = 0
	for i = 1, rebirthLevel do
		local rebirthConfig = GameConfig.Rebirths[i]
		if rebirthConfig and rebirthConfig.Rewards.LuckBonus then
			totalLuckBonus = totalLuckBonus + rebirthConfig.Rewards.LuckBonus
		end
	end
	playerRebirthData[player.UserId].luckBonus = totalLuckBonus
	
	-- Set player attribute for luck calculations
	player:SetAttribute("RebirthLevel", rebirthLevel)
	player:SetAttribute("LuckBonus", totalLuckBonus)
end

-- Get player luck multiplier
function RebirthService.GetPlayerLuckMultiplier(player)
	local rebirthData = RebirthService.GetPlayerRebirthData(player)
	local baseLuck = GameConfig.RebirthDefaults.BaseLuck or 1.0
	local luckBonus = rebirthData.luckBonus or 0
	return baseLuck + (luckBonus / 100) -- Convert percentage to multiplier
end

-- Get player unlocked crates
function RebirthService.GetPlayerUnlockedCrates(player)
	local rebirthData = RebirthService.GetPlayerRebirthData(player)
	return rebirthData.unlockedCrates or {"FreeCrate", "StarterCrate", "PremiumCrate"}
end

-- Check if player has unlocked a specific crate
function RebirthService.IsCrateUnlocked(player, crateName)
	local unlockedCrates = RebirthService.GetPlayerUnlockedCrates(player)
	for _, unlockedCrate in ipairs(unlockedCrates) do
		if unlockedCrate == crateName then
			return true
		end
	end
	return false
end

-- Check if player has required items
local function checkItemRequirements(player, requirements)
	local inventory = player:FindFirstChild("Inventory")
	if not inventory then return false end
	
	local itemCounts = {}
	for _, item in ipairs(inventory:GetChildren()) do
		local itemName = item:GetAttribute("ItemName") or item.Name
		itemCounts[itemName] = (itemCounts[itemName] or 0) + 1
	end
	
	for _, itemReq in ipairs(requirements.Items) do
		if (itemCounts[itemReq.Name] or 0) < itemReq.Amount then
			return false
		end
	end
	
	return true
end

-- Remove required items from inventory
local function removeRequiredItems(player, requirements)
	local inventory = player:FindFirstChild("Inventory")
	if not inventory then return false end
	
	local itemsToRemove = {}
	for _, itemReq in ipairs(requirements.Items) do
		itemsToRemove[itemReq.Name] = itemReq.Amount
	end
	
	-- Remove items
	for _, item in ipairs(inventory:GetChildren()) do
		local itemName = item:GetAttribute("ItemName") or item.Name
		if itemsToRemove[itemName] and itemsToRemove[itemName] > 0 then
			itemsToRemove[itemName] = itemsToRemove[itemName] - 1
			item:Destroy()
		end
	end
	
	return true
end

-- Clear player inventory
local function clearInventory(player)
	local inventory = player:FindFirstChild("Inventory")
	if inventory then
		local itemCount = #inventory:GetChildren()
		print("[RebirthService] Found", itemCount, "items in inventory for", player.Name)
		for _, item in ipairs(inventory:GetChildren()) do
			item:Destroy()
		end
		print("[RebirthService] Destroyed all items in inventory for", player.Name)
	else
		print("[RebirthService] No inventory found for player", player.Name)
	end
end

-- Perform rebirth
function RebirthService.PerformRebirth(player, rebirthLevel)
	local rebirthConfig = GameConfig.Rebirths[rebirthLevel]
	if not rebirthConfig then
		return {success = false, error = "Invalid rebirth level"}
	end
	
	local currentRebirthData = RebirthService.GetPlayerRebirthData(player)
	
	-- Check if player is at the correct rebirth level
	if currentRebirthData.currentRebirth + 1 ~= rebirthLevel then
		return {success = false, error = "Invalid rebirth sequence"}
	end
	
	-- Check money requirement
	local currentMoney = player:GetAttribute("RobuxValue") or 0
	if currentMoney < rebirthConfig.Requirements.Money then
		return {success = false, error = "Not enough money"}
	end
	
	-- Check item requirements
	if not checkItemRequirements(player, rebirthConfig.Requirements) then
		return {success = false, error = "Missing required items"}
	end
	
	-- Perform rebirth
	-- 1. Remove required money
	local PlayerDataService = require(script.Parent.PlayerDataService)
	PlayerDataService.UpdatePlayerRobux(player, rebirthConfig.ResetMoney)
	
	-- 2. Remove required items
	removeRequiredItems(player, rebirthConfig.Requirements)
	
	-- 3. Clear inventory if required
	print("[RebirthService] ClearInventory value for rebirth", rebirthLevel, ":", rebirthConfig.ClearInventory)
	if rebirthConfig.ClearInventory then
		print("[RebirthService] Clearing inventory for player", player.Name)
		clearInventory(player)
		print("[RebirthService] Inventory cleared for player", player.Name)
	else
		print("[RebirthService] Not clearing inventory for player", player.Name)
	end
	
	-- 4. Update rebirth level and luck bonus
	RebirthService.SetPlayerRebirthLevel(player, rebirthLevel)
	
	-- Update rebirths leaderstat
	local PlayerDataService = require(script.Parent.PlayerDataService)
	PlayerDataService.UpdatePlayerRebirths(player, rebirthLevel)
	
	-- 5. Unlock new crates (always ensure all crates from all previous rebirths are included)
	local allUnlocked = {"FreeCrate", "StarterCrate", "PremiumCrate"}
	for i = 1, rebirthLevel do
		local config = GameConfig.Rebirths[i]
		if config and config.Rewards and config.Rewards.UnlockedCrates then
			for _, crate in ipairs(config.Rewards.UnlockedCrates) do
				local already = false
				for _, c in ipairs(allUnlocked) do if c == crate then already = true break end end
				if not already then table.insert(allUnlocked, crate) end
			end
		end
	end
	playerRebirthData[player.UserId].unlockedCrates = allUnlocked
	
	-- 6. Save data
	PlayerDataService.Save(player)
	
	-- 7. Send update to client
	local newRebirthData = RebirthService.GetPlayerRebirthData(player)
	Remotes.RebirthUpdated:FireClient(player, newRebirthData)
	
	print("[RebirthService] Player " .. player.Name .. " completed rebirth level " .. rebirthLevel)
	
	return {
		success = true,
		rebirthData = newRebirthData
	}
end

-- Get rebirth data for client
local function getRebirthData(player)
	return RebirthService.GetPlayerRebirthData(player)
end

-- Get unlocked crates for client
local function getUnlockedCrates(player)
	return RebirthService.GetPlayerUnlockedCrates(player)
end

-- Handle rebirth request
local function handleRebirthRequest(player, rebirthLevel)
	return RebirthService.PerformRebirth(player, rebirthLevel)
end

-- Initialize service
function RebirthService.Init()
	-- Connect remote events
	Remotes.GetRebirthData.OnServerInvoke = getRebirthData
	Remotes.GetUnlockedCrates.OnServerInvoke = getUnlockedCrates
	Remotes.PerformRebirth.OnServerInvoke = handleRebirthRequest
	
	-- Initialize rebirth data for existing players
	for _, player in pairs(Players:GetPlayers()) do
		initializePlayerRebirthData(player)
	end
	
	-- Handle new players joining
	Players.PlayerAdded:Connect(function(player)
		-- Wait for player data to be loaded
		task.wait(3)
		
		-- Initialize rebirth data
		initializePlayerRebirthData(player)
		
		-- Send current rebirth data to client
		local rebirthData = RebirthService.GetPlayerRebirthData(player)
		Remotes.RebirthUpdated:FireClient(player, rebirthData)
		
		print("[RebirthService] Initialized rebirth data for", player.Name, ":", game:GetService("HttpService"):JSONEncode(rebirthData))
	end)
	
	print("[RebirthService] Initialized")
end

-- Clean up when player leaves
Players.PlayerRemoving:Connect(function(player)
	if playerRebirthData[player.UserId] then
		playerRebirthData[player.UserId] = nil
	end
end)

-- Save/load rebirth data with PlayerDataService
function RebirthService.GetPlayerRebirthsForSave(player)
	local data = RebirthService.GetPlayerRebirthData(player)
	return {
		currentRebirth = data.currentRebirth,
		luckBonus = data.luckBonus,
		unlockedCrates = data.unlockedCrates
	}
end

function RebirthService.LoadPlayerRebirthsFromSave(player, data)
	-- Initialize player data if not exists
	initializePlayerRebirthData(player)
	
	if data and data.currentRebirth then
		RebirthService.SetPlayerRebirthLevel(player, data.currentRebirth)
		print("[RebirthService] Loaded rebirth level", data.currentRebirth, "for", player.Name)
		
		-- Update rebirths leaderstat
		local PlayerDataService = require(script.Parent.PlayerDataService)
		PlayerDataService.UpdatePlayerRebirths(player, data.currentRebirth)
	end
	
	if data and data.unlockedCrates then
		playerRebirthData[player.UserId].unlockedCrates = data.unlockedCrates
		print("[RebirthService] Loaded unlocked crates for", player.Name, ":", table.concat(data.unlockedCrates, ", "))
	else
		playerRebirthData[player.UserId].unlockedCrates = {"FreeCrate", "StarterCrate", "PremiumCrate"}
		print("[RebirthService] Using default unlocked crates for", player.Name)
	end
	
	-- Ensure player attributes are set
	player:SetAttribute("RebirthLevel", playerRebirthData[player.UserId].currentRebirth)
	player:SetAttribute("LuckBonus", playerRebirthData[player.UserId].luckBonus)
	
	print("[RebirthService] Final rebirth data for", player.Name, ":", game:GetService("HttpService"):JSONEncode(playerRebirthData[player.UserId]))
end

return RebirthService 