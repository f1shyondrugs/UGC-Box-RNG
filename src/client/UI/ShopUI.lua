local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Shared = ReplicatedStorage.Shared
local GameConfig = require(Shared.Modules.GameConfig)

local ShopUI = {}

-- Calculate UI scale based on screen size
local function calculateUIScale()
	local viewport = workspace.CurrentCamera.ViewportSize
	local baseResolution = 1080
	local scale = math.min(viewport.Y / baseResolution, 1.2) -- Cap at 1.2x for very high resolutions
	return math.max(scale, 0.7) -- Minimum scale of 0.7 for very small screens
end

-- Function to animate a rainbow background
local function AnimateRainbowBackground(uiElement, initialColor, finalColor)
	local gradient = uiElement:FindFirstChildOfClass("UIGradient")
	if not gradient then
		gradient = Instance.new("UIGradient")
		gradient.Parent = uiElement
	end

	local colors = {
		Color3.fromRGB(255, 0, 0),
		Color3.fromRGB(255, 128, 0),
		Color3.fromRGB(255, 255, 0),
		Color3.fromRGB(0, 255, 0),
		Color3.fromRGB(0, 0, 255),
		Color3.fromRGB(75, 0, 130),
		Color3.fromRGB(238, 130, 238)
	}
	
	local tweenInfo = TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, true, 0)
	local currentColorIndex = 1

	local function updateColor()
		local startColor = colors[currentColorIndex]
		local nextColorIndex = (currentColorIndex % #colors) + 1
		local endColor = colors[nextColorIndex]

		gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, startColor), ColorSequenceKeypoint.new(1, endColor)})

		currentColorIndex = nextColorIndex
	end

	local colorTween = TweenService:Create(gradient, tweenInfo, { Rotation = 360 })
	colorTween:Play()
	
	-- Update colors periodically to cycle through them
	task.spawn(function()
		while true do
			task.wait(tweenInfo.Time / #colors)
			updateColor()
		end
	end)
end

function ShopUI.Create(parentGui)
	local components = {}
	
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ShopGui"
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
	mainFrame.Name = "ShopMainFrame"
	mainFrame.Size = UDim2.new(0.6, 0, 0.75, 0)
	mainFrame.Position = UDim2.new(0.2, 0, 0.125, 0)
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

	-- Subtle, less saturated animated background for main frame
	if mainFrame:FindFirstChild("AnimatedBg") then mainFrame.AnimatedBg:Destroy() end
	local animatedBg = Instance.new("Frame")
	animatedBg.Name = "AnimatedBg"
	animatedBg.Size = UDim2.new(1, 0, 1, 0)
	animatedBg.Position = UDim2.new(0, 0, 0, 0)
	animatedBg.BackgroundTransparency = 0.7
	animatedBg.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
	animatedBg.ZIndex = 49
	animatedBg.Parent = mainFrame

    -- Add rounded corners to animatedBg
    local animatedBgCorner = Instance.new("UICorner")
    animatedBgCorner.CornerRadius = UDim.new(0, 20)
    animatedBgCorner.Parent = animatedBg

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
	title.Text = "🛒 GAMEPASS SHOP"
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

	-- Shop title: bold, simple, no rainbow or pulsing
	if title:FindFirstChildOfClass("UIGradient") then title:FindFirstChildOfClass("UIGradient"):Destroy() end
	title.TextTransparency = 0
	title.TextStrokeTransparency = 0.7

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

	-- Content Area (uses vertical list to allow special full-width card on top)
	local contentFrame = Instance.new("ScrollingFrame")
	contentFrame.Name = "ContentFrame"
	contentFrame.Size = UDim2.new(1, -40, 1, -110)
	contentFrame.Position = UDim2.new(0, 20, 0, 90)
	contentFrame.BackgroundTransparency = 1
	contentFrame.ZIndex = 51
	contentFrame.Parent = mainFrame
	contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0) -- Will be calculated by UIListLayout
	contentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	contentFrame.VerticalScrollBarInset = Enum.ScrollBarInset.Always
	contentFrame.ScrollingDirection = Enum.ScrollingDirection.Y -- Enable vertical scrolling, disable horizontal
	components.ContentFrame = contentFrame

	-- Vertical list layout inside content frame
	local listLayout = Instance.new("UIListLayout")
	listLayout.FillDirection = Enum.FillDirection.Vertical
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding = UDim.new(0, 10)
	listLayout.Parent = contentFrame

	-- Container for Ultra Lucky (full width, always at top)
	local ultraLuckyContainer = Instance.new("Frame")
	ultraLuckyContainer.Name = "UltraLuckyContainer"
	ultraLuckyContainer.Size = UDim2.new(1, 0, 0, 200)
	ultraLuckyContainer.BackgroundTransparency = 1
	ultraLuckyContainer.ZIndex = 51
	ultraLuckyContainer.Parent = contentFrame

	-- Container for grid items (all other gamepasses)
	local gridContainer = Instance.new("Frame")
	gridContainer.Name = "GridContainer"
	gridContainer.Size = UDim2.new(1, 0, 0, 0) -- Automatic Y size
	gridContainer.AutomaticSize = Enum.AutomaticSize.Y
	gridContainer.BackgroundTransparency = 1
	gridContainer.ZIndex = 51
	gridContainer.Parent = contentFrame

	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
	gridLayout.CellSize = UDim2.new(0.48, 0, 0, 200)
	gridLayout.FillDirection = Enum.FillDirection.Horizontal
	gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	gridLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	gridLayout.StartCorner = Enum.StartCorner.TopLeft
	gridLayout.FillDirectionMaxCells = 2
	gridLayout.Parent = gridContainer

	-- Add padding to content frame
	local contentPadding = Instance.new("UIPadding")
	contentPadding.PaddingTop = UDim.new(0, 10)
	contentPadding.PaddingBottom = UDim.new(0, 10)
	contentPadding.PaddingLeft = UDim.new(0, 10)
	contentPadding.PaddingRight = UDim.new(0, 10)
	contentPadding.Parent = contentFrame

	-- Store gamepass card references
	components.GamepassCards = {}

	-- Function to create a gamepass card
	local function createGamepassCard(gamepassData)
		local card
		if gamepassData.UltraLucky then
			card = Instance.new("Frame")
			card.Name = gamepassData.Name .. "Card"
			card.BackgroundColor3 = Color3.fromRGB(25, 30, 45)
			card.BorderSizePixel = 0
			card.ZIndex = 52
			card.LayoutOrder = 0
			card.Size = UDim2.new(0.96, 10, 0, 200) -- Match width of two grid cards plus padding
			card.Parent = ultraLuckyContainer

			-- Gentle rainbow background effect
			local rainbowGradient = Instance.new("UIGradient")
			rainbowGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 120, 180)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(120, 200, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 220, 120)),
			})
			rainbowGradient.Rotation = 30
			rainbowGradient.Parent = card
		else
			card = Instance.new("Frame")
			card.Name = gamepassData.Name .. "Card"
			card.BackgroundColor3 = Color3.fromRGB(25, 30, 45)
			card.BorderSizePixel = 0
			card.ZIndex = 52
			card.LayoutOrder = gamepassData.LayoutOrder or 1
			card.Size = UDim2.new(0.48, 0, 0, 200)
			card.Parent = gridContainer
		end

		local cardCorner = Instance.new("UICorner")
		cardCorner.CornerRadius = UDim.new(0, 12)
		cardCorner.Parent = card

		local cardGradient = Instance.new("UIGradient")
		cardGradient.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 40, 60)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 25, 40))
		}
		cardGradient.Rotation = 90
		cardGradient.Parent = card

		local cardStroke = Instance.new("UIStroke")
		cardStroke.Color = gamepassData.AccentColor or Color3.fromRGB(120, 80, 255)
		cardStroke.Thickness = 2
		cardStroke.Transparency = 0.5
		cardStroke.Parent = card

		-- Icon
		local icon = Instance.new("ImageLabel")
		icon.Name = "Icon"
		icon.Size = UDim2.new(0, 40, 0, 40)
		icon.Position = UDim2.new(0.5, -20, 0, 10)
		icon.BackgroundTransparency = 1
		icon.Image = gamepassData.Icon or ""
		icon.ZIndex = 53
		icon.Parent = card

		-- Remove all card and icon animations (no glow, no bounce, no spin)
		-- Only keep soft glow on hover for card
		local originalStrokeColor = cardStroke.Color
		local originalStrokeTransparency = cardStroke.Transparency
		local originalCardColor = card.BackgroundColor3
		card.MouseEnter:Connect(function()
			TweenService:Create(cardStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(255, 255, 255), Transparency = 0.2}):Play()
			TweenService:Create(card, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 45, 60)}):Play()
		end)
		card.MouseLeave:Connect(function()
			TweenService:Create(cardStroke, TweenInfo.new(0.2), {Color = originalStrokeColor, Transparency = originalStrokeTransparency}):Play()
			TweenService:Create(card, TweenInfo.new(0.2), {BackgroundColor3 = originalCardColor}):Play()
		end)

		-- Title
		local titleLabel = Instance.new("TextLabel")
		titleLabel.Name = "Title"
		titleLabel.Size = UDim2.new(1, -10, 0, 28)
		titleLabel.Position = UDim2.new(0, 5, 0, 55)
		titleLabel.BackgroundTransparency = 1
		titleLabel.Text = gamepassData.Name
		titleLabel.Font = Enum.Font.GothamBold
		titleLabel.TextSize = 22
		titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		titleLabel.TextXAlignment = Enum.TextXAlignment.Center
		titleLabel.TextScaled = true
		titleLabel.ZIndex = 53
		titleLabel.Parent = card

		-- Price
		local priceLabel = Instance.new("TextLabel")
		priceLabel.Name = "Price"
		priceLabel.Size = UDim2.new(1, -10, 0, 22)
		priceLabel.Position = UDim2.new(0, 5, 0, 85)
		priceLabel.BackgroundTransparency = 1
		priceLabel.Text = gamepassData.Price or ""
		priceLabel.Font = Enum.Font.Gotham
		priceLabel.TextSize = 16
		priceLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
		priceLabel.TextXAlignment = Enum.TextXAlignment.Center
		priceLabel.TextScaled = true
		priceLabel.ZIndex = 53
		priceLabel.Parent = card

		-- Buy Button
		local buyButton = Instance.new("TextButton")
		buyButton.Name = "BuyButton"
		buyButton.Size = UDim2.new(1, -10, 0, 36)
		buyButton.Position = UDim2.new(0, 5, 1, -40)
		buyButton.BackgroundColor3 = gamepassData.ButtonColor or Color3.fromRGB(50, 150, 50)
		buyButton.Text = gamepassData.ButtonText or "Buy"
		buyButton.Font = Enum.Font.GothamBold
		buyButton.TextSize = 18
		buyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		buyButton.TextScaled = true
		buyButton.ZIndex = 53
		buyButton.Parent = card

		local buyCorner = Instance.new("UICorner")
		buyCorner.CornerRadius = UDim.new(0, 8)
		buyCorner.Parent = buyButton

		local buyGradient = Instance.new("UIGradient")
		buyGradient.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, gamepassData.ButtonColor or Color3.fromRGB(60, 170, 60)),
			ColorSequenceKeypoint.new(1, gamepassData.ButtonColor or Color3.fromRGB(40, 130, 40))
		}
		buyGradient.Rotation = 90
		buyGradient.Parent = buyButton

		-- Buy button: only color shift on hover, no bounce or shine
		buyButton.MouseEnter:Connect(function()
			TweenService:Create(buyButton, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(70, 190, 70)}):Play()
		end)
		buyButton.MouseLeave:Connect(function()
			TweenService:Create(buyButton, TweenInfo.new(0.15), {BackgroundColor3 = gamepassData.ButtonColor or Color3.fromRGB(50, 150, 50)}):Play()
		end)

		-- Hover effects for the card itself (stroke and background)
		local originalStrokeColor = cardStroke.Color
		local originalStrokeTransparency = cardStroke.Transparency
		local originalCardColor = card.BackgroundColor3
		
		card.MouseEnter:Connect(function()
			TweenService:Create(cardStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(255, 255, 255), Transparency = 0.1}):Play()
			TweenService:Create(card, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 45, 60)}):Play()
		end)
		
		card.MouseLeave:Connect(function()
			TweenService:Create(cardStroke, TweenInfo.new(0.2), {Color = originalStrokeColor, Transparency = originalStrokeTransparency}):Play()
			TweenService:Create(card, TweenInfo.new(0.2), {BackgroundColor3 = originalCardColor}):Play()
		end)

		-- Hover effects for the buy button
		buyButton.MouseEnter:Connect(function()
			buyButton.BackgroundColor3 = Color3.fromRGB(70, 190, 70)
			cardStroke.Transparency = 0.2
		end)

		buyButton.MouseLeave:Connect(function()
			buyButton.BackgroundColor3 = gamepassData.ButtonColor or Color3.fromRGB(50, 150, 50)
			cardStroke.Transparency = 0.5
		end)

		-- Click handler
		if gamepassData.OnClick then
			buyButton.MouseButton1Click:Connect(gamepassData.OnClick)
		end

		if gamepassData.RainbowEffect then
			AnimateRainbowBackground(card)
			cardStroke.Transparency = 0.8 -- Make stroke visible but subtle under rainbow
		end

		if gamepassData.UltraLucky then
			-- Left-align icon and text for Ultra Lucky
			icon.Position = UDim2.new(0, 20, 0, 20)
			titleLabel.TextXAlignment = Enum.TextXAlignment.Left
			titleLabel.Position = UDim2.new(0, 70, 0, 25)
			titleLabel.Size = UDim2.new(1, -80, 0, 32)
			priceLabel.TextXAlignment = Enum.TextXAlignment.Left
			priceLabel.Position = UDim2.new(0, 70, 0, 65)
			priceLabel.Size = UDim2.new(1, -80, 0, 24)
			buyButton.Position = UDim2.new(0, 70, 1, -50)
			buyButton.Size = UDim2.new(1, -80, 0, 36)
			-- 'Best Value!' badge for Ultra Lucky: smaller, less saturated
			if gamepassData.UltraLucky then
				local badge = Instance.new("TextLabel")
				badge.Name = "BestValueBadge"
				badge.Text = "🌈 Best Value!"
				badge.Font = Enum.Font.GothamBold
				badge.TextSize = 14
				badge.TextColor3 = Color3.fromRGB(255, 230, 120)
				badge.BackgroundTransparency = 0.4
				badge.BackgroundColor3 = Color3.fromRGB(200, 160, 80)
				badge.Size = UDim2.new(0, 90, 0, 22)
				badge.Position = UDim2.new(1, -100, 0, 10)
				badge.ZIndex = 55
				local badgeCorner = Instance.new("UICorner")
				badgeCorner.CornerRadius = UDim.new(0, 8)
				badgeCorner.Parent = badge
				badge.Parent = card
			end
		end

		return card
	end

	components.CreateGamepassCard = createGamepassCard
	components.GridContainer = gridContainer
	components.ListLayout = listLayout
	components.AnimateRainbowBackground = AnimateRainbowBackground

	return components
end

return ShopUI 