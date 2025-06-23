-- CollectionController.lua
-- Manages the item collection index UI

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

local Shared = ReplicatedStorage.Shared
local Remotes = require(Shared.Remotes.Remotes)
local GameConfig = require(Shared.Modules.GameConfig)
local CollectionUI = require(script.Parent.Parent.UI.CollectionUI)
local ItemValueCalculator = require(Shared.Modules.ItemValueCalculator)

local CollectionController = {}

-- State management
local isAnimating = false
local currentTab = "StarterCrate"
local hiddenUIs = {}
local collectionData = {}
local ANIMATION_TIME = 0.3

local function hideOtherUIs(show)
	local playerGui = LocalPlayer:WaitForChild("PlayerGui")
	
	if show then
		-- Hide other UIs
		for _, gui in pairs(playerGui:GetChildren()) do
			if gui:IsA("ScreenGui") and gui.Name ~= "CollectionGui" then
				if gui.Enabled then
					hiddenUIs[gui] = true
					gui.Enabled = false
				end
			end
		end
		
		-- Also hide CoreGui elements
		local StarterGui = game:GetService("StarterGui")
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
		local StarterGui = game:GetService("StarterGui")
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
	end
end

-- Organize items by crate
local function getItemsByCrate()
	local itemsByCrate = {}
	
	-- Go through all crates and their rewards
	for crateName, crateConfig in pairs(GameConfig.Boxes) do
		itemsByCrate[crateName] = {}
		for itemName, _ in pairs(crateConfig.Rewards or {}) do
			local itemConfig = GameConfig.Items[itemName]
			if itemConfig then
				table.insert(itemsByCrate[crateName], {
					Name = itemName,
					Config = itemConfig,
					Collection = collectionData[itemName]
				})
			end
		end
		
		-- Sort by rarity (reverse order: highest rarity first)
		table.sort(itemsByCrate[crateName], function(a, b)
			local rarityOrder = {
				Common = 1, Uncommon = 2, Rare = 3, Epic = 4, 
				Legendary = 5, Mythical = 6, Celestial = 7, 
				Divine = 8, Transcendent = 9, Ethereal = 10, Quantum = 11
			}
			local aRarity = rarityOrder[a.Config.Rarity] or 0
			local bRarity = rarityOrder[b.Config.Rarity] or 0
			return aRarity > bRarity
		end)
	end
	
	return itemsByCrate
end

-- Update progress info
local function updateProgressInfo(ui)
	local totalItems = 0
	local discoveredItems = 0
	
	for _, itemConfig in pairs(GameConfig.Items) do
		totalItems = totalItems + 1
	end
	
	for _, collection in pairs(collectionData) do
		if collection.Discovered then
			discoveredItems = discoveredItems + 1
		end
	end
	
	local percentage = totalItems > 0 and math.floor((discoveredItems / totalItems) * 100) or 0
	ui.ProgressInfo.Text = string.format("Discovered: %d/%d items (%d%%)", discoveredItems, totalItems, percentage)
end

-- Create tooltip content
local function createTooltipContent(itemName, itemConfig, collectionData)
	local content = {}
	
	if collectionData and collectionData.Discovered then
		table.insert(content, "🎯 DISCOVERED")
		table.insert(content, "")
		table.insert(content, string.format("Rarity: %s", itemConfig.Rarity))
		table.insert(content, string.format("Type: %s", itemConfig.Type or "UGC Item"))
		table.insert(content, string.format("Max Size Found: %.2f", collectionData.MaxSize))
		table.insert(content, "")
		
		-- List discovered mutations with better organization
		local mutationList = {}
		if collectionData.Mutations then
			for mutationName, isFound in pairs(collectionData.Mutations) do
				if isFound then
					if mutationName == "None" then
						table.insert(mutationList, "Normal")
					else
						table.insert(mutationList, mutationName)
					end
				end
			end
		end
		
		-- Sort mutations for consistent display (put Normal first, then alphabetical)
		table.sort(mutationList, function(a, b)
			if a == "Normal" then return true end
			if b == "Normal" then return false end
			return a < b
		end)
		
		if #mutationList > 0 then
			table.insert(content, string.format("Variants Found (%d):", #mutationList))
			for _, mutation in ipairs(mutationList) do
				-- Add some visual flair to different mutation types
				local icon = "•"
				if mutation == "Normal" then
					icon = "◦"
				elseif mutation == "Shiny" then
					icon = "✨"
				elseif mutation == "Glowing" then
					icon = "💡"
				elseif mutation == "Rainbow" then
					icon = "🌈"
				elseif mutation == "Corrupted" then
					icon = "🔮"
				elseif mutation == "Stellar" then
					icon = "⭐"
				elseif mutation == "Quantum" then
					icon = "🌀"
				elseif mutation == "Unknown" then
					icon = "❓"
				end
				local mutationLine = icon .. " " .. mutation
				table.insert(content, mutationLine)
			end
		else
			table.insert(content, "No variants found yet")
		end
		
		-- Add value information with mutations
		table.insert(content, "")
		local baseValue = ItemValueCalculator.GetFormattedValue(itemConfig, nil, 1)
		table.insert(content, "Base Value: " .. baseValue)
	else
		table.insert(content, "❓ NOT DISCOVERED")
		table.insert(content, "")
		table.insert(content, "Find this item by opening crates!")
		table.insert(content, "Item details will be revealed once discovered.")
	end
	
	return table.concat(content, "\n")
end

-- Show tooltip
local function showTooltip(ui, card, itemName, itemConfig, itemCollection)
	local tooltip = ui.Tooltip
	local mouse = LocalPlayer:GetMouse()
	
	tooltip.Visible = true
	tooltip.Position = UDim2.new(0, mouse.X + 10, 0, mouse.Y - 75)
	
	ui.TooltipTitle.Text = itemCollection and itemCollection.Discovered and itemName or "???"
	ui.TooltipContent.Text = createTooltipContent(itemName, itemConfig, itemCollection)
end

-- Hide tooltip
local function hideTooltip(ui)
	ui.Tooltip.Visible = false
end

-- Display items for current tab
local function displayItems(ui, crateName)
	-- Clear existing items
	for _, child in ipairs(ui.ItemsContainer:GetChildren()) do
		if child.Name:find("Card") then
			child:Destroy()
		end
	end
	
	local itemsByCrate = getItemsByCrate()
	local crateItems = itemsByCrate[crateName] or {}
	
	for _, itemData in ipairs(crateItems) do
		local card = CollectionUI.CreateItemCard(itemData.Name, itemData.Config, itemData.Collection)
		card.Parent = ui.ItemsContainer
		
		-- Add hover functionality
		card.MouseEnter:Connect(function()
			showTooltip(ui, card, itemData.Name, itemData.Config, itemData.Collection)
		end)
		
		card.MouseLeave:Connect(function()
			hideTooltip(ui)
		end)
		
		card.MouseMoved:Connect(function()
			if ui.Tooltip.Visible then
				local mouse = LocalPlayer:GetMouse()
				ui.Tooltip.Position = UDim2.new(0, mouse.X + 10, 0, mouse.Y - 75)
			end
		end)
	end
end

-- Create crate tabs
local function createTabs(ui)
	-- Clear existing tabs
	for _, child in ipairs(ui.TabsContainer:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end
	
	local crateOrder = {
		"StarterCrate", "PremiumCrate", "LegendaryCrate", "MythicalCrate",
		"CelestialCrate", "DivineCrate", "TranscendentCrate", "EtherealCrate", "QuantumCrate"
	}
	
	for i, crateName in ipairs(crateOrder) do
		local crateConfig = GameConfig.Boxes[crateName]
		if crateConfig then
			local isActive = (crateName == currentTab)
			local tab = CollectionUI.CreateCrateTab(crateConfig.Name, isActive)
			tab.LayoutOrder = i
			tab.Parent = ui.TabsContainer
			
			tab.MouseButton1Click:Connect(function()
				if currentTab ~= crateName then
					currentTab = crateName
					createTabs(ui) -- Refresh tabs to show active state
					displayItems(ui, crateName)
				end
			end)
		end
	end
end

-- Toggle collection UI
local function toggleCollection(ui, visible, soundController)
	if isAnimating then return end
	isAnimating = true

	local tweenInfo = TweenInfo.new(ANIMATION_TIME, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

	if visible then
		-- Show and animate in
		hideOtherUIs(true)
		ui.ToggleButton.Visible = false
		ui.MainFrame.Visible = true
		
		-- Load latest collection data
		task.spawn(function()
			local success, data = pcall(function()
				return Remotes.GetPlayerCollection:InvokeServer()
			end)
			
			if success and data then
				collectionData = data
				updateProgressInfo(ui)
				displayItems(ui, currentTab)
			end
		end)
		
		-- Animate main frame
		ui.MainFrame.Position = UDim2.new(0, 0, -1, 0)
		local mainTween = TweenService:Create(ui.MainFrame, tweenInfo, {Position = UDim2.new(0, 0, 0, 0)})
		mainTween:Play()

		task.delay(ANIMATION_TIME, function()
			isAnimating = false
		end)
	else
		-- Animate out and hide
		local mainTween = TweenService:Create(ui.MainFrame, tweenInfo, {Position = UDim2.new(0, 0, -1, 0)})
		mainTween:Play()

		task.delay(ANIMATION_TIME, function()
			ui.MainFrame.Visible = false
			hideOtherUIs(false)
			ui.ToggleButton.Visible = true
			hideTooltip(ui)
			isAnimating = false
		end)
	end
end

function CollectionController.Start(parentGui, soundController)
	local ui = CollectionUI.Create(parentGui)
	
	-- Connect buttons
	ui.ToggleButton.MouseButton1Click:Connect(function()
		soundController:playUIClick()
		toggleCollection(ui, not ui.MainFrame.Visible, soundController)
	end)
	
	ui.CloseButton.MouseButton1Click:Connect(function()
		if isAnimating then return end
		soundController:playUIClick()
		toggleCollection(ui, false, soundController)
	end)

	-- Keyboard shortcuts
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == Enum.KeyCode.C then
			toggleCollection(ui, not ui.MainFrame.Visible, soundController)
		elseif input.KeyCode == Enum.KeyCode.Escape and ui.MainFrame.Visible then
			toggleCollection(ui, false, soundController)
		end
	end)
	
	-- Initialize UI
	createTabs(ui)
	updateProgressInfo(ui)
	displayItems(ui, currentTab)
	
	-- Load initial collection data
	task.spawn(function()
		local success, data = pcall(function()
			return Remotes.GetPlayerCollection:InvokeServer()
		end)
		
		if success and data then
			collectionData = data
			updateProgressInfo(ui)
			displayItems(ui, currentTab)
		end
	end)
end

return CollectionController 