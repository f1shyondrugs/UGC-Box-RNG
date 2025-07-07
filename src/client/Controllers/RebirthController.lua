local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Shared = ReplicatedStorage.Shared

local GameConfig = require(Shared.Modules.GameConfig)
local Remotes = require(Shared.Remotes.Remotes)
local RebirthUI = require(script.Parent.Parent.UI.RebirthUI)
local NumberFormatter = require(Shared.Modules.NumberFormatter)
local CrateSelectionController = require(script.Parent.CrateSelectionController)
local NavigationController = require(script.Parent.NavigationController)

local RebirthController = {}
RebirthController.ClassName = "RebirthController"

-- State
local components = nil
local isVisible = false
local rebirthData = {}
local hiddenUIs = {}
local soundController = nil

-- Check if player is eligible for any rebirth
local function checkRebirthEligibility()
	local currentRebirths = rebirthData.currentRebirth or 0
	local nextRebirthLevel = currentRebirths + 1
	local maxRebirths = GameConfig.RebirthDefaults.MaxRebirths or 20
	
	-- Check if player has reached max rebirths
	if nextRebirthLevel > maxRebirths then
		return false
	end
	
	local rebirthConfig = GameConfig.Rebirths[nextRebirthLevel]
	if not rebirthConfig then
		return false
	end
	
	-- Check money requirement
	local currentMoney = LocalPlayer:GetAttribute("RobuxValue") or 0
	if currentMoney < rebirthConfig.Requirements.Money then
		return false
	end
	
	-- Check item requirements
	local inventory = LocalPlayer:FindFirstChild("Inventory")
	if not inventory then
		return false
	end
	
	local itemCounts = {}
	for _, item in ipairs(inventory:GetChildren()) do
		local itemName = item:GetAttribute("ItemName") or item.Name
		itemCounts[itemName] = (itemCounts[itemName] or 0) + 1
	end
	
	for _, itemReq in ipairs(rebirthConfig.Requirements.Items) do
		if (itemCounts[itemReq.Name] or 0) < itemReq.Amount then
			return false
		end
	end
	
	return true
end

-- Update rebirth notification
local function updateRebirthNotification()
	local isEligible = checkRebirthEligibility()
	NavigationController.SetNotification("Rebirth", isEligible)
end

local function hideOtherUIs(show)
	local playerGui = LocalPlayer:WaitForChild("PlayerGui")
	if show then
		for _, gui in pairs(playerGui:GetChildren()) do
			if gui:IsA("ScreenGui") and gui ~= (components and components.ScreenGui) then
				if gui.Enabled then
					hiddenUIs[gui] = true
					gui.Enabled = false
				end
			end
		end
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
	else
		for gui, _ in pairs(hiddenUIs) do
			if gui and gui.Parent then
				gui.Enabled = true
			end
		end
		hiddenUIs = {}
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
	end
end

-- Check if player has required items for rebirth
local function checkItemRequirements(requirements)
	local inventory = LocalPlayer:FindFirstChild("Inventory")
	if not inventory then return false end
	
	local itemCounts = {}
	for _, item in ipairs(inventory:GetChildren()) do
		local itemName = item:GetAttribute("ItemName") or item.Name
		itemCounts[itemName] = (itemCounts[itemName] or 0) + 1
	end
	
	for _, itemReq in ipairs(requirements.Items) do
		if (itemCounts[itemReq.Name] or 0) < itemReq.Amount then
			return false
		end
	end
	
	return true
end

-- Update the rebirth display
local function updateRebirthDisplay()
	if not components then return end
	
	-- Update current stats
	local currentRebirths = rebirthData.currentRebirth or 0
	local currentLuckBonus = rebirthData.luckBonus or 0
	local currentMoney = LocalPlayer:GetAttribute("RobuxValue") or 0
	
	components.CurrentStatsInfo.Text = string.format(
		"Rebirths: %d | Luck Bonus: %d%% | Money: %s R$",
		currentRebirths,
		currentLuckBonus,
		NumberFormatter.FormatCurrency(currentMoney)
	)
	
	-- Clear existing rebirth entries
	for _, child in pairs(components.RebirthContainer:GetChildren()) do
		if child:IsA("Frame") and child.Name:match("RebirthEntry") then
			child:Destroy()
		end
	end
	
	-- Create rebirth entries
	local nextRebirthLevel = currentRebirths + 1
	local maxRebirths = GameConfig.RebirthDefaults.MaxRebirths or 5
	
	if nextRebirthLevel <= maxRebirths then
		local rebirthConfig = GameConfig.Rebirths[nextRebirthLevel]
		if rebirthConfig then
			-- Check requirements
			local canAfford = currentMoney >= rebirthConfig.Requirements.Money
			local hasItems = checkItemRequirements(rebirthConfig.Requirements)
			
			local entry, rebirthButton = RebirthUI.CreateRebirthEntry(nextRebirthLevel, rebirthConfig, canAfford, hasItems)
			entry.LayoutOrder = nextRebirthLevel
			entry.Parent = components.RebirthContainer
			
			-- Connect rebirth button
			rebirthButton.MouseButton1Click:Connect(function()
				if canAfford and hasItems then
					-- Show confirmation dialog
					local confirmationDialog = RebirthUI.CreateConfirmationDialog(
						LocalPlayer.PlayerGui,
						rebirthConfig,
						function() -- onConfirm
							RebirthController:PerformRebirth(nextRebirthLevel)
						end,
						function() -- onCancel
							-- Do nothing, just close dialog
						end
					)
				else
					-- Show error message
					if soundController then
						soundController:playUIClick()
					end
				end
			end)
		end
	else
		-- Max rebirths reached
		local maxReachedLabel = Instance.new("TextLabel")
		maxReachedLabel.Name = "MaxReachedLabel"
		maxReachedLabel.Size = UDim2.new(1, 0, 0, 100)
		maxReachedLabel.Text = "🏆 Congratulations!\nYou have reached the maximum rebirth level!"
		maxReachedLabel.Font = Enum.Font.GothamBold
		maxReachedLabel.TextSize = 18
		maxReachedLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
		maxReachedLabel.TextXAlignment = Enum.TextXAlignment.Center
		maxReachedLabel.TextYAlignment = Enum.TextYAlignment.Center
		maxReachedLabel.BackgroundTransparency = 1
		maxReachedLabel.ZIndex = 53
		maxReachedLabel.Parent = components.RebirthContainer
	end
end

-- Perform rebirth
function RebirthController:PerformRebirth(rebirthLevel)
	if not components then return end
	
	local success, result = pcall(function()
		return Remotes.PerformRebirth:InvokeServer(rebirthLevel)
	end)
	
	if success and result.success then
		-- Update local data
		rebirthData = result.rebirthData
		
		-- Play rebirth animation
		self:PlayRebirthAnimation(rebirthLevel, result.rebirthData)
		
	else
		-- Show error message
		warn("Rebirth failed:", result and result.error or "Unknown error")
		if soundController then
			soundController:playUIClick()
		end
	end
end

-- Play epic rebirth animation
function RebirthController:PlayRebirthAnimation(rebirthLevel, rebirthData)
	local playerGui = LocalPlayer.PlayerGui
	
	-- Hide all other GUIs
	local hiddenGuis = {}
	for _, gui in ipairs(playerGui:GetChildren()) do
		if gui:IsA("ScreenGui") and gui.Enabled then
			hiddenGuis[gui] = true
			gui.Enabled = false
		end
	end
	
	-- Create fullscreen overlay
	local overlay = Instance.new("ScreenGui")
	overlay.Name = "RebirthAnimationOverlay"
	overlay.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	overlay.IgnoreGuiInset = true
	overlay.ResetOnSpawn = false
	overlay.Parent = playerGui
	
	-- Background with blur effect
	local background = Instance.new("Frame")
	background.Name = "Background"
	background.Size = UDim2.new(1, 0, 1, 0)
	background.Position = UDim2.new(0, 0, 0, 0)
	background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	background.BackgroundTransparency = 1
	background.ZIndex = 1000
	background.Parent = overlay
	
	-- Add blur effect
	local blur = Instance.new("BlurEffect")
	blur.Size = 0
	blur.Parent = background
	
	-- Phase 3: Fade Out
	local function startFadeOut()
		-- Fade out all elements
		local fadeOut = TweenService:Create(overlay, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			BackgroundTransparency = 1
		})
		fadeOut:Play()
		
		-- Reduce blur
		local blurOut = TweenService:Create(blur, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Size = 0
		})
		blurOut:Play()
		
		-- Clean up after animation
		fadeOut.Completed:Connect(function()
			overlay:Destroy()
			-- Restore all hidden GUIs
			for gui, _ in pairs(hiddenGuis) do
				if gui and gui.Parent then gui.Enabled = true end
			end
			-- Update display
			updateRebirthDisplay()
		end)
	end
	
	-- Phase 2: Main Animation with Text
	local function startMainAnimation()
		-- Create main text container
		local textContainer = Instance.new("Frame")
		textContainer.Name = "TextContainer"
		textContainer.Size = UDim2.new(0, 800, 0, 400)
		textContainer.Position = UDim2.new(0.5, -400, 0.5, -200)
		textContainer.BackgroundTransparency = 1
		textContainer.ZIndex = 1001
		textContainer.Parent = overlay
		
		-- Rewards text
		local rewardsText = Instance.new("TextLabel")
		rewardsText.Name = "RewardsText"
		rewardsText.Size = UDim2.new(1, 0, 0, 120)
		rewardsText.Position = UDim2.new(0.5, -400, 0.55, -60)
		
		-- Get rebirth config for detailed rewards
		local rebirthConfig = GameConfig.Rebirths[rebirthLevel]
		local rewardsLines = {}
		table.insert(rewardsLines, "✨ +" .. (rebirthData.luckBonus or 0) .. "% Luck Bonus")
		
		if rebirthConfig and rebirthConfig.Rewards.UnlockedCrates then
			for _, crateName in ipairs(rebirthConfig.Rewards.UnlockedCrates) do
				table.insert(rewardsLines, "🎁 Unlocked: " .. crateName)
			end
		end
		
		rewardsText.Text = table.concat(rewardsLines, "\n")
		rewardsText.Font = Enum.Font.GothamBold
		rewardsText.TextSize = 48
		rewardsText.TextColor3 = Color3.fromRGB(100, 255, 255)
		rewardsText.TextXAlignment = Enum.TextXAlignment.Center
		rewardsText.TextYAlignment = Enum.TextYAlignment.Center
		rewardsText.BackgroundTransparency = 1
		rewardsText.ZIndex = 9999
		rewardsText.Parent = textContainer
		
		-- Click to continue text
		local clickText = Instance.new("TextLabel")
		clickText.Name = "ClickText"
		clickText.Size = UDim2.new(1, 0, 0, 40)
		clickText.Position = UDim2.new(0.5, -400, 0.7, -20)
		clickText.Text = "Click anywhere to continue..."
		clickText.Font = Enum.Font.Gotham
		clickText.TextSize = 28
		clickText.TextColor3 = Color3.fromRGB(200, 200, 200)
		clickText.TextXAlignment = Enum.TextXAlignment.Center
		clickText.TextYAlignment = Enum.TextYAlignment.Center
		clickText.BackgroundTransparency = 1
		clickText.ZIndex = 9999
		clickText.Parent = textContainer
		
		-- Animate text appearance
		rewardsText.TextTransparency = 1
		clickText.TextTransparency = 1
		
		-- Dramatic text reveal with shake
		task.wait(0.5)
		
		-- Rewards text animation
		local rewardsTween = TweenService:Create(rewardsText, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			TextTransparency = 0
		})
		rewardsTween:Play()
		
		-- Show click text
		task.wait(1)
		local clickTween = TweenService:Create(clickText, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			TextTransparency = 0
		})
		clickTween:Play()
		
		-- Add pulsing effect to click text
		local pulseConnection
		pulseConnection = game:GetService("RunService").Heartbeat:Connect(function()
			local time = tick()
			local pulse = math.sin(time * 2) * 0.3 + 0.7
			clickText.TextTransparency = pulse
		end)
		
		-- Wait for click
		local clicked = false
		local function closeOverlay()
			if overlay and overlay.Parent then overlay:Destroy() end
			for gui, _ in pairs(hiddenGuis) do if gui and gui.Parent then gui.Enabled = true end end
			updateRebirthDisplay()
		end
		local inputConn
		inputConn = UserInputService.InputBegan:Connect(function(input, gp)
			if not overlay or not overlay.Parent then return end
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.Keyboard then
				print('UserInputService InputBegan:', input.UserInputType)
				if inputConn then inputConn:Disconnect() end
				if pulseConnection then pulseConnection:Disconnect() end
				closeOverlay()
			end
		end)
		
		-- Auto-continue after 5 seconds
		task.wait(5)
		if not clicked then
			if inputConn then inputConn:Disconnect() end
			if pulseConnection then
				pulseConnection:Disconnect()
			end
			closeOverlay()
		end
	end
	
	-- Phase 1: Buildup Animation
	local function startBuildup()
		-- Fade in background
		local fadeIn = TweenService:Create(background, TweenInfo.new(1.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0.3
		})
		fadeIn:Play()
		
		-- Increase blur gradually
		local blurTween = TweenService:Create(blur, TweenInfo.new(2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Size = 20
		})
		blurTween:Play()
		
		-- Add particle effects
		local particles = Instance.new("Frame")
		particles.Name = "Particles"
		particles.Size = UDim2.new(1, 0, 1, 0)
		particles.Position = UDim2.new(0, 0, 0, 0)
		particles.BackgroundTransparency = 1
		particles.ZIndex = 1001
		particles.Parent = overlay
		
		-- Create floating particles
		for i = 1, 20 do
			local particle = Instance.new("TextLabel")
			particle.Name = "Particle" .. i
			particle.Size = UDim2.new(0, 20, 0, 20)
			particle.Position = UDim2.new(math.random(), 0, math.random(), 0)
			particle.Text = "✨"
			particle.Font = Enum.Font.GothamBold
			particle.TextSize = math.random(16, 32)
			particle.TextColor3 = Color3.fromRGB(255, 215, 0)
			particle.TextTransparency = 1
			particle.BackgroundTransparency = 1
			particle.ZIndex = 1002
			particle.Parent = particles
			
			-- Animate particle
			local particleTween = TweenService:Create(particle, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				TextTransparency = 0,
				Position = UDim2.new(math.random(), 0, math.random(), 0)
			})
			particleTween:Play()
		end
		
		-- Camera shake buildup
		local camera = workspace.CurrentCamera
		local originalCFrame = camera.CFrame
		local shakeIntensity = 0
		
		local shakeConnection
		shakeConnection = game:GetService("RunService").Heartbeat:Connect(function()
			shakeIntensity = shakeIntensity + 0.1
			local shakeOffset = Vector3.new(
				math.sin(shakeIntensity * 10) * shakeIntensity * 0.5,
				math.cos(shakeIntensity * 8) * shakeIntensity * 0.3,
				math.sin(shakeIntensity * 12) * shakeIntensity * 0.2
			)
			camera.CFrame = originalCFrame + shakeOffset
		end)
		
		-- Play buildup sound
		if soundController then
			soundController:playUIClick()
		end
		
		-- After buildup, start the main animation
		task.wait(2.5)
		shakeConnection:Disconnect()
		camera.CFrame = originalCFrame
		startMainAnimation()
	end
	

	
	-- Start the animation sequence
	startBuildup()
end

function RebirthController:Start()
	print("[RebirthController] Starting...")
	
	-- Create UI components
	components = RebirthUI.Create(LocalPlayer.PlayerGui)
	
	-- Set up connections
	self:SetupConnections()
	
	-- Load initial rebirth data
	self:LoadRebirthData()
	
	print("[RebirthController] Started successfully!")
end

function RebirthController:SetupConnections()
	-- Close button connection
	components.CloseButton.MouseButton1Click:Connect(function()
		if soundController then
			soundController:playUIClick()
		end
		self:Hide()
	end)
	
	-- Handle UI scaling when viewport changes
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		if components.UpdateScale then
			components.UpdateScale()
		end
	end)
	
	-- Listen for rebirth updates from server
	Remotes.RebirthUpdated.OnClientEvent:Connect(function(newRebirthData)
		rebirthData = newRebirthData
		if isVisible then
			updateRebirthDisplay()
		end
		-- Refresh crate selection UI after rebirth
		if CrateSelectionController and CrateSelectionController.InitializeCrates then
			CrateSelectionController:InitializeCrates()
		end
		-- Update rebirth notification
		updateRebirthNotification()
	end)
	
	-- Listen for money changes to update affordability
	LocalPlayer:GetAttributeChangedSignal("RobuxValue"):Connect(function()
		if isVisible then
			updateRebirthDisplay()
		end
		-- Update rebirth notification when money changes
		updateRebirthNotification()
	end)
	
	-- Listen for inventory changes to update rebirth eligibility
	local inventory = LocalPlayer:FindFirstChild("Inventory")
	if inventory then
		inventory.ChildAdded:Connect(function()
			updateRebirthNotification()
		end)
		
		inventory.ChildRemoved:Connect(function()
			updateRebirthNotification()
		end)
	else
		-- Wait for inventory to be created
		LocalPlayer.ChildAdded:Connect(function(child)
			if child.Name == "Inventory" then
				child.ChildAdded:Connect(function()
					updateRebirthNotification()
				end)
				
				child.ChildRemoved:Connect(function()
					updateRebirthNotification()
				end)
			end
		end)
	end
end

function RebirthController:LoadRebirthData()
	-- Load rebirth data from server
	local success, data = pcall(function()
		return Remotes.GetRebirthData:InvokeServer()
	end)
	
	if success and data then
		rebirthData = data
		print("[RebirthController] Loaded rebirth data:", data)
	else
		warn("[RebirthController] Failed to load rebirth data")
		rebirthData = {
			currentRebirth = 0,
			luckBonus = 0
		}
	end
	
	-- Update rebirth notification after loading data
	updateRebirthNotification()
end

function RebirthController:Show()
	if not components then return end
	
	isVisible = true
	hideOtherUIs(true)
	
	-- Update display with current data
	updateRebirthDisplay()
	
	components.MainFrame.Visible = true
	
	-- Animate the UI appearing
	components.MainFrame.Size = UDim2.new(0, 0, 0, 0)
	components.MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	
	local showTween = TweenService:Create(
		components.MainFrame,
		TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{
			Size = UDim2.new(0.75, 0, 0.85, 0),
			Position = UDim2.new(0.125, 0, 0.075, 0)
		}
	)
	showTween:Play()
end

function RebirthController:Hide()
	if not components then return end
	
	isVisible = false
	hideOtherUIs(false)
	
	-- Animate the UI disappearing
	local hideTween = TweenService:Create(
		components.MainFrame,
		TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In),
		{
			Size = UDim2.new(0, 0, 0, 0),
			Position = UDim2.new(0.5, 0, 0.5, 0)
		}
	)
	
	hideTween:Play()
	hideTween.Completed:Connect(function()
		components.MainFrame.Visible = false
	end)
end

function RebirthController:Toggle()
	if isVisible then
		self:Hide()
	else
		self:Show()
	end
end

function RebirthController:IsVisible()
	return isVisible
end

function RebirthController:SetSoundController(controller)
	soundController = controller
end

-- Get current rebirth data
function RebirthController:GetRebirthData()
	return rebirthData
end

-- Clean up when controller is destroyed
function RebirthController:Destroy()
	-- Destroy UI
	if components and components.ScreenGui then
		components.ScreenGui:Destroy()
	end
	
	print("[RebirthController] Destroyed")
end

return RebirthController 