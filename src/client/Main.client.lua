local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local LocalPlayer = Players.LocalPlayer

local Shared = ReplicatedStorage.Shared
local Remotes = require(Shared.Remotes.Remotes)
local GameConfig = require(Shared.Modules.GameConfig)

-- V2 Controllers & UI
local BoxAnimator = require(script.Parent.Controllers.BoxAnimator)
local CameraShaker = require(script.Parent.Controllers.CameraShaker)
local Notifier = require(script.Parent.Controllers.Notifier)
local InventoryController = require(script.Parent.Controllers.InventoryController)
local CollectionController = require(script.Parent.Controllers.CollectionController)
local NameplateController = require(script.Parent.Controllers.NameplateController)
local SoundController = require(script.Parent.Controllers.SoundController)
local BuyButtonUI = require(script.Parent.UI.BuyButtonUI)
local StatsUI = require(script.Parent.UI.StatsUI)

-- Constants
local MAX_BOXES = 16
local BUY_COOLDOWN = 0.5 -- seconds

-- State
local currentBoxCount = 0
local isOnCooldown = false
local isFreeCrateOnCooldown = false
local openingBoxes = {} -- A set of box parts that are currently being opened

-- Initialize Services
local soundController = SoundController.new()
soundController:playMusic()

CameraShaker.Start()
Notifier.Start(PlayerGui)
InventoryController.Start(PlayerGui, openingBoxes, soundController)
CollectionController.Start(PlayerGui, soundController)
NameplateController.Start()

-- Create Stats UI at the top
local statsGui = StatsUI.Create(PlayerGui)

-- Create and manage the Buy UGC Crate button with dropdown
local buyButtonGui = BuyButtonUI.Create(PlayerGui)

-- Set default crate
BuyButtonUI.SetSelectedCrate(buyButtonGui, "StarterCrate")

-- Setup stats monitoring
local leaderstats = LocalPlayer:WaitForChild("leaderstats")
local robuxStat = leaderstats:WaitForChild("R$")
local rapStat = leaderstats:WaitForChild("RAP")
local boxesStat = leaderstats:WaitForChild("Boxes Opened")

local function updateStatsDisplay()
	StatsUI.UpdateStats(statsGui, robuxStat.Value, rapStat.Value, boxesStat.Value)
	BuyButtonUI.UpdateAffordability(buyButtonGui, robuxStat.Value)
end

-- Connect to stat changes
robuxStat.Changed:Connect(updateStatsDisplay)
rapStat.Changed:Connect(updateStatsDisplay)
boxesStat.Changed:Connect(updateStatsDisplay)

-- Initial update
updateStatsDisplay()

local function updateButtonState()
	if currentBoxCount >= MAX_BOXES then
		BuyButtonUI.SetEnabled(buyButtonGui, false, "All")
	else
		if not isOnCooldown then
			BuyButtonUI.SetEnabled(buyButtonGui, true, "Paid")
		end
		if not isFreeCrateOnCooldown then
			BuyButtonUI.SetEnabled(buyButtonGui, true, "Free")
		end
	end
end

-- Handle dropdown interactions
buyButtonGui.CrateDropdown.MouseButton1Click:Connect(function()
	soundController:playUIClick()
	BuyButtonUI.ToggleDropdown(buyButtonGui)
end)

-- Handle crate selection
for crateType, optionButton in pairs(buyButtonGui.OptionButtons) do
	optionButton.MouseButton1Click:Connect(function()
		soundController:playUIClick()
		BuyButtonUI.SetSelectedCrate(buyButtonGui, crateType)
		BuyButtonUI.UpdateAffordability(buyButtonGui, robuxStat.Value)
		BuyButtonUI.HideDropdown(buyButtonGui)
	end)
end

-- Handle buy button click
buyButtonGui.BuyButton.MouseButton1Click:Connect(function()
	soundController:playUIClick()
	if currentBoxCount < MAX_BOXES and not isOnCooldown then
		local selectedCrateType = buyButtonGui.SelectedCrateType
		Remotes.RequestBox:FireServer(selectedCrateType)
		
		isOnCooldown = true
		BuyButtonUI.StartCooldown(buyButtonGui, BUY_COOLDOWN)
		
		task.delay(BUY_COOLDOWN, function()
			isOnCooldown = false
			updateButtonState()
		end)
	end
end)

-- Handle Free Crate button click
buyButtonGui.FreeCrateButton.MouseButton1Click:Connect(function()
	soundController:playUIClick()
	if currentBoxCount < MAX_BOXES and not isFreeCrateOnCooldown then
		Remotes.RequestBox:FireServer("FreeCrate")
	end
end)

-- Listen for server-initiated cooldown
Remotes.StartFreeCrateCooldown.OnClientEvent:Connect(function(duration)
	isFreeCrateOnCooldown = true
	BuyButtonUI.SetEnabled(buyButtonGui, false, "Free")
	
	local timer = duration
	buyButtonGui.FreeCrateTimer.Text = tostring(timer) .. "s"
	
	local timerConnection
	timerConnection = game:GetService("RunService").Heartbeat:Connect(function(dt)
		timer = timer - dt
		buyButtonGui.FreeCrateTimer.Text = tostring(math.ceil(timer)) .. "s"
		if timer <= 0 then
			isFreeCrateOnCooldown = false
			buyButtonGui.FreeCrateTimer.Text = "Ready!"
			updateButtonState()
			timerConnection:Disconnect()
		end
	end)
end)

-- Close dropdown when clicking elsewhere
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if buyButtonGui.OptionsFrame.Visible then
			-- Check if the click was outside the dropdown
			local dropdown = buyButtonGui.CrateDropdown
			local mousePos = game:GetService("UserInputService"):GetMouseLocation()
			local isMouseOver = mousePos.X >= dropdown.AbsolutePosition.X and mousePos.X <= dropdown.AbsolutePosition.X + dropdown.AbsoluteSize.X and
			                    mousePos.Y >= dropdown.AbsolutePosition.Y and mousePos.Y <= dropdown.AbsolutePosition.Y + dropdown.AbsoluteSize.Y + buyButtonGui.OptionsFrame.AbsoluteSize.Y
			
			if not isMouseOver then
				BuyButtonUI.HideDropdown(buyButtonGui)
			end
		end
	end
end)

Remotes.UpdateBoxCount.OnClientEvent:Connect(function(newCount)
	currentBoxCount = newCount
	updateButtonState()
end)

-- Listen for the box landing event
Remotes.BoxLanded.OnClientEvent:Connect(function()
	soundController:playBoxLand()
	-- CameraShaker.Shake(0.2, 0.3) -- Short, sharp shake
end)

-- Initial State
updateButtonState()

print("UGC Client Systems Initialized")

local function onBoxAdded(boxPart)
	if not boxPart:IsA("Part") then return end

	local prompt = boxPart:FindFirstChildOfClass("ProximityPrompt")
	if not prompt or boxPart:GetAttribute("Owner") ~= LocalPlayer.UserId then
		return
	end

	prompt.Triggered:Connect(function()
		prompt.Enabled = false -- Prevent double clicks
		soundController:playBoxOpen()
		Remotes.RequestOpen:FireServer(boxPart)
	end)
end

-- More robust handling for the Boxes folder
local boxesFolder = Workspace:FindFirstChild("Boxes")
if boxesFolder then
	-- Handle existing boxes that might have been created before the script ran
	for _, boxPart in ipairs(boxesFolder:GetChildren()) do
		task.spawn(onBoxAdded, boxPart)
	end
	boxesFolder.ChildAdded:Connect(onBoxAdded)
else
	-- If the folder doesn't exist yet, wait for it
	Workspace.ChildAdded:Connect(function(child)
		if child.Name == "Boxes" then
			boxesFolder = child
			-- Handle existing boxes that might have been created before the script ran
			for _, boxPart in ipairs(boxesFolder:GetChildren()) do
				task.spawn(onBoxAdded, boxPart)
			end
			boxesFolder.ChildAdded:Connect(onBoxAdded)
		end
	end)
end

Remotes.PlayAnimation.OnClientEvent:Connect(function(boxPart, itemName, mutations, size)
	openingBoxes[boxPart] = true

	-- Get the full config tables before calling the animators
	local itemConfig = GameConfig.Items[itemName]
	if not itemConfig then return end -- Safety check
	
	local mutationConfigs = {}
	local mutationNames = mutations or {}
	for _, mutationName in ipairs(mutationNames) do
		local mutationConfig = GameConfig.Mutations[mutationName]
		if mutationConfig then
			table.insert(mutationConfigs, mutationConfig)
		end
	end

	local duration = BoxAnimator.PlayAddictiveAnimation(boxPart, itemConfig, mutationNames, mutationConfigs, size, soundController)

	-- Remove early reward sound - it will now play when text appears
	-- soundController:playRewardSound(itemConfig.Rarity)

	task.delay(duration, function()
		if boxPart then
			openingBoxes[boxPart] = nil
			BoxAnimator.AnimateFloatingText(boxPart.Position, itemName, itemConfig, mutationNames, mutationConfigs, size, soundController)
			Remotes.AnimationComplete:FireServer(boxPart)
		end
	end)
end) 