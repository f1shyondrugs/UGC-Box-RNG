local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Shared = ReplicatedStorage.Shared
local ItemValueCalculator = require(Shared.Modules.ItemValueCalculator)
local NumberFormatter = require(Shared.Modules.NumberFormatter)

local StatsUI = {}

-- Function to calculate appropriate UI scale based on screen size
local function calculateUIScale()
	local camera = workspace.CurrentCamera
	local screenSize = camera.ViewportSize
	
	-- Base scale for 1920x1080 (desktop)
	local baseWidth = 1920
	local baseHeight = 1080
	
	-- Calculate scale factors
	local widthScale = screenSize.X / baseWidth
	local heightScale = screenSize.Y / baseHeight
	
	-- Use the smaller scale to ensure UI fits on screen
	local scale = math.min(widthScale, heightScale)
	
	-- Special handling for mobile vs desktop
	if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
		-- Mobile device - keep smaller for touch interfaces
		scale = scale * 0.8
		-- Apply minimum and maximum bounds for mobile
		scale = math.max(0.4, math.min(scale, 1.0))
	else
		-- Desktop/PC - make UI larger and more prominent
		scale = scale * 1.3
		-- Apply minimum and maximum bounds for desktop
		scale = math.max(0.8, math.min(scale, 2.0))
	end
	
	return scale
end

function StatsUI.Create(parentGui)
	local components = {}
	
	-- Create a ScreenGui container for the stats
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "StatsGui"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = parentGui
	components.ScreenGui = screenGui
	
	-- Add a UIScale to manage UI scaling across different resolutions
	local uiScale = Instance.new("UIScale")
	uiScale.Scale = calculateUIScale()
	uiScale.Parent = screenGui
	components.UIScale = uiScale
	
	-- Main Stats Container (top center)
	local statsContainer = Instance.new("Frame")
	statsContainer.Name = "StatsContainer"
	statsContainer.Size = UDim2.new(0, 450, 0, 60) -- Increased width for margins
	statsContainer.Position = UDim2.new(0.5, -225, 0, 20) -- Adjusted center position
	statsContainer.BackgroundTransparency = 1
	statsContainer.ZIndex = 100
	statsContainer.Parent = screenGui
	components.StatsContainer = statsContainer
	
	-- RAP (Left side)
	local rapFrame = Instance.new("Frame")
	rapFrame.Name = "RAPFrame"
	rapFrame.Size = UDim2.new(0, 120, 0, 40)
	rapFrame.Position = UDim2.new(0, 0, 0.5, -20)
	rapFrame.BackgroundColor3 = Color3.fromRGB(41, 43, 48)
	rapFrame.BorderSizePixel = 2
	rapFrame.BorderColor3 = Color3.fromRGB(25, 27, 32) -- Darker border
	rapFrame.ZIndex = 101
	rapFrame.Parent = statsContainer
	components.RAPFrame = rapFrame
	
	local rapCorner = Instance.new("UICorner")
	rapCorner.CornerRadius = UDim.new(0, 8)
	rapCorner.Parent = rapFrame
	
	local rapIcon = Instance.new("TextLabel")
	rapIcon.Size = UDim2.new(0, 30, 0, 30)
	rapIcon.Position = UDim2.new(0, 5, 0.5, -15)
	rapIcon.BackgroundTransparency = 1
	rapIcon.Text = "📊"
	rapIcon.Font = Enum.Font.SourceSansBold
	rapIcon.TextScaled = true
	rapIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
	rapIcon.ZIndex = 102
	rapIcon.Parent = rapFrame
	
	local rapLabel = Instance.new("TextLabel")
	rapLabel.Name = "RAPLabel"
	rapLabel.Size = UDim2.new(1, -40, 1, 0)
	rapLabel.Position = UDim2.new(0, 35, 0, 0)
	rapLabel.BackgroundTransparency = 1
	rapLabel.Text = "R$0"
	rapLabel.Font = Enum.Font.SourceSansBold
	rapLabel.TextSize = 14
	rapLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	rapLabel.TextXAlignment = Enum.TextXAlignment.Left
	rapLabel.TextYAlignment = Enum.TextYAlignment.Center
	rapLabel.ZIndex = 102
	rapLabel.Parent = rapFrame
	components.RAPLabel = rapLabel
	
	-- R$ (Center - Main display)
	local robuxFrame = Instance.new("Frame")
	robuxFrame.Name = "RobuxFrame"
	robuxFrame.Size = UDim2.new(0, 160, 0, 50)
	robuxFrame.Position = UDim2.new(0.5, -80, 0.5, -25)
	robuxFrame.BackgroundColor3 = Color3.fromRGB(41, 43, 48)
	robuxFrame.BorderSizePixel = 2
	robuxFrame.BorderColor3 = Color3.fromRGB(25, 27, 32) -- Darker border
	robuxFrame.ZIndex = 103
	robuxFrame.Parent = statsContainer
	components.RobuxFrame = robuxFrame
	
	local robuxCorner = Instance.new("UICorner")
	robuxCorner.CornerRadius = UDim.new(0, 10)
	robuxCorner.Parent = robuxFrame
	
	-- Add subtle gradient to robux frame
	local robuxGradient = Instance.new("UIGradient")
	robuxGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 47, 52)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 37, 42))
	}
	robuxGradient.Rotation = 90
	robuxGradient.Parent = robuxFrame
	
	local robuxIcon = Instance.new("TextLabel")
	robuxIcon.Size = UDim2.new(0, 35, 0, 35)
	robuxIcon.Position = UDim2.new(0, 8, 0.5, -17)
	robuxIcon.BackgroundTransparency = 1
	robuxIcon.Text = "R$"
	robuxIcon.Font = Enum.Font.SourceSansBold
	robuxIcon.TextScaled = true
	robuxIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
	robuxIcon.ZIndex = 104
	robuxIcon.Parent = robuxFrame
	
	local robuxLabel = Instance.new("TextLabel")
	robuxLabel.Name = "RobuxLabel"
	robuxLabel.Size = UDim2.new(1, -50, 1, 0)
	robuxLabel.Position = UDim2.new(0, 45, 0, 0)
	robuxLabel.BackgroundTransparency = 1
	robuxLabel.Text = "500"
	robuxLabel.Font = Enum.Font.SourceSansBold
	robuxLabel.TextSize = 20
	robuxLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	robuxLabel.TextXAlignment = Enum.TextXAlignment.Left
	robuxLabel.TextYAlignment = Enum.TextYAlignment.Center
	robuxLabel.ZIndex = 104
	robuxLabel.Parent = robuxFrame
	components.RobuxLabel = robuxLabel
	
	-- Boxes Opened (Right side)
	local boxesFrame = Instance.new("Frame")
	boxesFrame.Name = "BoxesFrame"
	boxesFrame.Size = UDim2.new(0, 120, 0, 40)
	boxesFrame.Position = UDim2.new(1, -120, 0.5, -20)
	boxesFrame.BackgroundColor3 = Color3.fromRGB(41, 43, 48)
	boxesFrame.BorderSizePixel = 2
	boxesFrame.BorderColor3 = Color3.fromRGB(25, 27, 32) -- Darker border
	boxesFrame.ZIndex = 101
	boxesFrame.Parent = statsContainer
	components.BoxesFrame = boxesFrame
	
	local boxesCorner = Instance.new("UICorner")
	boxesCorner.CornerRadius = UDim.new(0, 8)
	boxesCorner.Parent = boxesFrame
	
	local boxesIcon = Instance.new("TextLabel")
	boxesIcon.Size = UDim2.new(0, 30, 0, 30)
	boxesIcon.Position = UDim2.new(0, 5, 0.5, -15)
	boxesIcon.BackgroundTransparency = 1
	boxesIcon.Text = "📦"
	boxesIcon.Font = Enum.Font.SourceSansBold
	boxesIcon.TextScaled = true
	boxesIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
	boxesIcon.ZIndex = 102
	boxesIcon.Parent = boxesFrame
	
	local boxesLabel = Instance.new("TextLabel")
	boxesLabel.Name = "BoxesLabel"
	boxesLabel.Size = UDim2.new(1, -40, 1, 0)
	boxesLabel.Position = UDim2.new(0, 35, 0, 0)
	boxesLabel.BackgroundTransparency = 1
	boxesLabel.Text = "0"
	boxesLabel.Font = Enum.Font.SourceSansBold
	boxesLabel.TextSize = 14
	boxesLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	boxesLabel.TextXAlignment = Enum.TextXAlignment.Left
	boxesLabel.TextYAlignment = Enum.TextYAlignment.Center
	boxesLabel.ZIndex = 102
	boxesLabel.Parent = boxesFrame
	components.BoxesLabel = boxesLabel
	
	-- Update scale when screen size changes
	local function updateScale()
		uiScale.Scale = calculateUIScale()
	end
	
	-- Connect to viewport size changes
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
	components.UpdateScale = updateScale
	
	return components
end

function StatsUI.UpdateStats(components, robux, rap, boxesOpened, rebirths)
	-- Update R$ with formatting (center display - no R$ prefix since icon shows it)
	components.RobuxLabel.Text = NumberFormatter.FormatNumber(robux)
	
	-- Update RAP with formatting
	components.RAPLabel.Text = ItemValueCalculator.GetFormattedRAP(rap)
	
	-- Update Boxes Opened with formatting
	components.BoxesLabel.Text = NumberFormatter.FormatCount(boxesOpened)
	
	-- Update Rebirths (if rebirths parameter is provided)
	if rebirths then
		-- For now, we'll just update the boxes label to show rebirths
		-- You might want to add a separate rebirths display later
		components.BoxesLabel.Text = NumberFormatter.FormatCount(boxesOpened) .. " | " .. tostring(rebirths) .. "R"
	end
end

return StatsUI 