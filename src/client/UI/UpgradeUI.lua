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
local ButtonStyles = require(script.Parent.ButtonStyles)

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
	mainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
	mainFrame.BackgroundTransparency = 0.02
	mainFrame.BorderSizePixel = 0
	mainFrame.Visible = false
	mainFrame.ZIndex = 50
	mainFrame.Parent = screenGui
	components.MainFrame = mainFrame
	
	-- Add rounded corners to main frame
	local mainFrameCorner = Instance.new("UICorner")
	mainFrameCorner.CornerRadius = UDim.new(0, 20)
	mainFrameCorner.Parent = mainFrame

	-- Background gradient with more depth
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 24, 35)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(15, 18, 28)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 12, 18))
	}
	gradient.Rotation = 135
	gradient.Parent = mainFrame

	-- Title Bar
	local titleBar = Instance.new("Frame")
	titleBar.Name = "TitleBar"
	titleBar.Size = UDim2.new(1, 0, 0, 70)
	titleBar.Position = UDim2.new(0, 0, 0, 0)
	titleBar.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
	titleBar.BorderSizePixel = 0
	titleBar.ZIndex = 51
	titleBar.Parent = mainFrame
	
	-- Add rounded corners to title bar
	local titleBarCorner = Instance.new("UICorner")
	titleBarCorner.CornerRadius = UDim.new(0, 20)
	titleBarCorner.Parent = titleBar
	
	-- Title bar gradient
	local titleGradient = Instance.new("UIGradient")
	titleGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 45, 75)),
		ColorSequenceKeypoint.new(0.3, Color3.fromRGB(40, 35, 60)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 45))
	}
	titleGradient.Rotation = 110
	titleGradient.Parent = titleBar

	-- Add a subtle accent line
	local accentLine = Instance.new("Frame")
	accentLine.Name = "AccentLine"
	accentLine.Size = UDim2.new(1, 0, 0, 2)
	accentLine.Position = UDim2.new(0, 0, 1, -2)
	accentLine.BackgroundColor3 = Color3.fromRGB(120, 80, 255)
	accentLine.BorderSizePixel = 0
	accentLine.ZIndex = 52
	accentLine.Parent = titleBar
	
	local accentGradient = Instance.new("UIGradient")
	accentGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 80, 255)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 100, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(90, 60, 200))
	}
	accentGradient.Parent = accentLine

	-- Title with improved styling
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, -120, 1, 0)
	title.Position = UDim2.new(0, 25, 0, 0)
	title.Text = "⚡ UPGRADES"
	title.Font = Enum.Font.GothamBold
	title.TextSize = 24
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.BackgroundTransparency = 1
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextYAlignment = Enum.TextYAlignment.Center
	title.ZIndex = 52
	title.Parent = titleBar
	components.Title = title

	-- Add text shadow effect
	local titleShadow = Instance.new("TextLabel")
	titleShadow.Name = "TitleShadow"
	titleShadow.Size = title.Size
	titleShadow.Position = UDim2.new(0, 27, 0, 2)
	titleShadow.Text = title.Text
	titleShadow.Font = title.Font
	titleShadow.TextSize = title.TextSize
	titleShadow.TextColor3 = Color3.fromRGB(0, 0, 0)
	titleShadow.TextTransparency = 0.8
	titleShadow.BackgroundTransparency = 1
	titleShadow.TextXAlignment = Enum.TextXAlignment.Left
	titleShadow.TextYAlignment = Enum.TextYAlignment.Center
	titleShadow.ZIndex = 51
	titleShadow.Parent = titleBar

	-- Close Button
	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Size = UDim2.new(0, 40, 0, 40)
	closeButton.Position = UDim2.new(1, -50, 0.5, -20)
	closeButton.BackgroundColor3 = Color3.fromRGB(220, 70, 70)
	closeButton.Text = "✕"
	closeButton.Font = Enum.Font.GothamBold
	closeButton.TextSize = 16
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.ZIndex = 55
	closeButton.Parent = titleBar
	components.CloseButton = closeButton

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 20)
	closeCorner.Parent = closeButton

	local closeGradient = Instance.new("UIGradient")
	closeGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(240, 80, 80)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 60, 60))
	}
	closeGradient.Rotation = 90
	closeGradient.Parent = closeButton
	
	local closeStroke = Instance.new("UIStroke")
	closeStroke.Color = Color3.fromRGB(255, 100, 100)
	closeStroke.Thickness = 1
	closeStroke.Transparency = 0.5
	closeStroke.Parent = closeButton

	-- Content Area
	local contentFrame = Instance.new("Frame")
	contentFrame.Name = "ContentFrame"
	contentFrame.Size = UDim2.new(1, -40, 1, -100)
	contentFrame.Position = UDim2.new(0, 20, 0, 80)
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
	upgradeFrame.BackgroundColor3 = Color3.fromHex("#121620")
	upgradeFrame.BackgroundTransparency = 0.5
	upgradeFrame.BorderSizePixel = 0
	upgradeFrame.ZIndex = 53
	upgradeFrame.Parent = parent

	local frameCorner = Instance.new("UICorner")
	frameCorner.CornerRadius = UDim.new(0, 12)
	frameCorner.Parent = upgradeFrame

	local frameStroke = Instance.new("UIStroke")
	frameStroke.Color = Color3.fromRGB(50, 55, 70)
	frameStroke.Thickness = 1
	frameStroke.Transparency = 0.7
	frameStroke.Parent = upgradeFrame

	local frameGradient = Instance.new("UIGradient")
	frameGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 30, 45)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(18, 22, 32)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 15, 22))
	}
	frameGradient.Rotation = 135
	frameGradient.Parent = upgradeFrame

	-- Icon
	local icon = Instance.new("TextLabel")
	icon.Name = "Icon"
	icon.Size = UDim2.new(0, 60, 0, 60)
	icon.Position = UDim2.new(0, 15, 0, 15)
	icon.Text = upgrade.Icon
	icon.Font = Enum.Font.GothamBold
	icon.TextSize = 32
	icon.TextColor3 = Color3.fromRGB(255, 255, 255)
	icon.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
	icon.ZIndex = 54
	icon.Parent = upgradeFrame

	local iconCorner = Instance.new("UICorner")
	iconCorner.CornerRadius = UDim.new(0, 12)
	iconCorner.Parent = icon

	local iconGradient = Instance.new("UIGradient")
	iconGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 45, 75)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 40, 55))
	}
	iconGradient.Rotation = 90
	iconGradient.Parent = icon

	local iconStroke = Instance.new("UIStroke")
	iconStroke.Color = Color3.fromRGB(120, 80, 255)
	iconStroke.Thickness = 1
	iconStroke.Transparency = 0.5
	iconStroke.Parent = icon

	-- Name and Description
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.Size = UDim2.new(0, 300, 0, 25)
	nameLabel.Position = UDim2.new(0, 90, 0, 15)
	nameLabel.Text = upgrade.Name
	nameLabel.Font = Enum.Font.GothamBold
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
	upgradeButton.Font = Enum.Font.GothamBold
	upgradeButton.TextSize = 14
	upgradeButton.ZIndex = 54
	upgradeButton.Parent = upgradeFrame

	-- Apply playful button style
	ButtonStyles.ApplyStyle(upgradeButton, "Success", {
		cornerRadius = 12,
		strokeThickness = 1,
		strokeTransparency = 0.5
	})

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
		ButtonStyles.UpdateStyle(components.UpgradeButton, "Disabled")
		components.UpgradeButton.Active = false
	else
		components.UpgradeButton.Text = "Upgrade\n" .. NumberFormatter.FormatCurrency(upgradeData.cost or 0)
		ButtonStyles.UpdateStyle(components.UpgradeButton, "Success")
		components.UpgradeButton.Active = true
	end
	
	-- Always show Infinite Storage button for InventorySlots upgrade
	if upgradeId == "InventorySlots" then
		if not components.InfiniteStorageButton then
			local infiniteButton = Instance.new("TextButton")
			infiniteButton.Name = "InfiniteStorageButton"
			infiniteButton.Size = UDim2.new(0, 40, 0, 40)
			infiniteButton.Position = UDim2.new(1, -205, 0, 40)
			infiniteButton.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
			infiniteButton.Text = "+"
			infiniteButton.Font = Enum.Font.GothamBold
			infiniteButton.TextSize = 18
			infiniteButton.TextColor3 = Color3.fromRGB(255, 255, 255)
			infiniteButton.ZIndex = 54
			infiniteButton.Parent = components.Frame
			components.InfiniteStorageButton = infiniteButton

			local infiniteCorner = Instance.new("UICorner")
			infiniteCorner.CornerRadius = UDim.new(0, 20)
			infiniteCorner.Parent = infiniteButton

			local infiniteStroke = Instance.new("UIStroke")
			infiniteStroke.Color = Color3.fromRGB(150, 255, 150)
			infiniteStroke.Thickness = 1
			infiniteStroke.Transparency = 0.3
			infiniteStroke.Parent = infiniteButton

			local infiniteGradient = Instance.new("UIGradient")
			infiniteGradient.Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 220, 120)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 200, 100))
			}
			infiniteGradient.Rotation = 90
			infiniteGradient.Parent = infiniteButton

			-- Hover effects
			infiniteButton.MouseEnter:Connect(function()
				infiniteButton.BackgroundColor3 = Color3.fromRGB(120, 220, 120)
				infiniteStroke.Color = Color3.fromRGB(200, 255, 200)
				infiniteStroke.Transparency = 0.1
			end)
			infiniteButton.MouseLeave:Connect(function()
				infiniteButton.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
				infiniteStroke.Color = Color3.fromRGB(150, 255, 150)
				infiniteStroke.Transparency = 0.3
			end)
		else
			-- Make sure the button is visible
			components.InfiniteStorageButton.Visible = true
		end
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