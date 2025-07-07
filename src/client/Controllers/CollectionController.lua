-- CollectionController.lua
-- Manages the item collection index UI

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local NavigationController = require(script.Parent.NavigationController)

local Shared = ReplicatedStorage.Shared
local Remotes = require(Shared.Remotes.Remotes)
local GameConfig = require(Shared.Modules.GameConfig)
local CollectionUI = require(script.Parent.Parent.UI.CollectionUI)
local ItemValueCalculator = require(Shared.Modules.ItemValueCalculator)
local NumberFormatter = require(Shared.Modules.NumberFormatter)

local CollectionController = {}

-- State management
local isAnimating = false
local currentTab = nil -- Will be set dynamically to the cheapest crate
local hiddenUIs = {}
local collectionData = {}
local ANIMATION_TIME = 0.3

-- Initialize currentTab to the cheapest crate
local function initializeCurrentTab()
	if currentTab then return end -- Already initialized
	
	local cratesWithPrice = {}
	for crateName, crateConfig in pairs(GameConfig.Boxes) do
		-- Include all crates, treating FreeCrate as price 0
		local price = crateConfig.Price or 0
		table.insert(cratesWithPrice, {
			name = crateName,
			price = price
		})
	end
	
	-- Sort by price (cheapest first)
	table.sort(cratesWithPrice, function(a, b)
		return a.price < b.price
	end)
	
	-- Set to cheapest crate, or fallback to StarterCrate if none found
	if #cratesWithPrice > 0 then
		currentTab = cratesWithPrice[1].name
	else
		currentTab = "StarterCrate" -- Fallback
	end
end

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
				Divine = 8, Transcendent = 9, Ethereal = 10, Quantum = 11,
				Limited = 12, Vintage = 13, Exclusive = 14, Ultimate = 15, Dominus = 16
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

-- Calculate drop chance for an item across all crates
local function calculateDropChance(itemName)
	local totalChance = 0
	
	-- Check all crates for this item
	for crateName, crateConfig in pairs(GameConfig.Boxes) do
		if crateConfig.Rewards and crateConfig.Rewards[itemName] then
			totalChance = totalChance + crateConfig.Rewards[itemName]
		end
	end
	
	return totalChance
end

-- Format drop chance for display
local function formatDropChance(chance)
	return NumberFormatter.FormatPercentage(chance)
end

-- Setup 3D item preview for collection cards
local function setup3DItemPreview(viewport, itemConfig)
	if not viewport or not itemConfig or not itemConfig.AssetId then return end

	viewport:ClearAllChildren()

	local camera = Instance.new("Camera")
	camera.Parent = viewport
	viewport.CurrentCamera = camera

	local light = Instance.new("PointLight")
	light.Brightness = 2
	light.Color = Color3.new(1, 1, 1)
	light.Range = 40
	light.Parent = camera

	task.spawn(function()
		local assetPreviewContainer = ReplicatedStorage:WaitForChild("AssetPreviews")
		local asset = assetPreviewContainer:FindFirstChild(tostring(itemConfig.AssetId))

		if not asset then
			local success, err = pcall(function()
				return Remotes.LoadAssetForPreview:InvokeServer(itemConfig.AssetId)
			end)

			if not success then
				warn("Error invoking LoadAssetForPreview on server:", err)
				return
			end
			
			asset = assetPreviewContainer:WaitForChild(tostring(itemConfig.AssetId), 10)
		end

		local modelToDisplay
		local isLegacyClothing = false

		if asset then
			local assetClone = asset:Clone()
			if assetClone:IsA("Model") or assetClone:IsA("Accessory") then
				modelToDisplay = assetClone
			elseif assetClone:IsA("Shirt") or assetClone:IsA("Pants") or assetClone:IsA("TShirt") then
				isLegacyClothing = true
				-- Create a simple mannequin for clothing
				local mannequin = Instance.new("Model")
				local torso = Instance.new("Part")
				torso.Name = "Torso"
				torso.Size = Vector3.new(2, 1, 1)
				torso.Material = Enum.Material.SmoothPlastic
				torso.Color = Color3.fromRGB(255, 255, 255)
				torso.Anchored = true
				torso.Parent = mannequin
				mannequin.PrimaryPart = torso
				assetClone.Parent = mannequin
				modelToDisplay = mannequin
			end
		end

		if modelToDisplay then
			modelToDisplay.Parent = viewport
			
			local modelCFrame, modelSize = modelToDisplay:GetBoundingBox()
			local modelCenter = modelCFrame.Position
			
			local maxDimension = math.max(modelSize.X, modelSize.Y, modelSize.Z)
			local distance = maxDimension * 1.5 + (isLegacyClothing and 4 or 2)
			
			local angle = 0
			local connection
			connection = RunService.RenderStepped:Connect(function(dt)
				if not modelToDisplay.Parent then
					connection:Disconnect()
					return
				end
				
				angle = angle + dt * 45
				local rotation = CFrame.Angles(math.rad(10), math.rad(angle), 0)
				local cameraPosition = modelCenter + rotation:VectorToWorldSpace(Vector3.new(0, 0, distance))
				camera.CFrame = CFrame.lookAt(cameraPosition, modelCenter)
			end)
		else
			warn("Asset could not be displayed:", itemConfig.AssetId)
			local part = Instance.new("Part")
			part.Name = "PlaceholderPreview"
			part.Size = Vector3.new(2, 2, 2)
			part.Material = Enum.Material.ForceField
			part.Anchored = true
			part.Color = Color3.fromRGB(255, 0, 0)
			part.Parent = viewport
			camera.CFrame = CFrame.lookAt(Vector3.new(4, 2, 4), part.Position)
		end
	end)
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
		
		-- Add drop chance information
		local dropChance = calculateDropChance(itemName)
		if dropChance > 0 then
			table.insert(content, "Drop Rate: " .. formatDropChance(dropChance))
		end
	else
		table.insert(content, "❓ NOT DISCOVERED")
		table.insert(content, "")
		table.insert(content, "Find this item by opening crates!")
		table.insert(content, "Item details will be revealed once discovered.")
		table.insert(content, "")
		
		-- Show drop chance even for undiscovered items
		local dropChance = calculateDropChance(itemName)
		if dropChance > 0 then
			table.insert(content, "Drop Rate: " .. formatDropChance(dropChance))
		end
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
		
		-- Setup 3D preview for discovered items
		if itemData.Collection and itemData.Collection.Discovered then
			local preview = card:FindFirstChild("Preview")
			if preview and preview:IsA("ViewportFrame") then
				setup3DItemPreview(preview, itemData.Config)
			end
		end
		
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
	-- Ensure currentTab is initialized
	initializeCurrentTab()
	
	-- Clear existing tabs
	for _, child in ipairs(ui.TabsContainer:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end
	
	-- Dynamically get all crates from GameConfig and sort by price
	local cratesWithPrice = {}
	for crateName, crateConfig in pairs(GameConfig.Boxes) do
		-- Include all crates, treating FreeCrate as price 0
		local price = crateConfig.Price or 0
		table.insert(cratesWithPrice, {
			name = crateName,
			config = crateConfig,
			price = price
		})
	end
	
	-- Sort by price (cheapest first)
	table.sort(cratesWithPrice, function(a, b)
		return a.price < b.price
	end)
	
	-- Create tabs in sorted order
	for i, crateData in ipairs(cratesWithPrice) do
		local crateName = crateData.name
		local crateConfig = crateData.config
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
	
	-- If current tab is not valid (e.g., was FreeCrate or doesn't exist), set to first available crate
	if #cratesWithPrice > 0 then
		local validTab = false
		for _, crateData in ipairs(cratesWithPrice) do
			if crateData.name == currentTab then
				validTab = true
				break
			end
		end
		if not validTab then
			currentTab = cratesWithPrice[1].name
			createTabs(ui) -- Refresh to show correct active state
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
		
		-- Animate main frame from left
		ui.MainFrame.Position = UDim2.new(-1, 0, 0, 30)
		local mainTween = TweenService:Create(ui.MainFrame, tweenInfo, {Position = UDim2.new(0, 30, 0, 30)})
		mainTween:Play()

		task.delay(ANIMATION_TIME, function()
			isAnimating = false
		end)
	else
		-- Animate out to left and hide
		local mainTween = TweenService:Create(ui.MainFrame, tweenInfo, {Position = UDim2.new(-1, 0, 0, 30)})
		mainTween:Play()

		task.delay(ANIMATION_TIME, function()
			ui.MainFrame.Visible = false
			hideOtherUIs(false)
			hideTooltip(ui)
			isAnimating = false
		end)
	end
end

function CollectionController.Start(parentGui, soundController)
	local ui = CollectionUI.Create(parentGui)
	
	-- Register with NavigationController instead of connecting to toggle button
	NavigationController.RegisterController("Collection", function()
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
	initializeCurrentTab() -- Set currentTab to cheapest crate
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