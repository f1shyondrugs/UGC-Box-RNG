local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local NavigationController = require(script.Parent.NavigationController)

local Shared = ReplicatedStorage.Shared
local Remotes = require(Shared.Remotes.Remotes)
local GameConfig = require(Shared.Modules.GameConfig)
local InventoryUI = require(script.Parent.Parent.UI.InventoryUI)
local ItemValueCalculator = require(Shared.Modules.ItemValueCalculator)
local NumberFormatter = require(Shared.Modules.NumberFormatter)

local InventoryController = {}
local DEFAULT_INVENTORY_LIMIT = 50

-- Camera and UI state management
local originalCamera = nil
local inventoryCamera = nil
local cameraConnection = nil
local hiddenUIs = {}
local selectedItem = nil
local selectedItemTemplate = nil
local currentRainbowThread = nil -- Track current rainbow animation
local isAnimating = false
local ANIMATION_TIME = 0.3
local ANIMATION_STYLE = Enum.EasingStyle.Quint
local ANIMATION_DIRECTION = Enum.EasingDirection.Out

local function setupCharacterViewport(ui)
	local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	if not character then return end
	
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
	if not humanoidRootPart then
		warn("Could not find HumanoidRootPart for character viewport.")
		return
	end

	-- Clear existing character from viewport
	if ui and ui.CharacterViewport then
		ui.CharacterViewport:ClearAllChildren()
	else
		return -- Can't continue if UI isn't ready
	end

	-- Clone the character for the viewport
	local success, characterClone = pcall(function()
		return character:Clone()
	end)

	if not success or not characterClone then
		warn("Failed to clone character for viewport. It may have been destroyed.")
		return
	end
	
	-- Remove scripts and other unnecessary parts
	for _, child in pairs(characterClone:GetDescendants()) do
		if child:IsA("Script") or child:IsA("LocalScript") or child:IsA("ModuleScript") then
			child:Destroy()
		elseif child:IsA("Sound") then
			child:Destroy()
		end
	end

	-- Add the character to the viewport
	characterClone.Parent = ui.CharacterViewport

	-- Create camera for character viewport
	local camera = Instance.new("Camera")
	camera.Parent = ui.CharacterViewport
	ui.CharacterViewport.CurrentCamera = camera

	-- Position camera to face character from front
	local characterPosition = humanoidRootPart.Position
	local characterSize = characterClone:GetExtentsSize()
	
	-- Position camera in front and above character
	local cameraDistance = math.max(characterSize.X, characterSize.Y, characterSize.Z) * 1.2
	camera.CFrame = CFrame.lookAt(
		characterPosition + Vector3.new(0, characterSize.Y * 0.1, cameraDistance),
		characterPosition + Vector3.new(0, characterSize.Y * 0.3, 0)
	)

	-- Add subtle camera rotation animation
	local rotationTween = TweenService:Create(
		camera,
		TweenInfo.new(8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{CFrame = camera.CFrame * CFrame.Angles(0, math.rad(10), 0)}
	)
	rotationTween:Play()
end

function InventoryController.Start(parentGui, openingBoxes, soundController)
	local inventory = LocalPlayer:WaitForChild("Inventory")
	local leaderstats = LocalPlayer:WaitForChild("leaderstats")
	
	local ui = InventoryUI.Create(parentGui)
	
	local itemEntries = {} -- itemInstance -> { Template, LockIcon, Connection }
	local searchText = ""
	local sortBy = "Value" -- Default sort type
	local sortOrder = "desc" -- "asc" or "desc"
	local sortOptions = {"Value", "Name", "Size", "Rarity"}
	
	-- Performance caches
	local equippedItemsCache = nil
	local equippedItemsCacheTime = 0
	local EQUIPPED_CACHE_DURATION = 2 -- Cache for 2 seconds
	local loadingBatch = false
	local pendingItems = {}
	
	-- Batch loading configuration
	local ITEM_BATCH_SIZE = 10
	local BATCH_DELAY = 0.05

	-- Function to get current inventory limit dynamically
	local function getCurrentInventoryLimit()
		local success, upgradeData = pcall(function()
			return Remotes.GetUpgradeData:InvokeServer()
		end)
		
		if success and upgradeData and upgradeData.InventorySlots then
			local inventoryUpgrade = upgradeData.InventorySlots
			if inventoryUpgrade.effects and inventoryUpgrade.effects.CurrentSlots then
				return inventoryUpgrade.effects.CurrentSlots
			end
		end
		
		return DEFAULT_INVENTORY_LIMIT -- Fallback to default
	end
	
	-- Cached equipped items getter
	local function getCachedEquippedItems()
		local currentTime = tick()
		if equippedItemsCache and currentTime - equippedItemsCacheTime < EQUIPPED_CACHE_DURATION then
			return equippedItemsCache
		end
		
		local success, equippedItems = pcall(function()
			return Remotes.GetEquippedItems:InvokeServer()
		end)
		
		if success then
			equippedItemsCache = equippedItems
			equippedItemsCacheTime = currentTime
			return equippedItems
		end
		
		return equippedItemsCache or {}
	end
	
	-- Lazy 3D preview setup - only when needed
	local function setup3DPreviewLazy(viewport, itemConfig)
		if not viewport or not itemConfig then
			return
		end
		
		-- Check if already loaded
		if viewport:GetAttribute("PreviewLoaded") then
			return
		end
		
		-- Mark as loading to prevent duplicate calls
		viewport:SetAttribute("PreviewLoaded", true)
		
		task.spawn(function()
			-- Quick check if viewport still exists
			if not viewport.Parent then 
				viewport:SetAttribute("PreviewLoaded", false)
				return 
			end
			
			local success = pcall(function()
				setup3DItemPreview(viewport, itemConfig)
			end)
			
			if not success then
				-- Reset flag on failure so it can be retried
				viewport:SetAttribute("PreviewLoaded", false)
			end
		end)
	end

	local function matchesSearch(itemInstance, searchQuery)
		if not searchQuery or searchQuery == "" then
			return true
		end
		
		searchQuery = string.lower(searchQuery)
		
		-- Get item name
		local itemName = itemInstance:GetAttribute("ItemName") or itemInstance.Name
		if string.find(string.lower(itemName), searchQuery) then
			return true
		end
		
		-- Use cached data for better performance
		local entry = itemEntries[itemInstance]
		if entry then
			local itemConfig = entry.ItemConfig
			if itemConfig then
				-- Check rarity
				if itemConfig.Rarity and string.find(string.lower(itemConfig.Rarity), searchQuery) then
					return true
				end
				
				-- Check type
				if itemConfig.Type and string.find(string.lower(itemConfig.Type), searchQuery) then
					return true
				end
			end
			
			-- Check cached mutations
			local mutationNames = entry.MutationNames
			if mutationNames then
				for _, mutationName in ipairs(mutationNames) do
					if string.find(string.lower(mutationName), searchQuery) then
						return true
					end
				end
			end
		end
		
		-- Check size (convert to string for search)
		local size = itemInstance:GetAttribute("Size")
		if size and string.find(tostring(size), searchQuery) then
			return true
		end
		
		return false
	end

	-- Rarity order mapping for sorting
	local rarityOrder = {
		Common = 1,
		Uncommon = 2,
		Rare = 3,
		Epic = 4,
		Legendary = 5,
		Mythical = 6,
		Godly = 7,
		Celestial = 8,
		Divine = 9,
		Transcendent = 10,
		Ethereal = 11,
		Quantum = 12,
		Limited = 13,
		Vintage = 14,
		Exclusive = 15,
		Ultimate = 16,
		Dominus = 17
	}

	local function getSortValue(itemInstance, sortType)
		-- Use cached data from itemEntries for better performance
		local entry = itemEntries[itemInstance]
		if not entry then return 0 end
		
		local itemName = itemInstance:GetAttribute("ItemName") or itemInstance.Name
		local itemConfig = entry.ItemConfig -- Use cached config
		
		if sortType == "Value" then
			if not itemConfig then return 0 end
			local mutationConfigs = entry.MutationConfigs -- Use cached mutations
			local size = itemInstance:GetAttribute("Size") or 1
			local success, value = pcall(function()
				return ItemValueCalculator.GetValue(itemConfig, mutationConfigs, size)
			end)
			return success and value or 0
		elseif sortType == "Name" then
			return itemName or ""
		elseif sortType == "Size" then
			return itemInstance:GetAttribute("Size") or 1
		elseif sortType == "Rarity" then
			if itemConfig and itemConfig.Rarity then
				return rarityOrder[itemConfig.Rarity] or 0
			end
			return 0
		end
		
		return 0
	end

	local function sortInventory()
		-- Get all items with their sort values
		local allItems = {}
		for itemInstance, entry in pairs(itemEntries) do
			if entry.Template then
				table.insert(allItems, {
					instance = itemInstance,
					template = entry.Template,
					sortValue = getSortValue(itemInstance, sortBy),
					isVisible = entry.Template.Visible
				})
			end
		end
		

		
		-- Sort all items
		table.sort(allItems, function(a, b)
			if sortBy == "Name" then
				-- String comparison
				if sortOrder == "desc" then
					return tostring(a.sortValue) > tostring(b.sortValue)
				else
					return tostring(a.sortValue) < tostring(b.sortValue)
				end
			else
				-- Numeric comparison
				if sortOrder == "desc" then
					return tonumber(a.sortValue) > tonumber(b.sortValue)
				else
					return tonumber(a.sortValue) < tonumber(b.sortValue)
				end
			end
		end)
		
		-- Update layout order for all items (visible items will be grouped at top)
		local visibleOrder = 1
		local hiddenOrder = 1000
		local visibleCount = 0
		
		for _, item in ipairs(allItems) do
			if item.isVisible then
				item.template.LayoutOrder = visibleOrder
				visibleOrder = visibleOrder + 1
				visibleCount = visibleCount + 1
			else
				item.template.LayoutOrder = hiddenOrder
				hiddenOrder = hiddenOrder + 1
			end
		end
		

	end

	local function filterInventory()
		-- First apply search filter
		for itemInstance, entry in pairs(itemEntries) do
			if entry.Template then
				local visible = matchesSearch(itemInstance, searchText)
				entry.Template.Visible = visible
			end
		end
		
		-- Then sort visible items
		sortInventory()
	end

	local function onSearchChanged()
		searchText = ui.SearchBox.Text
		ui.ClearButton.Visible = searchText ~= ""
		filterInventory()
	end

	-- Update sort UI text
	local function updateSortUI()
		ui.SortByButton.Text = "Sort: " .. sortBy .. " ▼"
		if sortOrder == "desc" then
			if sortBy == "Name" then
				ui.SortOrderButton.Text = "Z to A ↓"
			else
				ui.SortOrderButton.Text = "High to Low ↓"
			end
		else
			if sortBy == "Name" then
				ui.SortOrderButton.Text = "A to Z ↑"
			else
				ui.SortOrderButton.Text = "Low to High ↑"
			end
		end
	end

	-- Sort by button cycling
	local function cycleSortBy()
		local currentIndex = 1
		for i, option in ipairs(sortOptions) do
			if option == sortBy then
				currentIndex = i
				break
			end
		end
		
		currentIndex = currentIndex + 1
		if currentIndex > #sortOptions then
			currentIndex = 1
		end
		
		sortBy = sortOptions[currentIndex]
		updateSortUI()
		filterInventory()
	end

	-- Sort order toggle
	local function toggleSortOrder()
		sortOrder = sortOrder == "desc" and "asc" or "desc"
		updateSortUI()
		filterInventory()
	end

	-- Connect search functionality
	ui.SearchBox:GetPropertyChangedSignal("Text"):Connect(onSearchChanged)
	ui.ClearButton.MouseButton1Click:Connect(function()
		ui.SearchBox.Text = ""
		ui.SearchBox:CaptureFocus()
	end)
	
	-- Connect sort functionality
	ui.SortByButton.MouseButton1Click:Connect(function()
		soundController:playUIClick()
		cycleSortBy()
	end)
	
	ui.SortOrderButton.MouseButton1Click:Connect(function()
		soundController:playUIClick()
		toggleSortOrder()
	end)
	
	-- Initialize sort UI
	updateSortUI()

	

	local function createMannequin()
		local mannequin = Instance.new("Model")
		mannequin.Name = "ClothingMannequin"

		local torso = Instance.new("Part")
		torso.Name = "Torso"
		torso.Size = Vector3.new(2, 2, 1)
		torso.Color = Color3.fromRGB(180, 180, 180)
		torso.Anchored = true
		torso.CFrame = CFrame.new(0, 2, 0)
		torso.Parent = mannequin
		mannequin.PrimaryPart = torso

		local head = Instance.new("Part")
		head.Name = "Head"
		head.Shape = Enum.PartType.Ball
		head.Size = Vector3.new(1.2, 1.2, 1.2)
		head.Color = Color3.fromRGB(200, 200, 200)
		head.Anchored = true
		head.CFrame = torso.CFrame * CFrame.new(0, 1.6, 0)
		head.Parent = mannequin

		local leftLeg = Instance.new("Part")
		leftLeg.Name = "LeftLeg"
		leftLeg.Size = Vector3.new(0.9, 2, 0.9)
		leftLeg.Color = Color3.fromRGB(180, 180, 180)
		leftLeg.Anchored = true
		leftLeg.CFrame = torso.CFrame * CFrame.new(-0.5, -2, 0)
		leftLeg.Parent = mannequin

		local rightLeg = Instance.new("Part")
		rightLeg.Name = "RightLeg"
		rightLeg.Size = Vector3.new(0.9, 2, 0.9)
		rightLeg.Color = Color3.fromRGB(180, 180, 180)
		rightLeg.Anchored = true
		rightLeg.CFrame = torso.CFrame * CFrame.new(0.5, -2, 0)
		rightLeg.Parent = mannequin
		
		return mannequin
	end

	local function setup3DItemPreview(viewport, itemConfig)
		if not itemConfig or not itemConfig.AssetId then return end

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
					Remotes.LoadAssetForPreview:InvokeServer(itemConfig.AssetId)
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
					modelToDisplay = createMannequin()
					assetClone.Parent = modelToDisplay
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

	local function hideOtherUIs(show)
		local playerGui = LocalPlayer:WaitForChild("PlayerGui")
		
		if show then
			-- Hide other UIs
			for _, gui in pairs(playerGui:GetChildren()) do
				if gui:IsA("ScreenGui") and gui ~= ui.ScreenGui then
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

	local function updateRAP()
		local totalRAP = LocalPlayer:GetAttribute("RAPValue") or 0
		local formattedRAP = ItemValueCalculator.GetFormattedRAP(totalRAP)
		ui.RAPLabel.Text = "Total RAP: " .. formattedRAP
	end

	local function updateBoxPrompts(isFull)
		local boxesFolder = workspace:FindFirstChild("Boxes")
		if not boxesFolder then return end

		for _, boxPart in ipairs(boxesFolder:GetChildren()) do
			if boxPart:IsA("BasePart") and boxPart:GetAttribute("Owner") == LocalPlayer.UserId then
				local prompt = boxPart:FindFirstChildOfClass("ProximityPrompt")
				if prompt then
					-- Check if box is already being opened or if inventory is full
					if isFull or openingBoxes[boxPart] or boxPart:GetAttribute("IsOpening") then
						prompt.Enabled = false
					else
						prompt.Enabled = true
					end
				end
			end
		end
	end

	local function updateInventoryCount()
		local count = #inventory:GetChildren()
		local currentLimit = getCurrentInventoryLimit()
		ui.InventoryTitle.Text = "INVENTORY (" .. NumberFormatter.FormatCount(count) .. " / " .. NumberFormatter.FormatCount(currentLimit) .. ")"
	
		local isFull = count >= currentLimit
		-- Show inventory full notification on navigation button
		NavigationController.SetNotification("Inventory", isFull)
		updateBoxPrompts(isFull)
	end

	local function resetDetailsPanel()
		-- Clean up any existing rainbow animation
		if currentRainbowThread then
			coroutine.close(currentRainbowThread)
			currentRainbowThread = nil
		end
		
		selectedItem = nil
		if selectedItemTemplate then
			local highlight = selectedItemTemplate:FindFirstChild("SelectionHighlight")
			if highlight then
				highlight.Visible = false
			end
		end
		selectedItemTemplate = nil
		
		ui.DetailTitle.Text = "Select an item to view details"
		ui.DetailTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
		ui.DetailItemType.Text = ""
		ui.DetailItemDescription.Text = ""
		ui.DetailItemRarity.Text = ""
		ui.DetailItemMutation.Text = ""
		ui.DetailItemSize.Text = ""
		ui.DetailItemValue.Text = ""
		
		ui.SellButton.Visible = false
		ui.LockButton.Visible = false
		ui.EquipButton.Visible = false
		ui.UnequipButton.Visible = false
		
		-- Clear the 3D preview
		for _, child in ipairs(ui.ItemViewport:GetChildren()) do
			if child:IsA("Model") or child:IsA("Camera") then
				child:Destroy()
			end
		end
	end

	local function updateDetails(itemInstance, itemTemplate)
		-- Clean up any existing rainbow animation
		if currentRainbowThread then
			coroutine.close(currentRainbowThread)
			currentRainbowThread = nil
		end
		
		selectedItem = itemInstance
		selectedItemTemplate = itemTemplate
		
		-- Show selection highlight
		local highlight = itemTemplate:FindFirstChild("SelectionHighlight")
		if highlight then
			highlight.Visible = true
		end
		
		-- Use cached data for better performance
		local entry = itemEntries[itemInstance]
		if not entry then return end
		
		local itemName = itemInstance:GetAttribute("ItemName") or itemInstance.Name
		local itemConfig = entry.ItemConfig
		local mutationNames = entry.MutationNames
		local mutationConfigs = entry.MutationConfigs
		
		if not itemConfig then return end
		
		local rarityConfig = GameConfig.Rarities[itemConfig.Rarity]
		local size = itemInstance:GetAttribute("Size") or 1
		local isLocked = itemInstance:GetAttribute("Locked") or false

		-- Create display name with all mutations
		local displayName = itemName
		local hasRainbow = false
		if #mutationNames > 0 then
			displayName = table.concat(mutationNames, " ") .. " " .. itemName
			-- Check for Rainbow mutation
			for _, mutationName in ipairs(mutationNames) do
				if mutationName == "Rainbow" then
					hasRainbow = true
					break
				end
			end
		end
		ui.DetailTitle.Text = displayName
		
		-- Use the color of the first/rarest mutation or rarity color
		local titleColor = rarityConfig.Color
		if mutationConfigs and #mutationConfigs > 0 and not hasRainbow then
			titleColor = mutationConfigs[1].Color or titleColor
		end
		ui.DetailTitle.TextColor3 = titleColor
		
		-- Start rainbow text animation for detail title if item has Rainbow mutation
		if hasRainbow then
			currentRainbowThread = coroutine.create(function()
				while ui.DetailTitle.Parent do
					local hue = (tick() * 1.5) % 5 / 5 -- Same speed as inventory
					local rainbowColor = Color3.fromHSV(hue, 1, 1)
					ui.DetailTitle.TextColor3 = rainbowColor
					task.wait(0.1) -- Smooth rainbow animation
				end
			end)
			coroutine.resume(currentRainbowThread)
		end
		
		-- UGC specific details
		ui.DetailItemType.Text = "Type: " .. (itemConfig.Type or "UGC Item")
		ui.DetailItemDescription.Text = itemConfig.Description or "A unique UGC item from the catalog."
		
		ui.DetailItemRarity.Text = "Rarity: " .. itemConfig.Rarity
		ui.DetailItemRarity.TextColor3 = rarityConfig.Color
		
		if #mutationNames > 0 then
			local mutationTexts = {}
			for _, mutationName in ipairs(mutationNames) do
				local mutationInfo = GameConfig.Mutations[mutationName]
				local mutationText = mutationName
				if mutationInfo and mutationInfo.Description then
					mutationText = mutationText .. " (" .. mutationInfo.Description .. ")"
				end
				table.insert(mutationTexts, mutationText)
			end
			ui.DetailItemMutation.Text = "Mutations: " .. table.concat(mutationTexts, ", ")
		else
			ui.DetailItemMutation.Text = "Mutations: None"
		end
		
		ui.DetailItemSize.Text = "Size: " .. NumberFormatter.FormatSize(size)
		
		local value = ItemValueCalculator.GetValue(itemConfig, mutationConfigs, size)
		local formattedValue = ItemValueCalculator.GetFormattedValue(itemConfig, mutationConfigs, size)
		ui.DetailItemValue.Text = "Value: " .. formattedValue
		
		-- Update sell button text with value
		ui.SellButton.Text = "Sell for " .. formattedValue
		
		-- Check if item is currently equipped
		local equippedItems = getCachedEquippedItems()
		local isEquipped = false
		if itemConfig.Type and equippedItems[itemConfig.Type] == itemInstance then
			isEquipped = true
		end
		
		-- Update button visibility and state - locked items can now be equipped
		ui.LockButton.Visible = true
		ui.EquipButton.Visible = not isEquipped
		ui.UnequipButton.Visible = isEquipped
		
		if isLocked then
			ui.SellButton.Visible = false
			ui.LockButton.Text = "Unlock"
			ui.LockButton.BackgroundColor3 = Color3.fromRGB(100, 160, 100) -- Greenish
		else
			ui.SellButton.Visible = true
			ui.LockButton.Text = "Lock"
			ui.LockButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242) -- Blue
		end
		
		-- Setup 3D preview of the selected item
		setup3DItemPreview(ui.ItemViewport, itemConfig)
	end
	
	local function addItemEntry(itemInstance)
		-- Get the actual item name from attribute (UUID system)
		local itemName = itemInstance:GetAttribute("ItemName") or itemInstance.Name
		local itemConfig = GameConfig.Items[itemName]
		if not itemConfig then return end

		local rarityConfig = GameConfig.Rarities[itemConfig.Rarity]
		local mutationNames = ItemValueCalculator.GetMutationNames(itemInstance)
		local mutationConfigs = ItemValueCalculator.GetMutationConfigs(itemInstance)

		local template = InventoryUI.CreateItemTemplate(itemInstance, itemName, itemConfig, rarityConfig, mutationConfigs)
		template.Parent = ui.ListPanel
		
		-- Setup 3D preview for the item in its template (simplified approach)
		local itemViewport3D = template:FindFirstChild("ItemViewport3D")
		if itemViewport3D then
			-- Load 3D preview immediately but asynchronously to avoid blocking
			task.spawn(function()
				setup3DItemPreview(itemViewport3D, itemConfig)
			end)
		end

		local function updateItemStatus()
			local isLocked = itemInstance:GetAttribute("Locked") or false
			
			-- Use cached equipped items instead of individual server calls
			local equippedItems = getCachedEquippedItems()
			local isEquipped = false
			if itemConfig and itemConfig.Type and equippedItems[itemConfig.Type] == itemInstance then
				isEquipped = true
			end
			
			-- Update name label to include lock and/or equipped icons
			local infoContainer = template:FindFirstChild("InfoContainer")
			local nameLabel = infoContainer and infoContainer:FindFirstChild("NameLabel")
			if nameLabel then
				local displayName = itemName
				
				if #mutationNames > 0 then
					displayName = table.concat(mutationNames, " ") .. " " .. itemName
				end
				
				-- Build prefix with status icons
				local prefix = ""
				if isEquipped then
					prefix = prefix .. "⚡ "
				end
				if isLocked then
					prefix = prefix .. "🔒 "
				end
				
				nameLabel.Text = prefix .. displayName
			end
			
			-- Add visual indication for equipped items - only equipped gets background change
			local gradient = template:FindFirstChild("UIGradient")
			local stroke = template:FindFirstChild("UIStroke")
			
			if isEquipped then
				-- Bright green glow for equipped items
				if stroke then
					stroke.Color = Color3.fromRGB(100, 255, 100)
					stroke.Thickness = 3
					stroke.Transparency = 0.3
				end
				if gradient then
					gradient.Color = ColorSequence.new{
						ColorSequenceKeypoint.new(0.0, Color3.fromRGB(100, 255, 100)),
						ColorSequenceKeypoint.new(0.5, Color3.fromRGB(76, 175, 80)),
						ColorSequenceKeypoint.new(1.0, Color3.fromRGB(50, 150, 50))
					}
				end
			else
				-- Reset to default rarity-based appearance for all non-equipped items
				if stroke then
					stroke.Color = rarityConfig and rarityConfig.Color or Color3.fromRGB(100, 100, 100)
					stroke.Thickness = 1
					stroke.Transparency = 0.7
				end
			end
			
			if selectedItem == itemInstance then
				updateDetails(itemInstance, template) -- Refresh details if this item is selected
			end
		end

		local connection = itemInstance:GetAttributeChangedSignal("Locked"):Connect(updateItemStatus)
		
		itemEntries[itemInstance] = { 
			Template = template, 
			Connection = connection, 
			UpdateStatus = updateItemStatus,
			ItemConfig = itemConfig, -- Cache for performance
			MutationNames = mutationNames, -- Cache for performance
			MutationConfigs = mutationConfigs -- Cache for performance
		}

		template.MouseButton1Click:Connect(function()
			if isAnimating then return end

			soundController:playUIClick() -- Play click sound

			-- If the same item is clicked again, deselect it
			if selectedItem == itemInstance then
				resetDetailsPanel()
			else
				-- Clear previous selection
				if selectedItemTemplate then
					local highlight = selectedItemTemplate:FindFirstChild("SelectionHighlight")
					if highlight then
						highlight.Visible = false
					end
				end
				
				updateDetails(itemInstance, template)
			end
		end)
		
		-- Set initial layout order to prevent items from being hidden
		template.LayoutOrder = #inventory:GetChildren()
		
		-- PERFORMANCE: Only update status if not in batch loading mode
		if not loadingBatch then
			updateInventoryCount()
			updateItemStatus() -- Set initial state
			
			-- Apply search filter and sorting to new item (with small delay)
			task.spawn(function()
				task.wait(0.1)
				if itemEntries[itemInstance] then
					filterInventory()
				end
			end)
		end
	end

	local function removeItemEntry(itemInstance)
		if itemEntries[itemInstance] then
			-- Clean up rainbow animation for this specific template
			local template = itemEntries[itemInstance].Template
			if template then
				local rainbowThread = template:GetAttribute("RainbowThread")
				if rainbowThread then
					coroutine.close(rainbowThread)
				end
			end
			
			itemEntries[itemInstance].Connection:Disconnect()
			itemEntries[itemInstance].Template:Destroy()
			itemEntries[itemInstance] = nil
		end
		
		if selectedItem == itemInstance then
			resetDetailsPanel()
		end
		
		-- Only update count if not in batch loading mode
		if not loadingBatch then
			updateInventoryCount()
		end
	end

	-- Batch processing for initial inventory load
	local function processPendingItems()
		if #pendingItems == 0 then
			loadingBatch = false
			-- After all items are loaded, update everything once
			updateInventoryCount()
			task.wait(0.1)
			filterInventory()
			-- Invalidate equipped items cache to refresh all statuses
			equippedItemsCache = nil
			-- Update all item statuses with fresh data
			for itemInstance, entry in pairs(itemEntries) do
				if entry.UpdateStatus then
					entry.UpdateStatus()
				end
			end
			print("Inventory loading complete - " .. #inventory:GetChildren() .. " items loaded")
			return
		end
		
		-- Process next batch
		local batchEnd = math.min(ITEM_BATCH_SIZE, #pendingItems)
		local itemsToProcess = {}
		
		-- Extract items for this batch
		for i = 1, batchEnd do
			table.insert(itemsToProcess, pendingItems[i])
		end
		
		-- Process the batch
		for _, itemInstance in ipairs(itemsToProcess) do
			addItemEntry(itemInstance)
		end
		
		-- Remove processed items from the front of the array
		for i = batchEnd, 1, -1 do
			table.remove(pendingItems, 1)
		end
		
		print("Processed batch of " .. batchEnd .. " items, " .. #pendingItems .. " remaining")
		
		-- Schedule next batch
		task.wait(BATCH_DELAY)
		task.spawn(processPendingItems)
	end
	
	-- Fast initial inventory population
	local function loadInventoryBatched()
		loadingBatch = true
		pendingItems = {}
		
		-- Queue all items for batch processing
		for _, itemInstance in ipairs(inventory:GetChildren()) do
			table.insert(pendingItems, itemInstance)
		end
		
		print("Starting batch inventory loading - " .. #pendingItems .. " items queued")
		
		-- Start batch processing
		task.spawn(processPendingItems)
	end

	local function toggleInventory(visible)
		if isAnimating then return end
		isAnimating = true

		local tweenInfo = TweenInfo.new(ANIMATION_TIME, ANIMATION_STYLE, ANIMATION_DIRECTION)

		if visible then
			-- Show and animate in
			hideOtherUIs(true)
			setupCharacterViewport(ui)
			
			ui.MainFrame.Visible = true
			
			-- Set initial positions & transparency
			ui.LeftPanel.Position = UDim2.new(-0.25, 0, 0.05, 0)
			ui.RightPanel.Position = UDim2.new(1.25, 0, 0.05, 0)
			ui.CharacterViewport.BackgroundTransparency = 1

			-- Define target positions on-screen
			local leftPanelEndPos = UDim2.new(0, 10, 0.05, 0)
			local rightPanelEndPos = UDim2.new(1, -10, 0.05, 0)
			
			local leftTween = TweenService:Create(ui.LeftPanel, tweenInfo, {Position = leftPanelEndPos})
			local rightTween = TweenService:Create(ui.RightPanel, tweenInfo, {Position = rightPanelEndPos})
			local viewportTween = TweenService:Create(ui.CharacterViewport, tweenInfo, {BackgroundTransparency = 1})
			
			leftTween:Play()
			rightTween:Play()
			if viewportTween then viewportTween:Play() end

			task.delay(ANIMATION_TIME, function()
				isAnimating = false
			end)
		else
			-- Animate out and hide
			local leftPanelEndPos = UDim2.new(-0.25, 0, 0.05, 0)
			local rightPanelEndPos = UDim2.new(1.25, 0, 0.05, 0)
			
			local leftTween = TweenService:Create(ui.LeftPanel, tweenInfo, {Position = leftPanelEndPos})
			local rightTween = TweenService:Create(ui.RightPanel, tweenInfo, {Position = rightPanelEndPos})
			local viewportTween = TweenService:Create(ui.CharacterViewport, tweenInfo, {BackgroundTransparency = 1})

			leftTween:Play()
			rightTween:Play()
			if viewportTween then viewportTween:Play() end

			-- Clean up rainbow animations when closing
			if currentRainbowThread then
				coroutine.close(currentRainbowThread)
				currentRainbowThread = nil
			end
			
			-- Clean up rainbow animations in item templates
			for itemInstance, entry in pairs(itemEntries) do
				local template = entry.Template
				if template then
					local rainbowThread = template:GetAttribute("RainbowThread")
					if rainbowThread then
						coroutine.close(rainbowThread)
						template:SetAttribute("RainbowThread", nil)
					end
				end
			end

			task.delay(ANIMATION_TIME, function()
				ui.MainFrame.Visible = false
				hideOtherUIs(false)
				isAnimating = false
			end)
		end
	end

	

	-- Register with NavigationController instead of connecting to toggle button
	NavigationController.RegisterController("Inventory", function()
		toggleInventory(not ui.MainFrame.Visible)
	end)
	
	ui.CloseButton.MouseButton1Click:Connect(function()
		if isAnimating then return end
		soundController:playUIClick()
		toggleInventory(false)
	end)

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == Enum.KeyCode.Tab then
			toggleInventory(not ui.MainFrame.Visible)
		elseif input.KeyCode == Enum.KeyCode.Escape and ui.MainFrame.Visible then
			toggleInventory(false)
		end
	end)

	ui.SellButton.MouseButton1Click:Connect(function()
		if selectedItem and not isAnimating then
			soundController:playSellItem()
			Remotes.SellItem:FireServer(selectedItem)
			resetDetailsPanel()
		end
	end)

	ui.EquipButton.MouseButton1Click:Connect(function()
		if selectedItem and not isAnimating then
			soundController:playUIClick()
			local itemName = selectedItem:GetAttribute("ItemName") or selectedItem.Name
			Remotes.EquipItem:FireServer(itemName, selectedItem.Name)
		end
	end)

	ui.UnequipButton.MouseButton1Click:Connect(function()
		if selectedItem and not isAnimating then
			soundController:playUIClick()
			local itemName = selectedItem:GetAttribute("ItemName") or selectedItem.Name
			local itemConfig = GameConfig.Items[itemName]
			if itemConfig and itemConfig.Type then
				Remotes.UnequipItem:FireServer(itemConfig.Type)
			end
		end
	end)

	ui.SellUnlockedButton.MouseButton1Click:Connect(function()
		soundController:playSellItem()
		Remotes.SellUnlockedItems:FireServer()
	end)

	ui.LockButton.MouseButton1Click:Connect(function()
		if selectedItem then
			Remotes.ToggleItemLock:FireServer(selectedItem)
		end
	end)

	local function refreshAllItemStatuses()
		-- Invalidate cache first
		equippedItemsCache = nil
		-- Update all item templates to show equipped status
		for itemInstance, entry in pairs(itemEntries) do
			if entry.UpdateStatus then
				entry.UpdateStatus()
			end
		end
	end

	-- Listen for server-side equip status changes
	Remotes.EquipStatusChanged.OnClientEvent:Connect(function()
		refreshAllItemStatuses()
		if selectedItem and selectedItemTemplate then
			updateDetails(selectedItem, selectedItemTemplate)
		end
	end)

	-- Handle initial loading and new items
	local initialLoadComplete = false
	local timerActive = true
	
	local function startInitialLoad()
		-- Start a fallback timer - if no server signal comes within 5 seconds, load anyway
		task.delay(5, function()
			if timerActive and not initialLoadComplete then
				initialLoadComplete = true
				loadInventoryBatched()
			end
		end)
	end
	
	-- Listen for server signal that inventory loading is complete
	Remotes.InventoryLoadComplete.OnClientEvent:Connect(function()
		if not initialLoadComplete then
			-- Cancel fallback timer by setting flag
			timerActive = false
			initialLoadComplete = true
			loadInventoryBatched()
		end
	end)

	inventory.ChildAdded:Connect(function(itemInstance)
		if not initialLoadComplete then
			-- We're still in the initial loading phase - items are being loaded by server
			-- Don't start individual item processing yet
		else
			-- Handle new items immediately (not in batch mode)
			if not loadingBatch then
				addItemEntry(itemInstance)
			end
		end
	end)
	
	-- Start the fallback timer
	startInitialLoad()
	inventory.ChildRemoved:Connect(removeItemEntry)
	
	-- Initialize UI state
	resetDetailsPanel()
	updateInventoryCount()
	updateRAP()
	
	-- Connect to RAP changes
	LocalPlayer:GetAttributeChangedSignal("RAPValue"):Connect(updateRAP)
	
	-- Listen for upgrade updates to refresh inventory limit display
	Remotes.UpgradeUpdated.OnClientEvent:Connect(function(upgradeId, newLevel)
		if upgradeId == "InventorySlots" then
			-- Refresh the inventory count display with new limit
			updateInventoryCount()
		end
	end)
	
	-- Make global action buttons visible
	ui.SellUnlockedButton.Visible = true

	LocalPlayer.CharacterAdded:Connect(function()
		-- Wait a bit for character to fully load
		task.wait(2)
		if ui.MainFrame.Visible then
			setupCharacterViewport(ui)
		end
	end)
end

return InventoryController 