local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Shared = ReplicatedStorage.Shared
local GameConfig = require(Shared.Modules.GameConfig)
local NumberFormatter = require(Shared.Modules.NumberFormatter)
local ItemValueCalculator = require(Shared.Modules.ItemValueCalculator)

local EnchanterUI = {}

-- Calculate UI scale based on screen size
local function calculateUIScale()
	local viewport = workspace.CurrentCamera.ViewportSize
	local baseResolution = 1080
	local scale = math.min(viewport.Y / baseResolution, 1.2) -- Cap at 1.2x for very high resolutions
	return math.max(scale, 0.7) -- Minimum scale of 0.7 for very small screens
end

function EnchanterUI.Create(parentGui)
	local components = {}
	
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "EnchanterGui"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = parentGui
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	components.ScreenGui = screenGui

	-- Add a UIScale to manage UI scaling across different resolutions
	local uiScale = Instance.new("UIScale")
	uiScale.Scale = calculateUIScale()
	uiScale.Parent = screenGui
	components.UIScale = uiScale

	-- Main Frame (with margins from screen edges)
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "EnchanterMainFrame"
	mainFrame.Size = UDim2.new(0.7, 0, 0.8, 0) -- Larger size for better visibility
	mainFrame.Position = UDim2.new(0.15, 0, 0.1, 0) -- Centered
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
	title.Size = UDim2.new(1, -220, 1, 0)
	title.Position = UDim2.new(0, 20, 0, 0)
	title.Text = "🔮 ITEM ENCHANTER"
	title.Font = Enum.Font.SourceSansBold
	title.TextSize = 32
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.BackgroundTransparency = 1
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.ZIndex = 52
	title.Parent = titleBar
	components.Title = title

	-- Subtitle
	local subtitle = Instance.new("TextLabel")
	subtitle.Name = "Subtitle"
	subtitle.Size = UDim2.new(0, 400, 0, 25)
	subtitle.Position = UDim2.new(0, 20, 1, -30)
	subtitle.Text = "Reroll your item's mutators for R$"
	subtitle.Font = Enum.Font.SourceSans
	subtitle.TextSize = 16
	subtitle.TextColor3 = Color3.fromRGB(200, 200, 200)
	subtitle.BackgroundTransparency = 1
	subtitle.TextXAlignment = Enum.TextXAlignment.Left
	subtitle.ZIndex = 52
	subtitle.Parent = titleBar
	components.Subtitle = subtitle

	-- Info Button (? button)
	local infoButton = Instance.new("TextButton")
	infoButton.Name = "InfoButton"
	infoButton.Size = UDim2.new(0, 50, 0, 50)
	infoButton.Position = UDim2.new(1, -120, 0, 15)
	infoButton.BackgroundColor3 = Color3.fromRGB(60, 80, 100)
	infoButton.Text = "?"
	infoButton.Font = Enum.Font.SourceSansBold
	infoButton.TextScaled = true
	infoButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	infoButton.ZIndex = 55
	infoButton.Parent = titleBar
	components.InfoButton = infoButton

	local infoCorner = Instance.new("UICorner")
	infoCorner.CornerRadius = UDim.new(0, 16)
	infoCorner.Parent = infoButton

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

	-- Left Panel - Item Selection and Display
	local leftPanel = Instance.new("Frame")
	leftPanel.Name = "LeftPanel"
	leftPanel.Size = UDim2.new(0.6, -10, 1, 0)
	leftPanel.Position = UDim2.new(0, 0, 0, 0)
	leftPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	leftPanel.BackgroundTransparency = 0.3
	leftPanel.BorderSizePixel = 0
	leftPanel.ZIndex = 52
	leftPanel.Parent = contentFrame
	components.LeftPanel = leftPanel

	local leftCorner = Instance.new("UICorner")
	leftCorner.CornerRadius = UDim.new(0, 12)
	leftCorner.Parent = leftPanel

	-- Item Selection Header
	local selectionHeader = Instance.new("TextLabel")
	selectionHeader.Name = "SelectionHeader"
	selectionHeader.Size = UDim2.new(1, 0, 0, 25)
	selectionHeader.Position = UDim2.new(0, 15, 0, 10)
	selectionHeader.Text = "Select Item to Enchant:"
	selectionHeader.Font = Enum.Font.SourceSansBold
	selectionHeader.TextSize = 16
	selectionHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
	selectionHeader.TextXAlignment = Enum.TextXAlignment.Left
	selectionHeader.BackgroundTransparency = 1
	selectionHeader.ZIndex = 53
	selectionHeader.Parent = leftPanel
	components.SelectionHeader = selectionHeader

	-- Search Bar for item filtering
	local searchBox = Instance.new("TextBox")
	searchBox.Name = "SearchBox"
	searchBox.Size = UDim2.new(1, -30, 0, 28)
	searchBox.Position = UDim2.new(0, 15, 0, 35)
	searchBox.PlaceholderText = "Search items..."
	searchBox.Text = ""
	searchBox.Font = Enum.Font.SourceSans
	searchBox.TextSize = 16
	searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	searchBox.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
	searchBox.BackgroundTransparency = 0.15
	searchBox.ClearTextOnFocus = false
	searchBox.ZIndex = 54
	searchBox.Parent = leftPanel
	components.SearchBox = searchBox

	-- Item Selection List
	local itemSelectionFrame = Instance.new("ScrollingFrame")
	itemSelectionFrame.Name = "ItemSelectionFrame"
	itemSelectionFrame.Size = UDim2.new(1, -30, 0, 90)
	itemSelectionFrame.Position = UDim2.new(0, 15, 0, 70)
	itemSelectionFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
	itemSelectionFrame.BorderSizePixel = 0
	itemSelectionFrame.ScrollBarThickness = 6
	itemSelectionFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
	itemSelectionFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	itemSelectionFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	itemSelectionFrame.ZIndex = 53
	itemSelectionFrame.Parent = leftPanel
	components.ItemSelectionFrame = itemSelectionFrame

	local selectionCorner = Instance.new("UICorner")
	selectionCorner.CornerRadius = UDim.new(0, 8)
	selectionCorner.Parent = itemSelectionFrame

	local selectionLayout = Instance.new("UIListLayout")
	selectionLayout.Padding = UDim.new(0, 3)
	selectionLayout.Parent = itemSelectionFrame

	-- Selected Item Display Container
	local selectedItemContainer = Instance.new("Frame")
	selectedItemContainer.Name = "SelectedItemContainer"
	selectedItemContainer.Size = UDim2.new(1, -30, 0, 140)
	selectedItemContainer.Position = UDim2.new(0, 15, 0, 175)
	selectedItemContainer.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
	selectedItemContainer.BorderSizePixel = 0
	selectedItemContainer.ZIndex = 53
	selectedItemContainer.Parent = leftPanel
	components.SelectedItemContainer = selectedItemContainer

	local selectedItemCorner = Instance.new("UICorner")
	selectedItemCorner.CornerRadius = UDim.new(0, 8)
	selectedItemCorner.Parent = selectedItemContainer

	-- Item Preview (3D viewport)
	local itemViewport = Instance.new("ViewportFrame")
	itemViewport.Name = "ItemViewport"
	itemViewport.Size = UDim2.new(0, 100, 0, 100)
	itemViewport.Position = UDim2.new(0, 15, 0, 15)
	itemViewport.BackgroundColor3 = Color3.fromRGB(20, 22, 25)
	itemViewport.BorderSizePixel = 0
	itemViewport.ZIndex = 54
	itemViewport.Parent = selectedItemContainer
	components.ItemViewport = itemViewport

	local viewportCorner = Instance.new("UICorner")
	viewportCorner.CornerRadius = UDim.new(0, 8)
	viewportCorner.Parent = itemViewport

	-- Selected Item Info Panel
	local itemInfoPanel = Instance.new("Frame")
	itemInfoPanel.Name = "ItemInfoPanel"
	itemInfoPanel.Size = UDim2.new(1, -130, 1, -30)
	itemInfoPanel.Position = UDim2.new(0, 130, 0, 15)
	itemInfoPanel.BackgroundTransparency = 1
	itemInfoPanel.ZIndex = 54
	itemInfoPanel.Parent = selectedItemContainer

	-- Item Name
	local itemNameLabel = Instance.new("TextLabel")
	itemNameLabel.Name = "ItemNameLabel"
	itemNameLabel.Size = UDim2.new(1, 0, 0, 25)
	itemNameLabel.Position = UDim2.new(0, 0, 0, 0)
	itemNameLabel.Text = "No item selected"
	itemNameLabel.Font = Enum.Font.SourceSansBold
	itemNameLabel.TextSize = 16
	itemNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	itemNameLabel.TextXAlignment = Enum.TextXAlignment.Left
	itemNameLabel.BackgroundTransparency = 1
	itemNameLabel.ZIndex = 55
	itemNameLabel.Parent = itemInfoPanel
	components.ItemNameLabel = itemNameLabel

	-- Item Value
	local itemValueLabel = Instance.new("TextLabel")
	itemValueLabel.Name = "ItemValueLabel"
	itemValueLabel.Size = UDim2.new(1, 0, 0, 20)
	itemValueLabel.Position = UDim2.new(0, 0, 0, 25)
	itemValueLabel.Text = ""
	itemValueLabel.Font = Enum.Font.SourceSansBold
	itemValueLabel.TextSize = 14
	itemValueLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
	itemValueLabel.TextXAlignment = Enum.TextXAlignment.Left
	itemValueLabel.BackgroundTransparency = 1
	itemValueLabel.ZIndex = 55
	itemValueLabel.Parent = itemInfoPanel
	components.ItemValueLabel = itemValueLabel

	-- Item Type
	local itemTypeLabel = Instance.new("TextLabel")
	itemTypeLabel.Name = "ItemTypeLabel"
	itemTypeLabel.Size = UDim2.new(1, 0, 0, 18)
	itemTypeLabel.Position = UDim2.new(0, 0, 0, 50)
	itemTypeLabel.Text = ""
	itemTypeLabel.Font = Enum.Font.SourceSans
	itemTypeLabel.TextSize = 12
	itemTypeLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	itemTypeLabel.TextXAlignment = Enum.TextXAlignment.Left
	itemTypeLabel.BackgroundTransparency = 1
	itemTypeLabel.ZIndex = 55
	itemTypeLabel.Parent = itemInfoPanel
	components.ItemTypeLabel = itemTypeLabel

	-- Item Size
	local itemSizeLabel = Instance.new("TextLabel")
	itemSizeLabel.Name = "ItemSizeLabel"
	itemSizeLabel.Size = UDim2.new(1, 0, 0, 18)
	itemSizeLabel.Position = UDim2.new(0, 0, 0, 70)
	itemSizeLabel.Text = ""
	itemSizeLabel.Font = Enum.Font.SourceSans
	itemSizeLabel.TextSize = 12
	itemSizeLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
	itemSizeLabel.TextXAlignment = Enum.TextXAlignment.Left
	itemSizeLabel.BackgroundTransparency = 1
	itemSizeLabel.ZIndex = 55
	itemSizeLabel.Parent = itemInfoPanel
	components.ItemSizeLabel = itemSizeLabel

	-- Current Mutators Label
	local currentMutatorsLabel = Instance.new("TextLabel")
	currentMutatorsLabel.Name = "CurrentMutatorsLabel"
	currentMutatorsLabel.Size = UDim2.new(1, 0, 0, 20)
	currentMutatorsLabel.Position = UDim2.new(0, 15, 0, 330)
	currentMutatorsLabel.Text = "Current Mutators:"
	currentMutatorsLabel.Font = Enum.Font.SourceSansBold
	currentMutatorsLabel.TextSize = 14
	currentMutatorsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	currentMutatorsLabel.TextXAlignment = Enum.TextXAlignment.Left
	currentMutatorsLabel.BackgroundTransparency = 1
	currentMutatorsLabel.ZIndex = 53
	currentMutatorsLabel.Parent = leftPanel
	components.CurrentMutatorsLabel = currentMutatorsLabel

	-- Mutators List
	local mutatorsScrollFrame = Instance.new("ScrollingFrame")
	mutatorsScrollFrame.Name = "MutatorsScrollFrame"
	mutatorsScrollFrame.Size = UDim2.new(1, -30, 1, -365)
	mutatorsScrollFrame.Position = UDim2.new(0, 15, 0, 355)
	mutatorsScrollFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
	mutatorsScrollFrame.BorderSizePixel = 0
	mutatorsScrollFrame.ScrollBarThickness = 6
	mutatorsScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
	mutatorsScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	mutatorsScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	mutatorsScrollFrame.ZIndex = 53
	mutatorsScrollFrame.Parent = leftPanel
	components.MutatorsScrollFrame = mutatorsScrollFrame

	local mutatorsCorner = Instance.new("UICorner")
	mutatorsCorner.CornerRadius = UDim.new(0, 8)
	mutatorsCorner.Parent = mutatorsScrollFrame

	local mutatorsLayout = Instance.new("UIListLayout")
	mutatorsLayout.Padding = UDim.new(0, 5)
	mutatorsLayout.Parent = mutatorsScrollFrame

	-- Right Panel - Actions
	local rightPanel = Instance.new("Frame")
	rightPanel.Name = "RightPanel"
	rightPanel.Size = UDim2.new(0.4, -10, 1, 0)
	rightPanel.Position = UDim2.new(0.6, 10, 0, 0)
	rightPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	rightPanel.BackgroundTransparency = 0.3
	rightPanel.BorderSizePixel = 0
	rightPanel.ZIndex = 52
	rightPanel.Parent = contentFrame
	components.RightPanel = rightPanel

	local rightCorner = Instance.new("UICorner")
	rightCorner.CornerRadius = UDim.new(0, 12)
	rightCorner.Parent = rightPanel

	-- Action Panel Content
	local actionLayout = Instance.new("UIListLayout")
	actionLayout.Padding = UDim.new(0, 15)
	actionLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	actionLayout.Parent = rightPanel

	local actionPadding = Instance.new("UIPadding")
	actionPadding.PaddingLeft = UDim.new(0, 20)
	actionPadding.PaddingRight = UDim.new(0, 20)
	actionPadding.PaddingTop = UDim.new(0, 20)
	actionPadding.PaddingBottom = UDim.new(0, 20)
	actionPadding.Parent = rightPanel

	-- Action Title
	local actionTitle = Instance.new("TextLabel")
	actionTitle.Name = "ActionTitle"
	actionTitle.Size = UDim2.new(1, 0, 0, 30)
	actionTitle.Text = "Mutator Reroll"
	actionTitle.Font = Enum.Font.SourceSansBold
	actionTitle.TextSize = 20
	actionTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	actionTitle.BackgroundTransparency = 1
	actionTitle.ZIndex = 53
	actionTitle.Parent = rightPanel
	components.ActionTitle = actionTitle

	-- Cost Display
	local costLabel = Instance.new("TextLabel")
	costLabel.Name = "CostLabel"
	costLabel.Size = UDim2.new(1, 0, 0, 25)
	costLabel.Text = "Cost: 0 R$"
	costLabel.Font = Enum.Font.SourceSansBold
	costLabel.TextSize = 18
	costLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	costLabel.BackgroundTransparency = 1
	costLabel.ZIndex = 53
	costLabel.Parent = rightPanel
	components.CostLabel = costLabel

	-- Description
	local descriptionLabel = Instance.new("TextLabel")
	descriptionLabel.Name = "DescriptionLabel"
	descriptionLabel.Size = UDim2.new(1, 0, 0, 60)
	descriptionLabel.Text = "Reroll all mutators on this item using the same probability system as opening crates. This will replace all current mutators with new ones."
	descriptionLabel.Font = Enum.Font.SourceSans
	descriptionLabel.TextSize = 14
	descriptionLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	descriptionLabel.TextWrapped = true
	descriptionLabel.BackgroundTransparency = 1
	descriptionLabel.ZIndex = 53
	descriptionLabel.Parent = rightPanel
	components.DescriptionLabel = descriptionLabel

	-- Reroll Button
	local rerollButton = Instance.new("TextButton")
	rerollButton.Name = "RerollButton"
	rerollButton.Size = UDim2.new(1, 0, 0, 50)
	rerollButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
	rerollButton.Text = "Reroll Mutators"
	rerollButton.Font = Enum.Font.SourceSansBold
	rerollButton.TextSize = 18
	rerollButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	rerollButton.ZIndex = 53
	rerollButton.Parent = rightPanel
	components.RerollButton = rerollButton

	local rerollCorner = Instance.new("UICorner")
	rerollCorner.CornerRadius = UDim.new(0, 12)
	rerollCorner.Parent = rerollButton

	-- Warning Label
	local warningLabel = Instance.new("TextLabel")
	warningLabel.Name = "WarningLabel"
	warningLabel.Size = UDim2.new(1, 0, 0, 40)
	warningLabel.Text = "⚠️ This will replace ALL current mutators!"
	warningLabel.Font = Enum.Font.SourceSans
	warningLabel.TextSize = 12
	warningLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
	warningLabel.TextWrapped = true
	warningLabel.BackgroundTransparency = 1
	warningLabel.ZIndex = 53
	warningLabel.Parent = rightPanel
	components.WarningLabel = warningLabel

	-- Info Popup (initially hidden)
	local infoPopup = Instance.new("Frame")
	infoPopup.Name = "InfoPopup"
	infoPopup.Size = UDim2.new(0.8, 0, 0.8, 0)
	infoPopup.Position = UDim2.new(0.1, 0, 0.1, 0)
	infoPopup.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
	infoPopup.BorderSizePixel = 0
	infoPopup.Visible = false
	infoPopup.ZIndex = 100
	infoPopup.Parent = screenGui
	components.InfoPopup = infoPopup

	local infoPopupCorner = Instance.new("UICorner")
	infoPopupCorner.CornerRadius = UDim.new(0, 16)
	infoPopupCorner.Parent = infoPopup

	-- Info Popup Title Bar
	local infoTitleBar = Instance.new("Frame")
	infoTitleBar.Name = "InfoTitleBar"
	infoTitleBar.Size = UDim2.new(1, 0, 0, 60)
	infoTitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
	infoTitleBar.BorderSizePixel = 0
	infoTitleBar.ZIndex = 101
	infoTitleBar.Parent = infoPopup

	local infoTitleCorner = Instance.new("UICorner")
	infoTitleCorner.CornerRadius = UDim.new(0, 16)
	infoTitleCorner.Parent = infoTitleBar

	local infoTitle = Instance.new("TextLabel")
	infoTitle.Name = "InfoTitle"
	infoTitle.Size = UDim2.new(1, -100, 1, 0)
	infoTitle.Position = UDim2.new(0, 20, 0, 0)
	infoTitle.Text = "🎲 Mutator Probabilities"
	infoTitle.Font = Enum.Font.SourceSansBold
	infoTitle.TextSize = 24
	infoTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	infoTitle.TextXAlignment = Enum.TextXAlignment.Left
	infoTitle.BackgroundTransparency = 1
	infoTitle.ZIndex = 102
	infoTitle.Parent = infoTitleBar
	components.InfoTitle = infoTitle

	-- Info Close Button
	local infoCloseButton = Instance.new("TextButton")
	infoCloseButton.Name = "InfoCloseButton"
	infoCloseButton.Size = UDim2.new(0, 40, 0, 40)
	infoCloseButton.Position = UDim2.new(1, -50, 0, 10)
	infoCloseButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
	infoCloseButton.Text = "X"
	infoCloseButton.Font = Enum.Font.SourceSansBold
	infoCloseButton.TextSize = 16
	infoCloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	infoCloseButton.ZIndex = 102
	infoCloseButton.Parent = infoTitleBar
	components.InfoCloseButton = infoCloseButton

	local infoCloseCorner = Instance.new("UICorner")
	infoCloseCorner.CornerRadius = UDim.new(0, 12)
	infoCloseCorner.Parent = infoCloseButton

	-- Info Content
	local infoScrollFrame = Instance.new("ScrollingFrame")
	infoScrollFrame.Name = "InfoScrollFrame"
	infoScrollFrame.Size = UDim2.new(1, -30, 1, -90)
	infoScrollFrame.Position = UDim2.new(0, 15, 0, 75)
	infoScrollFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	infoScrollFrame.BorderSizePixel = 0
	infoScrollFrame.ScrollBarThickness = 8
	infoScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
	infoScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	infoScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	infoScrollFrame.ZIndex = 101
	infoScrollFrame.Parent = infoPopup
	components.InfoScrollFrame = infoScrollFrame

	local infoScrollCorner = Instance.new("UICorner")
	infoScrollCorner.CornerRadius = UDim.new(0, 12)
	infoScrollCorner.Parent = infoScrollFrame

	local infoScrollPadding = Instance.new("UIPadding")
	infoScrollPadding.PaddingLeft = UDim.new(0, 15)
	infoScrollPadding.PaddingRight = UDim.new(0, 15)
	infoScrollPadding.PaddingTop = UDim.new(0, 15)
	infoScrollPadding.PaddingBottom = UDim.new(0, 15)
	infoScrollPadding.Parent = infoScrollFrame

	local infoScrollLayout = Instance.new("UIListLayout")
	infoScrollLayout.Padding = UDim.new(0, 10)
	infoScrollLayout.Parent = infoScrollFrame

	-- Update scale when screen size changes
	local function updateScale()
		uiScale.Scale = calculateUIScale()
	end
	
	-- Connect to viewport size changes
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
	components.UpdateScale = updateScale

	return components
end

-- Function to create item selection entry
function EnchanterUI.CreateItemSelectionEntry(itemData, isSelected)
	local entry = Instance.new("TextButton")
	entry.Name = "ItemEntry_" .. (itemData.itemInstance.Name or "Unknown")
	entry.Size = UDim2.new(1, -10, 0, 40)
	entry.BackgroundColor3 = isSelected and Color3.fromRGB(88, 101, 242) or Color3.fromRGB(40, 40, 50)
	entry.BorderSizePixel = 0
	entry.ZIndex = 54
	entry.AutoButtonColor = false
	entry.Text = "" -- Remove default 'Button' text
	
	local entryCorner = Instance.new("UICorner")
	entryCorner.CornerRadius = UDim.new(0, 6)
	entryCorner.Parent = entry
	
	-- Item name and mutations
	local mutationNames = require(game.ReplicatedStorage.Shared.Modules.ItemValueCalculator).GetMutationNames(itemData.itemInstance)
	local displayName = itemData.itemName
	if #mutationNames > 0 then
		displayName = table.concat(mutationNames, " ") .. " " .. itemData.itemName
	end
	
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0.7, 0, 0.6, 0)
	nameLabel.Position = UDim2.new(0, 8, 0, 0)
	nameLabel.Text = displayName
	nameLabel.Font = Enum.Font.SourceSans
	nameLabel.TextSize = 12
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.TextYAlignment = Enum.TextYAlignment.Center
	nameLabel.BackgroundTransparency = 1
	nameLabel.ZIndex = 55
	nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
	nameLabel.Parent = entry
	
	-- Item value
	local NumberFormatter = require(game.ReplicatedStorage.Shared.Modules.NumberFormatter)
	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(0.3, -8, 0.6, 0)
	valueLabel.Position = UDim2.new(0.7, 0, 0, 0)
	valueLabel.Text = "R$ " .. NumberFormatter.FormatCurrency(itemData.value)
	valueLabel.Font = Enum.Font.SourceSansBold
	valueLabel.TextSize = 11
	valueLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.TextYAlignment = Enum.TextYAlignment.Center
	valueLabel.BackgroundTransparency = 1
	valueLabel.ZIndex = 55
	valueLabel.Parent = entry
	
	-- Size info
	local size = itemData.itemInstance:GetAttribute("Size") or 1
	local sizeLabel = Instance.new("TextLabel")
	sizeLabel.Size = UDim2.new(1, -8, 0.4, 0)
	sizeLabel.Position = UDim2.new(0, 8, 0.6, 0)
	sizeLabel.Text = "Size: " .. NumberFormatter.FormatSize(size)
	sizeLabel.Font = Enum.Font.SourceSans
	sizeLabel.TextSize = 10
	sizeLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	sizeLabel.TextXAlignment = Enum.TextXAlignment.Left
	sizeLabel.TextYAlignment = Enum.TextYAlignment.Center
	sizeLabel.BackgroundTransparency = 1
	sizeLabel.ZIndex = 55
	sizeLabel.Parent = entry
	
	return entry
end

-- Create mutator entry for display
function EnchanterUI.CreateMutatorEntry(mutatorName, mutatorConfig)
	mutatorConfig = mutatorConfig or {ValueMultiplier = 1, Color = Color3.fromRGB(180,180,180)}
	local entry = Instance.new("Frame")
	entry.Name = mutatorName .. "Entry"
	entry.Size = UDim2.new(1, -10, 0, 25)
	entry.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
	entry.BorderSizePixel = 0
	entry.ZIndex = 54
	
	local entryCorner = Instance.new("UICorner")
	entryCorner.CornerRadius = UDim.new(0, 6)
	entryCorner.Parent = entry
	
	local entryLabel = Instance.new("TextLabel")
	entryLabel.Name = "EntryLabel"
	entryLabel.Size = UDim2.new(1, -10, 1, 0)
	entryLabel.Position = UDim2.new(0, 5, 0, 0)
	if mutatorName == "No mutators" or mutatorName == "No mutators (1x value)" then
		entryLabel.Text = "No mutators (1x value)"
	else
		entryLabel.Text = mutatorName .. " (" .. (mutatorConfig.ValueMultiplier or 1) .. "x value)"
	end
	entryLabel.Font = Enum.Font.SourceSans
	entryLabel.TextSize = 12
	entryLabel.TextColor3 = mutatorConfig.Color or Color3.fromRGB(255, 255, 255)
	entryLabel.TextXAlignment = Enum.TextXAlignment.Left
	entryLabel.BackgroundTransparency = 1
	entryLabel.ZIndex = 55
	entryLabel.Parent = entry
	
	return entry
end

-- Create info entry for mutator probabilities
function EnchanterUI.CreateInfoEntry(mutatorName, mutatorConfig)
	local entry = Instance.new("Frame")
	entry.Name = mutatorName .. "InfoEntry"
	entry.Size = UDim2.new(1, 0, 0, 40)
	entry.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
	entry.BorderSizePixel = 0
	entry.ZIndex = 102
	
	local entryCorner = Instance.new("UICorner")
	entryCorner.CornerRadius = UDim.new(0, 8)
	entryCorner.Parent = entry
	
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.Size = UDim2.new(0.5, 0, 0.5, 0)
	nameLabel.Position = UDim2.new(0, 10, 0, 5)
	nameLabel.Text = mutatorName
	nameLabel.Font = Enum.Font.SourceSansBold
	nameLabel.TextSize = 14
	nameLabel.TextColor3 = mutatorConfig.Color or Color3.fromRGB(255, 255, 255)
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.BackgroundTransparency = 1
	nameLabel.ZIndex = 103
	nameLabel.Parent = entry
	
	local chanceLabel = Instance.new("TextLabel")
	chanceLabel.Name = "ChanceLabel"
	chanceLabel.Size = UDim2.new(0.5, 0, 0.5, 0)
	chanceLabel.Position = UDim2.new(0.5, 0, 0, 5)
	chanceLabel.Text = mutatorConfig.Chance .. "%"
	chanceLabel.Font = Enum.Font.SourceSans
	chanceLabel.TextSize = 14
	chanceLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
	chanceLabel.TextXAlignment = Enum.TextXAlignment.Right
	chanceLabel.BackgroundTransparency = 1
	chanceLabel.ZIndex = 103
	chanceLabel.Parent = entry
	
	local multiplierLabel = Instance.new("TextLabel")
	multiplierLabel.Name = "MultiplierLabel"
	multiplierLabel.Size = UDim2.new(1, -20, 0.5, 0)
	multiplierLabel.Position = UDim2.new(0, 10, 0.5, 0)
	multiplierLabel.Text = "Value Multiplier: " .. (mutatorConfig.ValueMultiplier or 1) .. "x"
	multiplierLabel.Font = Enum.Font.SourceSans
	multiplierLabel.TextSize = 12
	multiplierLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	multiplierLabel.TextXAlignment = Enum.TextXAlignment.Left
	multiplierLabel.BackgroundTransparency = 1
	multiplierLabel.ZIndex = 103
	multiplierLabel.Parent = entry
	
	return entry
end

return EnchanterUI 