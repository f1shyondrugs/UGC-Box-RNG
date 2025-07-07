local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local NavigationController = require(script.Parent.NavigationController)
local Shared = ReplicatedStorage.Shared
local SettingsConfig = require(Shared.Modules.SettingsConfig)
local SettingsUI = require(script.Parent.Parent.UI.SettingsUI)
local Remotes = require(Shared.Remotes.Remotes)

local SettingsController = {}

local ui = nil
local settings = {}
local isVisible = false
local soundController = nil
local hiddenUIs = {}
-- Connection to track new crates being spawned so we can hide/show them based on the
-- "ShowOthersCrates" setting.
local cratesFolderConnection = nil

-- Helper that sets transparency for every BasePart / Decal / Texture of the given crate
-- root instance. A transparency of 1 completely hides the object, 0 shows it.
local function setCrateTransparency(crateRoot, transparency)
    for _, descendant in ipairs(crateRoot:GetDescendants()) do
        if descendant:IsA("BasePart") then
            -- Use LocalTransparencyModifier so we do not interfere with server driven
            -- transparency changes (e.g. during animations)
            descendant.LocalTransparencyModifier = transparency
            descendant.Transparency = transparency
        elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
            descendant.Transparency = transparency
        end
    end
end

-- Updates visibility for all existing crates and (re)configures the ChildAdded
-- listener so future crates respect the current setting.
local function updateCrateVisibility()
    local boxesFolder = workspace:FindFirstChild("Boxes")
    if not boxesFolder then return end

    -- First apply to currently present crates
    for _, crate in ipairs(boxesFolder:GetChildren()) do
        local ownerId = crate:GetAttribute("Owner")
        if ownerId and ownerId ~= LocalPlayer.UserId then
            if settings.ShowOthersCrates and not settings.HideOtherPlayers then
                setCrateTransparency(crate, 0)
            else
                setCrateTransparency(crate, 1)
            end
        end
    end

    -- Manage child-added connection depending on current preference
    if settings.ShowOthersCrates and not settings.HideOtherPlayers then
        if cratesFolderConnection then
            cratesFolderConnection:Disconnect()
            cratesFolderConnection = nil
        end
    else
        -- Hide new crates as they spawn
        if not cratesFolderConnection then
            cratesFolderConnection = boxesFolder.ChildAdded:Connect(function(crate)
                -- Defer slightly to ensure attributes replicate
                task.defer(function()
                    local ownerId = crate:GetAttribute("Owner")
                    if ownerId and ownerId ~= LocalPlayer.UserId then
                        if settings.ShowOthersCrates and not settings.HideOtherPlayers then
                            -- Should be visible, do nothing (they will have default transparency)
                        else
                            setCrateTransparency(crate, 1)
                        end
                    end
                end)
            end)
        end
    end
end

-- Animation settings
local ANIMATION_TIME = 0.3
local EASE_INFO = TweenInfo.new(ANIMATION_TIME, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

-- Hide other UIs for clean settings experience
local function hideOtherUIs(show)
	local playerGui = LocalPlayer:WaitForChild("PlayerGui")
	
	if show then
		-- Hide other UIs for clean settings experience
		for _, gui in pairs(playerGui:GetChildren()) do
			if gui:IsA("ScreenGui") and gui.Name ~= "SettingsGui" then
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

-- Default settings
local function initializeDefaultSettings()
	for settingId, settingConfig in pairs(SettingsConfig.Settings) do
		if settings[settingId] == nil then
			settings[settingId] = settingConfig.DefaultValue
		end
	end
end

-- Get floating text size multiplier
function SettingsController.GetFloatingTextSize()
	return settings.FloatingTextSize or 1.0
end

-- Apply effects based on settings
local function applyEffects()
	-- Apply "Hide Other Players" setting
	if settings.HideOtherPlayers then
		-- Hide all other players
		for _, player in pairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character then
				for _, part in pairs(player.Character:GetDescendants()) do
					if part:IsA("BasePart") then
						part.Transparency = 1
					elseif part:IsA("Accessory") then
						for _, accessoryPart in pairs(part:GetDescendants()) do
							if accessoryPart:IsA("BasePart") then
								accessoryPart.Transparency = 1
							end
						end
					end
				end
			end
		end
	else
		-- Show all other players
		for _, player in pairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character then
				for _, part in pairs(player.Character:GetDescendants()) do
					if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
						part.Transparency = 0
					elseif part:IsA("Accessory") then
						for _, accessoryPart in pairs(part:GetDescendants()) do
							if accessoryPart:IsA("BasePart") then
								accessoryPart.Transparency = 0
							end
						end
					end
				end
			end
		end
	end

	-- Apply "Show Others' Crates" visibility preference
	updateCrateVisibility()
end

-- Handle new players joining (for hide players setting)
local function onPlayerAdded(player)
	if player == LocalPlayer then return end
	
	player.CharacterAdded:Connect(function(character)
		task.wait(1) -- Wait for character to load
		if settings.HideOtherPlayers then
			for _, part in pairs(character:GetDescendants()) do
				if part:IsA("BasePart") then
					part.Transparency = 1
				elseif part:IsA("Accessory") then
					for _, accessoryPart in pairs(part:GetDescendants()) do
						if accessoryPart:IsA("BasePart") then
							accessoryPart.Transparency = 1
						end
					end
				end
			end
		end
	end)
end

-- Save individual setting to server
local function saveSetting(settingId, value)
	Remotes.SaveSetting:FireServer(settingId, value)
end

-- Load settings from server
local function loadSettings()
	local success, settingsData = pcall(function()
		return Remotes.GetPlayerSettings:InvokeServer()
	end)
	
	if success and settingsData then
		for settingId, value in pairs(settingsData) do
			settings[settingId] = value
		end
	end
	
	-- Ensure all settings have values
	initializeDefaultSettings()
end

-- Toggle a setting (for boolean settings)
local function toggleSetting(settingId)
	if settings[settingId] ~= nil then
		settings[settingId] = not settings[settingId]
		saveSetting(settingId, settings[settingId])
		applyEffects()
		
		-- Update the UI for this setting
		local settingFrame = ui.SettingFrames[settingId]
		if settingFrame then
			SettingsUI.UpdateSettingFrame(settingFrame, settingId, settings[settingId])
		end
		
		-- Provide feedback
		local settingConfig = SettingsConfig.GetSetting(settingId)
		if settingConfig then
			local status = settings[settingId] and "enabled" or "disabled"
			if soundController then
				soundController:playUIClick()
			end
			
			-- Special notifications for certain settings
			if settingId == "ShowOthersCrates" then
				local message = settings[settingId] and 
					"You will now see other players' crates" or 
					"Other players' crates are now hidden"
				-- Could show notification if Notifier is available
			elseif settingId == "DisableEffects" then
				local message = settings[settingId] and 
					"Visual effects disabled for better performance" or 
					"Visual effects re-enabled"
				-- Could show notification if Notifier is available  
			elseif settingId == "HideOtherPlayers" then
				local message = settings[settingId] and 
					"Other players are now hidden" or 
					"Other players are now visible"
				-- Could show notification if Notifier is available
			end
		end
	end
end

-- Set a slider setting value
local function setSliderValue(settingId, value)
	local settingConfig = SettingsConfig.GetSetting(settingId)
	if not settingConfig then return end
	
	-- Clamp value to min/max
	value = math.clamp(value, settingConfig.MinValue, settingConfig.MaxValue)
	settings[settingId] = value
	saveSetting(settingId, value)
	applyEffects()
	
	-- Update the UI for this setting
	local settingFrame = ui.SettingFrames[settingId]
	if settingFrame then
		SettingsUI.UpdateSettingFrame(settingFrame, settingId, value)
	end
	
	if soundController then
		soundController:playUIClick()
	end
end

-- Handle slider interaction
local function setupSliderInteraction(settingFrame, settingId)
	local settingConfig = SettingsConfig.GetSetting(settingId)
	if not settingConfig or settingConfig.Type ~= "Slider" then return end
	
	local sliderKnob = settingFrame.SliderKnob
	local sliderTrack = settingFrame.SliderTrack
	local sliderContainer = settingFrame.SliderContainer
	
	local UserInputService = game:GetService("UserInputService")
	local isDragging = false
	
	local function updateSliderFromPosition(inputPosition)
		local trackPosition = sliderTrack.AbsolutePosition
		local trackSize = sliderTrack.AbsoluteSize
		local relativeX = inputPosition.X - trackPosition.X
		
		-- Calculate normalized position (0 to 1)
		local normalizedPosition = math.clamp(relativeX / trackSize.X, 0, 1)
		
		-- Convert to actual value
		local value = settingConfig.MinValue + (normalizedPosition * (settingConfig.MaxValue - settingConfig.MinValue))
		
		setSliderValue(settingId, value)
	end
	
	-- Mouse/touch down
	sliderKnob.MouseButton1Down:Connect(function()
		isDragging = true
	end)
	
	-- Track click
	sliderTrack.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			updateSliderFromPosition(input.Position)
			isDragging = true
		end
	end)
	
	-- Drag handling
	UserInputService.InputChanged:Connect(function(input)
		if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			updateSliderFromPosition(input.Position)
		end
	end)
	
	-- Stop dragging
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isDragging = false
		end
	end)
end

-- Update settings display
local function updateSettingsDisplay()
	if not ui then return end

	-- Clear existing setting frames
	for _, frame in pairs(ui.SettingFrames) do
		if frame.Frame then
			frame.Frame:Destroy()
		end
	end
	ui.SettingFrames = {}

	-- Create setting frames for each setting
	local layoutOrder = 0
	for settingId, _ in pairs(SettingsConfig.Settings) do
		layoutOrder = layoutOrder + 1
		local settingFrame = SettingsUI.CreateSettingFrame(ui.ScrollingFrame, settingId, settings[settingId])
		if settingFrame then
			settingFrame.Frame.LayoutOrder = layoutOrder
			ui.SettingFrames[settingId] = settingFrame

			local settingConfig = SettingsConfig.GetSetting(settingId)
			if settingConfig and settingConfig.Type == "Slider" then
				-- Setup slider interaction
				setupSliderInteraction(settingFrame, settingId)
			else
				-- Connect toggle button for boolean settings
				if settingFrame.ToggleButton then
					settingFrame.ToggleButton.MouseButton1Click:Connect(function()
						toggleSetting(settingId)
					end)
				end
			end
		end
	end

	-- Update scroll frame canvas size
	ui.ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, layoutOrder * 135) -- 120 height + 15 padding
end

-- Toggle settings GUI
local function toggleSettingsGUI()
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
		
		-- Refresh settings display when opening
		updateSettingsDisplay()
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

function SettingsController.Start(parentGui, soundControllerRef)
	soundController = soundControllerRef
	
	-- Load settings first
	loadSettings()
	
	-- Create UI
	ui = SettingsUI.Create(parentGui)
	
	-- Register with NavigationController instead of connecting to toggle button
	NavigationController.RegisterController("Settings", function()
		toggleSettingsGUI()
	end)
	
	-- Connect close button
	ui.CloseButton.MouseButton1Click:Connect(function()
		if soundController then
			soundController:playUIClick()
		end
		if isVisible then
			toggleSettingsGUI()
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
					toggleSettingsGUI()
				end
			end
		end
	end)
	
	-- Handle players joining for hide players setting
	Players.PlayerAdded:Connect(onPlayerAdded)
	
	-- Handle existing players
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			onPlayerAdded(player)
		end
	end
	
	-- Apply effects on start
	applyEffects()

	-- Reapply effects whenever the local player's character respawns
	LocalPlayer.CharacterAdded:Connect(function()
		task.wait(2) -- Wait for character to fully load
		applyEffects()
	end)
 
	-- Also listen for the Boxes folder being added later in case the map loads it after
	-- this script has run. Once it appears, immediately update visibility.
	workspace.ChildAdded:Connect(function(child)
	    if child.Name == "Boxes" then
	        task.defer(updateCrateVisibility)
	    end
	end)
	
	-- Initial settings display
	updateSettingsDisplay()
end

-- Expose settings for other systems to check
function SettingsController.GetSetting(settingId)
	return settings[settingId]
end

-- Expose function to check if effects are disabled
function SettingsController.AreEffectsDisabled()
	return settings.DisableEffects or false
end

-- Expose function to check if other players are hidden
function SettingsController.AreOtherPlayersHidden()
	return settings.HideOtherPlayers or false
end

return SettingsController 