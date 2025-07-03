-- AutoOpenUI.lua
-- Auto-Open feature interface matching the InventoryUI style with slide-in animations

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Shared = game.ReplicatedStorage.Shared
local GameConfig = require(Shared.Modules.GameConfig)

local AutoOpenUI = {}

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

function AutoOpenUI.Create(parentGui)
	local components = {}
	
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "AutoOpenGui"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = parentGui
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	components.ScreenGui = screenGui

	local uiScale = Instance.new("UIScale")
	uiScale.Scale = calculateUIScale()
	uiScale.Parent = screenGui
	components.UIScale = uiScale

	-- Full Screen Main Frame (initially hidden)
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "AutoOpenMainFrame"
	mainFrame.Size = UDim2.new(1, 0, 1, 0)
	mainFrame.Position = UDim2.new(0, 0, 0, 0)
	mainFrame.BackgroundTransparency = 1 -- Make background transparent
	mainFrame.BorderSizePixel = 0
	mainFrame.Visible = false
	mainFrame.ZIndex = 50
	mainFrame.Parent = screenGui
	components.MainFrame = mainFrame

	-- Left Panel - Auto-Open Controls
	local leftPanel = Instance.new("Frame")
	leftPanel.Name = "LeftPanel"
	leftPanel.Size = UDim2.new(0.25, -15, 0.9, 0)
	leftPanel.Position = UDim2.new(-0.25, 0, 0.05, 0) -- Initially off-screen to the left
	leftPanel.BackgroundColor3 = Color3.fromHex("#121620")
	leftPanel.BackgroundTransparency = 0.5
	leftPanel.BorderSizePixel = 0
	leftPanel.ZIndex = 52
	leftPanel.Parent = mainFrame
	components.LeftPanel = leftPanel

	local leftCorner = Instance.new("UICorner")
	leftCorner.CornerRadius = UDim.new(0, 12)
	leftCorner.Parent = leftPanel

	local leftStroke = Instance.new("UIStroke")
	leftStroke.Color = Color3.fromRGB(50, 55, 70)
	leftStroke.Thickness = 1
	leftStroke.Transparency = 0.7
	leftStroke.Parent = leftPanel

	-- Left panel gradient
	local leftGradient = Instance.new("UIGradient")
	leftGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 30, 45)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(18, 22, 32)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 15, 22))
	}
	leftGradient.Rotation = 135
	leftGradient.Parent = leftPanel

	-- Right Panel - Auto-Open Settings
	local rightPanel = Instance.new("Frame")
	rightPanel.Name = "RightPanel"
	rightPanel.Size = UDim2.new(0.25, -15, 0.9, 0)
	rightPanel.Position = UDim2.new(1.25, 0, 0.05, 0) -- Initially off-screen to the right
	rightPanel.AnchorPoint = Vector2.new(1, 0)
	rightPanel.BackgroundColor3 = Color3.fromHex("#121620")
	rightPanel.BackgroundTransparency = 0.5
	rightPanel.BorderSizePixel = 0
	rightPanel.ZIndex = 52
	rightPanel.Parent = mainFrame
	components.RightPanel = rightPanel

	local rightCorner = Instance.new("UICorner")
	rightCorner.CornerRadius = UDim.new(0, 12)
	rightCorner.Parent = rightPanel

	local rightStroke = Instance.new("UIStroke")
	rightStroke.Color = Color3.fromRGB(50, 55, 70)
	rightStroke.Thickness = 1
	rightStroke.Transparency = 0.7
	rightStroke.Parent = rightPanel

	-- Right panel gradient
	local rightGradient = Instance.new("UIGradient")
	rightGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 30, 45)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(18, 22, 32)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 15, 22))
	}
	rightGradient.Rotation = 135
	rightGradient.Parent = rightPanel

	-- Close Button (Top Right)
	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Size = UDim2.new(0, 40, 0, 40)
	closeButton.Position = UDim2.new(1, -50, 0, 15)
	closeButton.BackgroundColor3 = Color3.fromRGB(220, 70, 70)
	closeButton.Text = "✕"
	closeButton.Font = Enum.Font.GothamBold
	closeButton.TextSize = 16
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.ZIndex = 55
	closeButton.Parent = mainFrame
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

	local closeAspect = Instance.new("UIAspectRatioConstraint")
	closeAspect.AspectRatio = 1
	closeAspect.Parent = closeButton

	-- LEFT PANEL CONTENT
	
	-- Title for left panel
	local controlTitle = Instance.new("TextLabel")
	controlTitle.Name = "ControlTitle"
	controlTitle.Size = UDim2.new(1, -20, 0, 35)
	controlTitle.Position = UDim2.new(0, 10, 0, 8)
	controlTitle.Text = "🤖 AUTO-OPEN CONTROLS"
	controlTitle.Font = Enum.Font.GothamBold
	controlTitle.TextSize = 18
	controlTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	controlTitle.BackgroundTransparency = 1
	controlTitle.TextXAlignment = Enum.TextXAlignment.Left
	controlTitle.ZIndex = 53
	controlTitle.Parent = leftPanel
	components.ControlTitle = controlTitle

	-- Enable/Disable Section
	local enableSection = AutoOpenUI.CreateToggleSection(leftPanel, "Enable Auto-Open", "Requires Auto-Open Gamepass (1290860985)", UDim2.new(0, 10, 0, 50))
	components.EnableToggle = enableSection.Toggle
	components.EnableSection = enableSection

	-- Count Section
	local countSection = AutoOpenUI.CreateNumberSection(leftPanel, "Crates to Open", "Number of crates to open until stop", 1, 100, 10, UDim2.new(0, 10, 0, 140), true)
	components.CountInput = countSection.Input
	components.CountSection = countSection

	-- Money Threshold Section
	local moneySection = AutoOpenUI.CreateNumberSection(leftPanel, "Stop Below R$", "Stop when money is below this amount", 0, 999999999, 1000, UDim2.new(0, 10, 0, 250), true)
	components.MoneyInput = moneySection.Input
	components.MoneySection = moneySection

	-- Crate Selection Button
	local crateSelectButton = Instance.new("TextButton")
	crateSelectButton.Name = "CrateSelectButton"
	crateSelectButton.Size = UDim2.new(1, -20, 0, 40)
	crateSelectButton.Position = UDim2.new(0, 10, 0, 360)
	crateSelectButton.BackgroundColor3 = Color3.fromRGB(42, 47, 65)
	crateSelectButton.Font = Enum.Font.GothamBold
	crateSelectButton.Text = "📦 Select Crate"
	crateSelectButton.TextSize = 18
	crateSelectButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	crateSelectButton.AutoButtonColor = false
	crateSelectButton.ZIndex = 204
	crateSelectButton.Parent = leftPanel
	components.CrateSelectButton = crateSelectButton

	local crateCorner = Instance.new("UICorner")
	crateCorner.CornerRadius = UDim.new(0, 12)
	crateCorner.Parent = crateSelectButton

	local crateStroke = Instance.new("UIStroke")
	crateStroke.Color = Color3.fromRGB(120, 80, 255)
	crateStroke.Thickness = 2
	crateStroke.Transparency = 0.3
	crateStroke.Parent = crateSelectButton

	crateSelectButton.MouseEnter:Connect(function()
		crateSelectButton.BackgroundColor3 = Color3.fromRGB(120, 80, 255)
		crateStroke.Color = Color3.fromRGB(200, 160, 255)
		crateStroke.Transparency = 0.1
	end)
	crateSelectButton.MouseLeave:Connect(function()
		crateSelectButton.BackgroundColor3 = Color3.fromRGB(42, 47, 65)
		crateStroke.Color = Color3.fromRGB(120, 80, 255)
		crateStroke.Transparency = 0.3
	end)

	-- RIGHT PANEL CONTENT
	
	-- Title for right panel
	local settingsTitle = Instance.new("TextLabel")
	settingsTitle.Name = "SettingsTitle"
	settingsTitle.Size = UDim2.new(1, -20, 0, 35)
	settingsTitle.Position = UDim2.new(0, 10, 0, 8)
	settingsTitle.Text = "⚙️ AUTO-SELL SETTINGS"
	settingsTitle.Font = Enum.Font.GothamBold
	settingsTitle.TextSize = 18
	settingsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	settingsTitle.BackgroundTransparency = 1
	settingsTitle.TextXAlignment = Enum.TextXAlignment.Left
	settingsTitle.ZIndex = 53
	settingsTitle.Parent = rightPanel
	components.SettingsTitle = settingsTitle

	-- Enable/Disable Auto-Sell Section
	local autoSellSection = AutoOpenUI.CreateToggleSection(rightPanel, "Enable Auto-Sell", "Requires Auto-Sell Gamepass (1296259225)", UDim2.new(0, 10, 0, 50))
	components.AutoSellToggle = autoSellSection.Toggle
	components.AutoSellSection = autoSellSection

	-- Size Threshold Section
	local sizeSection = AutoOpenUI.CreateNumberSection(rightPanel, "Auto-Sell Below Size", "Auto-sell items smaller than this size", 0, 10, 3, UDim2.new(0, 10, 0, 140))
	components.SizeInput = sizeSection.Input
	components.SizeSection = sizeSection

	-- Value Threshold Section  
	local valueSection = AutoOpenUI.CreateNumberSection(rightPanel, "Auto-Sell Below Value", "Auto-sell items worth less than this amount", 0, 999999999, 100, UDim2.new(0, 10, 0, 230))
	components.ValueInput = valueSection.Input
	components.ValueSection = valueSection

	-- Update canvas size for scrolling frames
	task.wait() -- Wait for layout to complete
	local function updateCanvasSize()
		for _, section in pairs({countSection, moneySection, sizeSection, valueSection}) do
			if section.Container and section.Container:IsA("ScrollingFrame") then
				local layout = section.Container:FindFirstChildOfClass("UIListLayout")
				if layout then
					section.Container.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
				end
			end
		end
	end
	updateCanvasSize()

	return components
end

function AutoOpenUI.CreateToggleSection(parent, title, subtitle, position)
	local section = Instance.new("Frame")
	section.Name = title .. "Section"
	section.Size = UDim2.new(1, -20, 0, 80)
	section.Position = position or UDim2.new(0, 10, 0, 0)
	section.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
	section.BorderSizePixel = 0
	section.ZIndex = 202
	section.Parent = parent

	local sectionCorner = Instance.new("UICorner")
	sectionCorner.CornerRadius = UDim.new(0, 8)
	sectionCorner.Parent = section

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(1, -60, 0, 25)
	titleLabel.Position = UDim2.new(0, 15, 0, 5)
	titleLabel.Text = title
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 16
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.BackgroundTransparency = 1
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.ZIndex = 203
	titleLabel.Parent = section

	local subtitleLabel = Instance.new("TextLabel")
	subtitleLabel.Name = "Subtitle"
	subtitleLabel.Size = UDim2.new(1, -60, 0, 15)
	subtitleLabel.Position = UDim2.new(0, 15, 0, 30)
	subtitleLabel.Text = subtitle
	subtitleLabel.Font = Enum.Font.Gotham
	subtitleLabel.TextSize = 12
	subtitleLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	subtitleLabel.BackgroundTransparency = 1
	subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	subtitleLabel.ZIndex = 203
	subtitleLabel.Parent = section

	-- Toggle Switch
	local toggle = Instance.new("TextButton")
	toggle.Name = "Toggle"
	toggle.Size = UDim2.new(0, 50, 0, 25)
	toggle.Position = UDim2.new(1, -65, 0, 15)
	toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	toggle.Text = ""
	toggle.ZIndex = 204
	toggle.Parent = section

	local toggleCorner = Instance.new("UICorner")
	toggleCorner.CornerRadius = UDim.new(0, 12)
	toggleCorner.Parent = toggle

	local indicator = Instance.new("Frame")
	indicator.Name = "Indicator"
	indicator.Size = UDim2.new(0, 21, 0, 21)
	indicator.Position = UDim2.new(0, 2, 0, 2)
	indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	indicator.Visible = false
	indicator.ZIndex = 205
	indicator.Parent = toggle

	local indicatorCorner = Instance.new("UICorner")
	indicatorCorner.CornerRadius = UDim.new(0, 10)
	indicatorCorner.Parent = indicator

	return {
		Section = section,
		Toggle = toggle,
		Indicator = indicator,
		Title = titleLabel,
		Subtitle = subtitleLabel
	}
end

function AutoOpenUI.CreateNumberSection(parent, title, subtitle, minValue, maxValue, defaultValue, position, hasInfiniteToggle)
	local section = Instance.new("Frame")
	section.Name = title .. "Section"
	section.Size = UDim2.new(1, -20, 0, hasInfiniteToggle and 100 or 80)
	section.Position = position or UDim2.new(0, 10, 0, 0)
	section.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
	section.BorderSizePixel = 0
	section.ZIndex = 202
	section.Parent = parent

	local sectionCorner = Instance.new("UICorner")
	sectionCorner.CornerRadius = UDim.new(0, 8)
	sectionCorner.Parent = section

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(1, -100, 0, 25)
	titleLabel.Position = UDim2.new(0, 15, 0, 5)
	titleLabel.Text = title
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 16
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.BackgroundTransparency = 1
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.ZIndex = 203
	titleLabel.Parent = section

	local subtitleLabel = Instance.new("TextLabel")
	subtitleLabel.Name = "Subtitle"
	subtitleLabel.Size = UDim2.new(1, -100, 0, 15)
	subtitleLabel.Position = UDim2.new(0, 15, 0, 30)
	subtitleLabel.Text = subtitle
	subtitleLabel.Font = Enum.Font.Gotham
	subtitleLabel.TextSize = 12
	subtitleLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	subtitleLabel.BackgroundTransparency = 1
	subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	subtitleLabel.ZIndex = 203
	subtitleLabel.Parent = section

	-- Input Container
	local inputContainer = Instance.new("Frame")
	inputContainer.Name = "InputContainer"
	inputContainer.Size = UDim2.new(0, 80, 0, 30)
	inputContainer.Position = UDim2.new(1, -90, 0, 25)
	inputContainer.BackgroundTransparency = 1
	inputContainer.ZIndex = 203
	inputContainer.Parent = section

	-- Decrease Button
	local decreaseButton = Instance.new("TextButton")
	decreaseButton.Name = "DecreaseButton"
	decreaseButton.Size = UDim2.new(0, 20, 0, 30)
	decreaseButton.Position = UDim2.new(0, 0, 0, 0)
	decreaseButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	decreaseButton.Text = "-"
	decreaseButton.Font = Enum.Font.GothamBold
	decreaseButton.TextSize = 16
	decreaseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	decreaseButton.ZIndex = 204
	decreaseButton.Parent = inputContainer

	local decreaseCorner = Instance.new("UICorner")
	decreaseCorner.CornerRadius = UDim.new(0, 4)
	decreaseCorner.Parent = decreaseButton

	-- Input Field
	local input = Instance.new("TextBox")
	input.Name = "Input"
	input.Size = UDim2.new(0, 40, 0, 30)
	input.Position = UDim2.new(0, 20, 0, 0)
	input.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	input.Text = tostring(defaultValue)
	input.Font = Enum.Font.Gotham
	input.TextSize = 14
	input.TextColor3 = Color3.fromRGB(255, 255, 255)
	input.ZIndex = 204
	input.Parent = inputContainer

	local inputCorner = Instance.new("UICorner")
	inputCorner.CornerRadius = UDim.new(0, 4)
	inputCorner.Parent = input

	-- Increase Button
	local increaseButton = Instance.new("TextButton")
	increaseButton.Name = "IncreaseButton"
	increaseButton.Size = UDim2.new(0, 20, 0, 30)
	increaseButton.Position = UDim2.new(0, 60, 0, 0)
	increaseButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	increaseButton.Text = "+"
	increaseButton.Font = Enum.Font.GothamBold
	increaseButton.TextSize = 16
	increaseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	increaseButton.ZIndex = 204
	increaseButton.Parent = inputContainer

	local increaseCorner = Instance.new("UICorner")
	increaseCorner.CornerRadius = UDim.new(0, 4)
	increaseCorner.Parent = increaseButton

	-- Infinite Toggle (if enabled)
	local infiniteToggle, infiniteIndicator, infiniteLabel
	if hasInfiniteToggle then
		-- Infinite Toggle Switch
		infiniteToggle = Instance.new("TextButton")
		infiniteToggle.Name = "InfiniteToggle"
		infiniteToggle.Size = UDim2.new(0, 40, 0, 20)
		infiniteToggle.Position = UDim2.new(0, 15, 0, 65)
		infiniteToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		infiniteToggle.Text = ""
		infiniteToggle.ZIndex = 204
		infiniteToggle.Parent = section

		local infiniteToggleCorner = Instance.new("UICorner")
		infiniteToggleCorner.CornerRadius = UDim.new(0, 10)
		infiniteToggleCorner.Parent = infiniteToggle

		infiniteIndicator = Instance.new("Frame")
		infiniteIndicator.Name = "InfiniteIndicator"
		infiniteIndicator.Size = UDim2.new(0, 16, 0, 16)
		infiniteIndicator.Position = UDim2.new(0, 2, 0, 2)
		infiniteIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		infiniteIndicator.Visible = false
		infiniteIndicator.ZIndex = 205
		infiniteIndicator.Parent = infiniteToggle

		local infiniteIndicatorCorner = Instance.new("UICorner")
		infiniteIndicatorCorner.CornerRadius = UDim.new(0, 8)
		infiniteIndicatorCorner.Parent = infiniteIndicator

		infiniteLabel = Instance.new("TextLabel")
		infiniteLabel.Name = "InfiniteLabel"
		infiniteLabel.Size = UDim2.new(1, -60, 0, 20)
		infiniteLabel.Position = UDim2.new(0, 60, 0, 65)
		infiniteLabel.Text = "Infinite"
		infiniteLabel.Font = Enum.Font.Gotham
		infiniteLabel.TextSize = 12
		infiniteLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
		infiniteLabel.BackgroundTransparency = 1
		infiniteLabel.TextXAlignment = Enum.TextXAlignment.Left
		infiniteLabel.ZIndex = 203
		infiniteLabel.Parent = section
	end

	-- Button functionality
	decreaseButton.MouseButton1Click:Connect(function()
		local current = tonumber(input.Text) or defaultValue
		local newValue = math.max(minValue, current - 1)
		input.Text = tostring(newValue)
	end)

	increaseButton.MouseButton1Click:Connect(function()
		local current = tonumber(input.Text) or defaultValue
		-- Remove maxValue constraint - allow infinite input
		local newValue = current + 1
		input.Text = tostring(newValue)
	end)

	-- Validate input
	input.FocusLost:Connect(function()
		local value = tonumber(input.Text)
		if not value then
			input.Text = tostring(defaultValue)
		else
			-- Only enforce minimum, no maximum
			input.Text = tostring(math.max(value, minValue))
		end
	end)

	-- Update input visibility based on infinite toggle
	local function updateInputVisibility()
		if hasInfiniteToggle and infiniteToggle then
			local isInfinite = infiniteIndicator.Visible
			inputContainer.Visible = not isInfinite
			if isInfinite then
				input.Text = "∞"
			end
		end
	end

	-- Infinite toggle functionality
	if hasInfiniteToggle and infiniteToggle then
		infiniteToggle.MouseButton1Click:Connect(function()
			local isInfinite = not infiniteIndicator.Visible
			infiniteIndicator.Visible = isInfinite
			infiniteToggle.BackgroundColor3 = isInfinite and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(60, 60, 60)
			
			-- Animate indicator
			local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			if isInfinite then
				TweenService:Create(infiniteIndicator, tweenInfo, {Position = UDim2.new(1, -18, 0, 2)}):Play()
			else
				TweenService:Create(infiniteIndicator, tweenInfo, {Position = UDim2.new(0, 2, 0, 2)}):Play()
			end
			
			updateInputVisibility()
		end)
		
		updateInputVisibility()
	end

	return {
		Section = section,
		Input = input,
		DecreaseButton = decreaseButton,
		IncreaseButton = increaseButton,
		InfiniteToggle = infiniteToggle,
		InfiniteIndicator = infiniteIndicator,
		InfiniteLabel = infiniteLabel,
		IsInfinite = function()
			return hasInfiniteToggle and infiniteToggle and infiniteIndicator.Visible
		end,
		SetInfinite = function(infinite)
			if hasInfiniteToggle and infiniteToggle then
				infiniteIndicator.Visible = infinite
				infiniteToggle.BackgroundColor3 = infinite and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(60, 60, 60)
				
				local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				if infinite then
					TweenService:Create(infiniteIndicator, tweenInfo, {Position = UDim2.new(1, -18, 0, 2)}):Play()
				else
					TweenService:Create(infiniteIndicator, tweenInfo, {Position = UDim2.new(0, 2, 0, 2)}):Play()
				end
				
				updateInputVisibility()
			end
		end
	}
end

function AutoOpenUI.ShowSettings(components)
	-- Animation constants
	local ANIMATION_TIME = 0.3
	local ANIMATION_STYLE = Enum.EasingStyle.Quint
	local ANIMATION_DIRECTION = Enum.EasingDirection.Out
	
	local tweenInfo = TweenInfo.new(ANIMATION_TIME, ANIMATION_STYLE, ANIMATION_DIRECTION)
	
	components.MainFrame.Visible = true
	
	-- Set initial positions off-screen
	components.LeftPanel.Position = UDim2.new(-0.25, 0, 0.05, 0)
	components.RightPanel.Position = UDim2.new(1.25, 0, 0.05, 0)
	
	-- Define target positions on-screen
	local leftPanelEndPos = UDim2.new(0, 10, 0.05, 0)
	local rightPanelEndPos = UDim2.new(1, -10, 0.05, 0)
	
	-- Create and play slide-in animations
	local leftTween = TweenService:Create(components.LeftPanel, tweenInfo, {Position = leftPanelEndPos})
	local rightTween = TweenService:Create(components.RightPanel, tweenInfo, {Position = rightPanelEndPos})
	
	leftTween:Play()
	rightTween:Play()
end

function AutoOpenUI.HideSettings(components)
	-- Animation constants
	local ANIMATION_TIME = 0.3
	local ANIMATION_STYLE = Enum.EasingStyle.Quint
	local ANIMATION_DIRECTION = Enum.EasingDirection.Out
	
	local tweenInfo = TweenInfo.new(ANIMATION_TIME, ANIMATION_STYLE, ANIMATION_DIRECTION)
	
	-- Define target positions off-screen
	local leftPanelEndPos = UDim2.new(-0.25, 0, 0.05, 0)
	local rightPanelEndPos = UDim2.new(1.25, 0, 0.05, 0)
	
	-- Create and play slide-out animations
	local leftTween = TweenService:Create(components.LeftPanel, tweenInfo, {Position = leftPanelEndPos})
	local rightTween = TweenService:Create(components.RightPanel, tweenInfo, {Position = rightPanelEndPos})

	leftTween:Play()
	rightTween:Play()
	
	-- Hide the main frame after animation completes
	task.delay(ANIMATION_TIME, function()
		components.MainFrame.Visible = false
	end)
end

function AutoOpenUI.UpdateToggleState(toggle, indicator, enabled)
	local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	
	indicator.Visible = enabled
	toggle.BackgroundColor3 = enabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(60, 60, 60)
	
	if enabled then
		-- Slide indicator to the right
		TweenService:Create(indicator, tweenInfo, {Position = UDim2.new(1, -23, 0, 2)}):Play()
	else
		-- Slide indicator to the left
		TweenService:Create(indicator, tweenInfo, {Position = UDim2.new(0, 2, 0, 2)}):Play()
	end
end

return AutoOpenUI 