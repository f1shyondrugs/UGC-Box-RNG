local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

local Shared = ReplicatedStorage.Shared
local Remotes = require(Shared.Remotes.Remotes)
local GameConfig = require(Shared.Modules.GameConfig)
local InventoryUI = require(script.Parent.Parent.UI.InventoryUI)
local ItemValueCalculator = require(Shared.Modules.ItemValueCalculator)

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
	local rapStat = leaderstats:WaitForChild("RAP")
	
	-- Get current inventory limit from upgrades
	local currentInventoryLimit = DEFAULT_INVENTORY_LIMIT
	local success, upgradeData = pcall(function()
		return Remotes.GetUpgradeData:InvokeServer()
	end)
	
	if success and upgradeData and upgradeData.InventorySlots then
		local inventoryUpgrade = upgradeData.InventorySlots
		if inventoryUpgrade.effects and inventoryUpgrade.effects.CurrentSlots then
			currentInventoryLimit = inventoryUpgrade.effects.CurrentSlots
		end
	end
	
	local ui = InventoryUI.Create(parentGui)
	
	local itemEntries = {} -- itemInstance -> { Template, LockIcon, Connection }
	local searchText = ""

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
		
		-- Check item config properties
		local itemConfig = GameConfig.Items[itemName]
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
		
		-- Check mutations
		local mutationNames = ItemValueCalculator.GetMutationNames(itemInstance)
		for _, mutationName in ipairs(mutationNames) do
			if string.find(string.lower(mutationName), searchQuery) then
				return true
			end
		end
		
		-- Check size (convert to string for search)
		local size = itemInstance:GetAttribute("Size")
		if size and string.find(tostring(size), searchQuery) then
			return true
		end
		
		return false
	end

	local function filterInventory()
		for itemInstance, entry in pairs(itemEntries) do
			if entry.Template then
				local visible = matchesSearch(itemInstance, searchText)
				entry.Template.Visible = visible
			end
		end
	end

	local function onSearchChanged()
		searchText = ui.SearchBox.Text
		ui.ClearButton.Visible = searchText ~= ""
		filterInventory()
	end

	-- Connect search functionality
	ui.SearchBox:GetPropertyChangedSignal("Text"):Connect(onSearchChanged)
	ui.ClearButton.MouseButton1Click:Connect(function()
		ui.SearchBox.Text = ""
		ui.SearchBox:CaptureFocus()
	end)

	

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
		local totalRAP = rapStat.Value
		local formattedRAP = ItemValueCalculator.GetFormattedRAP(totalRAP)
		ui.RAPLabel.Text = "Total RAP: " .. formattedRAP
	end

	local function updateBoxPrompts(isFull)
		local boxesFolder = workspace:FindFirstChild("Boxes")
		if not boxesFolder then return end

		for _, boxPart in ipairs(boxesFolder:GetChildren()) do
			if boxPart:IsA("Part") and boxPart:GetAttribute("Owner") == LocalPlayer.UserId then
				local prompt = boxPart:FindFirstChildOfClass("ProximityPrompt")
				if prompt then
					if isFull or openingBoxes[boxPart] then
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
			ui.InventoryTitle.Text = string.format("INVENTORY (%d / %d)", count, currentInventoryLimit)
	
	local isFull = count >= currentInventoryLimit
		ui.WarningIcon.Visible = isFull
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
		
		-- Get the actual item name from attribute (UUID system)
		local itemName = itemInstance:GetAttribute("ItemName") or itemInstance.Name
		local itemConfig = GameConfig.Items[itemName]
		if not itemConfig then return end
		
		local rarityConfig = GameConfig.Rarities[itemConfig.Rarity]
		local mutationNames = ItemValueCalculator.GetMutationNames(itemInstance)
		local mutationConfigs = ItemValueCalculator.GetMutationConfigs(itemInstance)
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
		
		ui.DetailItemSize.Text = string.format("Size: %.2f", size)
		
		local value = ItemValueCalculator.GetValue(itemConfig, mutationConfigs, size)
		local formattedValue = ItemValueCalculator.GetFormattedValue(itemConfig, mutationConfigs, size)
		ui.DetailItemValue.Text = "Value: " .. formattedValue
		
		-- Update sell button text with value
		ui.SellButton.Text = "Sell for " .. formattedValue
		
		-- Check if item is currently equipped
		local equippedItems = Remotes.GetEquippedItems:InvokeServer()
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
		
		-- Setup 3D preview for the item in its template
		local itemViewport3D = template:FindFirstChild("ItemViewport3D")
		if itemViewport3D then
			setup3DItemPreview(itemViewport3D, itemConfig)
		end
		
		local lockIcon = template:FindFirstChild("LockIcon")
		local equippedIcon = template:FindFirstChild("EquippedIcon")

		local function updateItemStatus()
			local isLocked = itemInstance:GetAttribute("Locked") or false
			if lockIcon then
				lockIcon.Visible = isLocked
			end
			
			-- Check equipped status
			local success, equippedItems = pcall(function()
				return Remotes.GetEquippedItems:InvokeServer()
			end)
			local isEquipped = false
			if success and itemConfig and itemConfig.Type and equippedItems[itemConfig.Type] == itemInstance then
				isEquipped = true
			end
			
			if equippedIcon then
				equippedIcon.Visible = isEquipped
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
					local rarityConfig = GameConfig.Rarities[itemConfig.Rarity]
					stroke.Color = rarityConfig and rarityConfig.Color or Color3.fromRGB(100, 100, 100)
					stroke.Thickness = 1
					stroke.Transparency = 0.7
				end
				-- Reset gradient to original rarity colors (this is handled in the template creation)
			end
			
			if selectedItem == itemInstance then
				updateDetails(itemInstance, template) -- Refresh details if this item is selected
			end
		end

		local connection = itemInstance:GetAttributeChangedSignal("Locked"):Connect(updateItemStatus)
		
		itemEntries[itemInstance] = { Template = template, Connection = connection, UpdateStatus = updateItemStatus }

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
		
		updateInventoryCount()
		updateItemStatus() -- Set initial state
		
		-- Apply search filter to new item
		filterInventory()
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
		updateInventoryCount()
	end

	local function toggleInventory(visible)
		if isAnimating then return end
		isAnimating = true

		local tweenInfo = TweenInfo.new(ANIMATION_TIME, ANIMATION_STYLE, ANIMATION_DIRECTION)

		if visible then
			-- Show and animate in
			hideOtherUIs(true)
			ui.ToggleButton.Visible = false
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
				ui.ToggleButton.Visible = true
				isAnimating = false
			end)
		end
	end

	

	-- Connect Buttons
	ui.ToggleButton.MouseButton1Click:Connect(function()
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

	-- Initial population and search setup
	for _, itemInstance in ipairs(inventory:GetChildren()) do
		addItemEntry(itemInstance)
	end
	
	-- Apply initial search filter
	filterInventory()

	inventory.ChildAdded:Connect(addItemEntry)
	inventory.ChildRemoved:Connect(removeItemEntry)
	
	-- Initialize UI state
	resetDetailsPanel()
	updateInventoryCount()
	updateRAP()
	
	-- Connect to RAP changes
	rapStat:GetPropertyChangedSignal("Value"):Connect(updateRAP)
	
	-- Listen for upgrade updates to refresh inventory limit
	Remotes.UpgradeUpdated.OnClientEvent:Connect(function(upgradeId, newLevel)
		if upgradeId == "InventorySlots" then
			-- Update inventory limit
			local success, upgradeData = pcall(function()
				return Remotes.GetUpgradeData:InvokeServer()
			end)
			
			if success and upgradeData and upgradeData.InventorySlots then
				local inventoryUpgrade = upgradeData.InventorySlots
				if inventoryUpgrade.effects and inventoryUpgrade.effects.CurrentSlots then
					currentInventoryLimit = inventoryUpgrade.effects.CurrentSlots
					updateInventoryCount() -- Refresh display
				end
			end
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