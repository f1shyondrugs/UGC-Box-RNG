local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Shared = ReplicatedStorage.Shared
local ItemValueCalculator = require(Shared.Modules.ItemValueCalculator)

local StatsUI = {}

function StatsUI.Create(parentGui)
	local components = {}
	
	-- Main Stats Bar
	local statsBar = Instance.new("Frame")
	statsBar.Name = "StatsBar"
	statsBar.Size = UDim2.new(1, 0, 0, 60)
	statsBar.Position = UDim2.new(0, 0, 0, 0)
	statsBar.BackgroundColor3 = Color3.fromRGB(24, 25, 28)
	statsBar.BorderSizePixel = 0
	statsBar.Parent = parentGui
	components.StatsBar = statsBar
	
	-- Gradient for visual appeal
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(24, 25, 28)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(31, 33, 38))
	}
	gradient.Rotation = 90
	gradient.Parent = statsBar
	
	-- Stats Container
	local statsContainer = Instance.new("Frame")
	statsContainer.Size = UDim2.new(1, -20, 1, -10)
	statsContainer.Position = UDim2.new(0, 10, 0, 5)
	statsContainer.BackgroundTransparency = 1
	statsContainer.Parent = statsBar
	
	local statsLayout = Instance.new("UIListLayout")
	statsLayout.FillDirection = Enum.FillDirection.Horizontal
	statsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	statsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	statsLayout.Padding = UDim.new(0.05, 0)
	statsLayout.Parent = statsContainer
	
	-- R$ Stat
	local robuxFrame = Instance.new("Frame")
	robuxFrame.Size = UDim2.new(0.2, 0, 1, 0)
	robuxFrame.BackgroundTransparency = 1
	robuxFrame.Parent = statsContainer
	
	local robuxIcon = Instance.new("TextLabel")
	robuxIcon.Size = UDim2.new(0, 50, 0, 50)
	robuxIcon.Position = UDim2.new(0, 0, 0.5, 0)
	robuxIcon.AnchorPoint = Vector2.new(0, 0.5)
	robuxIcon.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
	robuxIcon.Text = "R$"
	robuxIcon.Font = Enum.Font.SourceSansBold
	robuxIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
	robuxIcon.TextScaled = true
	robuxIcon.Parent = robuxFrame
	
	local robuxIconAspect = Instance.new("UIAspectRatioConstraint")
	robuxIconAspect.AspectRatio = 1
	robuxIconAspect.Parent = robuxIcon
	
	local robuxCorner = Instance.new("UICorner")
	robuxCorner.CornerRadius = UDim.new(0, 6)
	robuxCorner.Parent = robuxIcon
	
	local robuxLabel = Instance.new("TextLabel")
	robuxLabel.Size = UDim2.new(1, -55, 1, 0)
	robuxLabel.Position = UDim2.new(0, 55, 0, 0)
	robuxLabel.BackgroundTransparency = 1
	robuxLabel.Text = "R$100"
	robuxLabel.Font = Enum.Font.SourceSansBold
	robuxLabel.TextColor3 = Color3.fromRGB(76, 175, 80)
	robuxLabel.TextXAlignment = Enum.TextXAlignment.Left
	robuxLabel.TextScaled = true
	robuxLabel.Parent = robuxFrame
	components.RobuxLabel = robuxLabel
	
	-- RAP Stat
	local rapFrame = Instance.new("Frame")
	rapFrame.Size = UDim2.new(0.2, 0, 1, 0)
	rapFrame.BackgroundTransparency = 1
	rapFrame.Parent = statsContainer
	
	local rapIcon = Instance.new("TextLabel")
	rapIcon.Size = UDim2.new(0, 50, 0, 50)
	rapIcon.Position = UDim2.new(0, 0, 0.5, 0)
	rapIcon.AnchorPoint = Vector2.new(0, 0.5)
	rapIcon.BackgroundColor3 = Color3.fromRGB(255, 193, 7)
	rapIcon.Text = "📊"
	rapIcon.Font = Enum.Font.SourceSans
	rapIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
	rapIcon.TextScaled = true
	rapIcon.Parent = rapFrame
	
	local rapIconAspect = Instance.new("UIAspectRatioConstraint")
	rapIconAspect.AspectRatio = 1
	rapIconAspect.Parent = rapIcon
	
	local rapCorner = Instance.new("UICorner")
	rapCorner.CornerRadius = UDim.new(0, 6)
	rapCorner.Parent = rapIcon
	
	local rapLabel = Instance.new("TextLabel")
	rapLabel.Size = UDim2.new(1, -55, 1, 0)
	rapLabel.Position = UDim2.new(0, 55, 0, 0)
	rapLabel.BackgroundTransparency = 1
	rapLabel.Text = "RAP: R$0"
	rapLabel.Font = Enum.Font.SourceSansBold
	rapLabel.TextColor3 = Color3.fromRGB(255, 193, 7)
	rapLabel.TextXAlignment = Enum.TextXAlignment.Left
	rapLabel.TextScaled = true
	rapLabel.Parent = rapFrame
	components.RAPLabel = rapLabel
	
	-- Boxes Opened Stat
	local boxesFrame = Instance.new("Frame")
	boxesFrame.Size = UDim2.new(0.2, 0, 1, 0)
	boxesFrame.BackgroundTransparency = 1
	boxesFrame.Parent = statsContainer
	
	local boxesIcon = Instance.new("TextLabel")
	boxesIcon.Size = UDim2.new(0, 50, 0, 50)
	boxesIcon.Position = UDim2.new(0, 0, 0.5, 0)
	boxesIcon.AnchorPoint = Vector2.new(0, 0.5)
	boxesIcon.BackgroundColor3 = Color3.fromRGB(156, 39, 176)
	boxesIcon.Text = "📦"
	boxesIcon.Font = Enum.Font.SourceSans
	boxesIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
	boxesIcon.TextScaled = true
	boxesIcon.Parent = boxesFrame
	
	local boxesIconAspect = Instance.new("UIAspectRatioConstraint")
	boxesIconAspect.AspectRatio = 1
	boxesIconAspect.Parent = boxesIcon
	
	local boxesCorner = Instance.new("UICorner")
	boxesCorner.CornerRadius = UDim.new(0, 6)
	boxesCorner.Parent = boxesIcon
	
	local boxesLabel = Instance.new("TextLabel")
	boxesLabel.Size = UDim2.new(1, -55, 1, 0)
	boxesLabel.Position = UDim2.new(0, 55, 0, 0)
	boxesLabel.BackgroundTransparency = 1
	boxesLabel.Text = "Boxes: 0"
	boxesLabel.Font = Enum.Font.SourceSansBold
	boxesLabel.TextColor3 = Color3.fromRGB(156, 39, 176)
	boxesLabel.TextXAlignment = Enum.TextXAlignment.Left
	boxesLabel.TextScaled = true
	boxesLabel.Parent = boxesFrame
	components.BoxesLabel = boxesLabel
	
	return components
end

function StatsUI.UpdateStats(components, robux, rap, boxesOpened)
	-- Update R$ with formatting
	if robux >= 1000000 then
		components.RobuxLabel.Text = string.format("R$%.1fM", robux / 1000000)
	elseif robux >= 1000 then
		components.RobuxLabel.Text = string.format("R$%.1fK", robux / 1000)
	else
		components.RobuxLabel.Text = string.format("R$%d", robux)
	end
	
	-- Update RAP with formatting
	components.RAPLabel.Text = "RAP: " .. ItemValueCalculator.GetFormattedRAP(rap)
	
	-- Update Boxes Opened with formatting
	if boxesOpened >= 1000000 then
		components.BoxesLabel.Text = string.format("Boxes: %.1fM", boxesOpened / 1000000)
	elseif boxesOpened >= 1000 then
		components.BoxesLabel.Text = string.format("Boxes: %.1fK", boxesOpened / 1000)
	else
		components.BoxesLabel.Text = string.format("Boxes: %d", boxesOpened)
	end
end

return StatsUI 