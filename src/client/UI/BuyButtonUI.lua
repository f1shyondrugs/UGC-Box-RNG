-- BuyButtonUI.lua
-- This module creates the main "Buy UGC Crate" button UI with crate selection.

local BuyButtonUI = {}

local GameConfig = require(game.ReplicatedStorage.Shared.Modules.GameConfig)

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

	-- Free Crate Button
	local freeCrateButton = Instance.new("TextButton")
	freeCrateButton.Name = "FreeCrateButton"
	freeCrateButton.Size = UDim2.new(0.15, 0, 0.1, 0) -- Responsive size
	freeCrateButton.Position = UDim2.new(0.02, 0, 0.55, 0) -- Reverted margin
	freeCrateButton.AnchorPoint = Vector2.new(0, 0)
	freeCrateButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
	freeCrateButton.Font = Enum.Font.SourceSansBold
	freeCrateButton.Text = ""
	freeCrateButton.ZIndex = 1 -- Lower ZIndex
	freeCrateButton.Parent = screenGui -- Parent to ScreenGui directly
	components.FreeCrateButton = freeCrateButton

	local freeCrateAspect = Instance.new("UIAspectRatioConstraint")
	freeCrateAspect.AspectRatio = 2.0
	freeCrateAspect.DominantAxis = Enum.DominantAxis.Width
	freeCrateAspect.Parent = freeCrateButton

	local freeCorner = Instance.new("UICorner")
	freeCorner.CornerRadius = UDim.new(0, 12)
	freeCorner.Parent = freeCrateButton
	
	local freeTitleLabel = Instance.new("TextLabel")
	freeTitleLabel.Name = "Title"
	freeTitleLabel.Size = UDim2.new(1, 0, 0.6, 0)
	freeTitleLabel.Text = "Free Crate"
	freeTitleLabel.Font = Enum.Font.SourceSansBold
	freeTitleLabel.TextScaled = true
	freeTitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	freeTitleLabel.BackgroundTransparency = 1
	freeTitleLabel.ZIndex = 1 -- Lower ZIndex
	freeTitleLabel.Parent = freeCrateButton
	
	local freeTitlePadding = Instance.new("UIPadding")
	freeTitlePadding.PaddingLeft = UDim.new(0.1, 0)
	freeTitlePadding.PaddingRight = UDim.new(0.1, 0)
	freeTitlePadding.PaddingTop = UDim.new(0.1, 0)
	freeTitlePadding.PaddingBottom = UDim.new(0.1, 0)
	freeTitlePadding.Parent = freeTitleLabel
	
	local freeTimerLabel = Instance.new("TextLabel")
	freeTimerLabel.Name = "TimerLabel"
	freeTimerLabel.Size = UDim2.new(1, 0, 0.4, 0)
	freeTimerLabel.Position = UDim2.new(0, 0, 0.6, 0)
	freeTimerLabel.Text = "Ready!"
	freeTimerLabel.Font = Enum.Font.SourceSans
	freeTimerLabel.TextScaled = true
	freeTimerLabel.TextColor3 = Color3.fromRGB(200, 255, 200)
	freeTimerLabel.BackgroundTransparency = 1
	freeTimerLabel.ZIndex = 1 -- Lower ZIndex
	freeTimerLabel.Parent = freeCrateButton
	components.FreeCrateTimer = freeTimerLabel

	local freeTimerPadding = Instance.new("UIPadding")
	freeTimerPadding.PaddingLeft = UDim.new(0.15, 0)
	freeTimerPadding.PaddingRight = UDim.new(0.15, 0)
	freeTimerPadding.PaddingTop = UDim.new(0.15, 0)
	freeTimerPadding.PaddingBottom = UDim.new(0.15, 0)
	freeTimerPadding.Parent = freeTimerLabel

	-- Main Container Frame for paid crates
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
	
	-- "Buy Crate" Text
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(1, 0, 0.6, 0)
	titleLabel.Position = UDim2.new(0,0,0,0)
	titleLabel.Text = "Buy UGC Crate"
	titleLabel.Font = Enum.Font.SourceSansBold
	titleLabel.TextScaled = true
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.BackgroundTransparency = 1
	titleLabel.ZIndex = 1 -- Lower ZIndex
	titleLabel.Parent = buyButton
	
	local titlePadding = Instance.new("UIPadding")
	titlePadding.PaddingLeft = UDim.new(0.1, 0)
	titlePadding.PaddingRight = UDim.new(0.1, 0)
	titlePadding.PaddingTop = UDim.new(0.1, 0)
	titlePadding.PaddingBottom = UDim.new(0.1, 0)
	titlePadding.Parent = titleLabel

	-- Cost Text
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
	
	-- First, get all paid crates and sort them by price
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
	for _, crateData in ipairs(sortedCrates) do
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
	
	-- Resize options frame based on number of options
	optionsFrame.Size = UDim2.new(1, 0, 0, #sortedCrates * 30)

	-- Store selected crate type
	components.SelectedCrateType = "StarterCrate" -- Default
	components.SelectedCrateConfig = GameConfig.Boxes["StarterCrate"]

	return components
end

function BuyButtonUI.SetSelectedCrate(components, crateType)
	local crateConfig = GameConfig.Boxes[crateType]
	if not crateConfig or crateConfig.Price == 0 then return end
	
	components.SelectedCrateType = crateType
	components.SelectedCrateConfig = crateConfig
	components.CrateDropdown.Text = crateConfig.Name .. " ▼"
	components.CostLabel.Text = "Cost: " .. crateConfig.Price .. " R$"
	components.CostLabel.TextColor3 = Color3.fromRGB(200, 205, 255) -- Reset to default color
end

function BuyButtonUI.ToggleDropdown(components)
	local optionsFrame = components.OptionsFrame
	optionsFrame.Visible = not optionsFrame.Visible
end

function BuyButtonUI.HideDropdown(components)
	components.OptionsFrame.Visible = false
end

function BuyButtonUI.SetEnabled(components, isEnabled, buttonType)
	buttonType = buttonType or "All"
	
	if buttonType == "All" or buttonType == "Paid" then
		local button = components.BuyButton
		button.AutoButtonColor = isEnabled
		if isEnabled then
			button.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
		else
			button.BackgroundColor3 = Color3.fromRGB(87, 91, 99)
		end
	end
	
	if buttonType == "All" or buttonType == "Free" then
		local button = components.FreeCrateButton
		button.AutoButtonColor = isEnabled
		if isEnabled then
			button.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
		else
			button.BackgroundColor3 = Color3.fromRGB(87, 91, 99)
		end
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
	if not selectedConfig then return end
	
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

return BuyButtonUI 