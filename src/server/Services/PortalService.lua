local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage.Shared
local Remotes = require(Shared.Remotes.Remotes)
local GameConfig = require(Shared.Modules.GameConfig)
local RebirthService = require(script.Parent.RebirthService)

local PortalService = {}

-- Area configurations with rebirth requirements
local AREAS = {
    [1] = { rebirths = 2 },
    [2] = { rebirths = 4 },
    [3] = { rebirths = 6 },
    [4] = { rebirths = 8 },
    [5] = { rebirths = 10 },
}

local function handlePortalTeleport(player, targetArea)
    -- Check rebirth requirement
    local rebirthData = RebirthService.GetPlayerRebirthData(player)
    local currentRebirths = rebirthData.currentRebirth or 0
    local requiredRebirths = AREAS[targetArea].rebirths
    
    if currentRebirths < requiredRebirths then
        -- Show error message
        local message = "Requires " .. requiredRebirths .. " rebirths!\nYou have: " .. currentRebirths
        Remotes.ShowFloatingError:FireClient(player, player.Character.HumanoidRootPart.Position, message)
        return
    end
    
    -- Find the target area portal part to teleport to
    local portalsFolder = Workspace:FindFirstChild("Portals")
    if portalsFolder then
        local targetPortal = portalsFolder:FindFirstChild(tostring(targetArea) .. "t")
        if targetPortal and targetPortal:IsA("BasePart") then
            -- Teleport player to the portal part's position
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = CFrame.new(targetPortal.Position)
                Remotes.PortalTeleported:FireClient(player, targetArea)
                print("[PortalService] Teleported " .. player.Name .. " to Area " .. targetArea .. " at position: " .. tostring(targetPortal.Position))
            end
        else
            print("[PortalService] Warning: Target portal part '" .. targetArea .. "t' not found")
        end
    end
end

local function setupExistingPortals()
    local portalsFolder = Workspace:FindFirstChild("Portals")
    if not portalsFolder then
        print("[PortalService] No Portals folder found in workspace. Please create a Portals folder with parts named 1, 2, 3, 4, 5")
        return
    end
    
    -- Setup touch detection for existing portal parts
    for _, portalPart in pairs(portalsFolder:GetChildren()) do
        if portalPart:IsA("BasePart") then
            -- Only setup touch detection for regular portal parts (not the "t" destination parts)
            local areaNumber = portalPart.Name:match("^(%d+)$")
            if areaNumber then
                local targetArea = tonumber(areaNumber)
                if targetArea and AREAS[targetArea] then
                    -- Add portal metadata
                    portalPart:SetAttribute("TargetArea", targetArea)
                    
                    -- Setup touch detection
                    portalPart.Touched:Connect(function(hit)
                        local character = hit.Parent
                        local player = Players:GetPlayerFromCharacter(character)
                        
                        if player then
                            handlePortalTeleport(player, targetArea)
                        end
                    end)
                    
                    print("[PortalService] Setup portal for Area " .. targetArea .. " at position: " .. tostring(portalPart.Position))
                else
                    print("[PortalService] Warning: Portal part '" .. portalPart.Name .. "' has invalid area number. Should be 1, 2, 3, 4, or 5")
                end
            elseif portalPart.Name:match("^(%d+)t$") then
                -- This is a destination part, don't setup touch detection
                print("[PortalService] Found destination part: " .. portalPart.Name .. " (no touch detection needed)")
            else
                print("[PortalService] Warning: Portal part '" .. portalPart.Name .. "' has invalid name format. Should be 1, 2, 3, 4, 5 or 1t, 2t, 3t, 4t, 5t")
            end
        end
    end
end



function PortalService.Start()
    -- Setup existing portal parts in the workspace
    setupExistingPortals()
    
    -- Handle portal teleport requests (backup method)
    Remotes.RequestPortalTeleport.OnServerEvent:Connect(function(player, targetArea)
        handlePortalTeleport(player, targetArea)
    end)
    
    print("[PortalService] Started successfully!")
end

return PortalService 