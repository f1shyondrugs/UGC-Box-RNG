local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local Notifier = {}

-- Reference to settings controller (will be set from main client)
local settingsController = nil

-- Set reference to settings controller
function Notifier.SetSettingsController(settings)
	settingsController = settings
end

-- Check if effects are disabled
local function areEffectsDisabled()
	return settingsController and settingsController.AreEffectsDisabled() or false
end

local notificationFrame
local textLabel

local function createNotificationUI(parent)
    notificationFrame = Instance.new("Frame")
    notificationFrame.Size = UDim2.new(1, 0, 0, 50)
    notificationFrame.Position = UDim2.new(0, 0, -50, 0) -- Start off-screen
    notificationFrame.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Default to error color
    notificationFrame.BorderSizePixel = 0
    notificationFrame.Parent = parent

    textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextSize = 20
    textLabel.TextColor3 = Color3.new(1,1,1)
    textLabel.Parent = notificationFrame
end

function Notifier.Start(parentGui)
    createNotificationUI(parentGui)

    local Remotes = require(game:GetService("ReplicatedStorage").Shared.Remotes.Remotes)
    Remotes.Notify.OnClientEvent:Connect(function(message, messageType)
        -- Skip animations if effects are disabled, but still show the message briefly
        if areEffectsDisabled() then
            textLabel.Text = message
            if messageType == "Error" then
                notificationFrame.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            else
                notificationFrame.BackgroundColor3 = Color3.fromRGB(50, 150, 200)
            end
            
            -- Show message immediately without animation
            notificationFrame.Position = UDim2.new(0, 0, 0, 0)
            task.wait(2) -- Shorter display time without animation
            notificationFrame.Position = UDim2.new(0, 0, -50, 0)
            return
        end
        
        textLabel.Text = message
        if messageType == "Error" then
            notificationFrame.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        else
            notificationFrame.BackgroundColor3 = Color3.fromRGB(50, 150, 200)
        end

        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        local tweenOn = TweenService:Create(notificationFrame, tweenInfo, {Position = UDim2.new(0, 0, 0, 0)})
        tweenOn:Play()

        task.wait(3)

        local tweenOff = TweenService:Create(notificationFrame, tweenInfo, {Position = UDim2.new(0, 0, -50, 0)})
        tweenOff:Play()
    end)
end

return Notifier 