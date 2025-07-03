local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Remotes = require(ReplicatedStorage.Shared.Remotes.Remotes)
local GameConfig = require(ReplicatedStorage.Shared.Modules.GameConfig)
local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)

local AdminService = {}

local ADMIN_USERNAMES = {
	["JohnJjaxon1"] = true,
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
			Remotes.ShowFloatingNotification:FireClient(player, "Invalid syntax. Use: /set <player> <leaderstat> <value>", "Error")
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
			Remotes.ShowFloatingNotification:FireClient(player, "Player '" .. targetPlayerName .. "' not found.", "Error")
			return
		end

		local leaderstats = targetPlayer:FindFirstChild("leaderstats")
		if not leaderstats then
			Remotes.ShowFloatingNotification:FireClient(player, "Could not find leaderstats for " .. targetPlayer.Name, "Error")
			return
		end

		local statToChange = leaderstats:FindFirstChild(statName)
		if not statToChange then
			Remotes.ShowFloatingNotification:FireClient(player, "Leaderstat '" .. statName .. "' not found on " .. targetPlayer.Name, "Error")
			return
		end

		local success, newValue = pcall(function()
			return tonumber(statValueString)
		end)

		if not success or newValue == nil then
			Remotes.ShowFloatingNotification:FireClient(player, "Invalid value: '" .. statValueString .. "'. Must be a number.", "Error")
			return
		end

		-- Use proper PlayerDataService functions to update stats
		if statName == "R$" then
			PlayerDataService.UpdatePlayerRobux(targetPlayer, newValue)
			Remotes.ShowFloatingNotification:FireClient(player, "Successfully set " .. targetPlayer.Name .. "'s R$ to " .. newValue, "Info")
		elseif statName == "Boxes Opened" then
			PlayerDataService.UpdatePlayerBoxesOpened(targetPlayer, newValue)
			Remotes.ShowFloatingNotification:FireClient(player, "Successfully set " .. targetPlayer.Name .. "'s Boxes Opened to " .. newValue, "Info")
		elseif statName == "RAP" then
			-- RAP is calculated, not directly set, so we'll notify that it's not supported
			Remotes.ShowFloatingNotification:FireClient(player, "RAP cannot be directly set as it's calculated from inventory. Use /give to add items instead.", "Error")
		else
			Remotes.ShowFloatingNotification:FireClient(player, "Unknown leaderstat: '" .. statName .. "'. Valid stats: R$, Boxes Opened", "Error")
		end

	elseif command == "/give" then
		-- Handle /give command
		-- Syntax: /give <player> <item name> [size] [mutations...]
		if #messageWords < 3 then
			Remotes.ShowFloatingNotification:FireClient(player, "Invalid syntax. Use: /give <player> <item name> [size] [mutations...]", "Error")
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
			Remotes.ShowFloatingNotification:FireClient(player, "Player '" .. targetPlayerName .. "' not found.", "Error")
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
			Remotes.ShowFloatingNotification:FireClient(player, "Could not find a valid item in the command.", "Error")
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
					Remotes.ShowFloatingNotification:FireClient(player, "Invalid mutation: '" .. mutationName .. "'. Ignoring.", "Error")
				end
			end
		end
		
		-- Give item with size
		local newItem = PlayerDataService.GiveItem(targetPlayer, itemName, mutations, size)
		
		if newItem then
			local mutationStr = #mutations > 0 and " with " .. table.concat(mutations, ", ") .. " mutations" or ""
			Remotes.ShowFloatingNotification:FireClient(player, string.format("Gave %s (Size: %.2f) to %s%s", itemName, size, targetPlayer.Name, mutationStr), "Info")
		else
			Remotes.ShowFloatingNotification:FireClient(player, "Failed to give item to " .. targetPlayer.Name, "Error")
		end

	elseif command == "/save" then
		-- Handle /save command
		-- Syntax: /save [player] or /save all
		if #messageWords < 2 then
			-- Save the admin's own data
			PlayerDataService.ForceSave(player)
			Remotes.ShowFloatingNotification:FireClient(player, "Your data has been saved.", "Info")
		elseif messageWords[2]:lower() == "all" then
			-- Save all players
			local playerCount = PlayerDataService.SaveAllPlayers()
			Remotes.ShowFloatingNotification:FireClient(player, "Forced save for all " .. playerCount .. " players.", "Info")
		else
			-- Save specific player
			local targetPlayerName = messageWords[2]
			local targetPlayer = nil
			for _, p in ipairs(Players:GetPlayers()) do
				if p.Name:lower():sub(1, #targetPlayerName) == targetPlayerName:lower() then
					targetPlayer = p
					break
				end
			end
			
			if not targetPlayer then
				Remotes.ShowFloatingNotification:FireClient(player, "Player '" .. targetPlayerName .. "' not found.", "Error")
				return
			end
			
			PlayerDataService.ForceSave(targetPlayer)
			Remotes.ShowFloatingNotification:FireClient(player, "Forced save for " .. targetPlayer.Name .. ".", "Info")
		end

	elseif command == "/help" then
		-- Show admin commands
		local helpText = "Admin Commands:\n" ..
			"/set <player> <stat> <value> - Set player stats (R$, Boxes Opened)\n" ..
			"/give <player> <item> [size] [mutations...] - Give items to players\n" ..
			"/save [player|all] - Force save player data\n" ..
			"/celebrate [player|all] - Trigger celebration fireworks\n" ..
			"/help - Show this help"
		Remotes.ShowFloatingNotification:FireClient(player, helpText, "Info")

	elseif command == "/celebrate" then
		-- Handle /celebrate command to spawn fireworks for a player or all
		if #messageWords < 2 then
			Remotes.ShowCelebrationEffect:FireClient(player)
		else
			local target = messageWords[2]:lower()
			if target == "all" then
				Remotes.ShowCelebrationEffect:FireAllClients()
			else
				local targetPlayer = nil
				for _, p in ipairs(Players:GetPlayers()) do
					if p.Name:lower():sub(1, #target) == target then
						targetPlayer = p
						break
					end
				end
				if targetPlayer then
					Remotes.ShowCelebrationEffect:FireClient(targetPlayer)
					Remotes.ShowFloatingNotification:FireClient(player, "Celebration triggered for " .. targetPlayer.Name, "Info")
				else
					Remotes.ShowFloatingNotification:FireClient(player, "Player '" .. messageWords[2] .. "' not found.", "Error")
				end
			end
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