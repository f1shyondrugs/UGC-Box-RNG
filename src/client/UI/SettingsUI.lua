-- SettingsUI.lua
-- Settings management interface matching Collection GUI style

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Shared = ReplicatedStorage.Shared
local SettingsConfig = require(Shared.Modules.SettingsConfig)

local SettingsUI = {}

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

function SettingsUI.Create(parentGui)
	local components = {}
	
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "SettingsGui"
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
	mainFrame.Name = "SettingsMainFrame"
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
	title.Text = "⚙️ SETTINGS"
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

	-- Scrolling Frame for settings
	local scrollingFrame = Instance.new("ScrollingFrame")
	scrollingFrame.Name = "SettingsScrollingFrame"
	scrollingFrame.Size = UDim2.new(1, 0, 1, 0)
	scrollingFrame.Position = UDim2.new(0, 0, 0, 0)
	scrollingFrame.BackgroundTransparency = 1
	scrollingFrame.BorderSizePixel = 0
	scrollingFrame.ScrollBarThickness = 8
	scrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
	scrollingFrame.ZIndex = 52
	scrollingFrame.Parent = contentFrame
	components.ScrollingFrame = scrollingFrame

	-- Layout for setting items
	local settingsLayout = Instance.new("UIListLayout")
	settingsLayout.SortOrder = Enum.SortOrder.LayoutOrder
	settingsLayout.Padding = UDim.new(0, 15)
	settingsLayout.Parent = scrollingFrame

	-- Store setting frames for updates
	components.SettingFrames = {}

	return components
end

-- Create an individual setting frame
function SettingsUI.CreateSettingFrame(parent, settingId, value)
	local setting = SettingsConfig.GetSetting(settingId)
	if not setting then return nil end
	
	local isSlider = setting.Type == "Slider"

	local settingFrame = Instance.new("Frame")
	settingFrame.Name = settingId .. "Frame"
	settingFrame.Size = UDim2.new(1, 0, 0, 120)
	settingFrame.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
	settingFrame.BorderSizePixel = 0
	settingFrame.ZIndex = 53
	settingFrame.Parent = parent

	local frameCorner = Instance.new("UICorner")
	frameCorner.CornerRadius = UDim.new(0, 12)
	frameCorner.Parent = settingFrame

	local frameGradient = Instance.new("UIGradient")
	frameGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 40, 55)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 30, 40))
	}
	frameGradient.Rotation = 90
	frameGradient.Parent = settingFrame

	-- Icon
	local icon = Instance.new("TextLabel")
	icon.Name = "Icon"
	icon.Size = UDim2.new(0, 60, 0, 60)
	icon.Position = UDim2.new(0, 15, 0, 15)
	icon.Text = setting.Icon
	icon.Font = Enum.Font.SourceSansBold
	icon.TextSize = 32
	icon.TextColor3 = Color3.fromRGB(255, 255, 255)
	icon.BackgroundColor3 = Color3.fromRGB(40, 45, 60)
	icon.ZIndex = 54
	icon.Parent = settingFrame

	local iconCorner = Instance.new("UICorner")
	iconCorner.CornerRadius = UDim.new(0, 8)
	iconCorner.Parent = icon

	-- Name and Description
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.Size = UDim2.new(0, 300, 0, 25)
	nameLabel.Position = UDim2.new(0, 90, 0, 15)
	nameLabel.Text = setting.Name
	nameLabel.Font = Enum.Font.SourceSansBold
	nameLabel.TextSize = 18
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.BackgroundTransparency = 1
	nameLabel.ZIndex = 54
	nameLabel.Parent = settingFrame

	local descLabel = Instance.new("TextLabel")
	descLabel.Name = "DescLabel"
	descLabel.Size = UDim2.new(0, 300, 0, 20)
	descLabel.Position = UDim2.new(0, 90, 0, 40)
	descLabel.Text = setting.Description
	descLabel.Font = Enum.Font.SourceSans
	descLabel.TextSize = 14
	descLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.BackgroundTransparency = 1
	descLabel.ZIndex = 54
	descLabel.Parent = settingFrame

	-- Category Label
	local categoryLabel = Instance.new("TextLabel")
	categoryLabel.Name = "CategoryLabel"
	categoryLabel.Size = UDim2.new(0, 150, 0, 20)
	categoryLabel.Position = UDim2.new(0, 90, 0, 65)
	categoryLabel.Text = "Category: " .. setting.Category
	categoryLabel.Font = Enum.Font.SourceSansBold
	categoryLabel.TextSize = 14
	categoryLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
	categoryLabel.TextXAlignment = Enum.TextXAlignment.Left
	categoryLabel.BackgroundTransparency = 1
	categoryLabel.ZIndex = 54
	categoryLabel.Parent = settingFrame

	-- Status Label
	local statusLabel = Instance.new("TextLabel")
	statusLabel.Name = "StatusLabel"
	statusLabel.Size = UDim2.new(0, 200, 0, 20)
	statusLabel.Position = UDim2.new(0, 90, 0, 85)
	statusLabel.Font = Enum.Font.SourceSans
	statusLabel.TextSize = 12
	statusLabel.TextXAlignment = Enum.TextXAlignment.Left
	statusLabel.BackgroundTransparency = 1
	statusLabel.ZIndex = 54
	statusLabel.Parent = settingFrame

	local components = {
		Frame = settingFrame,
		StatusLabel = statusLabel
	}

	if isSlider then
		-- Create slider components
		local sliderContainer = Instance.new("Frame")
		sliderContainer.Name = "SliderContainer"
		sliderContainer.Size = UDim2.new(0, 200, 0, 30)
		sliderContainer.Position = UDim2.new(1, -220, 0, 45)
		sliderContainer.BackgroundTransparency = 1
		sliderContainer.ZIndex = 54
		sliderContainer.Parent = settingFrame

		-- Slider track
		local sliderTrack = Instance.new("Frame")
		sliderTrack.Name = "SliderTrack"
		sliderTrack.Size = UDim2.new(1, -40, 0, 6)
		sliderTrack.Position = UDim2.new(0, 20, 0.5, -3)
		sliderTrack.BackgroundColor3 = Color3.fromRGB(60, 70, 85)
		sliderTrack.BorderSizePixel = 0
		sliderTrack.ZIndex = 54
		sliderTrack.Parent = sliderContainer

		local trackCorner = Instance.new("UICorner")
		trackCorner.CornerRadius = UDim.new(0, 3)
		trackCorner.Parent = sliderTrack

		-- Slider knob
		local sliderKnob = Instance.new("TextButton")
		sliderKnob.Name = "SliderKnob"
		sliderKnob.Size = UDim2.new(0, 20, 0, 20)
		sliderKnob.Position = UDim2.new(0, 10, 0.5, -10)
		sliderKnob.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
		sliderKnob.BorderSizePixel = 0
		sliderKnob.Text = ""
		sliderKnob.ZIndex = 55
		sliderKnob.Parent = sliderContainer

		local knobCorner = Instance.new("UICorner")
		knobCorner.CornerRadius = UDim.new(1, 0)
		knobCorner.Parent = sliderKnob

		-- Value label
		local valueLabel = Instance.new("TextLabel")
		valueLabel.Name = "ValueLabel"
		valueLabel.Size = UDim2.new(0, 40, 0, 20)
		valueLabel.Position = UDim2.new(1, -35, 0, 5)
		valueLabel.Font = Enum.Font.SourceSansBold
		valueLabel.TextSize = 12
		valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		valueLabel.TextXAlignment = Enum.TextXAlignment.Center
		valueLabel.BackgroundTransparency = 1
		valueLabel.ZIndex = 54
		valueLabel.Parent = sliderContainer

		components.SliderContainer = sliderContainer
		components.SliderTrack = sliderTrack
		components.SliderKnob = sliderKnob
		components.ValueLabel = valueLabel
	else
		-- Toggle Button for boolean settings
		local toggleButton = Instance.new("TextButton")
		toggleButton.Name = "ToggleButton"
		toggleButton.Size = UDim2.new(0, 120, 0, 40)
		toggleButton.Position = UDim2.new(1, -135, 0, 40)
		toggleButton.Font = Enum.Font.SourceSansBold
		toggleButton.TextSize = 14
		toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		toggleButton.ZIndex = 54
		toggleButton.Parent = settingFrame

		local buttonCorner = Instance.new("UICorner")
		buttonCorner.CornerRadius = UDim.new(0, 8)
		buttonCorner.Parent = toggleButton

		components.ToggleButton = toggleButton
	end

	-- Update display based on setting state
	SettingsUI.UpdateSettingFrame(components, settingId, value)

	return components
end

-- Update a setting frame with current state
function SettingsUI.UpdateSettingFrame(components, settingId, value)
	local setting = SettingsConfig.GetSetting(settingId)
	if not setting or not components then return end

	local isSlider = setting.Type == "Slider"

	if isSlider then
		-- Update slider display
		local normalizedValue = (value - setting.MinValue) / (setting.MaxValue - setting.MinValue)
		normalizedValue = math.clamp(normalizedValue, 0, 1)
		
		-- Update knob position
		local trackWidth = components.SliderTrack.AbsoluteSize.X
		local knobPosition = 20 + (trackWidth - 20) * normalizedValue
		components.SliderKnob.Position = UDim2.new(0, knobPosition - 10, 0.5, -10)
		
		-- Update value label
		components.ValueLabel.Text = string.format("%.1f", value)
		
		-- Update status
		components.StatusLabel.Text = string.format("Value: %.1f (%.0f%%)", value, normalizedValue * 100)
		components.StatusLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
	else
		-- Update toggle display
		local isEnabled = value
		local statusText = "Status: " .. (isEnabled and "ENABLED" or "DISABLED")
		components.StatusLabel.Text = statusText
		components.StatusLabel.TextColor3 = isEnabled and Color3.fromRGB(150, 255, 150) or Color3.fromRGB(255, 150, 150)

		-- Update button
		components.ToggleButton.Text = isEnabled and "DISABLE" or "ENABLE"
		components.ToggleButton.BackgroundColor3 = isEnabled and Color3.fromRGB(150, 50, 50) or Color3.fromRGB(50, 150, 50)
	end
end

return SettingsUI 