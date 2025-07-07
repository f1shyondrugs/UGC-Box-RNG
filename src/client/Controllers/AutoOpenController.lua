-- AutoOpenController.lua
-- Controls the Auto-Open feature with gamepass integration and settings management

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local Shared = ReplicatedStorage.Shared
local Remotes = require(Shared.Remotes.Remotes)
local GameConfig = require(Shared.Modules.GameConfig)
local NumberFormatter = require(Shared.Modules.NumberFormatter)
local AutoOpenUI = require(script.Parent.Parent.UI.AutoOpenUI)
local NavigationController = require(script.Parent.Parent.Controllers.NavigationController)
local CrateSelectionController = require(script.Parent.Parent.Controllers.CrateSelectionController)

local AutoOpenController = {}

-- Constants
local AUTO_OPEN_GAMEPASS_ID = GameConfig.AutoOpenGamepassId
local AUTO_SELL_GAMEPASS_ID = GameConfig.AutoSellGamepassId
local SETTINGS_KEY = "AutoOpenSettings_v1"

-- State
local ui = nil
local soundController = nil
local settings = {
	enabled = false,
	crateCount = 10,
	infiniteCrates = false,
	moneyThreshold = 1000,
	infiniteMoney = false,
	sizeThreshold = 3,
	valueThreshold = 100,
	autoSellEnabled = false, -- Default off as requested
	selectedCrate = "FreeCrate"
}
local isProcessing = false
local hasAutoOpenGamepass = false
local hasAutoSellGamepass = false
local isSettingsOpen = false
local hiddenUIs = {}
local autoOpenConnection = nil -- To track and cancel auto-opening

-- Hide other UIs for clean auto-open experience
local function hideOtherUIs(show)
	local playerGui = LocalPlayer:WaitForChild("PlayerGui")
	
	if show then
		-- Hide other UIs for clean auto-open experience
		for _, gui in pairs(playerGui:GetChildren()) do
			if gui:IsA("ScreenGui") and gui.Name ~= "AutoOpenGui" and gui.Name ~= "CrateSelectionGui" then
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

-- Settings persistence
local function sendSettingsToServer()
	if Remotes.UpdateAutoSellSettings then
		Remotes.UpdateAutoSellSettings:FireServer(settings)
	end
end

local function saveSettings()
	local dataToSave = {
		enabled = settings.enabled,
		crateCount = settings.crateCount,
		infiniteCrates = settings.infiniteCrates,
		moneyThreshold = settings.moneyThreshold,
		infiniteMoney = settings.infiniteMoney,
		sizeThreshold = settings.sizeThreshold,
		valueThreshold = settings.valueThreshold,
		autoSellEnabled = settings.autoSellEnabled,
		selectedCrate = settings.selectedCrate
	}
	
	local success, errorMsg = pcall(function()
		LocalPlayer:SetAttribute(SETTINGS_KEY, game:GetService("HttpService"):JSONEncode(dataToSave))
	end)
	
	if not success then
		warn("Failed to save Auto-Open settings:", errorMsg)
	end
	sendSettingsToServer()
end

local function loadSettings()
	local success, result = pcall(function()
		local savedData = LocalPlayer:GetAttribute(SETTINGS_KEY)
		if savedData then
			return game:GetService("HttpService"):JSONDecode(savedData)
		end
		return nil
	end)
	
	if success and result then
		settings.enabled = result.enabled or false
		settings.crateCount = result.crateCount or 10
		settings.infiniteCrates = result.infiniteCrates or false
		settings.moneyThreshold = result.moneyThreshold or 1000
		settings.infiniteMoney = result.infiniteMoney or false
		settings.sizeThreshold = result.sizeThreshold or 3
		settings.valueThreshold = result.valueThreshold or 100
		settings.autoSellEnabled = result.autoSellEnabled ~= nil and result.autoSellEnabled or true
		settings.selectedCrate = result.selectedCrate or "FreeCrate"
	end
end

-- Gamepass checking
local function checkAutoOpenGamepass()
	local isWhitelisted = false
	for _, id in ipairs(GameConfig.GamepassWhitelist or {}) do
		if LocalPlayer.UserId == id then
			isWhitelisted = true
			break
		end
	end

	if isWhitelisted then
		hasAutoOpenGamepass = true
		return true
	end

	local success, owns = pcall(function()
		return Remotes.CheckAutoOpenGamepass:InvokeServer()
	end)
	
	if success then
		hasAutoOpenGamepass = owns
	else
		hasAutoOpenGamepass = false
		warn("Failed to check Auto-Open gamepass ownership")
	end
	
	return hasAutoOpenGamepass
end

local function checkAutoSellGamepass()
	local isWhitelisted = false
	for _, id in ipairs(GameConfig.GamepassWhitelist or {}) do
		if LocalPlayer.UserId == id then
			isWhitelisted = true
			break
		end
	end

	if isWhitelisted then
		hasAutoSellGamepass = true
		return true
	end

	local success, owns = pcall(function()
		return Remotes.CheckAutoSellGamepass:InvokeServer()
	end)
	
	if success then
		hasAutoSellGamepass = owns
	else
		hasAutoSellGamepass = false
		warn("Failed to check Auto-Sell gamepass ownership")
	end
	
	return hasAutoSellGamepass
end

local function promptAutoOpenGamepassPurchase()
	if soundController then
		soundController:playUIClick()
	end
	
	local success, errorMsg = pcall(function()
		MarketplaceService:PromptGamePassPurchase(LocalPlayer, AUTO_OPEN_GAMEPASS_ID)
	end)
	
	if not success then
		warn("Failed to prompt Auto-Open gamepass purchase:", errorMsg)
	end
end

local function promptAutoSellGamepassPurchase()
	if soundController then
		soundController:playUIClick()
	end
	
	local success, errorMsg = pcall(function()
		MarketplaceService:PromptGamePassPurchase(LocalPlayer, AUTO_SELL_GAMEPASS_ID)
	end)
	
	if not success then
		warn("Failed to prompt Auto-Sell gamepass purchase:", errorMsg)
	end
end

-- UI Management
local function updateUI()
	if not ui then return end
	
	-- Update toggle state (only enable if has Auto-Open gamepass)
	AutoOpenUI.UpdateToggleState(ui.EnableToggle, ui.EnableSection.Indicator, settings.enabled and hasAutoOpenGamepass)
	
	-- Update auto-sell toggle (only enable if has Auto-Sell gamepass)
	if ui.AutoSellSection then
		AutoOpenUI.UpdateToggleState(ui.AutoSellToggle, ui.AutoSellSection.Indicator, settings.autoSellEnabled and hasAutoSellGamepass)
	end
	
	-- Update input values and infinite toggles
	ui.CountInput.Text = tostring(settings.crateCount)
	if ui.CountSection.SetInfinite then
		ui.CountSection.SetInfinite(settings.infiniteCrates)
	end
	
	ui.MoneyInput.Text = NumberFormatter.FormatNumber(settings.moneyThreshold)
	if ui.MoneySection.SetInfinite then
		ui.MoneySection.SetInfinite(settings.infiniteMoney)
	end
	
	ui.SizeInput.Text = tostring(settings.sizeThreshold)
	ui.ValueInput.Text = NumberFormatter.FormatNumber(settings.valueThreshold)
	
	-- Update crate selection button text
	if ui.CrateSelectButton then
		local crateName = settings.selectedCrate or "FreeCrate"
		local displayName = crateName:gsub("Crate", "")
		ui.CrateSelectButton.Text = "📦 " .. displayName
	end
	
	-- Show auto-sell sections but make them visually disabled when auto-sell is off
	if ui.SizeSection and ui.SizeSection.Section then
		ui.SizeSection.Section.Visible = hasAutoSellGamepass
		-- Make section appear disabled when auto-sell is off
		ui.SizeSection.Section.BackgroundTransparency = (hasAutoSellGamepass and settings.autoSellEnabled) and 0 or 0.7
		-- Disable input when auto-sell is off
		if ui.SizeInput then
			ui.SizeInput.TextEditable = hasAutoSellGamepass and settings.autoSellEnabled
			ui.SizeInput.TextColor3 = (hasAutoSellGamepass and settings.autoSellEnabled) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(120, 120, 120)
		end
		-- Disable buttons when auto-sell is off
		if ui.SizeSection.DecreaseButton then
			ui.SizeSection.DecreaseButton.BackgroundColor3 = (hasAutoSellGamepass and settings.autoSellEnabled) and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(50, 50, 50)
		end
		if ui.SizeSection.IncreaseButton then
			ui.SizeSection.IncreaseButton.BackgroundColor3 = (hasAutoSellGamepass and settings.autoSellEnabled) and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(50, 50, 50)
		end
	end
	if ui.ValueSection and ui.ValueSection.Section then
		ui.ValueSection.Section.Visible = hasAutoSellGamepass
		-- Make section appear disabled when auto-sell is off
		ui.ValueSection.Section.BackgroundTransparency = (hasAutoSellGamepass and settings.autoSellEnabled) and 0 or 0.7
		-- Disable input when auto-sell is off
		if ui.ValueInput then
			ui.ValueInput.TextEditable = hasAutoSellGamepass and settings.autoSellEnabled
			ui.ValueInput.TextColor3 = (hasAutoSellGamepass and settings.autoSellEnabled) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(120, 120, 120)
		end
		-- Disable buttons when auto-sell is off
		if ui.ValueSection.DecreaseButton then
			ui.ValueSection.DecreaseButton.BackgroundColor3 = (hasAutoSellGamepass and settings.autoSellEnabled) and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(50, 50, 50)
		end
		if ui.ValueSection.IncreaseButton then
			ui.ValueSection.IncreaseButton.BackgroundColor3 = (hasAutoSellGamepass and settings.autoSellEnabled) and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(50, 50, 50)
		end
	end
	
	-- Show/hide features section and purchase button based on gamepass ownership
	if ui.FeaturesSection then
		ui.FeaturesSection.Visible = not hasAutoSellGamepass
	end
	if ui.PurchaseButton then
		ui.PurchaseButton.Visible = not hasAutoSellGamepass
	end
	
	-- Update section transparency and add lock indicators based on gamepass ownership
	if ui.AutoSellSection and ui.AutoSellSection.Section then
		ui.AutoSellSection.Section.BackgroundTransparency = hasAutoSellGamepass and 0 or 0.7
		-- Add lock indicator if no gamepass
		if not hasAutoSellGamepass then
			if not ui.AutoSellSection.Section:FindFirstChild("LockIcon") then
				local lockIcon = Instance.new("TextLabel")
				lockIcon.Name = "LockIcon"
				lockIcon.Size = UDim2.new(0, 20, 0, 20)
				lockIcon.Position = UDim2.new(1, -25, 0, 5)
				lockIcon.Text = "🔒"
				lockIcon.Font = Enum.Font.GothamBold
				lockIcon.TextSize = 14
				lockIcon.TextColor3 = Color3.fromRGB(255, 150, 50)
				lockIcon.BackgroundTransparency = 1
				lockIcon.ZIndex = 206
				lockIcon.Parent = ui.AutoSellSection.Section
			end
		else
			local lockIcon = ui.AutoSellSection.Section:FindFirstChild("LockIcon")
			if lockIcon then
				lockIcon:Destroy()
			end
		end
		
		-- Update title to show disabled state when auto-sell is off
		if ui.AutoSellSection.Title then
			if hasAutoSellGamepass and not settings.autoSellEnabled then
				ui.AutoSellSection.Title.Text = "Enable Auto-Sell (Disabled)"
				ui.AutoSellSection.Title.TextColor3 = Color3.fromRGB(150, 150, 150)
			else
				ui.AutoSellSection.Title.Text = "Enable Auto-Sell"
				ui.AutoSellSection.Title.TextColor3 = Color3.fromRGB(255, 255, 255)
			end
		end
	end
	
	if ui.SizeSection and ui.SizeSection.Section then
		ui.SizeSection.Section.BackgroundTransparency = hasAutoSellGamepass and 0 or 0.7
		-- Add lock indicator if no gamepass
		if not hasAutoSellGamepass then
			if not ui.SizeSection.Section:FindFirstChild("LockIcon") then
				local lockIcon = Instance.new("TextLabel")
				lockIcon.Name = "LockIcon"
				lockIcon.Size = UDim2.new(0, 20, 0, 20)
				lockIcon.Position = UDim2.new(1, -25, 0, 5)
				lockIcon.Text = "🔒"
				lockIcon.Font = Enum.Font.GothamBold
				lockIcon.TextSize = 14
				lockIcon.TextColor3 = Color3.fromRGB(255, 150, 50)
				lockIcon.BackgroundTransparency = 1
				lockIcon.ZIndex = 206
				lockIcon.Parent = ui.SizeSection.Section
			end
		else
			local lockIcon = ui.SizeSection.Section:FindFirstChild("LockIcon")
			if lockIcon then
				lockIcon:Destroy()
			end
		end
		
		-- Update title to show disabled state when auto-sell is off
		if ui.SizeSection.Title then
			if hasAutoSellGamepass and not settings.autoSellEnabled then
				ui.SizeSection.Title.Text = "Auto-Sell Below Size (Disabled)"
				ui.SizeSection.Title.TextColor3 = Color3.fromRGB(150, 150, 150)
			else
				ui.SizeSection.Title.Text = "Auto-Sell Below Size"
				ui.SizeSection.Title.TextColor3 = Color3.fromRGB(255, 255, 255)
			end
		end
	end
	
	if ui.ValueSection and ui.ValueSection.Section then
		ui.ValueSection.Section.BackgroundTransparency = hasAutoSellGamepass and 0 or 0.7
		-- Add lock indicator if no gamepass
		if not hasAutoSellGamepass then
			if not ui.ValueSection.Section:FindFirstChild("LockIcon") then
				local lockIcon = Instance.new("TextLabel")
				lockIcon.Name = "LockIcon"
				lockIcon.Size = UDim2.new(0, 20, 0, 20)
				lockIcon.Position = UDim2.new(1, -25, 0, 5)
				lockIcon.Text = "🔒"
				lockIcon.Font = Enum.Font.GothamBold
				lockIcon.TextSize = 14
				lockIcon.TextColor3 = Color3.fromRGB(255, 150, 50)
				lockIcon.BackgroundTransparency = 1
				lockIcon.ZIndex = 206
				lockIcon.Parent = ui.ValueSection.Section
			end
		else
			local lockIcon = ui.ValueSection.Section:FindFirstChild("LockIcon")
			if lockIcon then
				lockIcon:Destroy()
			end
		end
		
		-- Update title to show disabled state when auto-sell is off
		if ui.ValueSection.Title then
			if hasAutoSellGamepass and not settings.autoSellEnabled then
				ui.ValueSection.Title.Text = "Auto-Sell Below Value (Disabled)"
				ui.ValueSection.Title.TextColor3 = Color3.fromRGB(150, 150, 150)
			else
				ui.ValueSection.Title.Text = "Auto-Sell Below Value"
				ui.ValueSection.Title.TextColor3 = Color3.fromRGB(255, 255, 255)
			end
		end
	end
	
	-- Removed AutoOpenButton UI update logic as it is now part of NavigationUI
end

local function collectSettingsFromUI()
	if not ui then return end
	
	local NumberFormatter = require(game.ReplicatedStorage.Shared.Modules.NumberFormatter)
	
	-- Collect input values and infinite states
	if ui.CountSection.IsInfinite and not ui.CountSection.IsInfinite() then
		local parsedValue = NumberFormatter.ParseFormattedNumber(ui.CountInput.Text)
		-- If parsing returns 0, it might be because the input is just "0" or invalid
		-- So we only fall back to regular parsing if the input doesn't contain any letters
		if parsedValue == 0 and not string.match(ui.CountInput.Text, "[%a]") then
			parsedValue = tonumber(ui.CountInput.Text) or 10
		end
		settings.crateCount = math.max(parsedValue, 1)
	end
	settings.infiniteCrates = ui.CountSection.IsInfinite and ui.CountSection.IsInfinite() or false
	
	if ui.MoneySection.IsInfinite and not ui.MoneySection.IsInfinite() then
		local parsedValue = NumberFormatter.ParseFormattedNumber(ui.MoneyInput.Text)
		-- If parsing returns 0, it might be because the input is just "0" or invalid
		-- So we only fall back to regular parsing if the input doesn't contain any letters
		if parsedValue == 0 and not string.match(ui.MoneyInput.Text, "[%a]") then
			parsedValue = tonumber(ui.MoneyInput.Text) or 1000
		end
		settings.moneyThreshold = math.max(parsedValue, 0)
	end
	settings.infiniteMoney = ui.MoneySection.IsInfinite and ui.MoneySection.IsInfinite() or false
	
	-- Only update auto-sell settings if player has the gamepass and auto-sell is enabled
	if hasAutoSellGamepass and settings.autoSellEnabled then
		local parsedSizeValue = NumberFormatter.ParseFormattedNumber(ui.SizeInput.Text)
		-- If parsing returns 0, it might be because the input is just "0" or invalid
		-- So we only fall back to regular parsing if the input doesn't contain any letters
		if parsedSizeValue == 0 and not string.match(ui.SizeInput.Text, "[%a]") then
			parsedSizeValue = tonumber(ui.SizeInput.Text) or 3
		end
		settings.sizeThreshold = math.max(parsedSizeValue, 0)
		
		local parsedValueThreshold = NumberFormatter.ParseFormattedNumber(ui.ValueInput.Text)
		-- If parsing returns 0, it might be because the input is just "0" or invalid
		-- So we only fall back to regular parsing if the input doesn't contain any letters
		if parsedValueThreshold == 0 and not string.match(ui.ValueInput.Text, "[%a]") then
			parsedValueThreshold = tonumber(ui.ValueInput.Text) or 100
		end
		settings.valueThreshold = math.max(parsedValueThreshold, 0)
	end
	
	saveSettings()
end

local function toggleSettings()
	if not ui then return end
	
	if soundController then
		soundController:playUIClick()
	end
	
	isSettingsOpen = not isSettingsOpen
	
	if isSettingsOpen then
		hideOtherUIs(true) -- Hide other UIs when showing auto-open panel
		AutoOpenUI.ShowSettings(ui)
		updateUI()
	else
		hideOtherUIs(false) -- Restore other UIs when hiding auto-open panel
		AutoOpenUI.HideSettings(ui)
		collectSettingsFromUI()
	end
end

-- Auto-Open Logic
local function shouldAutoSellItem(itemInstance, itemName, itemConfig)
	if not settings.autoSellEnabled then return false end
	if not itemInstance or not itemConfig then return false end
	
	-- Check size threshold
	local size = itemInstance:GetAttribute("Size") or 1
	if size < settings.sizeThreshold then
		return true
	end
	
	-- Check value threshold
	local value = itemConfig.Value or 0
	if value < settings.valueThreshold then
		return true
	end
	
	return false
end

local function processAutoOpen()
	print("[AutoOpenController] processAutoOpen called.")
	if not settings.enabled or not hasAutoOpenGamepass then
		isProcessing = false
		print("[AutoOpenController] Auto-Open not enabled or no Auto-Open gamepass. Exiting processAutoOpen.")
		return
	end
	
	-- Check if we should stop due to being disabled
	if not settings.enabled then
		isProcessing = false
		print("[AutoOpenController] Auto-Open setting disabled. Exiting processAutoOpen.")
		return
	end
	
	-- Check money threshold (unless infinite)
	if not settings.infiniteMoney then
		local currentMoney = LocalPlayer:GetAttribute("RobuxValue") or 0
		if currentMoney < settings.moneyThreshold then
			isProcessing = false
			print("[AutoOpenController] Money below threshold. Exiting processAutoOpen.")
			return
		end
		print("[AutoOpenController] Money check passed: R$" .. currentMoney)
	end
	
	isProcessing = true
	print("[AutoOpenController] Started processing auto-open.")
	
	-- Get selected crate from saved settings
	local selectedCrate = settings.selectedCrate
	print("[AutoOpenController] Selected Crate Type: " .. selectedCrate)
	
	-- Get the crate config for price checks
	local crateConfig = GameConfig.Boxes[selectedCrate]
	if not crateConfig then
		isProcessing = false
		print("[AutoOpenController] Crate config not found for type: " .. selectedCrate .. ". Exiting processAutoOpen.")
		return
	end
	
	local currentMoney = LocalPlayer:GetAttribute("RobuxValue") or 0
	if crateConfig.Price and currentMoney < crateConfig.Price then
		isProcessing = false
		print("[AutoOpenController] Not enough money to afford crate (R$" .. currentMoney .. " < R$" .. crateConfig.Price .. "). Exiting processAutoOpen.")
		return
	end
	
	-- Determine how many crates to open
	local cratesToOpen
	if settings.infiniteCrates then
		-- For infinite mode, open one at a time and check conditions each time
		cratesToOpen = 1
		print("[AutoOpenController] Infinite crates mode: Opening 1 crate.")
	else
		-- For limited mode, calculate based on available money and desired count
		local maxAffordable = math.floor(currentMoney / (crateConfig.Price or 1))
		cratesToOpen = math.min(settings.crateCount, maxAffordable)
		print("[AutoOpenController] Limited crates mode: Crates to open: " .. cratesToOpen .. ", Max affordable: " .. maxAffordable)
	end
	
	if cratesToOpen <= 0 then
		isProcessing = false
		print("[AutoOpenController] Crates to open is 0 or less. Exiting processAutoOpen.")
		return
	end
	
	-- Process crate opening with cancellation checks
	local openedCount = 0
	for i = 1, cratesToOpen do
		print("[AutoOpenController] Attempting to open crate " .. (openedCount + 1) .. "/" .. cratesToOpen .. ".")
		-- Check if auto-open was disabled during processing
		if not settings.enabled or not hasAutoOpenGamepass then
			print("[AutoOpenController] Auto-Open disabled or Auto-Open gamepass lost during processing. Breaking loop.")
			break
		end
		
		task.wait(0.1) -- Small delay between requests
		
		-- Re-check conditions before each crate
		local currentMoney = LocalPlayer:GetAttribute("RobuxValue") or 0
		
		-- Check money threshold (unless infinite)
		if not settings.infiniteMoney and currentMoney < settings.moneyThreshold then
			print("[AutoOpenController] Money below threshold during processing. Breaking loop.")
			break
		end
		
		-- Check if we can afford this crate
		if crateConfig.Price and currentMoney < crateConfig.Price then
			print("[AutoOpenController] Not enough money for next crate during processing. Breaking loop.")
			break
		end
		
		-- Request box from server
		print("[AutoOpenController] Firing Remotes.RequestBox for crate: " .. selectedCrate)
		local success, errorMsg = pcall(function()
			Remotes.RequestBox:FireServer(selectedCrate)
		end)
		
		if not success then
			warn("Auto-Open failed to request box:", errorMsg)
			print("[AutoOpenController] Remote.RequestBox failed: " .. errorMsg .. ". Breaking loop.")
			break
		end
		
		openedCount = openedCount + 1
		
		-- For infinite mode, continue indefinitely until conditions are no longer met
		if settings.infiniteCrates then
			task.wait(1) -- Wait between infinite crates
			-- For infinite mode, the loop continues. No specific box to re-find here.
			-- The server is responsible for spawning new boxes.
			print("[AutoOpenController] Finished opening 1 crate in infinite mode. Looping again.")
		else
			task.wait(1) -- Wait for processing
			print("[AutoOpenController] Finished opening 1 crate in limited mode. Continuing loop.")
		end
	end
	
	isProcessing = false
	print("[AutoOpenController] Auto-open processing finished.")
end

-- Auto-Sell Logic (triggered when items are received)
local function handleNewItem(itemInstance, itemName)
	if not settings.autoSellEnabled or not hasAutoSellGamepass then return end
	
	local itemConfig = GameConfig.Items[itemName]
	if shouldAutoSellItem(itemInstance, itemName, itemConfig) then
		-- Send auto-sell request to server
		task.wait(0.1) -- Small delay to ensure item is fully processed
		local success, errorMsg = pcall(function()
			Remotes.SellItem:FireServer(itemInstance)
		end)
		
		if not success then
			warn("Auto-Sell failed:", errorMsg)
		end
	end
end

-- Main functions
function AutoOpenController.Start(parentGui, soundControllerRef)
	soundController = soundControllerRef
	
	-- Load saved settings
	loadSettings()
	
	-- Check gamepass ownership for both Auto-Open and Auto-Sell
	checkAutoOpenGamepass()
	checkAutoSellGamepass()
	
	-- Create UI
	ui = AutoOpenUI.Create(parentGui)
	
	-- Register with NavigationController instead of connecting to a standalone button
	NavigationController.RegisterController("AutoOpen", function()
		-- Temporarily bypass gamepass check for debugging
		toggleSettings()
	end)
	
	-- Connect settings close button
	ui.CloseButton.MouseButton1Click:Connect(function()
		if isSettingsOpen then
			toggleSettings()
		end
	end)
	
	-- Connect enable toggle
	ui.EnableToggle.MouseButton1Click:Connect(function()
		if hasAutoOpenGamepass then
			local wasEnabled = settings.enabled
			settings.enabled = not settings.enabled
			
			-- If disabling, immediately stop any ongoing auto-opening
			if wasEnabled and not settings.enabled then
				isProcessing = false -- This will cause processAutoOpen to stop
			end
			
			updateUI()
			saveSettings()
			
			if soundController then
				soundController:playUIClick()
			end
		else
			promptAutoOpenGamepassPurchase()
		end
	end)
	
	-- Connect auto-sell toggle
	if ui.AutoSellSection then
		ui.AutoSellToggle.MouseButton1Click:Connect(function()
			if hasAutoSellGamepass then
				settings.autoSellEnabled = not settings.autoSellEnabled
				if soundController then soundController:playUIClick() end
				updateUI()
				saveSettings()
			else
				if soundController then soundController:playUIClick() end
				promptAutoSellGamepassPurchase()
			end
		end)
	end
	
	-- Connect infinite toggles
	if ui.CountSection.InfiniteToggle then
		ui.CountSection.InfiniteToggle.MouseButton1Click:Connect(function()
			task.wait(0.1) -- Wait for toggle to update
			settings.infiniteCrates = ui.CountSection.IsInfinite()
			saveSettings()
		end)
	end
	
	if ui.MoneySection.InfiniteToggle then
		ui.MoneySection.InfiniteToggle.MouseButton1Click:Connect(function()
			task.wait(0.1) -- Wait for toggle to update
			settings.infiniteMoney = ui.MoneySection.IsInfinite()
			saveSettings()
		end)
	end
	
	-- Connect input change events
	local function setupInputConnection(input, settingName, min)
		input.FocusLost:Connect(function()
			-- Try to parse formatted numbers first (like "100Q")
			local value = NumberFormatter.ParseFormattedNumber(input.Text)
			-- If parsing returns 0, it might be because the input is just "0" or invalid
			-- So we only fall back to regular parsing if the input doesn't contain any letters
			if value == 0 and not string.match(input.Text, "[%a]") then
				-- Fall back to regular number parsing only for pure numbers
				value = tonumber(input.Text)
			end
			if value and value > 0 then
				-- Remove max constraint - only enforce minimum
				settings[settingName] = math.max(value, min or 0)
				input.Text = tostring(settings[settingName])
				saveSettings()
			end
		end)
	end
	
	setupInputConnection(ui.CountInput, "crateCount", 1)
	setupInputConnection(ui.MoneyInput, "moneyThreshold", 0)
	
	-- Auto-sell input connections with gamepass check
	if ui.SizeInput then
		ui.SizeInput.FocusLost:Connect(function()
			if hasAutoSellGamepass and settings.autoSellEnabled then
				-- Try to parse formatted numbers first (like "100Q")
				local value = NumberFormatter.ParseFormattedNumber(ui.SizeInput.Text)
				-- If parsing returns 0, it might be because the input is just "0" or invalid
				-- So we only fall back to regular parsing if the input doesn't contain any letters
				if value == 0 and not string.match(ui.SizeInput.Text, "[%a]") then
					-- Fall back to regular number parsing only for pure numbers
					value = tonumber(ui.SizeInput.Text)
				end
				if value and value > 0 then
					settings.sizeThreshold = math.max(value, 0)
					ui.SizeInput.Text = NumberFormatter.FormatNumber(settings.sizeThreshold)
					saveSettings()
				end
			elseif not hasAutoSellGamepass then
				if soundController then soundController:playUIClick() end
				promptAutoSellGamepassPurchase()
			end
		end)
	end
	
	if ui.ValueInput then
		ui.ValueInput.FocusLost:Connect(function()
			if hasAutoSellGamepass and settings.autoSellEnabled then
				-- Try to parse formatted numbers first (like "100Q")
				local value = NumberFormatter.ParseFormattedNumber(ui.ValueInput.Text)
				-- If parsing returns 0, it might be because the input is just "0" or invalid
				-- So we only fall back to regular parsing if the input doesn't contain any letters
				if value == 0 and not string.match(ui.ValueInput.Text, "[%a]") then
					-- Fall back to regular number parsing only for pure numbers
					value = tonumber(ui.ValueInput.Text)
				end
				if value and value > 0 then
					settings.valueThreshold = math.max(value, 0)
					ui.ValueInput.Text = NumberFormatter.FormatNumber(settings.valueThreshold)
					saveSettings()
				end
			elseif not hasAutoSellGamepass then
				if soundController then soundController:playUIClick() end
				promptAutoSellGamepassPurchase()
			end
		end)
	end
	
	-- Auto-sell button handlers with gamepass check
	if ui.SizeSection and ui.SizeSection.DecreaseButton then
		ui.SizeSection.DecreaseButton.MouseButton1Click:Connect(function()
			if hasAutoSellGamepass and settings.autoSellEnabled then
				local current = NumberFormatter.ParseFormattedNumber(ui.SizeInput.Text)
				-- If parsing returns 0, it might be because the input is just "0" or invalid
				-- So we only fall back to regular parsing if the input doesn't contain any letters
				if current == 0 and not string.match(ui.SizeInput.Text, "[%a]") then
					current = tonumber(ui.SizeInput.Text) or 3
				end
				local newValue = math.max(0, current - 1)
				ui.SizeInput.Text = NumberFormatter.FormatNumber(newValue)
				settings.sizeThreshold = newValue
				saveSettings()
			elseif not hasAutoSellGamepass then
				if soundController then soundController:playUIClick() end
				promptAutoSellGamepassPurchase()
			end
		end)
	end
	
	if ui.SizeSection and ui.SizeSection.IncreaseButton then
		ui.SizeSection.IncreaseButton.MouseButton1Click:Connect(function()
			if hasAutoSellGamepass and settings.autoSellEnabled then
				local current = NumberFormatter.ParseFormattedNumber(ui.SizeInput.Text)
				-- If parsing returns 0, it might be because the input is just "0" or invalid
				-- So we only fall back to regular parsing if the input doesn't contain any letters
				if current == 0 and not string.match(ui.SizeInput.Text, "[%a]") then
					current = tonumber(ui.SizeInput.Text) or 3
				end
				local newValue = current + 1
				ui.SizeInput.Text = NumberFormatter.FormatNumber(newValue)
				settings.sizeThreshold = newValue
				saveSettings()
			elseif not hasAutoSellGamepass then
				if soundController then soundController:playUIClick() end
				promptAutoSellGamepassPurchase()
			end
		end)
	end
	
	if ui.ValueSection and ui.ValueSection.DecreaseButton then
		ui.ValueSection.DecreaseButton.MouseButton1Click:Connect(function()
			if hasAutoSellGamepass and settings.autoSellEnabled then
				local current = NumberFormatter.ParseFormattedNumber(ui.ValueInput.Text)
				-- If parsing returns 0, it might be because the input is just "0" or invalid
				-- So we only fall back to regular parsing if the input doesn't contain any letters
				if current == 0 and not string.match(ui.ValueInput.Text, "[%a]") then
					current = tonumber(ui.ValueInput.Text) or 100
				end
				local newValue = math.max(0, current - 1)
				ui.ValueInput.Text = NumberFormatter.FormatNumber(newValue)
				settings.valueThreshold = newValue
				saveSettings()
			elseif not hasAutoSellGamepass then
				if soundController then soundController:playUIClick() end
				promptAutoSellGamepassPurchase()
			end
		end)
	end
	
	if ui.ValueSection and ui.ValueSection.IncreaseButton then
		ui.ValueSection.IncreaseButton.MouseButton1Click:Connect(function()
			if hasAutoSellGamepass and settings.autoSellEnabled then
				local current = NumberFormatter.ParseFormattedNumber(ui.ValueInput.Text)
				-- If parsing returns 0, it might be because the input doesn't contain any letters
				-- So we only fall back to regular parsing if the input doesn't contain any letters
				if current == 0 and not string.match(ui.ValueInput.Text, "[%a]") then
					current = tonumber(ui.ValueInput.Text) or 100
				end
				local newValue = current + 1
				ui.ValueInput.Text = NumberFormatter.FormatNumber(newValue)
				settings.valueThreshold = newValue
				saveSettings()
			elseif not hasAutoSellGamepass then
				if soundController then soundController:playUIClick() end
				promptAutoSellGamepassPurchase()
			end
		end)
	end
	
	-- Connect crate selection button
	if ui.CrateSelectButton then
		ui.CrateSelectButton.MouseButton1Click:Connect(function()
			CrateSelectionController:Show()
		end)
	end
	
	-- Connect purchase button
	if ui.PurchaseButton then
		ui.PurchaseButton.MouseButton1Click:Connect(function()
			if soundController then
				soundController:playUIClick()
			end
			promptAutoSellGamepassPurchase()
		end)
	end
	
	-- Listen for crate selection changes
	local lastSelectedCrate = settings.selectedCrate
	task.spawn(function()
		while true do
			task.wait(0.5) -- Check every half second
			local currentSelectedCrate = CrateSelectionController:GetSelectedCrate()
			if currentSelectedCrate ~= lastSelectedCrate then
				lastSelectedCrate = currentSelectedCrate
				settings.selectedCrate = currentSelectedCrate
				updateUI()
				saveSettings()
				print("[AutoOpenController] Selected crate updated to: " .. currentSelectedCrate)
			end
		end
	end)
	
	-- Monitor gamepass purchase completion
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamepassId, wasPurchased)
		if player == LocalPlayer and wasPurchased then
			if gamepassId == AUTO_OPEN_GAMEPASS_ID then
				hasAutoOpenGamepass = true
				updateUI()
				
				if soundController then
					soundController:playUIClick()
				end
			elseif gamepassId == AUTO_SELL_GAMEPASS_ID then
				hasAutoSellGamepass = true
				updateUI()
				
				if soundController then
					soundController:playUIClick()
				end
			end
		end
	end)
	
	-- Auto-processing loop with better cancellation support
	autoOpenConnection = task.spawn(function()
		while true do
			task.wait(1) -- Check every second for more responsiveness
			
			-- Only process if enabled and not already processing
			if settings.enabled and hasAutoOpenGamepass and not isProcessing then
				processAutoOpen()
			end
		end
	end)
	
	-- Initial UI update
	updateUI()
	
	-- Request settings from server
	local function requestSettingsFromServer()
		if Remotes.GetAutoSettings then
			local success, data = pcall(function()
				return Remotes.GetAutoSettings:InvokeServer()
			end)
			if success and data then
				for k, v in pairs(data) do
					settings[k] = v
				end
			end
		end
	end
	
	requestSettingsFromServer()
end

function AutoOpenController.HandleNewItem(itemInstance, itemName)
	handleNewItem(itemInstance, itemName)
end

function AutoOpenController.GetSettings()
	return settings
end

function AutoOpenController.SetEnabled(enabled)
	if hasAutoOpenGamepass then
		settings.enabled = enabled
		updateUI()
		saveSettings()
	end
end

function AutoOpenController.InitializeSelectedCrate()
	-- Set the saved selected crate in CrateSelectionController (called after CrateSelectionController is started)
	if settings.selectedCrate and CrateSelectionController.SetSelectedCrateQuiet then
		-- Wait a bit to ensure CrateSelectionController is fully initialized
		task.wait(0.1)
		
		CrateSelectionController:SetSelectedCrateQuiet(settings.selectedCrate)
		print("[AutoOpenController] Initialized selected crate to: " .. settings.selectedCrate)
	end
end

return AutoOpenController 