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
local NavigationController = require(script.Parent.Controllers.NavigationController)
local InventoryController = require(script.Parent.Controllers.InventoryController)
local CollectionController = require(script.Parent.Controllers.CollectionController)
local NameplateController = require(script.Parent.Controllers.NameplateController)
local SoundController = require(script.Parent.Controllers.SoundController)
local UpgradeController = require(script.Parent.Controllers.UpgradeController)
local SettingsController = require(script.Parent.Controllers.SettingsController)
local CrateSelectionController = require(script.Parent.Controllers.CrateSelectionController)
local BoxAnimator = require(script.Parent.Controllers.BoxAnimator)
local Notifier = require(script.Parent.Controllers.Notifier)
local BuyButtonUI = require(script.Parent.UI.BuyButtonUI)
local StatsUI = require(script.Parent.UI.StatsUI)

-- Constants (will be updated by upgrades)
local MAX_BOXES = 1 -- Default, will be updated by upgrade system
local BUY_COOLDOWN = 0.5 -- Default, will be updated by upgrade system

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
NavigationController.Start(PlayerGui, soundController)
InventoryController.Start(PlayerGui, openingBoxes, soundController)
CollectionController.Start(PlayerGui, soundController)
UpgradeController.Start(PlayerGui, soundController)
SettingsController.Start(PlayerGui, soundController)
CrateSelectionController:Start()

-- Connect BuyButtonUI to CrateSelectionController
BuyButtonUI.SetCrateSelectionController(CrateSelectionController)

-- Connect sound controller, box animator, and notifier to settings controller for effect checking
soundController:setSettingsController(SettingsController)
BoxAnimator.SetSettingsController(SettingsController)
Notifier.SetSettingsController(SettingsController)

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
local boxesOpenedStat = leaderstats:WaitForChild("Boxes Opened")

local function updateStatsDisplay()
	local robuxValue = LocalPlayer:GetAttribute("RobuxValue") or 0
	local rapValue = LocalPlayer:GetAttribute("RAPValue") or 0
	local boxesOpenedValue = LocalPlayer:GetAttribute("BoxesOpenedValue") or 0
	StatsUI.UpdateStats(statsGui, robuxValue, rapValue, boxesOpenedValue)
	BuyButtonUI.UpdateAffordability(buyButtonGui, robuxValue)
end

-- Connect to stat changes using attributes (raw numeric values)
LocalPlayer:GetAttributeChangedSignal("RobuxValue"):Connect(updateStatsDisplay)
LocalPlayer:GetAttributeChangedSignal("RAPValue"):Connect(updateStatsDisplay)
LocalPlayer:GetAttributeChangedSignal("BoxesOpenedValue"):Connect(updateStatsDisplay)

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

-- Handle crate selection button click (opens crate selection GUI)
buyButtonGui.CrateDropdown.MouseButton1Click:Connect(function()
	soundController:playUIClick()
	BuyButtonUI.OpenCrateSelection()
end)

-- Listen for crate selection changes from CrateSelectionController
-- We'll poll for changes since we don't have an event system set up
task.spawn(function()
	local lastSelectedCrate = CrateSelectionController:GetSelectedCrate()
	while true do
		task.wait(0.1) -- Check every 100ms
		local currentSelectedCrate = CrateSelectionController:GetSelectedCrate()
		if currentSelectedCrate ~= lastSelectedCrate then
			lastSelectedCrate = currentSelectedCrate
			BuyButtonUI.SetSelectedCrate(buyButtonGui, currentSelectedCrate)
			local robuxValue = LocalPlayer:GetAttribute("RobuxValue") or 0
			BuyButtonUI.UpdateAffordability(buyButtonGui, robuxValue)
			updateButtonState() -- Update button state when crate selection changes
		end
	end
end)

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

-- Handle cooldown updates from upgrade system
Remotes.CooldownUpdated.OnClientEvent:Connect(function(newCooldown)
	BUY_COOLDOWN = newCooldown
end)

-- Get initial upgrade values from upgrade system
local success, initialUpgradeData = pcall(function()
	return Remotes.GetUpgradeData:InvokeServer()
end)

if success and initialUpgradeData then
	-- Set initial max boxes
	if initialUpgradeData.MultiCrateOpening then
		local multiCrateData = initialUpgradeData.MultiCrateOpening
		if multiCrateData.effects and multiCrateData.effects.CurrentBoxes then
			MAX_BOXES = multiCrateData.effects.CurrentBoxes
		end
	end
	
	-- Set initial cooldown
	if initialUpgradeData.FasterCooldowns then
		local cooldownData = initialUpgradeData.FasterCooldowns
		if cooldownData.effects and cooldownData.effects.CurrentCooldownValue then
			BUY_COOLDOWN = cooldownData.effects.CurrentCooldownValue
		end
	end
end

-- Initial State
updateButtonState()

print("UGC Client Systems Initialized")

local function onBoxAdded(boxPart)
	if not boxPart:IsA("BasePart") then return end

	local prompt = boxPart:FindFirstChildOfClass("ProximityPrompt")
	if not prompt or boxPart:GetAttribute("Owner") ~= LocalPlayer.UserId then
		return
	end

	-- Add a flag to prevent multiple triggers
	local isTriggered = false

	prompt.Triggered:Connect(function()
		-- Prevent multiple triggers
		if isTriggered then
			return
		end
		isTriggered = true
		
		-- Properly disable and remove the prompt 
		prompt.Enabled = false
		prompt.MaxActivationDistance = 0
		prompt.RequiresLineOfSight = true
		prompt.ActionText = ""
		prompt.ObjectText = ""
		
		-- Mark the box as being opened
		boxPart:SetAttribute("IsOpening", true)
		
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

Remotes.PlayAnimation.OnClientEvent:Connect(function(boxPart, itemName, mutations, size, ownerUserId, isOwnCrate)
	-- Handle backwards compatibility for old server calls
	if ownerUserId == nil then
		ownerUserId = LocalPlayer.UserId
		isOwnCrate = true
	end
	
	-- If this is someone else's crate, check if we should show it
	if not isOwnCrate then
		-- Check if the player wants to see other players' crates
		if not SettingsController.GetSetting("ShowOthersCrates") then
			return -- Don't show other players' crate animations
		end
		
		-- Also check if other players are hidden
		if SettingsController.GetSetting("HideOtherPlayers") then
			return -- Don't show crates from hidden players
		end
	end
	
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

	local duration = BoxAnimator.PlayAddictiveAnimation(boxPart, itemConfig, mutationNames, mutationConfigs, size, soundController, isOwnCrate)

	-- Remove early reward sound - it will now play when text appears
	-- soundController:playRewardSound(itemConfig.Rarity)

	task.delay(duration, function()
		if boxPart then
			openingBoxes[boxPart] = nil
			
			-- Fire AnimationComplete when floating text starts (items get added to inventory now)
			if isOwnCrate then
				Remotes.AnimationComplete:FireServer(boxPart)
			end
			
			-- Start the floating text animation
			BoxAnimator.AnimateFloatingText(boxPart.Position, itemName, itemConfig, mutationNames, mutationConfigs, size, soundController, isOwnCrate)
		end
	end)
end) 