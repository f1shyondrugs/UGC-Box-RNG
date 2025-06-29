local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Shared = ReplicatedStorage.Shared

local GameConfig = require(Shared.Modules.GameConfig)
local Remotes = require(Shared.Remotes.Remotes)
local EnchanterUI = require(script.Parent.Parent.UI.EnchanterUI)
local NumberFormatter = require(Shared.Modules.NumberFormatter)
local InventoryController = require(script.Parent.InventoryController)

local EnchanterController = {}
EnchanterController.ClassName = "EnchanterController"

-- State
local components = nil
local isVisible = false
local availableItems = {}
local selectedItemIndex = 1
local hiddenUIs = {}
local soundController = nil
local isRolling = false
local filteredItems = {}

local function hideOtherUIs(show)
	local playerGui = LocalPlayer:WaitForChild("PlayerGui")
	if show then
		for _, gui in pairs(playerGui:GetChildren()) do
			if gui:IsA("ScreenGui") and gui ~= (components and components.ScreenGui) then
				if gui.Enabled then
					hiddenUIs[gui] = true
					gui.Enabled = false
				end
			end
		end
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
	else
		for gui, _ in pairs(hiddenUIs) do
			if gui and gui.Parent then
				gui.Enabled = true
			end
		end
		hiddenUIs = {}
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
	end
end

local function setup3DItemPreview(viewport, itemConfig)
	if not viewport or not itemConfig then return end

	-- Clear viewport
	viewport:ClearAllChildren()

	-- Create camera
	local camera = Instance.new("Camera")
	camera.Parent = viewport
	viewport.CurrentCamera = camera

	-- Try to load the UGC item
	local success, asset = pcall(function()
		return Remotes.LoadAssetForPreview:InvokeServer(itemConfig.AssetId)
	end)

	if success and asset then
		local assetClone = asset:Clone()
		assetClone.Parent = viewport

		-- Position camera to show the item nicely
		local cf, size = assetClone:GetBoundingBox()
		local distance = math.max(size.X, size.Y, size.Z) * 2
		camera.CFrame = CFrame.lookAt(cf.Position + Vector3.new(distance, distance * 0.5, distance), cf.Position)

		-- Start rotation animation
		local rotationConnection
		rotationConnection = RunService.RenderStepped:Connect(function(dt)
			if assetClone.Parent then
				-- Check if it's a model and set PrimaryPart if needed
				if assetClone:IsA("Model") then
					if not assetClone.PrimaryPart then
						-- Find the first part to use as PrimaryPart
						local firstPart = assetClone:FindFirstChildWhichIsA("Part") or assetClone:FindFirstChildWhichIsA("MeshPart")
						if firstPart then
							assetClone.PrimaryPart = firstPart
						end
					end
					
					-- Only rotate if we have a PrimaryPart
					if assetClone.PrimaryPart then
						assetClone:SetPrimaryPartCFrame(assetClone:GetPrimaryPartCFrame() * CFrame.Angles(0, math.rad(30 * dt), 0))
					end
				elseif assetClone:IsA("BasePart") then
					-- If it's just a part, rotate it directly
					assetClone.CFrame = assetClone.CFrame * CFrame.Angles(0, math.rad(30 * dt), 0)
				end
			else
				rotationConnection:Disconnect()
			end
		end)
	else
		-- Fallback: create a simple preview
		local part = Instance.new("Part")
		part.Name = "PreviewPart"
		part.Size = Vector3.new(2, 2, 2)
		part.Material = Enum.Material.Neon
		part.Color = Color3.fromRGB(100, 150, 255)
		part.Anchored = true
		part.Parent = viewport
		camera.CFrame = CFrame.lookAt(Vector3.new(4, 2, 4), part.Position)
	end
end

local function updateSelectedItemDisplay(animateMutators)
	if not components or not filteredItems or selectedItemIndex < 1 or selectedItemIndex > #filteredItems then return end
	
	local ItemValueCalculator = require(Shared.Modules.ItemValueCalculator)
	local itemData = filteredItems[selectedItemIndex]
	-- Recalculate value in case mutations changed
	itemData.value = ItemValueCalculator.GetValue(itemData.itemConfig, ItemValueCalculator.GetMutationConfigs(itemData.itemInstance), itemData.itemInstance:GetAttribute("Size") or 1)
	local mutationNames = ItemValueCalculator.GetMutationNames(itemData.itemInstance)
	
	-- Build display name with mutations
	local displayName = itemData.itemName
	if #mutationNames > 0 then
		displayName = table.concat(mutationNames, " ") .. " " .. itemData.itemName
	end
	
	-- Update selected item info
	components.ItemNameLabel.Text = displayName
	components.ItemValueLabel.Text = "Value: " .. NumberFormatter.FormatCurrency(itemData.value)
	components.ItemTypeLabel.Text = "Type: " .. (itemData.itemConfig.Type or "UGC Item")
	
	local size = itemData.itemInstance:GetAttribute("Size") or 1
	components.ItemSizeLabel.Text = "Size: " .. NumberFormatter.FormatSize(size)
	
	-- Update cost (now uses item value)
	local cost = itemData.value or 0
	components.CostLabel.Text = "Cost: " .. NumberFormatter.FormatCurrency(cost)
	
	-- Check if player can afford
	local playerMoney = LocalPlayer:GetAttribute("RobuxValue") or 0
	if playerMoney >= cost then
		components.RerollButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
		components.RerollButton.Text = "Reroll Mutators"
		components.RerollButton.AutoButtonColor = true
	else
		components.RerollButton.BackgroundColor3 = Color3.fromRGB(87, 91, 99)
		components.RerollButton.Text = "Cannot Afford"
		components.RerollButton.AutoButtonColor = false
	end
	
	-- Update mutators display with animation
	local mutatorsFrame = components.MutatorsScrollFrame
	for _, child in pairs(mutatorsFrame:GetChildren()) do
		if child:IsA("Frame") then
			if animateMutators then
				-- Animate: flash color
				local origColor = child.BackgroundColor3
				child.BackgroundColor3 = Color3.fromRGB(255, 255, 120)
				game:GetService("TweenService"):Create(child, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {BackgroundColor3 = origColor}):Play()
			end
			child:Destroy()
		end
	end
	
	if #mutationNames > 0 then
		for _, mutationName in ipairs(mutationNames) do
			local mutationConfig = GameConfig.Mutations[mutationName]
			if mutationConfig then
				local entry = EnchanterUI.CreateMutatorEntry(mutationName, mutationConfig)
				entry.Parent = mutatorsFrame
				if animateMutators then
					entry.BackgroundColor3 = Color3.fromRGB(255, 255, 120)
					game:GetService("TweenService"):Create(entry, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(35, 40, 55)}):Play()
				end
			end
		end
	else
		-- Show "No mutators" entry
		local noMutatorsEntry = Instance.new("Frame")
		noMutatorsEntry.Name = "NoMutatorsEntry"
		noMutatorsEntry.Size = UDim2.new(1, -10, 0, 25)
		noMutatorsEntry.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
		noMutatorsEntry.BorderSizePixel = 0
		noMutatorsEntry.ZIndex = 54
		noMutatorsEntry.Parent = mutatorsFrame
		
		local entryCorner = Instance.new("UICorner")
		entryCorner.CornerRadius = UDim.new(0, 6)
		entryCorner.Parent = noMutatorsEntry
		
		local noMutatorsLabel = Instance.new("TextLabel")
		noMutatorsLabel.Size = UDim2.new(1, -10, 1, 0)
		noMutatorsLabel.Position = UDim2.new(0, 5, 0, 0)
		noMutatorsLabel.Text = "No mutators (1x value)"
		noMutatorsLabel.Font = Enum.Font.SourceSans
		noMutatorsLabel.TextSize = 12
		noMutatorsLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
		noMutatorsLabel.TextXAlignment = Enum.TextXAlignment.Left
		noMutatorsLabel.BackgroundTransparency = 1
		noMutatorsLabel.ZIndex = 55
		noMutatorsLabel.Parent = noMutatorsEntry
	end
	
	-- Setup 3D preview
	setup3DItemPreview(components.ItemViewport, itemData.itemConfig)
end

local function populateItemSelection()
	if not components or not filteredItems then return end
	
	-- Clear existing selection entries
	for _, child in pairs(components.ItemSelectionFrame:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end
	
	-- If filteredItems is empty, show a message
	if #filteredItems == 0 then
		local noResults = Instance.new("TextLabel")
		noResults.Size = UDim2.new(1, -10, 0, 40)
		noResults.Position = UDim2.new(0, 5, 0, 0)
		noResults.Text = "No items found."
		noResults.Font = Enum.Font.SourceSans
		noResults.TextSize = 16
		noResults.TextColor3 = Color3.fromRGB(200, 200, 200)
		noResults.BackgroundTransparency = 1
		noResults.ZIndex = 54
		noResults.Parent = components.ItemSelectionFrame
		return
	end

	-- Clamp selectedItemIndex to filteredItems
	if selectedItemIndex < 1 or selectedItemIndex > #filteredItems then
		selectedItemIndex = 1
	end

	-- Create selection entries for each item
	for index, itemData in ipairs(filteredItems) do
		local entry = EnchanterUI.CreateItemSelectionEntry(itemData, index == selectedItemIndex)
		entry.Parent = components.ItemSelectionFrame
		entry.MouseButton1Click:Connect(function()
			selectedItemIndex = index
			populateItemSelection() -- Refresh selection display
			updateSelectedItemDisplay() -- Update selected item display
			if soundController then
				soundController:playUIClick()
			end
		end)
	end
end

local function showInfoPopup()
	if not components then return end
	
	components.InfoPopup.Visible = true
	
	-- Clear existing info entries
	local infoFrame = components.InfoScrollFrame
	for _, child in pairs(infoFrame:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	
	-- Add introduction text
	local introLabel = Instance.new("TextLabel")
	introLabel.Name = "IntroLabel"
	introLabel.Size = UDim2.new(1, 0, 0, 60)
	introLabel.Text = "The Enchanter uses the same mutator probability system as crate opening. Each mutator has an independent chance to appear:"
	introLabel.Font = Enum.Font.SourceSans
	introLabel.TextSize = 14
	introLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
	introLabel.TextWrapped = true
	introLabel.BackgroundTransparency = 1
	introLabel.ZIndex = 103
	introLabel.Parent = infoFrame
	
	-- Add all mutator probability entries
	for mutatorName, mutatorConfig in pairs(GameConfig.Mutations) do
		local entry = EnchanterUI.CreateInfoEntry(mutatorName, mutatorConfig)
		entry.Parent = infoFrame
	end
	
	-- Add bottom explanation
	local explanationLabel = Instance.new("TextLabel")
	explanationLabel.Name = "ExplanationLabel"
	explanationLabel.Size = UDim2.new(1, 0, 0, 80)
	explanationLabel.Text = "💡 Items can get multiple mutators! Each mutator is rolled independently, so you could get very lucky and receive several rare mutators on the same item."
	explanationLabel.Font = Enum.Font.SourceSans
	explanationLabel.TextSize = 14
	explanationLabel.TextColor3 = Color3.fromRGB(255, 215, 100)
	explanationLabel.TextWrapped = true
	explanationLabel.BackgroundTransparency = 1
	explanationLabel.ZIndex = 103
	explanationLabel.Parent = infoFrame
end

local function hideInfoPopup()
	if components then
		components.InfoPopup.Visible = false
	end
end

local function updateItemListFromSearch()
	if not components or not components.SearchBox then return end
	local searchText = string.lower(components.SearchBox.Text or "")
	filteredItems = {}
	if searchText == "" then
		for i, item in ipairs(availableItems) do
			table.insert(filteredItems, item)
		end
	else
		for i, item in ipairs(availableItems) do
			local nameMatch = string.find(string.lower(item.itemName), searchText, 1, true)
			local mutNames = require(Shared.Modules.ItemValueCalculator).GetMutationNames(item.itemInstance)
			local mutMatch = false
			for _, mut in ipairs(mutNames) do
				if string.find(string.lower(mut), searchText, 1, true) then
					mutMatch = true
					break
				end
			end
			if nameMatch or mutMatch then
				table.insert(filteredItems, item)
			end
		end
	end
	selectedItemIndex = 1
	populateItemSelection()
	updateSelectedItemDisplay()
end

function EnchanterController:Start()
	print("[EnchanterController] Starting...")
	
	-- Create UI components
	components = EnchanterUI.Create(LocalPlayer.PlayerGui)
	
	-- Set up connections
	self:SetupConnections()
	
	print("[EnchanterController] Started successfully!")
end

function EnchanterController:SetupConnections()
	-- Close button connection
	components.CloseButton.MouseButton1Click:Connect(function()
		if soundController then
			soundController:playUIClick()
		end
		self:Hide()
	end)
	
	-- Info button connection
	components.InfoButton.MouseButton1Click:Connect(function()
		if soundController then
			soundController:playUIClick()
		end
		showInfoPopup()
	end)
	
	-- Info close button connection
	components.InfoCloseButton.MouseButton1Click:Connect(function()
		if soundController then
			soundController:playUIClick()
		end
		hideInfoPopup()
	end)
	
	-- Reroll button connection
	components.RerollButton.MouseButton1Click:Connect(function()
		if isRolling then return end
		if not filteredItems or selectedItemIndex < 1 or selectedItemIndex > #filteredItems then return end
		
		local selectedItem = filteredItems[selectedItemIndex]
		local cost = selectedItem.value or 0
		local playerMoney = LocalPlayer:GetAttribute("RobuxValue") or 0

		-- Check if the item is equipped before reroll
		local equippedType = selectedItem.itemConfig.Type
		local wasEquipped = false
		if equippedType then
			local equippedItems = nil
			local success, result = pcall(function()
				return Remotes.GetEquippedItems:InvokeServer()
			end)
			if success and type(result) == "table" then
				equippedItems = result
			end
			if equippedItems and equippedItems[equippedType] and equippedItems[equippedType].Name == selectedItem.itemInstance.Name then
				wasEquipped = true
			end
		end
		
		if playerMoney >= cost then
			isRolling = true
			if soundController then
				soundController:playUIClick()
			end
			
			-- Disable button temporarily
			components.RerollButton.AutoButtonColor = false
			components.RerollButton.BackgroundColor3 = Color3.fromRGB(87, 91, 99)
			components.RerollButton.Text = "Rerolling..."

			-- Predictable, visually appealing mutator shuffle animation
			local mutatorsFrame = components.MutatorsScrollFrame
			local shuffleSteps = 14
			local allMutatorNames = {}
			for name, _ in pairs(GameConfig.Mutations) do table.insert(allMutatorNames, name) end
			-- Build plausible mutator sets for each step
			local plausibleSets = {}
			for i = 1, shuffleSteps - 1 do
				local set = {}
				if i < shuffleSteps * 0.4 then
					-- Early: show 1-2 common mutators
					local commons = {}
					for name, config in pairs(GameConfig.Mutations) do
						if (config.Chance or 0) > 10 then table.insert(commons, name) end
					end
					if #commons == 0 then commons = allMutatorNames end -- fallback if no commons
					set[1] = commons[math.random(1, #commons)]
					if math.random() < 0.4 then set[2] = commons[math.random(1, #commons)] end
				elseif i < shuffleSteps * 0.7 then
					-- Middle: show 1-2 random mutators, sometimes a rare
					set[1] = allMutatorNames[math.random(1, #allMutatorNames)]
					if math.random() < 0.7 then set[2] = allMutatorNames[math.random(1, #allMutatorNames)] end
				else
					-- Late: show 2-3, can include rare/epic
					local used = {}
					for j = 1, math.random(2, 3) do
						local pick
						repeat pick = allMutatorNames[math.random(1, #allMutatorNames)] until not used[pick]
						used[pick] = true
						set[j] = pick
					end
				end
				table.insert(plausibleSets, set)
			end
			-- Final step: show the actual result (but we don't know it yet, so will update after reroll)
			local function showSet(set, highlight)
				for _, child in pairs(mutatorsFrame:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
				for _, mutName in ipairs(set) do
					local config = GameConfig.Mutations[mutName]
					local displayName = mutName
					if not config then
						config = {ValueMultiplier = 1, Color = Color3.fromRGB(180,180,180)}
						displayName = mutName == "No mutators" and "No mutators (1x value)" or mutName
					end
					local entry = EnchanterUI.CreateMutatorEntry(displayName, config)
					if highlight then
						entry.BackgroundColor3 = Color3.fromRGB(255, 255, 120)
						TweenService:Create(entry, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(35, 40, 55)}):Play()
					else
						entry.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
						TweenService:Create(entry, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(35, 40, 55)}):Play()
					end
					entry.Parent = mutatorsFrame
				end
			end
			for i, set in ipairs(plausibleSets) do
				showSet(set, false)
				wait(0.07 + 0.04 * (i / shuffleSteps))
			end

			-- Send reroll request to server
			Remotes.RerollMutators:FireServer(selectedItem.itemInstance)
			
			-- Wait for the server to update the item (simulate delay)
			task.wait(0.5)
			-- Now show the actual result with a highlight
			local ItemValueCalculator = require(Shared.Modules.ItemValueCalculator)
			local mutationNames = ItemValueCalculator.GetMutationNames(selectedItem.itemInstance)
			if #mutationNames > 0 then
				showSet(mutationNames, true)
			else
				showSet({"No mutators"}, true)
			end
			task.wait(0.4)

			-- Re-enable button after a short delay
			local newPlayerMoney = LocalPlayer:GetAttribute("RobuxValue") or 0
			if newPlayerMoney >= cost then
				components.RerollButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
				components.RerollButton.Text = "Reroll Mutators"
				components.RerollButton.AutoButtonColor = true
			else
				components.RerollButton.BackgroundColor3 = Color3.fromRGB(87, 91, 99)
				components.RerollButton.Text = "Cannot Afford"
				components.RerollButton.AutoButtonColor = false
			end
			-- Animate mutator change and update value
			updateSelectedItemDisplay(true)
			populateItemSelection() -- Refresh the item selection list so the name/mutators update
			-- Re-equip if it was equipped before
			if wasEquipped then
				local itemName = selectedItem.itemName
				local itemInstanceName = selectedItem.itemInstance.Name
				Remotes.EquipItem:FireServer(itemName, itemInstanceName)
			end
			-- Reload inventory UI
			InventoryController.Start(LocalPlayer.PlayerGui, nil, soundController) 
			task.wait(0.5) -- Add cooldown after roll
			isRolling = false
		else
			-- Play error sound or show notification
			if soundController then
				soundController:playUIClick()
			end
		end
	end)
	
	-- Handle UI scaling when viewport changes
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		if components.UpdateScale then
			components.UpdateScale()
		end
	end)
	
	-- Listen for money changes to update affordability
	LocalPlayer:GetAttributeChangedSignal("RobuxValue"):Connect(function()
		if filteredItems and selectedItemIndex >= 1 and selectedItemIndex <= #filteredItems and components then
			local selectedItem = filteredItems[selectedItemIndex]
			local cost = selectedItem.value or 0
			local playerMoney = LocalPlayer:GetAttribute("RobuxValue") or 0
			
			if playerMoney >= cost then
				components.RerollButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
				components.RerollButton.Text = "Reroll Mutators"
				components.RerollButton.AutoButtonColor = true
			else
				components.RerollButton.BackgroundColor3 = Color3.fromRGB(87, 91, 99)
				components.RerollButton.Text = "Cannot Afford"
				components.RerollButton.AutoButtonColor = false
			end
		end
	end)

	-- Connect search box change
	if components and components.SearchBox then
		components.SearchBox:GetPropertyChangedSignal("Text"):Connect(updateItemListFromSearch)
	end
end

function EnchanterController:Show(itemsList)
	if not components or type(itemsList) ~= "table" or #itemsList == 0 then return end
	
	availableItems = itemsList
	filteredItems = {}
	for i, item in ipairs(availableItems) do
		table.insert(filteredItems, item)
	end
	selectedItemIndex = 1 -- Start with first item selected
	isVisible = true
	hideOtherUIs(true)
	populateItemSelection()
	updateSelectedItemDisplay()
	components.MainFrame.Visible = true
	-- Animate the UI appearing
	components.MainFrame.Size = UDim2.new(0, 0, 0, 0)
	components.MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	local showTween = TweenService:Create(
		components.MainFrame,
		TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{
			Size = UDim2.new(0.7, 0, 0.8, 0),
			Position = UDim2.new(0.15, 0, 0.1, 0)
		}
	)
	showTween:Play()
end

function EnchanterController:Hide()
	if not components then return end
	
	isVisible = false
	hideOtherUIs(false)
	hideInfoPopup()
	
	-- Animate the UI disappearing
	local hideTween = TweenService:Create(
		components.MainFrame,
		TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In),
		{
			Size = UDim2.new(0, 0, 0, 0),
			Position = UDim2.new(0.5, 0, 0.5, 0)
		}
	)
	
	hideTween:Play()
	hideTween.Completed:Connect(function()
		components.MainFrame.Visible = false
		availableItems = {}
		selectedItemIndex = 1
	end)
end

function EnchanterController:IsVisible()
	return isVisible
end

function EnchanterController:SetSoundController(controller)
	soundController = controller
end

-- Handle enchanter open requests from server
Remotes.OpenEnchanter.OnClientEvent:Connect(function(itemsList)
	if EnchanterController.Show then
		EnchanterController:Show(itemsList)
	end
end)

-- Clean up when controller is destroyed
function EnchanterController:Destroy()
	-- Destroy UI
	if components and components.ScreenGui then
		components.ScreenGui:Destroy()
	end
	
	print("[EnchanterController] Destroyed")
end

return EnchanterController