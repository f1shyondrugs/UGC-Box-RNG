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
	title.Text = "📦 CRATE SELECTION"
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

	-- Subtitle
	local subtitle = Instance.new("TextLabel")
	subtitle.Name = "Subtitle"
	subtitle.Size = UDim2.new(0, 400, 0, 20)
	subtitle.Position = UDim2.new(0, 25, 1, -25)
	subtitle.Text = "Choose your crate to purchase"
	subtitle.Font = Enum.Font.GothamBold
	subtitle.TextSize = 14
	subtitle.TextColor3 = Color3.fromRGB(200, 200, 200)
	subtitle.BackgroundTransparency = 1
	subtitle.TextXAlignment = Enum.TextXAlignment.Left
	subtitle.ZIndex = 52
	subtitle.Parent = titleBar
	components.Subtitle = subtitle

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
	closeButton.AutoButtonColor = false
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

	-- Content Area
	local contentFrame = Instance.new("Frame")
	contentFrame.Name = "ContentFrame"
	contentFrame.Size = UDim2.new(1, -40, 1, -100)
	contentFrame.Position = UDim2.new(0, 20, 0, 80)
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
	cratesLayout.Padding = UDim.new(0, 20)
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
function CrateSelectionUI.CreateCrateCard(crateName, crateConfig, isSelected, isUnlocked)
	local card = Instance.new("Frame")
	card.Name = crateName .. "Card"
	card.Size = UDim2.new(1, 0, 0, 180) -- Much bigger cards
	card.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
	card.BackgroundTransparency = 0.5
	card.BorderSizePixel = 0
	card.ZIndex = 53

	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 12)
	cardCorner.Parent = card

	local cardStroke = Instance.new("UIStroke")
	cardStroke.Color = isSelected and Color3.fromRGB(120, 80, 255) or (isUnlocked and Color3.fromRGB(50, 55, 70) or Color3.fromRGB(150, 50, 50))
	cardStroke.Thickness = isSelected and 2 or 1
	cardStroke.Transparency = 0.5
	cardStroke.Parent = card

	-- Gradient
	local cardGradient = Instance.new("UIGradient")
	if isSelected then
		cardGradient.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 30, 50)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(25, 22, 38)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 15, 28))
		}
	elseif not isUnlocked then
		cardGradient.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 20, 20)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(35, 15, 15)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 10, 10))
		}
	else
		cardGradient.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 30, 45)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(18, 22, 32)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 15, 22))
		}
	end
	cardGradient.Rotation = 135
	cardGradient.Parent = card

	-- 3D Crate Preview (Left Side) - Much bigger
	local crateViewport = Instance.new("ViewportFrame")
	crateViewport.Name = "CrateViewport"
	crateViewport.Size = UDim2.new(0, 150, 0, 150) -- Bigger viewport
	crateViewport.Position = UDim2.new(0, 15, 0, 15)
	crateViewport.BackgroundColor3 = Color3.fromRGB(20, 22, 25)
	crateViewport.BackgroundTransparency = 0.3
	crateViewport.BorderSizePixel = 0
	crateViewport.ZIndex = 54
	crateViewport.Parent = card

	local viewportCorner = Instance.new("UICorner")
	viewportCorner.CornerRadius = UDim.new(0, 12)
	viewportCorner.Parent = crateViewport

	local viewportStroke = Instance.new("UIStroke")
	viewportStroke.Color = Color3.fromRGB(50, 55, 70)
	viewportStroke.Thickness = 1
	viewportStroke.Transparency = 0.7
	viewportStroke.Parent = crateViewport

	-- Info Section (Right Side) - Adjusted for bigger cards
	local infoFrame = Instance.new("Frame")
	infoFrame.Name = "InfoFrame"
	infoFrame.Size = UDim2.new(1, -190, 1, -30)
	infoFrame.Position = UDim2.new(0, 180, 0, 15)
	infoFrame.BackgroundTransparency = 1
	infoFrame.ZIndex = 54
	infoFrame.Parent = card

	-- Crate Name - Much bigger
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.Size = UDim2.new(1, 0, 0, 40)
	nameLabel.Position = UDim2.new(0, 0, 0, 0)
	nameLabel.Text = crateConfig.Name or crateName
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 28 -- Much bigger text
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.BackgroundTransparency = 1
	nameLabel.ZIndex = 55
	nameLabel.Parent = infoFrame

	-- Add name shadow
	local nameShadow = Instance.new("TextLabel")
	nameShadow.Name = "NameShadow"
	nameShadow.Size = nameLabel.Size
	nameShadow.Position = UDim2.new(0, 2, 0, 2)
	nameShadow.Text = nameLabel.Text
	nameShadow.Font = nameLabel.Font
	nameShadow.TextSize = nameLabel.TextSize
	nameShadow.TextColor3 = Color3.fromRGB(0, 0, 0)
	nameShadow.TextTransparency = 0.8
	nameShadow.TextXAlignment = Enum.TextXAlignment.Left
	nameShadow.BackgroundTransparency = 1
	nameShadow.ZIndex = 54
	nameShadow.Parent = infoFrame

	-- Price - Bigger
	local priceLabel = Instance.new("TextLabel")
	priceLabel.Name = "PriceLabel"
	priceLabel.Size = UDim2.new(1, 0, 0, 35)
	priceLabel.Position = UDim2.new(0, 0, 0, 45)
	local priceText = crateConfig.Price and NumberFormatter.FormatCurrency(crateConfig.Price) or "FREE"
	priceLabel.Text = "💰 " .. priceText
	priceLabel.Font = Enum.Font.GothamBold
	priceLabel.TextSize = 22 -- Bigger price text
	priceLabel.TextColor3 = crateConfig.Price and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(100, 255, 100)
	priceLabel.TextXAlignment = Enum.TextXAlignment.Left
	priceLabel.BackgroundTransparency = 1
	priceLabel.ZIndex = 55
	priceLabel.Parent = infoFrame

	-- Description - Bigger and more readable
	local descLabel = Instance.new("TextLabel")
	descLabel.Name = "DescLabel"
	descLabel.Size = UDim2.new(1, 0, 0, 30)
	descLabel.Position = UDim2.new(0, 0, 0, 85)
	descLabel.Text = crateConfig.Description or "A mysterious crate containing valuable items..."
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextSize = 16 -- Bigger description text
	descLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.TextWrapped = true
	descLabel.BackgroundTransparency = 1
	descLabel.ZIndex = 55
	descLabel.Parent = infoFrame

	-- Cooldown info (for free crates) - Bigger
	if crateName == "FreeCrate" then
		local cooldownLabel = Instance.new("TextLabel")
		cooldownLabel.Name = "CooldownLabel"
		cooldownLabel.Size = UDim2.new(1, 0, 0, 25)
		cooldownLabel.Position = UDim2.new(0, 0, 0, 120)
		cooldownLabel.Text = "⏰ Cooldown: 1 minute"
		cooldownLabel.Font = Enum.Font.Gotham
		cooldownLabel.TextSize = 14 -- Bigger cooldown text
		cooldownLabel.TextColor3 = Color3.fromRGB(150, 150, 255)
		cooldownLabel.TextXAlignment = Enum.TextXAlignment.Left
		cooldownLabel.BackgroundTransparency = 1
		cooldownLabel.ZIndex = 55
		cooldownLabel.Parent = infoFrame
	end

	-- Select Button - Much bigger and better styled
	local selectButton = Instance.new("TextButton")
	selectButton.Name = "SelectButton"
	selectButton.Size = UDim2.new(0, 140, 0, 50) -- Much bigger button
	selectButton.Position = UDim2.new(1, -150, 0.5, -25)
	
	if not isUnlocked then
		selectButton.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
		selectButton.Text = "🔒 LOCKED"
	elseif isSelected then
		selectButton.BackgroundColor3 = Color3.fromRGB(60, 140, 60)
		selectButton.Text = "✓ SELECTED"
	else
		selectButton.BackgroundColor3 = Color3.fromRGB(120, 80, 255)
		selectButton.Text = "SELECT CRATE"
	end
	
	selectButton.Font = Enum.Font.GothamBold
	selectButton.TextSize = 16 -- Bigger button text
	selectButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	selectButton.AutoButtonColor = false -- Fix the purple overlay issue
	selectButton.ZIndex = 55
	selectButton.Parent = card

	local selectCorner = Instance.new("UICorner")
	selectCorner.CornerRadius = UDim.new(0, 12)
	selectCorner.Parent = selectButton

	local selectGradient = Instance.new("UIGradient")
	if not isUnlocked then
		selectGradient.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 80, 80)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 50, 50))
		}
	elseif isSelected then
		selectGradient.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 160, 80)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 140, 60))
		}
	else
		selectGradient.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 100, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 80, 255))
		}
	end
	selectGradient.Rotation = 90
	selectGradient.Parent = selectButton

	local selectStroke = Instance.new("UIStroke")
	if not isUnlocked then
		selectStroke.Color = Color3.fromRGB(200, 100, 100)
	elseif isSelected then
		selectStroke.Color = Color3.fromRGB(100, 200, 100)
	else
		selectStroke.Color = Color3.fromRGB(200, 160, 255)
	end
	selectStroke.Thickness = 1
	selectStroke.Transparency = 0.3
	selectStroke.Parent = selectButton

	return card
end

-- Update card selection state
function CrateSelectionUI.UpdateCardSelection(card, isSelected)
	local cardStroke = card:FindFirstChild("UIStroke")
	local cardGradient = card:FindFirstChild("UIGradient")
	local selectButton = card:FindFirstChild("SelectButton")
	local selectGradient = selectButton and selectButton:FindFirstChild("UIGradient")
	local selectStroke = selectButton and selectButton:FindFirstChild("UIStroke")
	
	-- Check if crate is locked by looking at button text
	local isLocked = selectButton and selectButton.Text == "🔒 LOCKED"
	
	if isSelected then
		-- Update card stroke
		if cardStroke then
			cardStroke.Color = Color3.fromRGB(120, 80, 255)
			cardStroke.Thickness = 2
		end
		
		-- Update card gradient
		if cardGradient then
			cardGradient.Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 30, 50)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(25, 22, 38)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 15, 28))
			}
		end
		
		-- Update button
		if selectButton then
			selectButton.BackgroundColor3 = Color3.fromRGB(60, 140, 60)
			selectButton.Text = "✓ SELECTED"
		end
		
		-- Update button gradient
		if selectGradient then
			selectGradient.Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 160, 80)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 140, 60))
			}
		end
		
		-- Update button stroke
		if selectStroke then
			selectStroke.Color = Color3.fromRGB(100, 200, 100)
		end
	else
		-- Update card stroke
		if cardStroke then
			cardStroke.Color = isLocked and Color3.fromRGB(150, 50, 50) or Color3.fromRGB(50, 55, 70)
			cardStroke.Thickness = 1
		end
		
		-- Update card gradient
		if cardGradient then
			if isLocked then
				cardGradient.Color = ColorSequence.new{
					ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 20, 20)),
					ColorSequenceKeypoint.new(0.5, Color3.fromRGB(35, 15, 15)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 10, 10))
				}
			else
				cardGradient.Color = ColorSequence.new{
					ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 30, 45)),
					ColorSequenceKeypoint.new(0.5, Color3.fromRGB(18, 22, 32)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 15, 22))
				}
			end
		end
		
		-- Update button
		if selectButton then
			if isLocked then
				selectButton.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
				selectButton.Text = "🔒 LOCKED"
			else
				selectButton.BackgroundColor3 = Color3.fromRGB(120, 80, 255)
				selectButton.Text = "SELECT CRATE"
			end
		end
		
		-- Update button gradient
		if selectGradient then
			if isLocked then
				selectGradient.Color = ColorSequence.new{
					ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 80, 80)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 50, 50))
				}
			else
				selectGradient.Color = ColorSequence.new{
					ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 100, 255)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 80, 255))
				}
			end
		end
		
		-- Update button stroke
		if selectStroke then
			if isLocked then
				selectStroke.Color = Color3.fromRGB(200, 100, 100)
			else
				selectStroke.Color = Color3.fromRGB(200, 160, 255)
			end
		end
	end
end

return CrateSelectionUI 