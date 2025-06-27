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
local UpgradeController = require(script.Parent.Controllers.UpgradeController)
local BuyButtonUI = require(script.Parent.UI.BuyButtonUI)
local StatsUI = require(script.Parent.UI.StatsUI)

-- Constants (will be updated by upgrades)
local MAX_BOXES = 1 -- Default, will be updated by upgrade system
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
UpgradeController.Start(PlayerGui, soundController)
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
		BuyButtonUI.SetEnabled(buyButtonGui, false)
	else
		if not isOnCooldown and (not isFreeCrateOnCooldown or buyButtonGui.SelectedCrateType ~= "FreeCrate") then
			BuyButtonUI.SetEnabled(buyButtonGui, true)
		else
			BuyButtonUI.SetEnabled(buyButtonGui, false)
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
		updateButtonState() -- Update button state when crate selection changes
	end)
end

-- Handle buy button click (works for both paid and free crates)
buyButtonGui.BuyButton.MouseButton1Click:Connect(function()
	soundController:playUIClick()
	if currentBoxCount < MAX_BOXES and not isOnCooldown then
		local selectedCrateType = buyButtonGui.SelectedCrateType
		
		-- Check if it's a free crate and if it's on cooldown
		if selectedCrateType == "FreeCrate" and isFreeCrateOnCooldown then
			return -- Don't allow clicking if free crate is on cooldown
		end
		
		Remotes.RequestBox:FireServer(selectedCrateType)
		
		isOnCooldown = true
		BuyButtonUI.StartCooldown(buyButtonGui, BUY_COOLDOWN)
		
		task.delay(BUY_COOLDOWN, function()
			isOnCooldown = false
			updateButtonState()
		end)
	end
end)

-- Listen for server-initiated cooldown (for free crates)
Remotes.StartFreeCrateCooldown.OnClientEvent:Connect(function(duration)
	isFreeCrateOnCooldown = true
	updateButtonState()
	
	local timer = duration
	BuyButtonUI.UpdateFreeCrateCooldown(buyButtonGui, timer)
	
	local timerConnection
	timerConnection = game:GetService("RunService").Heartbeat:Connect(function(dt)
		timer = timer - dt
		BuyButtonUI.UpdateFreeCrateCooldown(buyButtonGui, timer)
		if timer <= 0 then
			isFreeCrateOnCooldown = false
			BuyButtonUI.UpdateFreeCrateCooldown(buyButtonGui, 0)
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

-- Handle max boxes updates from upgrade system
Remotes.MaxBoxesUpdated.OnClientEvent:Connect(function(newMaxBoxes)
	MAX_BOXES = newMaxBoxes
	updateButtonState()
end)

-- Get initial max boxes value from upgrade system
local success, initialMaxBoxes = pcall(function()
	return Remotes.GetUpgradeData:InvokeServer()
end)

if success and initialMaxBoxes and initialMaxBoxes.MultiCrateOpening then
	local multiCrateData = initialMaxBoxes.MultiCrateOpening
	if multiCrateData.effects and multiCrateData.effects.CurrentBoxes then
		MAX_BOXES = multiCrateData.effects.CurrentBoxes
	end
end

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