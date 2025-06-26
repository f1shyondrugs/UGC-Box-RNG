-- CollectionUI.lua
-- Comprehensive item collection index organized by crates

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Shared = ReplicatedStorage.Shared
local GameConfig = require(Shared.Modules.GameConfig)
local ItemValueCalculator = require(Shared.Modules.ItemValueCalculator)

local CollectionUI = {}

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

function CollectionUI.Create(parentGui)
	local components = {}
	
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "CollectionGui"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = parentGui
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	components.ScreenGui = screenGui

	local uiScale = Instance.new("UIScale")
	uiScale.Scale = calculateUIScale()
	uiScale.Parent = screenGui
	components.UIScale = uiScale

	-- Toggle Button
	local toggleButton = Instance.new("TextButton")
	toggleButton.Name = "CollectionToggleButton"
	toggleButton.Size = UDim2.new(0, 50, 0, 50)
	toggleButton.Position = UDim2.new(0, 15, 0.5, 30) -- Below inventory button
	toggleButton.BackgroundColor3 = Color3.fromRGB(61, 33, 88)
	toggleButton.BorderSizePixel = 0
	toggleButton.Text = "📚"
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

	-- Main Frame (with margins from screen edges)
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "CollectionMainFrame"
	mainFrame.Size = UDim2.new(1, -60, 1, -60) -- Add 30px margin on all sides
	mainFrame.Position = UDim2.new(0, 30, 0, 30) -- Center with 30px offset
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
	title.Size = UDim2.new(1, -120, 1, 0)
	title.Position = UDim2.new(0, 20, 0, 0)
	title.Text = "📚 ITEM COLLECTION"
	title.Font = Enum.Font.SourceSansBold
	title.TextSize = 32
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.BackgroundTransparency = 1
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.ZIndex = 52
	title.Parent = titleBar
	components.Title = title

	-- Progress Info
	local progressInfo = Instance.new("TextLabel")
	progressInfo.Name = "ProgressInfo"
	progressInfo.Size = UDim2.new(0, 300, 0, 25)
	progressInfo.Position = UDim2.new(0, 20, 1, -30)
	progressInfo.Text = "Discovered: 0/100 items (0%)"
	progressInfo.Font = Enum.Font.SourceSans
	progressInfo.TextSize = 16
	progressInfo.TextColor3 = Color3.fromRGB(200, 200, 200)
	progressInfo.BackgroundTransparency = 1
	progressInfo.TextXAlignment = Enum.TextXAlignment.Left
	progressInfo.ZIndex = 52
	progressInfo.Parent = titleBar
	components.ProgressInfo = progressInfo

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

	-- Crate Tabs Container (Horizontal Scrolling Frame)
	local tabsContainer = Instance.new("ScrollingFrame")
	tabsContainer.Name = "TabsContainer"
	tabsContainer.Size = UDim2.new(1, 0, 0, 60) -- Made slightly taller for better visibility
	tabsContainer.Position = UDim2.new(0, 0, 0, 0)
	tabsContainer.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
	tabsContainer.BackgroundTransparency = 0.3
	tabsContainer.BorderSizePixel = 0
	tabsContainer.CanvasSize = UDim2.new(0, 0, 0, 0) -- Will be set dynamically
	tabsContainer.AutomaticCanvasSize = Enum.AutomaticSize.X -- Horizontal auto-sizing
	tabsContainer.ScrollBarThickness = 6
	tabsContainer.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
	tabsContainer.HorizontalScrollBarInset = Enum.ScrollBarInset.ScrollBar
	tabsContainer.VerticalScrollBarInset = Enum.ScrollBarInset.None
	tabsContainer.ScrollingDirection = Enum.ScrollingDirection.X -- Only horizontal scrolling
	tabsContainer.ZIndex = 52
	tabsContainer.Parent = contentFrame
	
	-- Add rounded corners to tabs container
	local tabsContainerCorner = Instance.new("UICorner")
	tabsContainerCorner.CornerRadius = UDim.new(0, 10)
	tabsContainerCorner.Parent = tabsContainer
	
	-- Add padding to tabs container
	local tabsContainerPadding = Instance.new("UIPadding")
	tabsContainerPadding.PaddingLeft = UDim.new(0, 10)
	tabsContainerPadding.PaddingRight = UDim.new(0, 10)
	tabsContainerPadding.PaddingTop = UDim.new(0, 8)
	tabsContainerPadding.PaddingBottom = UDim.new(0, 8)
	tabsContainerPadding.Parent = tabsContainer

	local tabsLayout = Instance.new("UIListLayout")
	tabsLayout.FillDirection = Enum.FillDirection.Horizontal
	tabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	tabsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	tabsLayout.Padding = UDim.new(0, 8) -- Increased padding between tabs
	tabsLayout.Parent = tabsContainer

	-- Items Display Area
	local itemsContainer = Instance.new("ScrollingFrame")
	itemsContainer.Name = "ItemsContainer"
	itemsContainer.Size = UDim2.new(1, 0, 1, -80) -- Adjusted for new tabs height
	itemsContainer.Position = UDim2.new(0, 0, 0, 70) -- Adjusted for new tabs height
	itemsContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	itemsContainer.BackgroundTransparency = 0.3
	itemsContainer.BorderSizePixel = 0
	itemsContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
	itemsContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
	itemsContainer.ScrollBarThickness = 8
	itemsContainer.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
	itemsContainer.ZIndex = 52
	itemsContainer.Parent = contentFrame
	components.ItemsContainer = itemsContainer

	local itemsCorner = Instance.new("UICorner")
	itemsCorner.CornerRadius = UDim.new(0, 12)
	itemsCorner.Parent = itemsContainer
	
	-- Add padding to items container
	local itemsContainerPadding = Instance.new("UIPadding")
	itemsContainerPadding.PaddingLeft = UDim.new(0, 15)
	itemsContainerPadding.PaddingRight = UDim.new(0, 15)
	itemsContainerPadding.PaddingTop = UDim.new(0, 15)
	itemsContainerPadding.PaddingBottom = UDim.new(0, 15)
	itemsContainerPadding.Parent = itemsContainer

	-- Use UIGridLayout for items
	local itemsLayout = Instance.new("UIGridLayout")
	itemsLayout.CellSize = UDim2.new(0, 200, 0, 120)
	itemsLayout.CellPadding = UDim2.new(0, 12, 0, 12) -- Slightly increased padding
	itemsLayout.SortOrder = Enum.SortOrder.Name
	itemsLayout.Parent = itemsContainer

	-- Tooltip Frame (initially hidden)
	local tooltip = Instance.new("Frame")
	tooltip.Name = "Tooltip"
	tooltip.Size = UDim2.new(0, 300, 0, 250)
	tooltip.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
	tooltip.BorderSizePixel = 0
	tooltip.Visible = false
	tooltip.ZIndex = 100
	tooltip.Parent = screenGui
	components.Tooltip = tooltip

	local tooltipCorner = Instance.new("UICorner")
	tooltipCorner.CornerRadius = UDim.new(0, 8)
	tooltipCorner.Parent = tooltip

	local tooltipStroke = Instance.new("UIStroke")
	tooltipStroke.Color = Color3.fromRGB(100, 100, 120)
	tooltipStroke.Thickness = 2
	tooltipStroke.Parent = tooltip

	local tooltipTitle = Instance.new("TextLabel")
	tooltipTitle.Name = "TooltipTitle"
	tooltipTitle.Size = UDim2.new(1, -20, 0, 30)
	tooltipTitle.Position = UDim2.new(0, 10, 0, 5)
	tooltipTitle.Text = "Item Name"
	tooltipTitle.Font = Enum.Font.SourceSansBold
	tooltipTitle.TextSize = 18
	tooltipTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	tooltipTitle.BackgroundTransparency = 1
	tooltipTitle.TextXAlignment = Enum.TextXAlignment.Left
	tooltipTitle.ZIndex = 101
	tooltipTitle.Parent = tooltip
	components.TooltipTitle = tooltipTitle

	local tooltipContent = Instance.new("TextLabel")
	tooltipContent.Name = "TooltipContent"
	tooltipContent.Size = UDim2.new(1, -20, 1, -45)
	tooltipContent.Position = UDim2.new(0, 10, 0, 35)
	tooltipContent.Text = "Collection details here..."
	tooltipContent.Font = Enum.Font.SourceSans
	tooltipContent.TextSize = 14
	tooltipContent.TextColor3 = Color3.fromRGB(220, 220, 220)
	tooltipContent.BackgroundTransparency = 1
	tooltipContent.TextXAlignment = Enum.TextXAlignment.Left
	tooltipContent.TextYAlignment = Enum.TextYAlignment.Top
	tooltipContent.TextWrapped = true
	tooltipContent.ZIndex = 101
		tooltipContent.Parent = tooltip
	components.TooltipContent = tooltipContent
	components.TabsContainer = tabsContainer
	
	-- Update scale when screen size changes
	local function updateScale()
		uiScale.Scale = calculateUIScale()
	end
	
	-- Connect to viewport size changes
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
	components.UpdateScale = updateScale
	
	return components
end

-- Create tab button for crate
function CollectionUI.CreateCrateTab(crateName, isActive)
	local tab = Instance.new("TextButton")
	tab.Name = crateName .. "Tab"
	tab.Size = UDim2.new(0, 140, 0, 44) -- Fixed height for horizontal scrolling
	tab.BackgroundColor3 = isActive and Color3.fromRGB(70, 60, 90) or Color3.fromRGB(45, 50, 65)
	tab.Text = crateName
	tab.Font = Enum.Font.SourceSansBold
	tab.TextSize = 15
	tab.TextColor3 = Color3.fromRGB(255, 255, 255)
	tab.BorderSizePixel = 0
	tab.ZIndex = 53
	
	-- Add padding to tab text
	local tabPadding = Instance.new("UIPadding")
	tabPadding.PaddingLeft = UDim.new(0, 12)
	tabPadding.PaddingRight = UDim.new(0, 12)
	tabPadding.PaddingTop = UDim.new(0, 6)
	tabPadding.PaddingBottom = UDim.new(0, 6)
	tabPadding.Parent = tab
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = tab
	
	-- Enhanced styling for active/inactive states
	if isActive then
		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(150, 120, 220)
		stroke.Thickness = 2
		stroke.Parent = tab
		
		-- Add gradient for active tab
		local gradient = Instance.new("UIGradient")
		gradient.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 70, 100)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 50, 80))
		}
		gradient.Rotation = 90
		gradient.Parent = tab
	else
		-- Add subtle stroke for inactive tabs
		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(80, 85, 100)
		stroke.Thickness = 1
		stroke.Transparency = 0.5
		stroke.Parent = tab
	end
	
	return tab
end

-- Calculate drop chance for an item across all crates
local function calculateDropChance(itemName)
	local totalChance = 0
	
	-- Check all crates for this item
	for crateName, crateConfig in pairs(GameConfig.Boxes) do
		if crateConfig.Rewards and crateConfig.Rewards[itemName] then
			totalChance = totalChance + crateConfig.Rewards[itemName]
		end
	end
	
	return totalChance
end

-- Format drop chance for display
local function formatDropChance(chance)
	if chance >= 10 then
		return string.format("%.1f%%", chance)
	elseif chance >= 1 then
		return string.format("%.2f%%", chance)
	elseif chance >= 0.1 then
		return string.format("%.3f%%", chance)
	elseif chance >= 0.01 then
		return string.format("%.4f%%", chance)
	elseif chance >= 0.001 then
		return string.format("%.5f%%", chance)
	else
		return string.format("%.6f%%", chance)
	end
end

-- Create item card for collection display
function CollectionUI.CreateItemCard(itemName, itemConfig, collectionData)
	local isDiscovered = collectionData and collectionData.Discovered or false
	local maxSize = collectionData and collectionData.MaxSize or 0
	local mutations = collectionData and collectionData.Mutations or {}
	
	local card = Instance.new("Frame")
	card.Name = itemName .. "Card"
	card.Size = UDim2.new(0, 200, 0, 120)
	card.BackgroundColor3 = isDiscovered and Color3.fromRGB(35, 40, 55) or Color3.fromRGB(25, 25, 35)
	card.BorderSizePixel = 0
	card.ZIndex = 53
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = card
	
	-- Rarity border
	local rarityConfig = GameConfig.Rarities[itemConfig.Rarity]
	local stroke = Instance.new("UIStroke")
	stroke.Color = isDiscovered and (rarityConfig and rarityConfig.Color or Color3.fromRGB(100, 100, 100)) or Color3.fromRGB(60, 60, 60)
	stroke.Thickness = isDiscovered and 2 or 1
	stroke.Transparency = isDiscovered and 0.3 or 0.7
	stroke.Parent = card
	
	-- Item preview or placeholder
	local preview = Instance.new("Frame")
	preview.Name = "Preview"
	preview.Size = UDim2.new(0, 60, 0, 60)
	preview.Position = UDim2.new(0, 10, 0, 10)
	preview.BackgroundColor3 = isDiscovered and Color3.fromRGB(45, 50, 65) or Color3.fromRGB(35, 35, 45)
	preview.BorderSizePixel = 0
	preview.ZIndex = 54
	preview.Parent = card
	
	local previewCorner = Instance.new("UICorner")
	previewCorner.CornerRadius = UDim.new(0, 8)
	previewCorner.Parent = preview
	
	-- Question mark for undiscovered items
	if not isDiscovered then
		local questionMark = Instance.new("TextLabel")
		questionMark.Size = UDim2.new(1, 0, 1, 0)
		questionMark.Text = "?"
		questionMark.Font = Enum.Font.SourceSansBold
		questionMark.TextSize = 32
		questionMark.TextColor3 = Color3.fromRGB(100, 100, 100)
		questionMark.BackgroundTransparency = 1
		questionMark.ZIndex = 55
		questionMark.Parent = preview
	end
	
	-- Item info
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.Size = UDim2.new(1, -85, 0, 20)
	nameLabel.Position = UDim2.new(0, 75, 0, 10)
	nameLabel.Text = isDiscovered and itemName or "???"
	nameLabel.Font = Enum.Font.SourceSansBold
	nameLabel.TextSize = 14
	nameLabel.TextColor3 = isDiscovered and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(120, 120, 120)
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
	nameLabel.ZIndex = 54
	nameLabel.Parent = card
	
	-- Rarity label
	local rarityLabel = Instance.new("TextLabel")
	rarityLabel.Name = "RarityLabel"
	rarityLabel.Size = UDim2.new(1, -85, 0, 16)
	rarityLabel.Position = UDim2.new(0, 75, 0, 30)
	rarityLabel.Text = isDiscovered and itemConfig.Rarity or "???"
	rarityLabel.Font = Enum.Font.SourceSans
	rarityLabel.TextSize = 12
	rarityLabel.TextColor3 = isDiscovered and (rarityConfig and rarityConfig.Color or Color3.fromRGB(200, 200, 200)) or Color3.fromRGB(100, 100, 100)
	rarityLabel.BackgroundTransparency = 1
	rarityLabel.TextXAlignment = Enum.TextXAlignment.Left
	rarityLabel.ZIndex = 54
	rarityLabel.Parent = card
	
	-- Collection status
	local statusLabel = Instance.new("TextLabel")
	statusLabel.Name = "StatusLabel"
	statusLabel.Size = UDim2.new(1, -85, 0, 16)
	statusLabel.Position = UDim2.new(0, 75, 0, 48)
	
	if isDiscovered then
		local mutationCount = 0
		if mutations and next(mutations) then
			for _ in pairs(mutations) do
				mutationCount = mutationCount + 1
			end
		end
		
		statusLabel.Text = string.format("Max Size: %.2f | Variants: %d", maxSize, mutationCount)
		statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
	else
		statusLabel.Text = "Not discovered"
		statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
	end
	statusLabel.Font = Enum.Font.SourceSans
	statusLabel.TextSize = 11
	statusLabel.BackgroundTransparency = 1
	statusLabel.TextXAlignment = Enum.TextXAlignment.Left
	statusLabel.ZIndex = 54
	statusLabel.Parent = card
	
	-- Value label
	local valueLabel = Instance.new("TextLabel")
	valueLabel.Name = "ValueLabel"
	valueLabel.Size = UDim2.new(1, -85, 0, 16)
	valueLabel.Position = UDim2.new(0, 75, 0, 66)
	if isDiscovered then
		local value = ItemValueCalculator.GetFormattedValue(itemConfig, nil, 1)
		valueLabel.Text = "Base Value: " .. value
		valueLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	else
		valueLabel.Text = "Value: ???"
		valueLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
	end
	valueLabel.Font = Enum.Font.SourceSans
	valueLabel.TextSize = 11
	valueLabel.BackgroundTransparency = 1
	valueLabel.TextXAlignment = Enum.TextXAlignment.Left
	valueLabel.ZIndex = 54
	valueLabel.Parent = card
	
	-- Drop chance label
	local dropChanceLabel = Instance.new("TextLabel")
	dropChanceLabel.Name = "DropChanceLabel"
	dropChanceLabel.Size = UDim2.new(1, -85, 0, 16)
	dropChanceLabel.Position = UDim2.new(0, 75, 0, 84)
	
	local dropChance = calculateDropChance(itemName)
	if dropChance > 0 then
		dropChanceLabel.Text = "Drop Rate: " .. formatDropChance(dropChance)
		dropChanceLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
	else
		dropChanceLabel.Text = "Drop Rate: Unknown"
		dropChanceLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
	end
	dropChanceLabel.Font = Enum.Font.SourceSans
	dropChanceLabel.TextSize = 11
	dropChanceLabel.BackgroundTransparency = 1
	dropChanceLabel.TextXAlignment = Enum.TextXAlignment.Left
	dropChanceLabel.ZIndex = 54
	dropChanceLabel.Parent = card
	
	-- Progress indicator for discovered items
	if isDiscovered then
		local progressBar = Instance.new("Frame")
		progressBar.Name = "ProgressBar"
		progressBar.Size = UDim2.new(1, -20, 0, 4)
		progressBar.Position = UDim2.new(0, 10, 1, -10)
		progressBar.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
		progressBar.BorderSizePixel = 0
		progressBar.ZIndex = 54
		progressBar.Parent = card
		
		local progressFill = Instance.new("Frame")
		progressFill.Name = "ProgressFill"
		-- Calculate mutation count for progress bar
		local mutationCount = 0
		if mutations then
			for _ in pairs(mutations) do
				mutationCount = mutationCount + 1
			end
		end
		-- Use math.max to ensure we don't divide by 0, and clamp between 0 and 1
		local progressPercent = math.min(math.max(mutationCount / 7, 0), 1) -- Max 7 mutations
		progressFill.Size = UDim2.new(progressPercent, 0, 1, 0)
		progressFill.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
		progressFill.BorderSizePixel = 0
		progressFill.ZIndex = 55
		progressFill.Parent = progressBar
	end
	
	return card
end

return CollectionUI 