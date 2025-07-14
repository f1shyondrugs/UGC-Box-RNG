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
	title.Text = "⚙️ SETTINGS"
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
	settingFrame.BackgroundColor3 = Color3.fromHex("#121620")
	settingFrame.BackgroundTransparency = 0.5
	settingFrame.BorderSizePixel = 0
	settingFrame.ZIndex = 53
	settingFrame.Parent = parent

	local frameCorner = Instance.new("UICorner")
	frameCorner.CornerRadius = UDim.new(0, 12)
	frameCorner.Parent = settingFrame

	local frameStroke = Instance.new("UIStroke")
	frameStroke.Color = Color3.fromRGB(50, 55, 70)
	frameStroke.Thickness = 1
	frameStroke.Transparency = 0.7
	frameStroke.Parent = settingFrame

	local frameGradient = Instance.new("UIGradient")
	frameGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 30, 45)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(18, 22, 32)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 15, 22))
	}
	frameGradient.Rotation = 135
	frameGradient.Parent = settingFrame

	-- Icon
	local icon = Instance.new("TextLabel")
	icon.Name = "Icon"
	icon.Size = UDim2.new(0, 60, 0, 60)
	icon.Position = UDim2.new(0, 15, 0, 15)
	icon.Text = setting.Icon
	icon.Font = Enum.Font.GothamBold
	icon.TextSize = 32
	icon.TextColor3 = Color3.fromRGB(255, 255, 255)
	icon.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
	icon.ZIndex = 54
	icon.Parent = settingFrame

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
	nameLabel.Text = setting.Name
	nameLabel.Font = Enum.Font.GothamBold
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
		sliderTrack.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
		sliderTrack.BorderSizePixel = 0
		sliderTrack.ZIndex = 54
		sliderTrack.Parent = sliderContainer

		local trackCorner = Instance.new("UICorner")
		trackCorner.CornerRadius = UDim.new(0, 3)
		trackCorner.Parent = sliderTrack

		local trackGradient = Instance.new("UIGradient")
		trackGradient.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 55, 70)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 35, 50))
		}
		trackGradient.Rotation = 90
		trackGradient.Parent = sliderTrack

		-- Slider knob
		local sliderKnob = Instance.new("TextButton")
		sliderKnob.Name = "SliderKnob"
		sliderKnob.Size = UDim2.new(0, 20, 0, 20)
		sliderKnob.Position = UDim2.new(0, 10, 0.5, -10)
		sliderKnob.BackgroundColor3 = Color3.fromRGB(120, 80, 255)
		sliderKnob.BorderSizePixel = 0
		sliderKnob.Text = ""
		sliderKnob.ZIndex = 55
		sliderKnob.Parent = sliderContainer

		local knobCorner = Instance.new("UICorner")
		knobCorner.CornerRadius = UDim.new(1, 0)
		knobCorner.Parent = sliderKnob

		local knobGradient = Instance.new("UIGradient")
		knobGradient.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 100, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 80, 255))
		}
		knobGradient.Rotation = 90
		knobGradient.Parent = sliderKnob

		local knobStroke = Instance.new("UIStroke")
		knobStroke.Color = Color3.fromRGB(200, 160, 255)
		knobStroke.Thickness = 1
		knobStroke.Transparency = 0.3
		knobStroke.Parent = sliderKnob

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
		-- Toggle Switch for boolean settings (slider style)
		local toggle = Instance.new("TextButton")
		toggle.Name = "Toggle"
		toggle.Size = UDim2.new(0, 50, 0, 25)
		toggle.Position = UDim2.new(1, -65, 0, 40)
		toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		toggle.Text = ""
		toggle.ZIndex = 54
		toggle.Parent = settingFrame

		local toggleCorner = Instance.new("UICorner")
		toggleCorner.CornerRadius = UDim.new(0, 12)
		toggleCorner.Parent = toggle

		local indicator = Instance.new("Frame")
		indicator.Name = "Indicator"
		indicator.Size = UDim2.new(0, 21, 0, 21)
		indicator.Position = UDim2.new(0, 2, 0, 2)
		indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		indicator.ZIndex = 55
		indicator.Parent = toggle

		local indicatorCorner = Instance.new("UICorner")
		indicatorCorner.CornerRadius = UDim.new(0, 10)
		indicatorCorner.Parent = indicator

		components.Toggle = toggle
		components.Indicator = indicator
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
		-- Update slider toggle display
		local isEnabled = value
		local statusText = "Status: " .. (isEnabled and "ENABLED" or "DISABLED")
		components.StatusLabel.Text = statusText
		components.StatusLabel.TextColor3 = isEnabled and Color3.fromRGB(150, 255, 150) or Color3.fromRGB(255, 150, 150)

		if components.Toggle and components.Indicator then
			local TweenService = game:GetService("TweenService")
			local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			components.Toggle.BackgroundColor3 = isEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(60, 60, 60)
			local targetPos = isEnabled and UDim2.new(1, -23, 0, 2) or UDim2.new(0, 2, 0, 2)
			TweenService:Create(components.Indicator, tweenInfo, {Position = targetPos}):Play()
		end
	end
end

return SettingsUI 