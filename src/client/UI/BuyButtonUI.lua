-- BuyButtonUI.lua
-- This module creates the main "Buy UGC Crate" button UI with crate selection.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local BuyButtonUI = {}

local GameConfig = require(game.ReplicatedStorage.Shared.Modules.GameConfig)

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

function BuyButtonUI.Create(parent)
	local components = {}

	local screenGui = parent
	if not screenGui or not screenGui:IsA("ScreenGui") then
		screenGui = Instance.new("ScreenGui")
		screenGui.Name = "BuyButtonGui"
		screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		screenGui.Parent = parent
	end
	components.ScreenGui = screenGui

	-- Add a UIScale to manage UI scaling across different resolutions
	local uiScale = Instance.new("UIScale")
	uiScale.Scale = calculateUIScale()
	uiScale.Parent = screenGui
	components.UIScale = uiScale

	-- Main Container Frame for all crates (paid and free)
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "BuyContainer"
	mainFrame.Size = UDim2.new(0.3, 0, 0.16, 0) -- Made container smaller
	mainFrame.Position = UDim2.new(0.5, 0, 0.93, 0)
	mainFrame.AnchorPoint = Vector2.new(0.5, 1)
	mainFrame.BackgroundTransparency = 1
	mainFrame.ZIndex = 1 -- Lower ZIndex
	mainFrame.Parent = screenGui
	components.MainFrame = mainFrame

	local listLayout = Instance.new("UIListLayout")
	listLayout.FillDirection = Enum.FillDirection.Horizontal
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	listLayout.Padding = UDim.new(0.04, 0) -- 4% of container width as padding
	listLayout.Parent = mainFrame
	
	-- Main Buy Button
	local buyButton = Instance.new("TextButton")
	buyButton.Name = "BuyBoxButton"
	buyButton.Size = UDim2.new(0.48, 0, 0.9, 0) -- 48% of container width
	buyButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
	buyButton.Font = Enum.Font.SourceSansBold
	buyButton.Text = "" -- Text will be handled by children
	buyButton.ZIndex = 1 -- Lower ZIndex
	buyButton.Parent = mainFrame
	components.BuyButton = buyButton
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = buyButton
	
	-- "Buy/Get Crate" Text (will change based on selection)
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(1, 0, 0.6, 0)
	titleLabel.Position = UDim2.new(0,0,0,0)
	titleLabel.Text = "Get Crate"
	titleLabel.Font = Enum.Font.SourceSansBold
	titleLabel.TextScaled = true
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.BackgroundTransparency = 1
	titleLabel.ZIndex = 1 -- Lower ZIndex
	titleLabel.Parent = buyButton
	components.TitleLabel = titleLabel
	
	local titlePadding = Instance.new("UIPadding")
	titlePadding.PaddingLeft = UDim.new(0.1, 0)
	titlePadding.PaddingRight = UDim.new(0.1, 0)
	titlePadding.PaddingTop = UDim.new(0.1, 0)
	titlePadding.PaddingBottom = UDim.new(0.1, 0)
	titlePadding.Parent = titleLabel

	-- Cost Text (will show cost or cooldown)
	local costLabel = Instance.new("TextLabel")
	costLabel.Name = "CostLabel"
	costLabel.Size = UDim2.new(1, 0, 0.4, 0)
	costLabel.Position = UDim2.new(0, 0, 0.6, 0)
	costLabel.Text = "Select a crate"
	costLabel.Font = Enum.Font.SourceSans
	costLabel.TextScaled = true
	costLabel.TextColor3 = Color3.fromRGB(200, 205, 255)
	costLabel.BackgroundTransparency = 1
	costLabel.ZIndex = 1 -- Lower ZIndex
	costLabel.Parent = buyButton
	components.CostLabel = costLabel
	
	local costPadding = Instance.new("UIPadding")
	costPadding.PaddingLeft = UDim.new(0.1, 0)
	costPadding.PaddingRight = UDim.new(0.1, 0)
	costPadding.PaddingTop = UDim.new(0.1, 0)
	costPadding.PaddingBottom = UDim.new(0.1, 0)
	costPadding.Parent = costLabel

	-- Cooldown Bar
	local cooldownBar = Instance.new("Frame")
	cooldownBar.Name = "CooldownBar"
	cooldownBar.Size = UDim2.new(0, 0, 1, 0) -- Starts with 0 width
	cooldownBar.Position = UDim2.new(0,0,0,0)
	cooldownBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	cooldownBar.BackgroundTransparency = 0.5
	cooldownBar.ZIndex = 1 -- Lower ZIndex
	cooldownBar.Parent = buyButton
	
	local barCorner = Instance.new("UICorner")
	barCorner.CornerRadius = UDim.new(0, 12)
	barCorner.Parent = cooldownBar

	components.CooldownBar = cooldownBar
	
	-- Crate Selection Dropdown
	local crateDropdown = Instance.new("TextButton")
	crateDropdown.Name = "CrateDropdown"
	crateDropdown.Size = UDim2.new(0.48, 0, 0.9, 0) -- 48% of container width
	crateDropdown.BackgroundColor3 = Color3.fromRGB(60, 65, 75)
	crateDropdown.Font = Enum.Font.SourceSans
	crateDropdown.Text = "Select Crate ▼"
	crateDropdown.TextScaled = true
	crateDropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
	crateDropdown.ZIndex = 1 -- Lower ZIndex
	crateDropdown.Parent = mainFrame
	components.CrateDropdown = crateDropdown
	
	local dropdownPadding = Instance.new("UIPadding")
	dropdownPadding.PaddingLeft = UDim.new(0.05, 0)
	dropdownPadding.PaddingRight = UDim.new(0.05, 0)
	dropdownPadding.Parent = crateDropdown

	local dropdownCorner = Instance.new("UICorner")
	dropdownCorner.CornerRadius = UDim.new(0, 8)
	dropdownCorner.Parent = crateDropdown

	-- Dropdown Options Frame (initially hidden)
	local optionsFrame = Instance.new("Frame")
	optionsFrame.Name = "OptionsFrame"
	optionsFrame.AnchorPoint = Vector2.new(0.5, 1) -- Anchor to middle bottom
	optionsFrame.Size = UDim2.new(1, 0, 0, 0) -- Will be resized based on options
	optionsFrame.Position = UDim2.new(0.5, 0, 0, -5) -- Position above the dropdown
	optionsFrame.BackgroundColor3 = Color3.fromRGB(50, 55, 65)
	optionsFrame.BorderSizePixel = 1
	optionsFrame.BorderColor3 = Color3.fromRGB(70, 75, 85)
	optionsFrame.Visible = false
	optionsFrame.ZIndex = 2 -- Keep this higher than buttons but still low
	optionsFrame.Parent = crateDropdown
	components.OptionsFrame = optionsFrame

	local optionsCorner = Instance.new("UICorner")
	optionsCorner.CornerRadius = UDim.new(0, 8)
	optionsCorner.Parent = optionsFrame

	local optionsLayout = Instance.new("UIListLayout")
	optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
	optionsLayout.Parent = optionsFrame

	-- Create dropdown options
	components.OptionButtons = {}
	
	-- First, add the Free Crate option at the top
	local freeCrateConfig = GameConfig.Boxes["FreeCrate"]
	if freeCrateConfig then
		local optionButton = Instance.new("TextButton")
		optionButton.Name = "FreeCrate"
		optionButton.Size = UDim2.new(1, 0, 0, 30)
		optionButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80) -- Green for free
		optionButton.BorderSizePixel = 0
		optionButton.Font = Enum.Font.SourceSansBold
		optionButton.Text = "🆓 " .. freeCrateConfig.Name .. " - FREE"
		optionButton.TextScaled = true
		optionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		optionButton.ZIndex = 3
		optionButton.LayoutOrder = 0 -- First in list
		optionButton.Parent = optionsFrame
		components.OptionButtons["FreeCrate"] = optionButton
		
		local optionPadding = Instance.new("UIPadding")
		optionPadding.PaddingLeft = UDim.new(0.05, 0)
		optionPadding.PaddingRight = UDim.new(0.05, 0)
		optionPadding.Parent = optionButton
		
		-- Add hover effect
		optionButton.MouseEnter:Connect(function()
			optionButton.BackgroundColor3 = Color3.fromRGB(96, 195, 100)
		end)
		optionButton.MouseLeave:Connect(function()
			optionButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
		end)
	end
	
	-- Then, get all paid crates and sort them by price
	local sortedCrates = {}
	for crateType, crateConfig in pairs(GameConfig.Boxes) do
		if crateConfig.Price > 0 then
			table.insert(sortedCrates, {type = crateType, config = crateConfig})
		end
	end
	table.sort(sortedCrates, function(a, b)
		return a.config.Price < b.config.Price
	end)

	-- Now create the buttons from the sorted list
	for i, crateData in ipairs(sortedCrates) do
		local crateType = crateData.type
		local crateConfig = crateData.config
		
		local optionButton = Instance.new("TextButton")
		optionButton.Name = crateType
		optionButton.Size = UDim2.new(1, 0, 0, 30) -- Keep fixed height for options
		optionButton.BackgroundColor3 = Color3.fromRGB(50, 55, 65)
		optionButton.BorderSizePixel = 0
		optionButton.Font = Enum.Font.SourceSans
		optionButton.Text = crateConfig.Name .. " - " .. crateConfig.Price .. " R$"
		optionButton.TextScaled = true
		optionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		optionButton.ZIndex = 3 -- Higher than the frame but still low
		optionButton.LayoutOrder = i -- After free crate
		optionButton.Parent = optionsFrame
		components.OptionButtons[crateType] = optionButton
		
		local optionPadding = Instance.new("UIPadding")
		optionPadding.PaddingLeft = UDim.new(0.05, 0)
		optionPadding.PaddingRight = UDim.new(0.05, 0)
		optionPadding.Parent = optionButton
		
		-- Add hover effect
		optionButton.MouseEnter:Connect(function()
			optionButton.BackgroundColor3 = Color3.fromRGB(70, 75, 85)
		end)
		optionButton.MouseLeave:Connect(function()
			optionButton.BackgroundColor3 = Color3.fromRGB(50, 55, 65)
		end)
	end
	
	-- Resize options frame based on number of options (including free crate)
	optionsFrame.Size = UDim2.new(1, 0, 0, (#sortedCrates + 1) * 30)

	-- Store selected crate type
	components.SelectedCrateType = "StarterCrate" -- Default
	components.SelectedCrateConfig = GameConfig.Boxes["StarterCrate"]
	
	-- Update scale when screen size changes
	local function updateScale()
		uiScale.Scale = calculateUIScale()
	end
	
	-- Connect to viewport size changes
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
	components.UpdateScale = updateScale

	return components
end

function BuyButtonUI.SetSelectedCrate(components, crateType)
	local crateConfig = GameConfig.Boxes[crateType]
	if not crateConfig then return end
	
	components.SelectedCrateType = crateType
	components.SelectedCrateConfig = crateConfig
	components.CrateDropdown.Text = crateConfig.Name .. " ▼"
	
	-- Update button appearance based on crate type
	if crateType == "FreeCrate" then
		-- Free crate styling
		components.BuyButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
		components.TitleLabel.Text = "Get Free Crate"
		components.CostLabel.Text = "FREE - No Cost!"
		components.CostLabel.TextColor3 = Color3.fromRGB(200, 255, 200)
	else
		-- Paid crate styling
		components.BuyButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
		components.TitleLabel.Text = "Buy UGC Crate"
		components.CostLabel.Text = "Cost: " .. crateConfig.Price .. " R$"
		components.CostLabel.TextColor3 = Color3.fromRGB(200, 205, 255)
	end
end

function BuyButtonUI.ToggleDropdown(components)
	local optionsFrame = components.OptionsFrame
	optionsFrame.Visible = not optionsFrame.Visible
end

function BuyButtonUI.HideDropdown(components)
	components.OptionsFrame.Visible = false
end

function BuyButtonUI.SetEnabled(components, isEnabled)
	local button = components.BuyButton
	button.AutoButtonColor = isEnabled
	if isEnabled then
		-- Restore appropriate color based on selected crate
		if components.SelectedCrateType == "FreeCrate" then
			button.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
		else
			button.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
		end
	else
		button.BackgroundColor3 = Color3.fromRGB(87, 91, 99)
	end
end

function BuyButtonUI.StartCooldown(components, duration)
	local button = components.BuyButton
	local bar = components.CooldownBar
	
	BuyButtonUI.SetEnabled(components, false)
	bar.Size = UDim2.new(0,0,1,0) -- Reset bar
	
	local tween = game:GetService("TweenService"):Create(bar, TweenInfo.new(duration), {Size = UDim2.new(1,0,1,0)})
	tween:Play()
end

function BuyButtonUI.UpdateAffordability(components, playerRobux)
	local selectedConfig = components.SelectedCrateConfig
	if not selectedConfig or selectedConfig.Price == 0 then return end -- Skip for free crates
	
	local canAfford = playerRobux >= selectedConfig.Price
	local costLabel = components.CostLabel
	
	if canAfford then
		costLabel.Text = "Cost: " .. selectedConfig.Price .. " R$"
		costLabel.TextColor3 = Color3.fromRGB(200, 205, 255)
	else
		local needed = selectedConfig.Price - playerRobux
		costLabel.Text = "Need " .. needed .. " more R$!"
		costLabel.TextColor3 = Color3.fromRGB(255, 100, 100) -- Red for insufficient funds
	end
end

-- New function to update free crate cooldown display
function BuyButtonUI.UpdateFreeCrateCooldown(components, timeRemaining)
	if components.SelectedCrateType == "FreeCrate" then
		if timeRemaining > 0 then
			components.CostLabel.Text = "Cooldown: " .. math.ceil(timeRemaining) .. "s"
			components.CostLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
		else
			components.CostLabel.Text = "FREE - Ready!"
			components.CostLabel.TextColor3 = Color3.fromRGB(200, 255, 200)
		end
	end
end

return BuyButtonUI 