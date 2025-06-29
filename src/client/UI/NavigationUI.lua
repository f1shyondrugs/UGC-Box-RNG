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
	containerFrame.Size = UDim2.new(0, 130, 0, 130) -- 2 buttons wide x 2 buttons tall (50+10+50+20 each direction)
	containerFrame.Position = UDim2.new(0, 15, 0.5, -65) -- Centered vertically on left side
	containerFrame.BackgroundColor3 = Color3.fromRGB(20, 22, 25) -- Nice dark gray
	containerFrame.BackgroundTransparency = 0.3 -- Seethrough
	containerFrame.BorderSizePixel = 0
	containerFrame.ZIndex = 100
	containerFrame.Parent = screenGui
	components.ContainerFrame = containerFrame
	
	local containerCorner = Instance.new("UICorner")
	containerCorner.CornerRadius = UDim.new(0, 12)
	containerCorner.Parent = containerFrame
	
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
	padding.PaddingBottom = UDim.new(0, 10)
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
		button.BackgroundColor3 = color or Color3.fromRGB(41, 43, 48)
		button.BorderSizePixel = 0
		button.Text = icon or "?"
		button.Font = Enum.Font.SourceSansBold
		button.TextScaled = true
		button.TextColor3 = Color3.fromRGB(255, 255, 255)
		button.ZIndex = 101
		button.LayoutOrder = layoutOrder
		button.Parent = containerFrame
		
		local aspect = Instance.new("UIAspectRatioConstraint")
		aspect.AspectRatio = 1
		aspect.Parent = button
		
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 8)
		corner.Parent = button
		
		return button
	end

	-- Create navigation buttons (2x2 grid)
	-- Row 1: Inventory, Collection 
	components.Buttons.Inventory = createNavButton("Inventory", "📦", Color3.fromRGB(41, 43, 48), 1)
	components.Buttons.Collection = createNavButton("Collection", "📚", Color3.fromRGB(60, 88, 50), 2)
	
	-- Row 2: Upgrade, Settings  
	components.Buttons.Upgrade = createNavButton("Upgrade", "⚡", Color3.fromRGB(88, 61, 33), 3)
	components.Buttons.Settings = createNavButton("Settings", "⚙️", Color3.fromRGB(70, 70, 70), 4)

	-- Make container draggable
	local dragging = false
	local dragStart = nil
	local startPos = nil
	
	containerFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = containerFrame.Position
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			containerFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

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
		button.MouseButton1Click:Connect(callback)
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