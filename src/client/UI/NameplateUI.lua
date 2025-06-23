-- NameplateUI.lua
-- This module is responsible for creating the visual components of a player's overhead nameplate.

local ItemValueCalculator = require(game:GetService("ReplicatedStorage").Shared.Modules.ItemValueCalculator)
local RankProvider = require(game:GetService("ReplicatedStorage").Shared.Modules.RankProvider)

local NameplateUI = {}

function NameplateUI.Create(targetPlayer)
	local components = {}

	-- The BillboardGui is what makes the UI render in the 3D world.
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "Nameplate"
	billboardGui.AlwaysOnTop = true
	billboardGui.Size = UDim2.new(7, 0, 2, 0) -- Use scale for consistent world-size
	billboardGui.StudsOffset = Vector3.new(0, 2.5, 0) -- Position it above the player's head
	components.BillboardGui = billboardGui

	-- A container frame for better organization and background
	local backgroundFrame = Instance.new("Frame")
	backgroundFrame.Name = "Background"
	backgroundFrame.Size = UDim2.new(1, 0, 1, 0)
	backgroundFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	backgroundFrame.BackgroundTransparency = 1 -- Removed background
	backgroundFrame.Parent = billboardGui
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = backgroundFrame

	-- Username Label
	local usernameLabel = Instance.new("TextLabel")
	usernameLabel.Name = "UsernameLabel"
	usernameLabel.Size = UDim2.new(1, -10, 0.6, 0)
	usernameLabel.Position = UDim2.new(0.5, 0, 0, 0)
	usernameLabel.AnchorPoint = Vector2.new(0.5, 0)
	usernameLabel.BackgroundTransparency = 1
	usernameLabel.Font = Enum.Font.SourceSansBold
	usernameLabel.Text = targetPlayer.Name
	usernameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	usernameLabel.TextSize = 18 -- Adjusted size
	usernameLabel.TextScaled = true -- Scale text to fit
	usernameLabel.Parent = backgroundFrame
	components.UsernameLabel = usernameLabel
	
	-- RAP Label
	local rapLabel = Instance.new("TextLabel")
	rapLabel.Name = "RAPLabel"
	rapLabel.Size = UDim2.new(1, -10, 0.4, 0)
	rapLabel.Position = UDim2.new(0.5, 0, 0.6, 0)
	rapLabel.AnchorPoint = Vector2.new(0.5, 0)
	rapLabel.BackgroundTransparency = 1
	rapLabel.Font = Enum.Font.SourceSans
	rapLabel.Text = "RAP: R$0"
	rapLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
	rapLabel.TextSize = 14 -- Adjusted size
	rapLabel.TextScaled = true -- Scale text to fit
	rapLabel.Parent = backgroundFrame
	components.RAPLabel = rapLabel
	
	return components
end

function NameplateUI.UpdateRAP(components, rapValue, player)
	local rapLabel = components.RAPLabel
	local rank = RankProvider.GetPlayerRank(player)
	local formattedRAP = ItemValueCalculator.GetFormattedRAP(rapValue)

	if rank and rank <= 500 then
		rapLabel.Font = Enum.Font.SourceSansBold
		rapLabel.Text = "#" .. rank .. " RAP: " .. formattedRAP
		
		if rank <= 3 then
			local color
			if rank == 1 then
				color = Color3.fromRGB(255, 215, 0) -- Gold
			elseif rank == 2 then
				color = Color3.fromRGB(192, 192, 192) -- Silver
			else -- Rank 3
				color = Color3.fromRGB(205, 127, 50) -- Bronze
			end
			rapLabel.TextColor3 = color
		else
			rapLabel.TextColor3 = Color3.fromRGB(100, 255, 100) -- Default Green
		end
	else
		rapLabel.Font = Enum.Font.SourceSans
		rapLabel.Text = "RAP: " .. formattedRAP
		rapLabel.TextColor3 = Color3.fromRGB(100, 255, 100) -- Default Green
	end
end

return NameplateUI 