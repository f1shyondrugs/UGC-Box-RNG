-- NameplateUI.lua
-- This module is responsible for creating the visual components of a player's overhead nameplate.

local ItemValueCalculator = require(game:GetService("ReplicatedStorage").Shared.Modules.ItemValueCalculator)

local NameplateUI = {}

function NameplateUI.Create(targetPlayer)
	local components = {}

	-- The BillboardGui is what makes the UI render in the 3D world.
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "Nameplate"
	billboardGui.AlwaysOnTop = true
	billboardGui.Size = UDim2.new(0, 200, 0, 60)
	billboardGui.StudsOffset = Vector3.new(0, 2.5, 0) -- Position it above the player's head
	components.BillboardGui = billboardGui

	-- A container frame for better organization and background
	local backgroundFrame = Instance.new("Frame")
	backgroundFrame.Name = "Background"
	backgroundFrame.Size = UDim2.new(1, 0, 1, 0)
	backgroundFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	backgroundFrame.BackgroundTransparency = 0.4
	backgroundFrame.Parent = billboardGui
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = backgroundFrame

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(0, 0, 0)
	stroke.Transparency = 0.5
	stroke.Parent = backgroundFrame

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
	usernameLabel.TextSize = 20
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
	rapLabel.TextSize = 16
	rapLabel.Parent = backgroundFrame
	components.RAPLabel = rapLabel
	
	return components
end

function NameplateUI.UpdateRAP(components, rapValue)
	components.RAPLabel.Text = "RAP: " .. ItemValueCalculator.GetFormattedRAP(rapValue)
end

return NameplateUI 