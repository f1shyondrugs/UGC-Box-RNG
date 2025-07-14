local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local NavigationUI = {}

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
	containerFrame.Size = UDim2.new(0, 130, 0, 190) -- Adjusted height for 2x3 grid (fits content exactly)
	containerFrame.Position = UDim2.new(0, 15, 0.5, -85) -- Adjusted center position for new height
	containerFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
	containerFrame.BackgroundTransparency = 0.02
	containerFrame.BorderSizePixel = 0
	containerFrame.ZIndex = 100
	containerFrame.Parent = screenGui
	components.ContainerFrame = containerFrame
	
	local containerCorner = Instance.new("UICorner")
	containerCorner.CornerRadius = UDim.new(0, 20)
	containerCorner.Parent = containerFrame

	local containerGradient = Instance.new("UIGradient")
	containerGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 24, 35)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(15, 18, 28)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 12, 18))
	}
	containerGradient.Rotation = 135
	containerGradient.Parent = containerFrame

	local containerStroke = Instance.new("UIStroke")
	containerStroke.Color = Color3.fromRGB(50, 55, 70)
	containerStroke.Thickness = 1
	containerStroke.Transparency = 0.7
	containerStroke.Parent = containerFrame
	
	-- Grid Layout (2 columns, 3 rows)
	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
	gridLayout.CellSize = UDim2.new(0, 50, 0, 50)
	gridLayout.FillDirection = Enum.FillDirection.Horizontal
	gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	gridLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	gridLayout.StartCorner = Enum.StartCorner.TopLeft
	gridLayout.FillDirectionMaxCells = 2  -- This forces 2 columns
	gridLayout.Parent = containerFrame
	
	-- Add padding to the container
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 10)
	padding.PaddingBottom = UDim.new(0, 0) -- Reduced bottom padding to remove extra margin
	padding.PaddingLeft = UDim.new(0, 10)
	padding.PaddingRight = UDim.new(0, 10)
	padding.Parent = containerFrame

	-- Store button references
	components.Buttons = {}

	-- Function to create a navigation button
	local function createNavButton(name, icon, color, layoutOrder)
		local button = Instance.new("TextButton")
		button.Name = name .. "Button"
		button.Size = UDim2.new(0, 50, 0, 50) -- This will be overridden by grid
		button.BackgroundColor3 = Color3.fromRGB(42, 47, 65) -- Solid attractive color
		button.BorderSizePixel = 0
		button.Text = icon or "?"
		button.Font = Enum.Font.GothamBold
		button.TextScaled = true
		button.TextColor3 = Color3.fromRGB(255, 255, 255)
		button.AutoButtonColor = false -- Prevent default button color changes
		button.ZIndex = 101
		button.LayoutOrder = layoutOrder
		button.Active = true -- Explicitly make the button active
		button.Parent = containerFrame
		print("Created navigation button: " .. name)
		
		local aspect = Instance.new("UIAspectRatioConstraint")
		aspect.AspectRatio = 1
		aspect.Parent = button
		
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 12)
		corner.Parent = button

		-- Enhanced stroke for visual appeal instead of gradient
		local buttonStroke = Instance.new("UIStroke")
		buttonStroke.Color = Color3.fromRGB(120, 80, 255)
		buttonStroke.Thickness = 2
		buttonStroke.Transparency = 0.3
		buttonStroke.Parent = button

		-- Hover effects
		button.MouseEnter:Connect(function()
			button.BackgroundColor3 = Color3.fromRGB(120, 80, 255)
			buttonStroke.Color = Color3.fromRGB(200, 160, 255)
			buttonStroke.Transparency = 0.1
		end)
		
		button.MouseLeave:Connect(function()
			button.BackgroundColor3 = Color3.fromRGB(42, 47, 65)
			buttonStroke.Color = Color3.fromRGB(120, 80, 255)
			buttonStroke.Transparency = 0.3
		end)
		
		return button
	end

	-- Create navigation buttons (2x3 grid)
	-- Row 1: Inventory, Upgrade 
	components.Buttons.Inventory = createNavButton("Inventory", "📦", nil, 1)
	components.Buttons.Upgrade = createNavButton("Upgrade", "⚡", nil, 2)
	
	-- Row 2: Settings, Auto-Open 
	components.Buttons.Settings = createNavButton("Settings", "⚙️", nil, 3)
	components.Buttons.AutoOpen = createNavButton("AutoOpen", "🤖", nil, 4)

	-- Row 3: Shop, Rebirth
	components.Buttons.Shop = createNavButton("Shop", "🛒", nil, 5)
	components.Buttons.Rebirth = createNavButton("Rebirth", "🌟", nil, 6)

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