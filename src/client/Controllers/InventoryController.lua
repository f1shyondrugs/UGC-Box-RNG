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
local INVENTORY_LIMIT = 50

-- Camera and UI state management
local originalCamera = nil
local inventoryCamera = nil
local cameraConnection = nil
local hiddenUIs = {}
local selectedItemTemplate = nil
local isAnimating = false
local ANIMATION_TIME = 0.3
local ANIMATION_STYLE = Enum.EasingStyle.Quint
local ANIMATION_DIRECTION = Enum.EasingDirection.Out

function InventoryController.Start(parentGui, openingBoxes)
	local inventory = LocalPlayer:WaitForChild("Inventory")
	local leaderstats = LocalPlayer:WaitForChild("leaderstats")
	local rapStat = leaderstats:WaitForChild("RAP")
	
	local ui = InventoryUI.Create(parentGui)
	
	local itemEntries = {} -- itemInstance -> { Template, LockIcon, Connection }
	local selectedItem = nil

	local function setupCharacterViewport()
		local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		if not character then return end
		
		local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
		if not humanoidRootPart then
			warn("Could not find HumanoidRootPart for character viewport.")
			return
		end

		-- Clear existing character from viewport
		ui.CharacterViewport:ClearAllChildren()

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

	local function setup3DItemPreview(viewport, itemConfig)
		if not itemConfig or not itemConfig.AssetId then return end
		
		-- Clear viewport
		viewport:ClearAllChildren()
		
		-- Create camera
		local camera = Instance.new("Camera")
		camera.Parent = viewport
		viewport.CurrentCamera = camera
		
		-- Try to load the asset as an accessory
		local success, asset = pcall(function()
			return game:GetService("InsertService"):LoadAsset(itemConfig.AssetId)
		end)
		
		if success and asset then
			local accessory = asset:FindFirstChildOfClass("Accessory")
			if accessory then
				-- Position the accessory in the viewport
				accessory.Parent = viewport
				
				-- Get the handle part
				local handle = accessory:FindFirstChild("Handle")
				if handle then
					-- Position camera to show the item nicely
					local itemSize = handle.Size
					local maxSize = math.max(itemSize.X, itemSize.Y, itemSize.Z)
					local distance = maxSize * 2
					
					camera.CFrame = CFrame.lookAt(
						handle.Position + Vector3.new(distance, distance * 0.5, distance),
						handle.Position
					)
					
					-- Add rotation animation
					local rotationTween = TweenService:Create(
						handle,
						TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
						{CFrame = handle.CFrame * CFrame.Angles(0, math.rad(360), 0)}
					)
					rotationTween:Play()
				end
			end
		else
			-- Fallback: Create a simple preview mesh
			local part = Instance.new("Part")
			part.Size = Vector3.new(1, 1, 1)
			part.Material = Enum.Material.Neon
			part.BrickColor = BrickColor.new("Bright blue")
			part.Anchored = true
			part.Parent = viewport
			
			camera.CFrame = CFrame.lookAt(Vector3.new(3, 2, 3), Vector3.new(0, 0, 0))
			
			-- Add rotation
			local rotationTween = TweenService:Create(
				part,
				TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
				{CFrame = part.CFrame * CFrame.Angles(0, math.rad(360), 0)}
			)
			rotationTween:Play()
		end
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
		ui.InventoryRAPLabel.Text = "Total RAP: " .. formattedRAP
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
		ui.InventoryTitle.Text = string.format("INVENTORY (%d / %d)", count, INVENTORY_LIMIT)
		
		local isFull = count >= INVENTORY_LIMIT
		ui.WarningIcon.Visible = isFull
		updateBoxPrompts(isFull)
	end

	local function resetDetailsPanel()
		ui.DetailTitle.Text = "ITEM DETAILS"
		ui.DetailTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
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
		
		-- Clear item viewport
		ui.ItemViewport:ClearAllChildren()
		
		-- Clear selection highlight
		if selectedItemTemplate then
			local highlight = selectedItemTemplate:FindFirstChild("SelectionHighlight")
			if highlight then
				highlight.Visible = false
			end
			selectedItemTemplate = nil
		end
		
		selectedItem = nil
	end

	local function updateDetails(itemInstance, itemTemplate)
		selectedItem = itemInstance
		selectedItemTemplate = itemTemplate
		
		-- Show selection highlight
		local highlight = itemTemplate:FindFirstChild("SelectionHighlight")
		if highlight then
			highlight.Visible = true
		end
		
		local itemName = itemInstance.Name
		local itemConfig = GameConfig.Items[itemName]
		if not itemConfig then return end
		
		local rarityConfig = GameConfig.Rarities[itemConfig.Rarity]
		local mutationName = itemInstance:GetAttribute("Mutation")
		local mutationConfig = mutationName and GameConfig.Mutations[mutationName]
		local size = itemInstance:GetAttribute("Size") or 1
		local isLocked = itemInstance:GetAttribute("Locked") or false

		local displayName = mutationName and (mutationName .. " " .. itemName) or itemName
		ui.DetailTitle.Text = displayName
		ui.DetailTitle.TextColor3 = mutationConfig and mutationConfig.Color or rarityConfig.Color
		
		-- UGC specific details
		ui.DetailItemType.Text = "Type: " .. (itemConfig.Type or "UGC Item")
		ui.DetailItemDescription.Text = itemConfig.Description or "A unique UGC item from the catalog."
		
		ui.DetailItemRarity.Text = "Rarity: " .. itemConfig.Rarity
		ui.DetailItemRarity.TextColor3 = rarityConfig.Color
		
		if mutationName then
			local mutationInfo = GameConfig.Mutations[mutationName]
			ui.DetailItemMutation.Text = "Mutation: " .. mutationName .. " (" .. (mutationInfo.Description or "") .. ")"
		else
			ui.DetailItemMutation.Text = "Mutation: None"
		end
		
		ui.DetailItemSize.Text = string.format("Size: %.2f", size)
		
		local value = ItemValueCalculator.GetValue(itemConfig, mutationConfig, size)
		local formattedValue = ItemValueCalculator.GetFormattedValue(itemConfig, mutationConfig, size)
		ui.DetailItemValue.Text = "Value: " .. formattedValue
		
		-- Update sell button text with value
		ui.SellButton.Text = "Sell for " .. formattedValue
		
		-- Check if item is currently equipped
		local equippedItems = Remotes.GetEquippedItems:InvokeServer()
		local isEquipped = false
		if itemConfig.Type and equippedItems[itemConfig.Type] == itemConfig.AssetId then
			isEquipped = true
		end
		
		-- Update button visibility and state based on lock status and equipped status
		ui.LockButton.Visible = true
		ui.EquipButton.Visible = not isEquipped and not isLocked
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
		local itemName = itemInstance.Name
		local itemConfig = GameConfig.Items[itemName]
		if not itemConfig then return end

		local rarityConfig = GameConfig.Rarities[itemConfig.Rarity]
		local mutationConfig = itemInstance:GetAttribute("Mutation") and GameConfig.Mutations[itemInstance:GetAttribute("Mutation")]

		local template = InventoryUI.CreateItemTemplate(itemInstance, itemName, itemConfig, rarityConfig, mutationConfig)
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
			if success and itemConfig and itemConfig.Type and equippedItems[itemConfig.Type] == itemConfig.AssetId then
				isEquipped = true
			end
			
			if equippedIcon then
				equippedIcon.Visible = isEquipped
			end
			
			if selectedItem == itemInstance then
				updateDetails(itemInstance, template) -- Refresh details if this item is selected
			end
		end

		local connection = itemInstance:GetAttributeChangedSignal("Locked"):Connect(updateItemStatus)
		
		itemEntries[itemInstance] = { Template = template, Connection = connection, UpdateStatus = updateItemStatus }

		template.MouseButton1Click:Connect(function()
			-- Clear previous selection
			if selectedItemTemplate then
				local highlight = selectedItemTemplate:FindFirstChild("SelectionHighlight")
				if highlight then
					highlight.Visible = false
				end
			end
			
			updateDetails(itemInstance, template)
		end)
		
		updateInventoryCount()
		updateItemStatus() -- Set initial state
	end

	local function removeItemEntry(itemInstance)
		if itemEntries[itemInstance] then
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
			setupCharacterViewport()
			
			ui.MainFrame.Visible = true
			
			-- Set initial positions off-screen
			local leftPanelStartPos = UDim2.new(-0.25, 0, 0.05, 0)
			local rightPanelStartPos = UDim2.new(1, 0, 0.05, 0)
			ui.LeftPanel.Position = leftPanelStartPos
			ui.RightPanel.Position = rightPanelStartPos

			-- Define target positions on-screen
			local leftPanelEndPos = UDim2.new(0, 10, 0.05, 0)
			local rightPanelEndPos = UDim2.new(0.75, 0, 0.05, 0)
			
			local leftTween = TweenService:Create(ui.LeftPanel, tweenInfo, {Position = leftPanelEndPos})
			local rightTween = TweenService:Create(ui.RightPanel, tweenInfo, {Position = rightPanelEndPos})
			
			leftTween:Play()
			rightTween:Play()

			task.delay(ANIMATION_TIME, function()
				isAnimating = false
			end)
		else
			-- Animate out and hide
			local leftPanelEndPos = UDim2.new(-0.25, 0, 0.05, 0)
			local rightPanelEndPos = UDim2.new(1, 0, 0.05, 0)
			
			local leftTween = TweenService:Create(ui.LeftPanel, tweenInfo, {Position = leftPanelEndPos})
			local rightTween = TweenService:Create(ui.RightPanel, tweenInfo, {Position = rightPanelEndPos})

			leftTween:Play()
			rightTween:Play()

			task.delay(ANIMATION_TIME, function()
				ui.MainFrame.Visible = false
				hideOtherUIs(false)
				ui.ToggleButton.Visible = true
				isAnimating = false
			end)
		end
	end

	-- Connect character spawned event
	LocalPlayer.CharacterAdded:Connect(function()
		-- Wait a bit for character to fully load
		task.wait(2)
		if ui.MainFrame.Visible then
			setupCharacterViewport()
		end
	end)

	-- Connect Buttons
	ui.ToggleButton.MouseButton1Click:Connect(function()
		toggleInventory(not ui.MainFrame.Visible)
	end)
	
	ui.CloseButton.MouseButton1Click:Connect(function()
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
		if selectedItem then
			Remotes.SellItem:FireServer(selectedItem)
		end
	end)

	ui.SellAllButton.MouseButton1Click:Connect(function()
		Remotes.SellAllItems:FireServer()
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

	ui.EquipButton.MouseButton1Click:Connect(function()
		if selectedItem then
			Remotes.EquipItem:FireServer(selectedItem.Name)
			-- Refresh all item statuses to update equipped icons
			task.wait(0.1) -- Small delay to let server process
			refreshAllItemStatuses()
			-- Refresh the details panel to update button visibility
			updateDetails(selectedItem, selectedItemTemplate)
		end
	end)

	ui.UnequipButton.MouseButton1Click:Connect(function()
		if selectedItem then
			local itemConfig = GameConfig.Items[selectedItem.Name]
			if itemConfig and itemConfig.Type then
				Remotes.UnequipItem:FireServer(itemConfig.Type)
				-- Refresh all item statuses to update equipped icons
				task.wait(0.1) -- Small delay to let server process
				refreshAllItemStatuses()
				-- Refresh the details panel to update button visibility
				updateDetails(selectedItem, selectedItemTemplate)
			end
		end
	end)

	-- Connect RAP updates
	rapStat:GetPropertyChangedSignal("Value"):Connect(updateRAP)

	-- Initial population
	resetDetailsPanel()
	updateInventoryCount()
	updateRAP()
	for _, itemInstance in ipairs(inventory:GetChildren()) do
		addItemEntry(itemInstance)
	end

	inventory.ChildAdded:Connect(addItemEntry)
	inventory.ChildRemoved:Connect(removeItemEntry)
end

return InventoryController 