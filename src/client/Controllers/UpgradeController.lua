local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local MarketplaceService = game:GetService("MarketplaceService")

local LocalPlayer = Players.LocalPlayer
local NavigationController = require(script.Parent.NavigationController)
local Shared = ReplicatedStorage.Shared
local Remotes = require(Shared.Remotes.Remotes)
local UpgradeConfig = require(Shared.Modules.UpgradeConfig)
local UpgradeUI = require(script.Parent.Parent.UI.UpgradeUI)
local GameConfig = require(Shared.Modules.GameConfig)

local UpgradeController = {}

local ui = nil
local upgradeData = {}
local isVisible = false
local soundController = nil
local hiddenUIs = {}

-- Infinite Storage gamepass variables
local INFINITE_STORAGE_GAMEPASS_ID = GameConfig.InfiniteStorageGamepassId
local hasInfiniteStorageGamepass = false

-- Animation settings
local ANIMATION_TIME = 0.3
local EASE_INFO = TweenInfo.new(ANIMATION_TIME, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

-- Hide other UIs for clean upgrade experience
local function hideOtherUIs(show)
	local playerGui = LocalPlayer:WaitForChild("PlayerGui")
	
	if show then
		-- Hide other UIs for clean upgrade experience
		for _, gui in pairs(playerGui:GetChildren()) do
			if gui:IsA("ScreenGui") and gui.Name ~= "UpgradeGui" then
				-- Don't hide tutorial GUI
				if gui.Name == "TutorialGui" then
					continue
				end
				
				if gui.Enabled then
					hiddenUIs[gui] = true
					gui.Enabled = false
				end
			end
		end
		
		-- Also hide CoreGui elements
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
	else
		-- Restore hidden UIs
		for gui, _ in pairs(hiddenUIs) do
			if gui and gui.Parent then
				gui.Enabled = true
			end
		end
		hiddenUIs = {}
		
		-- Restore CoreGui
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
	end
end

-- Infinite Storage gamepass checking
local function checkInfiniteStorageGamepass()
	local isWhitelisted = false
	for _, id in ipairs(GameConfig.GamepassWhitelist or {}) do
		if LocalPlayer.UserId == id then
			isWhitelisted = true
			break
		end
	end

	if isWhitelisted then
		hasInfiniteStorageGamepass = true
		return true
	end

	local success, owns = pcall(function()
		return Remotes.CheckInfiniteStorageGamepass:InvokeServer()
	end)
	
	if success then
		hasInfiniteStorageGamepass = owns
	else
		hasInfiniteStorageGamepass = false
		warn("Failed to check Infinite Storage gamepass ownership")
	end
	
	return hasInfiniteStorageGamepass
end

local function promptInfiniteStorageGamepassPurchase()
	if soundController then
		soundController:playUIClick()
	end
	
	local success, errorMsg = pcall(function()
		MarketplaceService:PromptGamePassPurchase(LocalPlayer, INFINITE_STORAGE_GAMEPASS_ID)
	end)
	
	if not success then
		warn("Failed to prompt Infinite Storage gamepass purchase:", errorMsg)
	end
end

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
			
			-- Connect infinite storage button for InventorySlots
			if upgradeId == "InventorySlots" and upgradeFrame.InfiniteStorageButton then
				-- Hide button if gamepass already owned
				if hasInfiniteStorageGamepass then
					upgradeFrame.InfiniteStorageButton.Visible = false
				else
					upgradeFrame.InfiniteStorageButton.Visible = true
				end

				upgradeFrame.InfiniteStorageButton.MouseButton1Click:Connect(function()
					if hasInfiniteStorageGamepass then
						-- Already have gamepass, maybe show some info
						if soundController then
							soundController:playUIClick()
						end
					else
						promptInfiniteStorageGamepassPurchase()
					end
				end)
			end
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
		hideOtherUIs(true)
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
		hideOtherUIs(false)
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
	
	-- Check Infinite Storage gamepass ownership
	checkInfiniteStorageGamepass()
	
	-- Monitor gamepass purchase completion
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamepassId, wasPurchased)
		if player == LocalPlayer and gamepassId == INFINITE_STORAGE_GAMEPASS_ID and wasPurchased then
			hasInfiniteStorageGamepass = true
			
			if ui and ui.UpgradeFrames then
				for _, frame in pairs(ui.UpgradeFrames) do
					if frame.InfiniteStorageButton then
						frame.InfiniteStorageButton.Visible = false
					end
				end
			end
			
			if soundController then
				soundController:playUIClick()
			end
		end
	end)
	
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