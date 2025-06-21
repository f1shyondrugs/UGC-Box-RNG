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
		screenGui.Parent = parent
	end
	components.ScreenGui = screenGui

	-- Main container for all action buttons
	local actionButtonsFrame = Instance.new("Frame")
	actionButtonsFrame.Name = "ActionButtonsFrame"
	actionButtonsFrame.Size = UDim2.new(1, 0, 0, 120)
	actionButtonsFrame.Position = UDim2.new(0.5, 0, 1, -20)
	actionButtonsFrame.AnchorPoint = Vector2.new(0.5, 1)
	actionButtonsFrame.BackgroundTransparency = 1
	actionButtonsFrame.Parent = screenGui

	-- Free Crate Button
	local freeCrateButton = Instance.new("TextButton")
	freeCrateButton.Name = "FreeCrateButton"
	freeCrateButton.Size = UDim2.new(0, 150, 0, 50)
	freeCrateButton.Position = UDim2.new(0, 20, 0.5, 75)
	freeCrateButton.AnchorPoint = Vector2.new(0, 0.5)
	freeCrateButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
	freeCrateButton.Font = Enum.Font.SourceSansBold
	freeCrateButton.Text = ""
	freeCrateButton.Parent = screenGui -- Parent to ScreenGui directly
	components.FreeCrateButton = freeCrateButton

	local freeCorner = Instance.new("UICorner")
	freeCorner.CornerRadius = UDim.new(0, 12)
	freeCorner.Parent = freeCrateButton
	
	local freeTitleLabel = Instance.new("TextLabel")
	freeTitleLabel.Name = "Title"
	freeTitleLabel.Size = UDim2.new(1, 0, 0.6, 0)
	freeTitleLabel.Text = "Free Crate"
	freeTitleLabel.Font = Enum.Font.SourceSansBold
	freeTitleLabel.TextSize = 20
	freeTitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	freeTitleLabel.BackgroundTransparency = 1
	freeTitleLabel.Parent = freeCrateButton
	
	local freeTimerLabel = Instance.new("TextLabel")
	freeTimerLabel.Name = "TimerLabel"
	freeTimerLabel.Size = UDim2.new(1, 0, 0.4, 0)
	freeTimerLabel.Position = UDim2.new(0, 0, 0.6, 0)
	freeTimerLabel.Text = "Ready!"
	freeTimerLabel.Font = Enum.Font.SourceSans
	freeTimerLabel.TextSize = 16
	freeTimerLabel.TextColor3 = Color3.fromRGB(200, 255, 200)
	freeTimerLabel.BackgroundTransparency = 1
	freeTimerLabel.Parent = freeCrateButton
	components.FreeCrateTimer = freeTimerLabel

	-- Main Container Frame for paid crates
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "BuyContainer"
	mainFrame.Size = UDim2.new(0, 220, 0, 120)
	mainFrame.Position = UDim2.new(0.5, 0, 1, -80)
	mainFrame.AnchorPoint = Vector2.new(0.5, 1)
	mainFrame.BackgroundTransparency = 1
	mainFrame.Parent = screenGui
	components.MainFrame = mainFrame

	-- Crate Selection Dropdown
	local crateDropdown = Instance.new("TextButton")
	crateDropdown.Name = "CrateDropdown"
	crateDropdown.Size = UDim2.new(1, 0, 0, 35)
	crateDropdown.Position = UDim2.new(0, 0, 0, 0)
	crateDropdown.BackgroundColor3 = Color3.fromRGB(60, 65, 75)
	crateDropdown.Font = Enum.Font.SourceSans
	crateDropdown.Text = "Select Crate ▼"
	crateDropdown.TextSize = 16
	crateDropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
	crateDropdown.Parent = mainFrame
	components.CrateDropdown = crateDropdown

	local dropdownCorner = Instance.new("UICorner")
	dropdownCorner.CornerRadius = UDim.new(0, 8)
	dropdownCorner.Parent = crateDropdown

	-- Dropdown Options Frame (initially hidden)
	local optionsFrame = Instance.new("Frame")
	optionsFrame.Name = "OptionsFrame"
	optionsFrame.AnchorPoint = Vector2.new(0, 1) -- Anchor to the bottom edge
	optionsFrame.Size = UDim2.new(1, 0, 0, 0) -- Will be resized based on options
	optionsFrame.Position = UDim2.new(0, 0, 0, -5) -- Position it above the main button
	optionsFrame.BackgroundColor3 = Color3.fromRGB(50, 55, 65)
	optionsFrame.BorderSizePixel = 1
	optionsFrame.BorderColor3 = Color3.fromRGB(70, 75, 85)
	optionsFrame.Visible = false
	optionsFrame.ZIndex = 15 -- Higher z-index to appear above other elements
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
		optionButton.Size = UDim2.new(1, 0, 0, 30)
		optionButton.BackgroundColor3 = Color3.fromRGB(50, 55, 65)
		optionButton.BorderSizePixel = 0
		optionButton.Font = Enum.Font.SourceSans
		optionButton.Text = crateConfig.Name .. " - " .. crateConfig.Price .. " R$"
		optionButton.TextSize = 14
		optionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		optionButton.ZIndex = 16 -- Higher than the frame
		optionButton.Parent = optionsFrame
		components.OptionButtons[crateType] = optionButton
		
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

	-- Main Buy Button
	local buyButton = Instance.new("TextButton")
	buyButton.Name = "BuyBoxButton"
	buyButton.Size = UDim2.new(1, 0, 0, 60)
	buyButton.Position = UDim2.new(0, 0, 0, 45)
	buyButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
	buyButton.Font = Enum.Font.SourceSansBold
	buyButton.Text = "" -- Text will be handled by children
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
	titleLabel.TextSize = 20
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Parent = buyButton

	-- Cost Text
	local costLabel = Instance.new("TextLabel")
	costLabel.Name = "CostLabel"
	costLabel.Size = UDim2.new(1, 0, 0.4, 0)
	costLabel.Position = UDim2.new(0, 0, 0.6, 0)
	costLabel.Text = "Select a crate"
	costLabel.Font = Enum.Font.SourceSans
	costLabel.TextSize = 16
	costLabel.TextColor3 = Color3.fromRGB(200, 205, 255)
	costLabel.BackgroundTransparency = 1
	costLabel.Parent = buyButton
	components.CostLabel = costLabel

	-- Cooldown Bar
	local cooldownBar = Instance.new("Frame")
	cooldownBar.Name = "CooldownBar"
	cooldownBar.Size = UDim2.new(0, 0, 1, 0) -- Starts with 0 width
	cooldownBar.Position = UDim2.new(0,0,0,0)
	cooldownBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	cooldownBar.BackgroundTransparency = 0.5
	cooldownBar.ZIndex = buyButton.ZIndex + 1
	cooldownBar.Parent = buyButton
	
	local barCorner = Instance.new("UICorner")
	barCorner.CornerRadius = UDim.new(0, 12)
	barCorner.Parent = cooldownBar

	components.CooldownBar = cooldownBar

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