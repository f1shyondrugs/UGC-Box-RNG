local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local NavigationUI = {}

local ButtonStyles = require(script.Parent.ButtonStyles)

-- Calculate UI scale based on screen size
local function calculateUIScale()
	local viewport = workspace.CurrentCamera.ViewportSize
	local baseResolution = 1080
	local scale = math.min(viewport.Y / baseResolution, 1.2) -- Cap at 1.2x for very high resolutions
	return math.max(scale, 0.7) -- Minimum scale of 0.7 for very small screens
end

function NavigationUI.Create(parentGui)
	local components = {}
	
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "NavigationGui"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = parentGui
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	components.ScreenGui = screenGui

	-- Add a UIScale to manage UI scaling across different resolutions
	local uiScale = Instance.new("UIScale")
	uiScale.Scale = calculateUIScale()
	uiScale.Parent = screenGui
	components.UIScale = uiScale

	-- Main Container Frame (draggable)
	local containerFrame = Instance.new("Frame")
	containerFrame.Name = "NavigationContainer"
	containerFrame.Size = UDim2.new(0, 220, 0, 300) -- Bigger container
	containerFrame.Position = UDim2.new(0, 15, 0.5, -150)
	containerFrame.BackgroundColor3 = Color3.fromRGB(40, 50, 80)
	containerFrame.BackgroundTransparency = 0.22 -- More transparent
	containerFrame.BorderSizePixel = 0
	containerFrame.ZIndex = 100
	containerFrame.Parent = screenGui
	components.ContainerFrame = containerFrame
	
	local containerCorner = Instance.new("UICorner")
	containerCorner.CornerRadius = UDim.new(0, 25) -- Slightly larger corner radius
	containerCorner.Parent = containerFrame

	local containerGradient = Instance.new("UIGradient")
	containerGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 40, 55)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(30, 35, 45)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 35))
	}
	containerGradient.Rotation = 135
	containerGradient.Parent = containerFrame

	local containerStroke = Instance.new("UIStroke")
	containerStroke.Color = Color3.fromRGB(70, 80, 100) -- Brighter stroke
	containerStroke.Thickness = 2 -- Thicker stroke
	containerStroke.Transparency = 0.3 -- Less transparent
	containerStroke.Parent = containerFrame
	
	-- Grid Layout (2 columns, 3 rows) - Bigger buttons
	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellPadding = UDim2.new(0, 14, 0, 14)
	gridLayout.CellSize = UDim2.new(0, 85, 0, 85)
	gridLayout.FillDirection = Enum.FillDirection.Horizontal
	gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	gridLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	gridLayout.StartCorner = Enum.StartCorner.TopLeft
	gridLayout.FillDirectionMaxCells = 2
	gridLayout.Parent = containerFrame
	
	-- Add padding to the container
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 18)
	padding.PaddingBottom = UDim.new(0, 18)
	padding.PaddingLeft = UDim.new(0, 15)
	padding.PaddingRight = UDim.new(0, 15)
	padding.Parent = containerFrame

	-- Store button references
	components.Buttons = {}

	-- Function to create a navigation button
	local function createNavButton(name, icon, color, layoutOrder)
		local button = Instance.new("TextButton")
		button.Name = name .. "Button"
		button.Text = "_____"
		button.Size = UDim2.new(0, 85, 0, 85)
		button.BorderSizePixel = 0
		button.BackgroundTransparency = 0
		button.AutoButtonColor = false
		button.ZIndex = 101
		button.LayoutOrder = layoutOrder
		button.Active = true
		button.Parent = containerFrame

		local aspect = Instance.new("UIAspectRatioConstraint")
		aspect.AspectRatio = 1
		aspect.Parent = button

		ButtonStyles.ApplyStyle(button, "Navigation", {
			cornerRadius = 18,
			strokeThickness = 3,
			strokeTransparency = 0.18
		})

		-- Icon (emoji) label
		local iconLabel = Instance.new("TextLabel")
		iconLabel.Name = "IconLabel"
		iconLabel.Size = UDim2.new(1, 0, 0.55, 0)
		iconLabel.Position = UDim2.new(0, 0, 0, 0)
		iconLabel.BackgroundTransparency = 1
		iconLabel.Text = icon or "?"
		iconLabel.Font = Enum.Font.GothamBold
		iconLabel.TextSize = 40
		iconLabel.TextColor3 = Color3.fromRGB(255,255,255)
		iconLabel.TextStrokeTransparency = 0.8
		iconLabel.TextXAlignment = Enum.TextXAlignment.Center
		iconLabel.TextYAlignment = Enum.TextYAlignment.Center
		iconLabel.ZIndex = 102
		iconLabel.Parent = button

		-- Text label below icon
		local textLabel = Instance.new("TextLabel")
		textLabel.Name = "NavTextLabel"
		textLabel.Size = UDim2.new(1, 0, 0.45, 0)
		textLabel.Position = UDim2.new(0, 0, 0.55, 0)
		textLabel.BackgroundTransparency = 1
		textLabel.Text = (icon == "🤖" and "Auto" or name)
		textLabel.Font = Enum.Font.GothamSemibold
		textLabel.TextSize = 18
		textLabel.TextColor3 = Color3.fromRGB(255,255,255)
		textLabel.TextStrokeTransparency = 0.8
		textLabel.TextXAlignment = Enum.TextXAlignment.Center
		textLabel.TextYAlignment = Enum.TextYAlignment.Center
		textLabel.ZIndex = 102
		textLabel.Parent = button

		return button
	end

	-- Create navigation buttons (2x3 grid) - Reordered for better UX
	-- Row 1: Main gameplay features (Inventory, Shop)
	components.Buttons.Inventory = createNavButton("Inventory", "📦", nil, 1)
	components.Buttons.Shop = createNavButton("Shop", "🛒", nil, 2)
	
	-- Row 2: Progression features (Upgrade, Rebirth)
	components.Buttons.Upgrade = createNavButton("Upgrade", "⚡", nil, 3)
	components.Buttons.Rebirth = createNavButton("Rebirth", "🌟", nil, 4)

	-- Row 3: Automation & Settings (Auto-Open, Settings)
	components.Buttons.AutoOpen = createNavButton("AutoOpen", "🤖", nil, 5)
	components.Buttons.Settings = createNavButton("Settings", "⚙️", nil, 6)

	-- Update scale when screen size changes
	local function updateScale()
		uiScale.Scale = calculateUIScale()
	end
	
	-- Connect to viewport size changes
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
	components.UpdateScale = updateScale

	return components
end

function NavigationUI.ConnectButton(navigationUI, buttonName, callback)
	local button = navigationUI.Buttons[buttonName]
	if button then
		print("Connecting click for: " .. buttonName)
		button.MouseButton1Click:Connect(function(...)
			print("Button clicked: " .. buttonName)
			callback(...)
		end)
	end
end

function NavigationUI.SetButtonIcon(navigationUI, buttonName, icon)
	local button = navigationUI.Buttons[buttonName]
	if button then
		button.Text = icon
	end
end

function NavigationUI.AddNotification(navigationUI, buttonName, visible)
	local button = navigationUI.Buttons[buttonName]
	if not button then return end
	
	local existing = button:FindFirstChild("NotificationIcon")
	if existing then
		existing.Visible = visible
		return
	end
	
	if visible then
		local notificationIcon = Instance.new("TextLabel")
		notificationIcon.Name = "NotificationIcon"
		notificationIcon.Size = UDim2.new(0, 20, 0, 20)
		notificationIcon.Position = UDim2.new(1, -5, 0, -5)
		notificationIcon.AnchorPoint = Vector2.new(1, 0)
		notificationIcon.Text = "!"
		notificationIcon.Font = Enum.Font.SourceSansBold
		notificationIcon.TextScaled = true
		notificationIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
		notificationIcon.BackgroundColor3 = Color3.fromRGB(237, 66, 69)
		notificationIcon.ZIndex = 102
		notificationIcon.Parent = button
		
		local notificationCorner = Instance.new("UICorner")
		notificationCorner.CornerRadius = UDim.new(1, 0)
		notificationCorner.Parent = notificationIcon
	end
end

return NavigationUI 