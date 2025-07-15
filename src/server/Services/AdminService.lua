local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local HttpService = game:GetService("HttpService")
local MessagingService = game:GetService("MessagingService")

local Remotes = require(ReplicatedStorage.Shared.Remotes.Remotes)
local GameConfig = require(ReplicatedStorage.Shared.Modules.GameConfig)
local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)

local AdminService = {}

local ADMIN_USERNAMES = {
	["JohnJjaxon1"] = true,
}

-- Ban system storage
local BANNED_PLAYERS = {}

-- Load banned players from datastore (you'll need to implement this with your data persistence system)
local function loadBannedPlayers()
	-- TODO: Implement loading from datastore
	-- For now, we'll use a simple table
	BANNED_PLAYERS = {}
end

local function saveBannedPlayers()
	-- TODO: Implement saving to datastore
	-- For now, we'll just print the banned players
	print("Banned players:", HttpService:JSONEncode(BANNED_PLAYERS))
end

local function isPlayerBanned(playerName)
	return BANNED_PLAYERS[playerName] ~= nil
end

local function banPlayer(playerName, reason, adminName)
	BANNED_PLAYERS[playerName] = {
		reason = reason,
		bannedBy = adminName,
		bannedAt = os.time()
	}
	saveBannedPlayers()
end

local function unbanPlayer(playerName)
	BANNED_PLAYERS[playerName] = nil
	saveBannedPlayers()
end

-- Cross-server kick functionality
local function kickPlayerFromAllServers(playerName, reason)
	-- Send cross-server message to kick the player
	local message = {
		action = "kick_player",
		playerName = playerName,
		reason = reason or "No reason provided",
		timestamp = os.time()
	}
	
	-- Publish to all servers with error handling
	local success, error = pcall(function()
		MessagingService:PublishAsync("AdminKickSystem", message)
	end)
	
	if not success then
		warn("Failed to send cross-server kick message:", error)
	end
	
	-- Also kick from current server if player is here
	local targetPlayer = Players:FindFirstChild(playerName)
	if targetPlayer then
		targetPlayer:Kick("Kicked by admin: " .. (reason or "No reason provided"))
		return true
	else
		return false
	end
end

local function kickAllPlayersFromAllServers(reason)
	-- Send cross-server message to kick all players
	local message = {
		action = "kick_all",
		reason = reason or "No reason provided",
		timestamp = os.time()
	}
	
	-- Publish to all servers with error handling
	local success, error = pcall(function()
		MessagingService:PublishAsync("AdminKickSystem", message)
	end)
	
	if not success then
		warn("Failed to send cross-server kick all message:", error)
	end
	
	-- Also kick all players from current server
	local kickedCount = 0
	for _, player in ipairs(Players:GetPlayers()) do
		player:Kick("Mass kick by admin: " .. (reason or "No reason provided"))
		kickedCount = kickedCount + 1
	end
	return kickedCount
end

-- Handle incoming cross-server kick messages
local function handleCrossServerKick(message)
	print("Received cross-server kick message:", HttpService:JSONEncode(message))
	
	if message.action == "kick_player" then
		local targetPlayer = Players:FindFirstChild(message.playerName)
		if targetPlayer then
			print("Kicking player from cross-server message:", targetPlayer.Name)
			targetPlayer:Kick("Kicked by admin: " .. message.reason)
		else
			print("Player not found on this server:", message.playerName)
		end
	elseif message.action == "kick_all" then
		print("Kicking all players from cross-server message")
		for _, player in ipairs(Players:GetPlayers()) do
			player:Kick("Mass kick by admin: " .. message.reason)
		end
	elseif message.action == "test" then
		print("Received cross-server test message from:", message.message)
		-- You could also notify admins about the test
		for _, adminPlayer in ipairs(Players:GetPlayers()) do
			if ADMIN_USERNAMES[adminPlayer.Name] then
				Remotes.ShowFloatingNotification:FireClient(adminPlayer, "Cross-server test received: " .. message.message, "Info")
			end
		end
	end
end

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
			"/reset <player> confirm - Reset player data completely\n" ..
			"/celebrate [player|all] - Trigger celebration fireworks\n" ..
			"/kick <player> <reason> - Kick a player from all servers\n" ..
			"/kick all <reason> - Kick all players from all servers\n" ..
			"/ban <player> <reason> - Ban a player\n" ..
			"/unban <player> - Unban a player\n" ..
			"/bans - List all banned players\n" ..
			"/testcrossserver - Test cross-server messaging\n" ..
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

	elseif command == "/kick" then
		-- Handle /kick command
		-- Syntax: /kick <player> <reason> or /kick all <reason>
		if #messageWords < 2 then
			Remotes.ShowFloatingNotification:FireClient(player, "Invalid syntax. Use: /kick <player> <reason> or /kick all <reason>", "Error")
			return
		end

		local target = messageWords[2]:lower()
		local reason = table.concat(messageWords, " ", 3) or "No reason provided"

		if target == "all" then
			-- Kick all players from all servers
			local kickedCount = kickAllPlayersFromAllServers(reason)
			Remotes.ShowFloatingNotification:FireClient(player, "Kicked " .. kickedCount .. " players from this server and sent kick command to all other servers. Reason: " .. reason, "Info")
		else
			-- Kick specific player from all servers
			local targetPlayer = nil
			for _, p in ipairs(Players:GetPlayers()) do
				if p.Name:lower():sub(1, #target) == target then
					targetPlayer = p
					break
				end
			end

			if not targetPlayer then
				Remotes.ShowFloatingNotification:FireClient(player, "Player '" .. messageWords[2] .. "' not found on this server, but kick command sent to all servers.", "Info")
				-- Still send the kick command to other servers
				kickPlayerFromAllServers(messageWords[2], reason)
				return
			end

			local success = kickPlayerFromAllServers(targetPlayer.Name, reason)
			if success then
				Remotes.ShowFloatingNotification:FireClient(player, "Kicked " .. targetPlayer.Name .. " from this server and sent kick command to all other servers. Reason: " .. reason, "Info")
			else
				Remotes.ShowFloatingNotification:FireClient(player, "Sent kick command for " .. targetPlayer.Name .. " to all servers. Reason: " .. reason, "Info")
			end
		end

	elseif command == "/ban" then
		-- Handle /ban command
		-- Syntax: /ban <player> <reason>
		if #messageWords < 3 then
			Remotes.ShowFloatingNotification:FireClient(player, "Invalid syntax. Use: /ban <player> <reason>", "Error")
			return
		end

		local targetPlayerName = messageWords[2]
		local reason = table.concat(messageWords, " ", 3)

		-- Check if player is already banned
		if isPlayerBanned(targetPlayerName) then
			Remotes.ShowFloatingNotification:FireClient(player, "Player '" .. targetPlayerName .. "' is already banned.", "Error")
			return
		end

		-- Ban the player
		banPlayer(targetPlayerName, reason, player.Name)
		
		-- Kick the player if they're currently online
		local targetPlayer = Players:FindFirstChild(targetPlayerName)
		if targetPlayer then
			targetPlayer:Kick("You have been banned. Reason: " .. reason)
		end

		Remotes.ShowFloatingNotification:FireClient(player, "Banned " .. targetPlayerName .. ". Reason: " .. reason, "Info")

	elseif command == "/unban" then
		-- Handle /unban command
		-- Syntax: /unban <player>
		if #messageWords < 2 then
			Remotes.ShowFloatingNotification:FireClient(player, "Invalid syntax. Use: /unban <player>", "Error")
			return
		end

		local targetPlayerName = messageWords[2]

		if not isPlayerBanned(targetPlayerName) then
			Remotes.ShowFloatingNotification:FireClient(player, "Player '" .. targetPlayerName .. "' is not banned.", "Error")
			return
		end

		unbanPlayer(targetPlayerName)
		Remotes.ShowFloatingNotification:FireClient(player, "Unbanned " .. targetPlayerName, "Info")

	elseif command == "/bans" then
		-- Handle /bans command to list all banned players
		local bannedList = {}
		for playerName, banData in pairs(BANNED_PLAYERS) do
			local banDate = os.date("%Y-%m-%d %H:%M:%S", banData.bannedAt)
			table.insert(bannedList, playerName .. " (by " .. banData.bannedBy .. " on " .. banDate .. " - " .. banData.reason .. ")")
		end

		if #bannedList == 0 then
			Remotes.ShowFloatingNotification:FireClient(player, "No players are currently banned.", "Info")
		else
			local banText = "Banned Players:\n" .. table.concat(bannedList, "\n")
			Remotes.ShowFloatingNotification:FireClient(player, banText, "Info")
		end

	elseif command == "/reset" then
		-- Handle /reset command
		-- Syntax: /reset <player> [confirm]
		if #messageWords < 2 then
			Remotes.ShowFloatingNotification:FireClient(player, "Invalid syntax. Use: /reset <player> [confirm]", "Error")
			return
		end

		local targetPlayerName = messageWords[2]
		local confirm = messageWords[3] and messageWords[3]:lower() == "confirm"
		
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

		if not confirm then
			Remotes.ShowFloatingNotification:FireClient(player, "WARNING: This will completely reset " .. targetPlayer.Name .. "'s data! Use '/reset " .. targetPlayer.Name .. " confirm' to proceed.", "Error")
			return
		end

		Remotes.ShowFloatingNotification:FireClient(player, "Resetting " .. targetPlayer.Name .. "'s data... this may take a minute or two.", "Info")

		-- Reset player data
		local success = PlayerDataService.ResetPlayerData(targetPlayer)
		
		if success then
			Remotes.ShowFloatingNotification:FireClient(player, "Successfully reset " .. targetPlayer.Name .. "'s data.", "Info")
			Remotes.ShowFloatingNotification:FireClient(targetPlayer, "Your data has been reset by an admin.", "Info")
		else
			Remotes.ShowFloatingNotification:FireClient(player, "Failed to reset " .. targetPlayer.Name .. "'s data.", "Error")
		end

	elseif command == "/testcrossserver" then
		-- Test cross-server messaging
		local message = {
			action = "test",
			message = "Cross-server test from " .. player.Name,
			timestamp = os.time()
		}
		
		local success, error = pcall(function()
			MessagingService:PublishAsync("AdminKickSystem", message)
		end)
		
		if success then
			Remotes.ShowFloatingNotification:FireClient(player, "Cross-server test message sent successfully", "Info")
		else
			Remotes.ShowFloatingNotification:FireClient(player, "Failed to send cross-server test: " .. tostring(error), "Error")
		end

	elseif command == "/testenchanter" then
		-- Test Enchanter ProximityPrompt creation
		print("[AdminService] Testing Enchanter ProximityPrompt creation...")
		Remotes.ShowFloatingNotification:FireClient(player, "Testing Enchanter ProximityPrompt creation...", "Info")
		
		-- Call the setup function directly
		local success, err = pcall(function()
			local EnchanterService = require(ServerScriptService.Server.Services.EnchanterService)
			print("[AdminService] Enchanter ProximityPrompt test initiated")
			
			-- Try to find and test the existing prompt
			local promptsFolder = workspace:FindFirstChild("ProximityPrompts")
			if promptsFolder then
				local enchanterMain = promptsFolder:FindFirstChild("EnchanterMain")
				if enchanterMain then
					local prompt = enchanterMain:FindFirstChildOfClass("ProximityPrompt")
					if prompt then
						print("[AdminService] ✓ ProximityPrompt found!")
						Remotes.ShowFloatingNotification:FireClient(player, "✓ ProximityPrompt found at position: " .. tostring(enchanterMain.Position), "Success")
					else
						print("[AdminService] ✗ ProximityPrompt not found!")
						Remotes.ShowFloatingNotification:FireClient(player, "✗ ProximityPrompt not found! Recreating...", "Error")
						-- Try to recreate it using the exposed function
						EnchanterService.SetupPrompt()
					end
				else
					print("[AdminService] ✗ EnchanterMain part not found!")
					Remotes.ShowFloatingNotification:FireClient(player, "✗ EnchanterMain part not found!", "Error")
				end
			else
				print("[AdminService] ✗ ProximityPrompts folder not found!")
				Remotes.ShowFloatingNotification:FireClient(player, "✗ ProximityPrompts folder not found!", "Error")
			end
		end)
		
		if not success then
			warn("[AdminService] Failed to test Enchanter ProximityPrompt:", err)
			Remotes.ShowFloatingNotification:FireClient(player, "Failed to test Enchanter ProximityPrompt: " .. tostring(err), "Error")
		end
	end
end


function AdminService.Start()
	-- Load banned players on startup
	loadBannedPlayers()

	-- Subscribe to cross-server kick messages
	local success, error = pcall(function()
		MessagingService:SubscribeAsync("AdminKickSystem", function(message)
			handleCrossServerKick(message)
		end)
	end)
	
	if not success then
		warn("Failed to subscribe to cross-server messages:", error)
	else
		print("Successfully subscribed to cross-server kick messages")
	end

	Players.PlayerAdded:Connect(function(player)
		-- Check if player is banned
		if isPlayerBanned(player.Name) then
			local banData = BANNED_PLAYERS[player.Name]
			local banDate = os.date("%Y-%m-%d %H:%M:%S", banData.bannedAt)
			player:Kick("You are banned from this game.\nReason: " .. banData.reason .. "\nBanned by: " .. banData.bannedBy .. "\nBanned on: " .. banDate)
			return
		end

		player.Chatted:Connect(function(message)
			onPlayerChatted(player, message)
		end)
	end)

	-- Also connect for players already in the game when the script runs
	for _, player in ipairs(Players:GetPlayers()) do
		-- Check if existing player is banned
		if isPlayerBanned(player.Name) then
			local banData = BANNED_PLAYERS[player.Name]
			local banDate = os.date("%Y-%m-%d %H:%M:%S", banData.bannedAt)
			player:Kick("You are banned from this game.\nReason: " .. banData.reason .. "\nBanned by: " .. banData.bannedBy .. "\nBanned on: " .. banDate)
		else
			player.Chatted:Connect(function(message)
				onPlayerChatted(player, message)
			end)
		end
	end

	print("AdminService Started. Listening for commands from admins and cross-server messages.")
end

return AdminService 