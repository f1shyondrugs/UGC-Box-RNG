-- CollectionUI.lua
-- Comprehensive item collection index organized by crates

local CollectionUI = {}

local ItemValueCalculator = require(game.ReplicatedStorage.Shared.Modules.ItemValueCalculator)
local GameConfig = require(game.ReplicatedStorage.Shared.Modules.GameConfig)

function CollectionUI.Create(parent)
	local components = {}

	-- Main ScreenGui
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "CollectionGui"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	components.ScreenGui = screenGui

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

	-- Main Frame
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "CollectionMainFrame"
	mainFrame.Size = UDim2.new(1, 0, 1, 0)
	mainFrame.Position = UDim2.new(0, 0, 0, 0)
	mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
	mainFrame.BackgroundTransparency = 0.05
	mainFrame.BorderSizePixel = 0
	mainFrame.Visible = false
	mainFrame.ZIndex = 50
	mainFrame.Parent = screenGui
	components.MainFrame = mainFrame

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
	closeCorner.CornerRadius = UDim.new(1, 0)
	closeCorner.Parent = closeButton

	-- Content Area
	local contentFrame = Instance.new("Frame")
	contentFrame.Name = "ContentFrame"
	contentFrame.Size = UDim2.new(1, -40, 1, -120)
	contentFrame.Position = UDim2.new(0, 20, 0, 100)
	contentFrame.BackgroundTransparency = 1
	contentFrame.ZIndex = 51
	contentFrame.Parent = mainFrame

	-- Crate Tabs Container
	local tabsContainer = Instance.new("Frame")
	tabsContainer.Name = "TabsContainer"
	tabsContainer.Size = UDim2.new(1, 0, 0, 50)
	tabsContainer.Position = UDim2.new(0, 0, 0, 0)
	tabsContainer.BackgroundTransparency = 1
	tabsContainer.ZIndex = 52
	tabsContainer.Parent = contentFrame

	local tabsLayout = Instance.new("UIListLayout")
	tabsLayout.FillDirection = Enum.FillDirection.Horizontal
	tabsLayout.Padding = UDim.new(0, 5)
	tabsLayout.Parent = tabsContainer

	-- Items Display Area
	local itemsContainer = Instance.new("ScrollingFrame")
	itemsContainer.Name = "ItemsContainer"
	itemsContainer.Size = UDim2.new(1, 0, 1, -70)
	itemsContainer.Position = UDim2.new(0, 0, 0, 60)
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

	-- Use UIGridLayout for items
	local itemsLayout = Instance.new("UIGridLayout")
	itemsLayout.CellSize = UDim2.new(0, 200, 0, 120)
	itemsLayout.CellPadding = UDim2.new(0, 10, 0, 10)
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

	-- Parent to provided parent
	screenGui.Parent = parent
	components.TabsContainer = tabsContainer
	
	return components
end

-- Create tab button for crate
function CollectionUI.CreateCrateTab(crateName, isActive)
	local tab = Instance.new("TextButton")
	tab.Name = crateName .. "Tab"
	tab.Size = UDim2.new(0, 120, 1, 0)
	tab.BackgroundColor3 = isActive and Color3.fromRGB(60, 50, 80) or Color3.fromRGB(40, 40, 55)
	tab.Text = crateName
	tab.Font = Enum.Font.SourceSansBold
	tab.TextSize = 14
	tab.TextColor3 = Color3.fromRGB(255, 255, 255)
	tab.BorderSizePixel = 0
	tab.ZIndex = 53
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = tab
	
	if isActive then
		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(150, 100, 200)
		stroke.Thickness = 2
		stroke.Parent = tab
	end
	
	return tab
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
	
	-- Progress indicator for discovered items
	if isDiscovered then
		local progressBar = Instance.new("Frame")
		progressBar.Name = "ProgressBar"
		progressBar.Size = UDim2.new(1, -20, 0, 4)
		progressBar.Position = UDim2.new(0, 10, 1, -15)
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