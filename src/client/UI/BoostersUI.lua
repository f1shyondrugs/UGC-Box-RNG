local BoostersUI = {}
local Players = game:GetService("Players")

function BoostersUI.Create(parent, boosters, onBoosterClick)
	local iconSize = 28
	local iconFrame = Instance.new("Frame")
	iconFrame.Name = "BoostersIconFrame"
	iconFrame.AnchorPoint = Vector2.new(0, 1)
	iconFrame.Position = UDim2.new(0, 16, 1, -16)
	iconFrame.Size = UDim2.new(0, iconSize, 0, #boosters * iconSize + (#boosters-1)*6)
	iconFrame.BackgroundTransparency = 1
	iconFrame.BorderSizePixel = 0
	iconFrame.ZIndex = 100
	iconFrame.Parent = parent

	local listLayout = Instance.new("UIListLayout")
	listLayout.Parent = iconFrame
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding = UDim.new(0, 6)

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

	for i, booster in ipairs(boosters) do
		local iconBtn = Instance.new(booster.Locked and "ImageButton" or "ImageLabel")
		iconBtn.Name = booster.Name .. "Icon"
		iconBtn.Size = UDim2.new(0, iconSize, 0, iconSize)
		iconBtn.BackgroundTransparency = 1
		-- Use the provided asset for Premium
		if booster.Name == "Premium Booster" then
			iconBtn.Image = "rbxasset://textures/ui/PlayerList/PremiumIcon@3x.png"
		else
			iconBtn.Image = booster.Icon
		end
		iconBtn.ZIndex = 101
		iconBtn.Parent = iconFrame
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

	return iconFrame
end

return BoostersUI 