-- UpgradeUI.lua
-- Upgrade management interface matching Collection GUI style

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Shared = ReplicatedStorage.Shared
local UpgradeConfig = require(Shared.Modules.UpgradeConfig)
local NumberFormatter = require(Shared.Modules.NumberFormatter)

local UpgradeUI = {}

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

function UpgradeUI.Create(parentGui)
	local components = {}
	
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "UpgradeGui"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = parentGui
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	components.ScreenGui = screenGui

	local uiScale = Instance.new("UIScale")
	uiScale.Scale = calculateUIScale()
	uiScale.Parent = screenGui
	components.UIScale = uiScale

	-- Note: Toggle button is now managed by NavigationController

	-- Main Frame (with margins from screen edges)
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "UpgradeMainFrame"
	mainFrame.Size = UDim2.new(1, -60, 1, -60) -- Add 30px margin on all sides
	mainFrame.Position = UDim2.new(0, 30, 0, 30) -- Center with 30px offset
	mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
	mainFrame.BackgroundTransparency = 0.05
	mainFrame.BorderSizePixel = 0
	mainFrame.Visible = false
	mainFrame.ZIndex = 50
	mainFrame.Parent = screenGui
	components.MainFrame = mainFrame
	
	-- Add rounded corners to main frame
	local mainFrameCorner = Instance.new("UICorner")
	mainFrameCorner.CornerRadius = UDim.new(0, 16)
	mainFrameCorner.Parent = mainFrame

	-- Background gradient
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 35)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 20))
	}
	gradient.Rotation = 45
	gradient.Parent = mainFrame

	-- Title Bar
	local titleBar = Instance.new("Frame")
	titleBar.Name = "TitleBar"
	titleBar.Size = UDim2.new(1, 0, 0, 80)
	titleBar.Position = UDim2.new(0, 0, 0, 0)
	titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
	titleBar.BorderSizePixel = 0
	titleBar.ZIndex = 51
	titleBar.Parent = mainFrame
	
	-- Add rounded corners to title bar (top corners only)
	local titleBarCorner = Instance.new("UICorner")
	titleBarCorner.CornerRadius = UDim.new(0, 16)
	titleBarCorner.Parent = titleBar
	
	local titleGradient = Instance.new("UIGradient")
	titleGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 35, 65)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 40))
	}
	titleGradient.Rotation = 90
	titleGradient.Parent = titleBar

	-- Title
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, -120, 1, 0)
	title.Position = UDim2.new(0, 20, 0, 0)
	title.Text = "⚡ UPGRADES"
	title.Font = Enum.Font.SourceSansBold
	title.TextSize = 32
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.BackgroundTransparency = 1
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.ZIndex = 52
	title.Parent = titleBar
	components.Title = title

	-- Close Button
	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Size = UDim2.new(0, 50, 0, 50)
	closeButton.Position = UDim2.new(1, -65, 0, 15)
	closeButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
	closeButton.Text = "X"
	closeButton.Font = Enum.Font.SourceSansBold
	closeButton.TextScaled = true
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.ZIndex = 55
	closeButton.Parent = titleBar
	components.CloseButton = closeButton

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 16)
	closeCorner.Parent = closeButton

	-- Content Area
	local contentFrame = Instance.new("Frame")
	contentFrame.Name = "ContentFrame"
	contentFrame.Size = UDim2.new(1, -40, 1, -120)
	contentFrame.Position = UDim2.new(0, 20, 0, 100)
	contentFrame.BackgroundTransparency = 1
	contentFrame.ZIndex = 51
	contentFrame.Parent = mainFrame

	-- Scrolling Frame for upgrades
	local scrollingFrame = Instance.new("ScrollingFrame")
	scrollingFrame.Name = "UpgradeScrollingFrame"
	scrollingFrame.Size = UDim2.new(1, 0, 1, 0)
	scrollingFrame.Position = UDim2.new(0, 0, 0, 0)
	scrollingFrame.BackgroundTransparency = 1
	scrollingFrame.BorderSizePixel = 0
	scrollingFrame.ScrollBarThickness = 8
	scrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
	scrollingFrame.ZIndex = 52
	scrollingFrame.Parent = contentFrame
	components.ScrollingFrame = scrollingFrame

	-- Layout for upgrade items
	local upgradeLayout = Instance.new("UIListLayout")
	upgradeLayout.SortOrder = Enum.SortOrder.LayoutOrder
	upgradeLayout.Padding = UDim.new(0, 15)
	upgradeLayout.Parent = scrollingFrame

	-- Store upgrade frames for updates
	components.UpgradeFrames = {}

	return components
end

-- Create an individual upgrade frame
function UpgradeUI.CreateUpgradeFrame(parent, upgradeId, upgradeData)
	local upgrade = UpgradeConfig.Upgrades[upgradeId]
	if not upgrade then return nil end

	local upgradeFrame = Instance.new("Frame")
	upgradeFrame.Name = upgradeId .. "Frame"
	upgradeFrame.Size = UDim2.new(1, 0, 0, 120)
	upgradeFrame.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
	upgradeFrame.BorderSizePixel = 0
	upgradeFrame.ZIndex = 53
	upgradeFrame.Parent = parent

	local frameCorner = Instance.new("UICorner")
	frameCorner.CornerRadius = UDim.new(0, 12)
	frameCorner.Parent = upgradeFrame

	local frameGradient = Instance.new("UIGradient")
	frameGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 40, 55)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 30, 40))
	}
	frameGradient.Rotation = 90
	frameGradient.Parent = upgradeFrame

	-- Icon
	local icon = Instance.new("TextLabel")
	icon.Name = "Icon"
	icon.Size = UDim2.new(0, 60, 0, 60)
	icon.Position = UDim2.new(0, 15, 0, 15)
	icon.Text = upgrade.Icon
	icon.Font = Enum.Font.SourceSansBold
	icon.TextSize = 32
	icon.TextColor3 = Color3.fromRGB(255, 255, 255)
	icon.BackgroundColor3 = Color3.fromRGB(40, 45, 60)
	icon.ZIndex = 54
	icon.Parent = upgradeFrame

	local iconCorner = Instance.new("UICorner")
	iconCorner.CornerRadius = UDim.new(0, 8)
	iconCorner.Parent = icon

	-- Name and Description
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.Size = UDim2.new(0, 300, 0, 25)
	nameLabel.Position = UDim2.new(0, 90, 0, 15)
	nameLabel.Text = upgrade.Name
	nameLabel.Font = Enum.Font.SourceSansBold
	nameLabel.TextSize = 18
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.BackgroundTransparency = 1
	nameLabel.ZIndex = 54
	nameLabel.Parent = upgradeFrame

	local descLabel = Instance.new("TextLabel")
	descLabel.Name = "DescLabel"
	descLabel.Size = UDim2.new(0, 300, 0, 20)
	descLabel.Position = UDim2.new(0, 90, 0, 40)
	descLabel.Text = upgrade.Description
	descLabel.Font = Enum.Font.SourceSans
	descLabel.TextSize = 14
	descLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.BackgroundTransparency = 1
	descLabel.ZIndex = 54
	descLabel.Parent = upgradeFrame

	-- Level and Effect Info
	local levelLabel = Instance.new("TextLabel")
	levelLabel.Name = "LevelLabel"
	levelLabel.Size = UDim2.new(0, 150, 0, 20)
	levelLabel.Position = UDim2.new(0, 90, 0, 65)
	levelLabel.Text = "Level: " .. upgradeData.level .. "/" .. upgrade.MaxLevel
	levelLabel.Font = Enum.Font.SourceSansBold
	levelLabel.TextSize = 14
	levelLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
	levelLabel.TextXAlignment = Enum.TextXAlignment.Left
	levelLabel.BackgroundTransparency = 1
	levelLabel.ZIndex = 54
	levelLabel.Parent = upgradeFrame

	local effectLabel = Instance.new("TextLabel")
	effectLabel.Name = "EffectLabel"
	effectLabel.Size = UDim2.new(0, 200, 0, 20)
	effectLabel.Position = UDim2.new(0, 90, 0, 85)
	effectLabel.Font = Enum.Font.SourceSans
	effectLabel.TextSize = 12
	effectLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
	effectLabel.TextXAlignment = Enum.TextXAlignment.Left
	effectLabel.BackgroundTransparency = 1
	effectLabel.ZIndex = 54
	effectLabel.Parent = upgradeFrame

	-- Upgrade Button
	local upgradeButton = Instance.new("TextButton")
	upgradeButton.Name = "UpgradeButton"
	upgradeButton.Size = UDim2.new(0, 120, 0, 40)
	upgradeButton.Position = UDim2.new(1, -135, 0, 40)
	upgradeButton.Font = Enum.Font.SourceSansBold
	upgradeButton.TextSize = 14
	upgradeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	upgradeButton.ZIndex = 54
	upgradeButton.Parent = upgradeFrame

	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 8)
	buttonCorner.Parent = upgradeButton

	-- Store references for updates
	local components = {
		Frame = upgradeFrame,
		LevelLabel = levelLabel,
		EffectLabel = effectLabel,
		UpgradeButton = upgradeButton
	}

	-- Update display based on upgrade data
	UpgradeUI.UpdateUpgradeFrame(components, upgradeId, upgradeData)

	return components
end

-- Update an upgrade frame with current data
function UpgradeUI.UpdateUpgradeFrame(components, upgradeId, upgradeData)
	local upgrade = UpgradeConfig.Upgrades[upgradeId]
	if not upgrade or not components then return end

	-- Update level display
	components.LevelLabel.Text = "Level: " .. upgradeData.level .. "/" .. upgrade.MaxLevel

	-- Update effect display
	local effectText = ""
	if upgradeData.isMaxLevel then
		effectText = "MAX LEVEL REACHED"
		components.EffectLabel.TextColor3 = Color3.fromRGB(255, 215, 0) -- Gold
	else
		if upgradeId == "InventorySlots" then
			effectText = "Current: " .. upgradeData.effects.CurrentSlots .. " → Next: " .. upgradeData.effects.NextSlots
		elseif upgradeId == "MultiCrateOpening" then
			effectText = "Current: " .. upgradeData.effects.CurrentBoxes .. " → Next: " .. upgradeData.effects.NextBoxes
		elseif upgradeId == "FasterCooldowns" then
			effectText = "Current: " .. upgradeData.effects.CurrentCooldown .. " → Next: " .. upgradeData.effects.NextCooldown
		end
		components.EffectLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
	end
	components.EffectLabel.Text = effectText

	-- Update button
	if upgradeData.isMaxLevel then
		components.UpgradeButton.Text = "MAX LEVEL"
		components.UpgradeButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
		components.UpgradeButton.Active = false
	else
		components.UpgradeButton.Text = "Upgrade\n" .. NumberFormatter.FormatCurrency(upgradeData.cost or 0)
		components.UpgradeButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
		components.UpgradeButton.Active = true
	end
end

-- Update affordability based on player money
function UpgradeUI.UpdateAffordability(ui, playerMoney)
	-- Convert playerMoney to number if it's a string (from StringValue)
	local numericPlayerMoney = tonumber(playerMoney)
	if not numericPlayerMoney then
		-- Handle formatted currency strings by removing non-digit characters except decimal points
		local cleanString = string.gsub(tostring(playerMoney), "[^%d%.]", "")
		numericPlayerMoney = tonumber(cleanString) or 0
	end
	
	for upgradeId, upgradeFrame in pairs(ui.UpgradeFrames) do
		local button = upgradeFrame.UpgradeButton
		if button.Active then
			local cost = tonumber(string.match(button.Text, "(%d+)"))
			if cost and numericPlayerMoney < cost then
				button.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
			else
				button.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
			end
		end
	end
end

return UpgradeUI 