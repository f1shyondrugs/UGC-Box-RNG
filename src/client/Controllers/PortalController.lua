local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Shared = ReplicatedStorage.Shared
local Remotes = require(Shared.Remotes.Remotes)
local GameConfig = require(Shared.Modules.GameConfig)

local PortalController = {}

local portalGuis = {} -- Store references to SurfaceGUIs
local currentRebirths = 0

-- Area configurations with rebirth requirements
local AREAS = {
    [1] = { rebirths = 2 },
    [2] = { rebirths = 4 },
    [3] = { rebirths = 6 },
    [4] = { rebirths = 8 },
    [5] = { rebirths = 10 },
}

local function createPortalGui(portalPart, areaNumber)
    -- Remove existing GUI if any
    if portalGuis[portalPart] then
        portalGuis[portalPart]:Destroy()
        portalGuis[portalPart] = nil
    end
    
    -- Create SurfaceGui
    local surfaceGui = Instance.new("SurfaceGui")
    surfaceGui.Name = "PortalGui"
    surfaceGui.Face = Enum.NormalId.Front
    surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
    surfaceGui.PixelsPerStud = 50
    surfaceGui.Parent = portalPart
    portalGuis[portalPart] = surfaceGui
    
    -- Create main frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(1, 0, 1, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    mainFrame.BackgroundTransparency = 1 -- Completely transparent
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = surfaceGui
    
    -- Add rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    -- Create area title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, -20, 0.4, 0) -- Add margin
    titleLabel.Position = UDim2.new(0, 10, 0, 0) -- Center with margin
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Area " .. areaNumber
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = mainFrame
    
    -- Create requirement text
    local requirementLabel = Instance.new("TextLabel")
    requirementLabel.Name = "RequirementLabel"
    requirementLabel.Size = UDim2.new(1, -20, 0.6, 0) -- Add margin
    requirementLabel.Position = UDim2.new(0, 10, 0.4, 0) -- Center with margin
    requirementLabel.BackgroundTransparency = 1
    requirementLabel.Text = "Requires " .. AREAS[areaNumber].rebirths .. " rebirths"
    requirementLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    requirementLabel.TextScaled = false -- Don't auto-scale
    requirementLabel.TextSize = 24 -- Fixed medium size
    requirementLabel.Font = Enum.Font.Gotham
    requirementLabel.Parent = mainFrame
    
    return surfaceGui
end

local function updatePortalStatus(portalPart, areaNumber)
    local isUnlocked = currentRebirths >= AREAS[areaNumber].rebirths
    
    -- Update part color
    if isUnlocked then
        portalPart.Color = Color3.fromRGB(50, 200, 50) -- Green for unlocked
    else
        portalPart.Color = Color3.fromRGB(200, 50, 50) -- Red for locked
    end
    
    -- Update GUI colors
    local surfaceGui = portalGuis[portalPart]
    if surfaceGui then
        local mainFrame = surfaceGui.MainFrame
        local titleLabel = mainFrame.TitleLabel
        local requirementLabel = mainFrame.RequirementLabel
        
        if isUnlocked then
            titleLabel.TextColor3 = Color3.fromRGB(50, 200, 50)
            requirementLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
            requirementLabel.Text = "UNLOCKED"
            requirementLabel.TextSize = 38 -- Larger for unlocked
        else
            titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            requirementLabel.TextColor3 = Color3.fromRGB(255, 150, 150)
            requirementLabel.Text = "Requires " .. AREAS[areaNumber].rebirths .. " rebirths"
            requirementLabel.TextSize = 34 -- Medium for locked
        end
    end
end

local function setupPortalVisuals()
    local portalsFolder = Workspace:FindFirstChild("Portals")
    if not portalsFolder then
        print("[PortalController] No Portals folder found")
        return
    end
    
    -- Setup visuals for regular portal parts (not the "t" destination parts)
    for _, portalPart in pairs(portalsFolder:GetChildren()) do
        if portalPart:IsA("BasePart") then
            local areaNumber = portalPart.Name:match("^(%d+)$")
            if areaNumber then
                local targetArea = tonumber(areaNumber)
                if targetArea and AREAS[targetArea] then
                    -- Create GUI for this portal
                    createPortalGui(portalPart, targetArea)
                    
                    -- Update initial status
                    updatePortalStatus(portalPart, targetArea)
                    
                    print("[PortalController] Setup visuals for portal " .. targetArea)
                end
            end
        end
    end
end

local function updateAllPortalStatuses()
    local portalsFolder = Workspace:FindFirstChild("Portals")
    if portalsFolder then
        for _, portalPart in pairs(portalsFolder:GetChildren()) do
            if portalPart:IsA("BasePart") then
                local areaNumber = portalPart.Name:match("^(%d+)$")
                if areaNumber then
                    local targetArea = tonumber(areaNumber)
                    if targetArea and AREAS[targetArea] then
                        updatePortalStatus(portalPart, targetArea)
                    end
                end
            end
        end
    end
end

function PortalController.Start()
    -- Setup initial portal visuals
    setupPortalVisuals()
    
    -- Listen for rebirth updates
    Remotes.RebirthUpdated.OnClientEvent:Connect(function(rebirthData)
        currentRebirths = rebirthData.currentRebirth or 0
        updateAllPortalStatuses()
        print("[PortalController] Updated portal statuses for " .. currentRebirths .. " rebirths")
    end)
    
    -- Get initial rebirth data
    task.spawn(function()
        local success, rebirthData = pcall(function()
            return Remotes.GetRebirthData:InvokeServer()
        end)
        
        if success and rebirthData then
            currentRebirths = rebirthData.currentRebirth or 0
            updateAllPortalStatuses()
            print("[PortalController] Initial portal statuses updated for " .. currentRebirths .. " rebirths")
        end
    end)
    
    print("[PortalController] Started successfully!")
end

return PortalController 