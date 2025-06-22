-- InventoryUI.lua
-- Modern immersive inventory UI with character focus and 3D item previews

local InventoryUI = {}

function InventoryUI.Create(parent)
	local components = {}

	-- Main ScreenGui
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "InventoryGui"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	components.ScreenGui = screenGui

	-- Toggle Button (compact design)
	local toggleButton = Instance.new("TextButton")
	toggleButton.Name = "InventoryToggleButton"
	toggleButton.Size = UDim2.new(0.06, 0, 0.06, 0)
	toggleButton.Position = UDim2.new(0.02, 0, 0.5, 0)
	toggleButton.AnchorPoint = Vector2.new(0, 0.5)
	toggleButton.BackgroundColor3 = Color3.fromRGB(41, 43, 48)
	toggleButton.BorderSizePixel = 0
	toggleButton.Text = "📦"
	toggleButton.Font = Enum.Font.SourceSansBold
	toggleButton.TextScaled = true
	toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	toggleButton.ZIndex = 100
	toggleButton.Parent = screenGui
	components.ToggleButton = toggleButton
	
	local toggleAspect = Instance.new("UIAspectRatioConstraint")
	toggleAspect.AspectRatio = 1
	toggleAspect.Parent = toggleButton
	
	local toggleCorner = Instance.new("UICorner")
	toggleCorner.CornerRadius = UDim.new(0, 8)
	toggleCorner.Parent = toggleButton

	-- Warning icon for full inventory
	local warningIcon = Instance.new("TextLabel")
	warningIcon.Name = "WarningIcon"
	warningIcon.Size = UDim2.new(0.4, 0, 0.4, 0)
	warningIcon.AnchorPoint = Vector2.new(1, 0)
	warningIcon.Position = UDim2.new(1.1, 0, -0.1, 0)
	warningIcon.Text = "!"
	warningIcon.Font = Enum.Font.SourceSansBold
	warningIcon.TextScaled = true
	warningIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
	warningIcon.BackgroundColor3 = Color3.fromRGB(237, 66, 69)
	warningIcon.Visible = false
	warningIcon.ZIndex = 101
	warningIcon.Parent = toggleButton
	components.WarningIcon = warningIcon
	
	local warningCorner = Instance.new("UICorner")
	warningCorner.CornerRadius = UDim.new(1, 0)
	warningCorner.Parent = warningIcon

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

	-- Character Viewport (Center/Background) - Made invisible
	local characterViewport = Instance.new("ViewportFrame")
	characterViewport.Name = "CharacterViewport"
	characterViewport.Size = UDim2.new(0.5, 0, 0.8, 0)
	characterViewport.Position = UDim2.new(0.25, 0, 0.1, 0)
	characterViewport.BackgroundTransparency = 1
	characterViewport.Visible = false -- Made invisible as requested
	characterViewport.ZIndex = 51
	characterViewport.Parent = mainFrame
	components.CharacterViewport = characterViewport

	-- Left Panel - Item Information
	local leftPanel = Instance.new("Frame")
	leftPanel.Name = "LeftPanel"
	leftPanel.Size = UDim2.new(0.25, -10, 0.9, 0)
	leftPanel.Position = UDim2.new(0, 10, 0.05, 0)
	leftPanel.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
	leftPanel.BorderSizePixel = 0
	leftPanel.ZIndex = 52
	leftPanel.Parent = mainFrame
	components.LeftPanel = leftPanel

	local leftCorner = Instance.new("UICorner")
	leftCorner.CornerRadius = UDim.new(0, 12)
	leftCorner.Parent = leftPanel

	-- Left panel gradient
	local leftGradient = Instance.new("UIGradient")
	leftGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0.0, Color3.fromRGB(35, 40, 50)),
		ColorSequenceKeypoint.new(1.0, Color3.fromRGB(15, 20, 30))
	}
	leftGradient.Rotation = 90
	leftGradient.Parent = leftPanel

	-- Right Panel - Item List with 3D Previews
	local rightPanel = Instance.new("Frame")
	rightPanel.Name = "RightPanel"
	rightPanel.Size = UDim2.new(0.25, -10, 0.9, 0)
	rightPanel.Position = UDim2.new(0.75, 0, 0.05, 0)
	rightPanel.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
	rightPanel.BorderSizePixel = 0
	rightPanel.ZIndex = 52
	rightPanel.Parent = mainFrame
	components.RightPanel = rightPanel

	local rightCorner = Instance.new("UICorner")
	rightCorner.CornerRadius = UDim.new(0, 12)
	rightCorner.Parent = rightPanel

	-- Right panel gradient
	local rightGradient = Instance.new("UIGradient")
	rightGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0.0, Color3.fromRGB(35, 40, 50)),
		ColorSequenceKeypoint.new(1.0, Color3.fromRGB(15, 20, 30))
	}
	rightGradient.Rotation = 90
	rightGradient.Parent = rightPanel

	-- Close Button (Top Right)
	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Size = UDim2.new(0.04, 0, 0.04, 0)
	closeButton.Position = UDim2.new(0.95, 0, 0.02, 0)
	closeButton.AnchorPoint = Vector2.new(0.5, 0)
	closeButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
	closeButton.Text = "X"
	closeButton.Font = Enum.Font.SourceSansBold
	closeButton.TextScaled = true
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.ZIndex = 55
	closeButton.Parent = mainFrame
	components.CloseButton = closeButton

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(1, 0)
	closeCorner.Parent = closeButton

	local closeAspect = Instance.new("UIAspectRatioConstraint")
	closeAspect.AspectRatio = 1
	closeAspect.Parent = closeButton

	-- LEFT PANEL CONTENT
	
	-- Title for left panel
	local detailTitle = Instance.new("TextLabel")
	detailTitle.Name = "DetailTitle"
	detailTitle.Size = UDim2.new(1, -20, 0, 40)
	detailTitle.Position = UDim2.new(0, 10, 0, 10)
	detailTitle.Text = "ITEM DETAILS"
	detailTitle.Font = Enum.Font.SourceSansBold
	detailTitle.TextSize = 24
	detailTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	detailTitle.BackgroundTransparency = 1
	detailTitle.TextXAlignment = Enum.TextXAlignment.Left
	detailTitle.ZIndex = 53
	detailTitle.Parent = leftPanel
	components.DetailTitle = detailTitle

	-- Item preview viewport (3D model)
	local itemViewport = Instance.new("ViewportFrame")
	itemViewport.Name = "ItemViewport"
	itemViewport.Size = UDim2.new(1, -20, 0, 150)
	itemViewport.Position = UDim2.new(0, 10, 0, 60)
	itemViewport.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
	itemViewport.BorderSizePixel = 0
	itemViewport.ZIndex = 53
	itemViewport.Parent = leftPanel
	components.ItemViewport = itemViewport

	local itemViewportCorner = Instance.new("UICorner")
	itemViewportCorner.CornerRadius = UDim.new(0, 8)
	itemViewportCorner.Parent = itemViewport

	-- Details scroll frame
	local detailsScroll = Instance.new("ScrollingFrame")
	detailsScroll.Name = "DetailsScroll"
	detailsScroll.Size = UDim2.new(1, -20, 1, -410) -- Adjusted for RAP label and buttons
	detailsScroll.Position = UDim2.new(0, 10, 0, 220)
	detailsScroll.BackgroundTransparency = 1
	detailsScroll.BorderSizePixel = 0
	detailsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	detailsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	detailsScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
	detailsScroll.ScrollBarThickness = 4
	detailsScroll.ZIndex = 53
	detailsScroll.Parent = leftPanel

	local detailsLayout = Instance.new("UIListLayout")
	detailsLayout.Padding = UDim.new(0, 8)
	detailsLayout.Parent = detailsScroll

	local function createDetailLabel(name, text, textSize)
		local label = Instance.new("TextLabel")
		label.Name = name
		label.Size = UDim2.new(1, 0, 0, textSize and (textSize + 10) or 30)
		label.Font = Enum.Font.SourceSans
		label.TextSize = textSize or 16
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
	rapLabel.Size = UDim2.new(1, -20, 0, 25)
	rapLabel.Position = UDim2.new(0, 10, 1, -185)
	rapLabel.Font = Enum.Font.SourceSansBold
	rapLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
	rapLabel.TextSize = 18
	rapLabel.Text = "Total RAP: R$0"
	rapLabel.TextXAlignment = Enum.TextXAlignment.Left
	rapLabel.BackgroundTransparency = 1
	rapLabel.ZIndex = 53
	rapLabel.Parent = leftPanel
	components.RAPLabel = rapLabel

	-- Action buttons container
	local buttonContainer = Instance.new("Frame")
	buttonContainer.Name = "ButtonContainer"
	buttonContainer.Size = UDim2.new(1, -20, 0, 150)
	buttonContainer.Position = UDim2.new(0, 10, 1, -160)
	buttonContainer.BackgroundTransparency = 1
	buttonContainer.ZIndex = 53
	buttonContainer.Parent = leftPanel
	
	local buttonLayout = Instance.new("UIListLayout")
	buttonLayout.Padding = UDim.new(0, 6)
	buttonLayout.Parent = buttonContainer

	local function createActionButton(name, text, color, layoutOrder)
		local button = Instance.new("TextButton")
		button.Name = name
		button.Size = UDim2.new(1, 0, 0, 28)
		button.BackgroundColor3 = color
		button.Text = text
		button.Font = Enum.Font.SourceSansBold
		button.TextSize = 14
		button.TextColor3 = Color3.fromRGB(255, 255, 255)
		button.LayoutOrder = layoutOrder or 0
		button.Visible = false
		button.ZIndex = 53
		button.Parent = buttonContainer
		
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 6)
		corner.Parent = button
		
		return button
	end

	-- Create action buttons
	local equipStateContainer = Instance.new("Frame")
	equipStateContainer.Name = "EquipStateContainer"
	equipStateContainer.Size = UDim2.new(1, 0, 0, 28)
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
	
	-- Title for right panel
	local inventoryTitle = Instance.new("TextLabel")
	inventoryTitle.Name = "InventoryTitle"
	inventoryTitle.Size = UDim2.new(1, -20, 0, 40)
	inventoryTitle.Position = UDim2.new(0, 10, 0, 10)
	inventoryTitle.Text = "INVENTORY"
	inventoryTitle.Font = Enum.Font.SourceSansBold
	inventoryTitle.TextSize = 24
	inventoryTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	inventoryTitle.BackgroundTransparency = 1
	inventoryTitle.TextXAlignment = Enum.TextXAlignment.Left
	inventoryTitle.ZIndex = 53
	inventoryTitle.Parent = rightPanel
	components.InventoryTitle = inventoryTitle

	-- Item list scroll frame
	local listPanel = Instance.new("ScrollingFrame")
	listPanel.Name = "ListPanel"
	listPanel.Size = UDim2.new(1, -20, 1, -70) -- Adjusted for title and RAP label
	listPanel.Position = UDim2.new(0, 10, 0, 50)
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
	listLayout.Padding = UDim.new(0, 8)
	listLayout.Parent = listPanel

	-- Parent the main GUI to the provided parent
	screenGui.Parent = parent

	return components
end

-- Create modern item template with 3D preview
function InventoryUI.CreateItemTemplate(itemInstance, itemName, itemConfig, rarityConfig, mutationConfig)
	local template = Instance.new("TextButton")
	template.Name = itemInstance.Name
	template.Size = UDim2.new(1, 0, 0, 90)
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
	nameLabel.Text = itemName
	nameLabel.TextColor3 = rarityConfig and rarityConfig.Color or Color3.fromRGB(255, 255, 255)
	if mutationConfig then
		nameLabel.TextColor3 = mutationConfig.Color
		nameLabel.Text = (itemInstance:GetAttribute("Mutation") or "") .. " " .. itemName
	end
	nameLabel.TextSize = 14
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.BackgroundTransparency = 1
	nameLabel.ZIndex = 55
	nameLabel.Parent = infoContainer
	
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
	local ItemValueCalculator = require(game.ReplicatedStorage.Shared.Modules.ItemValueCalculator)
	local size = itemInstance:GetAttribute("Size") or 1
	local value = ItemValueCalculator.GetFormattedValue(itemConfig, mutationConfig, size)
	
	local valueLabel = Instance.new("TextLabel")
	valueLabel.Name = "ValueLabel"
	valueLabel.Size = UDim2.new(1, 0, 0, 16)
	valueLabel.Font = Enum.Font.SourceSansBold
	valueLabel.Text = value .. " • Size: " .. string.format("%.2f", size)
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

	-- Lock Icon - bigger and more prominent
	local lockIcon = Instance.new("TextLabel")
	lockIcon.Name = "LockIcon"
	lockIcon.Size = UDim2.new(0, 32, 0, 32)
	lockIcon.Text = "🔒"
	lockIcon.Font = Enum.Font.SourceSansBold
	lockIcon.TextSize = 20
	lockIcon.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
	lockIcon.TextColor3 = Color3.fromRGB(0, 0, 0)
	lockIcon.Visible = false
	lockIcon.ZIndex = 56
	lockIcon.Parent = iconsContainer

	local lockCorner = Instance.new("UICorner")
	lockCorner.CornerRadius = UDim.new(1, 0)
	lockCorner.Parent = lockIcon
	
	-- Enhanced glow effect to lock icon
	local lockStroke = Instance.new("UIStroke")
	lockStroke.Color = Color3.fromRGB(255, 220, 100)
	lockStroke.Thickness = 3
	lockStroke.Transparency = 0.2
	lockStroke.Parent = lockIcon

	-- Equipped Icon
	local equippedIcon = Instance.new("TextLabel")
	equippedIcon.Name = "EquippedIcon"
	equippedIcon.Size = UDim2.new(0, 32, 0, 32)
	equippedIcon.Text = "⚡"
	equippedIcon.Font = Enum.Font.SourceSansBold
	equippedIcon.TextSize = 20
	equippedIcon.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
	equippedIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
	equippedIcon.Visible = false
	equippedIcon.ZIndex = 56
	equippedIcon.Parent = iconsContainer

	local equippedCorner = Instance.new("UICorner")
	equippedCorner.CornerRadius = UDim.new(1, 0)
	equippedCorner.Parent = equippedIcon
	
	-- Enhanced glow effect to equipped icon
	local equippedStroke = Instance.new("UIStroke")
	equippedStroke.Color = Color3.fromRGB(120, 255, 120)
	equippedStroke.Thickness = 3
	equippedStroke.Transparency = 0.2
	equippedStroke.Parent = equippedIcon

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