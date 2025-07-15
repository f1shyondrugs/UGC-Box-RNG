local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Shared = ReplicatedStorage.Shared
local GameConfig = require(Shared.Modules.GameConfig)
local NumberFormatter = require(Shared.Modules.NumberFormatter)

local RebirthUI = {}

-- Calculate UI scale based on screen size
local function calculateUIScale()
	local viewport = workspace.CurrentCamera.ViewportSize
	local baseResolution = 1080
	local scale = math.min(viewport.Y / baseResolution, 1.2) -- Cap at 1.2x for very high resolutions
	return math.max(scale, 0.7) -- Minimum scale of 0.7 for very small screens
end

function RebirthUI.Create(parentGui)
	local isMobile = UserInputService.TouchEnabled

	local components = {}
	
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "RebirthGui"
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
	mainFrame.Name = "RebirthMainFrame"
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
	accentLine.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
	accentLine.BorderSizePixel = 0
	accentLine.ZIndex = 52
	accentLine.Parent = titleBar
	
	local accentGradient = Instance.new("UIGradient")
	accentGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 215, 0)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 235, 59)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 193, 7))
	}
	accentGradient.Parent = accentLine

	-- Title with improved styling
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, -120, 1, 0)
	title.Position = UDim2.new(0, 25, 0, 0)
	title.Text = "🌟 REBIRTH"
	title.Font = Enum.Font.GothamBold
	title.TextSize = 24
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.BackgroundTransparency = 1
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextYAlignment = Enum.TextYAlignment.Center
	title.ZIndex = 52
	title.Parent = titleBar
	components.Title = title

	-- Close button
	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Size = UDim2.new(0, 40, 0, 40)
	closeButton.Position = UDim2.new(1, -50, 0.5, -20)
	closeButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
	closeButton.Text = "✕"
	closeButton.Font = Enum.Font.GothamBold
	closeButton.TextSize = 16
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.ZIndex = 52
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

	-- Content Area (scrolling frame)
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
	
	-- Add layout to ContentFrame to ensure proper ordering
	local contentLayout = Instance.new("UIListLayout")
	contentLayout.Padding = UDim.new(0, 15)
	contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
	contentLayout.Parent = contentFrame

	-- Current Stats Panel
	local currentStatsPanel = Instance.new("Frame")
	currentStatsPanel.Name = "CurrentStatsPanel"
	currentStatsPanel.Size = UDim2.new(1, 0, 0, 120)
	currentStatsPanel.BackgroundColor3 = Color3.fromHex("#121620")
	currentStatsPanel.BackgroundTransparency = 0.5
	currentStatsPanel.BorderSizePixel = 0
	currentStatsPanel.ZIndex = 52
	currentStatsPanel.LayoutOrder = 1
	currentStatsPanel.Parent = contentFrame
	components.CurrentStatsPanel = currentStatsPanel

	local currentStatsCorner = Instance.new("UICorner")
	currentStatsCorner.CornerRadius = UDim.new(0, 12)
	currentStatsCorner.Parent = currentStatsPanel

	local currentStatsStroke = Instance.new("UIStroke")
	currentStatsStroke.Color = Color3.fromRGB(255, 215, 0)
	currentStatsStroke.Thickness = 1
	currentStatsStroke.Transparency = 0.7
	currentStatsStroke.Parent = currentStatsPanel

	-- Current stats layout
	local currentStatsLayout = Instance.new("UIListLayout")
	currentStatsLayout.Padding = UDim.new(0, 10)
	currentStatsLayout.SortOrder = Enum.SortOrder.LayoutOrder
	currentStatsLayout.Parent = currentStatsPanel

	local currentStatsPadding = Instance.new("UIPadding")
	currentStatsPadding.PaddingTop = UDim.new(0, 15)
	currentStatsPadding.PaddingBottom = UDim.new(0, 15)
	currentStatsPadding.PaddingLeft = UDim.new(0, 20)
	currentStatsPadding.PaddingRight = UDim.new(0, 20)
	currentStatsPadding.Parent = currentStatsPanel

	-- Current stats title
	local currentStatsTitle = Instance.new("TextLabel")
	currentStatsTitle.Name = "CurrentStatsTitle"
	currentStatsTitle.Size = UDim2.new(1, 0, 0, 35)
	currentStatsTitle.Text = "📊 Current Progress"
	currentStatsTitle.Font = Enum.Font.GothamBold
	currentStatsTitle.TextSize = 24
	currentStatsTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
	currentStatsTitle.TextXAlignment = Enum.TextXAlignment.Left
	currentStatsTitle.BackgroundTransparency = 1
	currentStatsTitle.ZIndex = 53
	currentStatsTitle.LayoutOrder = 1
	currentStatsTitle.Parent = currentStatsPanel
	components.CurrentStatsTitle = currentStatsTitle

	-- Current stats info
	local currentStatsInfo = Instance.new("TextLabel")
	currentStatsInfo.Name = "CurrentStatsInfo"
	currentStatsInfo.Size = UDim2.new(1, 0, 0, 80)
	currentStatsInfo.Text = "Rebirths: 0 | Luck Bonus: 0% | Money: R$ 0"
	currentStatsInfo.Font = Enum.Font.Gotham
	currentStatsInfo.TextSize = 18
	currentStatsInfo.TextColor3 = Color3.fromRGB(220, 220, 220)
	currentStatsInfo.TextXAlignment = Enum.TextXAlignment.Left
	currentStatsInfo.TextWrapped = true
	currentStatsInfo.BackgroundTransparency = 1
	currentStatsInfo.ZIndex = 53
	currentStatsInfo.LayoutOrder = 2
	currentStatsInfo.Parent = currentStatsPanel
	components.CurrentStatsInfo = currentStatsInfo

	-- Rebirth Options Container
	local rebirthContainer = Instance.new("Frame")
	rebirthContainer.Name = "RebirthContainer"
	rebirthContainer.Size = UDim2.new(1, 0, 0, 0) -- Height will be set by AutomaticSize
	rebirthContainer.Position = UDim2.new(0, 0, 0, 140)
	rebirthContainer.BackgroundTransparency = 1
	rebirthContainer.ZIndex = 52
	rebirthContainer.LayoutOrder = 2
	rebirthContainer.Parent = contentFrame
	components.RebirthContainer = rebirthContainer

	local rebirthLayout = Instance.new("UIListLayout")
	rebirthLayout.Padding = UDim.new(0, 15)
	rebirthLayout.SortOrder = Enum.SortOrder.LayoutOrder
	rebirthLayout.Parent = rebirthContainer

	-- Update scale when screen size changes
	local function updateScale()
		uiScale.Scale = calculateUIScale()
	end
	
	-- Connect to viewport size changes
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
	components.UpdateScale = updateScale

	return components
end

-- Create confirmation dialog
function RebirthUI.CreateConfirmationDialog(parent, rebirthConfig, onConfirm, onCancel, selectedItems)
	local dialog = Instance.new("ScreenGui")
	dialog.Name = "RebirthConfirmationDialog"
	dialog.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	dialog.Parent = parent

	-- Background overlay
	local overlay = Instance.new("Frame")
	overlay.Name = "Overlay"
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.Position = UDim2.new(0, 0, 0, 0)
	overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	overlay.BackgroundTransparency = 0.5
	overlay.ZIndex = 1000
	overlay.Parent = dialog

	-- Main dialog frame
	local dialogFrame = Instance.new("Frame")
	dialogFrame.Name = "DialogFrame"
	dialogFrame.Size = UDim2.new(0, 600, 0, 500)
	dialogFrame.Position = UDim2.new(0.5, -300, 0.5, -250)
	dialogFrame.BackgroundColor3 = Color3.fromRGB(20, 24, 35)
	dialogFrame.BorderSizePixel = 0
	dialogFrame.ZIndex = 1001
	dialogFrame.Parent = dialog

	local dialogCorner = Instance.new("UICorner")
	dialogCorner.CornerRadius = UDim.new(0, 20)
	dialogCorner.Parent = dialogFrame

	local dialogGradient = Instance.new("UIGradient")
	dialogGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 35, 50)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 24, 35))
	}
	dialogGradient.Rotation = 135
	dialogGradient.Parent = dialogFrame

	-- Warning icon
	local warningIcon = Instance.new("TextLabel")
	warningIcon.Name = "WarningIcon"
	warningIcon.Size = UDim2.new(0, 80, 0, 80)
	warningIcon.Position = UDim2.new(0.5, -40, 0, 20)
	warningIcon.Text = "⚠️"
	warningIcon.Font = Enum.Font.GothamBold
	warningIcon.TextSize = 60
	warningIcon.TextColor3 = Color3.fromRGB(255, 193, 7)
	warningIcon.BackgroundTransparency = 1
	warningIcon.ZIndex = 1002
	warningIcon.Parent = dialogFrame

	-- Title
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, -40, 0, 50)
	title.Position = UDim2.new(0, 20, 0, 120)
	title.Text = "⚠️ REBIRTH CONFIRMATION ⚠️"
	title.Font = Enum.Font.GothamBold
	title.TextSize = 28
	title.TextColor3 = Color3.fromRGB(255, 193, 7)
	title.BackgroundTransparency = 1
	title.TextXAlignment = Enum.TextXAlignment.Center
	title.ZIndex = 1002
	title.Parent = dialogFrame

	-- Warning message
	local warningText = Instance.new("TextLabel")
	warningText.Name = "WarningText"
	warningText.Size = UDim2.new(1, -40, 0, 60)
	warningText.Position = UDim2.new(0, 20, 0, 180)
	warningText.Text = "Are you sure you want to rebirth?\nThis action cannot be undone!"
	warningText.Font = Enum.Font.GothamBold
	warningText.TextSize = 20
	warningText.TextColor3 = Color3.fromRGB(255, 255, 255)
	warningText.BackgroundTransparency = 1
	warningText.TextXAlignment = Enum.TextXAlignment.Center
	warningText.TextWrapped = true
	warningText.ZIndex = 1002
	warningText.Parent = dialogFrame

	-- What gets reset section
	local resetTitle = Instance.new("TextLabel")
	resetTitle.Name = "ResetTitle"
	resetTitle.Size = UDim2.new(1, -40, 0, 30)
	resetTitle.Position = UDim2.new(0, 20, 0, 250)
	resetTitle.Text = "🔄 The following will be RESET:"
	resetTitle.Font = Enum.Font.GothamBold
	resetTitle.TextSize = 18
	resetTitle.TextColor3 = Color3.fromRGB(255, 100, 100)
	resetTitle.BackgroundTransparency = 1
	resetTitle.TextXAlignment = Enum.TextXAlignment.Left
	resetTitle.ZIndex = 1002
	resetTitle.Parent = dialogFrame

	-- Reset list
	local resetList = Instance.new("TextLabel")
	resetList.Name = "ResetList"
	resetList.Size = UDim2.new(1, -40, 0, 100)
	resetList.Position = UDim2.new(0, 20, 0, 280)
	
	local resetText = "💰 R$ will be reset to: " .. NumberFormatter.FormatCurrency(rebirthConfig.ResetMoney) .. " R$\n"
	resetText = resetText .. "🗂️ ALL INVENTORY ITEMS will be removed\n"
	resetText = resetText .. "📦 Required items will be consumed:\n"
	for _, itemReq in ipairs(rebirthConfig.Requirements.Items) do
		resetText = resetText .. "   • " .. itemReq.Amount .. "x " .. itemReq.Name .. "\n"
	end
	
	resetList.Text = resetText
	resetList.Font = Enum.Font.Gotham
	resetList.TextSize = 16
	resetList.TextColor3 = Color3.fromRGB(255, 150, 150)
	resetList.BackgroundTransparency = 1
	resetList.TextXAlignment = Enum.TextXAlignment.Left
	resetList.TextWrapped = true
	resetList.ZIndex = 1002
	resetList.Parent = dialogFrame

	-- Selected items section (if items were selected)
	if selectedItems and #selectedItems > 0 then
		local selectedTitle = Instance.new("TextLabel")
		selectedTitle.Name = "SelectedTitle"
		selectedTitle.Size = UDim2.new(1, -40, 0, 30)
		selectedTitle.Position = UDim2.new(0, 20, 0, 390)
		selectedTitle.Text = "💾 Items to KEEP:"
		selectedTitle.Font = Enum.Font.GothamBold
		selectedTitle.TextSize = 16
		selectedTitle.TextColor3 = Color3.fromRGB(100, 255, 100)
		selectedTitle.BackgroundTransparency = 1
		selectedTitle.TextXAlignment = Enum.TextXAlignment.Left
		selectedTitle.ZIndex = 1002
		selectedTitle.Parent = dialogFrame

		local selectedList = Instance.new("TextLabel")
		selectedList.Name = "SelectedList"
		selectedList.Size = UDim2.new(1, -40, 0, 50)
		selectedList.Position = UDim2.new(0, 20, 0, 420)
		
		local selectedText = ""
		for i, itemName in ipairs(selectedItems) do
			selectedText = selectedText .. "   • " .. itemName .. "\n"
		end
		
		selectedList.Text = selectedText
		selectedList.Font = Enum.Font.Gotham
		selectedList.TextSize = 14
		selectedList.TextColor3 = Color3.fromRGB(100, 255, 100)
		selectedList.BackgroundTransparency = 1
		selectedList.TextXAlignment = Enum.TextXAlignment.Left
		selectedList.TextWrapped = true
		selectedList.ZIndex = 1002
		selectedList.Parent = dialogFrame

		-- Adjust button container position
		buttonContainer.Position = UDim2.new(0, 20, 1, -80)
	end

	-- Buttons container
	local buttonContainer = Instance.new("Frame")
	buttonContainer.Name = "ButtonContainer"
	buttonContainer.Size = UDim2.new(1, -40, 0, 60)
	buttonContainer.Position = UDim2.new(0, 20, 1, -80)
	buttonContainer.BackgroundTransparency = 1
	buttonContainer.ZIndex = 1002
	buttonContainer.Parent = dialogFrame

	-- Cancel button
	local cancelButton = Instance.new("TextButton")
	cancelButton.Name = "CancelButton"
	cancelButton.Size = UDim2.new(0.45, 0, 1, 0)
	cancelButton.Position = UDim2.new(0, 0, 0, 0)
	cancelButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	cancelButton.Text = "❌ CANCEL"
	cancelButton.Font = Enum.Font.GothamBold
	cancelButton.TextSize = 18
	cancelButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	cancelButton.ZIndex = 1003
	cancelButton.Parent = buttonContainer

	local cancelCorner = Instance.new("UICorner")
	cancelCorner.CornerRadius = UDim.new(0, 10)
	cancelCorner.Parent = cancelButton

	-- Confirm button
	local confirmButton = Instance.new("TextButton")
	confirmButton.Name = "ConfirmButton"
	confirmButton.Size = UDim2.new(0.45, 0, 1, 0)
	confirmButton.Position = UDim2.new(0.55, 0, 0, 0)
	confirmButton.BackgroundColor3 = Color3.fromRGB(255, 193, 7)
	confirmButton.Text = "✅ CONFIRM REBIRTH"
	confirmButton.Font = Enum.Font.GothamBold
	confirmButton.TextSize = 18
	confirmButton.TextColor3 = Color3.fromRGB(0, 0, 0)
	confirmButton.ZIndex = 1003
	confirmButton.Parent = buttonContainer

	local confirmCorner = Instance.new("UICorner")
	confirmCorner.CornerRadius = UDim.new(0, 10)
	confirmCorner.Parent = confirmButton

	-- Button connections
	cancelButton.MouseButton1Click:Connect(function()
		dialog:Destroy()
		if onCancel then onCancel() end
	end)

	confirmButton.MouseButton1Click:Connect(function()
		dialog:Destroy()
		if onConfirm then onConfirm() end
	end)

	return dialog
end

-- Create a rebirth option entry
function RebirthUI.CreateRebirthEntry(rebirthLevel, rebirthConfig, canAfford, hasItems, selectedItems)
	local entry = Instance.new("Frame")
	entry.Name = "RebirthEntry" .. rebirthLevel
	entry.Size = UDim2.new(1, 0, 0, 200)
	entry.BackgroundColor3 = Color3.fromHex("#121620")
	entry.BackgroundTransparency = 0.3
	entry.BorderSizePixel = 0
	entry.ZIndex = 53

	local entryCorner = Instance.new("UICorner")
	entryCorner.CornerRadius = UDim.new(0, 12)
	entryCorner.Parent = entry

	local entryStroke = Instance.new("UIStroke")
	entryStroke.Color = canAfford and hasItems and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(60, 80, 120)
	entryStroke.Thickness = canAfford and hasItems and 2 or 1
	entryStroke.Transparency = 0.7
	entryStroke.Parent = entry

	-- Entry layout
	local entryLayout = Instance.new("UIListLayout")
	entryLayout.Padding = UDim.new(0, 8)
	entryLayout.SortOrder = Enum.SortOrder.LayoutOrder
	entryLayout.Parent = entry

	local entryPadding = Instance.new("UIPadding")
	entryPadding.PaddingTop = UDim.new(0, 15)
	entryPadding.PaddingBottom = UDim.new(0, 15)
	entryPadding.PaddingLeft = UDim.new(0, 20)
	entryPadding.PaddingRight = UDim.new(0, 20)
	entryPadding.Parent = entry

	-- Rebirth title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.Size = UDim2.new(1, 0, 0, 35)
	titleLabel.Text = "🌟 " .. (rebirthConfig.Name or "Rebirth " .. rebirthLevel)
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 24
	titleLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.BackgroundTransparency = 1
	titleLabel.ZIndex = 54
	titleLabel.LayoutOrder = 1
	titleLabel.Parent = entry

	-- Description
	local descLabel = Instance.new("TextLabel")
	descLabel.Name = "DescLabel"
	descLabel.Size = UDim2.new(1, 0, 0, 30)
	descLabel.Text = rebirthConfig.Description or "Complete this rebirth to gain permanent bonuses!"
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextSize = 16
	descLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.BackgroundTransparency = 1
	descLabel.ZIndex = 54
	descLabel.LayoutOrder = 2
	descLabel.Parent = entry

	-- Requirements
	local reqLabel = Instance.new("TextLabel")
	reqLabel.Name = "ReqLabel"
	reqLabel.Size = UDim2.new(1, 0, 0, 50)
	local moneyReq = NumberFormatter.FormatCurrency(rebirthConfig.Requirements and rebirthConfig.Requirements.Money or 0)
	local itemsText = ""
	if rebirthConfig.Requirements and rebirthConfig.Requirements.Items then
		for i, itemReq in ipairs(rebirthConfig.Requirements.Items) do
			if i > 1 then itemsText = itemsText .. ", " end
			itemsText = itemsText .. (itemReq.Amount or 0) .. "x " .. (itemReq.Name or "Unknown Item")
		end
	end
	reqLabel.Text = "💰 " .. moneyReq .. " R$\n📦 " .. itemsText
	reqLabel.Font = Enum.Font.Gotham
	reqLabel.TextSize = 16
	reqLabel.TextColor3 = canAfford and hasItems and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
	reqLabel.TextXAlignment = Enum.TextXAlignment.Left
	reqLabel.TextWrapped = true
	reqLabel.BackgroundTransparency = 1
	reqLabel.ZIndex = 54
	reqLabel.LayoutOrder = 3
	reqLabel.Parent = entry

	-- Rewards (NEW: visually grouped container)
local rewardsContainer = Instance.new("Frame")
rewardsContainer.Name = "RewardsContainer"
rewardsContainer.Size = UDim2.new(1, 0, 0, 0)
rewardsContainer.AutomaticSize = Enum.AutomaticSize.Y
rewardsContainer.BackgroundColor3 = Color3.fromRGB(24, 28, 40)
rewardsContainer.BackgroundTransparency = 0.15
rewardsContainer.ZIndex = 55
rewardsContainer.LayoutOrder = 4
rewardsContainer.Parent = entry

local rewardsCorner = Instance.new("UICorner")
rewardsCorner.CornerRadius = UDim.new(0, 10)
rewardsCorner.Parent = rewardsContainer

local rewardsPadding = Instance.new("UIPadding")
rewardsPadding.PaddingTop = UDim.new(0, 8)
rewardsPadding.PaddingBottom = UDim.new(0, 8)
rewardsPadding.PaddingLeft = UDim.new(0, 12)
rewardsPadding.PaddingRight = UDim.new(0, 12)
rewardsPadding.Parent = rewardsContainer

local rewardsList = Instance.new("UIListLayout")
rewardsList.FillDirection = Enum.FillDirection.Vertical
rewardsList.SortOrder = Enum.SortOrder.LayoutOrder
rewardsList.Padding = UDim.new(0, 4)
rewardsList.Parent = rewardsContainer

-- Luck Bonus
local luckLabel = Instance.new("TextLabel")
luckLabel.Name = "LuckLabel"
luckLabel.Size = UDim2.new(1, 0, 0, 20)
luckLabel.BackgroundTransparency = 1
luckLabel.Text = "✨ <font color=\"#FFD700\">+" .. (rebirthConfig.Rewards and rebirthConfig.Rewards.LuckBonus or 0) .. "% Luck</font>"
luckLabel.Font = Enum.Font.GothamBold
luckLabel.TextSize = 16
luckLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
luckLabel.TextXAlignment = Enum.TextXAlignment.Left
luckLabel.RichText = true
luckLabel.ZIndex = 56
luckLabel.Parent = rewardsContainer

-- Crate Unlocks
if rebirthConfig.Rewards and rebirthConfig.Rewards.UnlockedCrates and #rebirthConfig.Rewards.UnlockedCrates > 0 then
	local cratesLabel = Instance.new("TextLabel")
	cratesLabel.Name = "CratesLabel"
	cratesLabel.Size = UDim2.new(1, 0, 0, 20)
	cratesLabel.BackgroundTransparency = 1
	cratesLabel.Text = "🎁 <font color=\"#4FC3F7\">Unlocks: " .. table.concat(rebirthConfig.Rewards.UnlockedCrates, ", ") .. "</font>"
	cratesLabel.Font = Enum.Font.GothamBold
	cratesLabel.TextSize = 16
	cratesLabel.TextColor3 = Color3.fromRGB(79, 195, 247)
	cratesLabel.TextXAlignment = Enum.TextXAlignment.Left
	cratesLabel.RichText = true
	cratesLabel.ZIndex = 56
	cratesLabel.Parent = rewardsContainer
end

-- Feature Unlocks
if rebirthConfig.Rewards and rebirthConfig.Rewards.UnlockedFeatures and #rebirthConfig.Rewards.UnlockedFeatures > 0 then
	local featuresLabel = Instance.new("TextLabel")
	featuresLabel.Name = "FeaturesLabel"
	featuresLabel.Size = UDim2.new(1, 0, 0, 20)
	featuresLabel.BackgroundTransparency = 1
	featuresLabel.Text = "🔓 <font color=\"#B388FF\">Features: " .. table.concat(rebirthConfig.Rewards.UnlockedFeatures, ", ") .. "</font>"
	featuresLabel.Font = Enum.Font.GothamBold
	featuresLabel.TextSize = 16
	featuresLabel.TextColor3 = Color3.fromRGB(179, 136, 255)
	featuresLabel.TextXAlignment = Enum.TextXAlignment.Left
	featuresLabel.RichText = true
	featuresLabel.ZIndex = 56
	featuresLabel.Parent = rewardsContainer
end

	-- Item Selection Button (only show if rebirth clears inventory)
	local itemSelectionButton = nil
	if rebirthConfig.ClearInventory then
		itemSelectionButton = Instance.new("TextButton")
		itemSelectionButton.Name = "ItemSelectionButton"
		itemSelectionButton.Size = UDim2.new(1, 0, 0, 35)
		itemSelectionButton.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
		itemSelectionButton.Text = "📦 SELECT 3 ITEMS TO KEEP"
		itemSelectionButton.Font = Enum.Font.GothamBold
		itemSelectionButton.TextSize = 14
		itemSelectionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		itemSelectionButton.ZIndex = 54
		itemSelectionButton.LayoutOrder = 5
		itemSelectionButton.Parent = entry

		local itemButtonCorner = Instance.new("UICorner")
		itemButtonCorner.CornerRadius = UDim.new(0, 8)
		itemButtonCorner.Parent = itemSelectionButton

		local itemButtonGradient = Instance.new("UIGradient")
		itemButtonGradient.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 170, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 130, 215))
		}
		itemButtonGradient.Rotation = 90
		itemButtonGradient.Parent = itemSelectionButton
	end

	-- Rebirth button
	local rebirthButton = Instance.new("TextButton")
	rebirthButton.Name = "RebirthButton"
	rebirthButton.Size = UDim2.new(1, 0, 0, 40)
	rebirthButton.BackgroundColor3 = canAfford and hasItems and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(80, 80, 80)
	rebirthButton.Text = canAfford and hasItems and "🌟 REBIRTH" or "❌ REQUIREMENTS NOT MET"
	rebirthButton.Font = Enum.Font.GothamBold
	rebirthButton.TextSize = 16
	rebirthButton.TextColor3 = Color3.fromRGB(0, 0, 0)
	rebirthButton.ZIndex = 54
	rebirthButton.LayoutOrder = itemSelectionButton and 6 or 5
	rebirthButton.Parent = entry

	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 8)
	buttonCorner.Parent = rebirthButton

	local buttonGradient = Instance.new("UIGradient")
	if canAfford and hasItems then
		buttonGradient.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 235, 59)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 193, 7))
		}
	else
		buttonGradient.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 100, 100)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 60, 60))
		}
	end
	buttonGradient.Rotation = 90
	buttonGradient.Parent = rebirthButton

	-- Add selected items display below the rebirth button if items are selected
	if selectedItems and #selectedItems > 0 then
		local selectedItemsFrame = Instance.new("Frame")
		selectedItemsFrame.Name = "SelectedItemsFrame"
		selectedItemsFrame.Size = UDim2.new(1, 0, 0, 120)
		selectedItemsFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
		selectedItemsFrame.BackgroundTransparency = 0.1
		selectedItemsFrame.BorderSizePixel = 0
		selectedItemsFrame.ZIndex = 54
		selectedItemsFrame.LayoutOrder = itemSelectionButton and 7 or 6
		selectedItemsFrame.Parent = entry
		
		local selectedItemsCorner = Instance.new("UICorner")
		selectedItemsCorner.CornerRadius = UDim.new(0, 8)
		selectedItemsCorner.Parent = selectedItemsFrame
		
		local selectedItemsStroke = Instance.new("UIStroke")
		selectedItemsStroke.Color = Color3.fromRGB(100, 255, 100)
		selectedItemsStroke.Thickness = 1
		selectedItemsStroke.Transparency = 0.7
		selectedItemsStroke.Parent = selectedItemsFrame
		
		-- Title
		local title = Instance.new("TextLabel")
		title.Name = "SelectedItemsTitle"
		title.Size = UDim2.new(1, 0, 0, 25)
		title.Position = UDim2.new(0, 0, 0, 0)
		title.Text = "💾 Selected Items to Keep:"
		title.Font = Enum.Font.GothamBold
		title.TextSize = 14
		title.TextColor3 = Color3.fromRGB(100, 255, 100)
		title.TextXAlignment = Enum.TextXAlignment.Center
		title.BackgroundTransparency = 1
		title.ZIndex = 55
		title.Parent = selectedItemsFrame
		
		-- Items grid container
		local gridContainer = Instance.new("Frame")
		gridContainer.Name = "ItemsGridContainer"
		gridContainer.Size = UDim2.new(1, -20, 1, -30)
		gridContainer.Position = UDim2.new(0, 10, 0, 25)
		gridContainer.BackgroundTransparency = 1
		gridContainer.ZIndex = 55
		gridContainer.Parent = selectedItemsFrame
		
		-- Grid layout for 3x1
		local gridLayout = Instance.new("UIGridLayout")
		gridLayout.CellSize = UDim2.new(0.33, -5, 1, 0)
		gridLayout.CellPadding = UDim2.new(0, 5, 0, 0)
		gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		gridLayout.Parent = gridContainer
		
		-- Create item slots
		for i = 1, 3 do
			local itemSlot = Instance.new("Frame")
			itemSlot.Name = "ItemSlot" .. i
			itemSlot.Size = UDim2.new(1, 0, 1, 0)
			itemSlot.BackgroundColor3 = Color3.fromRGB(30, 35, 50)
			itemSlot.BorderSizePixel = 0
			itemSlot.ZIndex = 56
			itemSlot.Parent = gridContainer
			
			local slotCorner = Instance.new("UICorner")
			slotCorner.CornerRadius = UDim.new(0, 6)
			slotCorner.Parent = itemSlot
			
			local slotStroke = Instance.new("UIStroke")
			slotStroke.Color = Color3.fromRGB(80, 120, 200)
			slotStroke.Thickness = 1
			slotStroke.Transparency = 0.5
			slotStroke.Parent = itemSlot
			
			if selectedItems[i] then
				-- Item name label (simplified for now)
				local itemLabel = Instance.new("TextLabel")
				itemLabel.Name = "ItemLabel"
				itemLabel.Size = UDim2.new(1, -10, 1, 0)
				itemLabel.Position = UDim2.new(0, 5, 0, 0)
				itemLabel.Text = selectedItems[i]
				itemLabel.Font = Enum.Font.Gotham
				itemLabel.TextSize = 10
				itemLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
				itemLabel.TextXAlignment = Enum.TextXAlignment.Center
				itemLabel.TextYAlignment = Enum.TextYAlignment.Center
				itemLabel.BackgroundTransparency = 1
				itemLabel.TextWrapped = true
				itemLabel.ZIndex = 57
				itemLabel.Parent = itemSlot
			else
				-- Empty slot
				local emptyLabel = Instance.new("TextLabel")
				emptyLabel.Name = "EmptyLabel"
				emptyLabel.Size = UDim2.new(1, -10, 1, 0)
				emptyLabel.Position = UDim2.new(0, 5, 0, 0)
				emptyLabel.Text = "Empty"
				emptyLabel.Font = Enum.Font.Gotham
				emptyLabel.TextSize = 10
				emptyLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
				emptyLabel.TextXAlignment = Enum.TextXAlignment.Center
				emptyLabel.TextYAlignment = Enum.TextYAlignment.Center
				emptyLabel.BackgroundTransparency = 1
				emptyLabel.ZIndex = 57
				emptyLabel.Parent = itemSlot
			end
		end
	end

	return entry, rebirthButton, itemSelectionButton
end

-- Create selected items display
function RebirthUI.CreateSelectedItemsDisplay(parent, selectedItems)
	-- Clear any existing selected items display
	for _, child in pairs(parent:GetChildren()) do
		if child.Name == "SelectedItemsDisplay" then
			child:Destroy()
		end
	end
	
	if not selectedItems or #selectedItems == 0 then
		return nil
	end
	
	-- Create container for selected items
	local container = Instance.new("Frame")
	container.Name = "SelectedItemsDisplay"
	container.Size = UDim2.new(1, 0, 0, 150) -- Increased height for 3D views
	container.BackgroundColor3 = Color3.fromRGB(24, 28, 40)
	container.BackgroundTransparency = 0.1
	container.BorderSizePixel = 0
	container.ZIndex = 53
	container.LayoutOrder = 999 -- Place at the bottom
	container.Parent = parent
	
	local containerCorner = Instance.new("UICorner")
	containerCorner.CornerRadius = UDim.new(0, 12)
	containerCorner.Parent = container
	
	local containerStroke = Instance.new("UIStroke")
	containerStroke.Color = Color3.fromRGB(100, 255, 100)
	containerStroke.Thickness = 2
	containerStroke.Transparency = 0.7
	containerStroke.Parent = container
	
	-- Title
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0, 30)
	title.Position = UDim2.new(0, 0, 0, 0)
	title.Text = "💾 Selected Items to Keep:"
	title.Font = Enum.Font.GothamBold
	title.TextSize = 18
	title.TextColor3 = Color3.fromRGB(100, 255, 100)
	title.TextXAlignment = Enum.TextXAlignment.Center
	title.BackgroundTransparency = 1
	title.ZIndex = 54
	title.Parent = container
	
	-- Items grid container
	local gridContainer = Instance.new("Frame")
	gridContainer.Name = "GridContainer"
	gridContainer.Size = UDim2.new(1, -20, 1, -40)
	gridContainer.Position = UDim2.new(0, 10, 0, 35)
	gridContainer.BackgroundTransparency = 1
	gridContainer.ZIndex = 54
	gridContainer.Parent = container
	
	-- Grid layout for 3x1
	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.new(0.33, -5, 1, 0)
	gridLayout.CellPadding = UDim2.new(0, 5, 0, 0)
	gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	gridLayout.Parent = gridContainer
	
	-- Create item slots with 3D views
	for i = 1, 3 do
		local itemSlot = Instance.new("Frame")
		itemSlot.Name = "ItemSlot" .. i
		itemSlot.Size = UDim2.new(1, 0, 1, 0)
		itemSlot.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
		itemSlot.BorderSizePixel = 0
		itemSlot.ZIndex = 55
		itemSlot.Parent = gridContainer
		
		local slotCorner = Instance.new("UICorner")
		slotCorner.CornerRadius = UDim.new(0, 8)
		slotCorner.Parent = itemSlot
		
		local slotStroke = Instance.new("UIStroke")
		slotStroke.Color = Color3.fromRGB(80, 120, 200)
		slotStroke.Thickness = 1
		slotStroke.Transparency = 0.5
		slotStroke.Parent = itemSlot
		
		if selectedItems[i] then
			-- Create 3D viewport for the item
			local viewportFrame = Instance.new("ViewportFrame")
			viewportFrame.Name = "ItemViewport"
			viewportFrame.Size = UDim2.new(1, -10, 0.7, 0)
			viewportFrame.Position = UDim2.new(0, 5, 0, 5)
			viewportFrame.BackgroundColor3 = Color3.fromRGB(25, 30, 45)
			viewportFrame.BorderSizePixel = 0
			viewportFrame.ZIndex = 56
			viewportFrame.Parent = itemSlot
			
			local viewportCorner = Instance.new("UICorner")
			viewportCorner.CornerRadius = UDim.new(0, 6)
			viewportCorner.Parent = viewportFrame
			
			-- Add camera to viewport
			local camera = Instance.new("Camera")
			camera.CFrame = CFrame.new(0, 0, 3) * CFrame.Angles(0, 0, 0)
			viewportFrame.CurrentCamera = camera
			viewportFrame.Parent = itemSlot
			
			-- Create a simple 3D model for the item (placeholder)
			local itemModel = Instance.new("Part")
			itemModel.Name = "ItemModel"
			itemModel.Size = Vector3.new(1, 1, 1)
			itemModel.Position = Vector3.new(0, 0, 0)
			itemModel.Anchored = true
			itemModel.CanCollide = false
			itemModel.Material = Enum.Material.Neon
			itemModel.Color = Color3.fromRGB(100, 255, 100)
			itemModel.Parent = viewportFrame
			
			-- Add lighting
			local light = Instance.new("PointLight")
			light.Color = Color3.fromRGB(255, 255, 255)
			light.Range = 10
			light.Brightness = 1
			light.Parent = itemModel
			
			-- Item name label below viewport
			local itemLabel = Instance.new("TextLabel")
			itemLabel.Name = "ItemLabel"
			itemLabel.Size = UDim2.new(1, -10, 0.25, 0)
			itemLabel.Position = UDim2.new(0, 5, 0.75, 0)
			itemLabel.Text = selectedItems[i]
			itemLabel.Font = Enum.Font.Gotham
			itemLabel.TextSize = 10
			itemLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			itemLabel.TextXAlignment = Enum.TextXAlignment.Center
			itemLabel.TextYAlignment = Enum.TextYAlignment.Center
			itemLabel.BackgroundTransparency = 1
			itemLabel.TextWrapped = true
			itemLabel.ZIndex = 56
			itemLabel.Parent = itemSlot
		else
			-- Empty slot
			local emptyLabel = Instance.new("TextLabel")
			emptyLabel.Name = "EmptyLabel"
			emptyLabel.Size = UDim2.new(1, -10, 1, 0)
			emptyLabel.Position = UDim2.new(0, 5, 0, 0)
			emptyLabel.Text = "Empty"
			emptyLabel.Font = Enum.Font.Gotham
			emptyLabel.TextSize = 12
			emptyLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
			emptyLabel.TextXAlignment = Enum.TextXAlignment.Center
			emptyLabel.TextYAlignment = Enum.TextYAlignment.Center
			emptyLabel.BackgroundTransparency = 1
			emptyLabel.ZIndex = 56
			emptyLabel.Parent = itemSlot
		end
	end
	
	return container
end

return RebirthUI 