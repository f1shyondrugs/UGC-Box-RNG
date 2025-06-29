local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local NavigationController = require(script.Parent.NavigationController)
local Shared = ReplicatedStorage.Shared
local Remotes = require(Shared.Remotes.Remotes)
local UpgradeConfig = require(Shared.Modules.UpgradeConfig)
local UpgradeUI = require(script.Parent.Parent.UI.UpgradeUI)

local UpgradeController = {}

local ui = nil
local upgradeData = {}
local isVisible = false
local soundController = nil

-- Animation settings
local ANIMATION_TIME = 0.3
local EASE_INFO = TweenInfo.new(ANIMATION_TIME, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local function updateUpgradeDisplay()
	if not ui then return end

	-- Clear existing upgrade frames
	for _, frame in pairs(ui.UpgradeFrames) do
		if frame.Frame then
			frame.Frame:Destroy()
		end
	end
	ui.UpgradeFrames = {}

	-- Create upgrade frames for each upgrade
	local layoutOrder = 0
	for upgradeId, data in pairs(upgradeData) do
		layoutOrder = layoutOrder + 1
		local upgradeFrame = UpgradeUI.CreateUpgradeFrame(ui.ScrollingFrame, upgradeId, data)
		if upgradeFrame then
			upgradeFrame.Frame.LayoutOrder = layoutOrder
			ui.UpgradeFrames[upgradeId] = upgradeFrame

			-- Connect upgrade button
			upgradeFrame.UpgradeButton.MouseButton1Click:Connect(function()
				if soundController then
					soundController:playUIClick()
				end
				
				if not data.isMaxLevel then
					Remotes.PurchaseUpgrade:FireServer(upgradeId)
				end
			end)
		end
	end

	-- Update scroll frame canvas size
	ui.ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, layoutOrder * 135) -- 120 height + 15 padding
end

local function refreshUpgradeData()
	local success, newUpgradeData = pcall(function()
		return Remotes.GetUpgradeData:InvokeServer()
	end)
	
	if success and newUpgradeData then
		upgradeData = newUpgradeData
		updateUpgradeDisplay()
		
		-- Update affordability based on current money
		local playerMoney = LocalPlayer:GetAttribute("RobuxValue") or 0
		if ui then
			UpgradeUI.UpdateAffordability(ui, playerMoney)
		end
	end
end

local function toggleUpgradeGUI()
	if not ui then return end

	isVisible = not isVisible
	
	if isVisible then
		ui.MainFrame.Visible = true
		-- Animate in
		ui.MainFrame.Size = UDim2.new(0, 0, 0, 0)
		ui.MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
		ui.MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
		
		local tweenIn = TweenService:Create(ui.MainFrame, EASE_INFO, {
			Size = UDim2.new(1, -60, 1, -60),
			Position = UDim2.new(0, 30, 0, 30),
			AnchorPoint = Vector2.new(0, 0)
		})
		tweenIn:Play()
		
		-- Refresh data when opening
		refreshUpgradeData()
	else
		-- Animate out
		local tweenOut = TweenService:Create(ui.MainFrame, EASE_INFO, {
			Size = UDim2.new(0, 0, 0, 0),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5)
		})
		tweenOut:Play()
		
		tweenOut.Completed:Connect(function()
			ui.MainFrame.Visible = false
		end)
	end
end

function UpgradeController.Start(parentGui, soundControllerRef)
	soundController = soundControllerRef
	
	-- Create UI
	ui = UpgradeUI.Create(parentGui)
	
	-- Register with NavigationController instead of connecting to toggle button
	NavigationController.RegisterController("Upgrade", function()
		toggleUpgradeGUI()
	end)
	
	-- Connect close button
	ui.CloseButton.MouseButton1Click:Connect(function()
		if soundController then
			soundController:playUIClick()
		end
		if isVisible then
			toggleUpgradeGUI()
		end
	end)
	
	-- Handle upgrade updates from server
	Remotes.UpgradeUpdated.OnClientEvent:Connect(function(upgradeId, newLevel)
		-- Update local upgrade data
		if upgradeData[upgradeId] then
			upgradeData[upgradeId].level = newLevel
			upgradeData[upgradeId].cost = UpgradeConfig.GetUpgradeCost(upgradeId, newLevel)
			upgradeData[upgradeId].effects = UpgradeConfig.GetUpgradeEffects(upgradeId, newLevel)
			upgradeData[upgradeId].isMaxLevel = UpgradeConfig.IsMaxLevel(upgradeId, newLevel)
			
			-- Update the specific upgrade frame
			local upgradeFrame = ui.UpgradeFrames[upgradeId]
			if upgradeFrame then
				UpgradeUI.UpdateUpgradeFrame(upgradeFrame, upgradeId, upgradeData[upgradeId])
			end
		end
	end)
	
	-- Handle max boxes update
	Remotes.MaxBoxesUpdated.OnClientEvent:Connect(function(newMaxBoxes)
		-- This will be handled by updating the MAX_BOXES variable in the main client
		-- We'll send this data to the main client through a different mechanism
		script.Parent.Parent.Main:SetAttribute("MaxBoxes", newMaxBoxes)
	end)
	
	-- Monitor money changes for affordability updates
	-- Use attribute changes to get raw numeric values instead of formatted strings
	LocalPlayer:GetAttributeChangedSignal("RobuxValue"):Connect(function()
		local playerMoney = LocalPlayer:GetAttribute("RobuxValue") or 0
		if ui then
			UpgradeUI.UpdateAffordability(ui, playerMoney)
		end
	end)
	
	-- Close GUI when clicking outside
	game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 and isVisible then
			local mouse = game:GetService("Players").LocalPlayer:GetMouse()
			local frame = ui.MainFrame
			
			-- Check if click was outside the main frame
			if frame.Visible then
				local mousePos = Vector2.new(mouse.X, mouse.Y)
				local framePos = frame.AbsolutePosition
				local frameSize = frame.AbsoluteSize
				
				local isOutside = mousePos.X < framePos.X or mousePos.X > framePos.X + frameSize.X or
				                  mousePos.Y < framePos.Y or mousePos.Y > framePos.Y + frameSize.Y
				
				if isOutside then
					toggleUpgradeGUI()
				end
			end
		end
	end)
	
	-- Initial data load
	refreshUpgradeData()
end

return UpgradeController 