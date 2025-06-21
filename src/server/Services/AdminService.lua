local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Shared.Remotes.Remotes)

local AdminService = {}

local ADMIN_USERNAME = "JohnJjaxon1"

local function onPlayerChatted(player, message)
	-- 1. Check if the player is the designated admin
	if player.Name ~= ADMIN_USERNAME then
		return
	end

	-- 2. Check if the message is the admin command
	local messageWords = message:split(" ")
	local command = messageWords[1]:lower()

	if command ~= ",set" then
		return
	end

	-- 3. Parse the arguments
	if #messageWords < 4 then
		Remotes.Notify:FireClient(player, "Invalid syntax. Use: ,set <player> <leaderstat> <value>", "Error")
		return
	end

	local targetPlayerName = messageWords[2]
	local statName = messageWords[3]
	local statValueString = messageWords[4]

	-- 4. Find the target player (with partial name matching)
	local targetPlayer = nil
	for _, p in ipairs(Players:GetPlayers()) do
		if p.Name:lower():sub(1, #targetPlayerName) == targetPlayerName:lower() then
			targetPlayer = p
			break
		end
	end

	if not targetPlayer then
		Remotes.Notify:FireClient(player, "Player '" .. targetPlayerName .. "' not found.", "Error")
		return
	end

	-- 5. Find the leaderstat
	local leaderstats = targetPlayer:FindFirstChild("leaderstats")
	if not leaderstats then
		Remotes.Notify:FireClient(player, "Could not find leaderstats for " .. targetPlayer.Name, "Error")
		return
	end

	local statToChange = leaderstats:FindFirstChild(statName)
	if not statToChange then
		Remotes.Notify:FireClient(player, "Leaderstat '" .. statName .. "' not found on " .. targetPlayer.Name, "Error")
		return
	end
	
	-- 6. Set the value
	local success, newValue = pcall(function()
		return tonumber(statValueString)
	end)

	if not success or newValue == nil then
		Remotes.Notify:FireClient(player, "Invalid value: '" .. statValueString .. "'. Must be a number.", "Error")
		return
	end

	statToChange.Value = newValue

	-- 7. Notify the admin of success
	Remotes.Notify:FireClient(player, "Successfully set " .. targetPlayer.Name .. "'s " .. statName .. " to " .. newValue, "Info")
end


function AdminService.Start()
	Players.PlayerAdded:Connect(function(player)
		player.Chatted:Connect(function(message)
			onPlayerChatted(player, message)
		end)
	end)

	-- Also connect for players already in the game when the script runs
	for _, player in ipairs(Players:GetPlayers()) do
		player.Chatted:Connect(function(message)
			onPlayerChatted(player, message)
		end)
	end

	print("AdminService Started. Listening for commands from: " .. ADMIN_USERNAME)
end

return AdminService 