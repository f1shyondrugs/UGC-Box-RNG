local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local DiscordLoggingService = {}

-- Discord webhook URL (you'll need to provide this)
local WEBHOOK_URL = "https://discord.com/api/webhooks/1391770087832162408/eY4KDW76_AIdSyF5k8rnaUn1eX-0K_oAV7mgUCjd00D3IpN5ZV6dInjpafpeGzWx9aEn"

-- Function to send webhook message
local function sendWebhook(embed)
	if WEBHOOK_URL == "YOUR_DISCORD_WEBHOOK_URL_HERE" then
		warn("Discord webhook URL not set! Please update the WEBHOOK_URL in DiscordLoggingService.lua")
		return
	end
	
	local success, result = pcall(function()
		local data = {
			embeds = {embed}
		}
		
		local response = HttpService:RequestAsync({
			Url = WEBHOOK_URL,
			Method = "POST",
			Headers = {
				["Content-Type"] = "application/json"
			},
			Body = HttpService:JSONEncode(data)
		})
		
		return response
	end)
	
	if not success then
		warn("Failed to send Discord webhook:", result)
	end
end

-- Function to get player leaderstats
local function getPlayerStats(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return {} end
	
	local stats = {}
	for _, stat in pairs(leaderstats:GetChildren()) do
		if stat:IsA("IntValue") or stat:IsA("NumberValue") then
			stats[stat.Name] = stat.Value
		end
	end
	
	return stats
end

-- Function to create join embed
local function createJoinEmbed(player)
	local stats = getPlayerStats(player)
	
	local embed = {
		title = "🎮 Player Joined",
		description = string.format("**%s** has joined the game!", player.Name),
		color = 0x00FF00, -- Green
		timestamp = DateTime.now():ToIsoDate(),
		thumbnail = {
			url = string.format("https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=150&height=150", player.UserId)
		},
		fields = {
			{
				name = "👤 Player Info",
				value = string.format("**Username:** %s\n**Display Name:** %s\n**User ID:** %d", 
					player.Name, 
					player.DisplayName, 
					player.UserId
				),
				inline = true
			}
		},
		footer = {
			text = "📦 UGC Box RNG 📦"
		}
	}
	
	-- Add leaderstats if available
	if next(stats) then
		local statsText = ""
		for statName, statValue in pairs(stats) do
			statsText = statsText .. string.format("**%s:** %s\n", statName, tostring(statValue))
		end
		
		table.insert(embed.fields, {
			name = "📊 Leaderstats",
			value = statsText,
			inline = true
		})
	end
	
	return embed
end

-- Function to create leave embed
local function createLeaveEmbed(player)
	local stats = getPlayerStats(player)
	
	local embed = {
		title = "👋 Player Left",
		description = string.format("**%s** has left the game!", player.Name),
		color = 0xFF0000, -- Red
		timestamp = DateTime.now():ToIsoDate(),
		thumbnail = {
			url = string.format("https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=150&height=150", player.UserId)
		},
		fields = {
			{
				name = "👤 Player Info",
				value = string.format("**Username:** %s\n**Display Name:** %s\n**User ID:** %d", 
					player.Name, 
					player.DisplayName, 
					player.UserId
				),
				inline = true
			}
		},
		footer = {
			text = "📦 UGC Box RNG 📦"
		}
	}
	
	-- Add leaderstats if available
	if next(stats) then
		local statsText = ""
		for statName, statValue in pairs(stats) do
			statsText = statsText .. string.format("**%s:** %s\n", statName, tostring(statValue))
		end
		
		table.insert(embed.fields, {
			name = "📊 Final Stats",
			value = statsText,
			inline = true
		})
	end
	
	return embed
end

-- Start the service
function DiscordLoggingService.Start()
	print("DiscordLoggingService started")
	
	-- Handle player joins
	Players.PlayerAdded:Connect(function(player)
		-- Wait a moment for leaderstats to load
		task.wait(2)
		
		local embed = createJoinEmbed(player)
		sendWebhook(embed)
		
		print("Logged join for player:", player.Name)
	end)
	
	-- Handle player leaves
	Players.PlayerRemoving:Connect(function(player)
		local embed = createLeaveEmbed(player)
		sendWebhook(embed)
		
		print("Logged leave for player:", player.Name)
	end)
end

-- Function to set webhook URL
function DiscordLoggingService.SetWebhookURL(url)
	WEBHOOK_URL = url
	print("Discord webhook URL updated")
end

return DiscordLoggingService 