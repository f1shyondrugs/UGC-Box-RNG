-- TutorialService.lua
-- Server-side service to handle tutorial completion and tracking

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

local Shared = ReplicatedStorage.Shared
local Remotes = require(Shared.Remotes.Remotes)

local TutorialService = {}

-- Store tutorial completion status in memory (for quick access)
local tutorialCompletion = {} -- player.UserId -> boolean

-- Create a separate DataStore for tutorial completion
local tutorialDataStore = DataStoreService:GetDataStore("TutorialCompletion_V1")

-- Load tutorial completion status from DataStore
local function loadTutorialCompletion(player)
    if not player or not player.UserId then return false end
    
    local userId = player.UserId
    local key = "Tutorial_" .. userId
    
    local success, data = pcall(function()
        return tutorialDataStore:GetAsync(key)
    end)
    
    if success and data then
        tutorialCompletion[userId] = data.completed or false
        print("[TutorialService] Loaded tutorial completion for " .. player.Name .. ": " .. tostring(tutorialCompletion[userId]))
        return tutorialCompletion[userId]
    else
        tutorialCompletion[userId] = false
        print("[TutorialService] No tutorial completion data found for " .. player.Name .. ", defaulting to false")
        return false
    end
end

-- Save tutorial completion status to DataStore
local function saveTutorialCompletion(player)
    if not player or not player.UserId then return end
    
    local userId = player.UserId
    local key = "Tutorial_" .. userId
    
    local data = {
        completed = tutorialCompletion[userId] or false,
        completedAt = tick(),
        playerName = player.Name
    }
    
    local success, err = pcall(function()
        tutorialDataStore:SetAsync(key, data)
    end)
    
    if success then
        print("[TutorialService] Saved tutorial completion for " .. player.Name .. ": " .. tostring(tutorialCompletion[userId]))
    else
        warn("[TutorialService] Failed to save tutorial completion for " .. player.Name .. ": " .. tostring(err))
    end
end

-- Handle tutorial completion
local function handleTutorialCompletion(player)
    if not player or not player.UserId then return end
    
    local userId = player.UserId
    tutorialCompletion[userId] = true
    
    print("[TutorialService] Player " .. player.Name .. " completed tutorial")
    
    -- Save to DataStore
    saveTutorialCompletion(player)
    
    -- Send confirmation to client
    Remotes.ShowFloatingNotification:FireClient(player, "Tutorial completed! You're ready to play!", "Success")
end

-- Check if player has completed tutorial
function TutorialService.HasCompletedTutorial(player)
    if not player or not player.UserId then return false end
    return tutorialCompletion[player.UserId] or false
end

-- Set tutorial completion status (for loading from saved data)
function TutorialService.SetTutorialCompletion(player, completed)
    if not player or not player.UserId then return end
    tutorialCompletion[player.UserId] = completed
    print("[TutorialService] Set tutorial completion for " .. player.Name .. " to: " .. tostring(completed))
end

-- Initialize tutorial service
function TutorialService.Start()
    print("[TutorialService] Starting TutorialService...")
    
    -- Connect to tutorial completion remote
    Remotes.SaveTutorialCompletion.OnServerEvent:Connect(handleTutorialCompletion)
    
    -- Connect to tutorial completion check remote
    Remotes.CheckTutorialCompletion.OnServerInvoke = function(player)
        return TutorialService.HasCompletedTutorial(player)
    end
    
    -- Handle players joining
    Players.PlayerAdded:Connect(function(player)
        -- Load tutorial completion status from DataStore
        task.spawn(function()
            local hasCompleted = loadTutorialCompletion(player)
            if not hasCompleted then
                print("[TutorialService] Player " .. player.Name .. " has not completed tutorial")
            else
                print("[TutorialService] Player " .. player.Name .. " has completed tutorial")
            end
        end)
    end)
    
    -- Handle players leaving
    Players.PlayerRemoving:Connect(function(player)
        if player and player.UserId then
            -- Save tutorial completion status before player leaves
            if tutorialCompletion[player.UserId] then
                saveTutorialCompletion(player)
            end
            -- Clear from memory
            tutorialCompletion[player.UserId] = nil
        end
    end)
    
    print("[TutorialService] Started successfully")
end

return TutorialService 