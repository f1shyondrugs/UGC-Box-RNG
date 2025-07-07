local BoostersUI = {}
local Players = game:GetService("Players")

function BoostersUI.Create(parent, boosters, onBoosterClick)
	local iconSize = 24
	local rowSpacing = 6
	
	-- Main container for both rows
	local mainContainer = Instance.new("Frame")
	mainContainer.Name = "BoostersMainContainer"
	mainContainer.AnchorPoint = Vector2.new(0, 1)
	mainContainer.Position = UDim2.new(0, 16, 1, -16)
	mainContainer.Size = UDim2.new(0, #boosters * iconSize + (#boosters-1) * 4, 0, 2 * iconSize + rowSpacing)
	mainContainer.BackgroundTransparency = 1
	mainContainer.BorderSizePixel = 0
	mainContainer.ZIndex = 100
	mainContainer.Parent = parent

	local listLayout = Instance.new("UIListLayout")
	listLayout.Parent = mainContainer
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding = UDim.new(0, rowSpacing)

	-- Top row container (Rebirth/Free2Play features)
	local topRowContainer = Instance.new("Frame")
	topRowContainer.Name = "TopRowContainer"
	topRowContainer.Size = UDim2.new(0, #boosters * iconSize + (#boosters-1) * 4, 0, iconSize)
	topRowContainer.BackgroundTransparency = 1
	topRowContainer.LayoutOrder = 1
	topRowContainer.Parent = mainContainer

	-- Bottom row container (Gamepasses)
	local bottomRowContainer = Instance.new("Frame")
	bottomRowContainer.Name = "BottomRowContainer"
	bottomRowContainer.Size = UDim2.new(0, #boosters * iconSize + (#boosters-1) * 4, 0, iconSize)
	bottomRowContainer.BackgroundTransparency = 1
	bottomRowContainer.LayoutOrder = 2
	bottomRowContainer.Parent = mainContainer

	local bottomListLayout = Instance.new("UIListLayout")
	bottomListLayout.Parent = bottomRowContainer
	bottomListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	bottomListLayout.Padding = UDim.new(0, 4)
	bottomListLayout.FillDirection = Enum.FillDirection.Horizontal

	-- Tooltip
	local tooltip = Instance.new("Frame")
	tooltip.Name = "BoosterTooltip"
	tooltip.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
	tooltip.BackgroundTransparency = 0.1
	tooltip.BorderSizePixel = 0
	tooltip.Visible = false
	tooltip.ZIndex = 200
	tooltip.AnchorPoint = Vector2.new(0, 1)
	tooltip.Parent = parent

	local tooltipTitle = Instance.new("TextLabel")
	tooltipTitle.Name = "TooltipTitle"
	tooltipTitle.Size = UDim2.new(1, -10, 0, 14)
	tooltipTitle.Position = UDim2.new(0, 5, 0, 3)
	tooltipTitle.BackgroundTransparency = 1
	tooltipTitle.Font = Enum.Font.GothamBold
	tooltipTitle.TextSize = 12
	tooltipTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	tooltipTitle.TextXAlignment = Enum.TextXAlignment.Left
	tooltipTitle.ZIndex = 201
	tooltipTitle.Parent = tooltip

	local tooltipDesc = Instance.new("TextLabel")
	tooltipDesc.Name = "TooltipDesc"
	tooltipDesc.Size = UDim2.new(1, -10, 0, 0) -- Height will be set dynamically
	tooltipDesc.Position = UDim2.new(0, 5, 0, 18)
	tooltipDesc.BackgroundTransparency = 1
	tooltipDesc.Font = Enum.Font.Gotham
	tooltipDesc.TextSize = 10
	tooltipDesc.TextColor3 = Color3.fromRGB(180, 200, 255)
	tooltipDesc.TextXAlignment = Enum.TextXAlignment.Left
	tooltipDesc.TextWrapped = true
	tooltipDesc.ZIndex = 201
	tooltipDesc.AutomaticSize = Enum.AutomaticSize.Y
	tooltipDesc.Parent = tooltip

	local titleConstraint = Instance.new("UITextSizeConstraint")
	titleConstraint.MaxTextSize = 12
	titleConstraint.Parent = tooltipTitle

	local descConstraint = Instance.new("UITextSizeConstraint")
	descConstraint.MaxTextSize = 10
	descConstraint.Parent = tooltipDesc

	-- Create Rebirth Luck icon in top row
	local rebirthLuckIcon = Instance.new("ImageLabel")
	rebirthLuckIcon.Name = "RebirthLuckIcon"
	rebirthLuckIcon.Size = UDim2.new(0, iconSize, 0, iconSize)
	rebirthLuckIcon.BackgroundTransparency = 1
	rebirthLuckIcon.Image = "rbxassetid://104355205832486"
	rebirthLuckIcon.ZIndex = 101
	rebirthLuckIcon.Parent = topRowContainer

	-- Create rebirth luck label
	local rebirthLuckLabel = Instance.new("TextLabel")
	rebirthLuckLabel.Name = "RebirthLuckLabel"
	rebirthLuckLabel.Size = UDim2.new(0, 60, 0, 14)
	rebirthLuckLabel.Position = UDim2.new(0, iconSize + 6, 0.5, -7)
	rebirthLuckLabel.BackgroundTransparency = 1
	rebirthLuckLabel.Text = "+0%"
	rebirthLuckLabel.Font = Enum.Font.GothamBold
	rebirthLuckLabel.TextSize = 10
	rebirthLuckLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	rebirthLuckLabel.TextXAlignment = Enum.TextXAlignment.Left
	rebirthLuckLabel.ZIndex = 101
	rebirthLuckLabel.Parent = topRowContainer

	-- Store rebirth luck components for external updates
	BoostersUI.RebirthLuckComponents = {
		Icon = rebirthLuckIcon,
		Label = rebirthLuckLabel
	}

	-- Hover logic for rebirth luck
	rebirthLuckIcon.MouseEnter:Connect(function()
		tooltip.Visible = true
		tooltipTitle.Text = "Rebirth Luck"
		tooltipDesc.Text = "Your current rebirth luck bonus from completed rebirths!"
		-- Calculate width based on the longest line
		local padding = 16
		local minWidth = 120
		local textService = game:GetService("TextService")
		local titleWidth = textService:GetTextSize(tooltipTitle.Text, 12, Enum.Font.GothamBold, Vector2.new(10000, 14)).X
		local descWidth = textService:GetTextSize(tooltipDesc.Text, 10, Enum.Font.Gotham, Vector2.new(10000, 100)).X
		local width = math.max(titleWidth, descWidth) + padding
		if width < minWidth then width = minWidth end
		tooltipTitle.Size = UDim2.new(1, -10, 0, 14)
		tooltipDesc.Size = UDim2.new(1, -10, 0, tooltipDesc.TextBounds.Y)
		local totalHeight = 8 + tooltipTitle.AbsoluteSize.Y + tooltipDesc.TextBounds.Y
		tooltip.Size = UDim2.new(0, width, 0, totalHeight)
		-- Position tooltip to the right of the icon
		local absPos = rebirthLuckIcon.AbsolutePosition
		local absSize = rebirthLuckIcon.AbsoluteSize
		tooltip.Position = UDim2.new(0, absPos.X + absSize.X + 8 - parent.AbsolutePosition.X, 0, absPos.Y + absSize.Y/2 - parent.AbsolutePosition.Y)
	end)
	rebirthLuckIcon.MouseLeave:Connect(function()
		tooltip.Visible = false
	end)

	-- Create all gamepass icons in bottom row
	for i, booster in ipairs(boosters) do
		local iconBtn = Instance.new(booster.Locked and "ImageButton" or "ImageLabel")
		iconBtn.Name = booster.Name .. "Icon"
		iconBtn.Size = UDim2.new(0, iconSize, 0, iconSize)
		iconBtn.BackgroundTransparency = 1
		iconBtn.LayoutOrder = i
		-- Use the provided asset for Premium
		if booster.Name == "Premium Booster" then
			iconBtn.Image = "rbxasset://textures/ui/PlayerList/PremiumIcon@3x.png"
		else
			iconBtn.Image = booster.Icon
		end
		iconBtn.ZIndex = 101
		iconBtn.Parent = bottomRowContainer
		if booster.Locked then
			iconBtn.MouseButton1Click:Connect(function()
				onBoosterClick(booster)
			end)
		end

		-- Hover logic
		iconBtn.MouseEnter:Connect(function()
			tooltip.Visible = true
			tooltipTitle.Text = booster.Name
			tooltipDesc.Text = booster.Description
			-- Calculate width based on the longest line
			local padding = 16
			local minWidth = 120
			local textService = game:GetService("TextService")
			local titleWidth = textService:GetTextSize(tooltipTitle.Text, 12, Enum.Font.GothamBold, Vector2.new(10000, 14)).X
			local descWidth = textService:GetTextSize(tooltipDesc.Text, 10, Enum.Font.Gotham, Vector2.new(10000, 100)).X
			local width = math.max(titleWidth, descWidth) + padding
			if width < minWidth then width = minWidth end
			tooltipTitle.Size = UDim2.new(1, -10, 0, 14)
			tooltipDesc.Size = UDim2.new(1, -10, 0, tooltipDesc.TextBounds.Y)
			local totalHeight = 8 + tooltipTitle.AbsoluteSize.Y + tooltipDesc.TextBounds.Y
			tooltip.Size = UDim2.new(0, width, 0, totalHeight)
			-- Position tooltip to the right of the icon
			local absPos = iconBtn.AbsolutePosition
			local absSize = iconBtn.AbsoluteSize
			tooltip.Position = UDim2.new(0, absPos.X + absSize.X + 8 - parent.AbsolutePosition.X, 0, absPos.Y + absSize.Y/2 - parent.AbsolutePosition.Y)
		end)
		iconBtn.MouseLeave:Connect(function()
			tooltip.Visible = false
		end)
	end

	return mainContainer
end

-- Function to update rebirth luck display
function BoostersUI.UpdateRebirthLuck(luckBonus)
	if BoostersUI.RebirthLuckComponents and BoostersUI.RebirthLuckComponents.Label then
		BoostersUI.RebirthLuckComponents.Label.Text = string.format("+%d%%", luckBonus or 0)
	end
end

return BoostersUI 