-- InventoryUI.lua
-- This module is responsible for creating and styling the UGC inventory UI components.
-- It returns a dictionary of all the created UI elements for the controller to manage.

local InventoryUI = {}

function InventoryUI.Create(parent)
	local components = {}

	-- Main ScreenGui
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "InventoryGui"
	screenGui.ResetOnSpawn = false
	components.ScreenGui = screenGui

	-- Toggle Button
	local toggleButton = Instance.new("TextButton")
	toggleButton.Name = "InventoryToggleButton"
	toggleButton.Size = UDim2.new(0.08, 0, 0.08, 0) -- Use scale
	toggleButton.Position = UDim2.new(0.02, 0, 0.5, 0) -- Use scale
	toggleButton.AnchorPoint = Vector2.new(0, 0.5)
	toggleButton.BackgroundColor3 = Color3.fromRGB(41, 43, 48)
	toggleButton.BorderColor3 = Color3.fromRGB(50, 52, 58)
	toggleButton.Text = "📦"
	toggleButton.Font = Enum.Font.SourceSansBold
	toggleButton.TextScaled = true
	toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	toggleButton.Parent = screenGui
	components.ToggleButton = toggleButton
	
	local toggleAspect = Instance.new("UIAspectRatioConstraint")
	toggleAspect.AspectRatio = 1
	toggleAspect.Parent = toggleButton
	
	local toggleCorner = Instance.new("UICorner")
	toggleCorner.CornerRadius = UDim.new(0, 8)
	toggleCorner.Parent = toggleButton

	local warningIcon = Instance.new("TextLabel")
	warningIcon.Name = "WarningIcon"
	warningIcon.Size = UDim2.new(0.5, 0, 0.5, 0)
	warningIcon.AnchorPoint = Vector2.new(1, 0)
	warningIcon.Position = UDim2.new(1.1, 0, -0.1, 0)
	warningIcon.Text = "!"
	warningIcon.Font = Enum.Font.SourceSansBold
	warningIcon.TextScaled = true
	warningIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
	warningIcon.BackgroundColor3 = Color3.fromRGB(237, 66, 69) -- Bright Red
	warningIcon.Visible = false -- Hidden by default
	warningIcon.Parent = toggleButton
	components.WarningIcon = warningIcon
	
	local warningCorner = Instance.new("UICorner")
	warningCorner.CornerRadius = UDim.new(1, 0) -- Makes it a circle
	warningCorner.Parent = warningIcon

	-- Main Inventory Frame (initially hidden)
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "InventoryMainFrame"
	mainFrame.Size = UDim2.new(0.6, 0, 0.7, 0)
	mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	mainFrame.BackgroundColor3 = Color3.fromRGB(31, 33, 38)
	mainFrame.BorderColor3 = Color3.fromRGB(50, 52, 58)
	mainFrame.BorderSizePixel = 2
	mainFrame.Visible = false
	mainFrame.Parent = screenGui
	components.MainFrame = mainFrame

	local mainCorner = Instance.new("UICorner")
	mainCorner.CornerRadius = UDim.new(0, 12)
	mainCorner.Parent = mainFrame
	
	local mainPadding = Instance.new("UIPadding")
	mainPadding.PaddingTop = UDim.new(0, 10)
	mainPadding.PaddingBottom = UDim.new(0, 10)
	mainPadding.PaddingLeft = UDim.new(0, 10)
	mainPadding.PaddingRight = UDim.new(0, 10)
	mainPadding.Parent = mainFrame

	-- Title Bar
	local titleBar = Instance.new("Frame")
	titleBar.Name = "TitleBar"
	titleBar.Size = UDim2.new(1, 0, 0, 50) -- Made taller for RAP display
	titleBar.BackgroundColor3 = Color3.fromRGB(24, 25, 28)
	titleBar.Parent = mainFrame

	local titleCorner = Instance.new("UICorner")
	titleCorner.CornerRadius = UDim.new(0, 8)
	titleCorner.Parent = titleBar

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.Size = UDim2.new(0.6, 0, 0.6, 0)
	titleLabel.Text = "UGC Collection"
	titleLabel.Font = Enum.Font.SourceSansBold
	titleLabel.TextScaled = true
	titleLabel.TextColor3 = Color3.fromRGB(220, 221, 222)
	titleLabel.BackgroundColor3 = titleBar.BackgroundColor3
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Position = UDim2.new(0, 15, 0, 0)
	titleLabel.Parent = titleBar

	-- RAP Display
	local rapLabel = Instance.new("TextLabel")
	rapLabel.Name = "RAPLabel"
	rapLabel.Size = UDim2.new(0.6, 0, 0.4, 0)
	rapLabel.Position = UDim2.new(0, 15, 0.6, 0)
	rapLabel.Text = "Total RAP: R$0"
	rapLabel.Font = Enum.Font.SourceSans
	rapLabel.TextScaled = true
	rapLabel.TextColor3 = Color3.fromRGB(100, 255, 100) -- Green color for RAP
	rapLabel.BackgroundTransparency = 1
	rapLabel.TextXAlignment = Enum.TextXAlignment.Left
	rapLabel.Parent = titleBar
	components.RAPLabel = rapLabel

	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Size = UDim2.new(0.1, 0, 0.6, 0)
	closeButton.AnchorPoint = Vector2.new(1, 0.5)
	closeButton.Position = UDim2.new(1, -10, 0.5, 0)
	closeButton.Text = "X"
	closeButton.Font = Enum.Font.SourceSansBold
	closeButton.TextScaled = true
	closeButton.TextColor3 = Color3.fromRGB(220, 221, 222)
	closeButton.BackgroundTransparency = 1
	closeButton.Parent = titleBar
	components.CloseButton = closeButton

	local closeButtonAspect = Instance.new("UIAspectRatioConstraint")
	closeButtonAspect.AspectRatio = 1
	closeButtonAspect.Parent = closeButton

	-- Main Content Area
	local contentFrame = Instance.new("Frame")
	contentFrame.Name = "ContentFrame"
	contentFrame.Size = UDim2.new(1, 0, 1, -60) -- Adjusted for taller title bar
	contentFrame.Position = UDim2.new(0, 0, 0, 60)
	contentFrame.BackgroundTransparency = 1
	contentFrame.Parent = mainFrame
	
	-- Left Panel (Item Details)
	local detailsPanel = Instance.new("Frame")
	detailsPanel.Name = "DetailsPanel"
	detailsPanel.Size = UDim2.new(0.3, -5, 1, 0) -- 30% width, 5px gap
	detailsPanel.BackgroundColor3 = Color3.fromRGB(41, 43, 48)
	detailsPanel.BorderColor3 = Color3.fromRGB(50, 52, 58)
	detailsPanel.Parent = contentFrame
	components.DetailsPanel = detailsPanel

	local detailsCorner = Instance.new("UICorner")
	detailsCorner.CornerRadius = UDim.new(0, 8)
	detailsCorner.Parent = detailsPanel

	-- Create a frame for the action buttons at the bottom
	local buttonContainer = Instance.new("Frame")
	buttonContainer.Name = "ButtonContainer"
	buttonContainer.Size = UDim2.new(1, 0, 0, 140) -- Fixed height for 3 buttons
	buttonContainer.AnchorPoint = Vector2.new(0.5, 1)
	buttonContainer.Position = UDim2.new(0.5, 0, 1, -10)
	buttonContainer.BackgroundTransparency = 1
	buttonContainer.Parent = detailsPanel
	
	local buttonLayout = Instance.new("UIListLayout")
	buttonLayout.Padding = UDim.new(0, 5)
	buttonLayout.Parent = buttonContainer

	-- Create a scrolling frame for the details
	local detailsScroll = Instance.new("ScrollingFrame")
	detailsScroll.Name = "DetailsScroll"
	detailsScroll.Size = UDim2.new(1, 0, 1, -150) -- Fill space above buttons
	detailsScroll.BackgroundTransparency = 1
	detailsScroll.BorderSizePixel = 0
	detailsScroll.CanvasSize = UDim2.new(0,0,0,0)
	detailsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	detailsScroll.Parent = detailsPanel
	
	local detailsLayout = Instance.new("UIListLayout")
	detailsLayout.Padding = UDim.new(0, 10)
	detailsLayout.Parent = detailsScroll
	
	local detailsPadding = Instance.new("UIPadding")
	detailsPadding.PaddingTop = UDim.new(0, 10)
	detailsPadding.PaddingLeft = UDim.new(0, 10)
	detailsPadding.PaddingRight = UDim.new(0, 10)
	detailsPadding.Parent = detailsScroll

	local function createDetailLabel(name, text)
		local label = Instance.new("TextLabel")
		label.Name = name
		label.Size = UDim2.new(1, 0, 0, 25) -- Fixed height for labels in scroll
		label.Font = Enum.Font.SourceSans
		label.TextScaled = false -- Use fixed text size for scrolling content
		label.TextSize = 16
		label.TextColor3 = Color3.fromRGB(220, 221, 222)
		label.Text = text
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.BackgroundTransparency = 1
		label.TextWrapped = true
		label.Parent = detailsScroll -- Parent to the scrolling frame
		return label
	end
	
	components.DetailItemName = createDetailLabel("ItemName", "Select a UGC Item")
	components.DetailItemName.Font = Enum.Font.SourceSansBold
	components.DetailItemName.TextSize = 20
	components.DetailItemName.Size = UDim2.new(1, 0, 0, 30)
	
	components.DetailItemType = createDetailLabel("ItemType", "")
	components.DetailItemDescription = createDetailLabel("ItemDescription", "")
	components.DetailItemDescription.Size = UDim2.new(1, 0, 0, 60) -- Taller for descriptions
	components.DetailItemRarity = createDetailLabel("ItemRarity", "")
	components.DetailItemMutation = createDetailLabel("ItemMutation", "")
	components.DetailItemSize = createDetailLabel("ItemSize", "")
	components.DetailItemValue = createDetailLabel("ItemValue", "")
	components.InventoryCount = createDetailLabel("InventoryCount", "")
	components.InventoryCount.LayoutOrder = -1 -- Place it above the other details
	components.InventoryCount.Font = Enum.Font.SourceSansBold
	components.InventoryCount.TextSize = 18

	local sellButton = Instance.new("TextButton")
	sellButton.Name = "SellButton"
	sellButton.Size = UDim2.new(1, 0, 0, 40)
	sellButton.BackgroundColor3 = Color3.fromRGB(220, 76, 76)
	sellButton.Text = "Sell for R$0"
	sellButton.Font = Enum.Font.SourceSansBold
	sellButton.TextSize = 18
	sellButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	sellButton.Visible = false -- Hide until an item is selected
	sellButton.Parent = buttonContainer -- Parent to the button container
	components.SellButton = sellButton
	
	local sellCorner = Instance.new("UICorner")
	sellCorner.Parent = sellButton

	local lockButton = Instance.new("TextButton")
	lockButton.Name = "LockButton"
	lockButton.Size = UDim2.new(1, 0, 0, 40)
	lockButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
	lockButton.Text = "Lock" -- Default text
	lockButton.Font = Enum.Font.SourceSansBold
	lockButton.TextSize = 18
	lockButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	lockButton.LayoutOrder = 2 -- Place it after the sell buttons
	lockButton.Visible = false -- Hide until item is selected
	lockButton.Parent = buttonContainer -- Parent to the button container
	components.LockButton = lockButton
	
	local lockCorner = Instance.new("UICorner")
	lockCorner.Parent = lockButton

	local sellAllButton = Instance.new("TextButton")
	sellAllButton.Name = "SellAllButton"
	sellAllButton.Size = UDim2.new(1, 0, 0, 40)
	sellAllButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	sellAllButton.Text = "Sell All Unlocked"
	sellAllButton.Font = Enum.Font.SourceSansBold
	sellAllButton.TextSize = 18
	sellAllButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	sellAllButton.LayoutOrder = 1 -- Place it after the single sell button
	sellAllButton.Parent = buttonContainer -- Parent to the button container
	components.SellAllButton = sellAllButton

	local sellAllCorner = Instance.new("UICorner")
	sellAllCorner.Parent = sellAllButton

	-- Right Panel (Item List)
	local listPanel = Instance.new("ScrollingFrame")
	listPanel.Name = "ListPanel"
	listPanel.Size = UDim2.new(0.7, -5, 1, 0) -- 70% width, 5px gap
	listPanel.Position = UDim2.new(0.3, 5, 0, 0)
	listPanel.BackgroundColor3 = Color3.fromRGB(41, 43, 48)
	listPanel.BorderColor3 = Color3.fromRGB(50, 52, 58)
	listPanel.CanvasSize = UDim2.new(0,0,0,0)
	listPanel.AutomaticCanvasSize = Enum.AutomaticSize.Y
	listPanel.ScrollBarImageColor3 = Color3.fromRGB(88, 101, 242)
	listPanel.Parent = contentFrame
	components.ListPanel = listPanel

	local listCorner = Instance.new("UICorner")
	listCorner.CornerRadius = UDim.new(0, 8)
	listCorner.Parent = listPanel

	local listPadding = Instance.new("UIPadding")
	listPadding.PaddingTop = UDim.new(0, 10)
	listPadding.PaddingLeft = UDim.new(0, 10)
	listPadding.Parent = listPanel

	local listLayout = Instance.new("UIGridLayout")
	listLayout.CellPadding = UDim2.new(0, 8, 0, 8)
	listLayout.CellSize = UDim2.new(0, 100, 0, 140) -- Made taller for UGC info
	listLayout.SortOrder = Enum.SortOrder.Name
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.Parent = listPanel
	components.ListLayout = listLayout

	-- Parent the main GUI to the provided parent
	screenGui.Parent = parent

	return components
end

-- This function creates the template for a single UGC item in the inventory grid.
function InventoryUI.CreateItemTemplate(itemInstance, itemName, itemConfig, rarityConfig, mutationConfig)
	local template = Instance.new("TextButton")
	template.Name = itemInstance.Name
	template.Size = UDim2.new(0, 100, 0, 140)
	template.BackgroundColor3 = Color3.fromRGB(54, 57, 63)
	template.ClipsDescendants = true
	template.Text = ""
	
	local corner = Instance.new("UICorner")
	corner.Parent = template
	
	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 3)
	layout.Parent = template

	local lockIcon = Instance.new("TextLabel")
	lockIcon.Name = "LockIcon"
	lockIcon.Size = UDim2.new(0, 25, 0, 25)
	lockIcon.AnchorPoint = Vector2.new(0, 1)
	lockIcon.Position = UDim2.new(0, 5, 1, -5)
	lockIcon.Text = "🔒"
	lockIcon.Font = Enum.Font.SourceSans
	lockIcon.TextSize = 20
	lockIcon.BackgroundTransparency = 1
	lockIcon.Visible = false
	lockIcon.Parent = template

	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 25)
	header.BackgroundColor3 = rarityConfig and rarityConfig.Color or Color3.fromRGB(114, 118, 125)
	if mutationConfig then
		header.BackgroundColor3 = mutationConfig.Color
	end
	header.BorderSizePixel = 0
	header.Parent = template
	
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 1, 0)
	nameLabel.Font = Enum.Font.SourceSansBold
	nameLabel.Text = itemName
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextSize = 12
	nameLabel.TextWrapped = true
	nameLabel.BackgroundTransparency = 1
	nameLabel.Parent = header
	
	-- UGC Type Label
	local typeLabel = Instance.new("TextLabel")
	typeLabel.Size = UDim2.new(1, -10, 0, 18)
	typeLabel.Font = Enum.Font.SourceSans
	typeLabel.Text = itemConfig.Type or "UGC"
	typeLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	typeLabel.TextSize = 12
	typeLabel.BackgroundTransparency = 1
	typeLabel.Position = UDim2.new(0,5,0,0)
	typeLabel.Parent = template
	
	local size = itemInstance:GetAttribute("Size") or 1
	local sizeLabel = Instance.new("TextLabel")
	sizeLabel.Size = UDim2.new(1, -10, 0, 18)
	sizeLabel.Font = Enum.Font.SourceSans
	sizeLabel.Text = string.format("Size: %.2f", size)
	sizeLabel.TextColor3 = Color3.fromRGB(220, 221, 222)
	sizeLabel.TextSize = 12
	sizeLabel.BackgroundTransparency = 1
	sizeLabel.Position = UDim2.new(0,5,0,0)
	sizeLabel.Parent = template

	-- Value Label
	local ItemValueCalculator = require(game.ReplicatedStorage.Shared.Modules.ItemValueCalculator)
	local value = ItemValueCalculator.GetFormattedValue(itemConfig, mutationConfig, size)
	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(1, -10, 0, 18)
	valueLabel.Font = Enum.Font.SourceSansBold
	valueLabel.Text = value
	valueLabel.TextColor3 = Color3.fromRGB(100, 255, 100) -- Green for R$ value
	valueLabel.TextSize = 12
	valueLabel.BackgroundTransparency = 1
	valueLabel.Position = UDim2.new(0,5,0,0)
	valueLabel.Parent = template

	return template
end

return InventoryUI 