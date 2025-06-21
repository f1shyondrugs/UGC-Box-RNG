local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local Shared = ReplicatedStorage.Shared
local Remotes = require(Shared.Remotes.Remotes)
local GameConfig = require(Shared.Modules.GameConfig)
local InventoryUI = require(script.Parent.Parent.UI.InventoryUI)
local ItemValueCalculator = require(Shared.Modules.ItemValueCalculator)

local InventoryController = {}
local INVENTORY_LIMIT = 50

function InventoryController.Start(parentGui, openingBoxes)
	local inventory = LocalPlayer:WaitForChild("Inventory")
	local leaderstats = LocalPlayer:WaitForChild("leaderstats")
	local rapStat = leaderstats:WaitForChild("RAP")
	
	local ui = InventoryUI.Create(parentGui)
	
	local itemEntries = {} -- itemInstance -> { Template, LockIcon, Connection }
	local selectedItem = nil

	local function updateRAP()
		local totalRAP = rapStat.Value
		ui.RAPLabel.Text = "Total RAP: " .. ItemValueCalculator.GetFormattedRAP(totalRAP)
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
		ui.InventoryCount.Text = string.format("UGC Items: %d / %d", count, INVENTORY_LIMIT)
		
		local isFull = count >= INVENTORY_LIMIT
		ui.WarningIcon.Visible = isFull

		if isFull then
			ui.InventoryCount.TextColor3 = Color3.fromRGB(255, 100, 100)
		else
			ui.InventoryCount.TextColor3 = Color3.fromRGB(220, 221, 222)
		end
		updateBoxPrompts(isFull)
	end

	local function resetDetailsPanel()
		ui.DetailItemName.Text = "Select a UGC Item"
		ui.DetailItemName.TextColor3 = Color3.fromRGB(220, 221, 222)
		ui.DetailItemType.Text = ""
		ui.DetailItemDescription.Text = ""
		ui.DetailItemRarity.Text = ""
		ui.DetailItemMutation.Text = ""
		ui.DetailItemSize.Text = ""
		ui.DetailItemValue.Text = ""
		ui.SellButton.Visible = false
		ui.LockButton.Visible = false
		selectedItem = nil
	end

	local function updateDetails(itemInstance)
		selectedItem = itemInstance
		
		local itemName = itemInstance.Name
		local itemConfig = GameConfig.Items[itemName]
		if not itemConfig then return end
		
		local rarityConfig = GameConfig.Rarities[itemConfig.Rarity]
		local mutationName = itemInstance:GetAttribute("Mutation")
		local mutationConfig = mutationName and GameConfig.Mutations[mutationName]
		local size = itemInstance:GetAttribute("Size") or 1
		local isLocked = itemInstance:GetAttribute("Locked") or false

		local displayName = mutationName and (mutationName .. " " .. itemName) or itemName
		ui.DetailItemName.Text = displayName
		ui.DetailItemName.TextColor3 = mutationConfig and mutationConfig.Color or rarityConfig.Color
		
		-- UGC specific details
		ui.DetailItemType.Text = "Type: " .. (itemConfig.Type or "UGC")
		ui.DetailItemDescription.Text = itemConfig.Description or "A unique UGC item"
		
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
		
		-- Update button visibility and state based on lock status
		ui.LockButton.Visible = true
		if isLocked then
			ui.SellButton.Visible = false
			ui.LockButton.Text = "Unlock"
			ui.LockButton.BackgroundColor3 = Color3.fromRGB(100, 160, 100) -- Greenish
		else
			ui.SellButton.Visible = true
			ui.LockButton.Text = "Lock"
			ui.LockButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242) -- Blue
		end
	end
	
	local function addItemEntry(itemInstance)
		local itemName = itemInstance.Name
		local itemConfig = GameConfig.Items[itemName]
		if not itemConfig then return end

		local rarityConfig = GameConfig.Rarities[itemConfig.Rarity]
		local mutationConfig = itemInstance:GetAttribute("Mutation") and GameConfig.Mutations[itemInstance:GetAttribute("Mutation")]

		local template = InventoryUI.CreateItemTemplate(itemInstance, itemName, itemConfig, rarityConfig, mutationConfig)
		template.Parent = ui.ListPanel
		
		local lockIcon = template:FindFirstChild("LockIcon") -- Find the icon manually

		local function updateLockVisibility()
			local isLocked = itemInstance:GetAttribute("Locked") or false
			if lockIcon then
				lockIcon.Visible = isLocked
			end
			if selectedItem == itemInstance then
				updateDetails(itemInstance) -- Refresh details if this item is selected
			end
		end

		local connection = itemInstance:GetAttributeChangedSignal("Locked"):Connect(updateLockVisibility)
		
		itemEntries[itemInstance] = { Template = template, Connection = connection }

		template.MouseButton1Click:Connect(function()
			updateDetails(itemInstance)
		end)
		
		updateInventoryCount()
		updateLockVisibility() -- Set initial state
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
		ui.MainFrame.Visible = visible
	end

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