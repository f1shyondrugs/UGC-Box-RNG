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
	local isMobile = UserInputService.TouchEnabled

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

	-- Main Frame (responsive layout)
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "EnchanterMainFrame"
	mainFrame.Size = UDim2.new(0.75, 0, 0.85, 0)
	mainFrame.Position = UDim2.new(0.125, 0, 0.075, 0)
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
	title.Text = "🔮 ITEM ENCHANTER"
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

	-- Info Button
	local infoButton = Instance.new("TextButton")
	infoButton.Name = "InfoButton"
	infoButton.Size = UDim2.new(0, 40, 0, 40)
	infoButton.Position = UDim2.new(1, -95, 0.5, -20)
	infoButton.BackgroundColor3 = Color3.fromRGB(70, 90, 120)
	infoButton.Text = "?"
	infoButton.Font = Enum.Font.GothamBold
	infoButton.TextSize = 18
	infoButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	infoButton.ZIndex = 55
	infoButton.Parent = titleBar
	components.InfoButton = infoButton

	local infoCorner = Instance.new("UICorner")
	infoCorner.CornerRadius = UDim.new(0, 20)
	infoCorner.Parent = infoButton
	
	local infoGradient = Instance.new("UIGradient")
	infoGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 100, 140)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 80, 110))
	}
	infoGradient.Rotation = 90
	infoGradient.Parent = infoButton
	
	local infoStroke = Instance.new("UIStroke")
	infoStroke.Color = Color3.fromRGB(100, 120, 160)
	infoStroke.Thickness = 1
	infoStroke.Transparency = 0.5
	infoStroke.Parent = infoButton

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

	-- Content Area (now a scrolling frame to support mobile)
	local contentFrame = Instance.new("ScrollingFrame")
	contentFrame.Name = "ContentFrame"
	contentFrame.Size = UDim2.new(1, -40, 1, -100)
	contentFrame.Position = UDim2.new(0, 20, 0, 80)
	contentFrame.BackgroundTransparency = 1
	contentFrame.ZIndex = 51
	contentFrame.Parent = mainFrame
	contentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	contentFrame.ScrollBarThickness = 8
	contentFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 100)
	components.ContentFrame = contentFrame

	-- Left Panel - Selected Item Display and Current Mutators (now a regular frame)
	local leftPanel = Instance.new("Frame")
	leftPanel.Name = "LeftPanel"
	-- Size and Position will be set adaptively later
	leftPanel.BackgroundColor3 = Color3.fromHex("#121620")
	leftPanel.BackgroundTransparency = 0.5
	leftPanel.BorderSizePixel = 0
	leftPanel.ZIndex = 52
	leftPanel.Parent = contentFrame
	components.LeftPanel = leftPanel

	local leftCorner = Instance.new("UICorner")
	leftCorner.CornerRadius = UDim.new(0, 12)
	leftCorner.Parent = leftPanel

	local leftStroke = Instance.new("UIStroke")
	leftStroke.Color = Color3.fromRGB(60, 80, 120)
	leftStroke.Thickness = 1
	leftStroke.Transparency = 0.7
	leftStroke.Parent = leftPanel

	-- Left panel layout
	local leftPanelLayout = Instance.new("UIListLayout")
	leftPanelLayout.Padding = UDim.new(0, 15)
	leftPanelLayout.SortOrder = Enum.SortOrder.LayoutOrder
	leftPanelLayout.Parent = leftPanel

	local leftPanelPadding = Instance.new("UIPadding")
	leftPanelPadding.PaddingTop = UDim.new(0, 20)
	leftPanelPadding.PaddingBottom = UDim.new(0, 20)
	leftPanelPadding.PaddingLeft = UDim.new(0, 20)
	leftPanelPadding.PaddingRight = UDim.new(0, 20)
	leftPanelPadding.Parent = leftPanel

	-- Select Item Button
	local selectItemButton = Instance.new("TextButton")
	selectItemButton.Name = "SelectItemButton"
	selectItemButton.Size = UDim2.new(1, 0, 0, 50)
	selectItemButton.BackgroundColor3 = Color3.fromRGB(80, 120, 180)
	selectItemButton.Text = "📦 Select Item to Enchant"
	selectItemButton.Font = Enum.Font.GothamBold
	selectItemButton.TextSize = 18
	selectItemButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	selectItemButton.ZIndex = 53
	selectItemButton.LayoutOrder = 1
	selectItemButton.Parent = leftPanel
	components.SelectItemButton = selectItemButton

	local selectItemCorner = Instance.new("UICorner")
	selectItemCorner.CornerRadius = UDim.new(0, 12)
	selectItemCorner.Parent = selectItemButton

	local selectItemGradient = Instance.new("UIGradient")
	selectItemGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(90, 130, 200)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 110, 160))
	}
	selectItemGradient.Rotation = 90
	selectItemGradient.Parent = selectItemButton

	local selectItemStroke = Instance.new("UIStroke")
	selectItemStroke.Color = Color3.fromRGB(120, 160, 220)
	selectItemStroke.Thickness = 1
	selectItemStroke.Transparency = 0.5
	selectItemStroke.Parent = selectItemButton

	-- Selected Item Display Container
	local selectedItemContainer = Instance.new("Frame")
	selectedItemContainer.Name = "SelectedItemContainer"
	selectedItemContainer.Size = UDim2.new(1, 0, 0, 150)
	selectedItemContainer.BackgroundColor3 = Color3.fromRGB(28, 32, 45)
	selectedItemContainer.BorderSizePixel = 0
	selectedItemContainer.ZIndex = 53
	selectedItemContainer.LayoutOrder = 2
	selectedItemContainer.Parent = leftPanel
	components.SelectedItemContainer = selectedItemContainer

	local selectedItemCorner = Instance.new("UICorner")
	selectedItemCorner.CornerRadius = UDim.new(0, 10)
	selectedItemCorner.Parent = selectedItemContainer

	local containerGradient = Instance.new("UIGradient")
	containerGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(32, 36, 50)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(24, 28, 40))
	}
	containerGradient.Rotation = 90
	containerGradient.Parent = selectedItemContainer

	local containerStroke = Instance.new("UIStroke")
	containerStroke.Color = Color3.fromRGB(40, 50, 70)
	containerStroke.Thickness = 1
	containerStroke.Transparency = 0.6
	containerStroke.Parent = selectedItemContainer

	-- Item Preview (3D viewport)
	local itemViewport = Instance.new("ViewportFrame")
	itemViewport.Name = "ItemViewport"
	itemViewport.Size = UDim2.new(0, 120, 0, 120)
	itemViewport.Position = UDim2.new(0, 15, 0.5, -60)
	itemViewport.BackgroundColor3 = Color3.fromRGB(20, 22, 25)
	itemViewport.BorderSizePixel = 0
	itemViewport.ZIndex = 54
	itemViewport.Parent = selectedItemContainer
	components.ItemViewport = itemViewport

	local viewportCorner = Instance.new("UICorner")
	viewportCorner.CornerRadius = UDim.new(0, 10)
	viewportCorner.Parent = itemViewport

	-- Selected Item Info Panel
	local itemInfoPanel = Instance.new("Frame")
	itemInfoPanel.Name = "ItemInfoPanel"
	itemInfoPanel.Size = UDim2.new(1, -155, 1, -30)
	itemInfoPanel.Position = UDim2.new(0, 140, 0, 15)
	itemInfoPanel.BackgroundTransparency = 1
	itemInfoPanel.ZIndex = 54
	itemInfoPanel.Parent = selectedItemContainer

	-- Item Name
	local itemNameLabel = Instance.new("TextLabel")
	itemNameLabel.Name = "ItemNameLabel"
	itemNameLabel.Size = UDim2.new(1, 0, 0, 25)
	itemNameLabel.Position = UDim2.new(0, 0, 0, 0)
	itemNameLabel.Text = "No item selected"
	itemNameLabel.Font = Enum.Font.GothamBold
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
	itemValueLabel.Text = "Value: R$ 0"
	itemValueLabel.Font = Enum.Font.Gotham
	itemValueLabel.TextSize = 14
	itemValueLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
	itemValueLabel.TextXAlignment = Enum.TextXAlignment.Left
	itemValueLabel.BackgroundTransparency = 1
	itemValueLabel.ZIndex = 55
	itemValueLabel.Parent = itemInfoPanel
	components.ItemValueLabel = itemValueLabel

	-- Item Size
	local itemSizeLabel = Instance.new("TextLabel")
	itemSizeLabel.Name = "ItemSizeLabel"
	itemSizeLabel.Size = UDim2.new(1, 0, 0, 20)
	itemSizeLabel.Position = UDim2.new(0, 0, 0, 45)
	itemSizeLabel.Text = "Size: 1"
	itemSizeLabel.Font = Enum.Font.Gotham
	itemSizeLabel.TextSize = 14
	itemSizeLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	itemSizeLabel.TextXAlignment = Enum.TextXAlignment.Left
	itemSizeLabel.BackgroundTransparency = 1
	itemSizeLabel.ZIndex = 55
	itemSizeLabel.Parent = itemInfoPanel
	components.ItemSizeLabel = itemSizeLabel

	-- Current Mutators Container (New)
	local currentMutatorsContainer = Instance.new("Frame")
	currentMutatorsContainer.Name = "CurrentMutatorsContainer"
	currentMutatorsContainer.Size = UDim2.new(1, 0, 0, 200) -- Start with a reasonable base size
	currentMutatorsContainer.AutomaticSize = Enum.AutomaticSize.Y
	currentMutatorsContainer.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
	currentMutatorsContainer.BorderSizePixel = 0
	currentMutatorsContainer.LayoutOrder = 3
	currentMutatorsContainer.Parent = leftPanel
	components.CurrentMutatorsContainer = currentMutatorsContainer
	
	local mutatorsContainerCorner = Instance.new("UICorner")
	mutatorsContainerCorner.CornerRadius = UDim.new(0, 10)
	mutatorsContainerCorner.Parent = currentMutatorsContainer
	
	local mutatorsContainerStroke = Instance.new("UIStroke")
	mutatorsContainerStroke.Color = Color3.fromRGB(60, 80, 120)
	mutatorsContainerStroke.Thickness = 1
	mutatorsContainerStroke.Transparency = 0.7
	mutatorsContainerStroke.Parent = currentMutatorsContainer

	local mutatorsContainerLayout = Instance.new("UIListLayout")
	mutatorsContainerLayout.Padding = UDim.new(0, 8)
	mutatorsContainerLayout.SortOrder = Enum.SortOrder.LayoutOrder
	mutatorsContainerLayout.Parent = currentMutatorsContainer

	local mutatorsContainerPadding = Instance.new("UIPadding")
	mutatorsContainerPadding.PaddingTop = UDim.new(0, 10)
	mutatorsContainerPadding.PaddingBottom = UDim.new(0, 10)
	mutatorsContainerPadding.PaddingLeft = UDim.new(0, 10)
	mutatorsContainerPadding.PaddingRight = UDim.new(0, 10)
	mutatorsContainerPadding.Parent = currentMutatorsContainer

	-- Current Mutators Label (Moved)
	local currentMutatorsLabel = Instance.new("TextLabel")
	currentMutatorsLabel.Name = "CurrentMutatorsLabel"
	currentMutatorsLabel.Size = UDim2.new(1, 0, 0, 25)
	currentMutatorsLabel.Text = "🔮 Current Mutators:"
	currentMutatorsLabel.Font = Enum.Font.GothamBold
	currentMutatorsLabel.TextSize = 16
	currentMutatorsLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
	currentMutatorsLabel.TextXAlignment = Enum.TextXAlignment.Left
	currentMutatorsLabel.BackgroundTransparency = 1
	currentMutatorsLabel.LayoutOrder = 1
	currentMutatorsLabel.Parent = currentMutatorsContainer
	components.CurrentMutatorsLabel = currentMutatorsLabel

	-- Current Mutators Scroll Frame (Moved)
	local mutatorsScrollFrame = Instance.new("ScrollingFrame")
	mutatorsScrollFrame.Name = "MutatorsScrollFrame"
	mutatorsScrollFrame.Size = UDim2.new(1, 0, 0, 150)
	mutatorsScrollFrame.BackgroundColor3 = Color3.fromRGB(22, 26, 35)
	mutatorsScrollFrame.BorderSizePixel = 0
	mutatorsScrollFrame.ScrollBarThickness = 3
	mutatorsScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
	mutatorsScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	mutatorsScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	mutatorsScrollFrame.LayoutOrder = 2
	mutatorsScrollFrame.Parent = currentMutatorsContainer
	components.MutatorsScrollFrame = mutatorsScrollFrame

	local mutatorsCorner = Instance.new("UICorner")
	mutatorsCorner.CornerRadius = UDim.new(0, 6)
	mutatorsCorner.Parent = mutatorsScrollFrame

	local mutatorsLayout = Instance.new("UIListLayout")
	mutatorsLayout.Padding = UDim.new(0, 3)
	mutatorsLayout.Parent = mutatorsScrollFrame

	-- Right Panel - Actions and Auto-Enchanter
	local rightPanel = Instance.new("Frame")
	rightPanel.Name = "RightPanel"
	-- Size and Position will be set adaptively later
	rightPanel.BackgroundColor3 = Color3.fromHex("#121620")
	rightPanel.BackgroundTransparency = 0.5
	rightPanel.BorderSizePixel = 0
	rightPanel.ZIndex = 52
	rightPanel.Parent = contentFrame
	components.RightPanel = rightPanel

	local rightCorner = Instance.new("UICorner")
	rightCorner.CornerRadius = UDim.new(0, 12)
	rightCorner.Parent = rightPanel

	local rightStroke = Instance.new("UIStroke")
	rightStroke.Color = Color3.fromRGB(60, 80, 120)
	rightStroke.Thickness = 1
	rightStroke.Transparency = 0.7
	rightStroke.Parent = rightPanel

	-- Right panel layout
	local rightPanelLayout = Instance.new("UIListLayout")
	rightPanelLayout.Padding = UDim.new(0, 15)
	rightPanelLayout.SortOrder = Enum.SortOrder.LayoutOrder
	rightPanelLayout.Parent = rightPanel

	local rightPanelPadding = Instance.new("UIPadding")
	rightPanelPadding.PaddingTop = UDim.new(0, 20)
	rightPanelPadding.PaddingBottom = UDim.new(0, 20)
	rightPanelPadding.PaddingLeft = UDim.new(0, 20)
	rightPanelPadding.PaddingRight = UDim.new(0, 20)
	rightPanelPadding.Parent = rightPanel

	-- Normal Enchanting Section
	local enchantingTitle = Instance.new("TextLabel")
	enchantingTitle.Name = "EnchantingTitle"
	enchantingTitle.Size = UDim2.new(1, 0, 0, 30)
	enchantingTitle.Text = "🎲 Normal Enchanting"
	enchantingTitle.Font = Enum.Font.GothamBold
	enchantingTitle.TextSize = 18
	enchantingTitle.TextColor3 = Color3.fromRGB(120, 180, 255)
	enchantingTitle.BackgroundTransparency = 1
	enchantingTitle.LayoutOrder = 1
	enchantingTitle.ZIndex = 53
	enchantingTitle.Parent = rightPanel
	components.EnchantingTitle = enchantingTitle

	-- Cost Display
	local costLabel = Instance.new("TextLabel")
	costLabel.Name = "CostLabel"
	costLabel.Size = UDim2.new(1, 0, 0, 25)
	costLabel.Text = "💰 Cost: 0 R$"
	costLabel.Font = Enum.Font.GothamBold
	costLabel.TextSize = 16
	costLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	costLabel.BackgroundTransparency = 1
	costLabel.LayoutOrder = 2
	costLabel.ZIndex = 53
	costLabel.Parent = rightPanel
	components.CostLabel = costLabel

	-- Reroll Button
	local rerollButton = Instance.new("TextButton")
	rerollButton.Name = "RerollButton"
	rerollButton.Size = UDim2.new(1, 0, 0, 50)
	rerollButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
	rerollButton.Text = "🎲 Reroll Mutators"
	rerollButton.Font = Enum.Font.GothamBold
	rerollButton.TextSize = 18
	rerollButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	rerollButton.LayoutOrder = 3
	rerollButton.ZIndex = 53
	rerollButton.Parent = rightPanel
	components.RerollButton = rerollButton

	local rerollCorner = Instance.new("UICorner")
	rerollCorner.CornerRadius = UDim.new(0, 12)
	rerollCorner.Parent = rerollButton

	local rerollGradient = Instance.new("UIGradient")
	rerollGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 120, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 90, 230))
	}
	rerollGradient.Rotation = 90
	rerollGradient.Parent = rerollButton

	local rerollStroke = Instance.new("UIStroke")
	rerollStroke.Color = Color3.fromRGB(120, 140, 255)
	rerollStroke.Thickness = 1
	rerollStroke.Transparency = 0.5
	rerollStroke.Parent = rerollButton

	-- Warning Label
	local warningLabel = Instance.new("TextLabel")
	warningLabel.Name = "WarningLabel"
	warningLabel.Size = UDim2.new(1, 0, 0, 40)
	warningLabel.Text = "⚠️ This will replace ALL current mutators!"
	warningLabel.Font = Enum.Font.Gotham
	warningLabel.TextSize = 12
	warningLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
	warningLabel.TextWrapped = true
	warningLabel.BackgroundTransparency = 1
	warningLabel.LayoutOrder = 4
	warningLabel.ZIndex = 53
	warningLabel.Parent = rightPanel
	components.WarningLabel = warningLabel

	-- Auto-Enchanter Section
	local autoEnchanterTitle = Instance.new("TextLabel")
	autoEnchanterTitle.Name = "AutoEnchanterTitle"
	autoEnchanterTitle.Size = UDim2.new(1, 0, 0, 30)
	autoEnchanterTitle.Text = "🤖 Auto-Enchanter"
	autoEnchanterTitle.Font = Enum.Font.GothamBold
	autoEnchanterTitle.TextSize = 18
	autoEnchanterTitle.TextColor3 = Color3.fromRGB(120, 180, 255)
	autoEnchanterTitle.BackgroundTransparency = 1
	autoEnchanterTitle.LayoutOrder = 5
	autoEnchanterTitle.ZIndex = 53
	autoEnchanterTitle.Parent = rightPanel
	components.AutoEnchanterTitle = autoEnchanterTitle

	-- Target Mutators Frame
	local targetMutatorsFrame = Instance.new("Frame")
	targetMutatorsFrame.Name = "TargetMutatorsFrame"
	targetMutatorsFrame.Size = UDim2.new(1, 0, 0, 100)
	targetMutatorsFrame.BackgroundColor3 = Color3.fromRGB(28, 32, 45)
	targetMutatorsFrame.BorderSizePixel = 0
	targetMutatorsFrame.LayoutOrder = 7
	targetMutatorsFrame.ZIndex = 53
	targetMutatorsFrame.Parent = rightPanel
	components.TargetMutatorsFrame = targetMutatorsFrame

	local targetMutatorsCorner = Instance.new("UICorner")
	targetMutatorsCorner.CornerRadius = UDim.new(0, 10)
	targetMutatorsCorner.Parent = targetMutatorsFrame

	local targetGradient = Instance.new("UIGradient")
	targetGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(32, 36, 50)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(24, 28, 40))
	}
	targetGradient.Rotation = 90
	targetGradient.Parent = targetMutatorsFrame

	local targetStroke = Instance.new("UIStroke")
	targetStroke.Color = Color3.fromRGB(40, 50, 70)
	targetStroke.Thickness = 1
	targetStroke.Transparency = 0.6
	targetStroke.Parent = targetMutatorsFrame

	local targetMutatorsLabel = Instance.new("TextLabel")
	targetMutatorsLabel.Name = "TargetMutatorsLabel"
	targetMutatorsLabel.Size = UDim2.new(1, 0, 0, 20)
	targetMutatorsLabel.Position = UDim2.new(0, 8, 0, 5)
	targetMutatorsLabel.Text = "Target Mutators:"
	targetMutatorsLabel.Font = Enum.Font.GothamBold
	targetMutatorsLabel.TextSize = 12
	targetMutatorsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	targetMutatorsLabel.TextXAlignment = Enum.TextXAlignment.Left
	targetMutatorsLabel.BackgroundTransparency = 1
	targetMutatorsLabel.ZIndex = 54
	targetMutatorsLabel.Parent = targetMutatorsFrame
	components.TargetMutatorsLabel = targetMutatorsLabel

	-- Mutator Selection ScrollFrame
	local mutatorSelectionFrame = Instance.new("ScrollingFrame")
	mutatorSelectionFrame.Name = "MutatorSelectionFrame"
	mutatorSelectionFrame.Size = UDim2.new(1, -16, 1, -30)
	mutatorSelectionFrame.Position = UDim2.new(0, 8, 0, 25)
	mutatorSelectionFrame.BackgroundTransparency = 1
	mutatorSelectionFrame.BorderSizePixel = 0
	mutatorSelectionFrame.ScrollBarThickness = 4
	mutatorSelectionFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
	mutatorSelectionFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	mutatorSelectionFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	mutatorSelectionFrame.ZIndex = 54
	mutatorSelectionFrame.Parent = targetMutatorsFrame
	components.MutatorSelectionFrame = mutatorSelectionFrame

	local mutatorSelectionLayout = Instance.new("UIListLayout")
	mutatorSelectionLayout.Padding = UDim.new(0, 3)
	mutatorSelectionLayout.Parent = mutatorSelectionFrame

	-- "Or Higher" Toggle Switch
	local orHigherFrame = Instance.new("Frame")
	orHigherFrame.Name = "OrHigherFrame"
	orHigherFrame.Size = UDim2.new(1, 0, 0, 25)
	orHigherFrame.BackgroundTransparency = 1
	orHigherFrame.LayoutOrder = 9
	orHigherFrame.ZIndex = 53
	orHigherFrame.Parent = rightPanel
	components.OrHigherFrame = orHigherFrame

	local orHigherSwitch = Instance.new("TextButton")
	orHigherSwitch.Name = "OrHigherSwitch"
	orHigherSwitch.Size = UDim2.new(0, 40, 0, 20)
	orHigherSwitch.Position = UDim2.new(0, 0, 0.5, -10)
	orHigherSwitch.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	orHigherSwitch.ZIndex = 54
	orHigherSwitch.Text = ""
	orHigherSwitch.Parent = orHigherFrame
	components.OrHigherSwitch = orHigherSwitch

	local switchCorner = Instance.new("UICorner")
	switchCorner.CornerRadius = UDim.new(0.5, 0)
	switchCorner.Parent = orHigherSwitch

	local switchKnob = Instance.new("Frame")
	switchKnob.Name = "SwitchKnob"
	switchKnob.Size = UDim2.new(0, 16, 0, 16)
	switchKnob.Position = UDim2.new(0, 2, 0.5, -8)
	switchKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	switchKnob.BorderSizePixel = 0
	switchKnob.ZIndex = 55
	switchKnob.Parent = orHigherSwitch
	components.OrHigherSwitchKnob = switchKnob

	local knobCorner = Instance.new("UICorner")
	knobCorner.CornerRadius = UDim.new(0.5, 0)
	knobCorner.Parent = switchKnob

	local orHigherLabel = Instance.new("TextLabel")
	orHigherLabel.Name = "OrHigherLabel"
	orHigherLabel.Size = UDim2.new(1, -50, 1, 0)
	orHigherLabel.Position = UDim2.new(0, 50, 0, 0)
	orHigherLabel.Text = "Stop on higher rarity"
	orHigherLabel.Font = Enum.Font.Gotham
	orHigherLabel.TextSize = 12
	orHigherLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
	orHigherLabel.TextXAlignment = Enum.TextXAlignment.Left
	orHigherLabel.BackgroundTransparency = 1
	orHigherLabel.ZIndex = 54
	orHigherLabel.Parent = orHigherFrame

	-- Auto-Enchant Controls
	local autoEnchantButton = Instance.new("TextButton")
	autoEnchantButton.Name = "AutoEnchantButton"
	autoEnchantButton.Size = UDim2.new(1, 0, 0, 40)
	autoEnchantButton.BackgroundColor3 = Color3.fromRGB(80, 170, 80)
	autoEnchantButton.Text = "▶ Start Auto-Enchanting"
	autoEnchantButton.Font = Enum.Font.GothamBold
	autoEnchantButton.TextSize = 16
	autoEnchantButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	autoEnchantButton.LayoutOrder = 10
	autoEnchantButton.ZIndex = 53
	autoEnchantButton.Parent = rightPanel
	components.AutoEnchantButton = autoEnchantButton

	local autoEnchantCorner = Instance.new("UICorner")
	autoEnchantCorner.CornerRadius = UDim.new(0, 10)
	autoEnchantCorner.Parent = autoEnchantButton

	local autoEnchantGradient = Instance.new("UIGradient")
	autoEnchantGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(90, 180, 90)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 160, 70))
	}
	autoEnchantGradient.Rotation = 90
	autoEnchantGradient.Parent = autoEnchantButton

	local autoEnchantStroke = Instance.new("UIStroke")
	autoEnchantStroke.Color = Color3.fromRGB(120, 200, 120)
	autoEnchantStroke.Thickness = 1
	autoEnchantStroke.Transparency = 0.5
	autoEnchantStroke.Parent = autoEnchantButton

	-- Stop Auto-Enchant Button
	local stopAutoEnchantButton = Instance.new("TextButton")
	stopAutoEnchantButton.Name = "StopAutoEnchantButton"
	stopAutoEnchantButton.Size = UDim2.new(1, 0, 0, 35)
	stopAutoEnchantButton.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
	stopAutoEnchantButton.Text = "⏹ Stop Auto-Enchanting"
	stopAutoEnchantButton.Font = Enum.Font.GothamBold
	stopAutoEnchantButton.TextSize = 14
	stopAutoEnchantButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	stopAutoEnchantButton.Visible = false
	stopAutoEnchantButton.LayoutOrder = 11
	stopAutoEnchantButton.ZIndex = 53
	stopAutoEnchantButton.Parent = rightPanel
	components.StopAutoEnchantButton = stopAutoEnchantButton

	local stopAutoEnchantCorner = Instance.new("UICorner")
	stopAutoEnchantCorner.CornerRadius = UDim.new(0, 10)
	stopAutoEnchantCorner.Parent = stopAutoEnchantButton

	local stopGradient = Instance.new("UIGradient")
	stopGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 80, 80)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 60, 60))
	}
	stopGradient.Rotation = 90
	stopGradient.Parent = stopAutoEnchantButton

	-- Progress Label
	local progressLabel = Instance.new("TextLabel")
	progressLabel.Name = "ProgressLabel"
	progressLabel.Size = UDim2.new(1, 0, 0, 25)
	progressLabel.Text = ""
	progressLabel.Font = Enum.Font.Gotham
	progressLabel.TextSize = 11
	progressLabel.TextColor3 = Color3.fromRGB(180, 200, 220)
	progressLabel.TextWrapped = true
	progressLabel.BackgroundTransparency = 1
	progressLabel.LayoutOrder = 12
	progressLabel.ZIndex = 53
	progressLabel.Parent = rightPanel
	components.ProgressLabel = progressLabel

	-- "Match Any" (OR) / "Match All" (AND) Toggle Switch
	local matchModeFrame = Instance.new("Frame")
	matchModeFrame.Name = "MatchModeFrame"
	matchModeFrame.Size = UDim2.new(1, 0, 0, 25)
	matchModeFrame.BackgroundTransparency = 1
	matchModeFrame.LayoutOrder = 8
	matchModeFrame.ZIndex = 53
	matchModeFrame.Parent = rightPanel
	components.MatchModeFrame = matchModeFrame

	local matchModeSwitch = Instance.new("TextButton")
	matchModeSwitch.Name = "MatchModeSwitch"
	matchModeSwitch.Size = UDim2.new(0, 40, 0, 20)
	matchModeSwitch.Position = UDim2.new(0, 0, 0.5, -10)
	matchModeSwitch.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	matchModeSwitch.ZIndex = 54
	matchModeSwitch.Text = ""
	matchModeSwitch.Parent = matchModeFrame
	components.MatchModeSwitch = matchModeSwitch

	local matchSwitchCorner = Instance.new("UICorner")
	matchSwitchCorner.CornerRadius = UDim.new(0.5, 0)
	matchSwitchCorner.Parent = matchModeSwitch

	local matchSwitchKnob = Instance.new("Frame")
	matchSwitchKnob.Name = "MatchSwitchKnob"
	matchSwitchKnob.Size = UDim2.new(0, 16, 0, 16)
	matchSwitchKnob.Position = UDim2.new(0, 2, 0.5, -8)
	matchSwitchKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	matchSwitchKnob.BorderSizePixel = 0
	matchSwitchKnob.ZIndex = 55
	matchSwitchKnob.Parent = matchModeSwitch
	components.MatchModeSwitchKnob = matchSwitchKnob

	local matchKnobCorner = Instance.new("UICorner")
	matchKnobCorner.CornerRadius = UDim.new(0.5, 0)
	matchKnobCorner.Parent = matchSwitchKnob

	local matchModeLabel = Instance.new("TextLabel")
	matchModeLabel.Name = "MatchModeLabel"
	matchModeLabel.Size = UDim2.new(1, -50, 1, 0)
	matchModeLabel.Position = UDim2.new(0, 50, 0, 0)
	matchModeLabel.Text = "Match All (AND)"
	matchModeLabel.Font = Enum.Font.Gotham
	matchModeLabel.TextSize = 12
	matchModeLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
	matchModeLabel.TextXAlignment = Enum.TextXAlignment.Left
	matchModeLabel.BackgroundTransparency = 1
	matchModeLabel.ZIndex = 54
	matchModeLabel.Parent = matchModeFrame

	-- Adaptive Layout
	if isMobile then
		-- Use a vertical list layout for the main content
		local contentLayout = Instance.new("UIListLayout")
		contentLayout.Padding = UDim.new(0, 15)
		contentLayout.FillDirection = Enum.FillDirection.Vertical
		contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
		contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		contentLayout.Parent = contentFrame

		-- Make panels full-width and auto-height
		leftPanel.Size = UDim2.new(1, 0, 0, 1) -- Height is irrelevant due to AutomaticSize
		leftPanel.AutomaticSize = Enum.AutomaticSize.Y
		leftPanel.LayoutOrder = 1

		rightPanel.Size = UDim2.new(1, 0, 0, 1) -- Height is irrelevant due to AutomaticSize
		rightPanel.AutomaticSize = Enum.AutomaticSize.Y
		rightPanel.LayoutOrder = 2

		-- Make the main frame wider for mobile screens
		mainFrame.Size = UDim2.new(0.95, 0, 0.9, 0)
		mainFrame.Position = UDim2.new(0.025, 0, 0.05, 0)
	else
		-- Desktop layout (the original manual positioning)
		leftPanel.Size = UDim2.new(0.6, -10, 1, 0)
		leftPanel.Position = UDim2.new(0, 0, 0, 0)

		rightPanel.Size = UDim2.new(0.4, -10, 1, 0)
		rightPanel.Position = UDim2.new(0.6, 10, 0, 0)
	end

	-- === ITEM SELECTION POPUP ===
	local itemSelectionPopup = Instance.new("Frame")
	itemSelectionPopup.Name = "ItemSelectionPopup"
	itemSelectionPopup.Size = UDim2.new(0, 600, 0, 500)
	itemSelectionPopup.Position = UDim2.new(0.5, -300, 0.5, -250)
	itemSelectionPopup.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
	itemSelectionPopup.BorderSizePixel = 0
	itemSelectionPopup.Visible = false
	itemSelectionPopup.ZIndex = 100
	itemSelectionPopup.Parent = screenGui
	components.ItemSelectionPopup = itemSelectionPopup

	local popupCorner = Instance.new("UICorner")
	popupCorner.CornerRadius = UDim.new(0, 16)
	popupCorner.Parent = itemSelectionPopup

	local popupGradient = Instance.new("UIGradient")
	popupGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 24, 35)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(15, 18, 28)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 12, 18))
	}
	popupGradient.Rotation = 135
	popupGradient.Parent = itemSelectionPopup

	-- Popup Title Bar
	local popupTitleBar = Instance.new("Frame")
	popupTitleBar.Name = "PopupTitleBar"
	popupTitleBar.Size = UDim2.new(1, 0, 0, 60)
	popupTitleBar.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
	popupTitleBar.BorderSizePixel = 0
	popupTitleBar.ZIndex = 101
	popupTitleBar.Parent = itemSelectionPopup

	local popupTitleCorner = Instance.new("UICorner")
	popupTitleCorner.CornerRadius = UDim.new(0, 16)
	popupTitleCorner.Parent = popupTitleBar

	local popupTitleGradient = Instance.new("UIGradient")
	popupTitleGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 45, 75)),
		ColorSequenceKeypoint.new(0.3, Color3.fromRGB(40, 35, 60)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 45))
	}
	popupTitleGradient.Rotation = 110
	popupTitleGradient.Parent = popupTitleBar

	-- Popup title
	local popupTitle = Instance.new("TextLabel")
	popupTitle.Name = "PopupTitle"
	popupTitle.Size = UDim2.new(1, -60, 1, 0)
	popupTitle.Position = UDim2.new(0, 20, 0, 0)
	popupTitle.Text = "📦 Select Item to Enchant"
	popupTitle.Font = Enum.Font.GothamBold
	popupTitle.TextSize = 20
	popupTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	popupTitle.TextXAlignment = Enum.TextXAlignment.Left
	popupTitle.TextYAlignment = Enum.TextYAlignment.Center
	popupTitle.BackgroundTransparency = 1
	popupTitle.ZIndex = 102
	popupTitle.Parent = popupTitleBar
	components.PopupTitle = popupTitle

	-- Popup close button
	local popupCloseButton = Instance.new("TextButton")
	popupCloseButton.Name = "PopupCloseButton"
	popupCloseButton.Size = UDim2.new(0, 40, 0, 40)
	popupCloseButton.Position = UDim2.new(1, -50, 0.5, -20)
	popupCloseButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
	popupCloseButton.Text = "✕"
	popupCloseButton.Font = Enum.Font.GothamBold
	popupCloseButton.TextSize = 16
	popupCloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	popupCloseButton.ZIndex = 102
	popupCloseButton.Parent = popupTitleBar
	components.PopupCloseButton = popupCloseButton

	local popupCloseCorner = Instance.new("UICorner")
	popupCloseCorner.CornerRadius = UDim.new(0, 20)
	popupCloseCorner.Parent = popupCloseButton

	-- Search Bar
	local searchBox = Instance.new("TextBox")
	searchBox.Name = "SearchBox"
	searchBox.Size = UDim2.new(1, -40, 0, 35)
	searchBox.Position = UDim2.new(0, 20, 0, 70)
	searchBox.PlaceholderText = "🔍 Search items..."
	searchBox.Text = ""
	searchBox.Font = Enum.Font.Gotham
	searchBox.TextSize = 16
	searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	searchBox.BackgroundColor3 = Color3.fromRGB(28, 32, 45)
	searchBox.BorderSizePixel = 0
	searchBox.ClearTextOnFocus = false
	searchBox.ZIndex = 101
	searchBox.Parent = itemSelectionPopup
	components.SearchBox = searchBox

	local searchCorner = Instance.new("UICorner")
	searchCorner.CornerRadius = UDim.new(0, 10)
	searchCorner.Parent = searchBox

	-- Item Selection List
	local itemSelectionFrame = Instance.new("ScrollingFrame")
	itemSelectionFrame.Name = "ItemSelectionFrame"
	itemSelectionFrame.Size = UDim2.new(1, -40, 1, -125)
	itemSelectionFrame.Position = UDim2.new(0, 20, 0, 115)
	itemSelectionFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
	itemSelectionFrame.BorderSizePixel = 0
	itemSelectionFrame.ScrollBarThickness = 8
	itemSelectionFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
	itemSelectionFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	itemSelectionFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	itemSelectionFrame.ZIndex = 101
	itemSelectionFrame.Parent = itemSelectionPopup
	components.ItemSelectionFrame = itemSelectionFrame

	local selectionCorner = Instance.new("UICorner")
	selectionCorner.CornerRadius = UDim.new(0, 10)
	selectionCorner.Parent = itemSelectionFrame

	local selectionLayout = Instance.new("UIGridLayout")
	selectionLayout.CellPadding = UDim2.new(0, 5, 0, 5)
	selectionLayout.CellSize = UDim2.new(0.5, -3, 0, 50)
	selectionLayout.Parent = itemSelectionFrame

	components.UpdateScale = function()
		uiScale.Scale = calculateUIScale()
	end

	return components
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
	entryLabel.Font = Enum.Font.Gotham
	entryLabel.TextSize = 12
	entryLabel.TextColor3 = mutatorConfig.Color or Color3.fromRGB(255, 255, 255)
	entryLabel.TextXAlignment = Enum.TextXAlignment.Left
	entryLabel.BackgroundTransparency = 1
	entryLabel.ZIndex = 55
	entryLabel.Parent = entry
	
	return entry
end

-- Create item entry for selection
function EnchanterUI.CreateItemEntry(itemData)
	local entry = Instance.new("TextButton")
	entry.Name = itemData.itemName .. "Entry"
	entry.Size = UDim2.new(1, 0, 1, 0)
	entry.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
	entry.BorderSizePixel = 0
	entry.ZIndex = 102
	
	local entryCorner = Instance.new("UICorner")
	entryCorner.CornerRadius = UDim.new(0, 8)
	entryCorner.Parent = entry
	
	local entryGradient = Instance.new("UIGradient")
	entryGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 45, 60)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 35, 50))
	}
	entryGradient.Rotation = 90
	entryGradient.Parent = entry
	
	local ItemValueCalculator = require(game.ReplicatedStorage.Shared.Modules.ItemValueCalculator)
	local mutationNames = ItemValueCalculator.GetMutationNames(itemData.itemInstance)
	
	local displayName = itemData.itemName
	if #mutationNames > 0 then
		displayName = table.concat(mutationNames, " ") .. " " .. itemData.itemName
	end
	
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0.7, 0, 0.6, 0)
	nameLabel.Position = UDim2.new(0, 8, 0, 0)
	nameLabel.Text = displayName
	nameLabel.Font = Enum.Font.Gotham
	nameLabel.TextSize = 11
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.TextYAlignment = Enum.TextYAlignment.Center
	nameLabel.BackgroundTransparency = 1
	nameLabel.ZIndex = 103
	nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
	nameLabel.Parent = entry
	
	local NumberFormatter = require(game.ReplicatedStorage.Shared.Modules.NumberFormatter)
	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(0.3, -8, 0.6, 0)
	valueLabel.Position = UDim2.new(0.7, 0, 0, 0)
	valueLabel.Text = "R$ " .. NumberFormatter.FormatCurrency(itemData.value)
	valueLabel.Font = Enum.Font.GothamBold
	valueLabel.TextSize = 10
	valueLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.TextYAlignment = Enum.TextYAlignment.Center
	valueLabel.BackgroundTransparency = 1
	valueLabel.ZIndex = 103
	valueLabel.Parent = entry
	
	local size = itemData.itemInstance:GetAttribute("Size") or 1
	local sizeLabel = Instance.new("TextLabel")
	sizeLabel.Size = UDim2.new(1, -8, 0.4, 0)
	sizeLabel.Position = UDim2.new(0, 8, 0.6, 0)
	sizeLabel.Text = "Size: " .. NumberFormatter.FormatSize(size)
	sizeLabel.Font = Enum.Font.Gotham
	sizeLabel.TextSize = 9
	sizeLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	sizeLabel.TextXAlignment = Enum.TextXAlignment.Left
	sizeLabel.TextYAlignment = Enum.TextYAlignment.Center
	sizeLabel.BackgroundTransparency = 1
	sizeLabel.ZIndex = 103
	sizeLabel.Parent = entry
	
	return entry
end

-- Create mutator selection checkbox entry with modern styling
function EnchanterUI.CreateMutatorCheckboxEntry(mutatorName, mutatorConfig, isSelected)
	local entry = Instance.new("Frame")
	entry.Name = mutatorName .. "CheckboxEntry"
	entry.Size = UDim2.new(1, -8, 0, 24)
	entry.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
	entry.BorderSizePixel = 0
	entry.ZIndex = 55
	
	local entryCorner = Instance.new("UICorner")
	entryCorner.CornerRadius = UDim.new(0, 6)
	entryCorner.Parent = entry
	
	local entryGradient = Instance.new("UIGradient")
	entryGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 45, 60)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 35, 50))
	}
	entryGradient.Rotation = 90
	entryGradient.Parent = entry
	
	local entryStroke = Instance.new("UIStroke")
	entryStroke.Color = Color3.fromRGB(50, 60, 80)
	entryStroke.Thickness = 1
	entryStroke.Transparency = 0.7
	entryStroke.Parent = entry
	
	local checkbox = Instance.new("TextButton")
	checkbox.Name = "Checkbox"
	checkbox.Size = UDim2.new(0, 18, 0, 18)
	checkbox.Position = UDim2.new(0, 4, 0.5, -9)
	checkbox.BackgroundColor3 = isSelected and Color3.fromRGB(80, 170, 80) or Color3.fromRGB(45, 50, 65)
	checkbox.BorderSizePixel = 0
	checkbox.Text = isSelected and "✓" or ""
	checkbox.Font = Enum.Font.GothamBold
	checkbox.TextSize = 11
	checkbox.TextColor3 = Color3.fromRGB(255, 255, 255)
	checkbox.ZIndex = 56
	checkbox.Parent = entry
	
	local checkboxCorner = Instance.new("UICorner")
	checkboxCorner.CornerRadius = UDim.new(0, 4)
	checkboxCorner.Parent = checkbox
	
	local checkboxGradient = Instance.new("UIGradient")
	if isSelected then
		checkboxGradient.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(90, 180, 90)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 160, 70))
		}
	else
		checkboxGradient.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(55, 60, 75)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 45, 60))
		}
	end
	checkboxGradient.Rotation = 90
	checkboxGradient.Parent = checkbox
	
	local checkboxStroke = Instance.new("UIStroke")
	checkboxStroke.Color = isSelected and Color3.fromRGB(120, 200, 120) or Color3.fromRGB(70, 80, 100)
	checkboxStroke.Thickness = 1
	checkboxStroke.Transparency = 0.5
	checkboxStroke.Parent = checkbox
	
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.Size = UDim2.new(1, -60, 1, 0)
	nameLabel.Position = UDim2.new(0, 26, 0, 0)
	nameLabel.Text = mutatorName
	nameLabel.Font = Enum.Font.GothamMedium
	nameLabel.TextSize = 11
	nameLabel.TextColor3 = mutatorConfig.Color or Color3.fromRGB(255, 255, 255)
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.TextYAlignment = Enum.TextYAlignment.Center
	nameLabel.BackgroundTransparency = 1
	nameLabel.ZIndex = 56
	nameLabel.Parent = entry
	
	local chanceContainer = Instance.new("Frame")
	chanceContainer.Name = "ChanceContainer"
	chanceContainer.Size = UDim2.new(0, 30, 0, 14)
	chanceContainer.Position = UDim2.new(1, -34, 0.5, -7)
	chanceContainer.BackgroundColor3 = Color3.fromRGB(60, 80, 120)
	chanceContainer.BorderSizePixel = 0
	chanceContainer.ZIndex = 56
	chanceContainer.Parent = entry
	
	local chanceCorner = Instance.new("UICorner")
	chanceCorner.CornerRadius = UDim.new(0.5, 0)
	chanceCorner.Parent = chanceContainer
	
	local chanceGradient = Instance.new("UIGradient")
	chanceGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(70, 90, 130)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 70, 110))
	}
	chanceGradient.Rotation = 90
	chanceGradient.Parent = chanceContainer
	
	local chanceLabel = Instance.new("TextLabel")
	chanceLabel.Name = "ChanceLabel"
	chanceLabel.Size = UDim2.new(1, 0, 1, 0)
	chanceLabel.Position = UDim2.new(0, 0, 0, 0)
	chanceLabel.Text = mutatorConfig.Chance .. "%"
	chanceLabel.Font = Enum.Font.GothamBold
	chanceLabel.TextSize = 8
	chanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	chanceLabel.TextXAlignment = Enum.TextXAlignment.Center
	chanceLabel.TextYAlignment = Enum.TextYAlignment.Center
	chanceLabel.BackgroundTransparency = 1
	chanceLabel.ZIndex = 57
	chanceLabel.Parent = chanceContainer
	
	return entry, checkbox
end

return EnchanterUI 