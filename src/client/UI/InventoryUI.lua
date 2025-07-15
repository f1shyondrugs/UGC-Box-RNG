-- InventoryUI.lua
-- Modern immersive inventory UI with character focus and 3D item previews

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Shared = ReplicatedStorage.Shared
local GameConfig = require(Shared.Modules.GameConfig)

local InventoryUI = {}

local ItemValueCalculator = require(game.ReplicatedStorage.Shared.Modules.ItemValueCalculator)
local NumberFormatter = require(game.ReplicatedStorage.Shared.Modules.NumberFormatter)

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

function InventoryUI.Create(parentGui)
	local components = {}
	
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "InventoryGui"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = parentGui
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	components.ScreenGui = screenGui

	-- Add a UIScale to manage UI scaling across different resolutions
	local uiScale = Instance.new("UIScale")
	uiScale.Scale = calculateUIScale()
	uiScale.Parent = screenGui
	components.UIScale = uiScale

	-- Note: Toggle button is now managed by NavigationController

	-- Full Screen Inventory Frame (initially hidden)
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "InventoryMainFrame"
	mainFrame.Size = UDim2.new(1, 0, 1, 0)
	mainFrame.Position = UDim2.new(0, 0, 0, 0)
	mainFrame.BackgroundTransparency = 1 -- Make background transparent
	mainFrame.BorderSizePixel = 0
	mainFrame.Visible = false
	mainFrame.ZIndex = 50
	mainFrame.Parent = screenGui
	components.MainFrame = mainFrame

	-- Character Viewport (Center/Background)
	local characterViewport = Instance.new("ViewportFrame")
	characterViewport.Name = "CharacterViewport"
	characterViewport.Size = UDim2.new(0.5, -20, 0.9, 0)
	characterViewport.Position = UDim2.new(0.5, 0, 0.05, 0)
	characterViewport.AnchorPoint = Vector2.new(0.5, 0)
	characterViewport.BackgroundColor3 = Color3.fromRGB(20, 22, 25)
	characterViewport.BorderSizePixel = 0
	characterViewport.Visible = true
	characterViewport.ZIndex = 51
	characterViewport.Parent = mainFrame
	characterViewport.BackgroundTransparency = 1
	components.CharacterViewport = characterViewport

	local viewportCorner = Instance.new("UICorner")
	viewportCorner.CornerRadius = UDim.new(0, 12)
	viewportCorner.Parent = characterViewport

	-- Left Panel - Item Information
	local leftPanel = Instance.new("Frame")
	leftPanel.Name = "LeftPanel"
	leftPanel.Size = UDim2.new(0.25, -15, 0.9, 0)
	leftPanel.Position = UDim2.new(0, 10, 0.05, 0)
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

	-- Right Panel - Item List with 3D Previews
	local rightPanel = Instance.new("Frame")
	rightPanel.Name = "RightPanel"
	rightPanel.Size = UDim2.new(0.25, -15, 0.9, 0)
	rightPanel.Position = UDim2.new(1, -10, 0.05, 0)
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
	local detailTitle = Instance.new("TextLabel")
	detailTitle.Name = "DetailTitle"
	detailTitle.Size = UDim2.new(1, -20, 0, 35)
	detailTitle.Position = UDim2.new(0, 10, 0, 8)
	detailTitle.Text = "ITEM DETAILS"
	detailTitle.Font = Enum.Font.GothamBold
	detailTitle.TextSize = 18
	detailTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	detailTitle.BackgroundTransparency = 1
	detailTitle.TextXAlignment = Enum.TextXAlignment.Left
	detailTitle.ZIndex = 53
	detailTitle.Parent = leftPanel
	components.DetailTitle = detailTitle

	-- Add title shadow
	local detailTitleShadow = Instance.new("TextLabel")
	detailTitleShadow.Name = "DetailTitleShadow"
	detailTitleShadow.Size = detailTitle.Size
	detailTitleShadow.Position = UDim2.new(0, 12, 0, 10)
	detailTitleShadow.Text = detailTitle.Text
	detailTitleShadow.Font = detailTitle.Font
	detailTitleShadow.TextSize = detailTitle.TextSize
	detailTitleShadow.TextColor3 = Color3.fromRGB(0, 0, 0)
	detailTitleShadow.TextTransparency = 0.8
	detailTitleShadow.BackgroundTransparency = 1
	detailTitleShadow.TextXAlignment = Enum.TextXAlignment.Left
	detailTitleShadow.ZIndex = 52
	detailTitleShadow.Parent = leftPanel

	-- Item preview viewport (3D model)
	local itemViewport = Instance.new("ViewportFrame")
	itemViewport.Name = "ItemViewport"
	itemViewport.Size = UDim2.new(1, -20, 0, 120)
	itemViewport.Position = UDim2.new(0, 10, 0, 50)
	itemViewport.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
	itemViewport.BorderSizePixel = 0
	itemViewport.ZIndex = 53
	itemViewport.Parent = leftPanel
	itemViewport.BackgroundTransparency = 1
	components.ItemViewport = itemViewport

	local itemViewportCorner = Instance.new("UICorner")
	itemViewportCorner.CornerRadius = UDim.new(0, 8)
	itemViewportCorner.Parent = itemViewport

	-- Details scroll frame
	local detailsScroll = Instance.new("ScrollingFrame")
	detailsScroll.Name = "DetailsScroll"
	detailsScroll.Size = UDim2.new(1, -20, 1, -350) -- More compact
	detailsScroll.Position = UDim2.new(0, 10, 0, 180)
	detailsScroll.BackgroundTransparency = 1
	detailsScroll.BorderSizePixel = 0
	detailsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	detailsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	detailsScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
	detailsScroll.ScrollBarThickness = 4
	detailsScroll.ZIndex = 53
	detailsScroll.Parent = leftPanel

	local detailsLayout = Instance.new("UIListLayout")
	detailsLayout.Padding = UDim.new(0, 6)
	detailsLayout.Parent = detailsScroll

	local function createDetailLabel(name, text, textSize)
		local label = Instance.new("TextLabel")
		label.Name = name
		label.Size = UDim2.new(1, 0, 0, textSize and (textSize + 8) or 25)
		label.Font = Enum.Font.SourceSans
		label.TextSize = textSize or 15
		label.TextColor3 = Color3.fromRGB(220, 221, 222)
		label.Text = text
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.BackgroundTransparency = 1
		label.TextWrapped = true
		label.ZIndex = 53
		label.Parent = detailsScroll
		return label
	end
	
	-- Create detail labels (reordered)
	components.DetailItemDescription = createDetailLabel("ItemDescription", "", 14)
	components.DetailItemDescription.Size = UDim2.new(1, 0, 0, 60)
	components.DetailItemDescription.LayoutOrder = 1
	
	components.DetailItemType = createDetailLabel("ItemType", "")
	components.DetailItemType.LayoutOrder = 2
	
	components.DetailItemRarity = createDetailLabel("ItemRarity", "")
	components.DetailItemRarity.LayoutOrder = 3
	
	components.DetailItemMutation = createDetailLabel("ItemMutation", "")
	components.DetailItemMutation.LayoutOrder = 4
	
	components.DetailItemSize = createDetailLabel("ItemSize", "")
	components.DetailItemSize.LayoutOrder = 5
	
	components.DetailItemValue = createDetailLabel("ItemValue", "")
	components.DetailItemValue.LayoutOrder = 6

	-- RAP Display (moved out of scroll)
	local rapLabel = Instance.new("TextLabel")
	rapLabel.Name = "RAPLabel"
	rapLabel.Size = UDim2.new(1, -20, 0, 22)
	rapLabel.Position = UDim2.new(0, 10, 1, -160)
	rapLabel.Font = Enum.Font.SourceSansBold
	rapLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
	rapLabel.TextSize = 16
	rapLabel.Text = "Total RAP: R$0"
	rapLabel.TextXAlignment = Enum.TextXAlignment.Left
	rapLabel.BackgroundTransparency = 1
	rapLabel.ZIndex = 53
	rapLabel.Parent = leftPanel
	components.RAPLabel = rapLabel

	-- Action buttons container
	local buttonContainer = Instance.new("Frame")
	buttonContainer.Name = "ButtonContainer"
	buttonContainer.Size = UDim2.new(1, -20, 0, 130)
	buttonContainer.Position = UDim2.new(0, 10, 1, -135)
	buttonContainer.BackgroundTransparency = 1
	buttonContainer.ZIndex = 53
	buttonContainer.Parent = leftPanel
	
	local buttonLayout = Instance.new("UIListLayout")
	buttonLayout.Padding = UDim.new(0, 5)
	buttonLayout.Parent = buttonContainer

	local function createActionButton(name, text, color, layoutOrder)
		local button = Instance.new("TextButton")
		button.Name = name
		button.Size = UDim2.new(1, 0, 0, 25)
		button.BackgroundColor3 = color
		button.Text = text
		button.Font = Enum.Font.SourceSansBold
		button.TextSize = 13
		button.TextColor3 = Color3.fromRGB(255, 255, 255)
		button.LayoutOrder = layoutOrder or 0
		button.Visible = false
		button.ZIndex = 53
		button.Parent = buttonContainer
		
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 5)
		corner.Parent = button
		
		return button
	end

	-- Create action buttons
	local equipStateContainer = Instance.new("Frame")
	equipStateContainer.Name = "EquipStateContainer"
	equipStateContainer.Size = UDim2.new(1, 0, 0, 25)
	equipStateContainer.BackgroundTransparency = 1
	equipStateContainer.LayoutOrder = 1
	equipStateContainer.Parent = buttonContainer

	components.EquipButton = createActionButton("EquipButton", "Equip", Color3.fromRGB(76, 175, 80))
	components.EquipButton.Parent = equipStateContainer
	components.UnequipButton = createActionButton("UnequipButton", "Unequip", Color3.fromRGB(255, 152, 0))
	components.UnequipButton.Parent = equipStateContainer
	
	components.SellButton = createActionButton("SellButton", "Sell for R$0", Color3.fromRGB(220, 76, 76), 3)
	components.LockButton = createActionButton("LockButton", "Lock", Color3.fromRGB(88, 101, 242), 4)
	-- components.SellAllButton = createActionButton("SellAllButton", "Sell All", Color3.fromRGB(100, 100, 100), 5)
	components.SellUnlockedButton = createActionButton("SellUnlockedButton", "Sell All (Unlocked)", Color3.fromRGB(160, 60, 60), 6)

	-- RIGHT PANEL CONTENT
	
	-- Header container for title, search, and sorting
	local headerContainer = Instance.new("Frame")
	headerContainer.Name = "HeaderContainer"
	headerContainer.Size = UDim2.new(1, -20, 0, 120)
	headerContainer.Position = UDim2.new(0, 10, 0, 8)
	headerContainer.BackgroundTransparency = 1
	headerContainer.ZIndex = 53
	headerContainer.Parent = rightPanel
	
	-- Title for right panel
	local inventoryTitle = Instance.new("TextLabel")
	inventoryTitle.Name = "InventoryTitle"
	inventoryTitle.Size = UDim2.new(1, -40, 0, 35) -- Make room for the + button
	inventoryTitle.Position = UDim2.new(0, 0, 0, 0)
	inventoryTitle.Text = "INVENTORY"
	inventoryTitle.Font = Enum.Font.SourceSansBold
	inventoryTitle.TextSize = 22
	inventoryTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	inventoryTitle.BackgroundTransparency = 1
	inventoryTitle.TextXAlignment = Enum.TextXAlignment.Left
	inventoryTitle.ZIndex = 53
	inventoryTitle.Parent = headerContainer
	components.InventoryTitle = inventoryTitle
	
	-- Infinite Storage button (+ symbol)
	local infiniteStorageButton = Instance.new("TextButton")
	infiniteStorageButton.Name = "InfiniteStorageButton"
	infiniteStorageButton.Size = UDim2.new(0, 30, 0, 30)
	infiniteStorageButton.Position = UDim2.new(1, -35, 0, 2)
	infiniteStorageButton.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
	infiniteStorageButton.Text = "+"
	infiniteStorageButton.Font = Enum.Font.GothamBold
	infiniteStorageButton.TextSize = 18
	infiniteStorageButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	infiniteStorageButton.ZIndex = 54
	infiniteStorageButton.Parent = headerContainer
	components.InfiniteStorageButton = infiniteStorageButton

	local infiniteCorner = Instance.new("UICorner")
	infiniteCorner.CornerRadius = UDim.new(0, 15)
	infiniteCorner.Parent = infiniteStorageButton

	local infiniteStroke = Instance.new("UIStroke")
	infiniteStroke.Color = Color3.fromRGB(150, 255, 150)
	infiniteStroke.Thickness = 1
	infiniteStroke.Transparency = 0.3
	infiniteStroke.Parent = infiniteStorageButton

	-- Hover effects for infinite storage button
	infiniteStorageButton.MouseEnter:Connect(function()
		infiniteStorageButton.BackgroundColor3 = Color3.fromRGB(120, 220, 120)
		infiniteStroke.Color = Color3.fromRGB(200, 255, 200)
		infiniteStroke.Transparency = 0.1
	end)
	infiniteStorageButton.MouseLeave:Connect(function()
		infiniteStorageButton.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
		infiniteStroke.Color = Color3.fromRGB(150, 255, 150)
		infiniteStroke.Transparency = 0.3
	end)

	-- Search container
	local searchContainer = Instance.new("Frame")
	searchContainer.Name = "SearchContainer"
	searchContainer.Size = UDim2.new(1, 0, 0, 35)
	searchContainer.Position = UDim2.new(0, 0, 0, 40)
	searchContainer.BackgroundColor3 = Color3.fromRGB(35, 40, 50)
	searchContainer.BorderSizePixel = 0
	searchContainer.ZIndex = 53
	searchContainer.Parent = headerContainer
	
	local searchCorner = Instance.new("UICorner")
	searchCorner.CornerRadius = UDim.new(0, 8)
	searchCorner.Parent = searchContainer
	
	local searchStroke = Instance.new("UIStroke")
	searchStroke.Color = Color3.fromRGB(80, 90, 110)
	searchStroke.Thickness = 1
	searchStroke.Transparency = 0.5
	searchStroke.Parent = searchContainer

	-- Search icon
	local searchIcon = Instance.new("TextLabel")
	searchIcon.Name = "SearchIcon"
	searchIcon.Size = UDim2.new(0, 30, 1, 0)
	searchIcon.Position = UDim2.new(0, 5, 0, 0)
	searchIcon.Text = "🔍"
	searchIcon.Font = Enum.Font.SourceSans
	searchIcon.TextSize = 16
	searchIcon.TextColor3 = Color3.fromRGB(150, 150, 150)
	searchIcon.BackgroundTransparency = 1
	searchIcon.ZIndex = 54
	searchIcon.Parent = searchContainer
	
	-- Search text box
	local searchBox = Instance.new("TextBox")
	searchBox.Name = "SearchBox"
	searchBox.Size = UDim2.new(1, -70, 1, -6)
	searchBox.Position = UDim2.new(0, 35, 0, 3)
	searchBox.PlaceholderText = "Search items..."
	searchBox.Text = ""
	searchBox.Font = Enum.Font.SourceSans
	searchBox.TextSize = 14
	searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	searchBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
	searchBox.BackgroundTransparency = 1
	searchBox.BorderSizePixel = 0
	searchBox.TextXAlignment = Enum.TextXAlignment.Left
	searchBox.ClearTextOnFocus = false
	searchBox.ZIndex = 54
	searchBox.Parent = searchContainer
	components.SearchBox = searchBox
	
	-- Clear search button
	local clearButton = Instance.new("TextButton")
	clearButton.Name = "ClearButton"
	clearButton.Size = UDim2.new(0, 25, 0, 25)
	clearButton.Position = UDim2.new(1, -30, 0.5, -12.5)
	clearButton.Text = "×"
	clearButton.Font = Enum.Font.SourceSansBold
	clearButton.TextSize = 18
	clearButton.TextColor3 = Color3.fromRGB(180, 180, 180)
	clearButton.BackgroundTransparency = 1
	clearButton.Visible = false
	clearButton.ZIndex = 54
	clearButton.Parent = searchContainer
	components.ClearButton = clearButton

	-- Sorting container
	local sortContainer = Instance.new("Frame")
	sortContainer.Name = "SortContainer"
	sortContainer.Size = UDim2.new(1, 0, 0, 35)
	sortContainer.Position = UDim2.new(0, 0, 0, 80)
	sortContainer.BackgroundTransparency = 1
	sortContainer.ZIndex = 53
	sortContainer.Parent = headerContainer
	
	-- Sort by dropdown
	local sortByFrame = Instance.new("Frame")
	sortByFrame.Name = "SortByFrame"
	sortByFrame.Size = UDim2.new(0.5, -5, 1, 0)
	sortByFrame.Position = UDim2.new(0, 0, 0, 0)
	sortByFrame.BackgroundColor3 = Color3.fromRGB(35, 40, 50)
	sortByFrame.BorderSizePixel = 0
	sortByFrame.ZIndex = 54
	sortByFrame.Parent = sortContainer
	
	local sortByCorner = Instance.new("UICorner")
	sortByCorner.CornerRadius = UDim.new(0, 6)
	sortByCorner.Parent = sortByFrame
	
	local sortByStroke = Instance.new("UIStroke")
	sortByStroke.Color = Color3.fromRGB(80, 90, 110)
	sortByStroke.Thickness = 1
	sortByStroke.Transparency = 0.5
	sortByStroke.Parent = sortByFrame
	
	local sortByButton = Instance.new("TextButton")
	sortByButton.Name = "SortByButton"
	sortByButton.Size = UDim2.new(1, -6, 1, -6)
	sortByButton.Position = UDim2.new(0, 3, 0, 3)
	sortByButton.Text = "Sort: Value ▼"
	sortByButton.Font = Enum.Font.SourceSans
	sortByButton.TextSize = 12
	sortByButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	sortByButton.BackgroundTransparency = 1
	sortByButton.TextXAlignment = Enum.TextXAlignment.Left
	sortByButton.ZIndex = 55
	sortByButton.Parent = sortByFrame
	components.SortByButton = sortByButton
	
	-- Sort order toggle
	local sortOrderFrame = Instance.new("Frame")
	sortOrderFrame.Name = "SortOrderFrame"
	sortOrderFrame.Size = UDim2.new(0.5, -5, 1, 0)
	sortOrderFrame.Position = UDim2.new(0.5, 5, 0, 0)
	sortOrderFrame.BackgroundColor3 = Color3.fromRGB(35, 40, 50)
	sortOrderFrame.BorderSizePixel = 0
	sortOrderFrame.ZIndex = 54
	sortOrderFrame.Parent = sortContainer
	
	local sortOrderCorner = Instance.new("UICorner")
	sortOrderCorner.CornerRadius = UDim.new(0, 6)
	sortOrderCorner.Parent = sortOrderFrame
	
	local sortOrderStroke = Instance.new("UIStroke")
	sortOrderStroke.Color = Color3.fromRGB(80, 90, 110)
	sortOrderStroke.Thickness = 1
	sortOrderStroke.Transparency = 0.5
	sortOrderStroke.Parent = sortOrderFrame
	
	local sortOrderButton = Instance.new("TextButton")
	sortOrderButton.Name = "SortOrderButton"
	sortOrderButton.Size = UDim2.new(1, -6, 1, -6)
	sortOrderButton.Position = UDim2.new(0, 3, 0, 3)
	sortOrderButton.Text = "High to Low ↓"
	sortOrderButton.Font = Enum.Font.SourceSans
	sortOrderButton.TextSize = 12
	sortOrderButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	sortOrderButton.BackgroundTransparency = 1
	sortOrderButton.TextXAlignment = Enum.TextXAlignment.Center
	sortOrderButton.ZIndex = 55
	sortOrderButton.Parent = sortOrderFrame
	components.SortOrderButton = sortOrderButton

	-- Item list scroll frame
	local listPanel = Instance.new("ScrollingFrame")
	listPanel.Name = "ListPanel"
	listPanel.Size = UDim2.new(1, -20, 1, -140)
	listPanel.Position = UDim2.new(0, 10, 0, 135)
	listPanel.BackgroundTransparency = 1
	listPanel.BorderSizePixel = 0
	listPanel.CanvasSize = UDim2.new(0, 0, 0, 0)
	listPanel.AutomaticCanvasSize = Enum.AutomaticSize.Y
	listPanel.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
	listPanel.ScrollBarThickness = 4
	listPanel.ZIndex = 53
	listPanel.Parent = rightPanel
	components.ListPanel = listPanel

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 6)
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = listPanel
	components.ListLayout = listLayout

	-- Parent the main GUI to the provided parent
	screenGui.Parent = parentGui
	
	-- Update scale when screen size changes
	local function updateScale()
		uiScale.Scale = calculateUIScale()
	end
	
	-- Connect to viewport size changes
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
	components.UpdateScale = updateScale

	return components
end

-- Create modern item template with 3D preview
function InventoryUI.CreateItemTemplate(itemInstance, itemName, itemConfig, rarityConfig, mutationConfigs)
	local template = Instance.new("TextButton")
	template.Name = itemInstance.Name
	template.Size = UDim2.new(1, 0, 0, 75) -- More compact
	template.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
	template.BorderSizePixel = 0
	template.Text = ""
	template.ZIndex = 54
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 15)
	corner.Parent = template
	
	-- Premium card gradient with enhanced colors
	local gradient = Instance.new("UIGradient")
	local rarityColors = {
		Common = {Color3.fromRGB(70, 80, 95), Color3.fromRGB(40, 50, 65), Color3.fromRGB(25, 30, 40)},
		Uncommon = {Color3.fromRGB(85, 140, 85), Color3.fromRGB(60, 110, 60), Color3.fromRGB(35, 80, 35)},
		Rare = {Color3.fromRGB(110, 110, 200), Color3.fromRGB(80, 80, 170), Color3.fromRGB(50, 50, 130)},
		Epic = {Color3.fromRGB(180, 110, 200), Color3.fromRGB(140, 80, 160), Color3.fromRGB(100, 50, 120)},
		Legendary = {Color3.fromRGB(255, 190, 110), Color3.fromRGB(220, 150, 70), Color3.fromRGB(180, 110, 30)},
		Mythical = {Color3.fromRGB(255, 120, 120), Color3.fromRGB(220, 80, 80), Color3.fromRGB(180, 40, 40)},
		Godly = {Color3.fromRGB(255, 230, 120), Color3.fromRGB(220, 190, 80), Color3.fromRGB(180, 150, 40)}
	}
	
	local colors = rarityColors[itemConfig.Rarity] or rarityColors.Common
	gradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0.0, colors[1]),
		ColorSequenceKeypoint.new(0.4, colors[2]),
		ColorSequenceKeypoint.new(0.8, colors[3]),
		ColorSequenceKeypoint.new(1.0, Color3.fromRGB(15, 20, 25))
	}
	gradient.Rotation = 160 -- Steeper diagonal for more dramatic effect
	gradient.Parent = template
	
	-- Enhanced rim lighting with glow effect
	local rimStroke = Instance.new("UIStroke")
	rimStroke.Color = rarityConfig and rarityConfig.Color or Color3.fromRGB(120, 120, 120)
	rimStroke.Thickness = 2
	rimStroke.Transparency = 0.5
	rimStroke.Parent = template
	
	-- Add shadow effect
	local shadow = Instance.new("Frame")
	shadow.Name = "Shadow"
	shadow.Size = UDim2.new(1, 6, 1, 6)
	shadow.Position = UDim2.new(0, 3, 0, 3)
	shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	shadow.BackgroundTransparency = 0.8
	shadow.BorderSizePixel = 0
	shadow.ZIndex = 53
	shadow.Parent = template
	
	local shadowCorner = Instance.new("UICorner")
	shadowCorner.CornerRadius = UDim.new(0, 15)
	shadowCorner.Parent = shadow

	-- 3D Item Preview (left side)
	local itemViewport = Instance.new("ViewportFrame")
	itemViewport.Name = "ItemViewport3D"
	itemViewport.Size = UDim2.new(0, 70, 0, 70)
	itemViewport.Position = UDim2.new(0, 10, 0.5, -35)
	itemViewport.BackgroundColor3 = Color3.fromRGB(15, 20, 30)
	itemViewport.BorderSizePixel = 0
	itemViewport.ZIndex = 55
	itemViewport.BackgroundTransparency = 1
	itemViewport.Parent = template

	local viewportCorner = Instance.new("UICorner")
	viewportCorner.CornerRadius = UDim.new(0, 10)
	viewportCorner.Parent = itemViewport
	
	-- Enhanced glow to viewport
	local viewportStroke = Instance.new("UIStroke")
	viewportStroke.Color = rarityConfig and rarityConfig.Color or Color3.fromRGB(120, 120, 120)
	viewportStroke.Thickness = 1.5
	viewportStroke.Transparency = 0.6
	viewportStroke.Parent = itemViewport

	-- Item Info Container (right side)
	local infoContainer = Instance.new("Frame")
	infoContainer.Name = "InfoContainer"
	infoContainer.Size = UDim2.new(1, -105, 1, -20)
	infoContainer.Position = UDim2.new(0, 90, 0, 10)
	infoContainer.BackgroundTransparency = 1
	infoContainer.ZIndex = 55
	infoContainer.Parent = template

	local infoLayout = Instance.new("UIListLayout")
	infoLayout.Padding = UDim.new(0, 2)
	infoLayout.Parent = infoContainer

	-- Item Name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.Size = UDim2.new(1, 0, 0, 20)
	nameLabel.Font = Enum.Font.SourceSansBold
	nameLabel.TextColor3 = rarityConfig and rarityConfig.Color or Color3.fromRGB(255, 255, 255)
	
	-- Handle multiple mutations for display name and color
	local mutationNames = ItemValueCalculator.GetMutationNames(itemInstance)
	local hasRainbow = false
	local displayName = itemName
	
	if mutationConfigs and #mutationConfigs > 0 then
		nameLabel.TextColor3 = mutationConfigs[1].Color or nameLabel.TextColor3
		if #mutationNames > 0 then
			displayName = table.concat(mutationNames, " ") .. " " .. itemName
			-- Check for Rainbow mutation
			for _, mutationName in ipairs(mutationNames) do
				if mutationName == "Rainbow" then
					hasRainbow = true
					break
				end
			end
		end
	end
	
	-- Add lock icon in front of name if item is locked
	local isLocked = itemInstance:GetAttribute("Locked") or false
	if isLocked then
		nameLabel.Text = "🔒 " .. displayName
	else
		nameLabel.Text = displayName
	end
	nameLabel.TextSize = 14
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.BackgroundTransparency = 1
	nameLabel.ZIndex = 55
	nameLabel.Parent = infoContainer
	
	-- Start rainbow text animation if item has Rainbow mutation
	if hasRainbow then
		local rainbowThread = coroutine.create(function()
			while nameLabel.Parent do
				local hue = (tick() * 1.5) % 5 / 5 -- Slightly slower than floating text
				local rainbowColor = Color3.fromHSV(hue, 1, 1)
				nameLabel.TextColor3 = rainbowColor
				task.wait(0.1) -- Smooth rainbow animation
			end
		end)
		coroutine.resume(rainbowThread)
		
		-- Store the thread in the template for cleanup
		template:SetAttribute("RainbowThread", rainbowThread)
	end

	-- Item Type
	local typeLabel = Instance.new("TextLabel")
	typeLabel.Name = "TypeLabel"
	typeLabel.Size = UDim2.new(1, 0, 0, 16)
	typeLabel.Font = Enum.Font.SourceSans
	typeLabel.Text = itemConfig.Type or "UGC Item"
	typeLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	typeLabel.TextSize = 12
	typeLabel.TextXAlignment = Enum.TextXAlignment.Left
	typeLabel.BackgroundTransparency = 1
	typeLabel.ZIndex = 55
	typeLabel.Parent = infoContainer

	-- Value and Size
	local size = itemInstance:GetAttribute("Size") or 1
	local value = ItemValueCalculator.GetFormattedValue(itemConfig, mutationConfigs, size)
	
	local valueLabel = Instance.new("TextLabel")
	valueLabel.Name = "ValueLabel"
	valueLabel.Size = UDim2.new(1, 0, 0, 16)
	valueLabel.Font = Enum.Font.SourceSansBold
	valueLabel.Text = value .. " • Size: " .. NumberFormatter.FormatSize(size)
	valueLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
	valueLabel.TextSize = 12
	valueLabel.TextXAlignment = Enum.TextXAlignment.Left
	valueLabel.BackgroundTransparency = 1
	valueLabel.ZIndex = 55
	valueLabel.Parent = infoContainer

	-- Status Icons Container
	local iconsContainer = Instance.new("Frame")
	iconsContainer.Name = "IconsContainer"
	iconsContainer.Size = UDim2.new(0, 75, 0, 35)
	iconsContainer.Position = UDim2.new(1, -85, 0, 5)
	iconsContainer.BackgroundTransparency = 1
	iconsContainer.ZIndex = 55
	iconsContainer.Parent = template

	local iconsLayout = Instance.new("UIListLayout")
	iconsLayout.FillDirection = Enum.FillDirection.Horizontal
	iconsLayout.Padding = UDim.new(0, 6)
	iconsLayout.Parent = iconsContainer




	-- Selection highlight
	local selectionHighlight = Instance.new("Frame")
	selectionHighlight.Name = "SelectionHighlight"
	selectionHighlight.Size = UDim2.new(1, 4, 1, 4)
	selectionHighlight.Position = UDim2.new(0, -2, 0, -2)
	selectionHighlight.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
	selectionHighlight.BorderSizePixel = 0
	selectionHighlight.Visible = false
	selectionHighlight.ZIndex = 53
	selectionHighlight.Parent = template

	local highlightCorner = Instance.new("UICorner")
	highlightCorner.CornerRadius = UDim.new(0, 10)
	highlightCorner.Parent = selectionHighlight

	return template
end



return InventoryUI 