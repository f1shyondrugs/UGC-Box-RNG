local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Remotes = require(ReplicatedStorage.Shared.Remotes.Remotes)
local GameConfig = require(ReplicatedStorage.Shared.Modules.GameConfig)
local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)

local AdminService = {}

local ADMIN_USERNAMES = {
	["JohnJjaxon1"] = true,
	["Das_F1sHy312"] = true,
}

local function onPlayerChatted(player, message)
	-- 1. Check if the player is a designated admin
	if not ADMIN_USERNAMES[player.Name] then
		return
	end

	-- 2. Check if the message is an admin command
	local messageWords = message:split(" ")
	local command = messageWords[1]:lower()

	if command == "/set" then
		-- Handle /set command
		if #messageWords < 4 then
			Remotes.Notify:FireClient(player, "Invalid syntax. Use: /set <player> <leaderstat> <value>", "Error")
			return
		end

		local targetPlayerName = messageWords[2]
		local statName = messageWords[3]
		local statValueString = messageWords[4]

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

		local success, newValue = pcall(function()
			return tonumber(statValueString)
		end)

		if not success or newValue == nil then
			Remotes.Notify:FireClient(player, "Invalid value: '" .. statValueString .. "'. Must be a number.", "Error")
			return
		end

		statToChange.Value = newValue

		Remotes.Notify:FireClient(player, "Successfully set " .. targetPlayer.Name .. "'s " .. statName .. " to " .. newValue, "Info")

	elseif command == "/give" then
		-- Handle /give command
		-- Syntax: /give <player> <item name> [size] [mutations...]
		if #messageWords < 3 then
			Remotes.Notify:FireClient(player, "Invalid syntax. Use: /give <player> <item name> [size] [mutations...]", "Error")
			return
		end

		local targetPlayerName = messageWords[2]
		
		-- Find target player
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

		-- Greedily parse item name
		local itemName = nil
		local lastItemWordIndex = 2
		for i = 3, #messageWords do
			local potentialName = table.concat(messageWords, " ", 3, i)
			if GameConfig.Items[potentialName] then
				itemName = potentialName
				lastItemWordIndex = i
			end
		end

		if not itemName then
			Remotes.Notify:FireClient(player, "Could not find a valid item in the command.", "Error")
			return
		end

		-- Check for optional size parameter
		local size = 1.0
		local mutationsStartIndex = lastItemWordIndex + 1
		local potentialSize = tonumber(messageWords[mutationsStartIndex])
		if potentialSize then
			size = potentialSize
			mutationsStartIndex = mutationsStartIndex + 1 -- Mutations start after the size
		end
		
		-- Parse and validate mutations
		local mutations = {}
		if mutationsStartIndex <= #messageWords then
			for i = mutationsStartIndex, #messageWords do
				local mutationName = messageWords[i]
				if GameConfig.Mutations[mutationName] then
					table.insert(mutations, mutationName)
				else
					Remotes.Notify:FireClient(player, "Invalid mutation: '" .. mutationName .. "'. Ignoring.", "Error")
				end
			end
		end
		
		-- Give item with size
		local newItem = PlayerDataService.GiveItem(targetPlayer, itemName, mutations, size)
		
		if newItem then
			local mutationStr = #mutations > 0 and " with " .. table.concat(mutations, ", ") .. " mutations" or ""
			Remotes.Notify:FireClient(player, string.format("Gave %s (Size: %.2f) to %s%s", itemName, size, targetPlayer.Name, mutationStr), "Info")
		else
			Remotes.Notify:FireClient(player, "Failed to give item to " .. targetPlayer.Name, "Error")
		end
	end
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

	print("AdminService Started. Listening for commands from admins.")
end

return AdminService 