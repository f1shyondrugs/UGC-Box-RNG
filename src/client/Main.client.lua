local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
-- local ProximityPromptService = game:GetService("ProximityPromptService") -- Removed

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
local EnchanterController = require(script.Parent.Controllers.EnchanterController)
local AutoOpenController = require(script.Parent.Controllers.AutoOpenController)
local ShopController = require(script.Parent.Controllers.ShopController)
local RebirthController = require(script.Parent.Controllers.RebirthController)
local ToastNotificationController = require(script.Parent.Controllers.ToastNotificationController)
local BuyButtonUI = require(script.Parent.UI.BuyButtonUI)
local StatsUI = require(script.Parent.UI.StatsUI)
local BoostersController = require(script.Parent.Controllers.BoostersController)

-- Constants (will be updated by upgrades)
local MAX_BOXES = 1 -- Default, will be updated by upgrade system
local BUY_COOLDOWN = 0.5 -- Default, will be updated by upgrade system

-- State
local currentBoxCount = 0
local isOnCooldown = false
local isFreeCrateOnCooldown = false
local openingBoxes = {} -- A set of box parts that are currently being opened

-- Setup GUI hiding until LoadingScreen is finished
local loadingScreen = PlayerGui:FindFirstChild("LoadingScreen") or PlayerGui:WaitForChild("LoadingScreen", 5)
local hiddenGuis = {}

-- Helper to hide a ScreenGui if loading is still active
local function tryHideGui(gui)
	if gui:IsA("ScreenGui") and gui ~= loadingScreen and loadingScreen and loadingScreen.Enabled then
		hiddenGuis[gui] = true
		gui.Enabled = false
	end
end

-- Hide any existing ScreenGuis that are already present (created by earlier code/controllers)
for _, gui in ipairs(PlayerGui:GetChildren()) do
	tryHideGui(gui)
end

-- Listen for new ScreenGuis that might be added while loading is active
local childConn
childConn = PlayerGui.ChildAdded:Connect(function(child)
	tryHideGui(child)
end)

-- When the LoadingScreen finishes, restore all GUIs and disconnect listener
if loadingScreen then
	if not loadingScreen.Enabled then
		-- Already finished, nothing to do
		childConn:Disconnect()
	else
		loadingScreen:GetPropertyChangedSignal("Enabled"):Connect(function()
			if not loadingScreen.Enabled then
				for gui, _ in pairs(hiddenGuis) do
					if gui and gui.Parent then
						gui.Enabled = true
					end
				end
				hiddenGuis = {}
				if childConn then childConn:Disconnect() end
			end
		end)
	end
end

-- Initialize Services
local soundController = SoundController.new()
soundController:playMusic()

CameraShaker.Start()
Notifier.Start(PlayerGui)
ToastNotificationController.Start(PlayerGui)
NavigationController.Start(PlayerGui, soundController)
InventoryController.Start(PlayerGui, openingBoxes, soundController)
CollectionController.Start(PlayerGui, soundController)
UpgradeController.Start(PlayerGui, soundController)
SettingsController.Start(PlayerGui, soundController)
AutoOpenController.Start(PlayerGui, soundController)
ShopController.Start(PlayerGui, soundController)
RebirthController:Start()
CrateSelectionController:Start()
EnchanterController:Start()

-- Initialize UnlockAnimationController
local UnlockAnimationController = require(script.Parent.Controllers.UnlockAnimationController)

-- Initialize saved selected crate after CrateSelectionController is started
AutoOpenController.InitializeSelectedCrate()

-- Connect BuyButtonUI to CrateSelectionController
BuyButtonUI.SetCrateSelectionController(CrateSelectionController)

-- Connect sound controller to controllers
EnchanterController:SetSoundController(soundController)
RebirthController:SetSoundController(soundController)

-- Connect sound controller, box animator, and notifier to settings controller for effect checking
soundController:setSettingsController(SettingsController)
BoxAnimator.SetSettingsController(SettingsController)
Notifier.SetSettingsController(SettingsController)
ToastNotificationController.SetSettingsController(SettingsController)

-- Register rebirth controller with navigation
NavigationController.RegisterController("Rebirth", function()
	RebirthController:Toggle()
end)

NameplateController.Start()

-- Create Stats UI at the top
local statsGui = StatsUI.Create(PlayerGui)

-- Create and manage the Buy UGC Crate button with dropdown
local buyButtonGui = BuyButtonUI.Create(PlayerGui)

-- Create Boosters UI in the bottom left (includes rebirth luck)
local boostersGui = BoostersController.Start(PlayerGui)

-- Connect rebirth luck updates
local function updateRebirthLuckDisplay()
	local luckBonus = LocalPlayer:GetAttribute("LuckBonus") or 0
	local BoostersUI = require(script.Parent.UI.BoostersUI)
	BoostersUI.UpdateRebirthLuck(luckBonus)
end

LocalPlayer:GetAttributeChangedSignal("LuckBonus"):Connect(updateRebirthLuckDisplay)
updateRebirthLuckDisplay()

-- Set crate to match the current CrateSelectionController selection
local currentSelectedCrate = CrateSelectionController:GetSelectedCrate()
BuyButtonUI.SetSelectedCrate(buyButtonGui, currentSelectedCrate)

-- Setup stats monitoring
local leaderstats = LocalPlayer:WaitForChild("leaderstats")
local robuxStat = leaderstats:WaitForChild("R$")
local boxesOpenedStat = leaderstats:WaitForChild("Boxes Opened")
local rebirthsStat = leaderstats:WaitForChild("Rebirths")

local function updateStatsDisplay()
	local robuxValue = LocalPlayer:GetAttribute("RobuxValue") or 0
	local rapValue = LocalPlayer:GetAttribute("RAPValue") or 0
	local boxesOpenedValue = LocalPlayer:GetAttribute("BoxesOpenedValue") or 0
	local rebirthsValue = LocalPlayer:GetAttribute("RebirthsValue") or 0
	StatsUI.UpdateStats(statsGui, robuxValue, rapValue, boxesOpenedValue, rebirthsValue)
	BuyButtonUI.UpdateAffordability(buyButtonGui, robuxValue)
end

-- Connect to stat changes using attributes (raw numeric values)
LocalPlayer:GetAttributeChangedSignal("RobuxValue"):Connect(updateStatsDisplay)
LocalPlayer:GetAttributeChangedSignal("RAPValue"):Connect(updateStatsDisplay)
LocalPlayer:GetAttributeChangedSignal("BoxesOpenedValue"):Connect(updateStatsDisplay)
LocalPlayer:GetAttributeChangedSignal("RebirthsValue"):Connect(updateStatsDisplay)

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
		task.wait(0.05) -- Check every 50ms for more responsive updates
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
Remotes.BoxLanded.OnClientEvent:Connect(function(boxPart)
	soundController:playBoxLand()
	-- CameraShaker.Shake(0.2, 0.3) -- Short, sharp shake

	-- If auto-open is enabled, automatically fire the RequestOpen remote
	local autoOpenSettings = AutoOpenController.GetSettings()
	if autoOpenSettings and autoOpenSettings.enabled then
		print("[Main.client.lua] Auto-Open is enabled. Directly firing Remotes.RequestOpen for box: " .. boxPart.Name)
		Remotes.RequestOpen:FireServer(boxPart)
	else
		print("[Main.client.lua] Auto-Open is not enabled, not opening box automatically.")
		-- If auto-open is not enabled, the player will have to manually interact with the ProximityPrompt.
		-- The onBoxAdded function already sets up the ProximityPrompt.Triggered connection.
	end
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
		print("[Main.client.lua] ProximityPrompt.Triggered fired for box: " .. boxPart.Name .. ". isTriggered flag: " .. tostring(isTriggered))
		-- Prevent multiple triggers while request is being processed
		if isTriggered then
			print("[Main.client.lua] Prompt already triggered, returning.")
			return
		end
		isTriggered = true
		
		-- Don't disable prompt here - let server decide based on inventory status
		-- Just fire the request and let server handle the rest
		print("[Main.client.lua] Firing Remotes.RequestOpen for box: " .. boxPart.Name)
		Remotes.RequestOpen:FireServer(boxPart)
		
		-- Reset trigger flag after a short delay to allow retry if inventory was full
		task.delay(1, function()
			isTriggered = false
			print("[Main.client.lua] isTriggered flag reset for box: " .. boxPart.Name)
		end)
	end)
end

-- More robust handling for the Boxes folder
local boxesFolder = Workspace:FindFirstChild("Boxes")
if boxesFolder then
	-- Handle existing boxes that might have been created before the script ran
	for _, boxPart in ipairs(boxesFolder:GetChildren()) do
		task.spawn(function()
			-- Wait a moment to ensure all box properties and prompts are fully replicated
			task.wait(0.1)
			onBoxAdded(boxPart)
		end)
	end
	boxesFolder.ChildAdded:Connect(function(boxPart)
		task.spawn(function()
			task.wait(0.1) -- Small delay for replication
			onBoxAdded(boxPart)
		end)
	end)
else
	-- If the folder doesn't exist yet, wait for it
	Workspace.ChildAdded:Connect(function(child)
		if child.Name == "Boxes" then
			boxesFolder = child
			-- Handle existing boxes that might have been created before the script ran
			for _, boxPart in ipairs(boxesFolder:GetChildren()) do
				task.spawn(function()
					task.wait(0.05) -- Reduced delay for more responsive updates
					onBoxAdded(boxPart)
				end)
			end
			boxesFolder.ChildAdded:Connect(function(boxPart)
				task.spawn(function()
					task.wait(0.05) -- Reduced delay for more responsive updates
					onBoxAdded(boxPart)
				end)
			end)
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
	
	-- Play box open sound when animation starts (only for own crates)
	if isOwnCrate then
		soundController:playBoxOpen()
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

			-- Add the item to inventory when floating text appears
			local item = boxPart:FindFirstChildOfClass("Tool") or boxPart:FindFirstChildOfClass("Part")
			if item then
				item.Parent = inventory

				-- Auto-sell check (call after item is added to inventory)
				AutoOpenController.HandleNewItem(item, itemName)
			end
		end
	end)
end)

-- Handle floating error messages
Remotes.ShowFloatingError.OnClientEvent:Connect(function(position, message)
	BoxAnimator.AnimateFloatingErrorText(position, message)
end)

-- Connect floating notification system
Remotes.ShowFloatingNotification.OnClientEvent:Connect(function(message, messageType)
	print("[Main.client] Received ShowFloatingNotification:", message, messageType)
	ToastNotificationController.ShowToast(message, messageType)
end)

-- Celebration effect remote
if Remotes.ShowCelebrationEffect then
	Remotes.ShowCelebrationEffect.OnClientEvent:Connect(function()
		BoxAnimator.PlayCelebrationEffect()
	end)
end

-- Local chat command to test celebration effect
LocalPlayer.Chatted:Connect(function(msg)
	if msg:lower() == "/celebrate" or msg:lower() == "!celebrate" then
		BoxAnimator.PlayCelebrationEffect()
	end
end)

-- Add at the bottom of the file:
local function tryReconnect()
	local placeId = game.PlaceId
	local jobId = nil -- nil means new server
	print("[Reconnect] Attempting to teleport to same place to avoid idle disconnect...")
	TeleportService:Teleport(placeId, LocalPlayer)
end

-- Roblox disconnects after 20 minutes of idling. We'll use a timer and user input detection to reset it.
-- This system is only active when auto-open is enabled to prevent unnecessary reconnects.
local idleTime = 0
local idleLimit = 19 * 60 -- 19 minutes, to be safe
local idleCheckConnection = nil

-- Save function for all controllers/services that need to persist state
local function saveAllData()
	-- Save auto-open settings
	local AutoOpenController = require(script.Parent.Controllers.AutoOpenController)
	if AutoOpenController and AutoOpenController.saveSettings then
		AutoOpenController.saveSettings()
	end
	-- Add other save calls here if needed
end

-- Reset idle timer on any user input
local function resetIdle()
	idleTime = 0
end

-- Function to start idle detection (only when auto-open is enabled)
local function startIdleDetection()
	if idleCheckConnection then return end -- Already running
	
	print("[Reconnect] Starting idle detection for auto-open users...")
	idleTime = 0
	idleCheckConnection = RunService.Heartbeat:Connect(function(dt)
		idleTime = idleTime + dt
		if idleTime > idleLimit then
			print("[Reconnect] Idle limit reached, saving and reconnecting...")
			saveAllData()
			task.wait(1)
			tryReconnect()
		end
	end)
end

-- Function to stop idle detection
local function stopIdleDetection()
	if idleCheckConnection then
		idleCheckConnection:Disconnect()
		idleCheckConnection = nil
		print("[Reconnect] Stopped idle detection.")
	end
end

-- Listen for user input (only when idle detection is active)
if UserInputService then
	UserInputService.InputBegan:Connect(resetIdle)
	UserInputService.InputChanged:Connect(resetIdle)
	UserInputService.InputEnded:Connect(resetIdle)
end

-- Monitor auto-open settings to start/stop idle detection
local function checkAutoOpenStatus()
	local AutoOpenController = require(script.Parent.Controllers.AutoOpenController)
	if AutoOpenController then
		local settings = AutoOpenController.GetSettings()
		if settings and settings.enabled then
			startIdleDetection()
		else
			stopIdleDetection()
		end
	end
end

-- Check auto-open status every 30 seconds
task.spawn(function()
	while task.wait(30) do
		checkAutoOpenStatus()
	end
end)

-- Initial check
task.wait(2) -- Wait for AutoOpenController to initialize
checkAutoOpenStatus()

-- On teleport, reload auto-open and other persistent features
LocalPlayer.OnTeleport:Connect(function(teleportState)
	if teleportState == Enum.TeleportState.Started then
		print("[Reconnect] Teleport started, will reload persistent features after arrival.")
	end
end) 