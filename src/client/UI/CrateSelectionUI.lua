local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Shared = ReplicatedStorage.Shared
local GameConfig = require(Shared.Modules.GameConfig)
local NumberFormatter = require(Shared.Modules.NumberFormatter)

local CrateSelectionUI = {}

-- Calculate UI scale based on screen size
local function calculateUIScale()
	local viewport = workspace.CurrentCamera.ViewportSize
	local baseResolution = 1080
	local scale = math.min(viewport.Y / baseResolution, 1.2) -- Cap at 1.2x for very high resolutions
	return math.max(scale, 0.7) -- Minimum scale of 0.7 for very small screens
end

function CrateSelectionUI.Create(parentGui)
	local components = {}
	
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "CrateSelectionGui"
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

	-- Main Frame (with margins from screen edges)
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "CrateSelectionMainFrame"
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
	title.Text = "📦 CRATE SELECTION"
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
	subtitle.Text = "Choose your crate to purchase"
	subtitle.Font = Enum.Font.SourceSans
	subtitle.TextSize = 16
	subtitle.TextColor3 = Color3.fromRGB(200, 200, 200)
	subtitle.BackgroundTransparency = 1
	subtitle.TextXAlignment = Enum.TextXAlignment.Left
	subtitle.ZIndex = 52
	subtitle.Parent = titleBar
	components.Subtitle = subtitle

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

	-- Crates Display Area (Scrolling Frame)
	local cratesContainer = Instance.new("ScrollingFrame")
	cratesContainer.Name = "CratesContainer"
	cratesContainer.Size = UDim2.new(1, 0, 1, 0)
	cratesContainer.Position = UDim2.new(0, 0, 0, 0)
	cratesContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	cratesContainer.BackgroundTransparency = 0.3
	cratesContainer.BorderSizePixel = 0
	cratesContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
	cratesContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
	cratesContainer.ScrollBarThickness = 8
	cratesContainer.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
	cratesContainer.ZIndex = 52
	cratesContainer.Parent = contentFrame
	components.CratesContainer = cratesContainer

	local cratesCorner = Instance.new("UICorner")
	cratesCorner.CornerRadius = UDim.new(0, 12)
	cratesCorner.Parent = cratesContainer
	
	-- Add padding to crates container
	local cratesContainerPadding = Instance.new("UIPadding")
	cratesContainerPadding.PaddingLeft = UDim.new(0, 15)
	cratesContainerPadding.PaddingRight = UDim.new(0, 15)
	cratesContainerPadding.PaddingTop = UDim.new(0, 15)
	cratesContainerPadding.PaddingBottom = UDim.new(0, 15)
	cratesContainerPadding.Parent = cratesContainer

	-- Layout for crate cards
	local cratesLayout = Instance.new("UIListLayout")
	cratesLayout.SortOrder = Enum.SortOrder.LayoutOrder
	cratesLayout.Padding = UDim.new(0, 12)
	cratesLayout.Parent = cratesContainer

	-- Store crate cards for selection
	components.CrateCards = {}

	-- Update scale when screen size changes
	local function updateScale()
		uiScale.Scale = calculateUIScale()
	end
	
	-- Connect to viewport size changes
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
	components.UpdateScale = updateScale

	return components
end

-- Create a crate card
function CrateSelectionUI.CreateCrateCard(crateName, crateConfig, isSelected)
	local card = Instance.new("Frame")
	card.Name = crateName .. "Card"
	card.Size = UDim2.new(1, 0, 0, 120)
	card.BackgroundColor3 = isSelected and Color3.fromRGB(45, 60, 80) or Color3.fromRGB(25, 30, 40)
	card.BorderSizePixel = 0
	card.ZIndex = 53

	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 12)
	cardCorner.Parent = card

	-- Selection highlight
	if isSelected then
		local highlight = Instance.new("UIStroke")
		highlight.Color = Color3.fromRGB(100, 150, 255)
		highlight.Thickness = 3
		highlight.Parent = card
	end

	-- Gradient
	local cardGradient = Instance.new("UIGradient")
	if isSelected then
		cardGradient.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(55, 70, 90)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 50, 70))
		}
	else
		cardGradient.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 40, 55)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 30, 40))
		}
	end
	cardGradient.Rotation = 90
	cardGradient.Parent = card

	-- 3D Crate Preview (Left Side)
	local crateViewport = Instance.new("ViewportFrame")
	crateViewport.Name = "CrateViewport"
	crateViewport.Size = UDim2.new(0, 100, 0, 100)
	crateViewport.Position = UDim2.new(0, 10, 0, 10)
	crateViewport.BackgroundColor3 = Color3.fromRGB(20, 22, 25)
	crateViewport.BorderSizePixel = 0
	crateViewport.ZIndex = 54
	crateViewport.Parent = card

	local viewportCorner = Instance.new("UICorner")
	viewportCorner.CornerRadius = UDim.new(0, 8)
	viewportCorner.Parent = crateViewport

	-- Info Section (Right Side)
	local infoFrame = Instance.new("Frame")
	infoFrame.Name = "InfoFrame"
	infoFrame.Size = UDim2.new(1, -130, 1, -20)
	infoFrame.Position = UDim2.new(0, 120, 0, 10)
	infoFrame.BackgroundTransparency = 1
	infoFrame.ZIndex = 54
	infoFrame.Parent = card

	-- Crate Name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.Size = UDim2.new(1, 0, 0, 30)
	nameLabel.Position = UDim2.new(0, 0, 0, 0)
	nameLabel.Text = crateConfig.Name or crateName
	nameLabel.Font = Enum.Font.SourceSansBold
	nameLabel.TextSize = 20
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.BackgroundTransparency = 1
	nameLabel.ZIndex = 55
	nameLabel.Parent = infoFrame

	-- Price
	local priceLabel = Instance.new("TextLabel")
	priceLabel.Name = "PriceLabel"
	priceLabel.Size = UDim2.new(0, 200, 0, 25)
	priceLabel.Position = UDim2.new(0, 0, 0, 35)
	local priceText = crateConfig.Price and NumberFormatter.FormatCurrency(crateConfig.Price) or "FREE"
	priceLabel.Text = "💰 " .. priceText
	priceLabel.Font = Enum.Font.SourceSansBold
	priceLabel.TextSize = 16
	priceLabel.TextColor3 = crateConfig.Price and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(100, 255, 100)
	priceLabel.TextXAlignment = Enum.TextXAlignment.Left
	priceLabel.BackgroundTransparency = 1
	priceLabel.ZIndex = 55
	priceLabel.Parent = infoFrame

	-- Description
	local descLabel = Instance.new("TextLabel")
	descLabel.Name = "DescLabel"
	descLabel.Size = UDim2.new(1, 0, 0, 20)
	descLabel.Position = UDim2.new(0, 0, 0, 65)
	descLabel.Text = crateConfig.Description or "A mysterious crate containing valuable items..."
	descLabel.Font = Enum.Font.SourceSans
	descLabel.TextSize = 14
	descLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.BackgroundTransparency = 1
	descLabel.ZIndex = 55
	descLabel.Parent = infoFrame

	-- Cooldown info (for free crates)
	if crateName == "FreeCrate" then
		local cooldownLabel = Instance.new("TextLabel")
		cooldownLabel.Name = "CooldownLabel"
		cooldownLabel.Size = UDim2.new(0, 300, 0, 15)
		cooldownLabel.Position = UDim2.new(0, 0, 0, 85)
		cooldownLabel.Text = "⏰ Cooldown: 5 minutes"
		cooldownLabel.Font = Enum.Font.SourceSans
		cooldownLabel.TextSize = 12
		cooldownLabel.TextColor3 = Color3.fromRGB(150, 150, 255)
		cooldownLabel.TextXAlignment = Enum.TextXAlignment.Left
		cooldownLabel.BackgroundTransparency = 1
		cooldownLabel.ZIndex = 55
		cooldownLabel.Parent = infoFrame
	end

	-- Select Button
	local selectButton = Instance.new("TextButton")
	selectButton.Name = "SelectButton"
	selectButton.Size = UDim2.new(0, 100, 0, 35)
	selectButton.Position = UDim2.new(1, -110, 0.5, -17.5)
	selectButton.BackgroundColor3 = isSelected and Color3.fromRGB(100, 150, 50) or Color3.fromRGB(50, 100, 150)
	selectButton.Text = isSelected and "SELECTED" or "SELECT"
	selectButton.Font = Enum.Font.SourceSansBold
	selectButton.TextSize = 14
	selectButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	selectButton.ZIndex = 55
	selectButton.Parent = card

	local selectCorner = Instance.new("UICorner")
	selectCorner.CornerRadius = UDim.new(0, 8)
	selectCorner.Parent = selectButton

	return card
end

-- Update card selection state
function CrateSelectionUI.UpdateCardSelection(card, isSelected)
	if isSelected then
		card.BackgroundColor3 = Color3.fromRGB(45, 60, 80)
		card.SelectButton.BackgroundColor3 = Color3.fromRGB(100, 150, 50)
		card.SelectButton.Text = "SELECTED"
		
		-- Add highlight if not already there
		if not card:FindFirstChild("UIStroke") then
			local highlight = Instance.new("UIStroke")
			highlight.Color = Color3.fromRGB(100, 150, 255)
			highlight.Thickness = 3
			highlight.Parent = card
		end
	else
		card.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
		card.SelectButton.BackgroundColor3 = Color3.fromRGB(50, 100, 150)
		card.SelectButton.Text = "SELECT"
		
		-- Remove highlight
		local highlight = card:FindFirstChild("UIStroke")
		if highlight then
			highlight:Destroy()
		end
	end
end

return CrateSelectionUI 