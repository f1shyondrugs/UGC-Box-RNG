-- CollectionController.lua
-- Manages the item collection index UI

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local NavigationController = require(script.Parent.NavigationController)
local BoxAnimator = require(script.Parent.BoxAnimator)

local Shared = ReplicatedStorage.Shared
local Remotes = require(Shared.Remotes.Remotes)
local GameConfig = require(Shared.Modules.GameConfig)
local CollectionUI = require(script.Parent.Parent.UI.CollectionUI)
local ItemValueCalculator = require(Shared.Modules.ItemValueCalculator)
local NumberFormatter = require(Shared.Modules.NumberFormatter)
local ToastNotificationController = require(script.Parent.ToastNotificationController)

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
	


	-- Check if collection is unlocked and update UI accordingly
	local function updateCollectionUI()
		local success, unlockedFeatures = pcall(function()
			return Remotes.GetUnlockedFeatures:InvokeServer()
		end)
		
		if success and unlockedFeatures then
			local isUnlocked = false
			for _, feature in ipairs(unlockedFeatures) do
				if feature == "Collection" then
					isUnlocked = true
					break
				end
			end
			
			print("[CollectionController] Collection unlocked:", isUnlocked)
			
			-- If locked, black out the UI
			if not isUnlocked then
				-- Black out all UI elements
				local function blackOutElement(element)
					if element:IsA("GuiObject") then
						element.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
						if element:IsA("TextLabel") or element:IsA("TextButton") then
							element.TextColor3 = Color3.fromRGB(100, 100, 100)
						end
					end
					
					-- Recursively black out children
					for _, child in pairs(element:GetChildren()) do
						blackOutElement(child)
					end
				end
				
				-- Try multiple times to ensure UI is created
				local attempts = 0
				while attempts < 10 do
					if ui and ui.MainFrame then
						blackOutElement(ui.MainFrame)
						print("[CollectionController] UI blacked out on attempt", attempts + 1)
						break
					else
						attempts = attempts + 1
						task.wait(0.1)
					end
				end
				
				if attempts >= 10 then
					print("[CollectionController] Failed to black out UI after 10 attempts")
				end
			else
				-- Restore normal colors (this will be handled by the UI creation)
				-- The UI is already created with normal colors, so we don't need to do anything
				print("[CollectionController] UI restored to normal")
			end
		else
			print("[CollectionController] Failed to get unlocked features:", success)
		end
	end
		
	-- Update UI initially (with delay to ensure UI is created)
	task.wait(1)
	updateCollectionUI()
	
	

	
	-- Setup collection pad trigger instead of navigation button
	local function setupCollectionPadTrigger()
		local collectionFolder = workspace:FindFirstChild("Collection")
		if not collectionFolder then
			collectionFolder = Instance.new("Folder")
			collectionFolder.Name = "Collection"
			collectionFolder.Parent = workspace
		end
		
		-- Find or create the collection pad
		local collectionPad = collectionFolder:FindFirstChild("Pad")
		if not collectionPad then
			-- Create the collection pad if it doesn't exist
			collectionPad = Instance.new("Part")
			collectionPad.Name = "Pad"
			collectionPad.Size = Vector3.new(6, 1, 6)
			collectionPad.Position = Vector3.new(-25, 0.5, 0) -- Position it somewhere in the world
			collectionPad.Anchored = true
			collectionPad.Material = Enum.Material.Neon
			collectionPad.Color = Color3.fromRGB(100, 200, 255) -- Blue color for collection
			collectionPad.Shape = Enum.PartType.Block
			collectionPad.Parent = collectionFolder
			-- Add a glowing effect
			local pointLight = Instance.new("PointLight")
			pointLight.Color = Color3.fromRGB(100, 200, 255)
			pointLight.Brightness = 2
			pointLight.Range = 15
			pointLight.Parent = collectionPad
		end

		-- Setup ProximityPrompt in dedicated folder
		local proximityPromptsFolder = workspace:FindFirstChild("ProximityPrompts")
		if not proximityPromptsFolder then
			proximityPromptsFolder = Instance.new("Folder")
			proximityPromptsFolder.Name = "ProximityPrompts"
			proximityPromptsFolder.Parent = workspace
		end
		
		local collectionPromptPart = proximityPromptsFolder:FindFirstChild("CollectionMain")
		if not collectionPromptPart then
			-- Create the part first
			collectionPromptPart = Instance.new("Part")
			collectionPromptPart.Name = "CollectionMain"
			collectionPromptPart.Size = Vector3.new(1, 1, 1)
			collectionPromptPart.Position = Vector3.new(-25, 1, 0) -- Position near collection area
			collectionPromptPart.Anchored = true
			collectionPromptPart.Transparency = 1 -- Invisible part
			collectionPromptPart.CanCollide = false
			collectionPromptPart.Parent = proximityPromptsFolder
		end
		
		-- Create or find the ProximityPrompt inside the part
		local collectionPrompt = collectionPromptPart:FindFirstChild("ProximityPrompt")
		if not collectionPrompt then
			collectionPrompt = Instance.new("ProximityPrompt")
			collectionPrompt.Name = "ProximityPrompt"
			collectionPrompt.ActionText = "Open Collection"
			collectionPrompt.ObjectText = "Item Collection"
			collectionPrompt.KeyboardKeyCode = Enum.KeyCode.E
			collectionPrompt.RequiresLineOfSight = false
			collectionPrompt.MaxActivationDistance = 8
			collectionPrompt.Parent = collectionPromptPart
			
			-- Connect the trigger
			collectionPrompt.Triggered:Connect(function(player)
				if player == LocalPlayer then
					local success, unlockedFeatures = pcall(function()
						return Remotes.GetUnlockedFeatures:InvokeServer()
					end)
					if success and unlockedFeatures then
						local isUnlocked = false
						for _, feature in ipairs(unlockedFeatures) do
							if feature == "Collection" then
								isUnlocked = true
								break
							end
						end
						if isUnlocked then
							local isCurrentlyOpen = ui.MainFrame.Visible
							toggleCollection(ui, not isCurrentlyOpen, soundController)
						else
							if BoxAnimator then
								ToastNotificationController.ShowToast("Collection unlocks at Rebirth 2!", "Error")
							end
						end
					end
				end
			end)
			
			print("[CollectionController] Created CollectionMain ProximityPrompt in Workspace.ProximityPrompts")
		end
		
		-- Reference the prompt for visual updates
		local prompt = collectionPrompt

		-- Ensure pointLight exists
		local pointLight = collectionPad:FindFirstChild("PointLight")
		if not pointLight then
			pointLight = Instance.new("PointLight")
			pointLight.Color = Color3.fromRGB(100, 200, 255)
			pointLight.Brightness = 2
			pointLight.Range = 15
			pointLight.Parent = collectionPad
		end

		-- ProximityPrompt connection is already set up when creating the prompt

		print("[CollectionController] Collection pad ProximityPrompt setup at position:", collectionPad.Position)
		
		-- Check if collection is unlocked and update visual appearance
		local function updateCollectionVisual()
			local success, unlockedFeatures = pcall(function()
				return Remotes.GetUnlockedFeatures:InvokeServer()
			end)
			
			if success and unlockedFeatures then
				local isUnlocked = false
				for _, feature in ipairs(unlockedFeatures) do
					if feature == "Collection" then
						isUnlocked = true
						break
					end
				end
				
				-- Update the pad and prompt
				if isUnlocked then
					prompt.ActionText = "Open Collection"
					prompt.ObjectText = "Item Collection"
					collectionPad.Color = Color3.fromRGB(100, 200, 255) -- Normal blue
					pointLight.Color = Color3.fromRGB(100, 200, 255)
				else
					prompt.ActionText = "Unlocks On Rebirth 2"
					prompt.ObjectText = "Item Collection (Locked)"
					collectionPad.Color = Color3.fromRGB(50, 50, 50) -- Dark gray
					pointLight.Color = Color3.fromRGB(50, 50, 50)
				end
			
			-- Paint Collection Machine parts
			local collectionArea = workspace:FindFirstChild("Collection")
			if collectionArea then
				if isUnlocked then
					-- Restore from original build
					local success, err = pcall(function()
						local originalBuilds = ReplicatedStorage:FindFirstChild("OriginalBuilds")
						if originalBuilds then
							local originalCollection = originalBuilds:FindFirstChild("Collection")
							if originalCollection then
								-- Clear current collection area
								collectionArea:ClearAllChildren()
								
								-- Clone and restore original parts
								for _, originalPart in pairs(originalCollection:GetChildren()) do
									local restoredPart = originalPart:Clone()
									restoredPart.Parent = collectionArea
								end
								

								
								print("[CollectionController] Restored Collection area from original build")
							else
								-- Fallback: restore normal colors
								local function restorePart(part)
									if part:IsA("BasePart") then
										part.Color = Color3.fromRGB(100, 200, 255) -- Blue for collection
										part.Material = Enum.Material.Neon -- Use neon material
										if part:FindFirstChild("PointLight") then
											part.PointLight.Color = Color3.fromRGB(100, 200, 255)
										end
									end
									
									-- Recursively restore children
									for _, child in pairs(part:GetChildren()) do
										restorePart(child)
									end
								end
								
								-- Restore all parts in Collection area
								for _, part in pairs(collectionArea:GetChildren()) do
									restorePart(part)
								end
								

							end
						end
					end)
					
					if not success then
						warn("[CollectionController] Failed to restore Collection area:", err)
						-- Fallback to simple color restoration
						local function restorePart(part)
							if part:IsA("BasePart") then
								part.Color = Color3.fromRGB(100, 200, 255) -- Blue for collection
								part.Material = Enum.Material.Neon
								if part:FindFirstChild("PointLight") then
									part.PointLight.Color = Color3.fromRGB(100, 200, 255)
								end
							end
							
							-- Recursively restore children
							for _, child in pairs(part:GetChildren()) do
								restorePart(child)
							end
						end
						
						-- Restore all parts in Collection area
						for _, part in pairs(collectionArea:GetChildren()) do
							restorePart(part)
						end
						

					end
				else
					-- Paint neon when locked
					local function paintPart(part)
						if part:IsA("BasePart") then
							part.Color = Color3.fromRGB(20, 20, 20) -- Very dark gray
							part.Material = Enum.Material.Neon -- Use neon material
							if part:FindFirstChild("PointLight") then
								part.PointLight.Color = Color3.fromRGB(20, 20, 20)
							end
						end
						
						-- Recursively paint children
						for _, child in pairs(part:GetChildren()) do
							paintPart(child)
						end
					end
					
					-- Paint all parts in Collection area
					for _, part in pairs(collectionArea:GetChildren()) do
						paintPart(part)
					end
				end
				
				print("[CollectionController] Painted Collection area - Unlocked:", isUnlocked)
			end
		end
	end
		
	-- Update visual initially
	updateCollectionVisual()
	
	-- Update visual when rebirth data changes
	Remotes.RebirthUpdated.OnClientEvent:Connect(function()
		task.wait(0.5) -- Small delay to ensure data is updated
		updateCollectionVisual()
		updateCollectionUI()
	end)
	end
	
	-- Continuously monitor UI and black out if needed
	task.spawn(function()
		while task.wait(2) do
			local success, unlockedFeatures = pcall(function()
				return Remotes.GetUnlockedFeatures:InvokeServer()
			end)
			
			if success and unlockedFeatures then
				local isUnlocked = false
				for _, feature in ipairs(unlockedFeatures) do
					if feature == "Collection" then
						isUnlocked = true
						break
					end
				end
				
				-- Paint Collection Machine parts
				local collectionArea = workspace:FindFirstChild("Collection")
				if collectionArea then
					if isUnlocked then
						-- Restore from original build
						local success, err = pcall(function()
							local originalBuilds = ReplicatedStorage:FindFirstChild("OriginalBuilds")
							if originalBuilds then
								local originalCollection = originalBuilds:FindFirstChild("Collection")
								if originalCollection then
									-- Clear current collection area
									collectionArea:ClearAllChildren()
									
									-- Clone and restore original parts
									for _, originalPart in pairs(originalCollection:GetChildren()) do
										local restoredPart = originalPart:Clone()
										restoredPart.Parent = collectionArea
									end
									
									print("[CollectionController] Restored Collection area from original build")
								else
									-- Fallback: restore normal colors
									local function restorePart(part)
										if part:IsA("BasePart") then
											part.Color = Color3.fromRGB(100, 200, 255) -- Blue for collection
											part.Material = Enum.Material.Neon -- Use neon material
											if part:FindFirstChild("PointLight") then
												part.PointLight.Color = Color3.fromRGB(100, 200, 255)
											end
										end
										
										-- Recursively restore children
										for _, child in pairs(part:GetChildren()) do
											restorePart(child)
										end
									end
									
									-- Restore all parts in Collection area
									for _, part in pairs(collectionArea:GetChildren()) do
										restorePart(part)
									end
								end
							end
						end)
						
						if not success then
							warn("[CollectionController] Failed to restore Collection area:", err)
							-- Fallback to simple color restoration
							local function restorePart(part)
								if part:IsA("BasePart") then
									part.Color = Color3.fromRGB(100, 200, 255) -- Blue for collection
									part.Material = Enum.Material.Neon
									if part:FindFirstChild("PointLight") then
										part.PointLight.Color = Color3.fromRGB(100, 200, 255)
									end
								end
								
								-- Recursively restore children
								for _, child in pairs(part:GetChildren()) do
									restorePart(child)
								end
							end
							
							-- Restore all parts in Collection area
							for _, part in pairs(collectionArea:GetChildren()) do
								restorePart(part)
							end
						end
					else
						-- Paint neon when locked
						local function paintPart(part)
							if part:IsA("BasePart") then
								part.Color = Color3.fromRGB(20, 20, 20) -- Very dark gray
								part.Material = Enum.Material.Neon -- Use neon material
								if part:FindFirstChild("PointLight") then
									part.PointLight.Color = Color3.fromRGB(20, 20, 20)
								end
							end
							
							-- Recursively paint children
							for _, child in pairs(part:GetChildren()) do
								paintPart(child)
							end
						end
						
						-- Paint all parts in Collection area
						for _, part in pairs(collectionArea:GetChildren()) do
							paintPart(part)
						end
					end
				end
				
				-- Also black out UI if it exists
				if not isUnlocked and ui and ui.MainFrame then
					-- Black out all UI elements
					local function blackOutElement(element)
						if element:IsA("GuiObject") then
							element.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
							if element:IsA("TextLabel") or element:IsA("TextButton") then
								element.TextColor3 = Color3.fromRGB(100, 100, 100)
							end
						end
						
						-- Recursively black out children
						for _, child in pairs(element:GetChildren()) do
							blackOutElement(child)
						end
					end
					
					blackOutElement(ui.MainFrame)
				end
			end
		end
	end)
	
	-- Setup collection screen with 3D item display
	local function setupCollectionScreen()
		local collectionFolder = workspace:FindFirstChild("Collection") or workspace:WaitForChild("Collection")
		
		local collectionScreen = collectionFolder:FindFirstChild("Screen")
		if not collectionScreen then
			-- Create the collection screen if it doesn't exist
			collectionScreen = Instance.new("Part")
			collectionScreen.Name = "Screen"
			collectionScreen.Size = Vector3.new(1, 8, 12)
			collectionScreen.Position = Vector3.new(-25, 6, 8) -- Position it near the pad
			collectionScreen.Anchored = true
			collectionScreen.Material = Enum.Material.Neon
			collectionScreen.Color = Color3.fromRGB(20, 20, 30)
			collectionScreen.Shape = Enum.PartType.Block
			collectionScreen.Parent = collectionFolder
		end
		
		-- Create SurfaceGui on the screen
		local surfaceGui = collectionScreen:FindFirstChild("SurfaceGui")
		if not surfaceGui then
			surfaceGui = Instance.new("SurfaceGui")
			surfaceGui.Name = "SurfaceGui"
			surfaceGui.Face = Enum.NormalId.Front
			surfaceGui.CanvasSize = Vector2.new(800, 600)
			surfaceGui.LightInfluence = 0
			surfaceGui.Parent = collectionScreen
		end
		
		-- Create main ItemFrame container
		local itemFrame = surfaceGui:FindFirstChild("ItemFrame")
		if not itemFrame then
			itemFrame = Instance.new("Frame")
			itemFrame.Name = "ItemFrame"
			itemFrame.Size = UDim2.new(1, 0, 1, 0)
			itemFrame.Position = UDim2.new(0, 0, 0, 0)
			itemFrame.BackgroundColor3 = Color3.fromRGB(15, 18, 28)
			itemFrame.BorderSizePixel = 0
			itemFrame.Parent = surfaceGui
			
			-- Add title
			local titleLabel = Instance.new("TextLabel")
			titleLabel.Name = "TitleLabel"
			titleLabel.Size = UDim2.new(1, 0, 0, 60)
			titleLabel.Position = UDim2.new(0, 0, 0, 0)
			titleLabel.Text = "📚 ITEM COLLECTION"
			titleLabel.Font = Enum.Font.GothamBold
			titleLabel.TextSize = 32
			titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			titleLabel.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
			titleLabel.BorderSizePixel = 0
			titleLabel.Parent = itemFrame
			
			-- Add scrolling frame for items
			local scrollFrame = Instance.new("ScrollingFrame")
			scrollFrame.Name = "ItemScrollFrame"
			scrollFrame.Size = UDim2.new(1, 0, 1, -60)
			scrollFrame.Position = UDim2.new(0, 0, 0, 60)
			scrollFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
			scrollFrame.BackgroundTransparency = 0.3
			scrollFrame.BorderSizePixel = 0
			scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
			scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
			scrollFrame.ScrollBarThickness = 8
			scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
			scrollFrame.Parent = itemFrame
			
			-- Add grid layout for items
			local gridLayout = Instance.new("UIGridLayout")
			gridLayout.CellSize = UDim2.new(0, 120, 0, 120)
			gridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
			gridLayout.SortOrder = Enum.SortOrder.Name
			gridLayout.Parent = scrollFrame
			
			-- Add padding
			local padding = Instance.new("UIPadding")
			padding.PaddingLeft = UDim.new(0, 10)
			padding.PaddingRight = UDim.new(0, 10)
			padding.PaddingTop = UDim.new(0, 10)
			padding.PaddingBottom = UDim.new(0, 10)
			padding.Parent = scrollFrame
		end
		
		return itemFrame
	end
	
	-- Function to create blacked-out 3D item displays for the screen
	local function createBlackedOut3DItemDisplay(itemName, itemConfig, parent)
		local itemDisplay = Instance.new("Frame")
		itemDisplay.Name = itemName .. "Display"
		itemDisplay.Size = UDim2.new(0, 120, 0, 120)
		itemDisplay.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
		itemDisplay.BorderSizePixel = 0
		itemDisplay.Parent = parent
		
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 8)
		corner.Parent = itemDisplay
		
		-- Create ViewportFrame for 3D model
		local viewport = Instance.new("ViewportFrame")
		viewport.Name = "ItemViewport"
		viewport.Size = UDim2.new(1, -10, 1, -30)
		viewport.Position = UDim2.new(0, 5, 0, 5)
		viewport.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
		viewport.BorderSizePixel = 0
		viewport.Parent = itemDisplay
		
		local viewportCorner = Instance.new("UICorner")
		viewportCorner.CornerRadius = UDim.new(0, 6)
		viewportCorner.Parent = viewport
		
		-- Add item name label
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Name = "ItemNameLabel"
		nameLabel.Size = UDim2.new(1, 0, 0, 20)
		nameLabel.Position = UDim2.new(0, 0, 1, -20)
		nameLabel.Text = itemName
		nameLabel.Font = Enum.Font.SourceSans
		nameLabel.TextSize = 12
		nameLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
		nameLabel.BackgroundTransparency = 1
		nameLabel.TextScaled = true
		nameLabel.Parent = itemDisplay
		
		-- Setup blacked-out 3D preview
		setup3DBlackedOutPreview(viewport, itemConfig)
		
		return itemDisplay
	end
	
	-- Function to setup blacked-out 3D preview (silhouette style)
	local function setup3DBlackedOutPreview(viewport, itemConfig)
		if not viewport or not itemConfig or not itemConfig.AssetId then return end

		viewport:ClearAllChildren()

		local camera = Instance.new("Camera")
		camera.Parent = viewport
		viewport.CurrentCamera = camera

		local light = Instance.new("PointLight")
		light.Brightness = 1
		light.Color = Color3.new(0.3, 0.3, 0.3) -- Dim lighting for silhouette effect
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
					torso.Color = Color3.fromRGB(20, 20, 20) -- Dark silhouette
					torso.Anchored = true
					torso.Parent = mannequin
					mannequin.PrimaryPart = torso
					assetClone.Parent = mannequin
					modelToDisplay = mannequin
				end
			end

			if modelToDisplay then
				-- Make all parts dark/black for silhouette effect
				for _, part in pairs(modelToDisplay:GetDescendants()) do
					if part:IsA("BasePart") then
						part.Color = Color3.fromRGB(20, 20, 20) -- Dark silhouette color
						part.Material = Enum.Material.SmoothPlastic
						-- Remove any textures/decals for clean silhouette
						for _, child in pairs(part:GetChildren()) do
							if child:IsA("Decal") or child:IsA("Texture") then
								child:Destroy()
							end
						end
					end
				end
				
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
					
					angle = angle + dt * 30 -- Slower rotation for screen display
					local rotation = CFrame.Angles(math.rad(10), math.rad(angle), 0)
					local cameraPosition = modelCenter + rotation:VectorToWorldSpace(Vector3.new(0, 0, distance))
					camera.CFrame = CFrame.lookAt(cameraPosition, modelCenter)
				end)
			else
				warn("Asset could not be displayed:", itemConfig.AssetId)
				-- Create a placeholder silhouette
				local part = Instance.new("Part")
				part.Name = "PlaceholderPreview"
				part.Size = Vector3.new(2, 2, 2)
				part.Material = Enum.Material.SmoothPlastic
				part.Anchored = true
				part.Color = Color3.fromRGB(20, 20, 20)
				part.Parent = viewport
				camera.CFrame = CFrame.lookAt(Vector3.new(4, 2, 4), part.Position)
			end
		end)
	end
	
	-- Function to update the collection screen with current items
	local function updateCollectionScreen()
		local itemFrame = setupCollectionScreen()
		local scrollFrame = itemFrame:FindFirstChild("ItemScrollFrame")
		if not scrollFrame then return end
		
		-- Clear existing items
		for _, child in ipairs(scrollFrame:GetChildren()) do
			if child:IsA("Frame") and child.Name:find("Display") then
				child:Destroy()
			end
		end
		
		-- Add items from all crates
		for itemName, itemConfig in pairs(GameConfig.Items) do
			createBlackedOut3DItemDisplay(itemName, itemConfig, scrollFrame)
		end
	end
	
	-- Setup the pad trigger and collection screen
	setupCollectionPadTrigger()
	updateCollectionScreen()
	
	ui.CloseButton.MouseButton1Click:Connect(function()
		if isAnimating then return end
		soundController:playUIClick()
		toggleCollection(ui, false, soundController)
	end)

	-- Keyboard shortcuts
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == Enum.KeyCode.Escape and ui.MainFrame.Visible then
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