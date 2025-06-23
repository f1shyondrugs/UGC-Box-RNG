local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local RankProvider = {}

local leaderboardDataValue = ReplicatedStorage:WaitForChild("LeaderboardData")
local leaderboardData = {}

local function updateLeaderboardData(jsonString)
	if not jsonString or jsonString == "" then
		leaderboardData = {}
		return
	end
	
	local success, decodedTable = pcall(HttpService.JSONDecode, HttpService, jsonString)
	if success then
		leaderboardData = decodedTable
	else
		warn("Failed to decode leaderboard data: " .. tostring(decodedTable))
		leaderboardData = {}
	end
end

-- Initial load
updateLeaderboardData(leaderboardDataValue.Value)

-- Connect to changes
leaderboardDataValue.Changed:Connect(updateLeaderboardData)

function RankProvider.GetPlayerRank(player)
    if not leaderboardData then
        return nil
    end

    for i, entry in ipairs(leaderboardData) do
        if entry.key == tostring(player.UserId) then
            return i
        end
    end

    return nil
end

return RankProvider 