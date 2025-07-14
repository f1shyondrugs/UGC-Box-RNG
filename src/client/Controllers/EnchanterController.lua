local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")

local LocalPlayer = Players.LocalPlayer
local Shared = ReplicatedStorage.Shared

local GameConfig = require(Shared.Modules.GameConfig)
local Remotes = require(Shared.Remotes.Remotes)
local EnchanterUI = require(script.Parent.Parent.UI.EnchanterUI)
local NumberFormatter = require(Shared.Modules.NumberFormatter)
local InventoryController = require(script.Parent.InventoryController)
local BoxAnimator = require(script.Parent.BoxAnimator)

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

-- Auto-enchanting state
local hasAutoEnchanterGamepass = false
local selectedTargetMutators = {}
local isAutoEnchanting = false
local mutatorCheckboxes = {}
local stopOnHigherRarity = false
local matchAnyMode = false -- false = AND (default), true = OR

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

local function promptGamepassPurchase()
	-- Safety check for gamepass ID
	if not GameConfig or not GameConfig.AutoEnchanterGamepassId then
		warn("AutoEnchanterGamepassId not found in GameConfig")
		-- Notify player about the issue
		local ToastNotificationController = require(script.Parent.ToastNotificationController)
		if ToastNotificationController then
			ToastNotificationController.ShowToast("Auto-Enchanter gamepass temporarily unavailable. Please try again later.", "Error")
		end
		return
	end
	
	-- Ensure the gamepass ID is a valid number
	local gamepassId = GameConfig.AutoEnchanterGamepassId
	if type(gamepassId) ~= "number" or gamepassId <= 0 then
		warn("Invalid AutoEnchanterGamepassId:", gamepassId)
		local ToastNotificationController = require(script.Parent.ToastNotificationController)
		if ToastNotificationController then
			ToastNotificationController.ShowToast("Auto-Enchanter gamepass temporarily unavailable. Please try again later.", "Error")
		end
		return
	end
	
	-- Safely prompt gamepass purchase
	local success, err = pcall(function()
		MarketplaceService:PromptGamePassPurchase(LocalPlayer, gamepassId)
	end)
	
	if not success then
		warn("Failed to prompt gamepass purchase:", err)
		local ToastNotificationController = require(script.Parent.ToastNotificationController)
		if ToastNotificationController then
			ToastNotificationController.ShowToast("Failed to open gamepass purchase. Please try again.", "Error")
		end
	end
end

local function updateMutatorsDisplay(mutationNames, animate)
	local mutatorsFrame = components.MutatorsScrollFrame
	-- Clear existing mutators
	for _, child in ipairs(mutatorsFrame:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	
	-- Sort mutationNames by chance (rarity)
	table.sort(mutationNames, function(a, b)
		local aConf = GameConfig.Mutations[a]
		local bConf = GameConfig.Mutations[b]
		if not aConf then return false end
		if not bConf then return true end
		return aConf.Chance > bConf.Chance
	end)
	
	if #mutationNames > 0 then
		for _, mutationName in ipairs(mutationNames) do
			local mutationConfig = GameConfig.Mutations[mutationName] or {Color = Color3.new(1,1,1), ValueMultiplier = 1}
			local entry = EnchanterUI.CreateMutatorEntry(mutationName, mutationConfig)
			entry.Parent = mutatorsFrame
			if animate then
				entry.BackgroundColor3 = Color3.fromRGB(255, 255, 120)
				game:GetService("TweenService"):Create(entry, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(35, 40, 55)}):Play()
			end
		end
	else
		local entry = EnchanterUI.CreateMutatorEntry("No mutators", {Color = Color3.fromRGB(150,150,150), ValueMultiplier = 1})
		entry.Parent = mutatorsFrame
	end
end

local function updateSelectedItemDisplay()
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
	
	-- Update mutators display
	updateMutatorsDisplay(mutationNames, false)
	
	-- Setup 3D preview
	setup3DItemPreview(components.ItemViewport, itemData.itemConfig)
end

local function hideItemSelectionPopup()
	if not components then return end
	
	-- Close the inventory enchanting mode if it's open
	InventoryController.CloseEnchantingMode()
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
		noResults.Font = Enum.Font.Gotham
		noResults.TextSize = 16
		noResults.TextColor3 = Color3.fromRGB(200, 200, 200)
		noResults.BackgroundTransparency = 1
		noResults.ZIndex = 103
		noResults.Parent = components.ItemSelectionFrame
		return
	end

	-- Clamp selectedItemIndex to filteredItems
	if selectedItemIndex < 1 or selectedItemIndex > #filteredItems then
		selectedItemIndex = 1
	end

	-- Create selection entries for each item
	for index, itemData in ipairs(filteredItems) do
		local entry = EnchanterUI.CreateItemEntry(itemData)
		entry.Parent = components.ItemSelectionFrame
		entry.MouseButton1Click:Connect(function()
			selectedItemIndex = index
			updateSelectedItemDisplay() -- Update selected item display
			hideItemSelectionPopup() -- Close the popup after selection
			if soundController then
				soundController:playUIClick()
			end
		end)
	end
end

local function showItemSelectionPopup()
	if not components then return end
	
	print("Opening inventory for item selection...")
	
	-- Check if InventoryController is ready
	if not InventoryController._ui then
		print("InventoryController not ready, attempting to initialize...")
		-- Try to initialize the inventory controller if it hasn't been started yet
		local initSuccess, initErr = pcall(function()
			InventoryController.Start(LocalPlayer.PlayerGui, nil, soundController)
		end)
		
		if not initSuccess then
			warn("Failed to initialize InventoryController:", initErr)
			-- Fallback to show the old popup
			components.ItemSelectionPopup.Visible = true
			return
		end
		
		-- Wait a moment for it to initialize
		task.wait(0.2)
		print("After init - InventoryController._ui exists:", InventoryController._ui ~= nil)
	end
	
	-- Use the inventory UI instead of the popup
	local success, err = pcall(function()
		return InventoryController.OpenForEnchanting(
			-- Callback when item is selected
			function(selectedItemInstance)
				print("Item selected in enchanting mode:", selectedItemInstance.Name)
				-- Find the item in our available items list
				for index, itemData in ipairs(availableItems) do
					if itemData.itemInstance == selectedItemInstance then
						selectedItemIndex = index
						-- Update our filtered items to match
						filteredItems = {}
						for i, item in ipairs(availableItems) do
							table.insert(filteredItems, item)
						end
											updateSelectedItemDisplay()
					InventoryController.CloseEnchantingMode()
					-- Make sure our enchanter GUI is visible again
					if components and components.ScreenGui then
						components.ScreenGui.Enabled = true
					end
					break
					end
				end
			end,
					-- Callback when closed
		function()
			print("Enchanting mode closed by user")
			InventoryController.CloseEnchantingMode()
			-- Make sure our enchanter GUI is visible again
			if components and components.ScreenGui then
				components.ScreenGui.Enabled = true
			end
		end
		)
	end)
	
	if not success then
		warn("Failed to open inventory for enchanting:", err)
		-- Fallback to show the old popup
		print("Falling back to old popup")
		components.ItemSelectionPopup.Visible = true
	else
		print("Successfully opened inventory for enchanting")
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
	
	-- Add all mutator probability entries
	for mutatorName, mutatorConfig in pairs(GameConfig.Mutations) do
		local entry = EnchanterUI.CreateInfoEntry(mutatorName, mutatorConfig)
		entry.Parent = infoFrame
	end
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
	populateItemSelection() -- Refresh the popup list
end

-- Update auto-enchanter UI based on gamepass ownership
local function updateAutoEnchanterUI()
	if not components then return end
	
	local hasSelection = false
	for _, v in pairs(selectedTargetMutators) do
		if v then
			hasSelection = true
			break
		end
	end
	local canAfford = false
	if filteredItems and selectedItemIndex >= 1 and selectedItemIndex <= #filteredItems then
		local selectedItem = filteredItems[selectedItemIndex]
		canAfford = (LocalPlayer:GetAttribute("RobuxValue") or 0) >= (selectedItem.value or 0)
	end

	-- Update visuals for all checkboxes based on gamepass ownership
	for _, checkbox in pairs(mutatorCheckboxes) do
		checkbox.Parent.Transparency = hasAutoEnchanterGamepass and 0 or 0.5
	end

	-- Update auto-enchant button state
	if isAutoEnchanting then
		components.AutoEnchantButton.Visible = false
		components.StopAutoEnchantButton.Visible = true
	else
		components.AutoEnchantButton.Visible = true
		components.StopAutoEnchantButton.Visible = false
		
		if hasAutoEnchanterGamepass then
			if hasSelection and canAfford then
				components.AutoEnchantButton.BackgroundColor3 = Color3.fromRGB(80, 170, 80)
				components.AutoEnchantButton.Text = "▶ Start Auto-Enchanting"
				components.AutoEnchantButton.AutoButtonColor = true
			else
				components.AutoEnchantButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
				components.AutoEnchantButton.Text = "Select an Item & Target"
				components.AutoEnchantButton.AutoButtonColor = false
			end
		else
			components.AutoEnchantButton.BackgroundColor3 = Color3.fromRGB(224, 172, 53)
			components.AutoEnchantButton.Text = "🔑 Get Auto-Enchanter"
			components.AutoEnchantButton.AutoButtonColor = true
		end
	end
end

-- Check gamepass ownership and update UI
local function checkGamepassOwnership()
	if not Remotes or not Remotes.CheckAutoEnchanterGamepass then
		warn("CheckAutoEnchanterGamepass remote not available yet, retrying in 2 seconds...")
		hasAutoEnchanterGamepass = false
		if components then
			updateAutoEnchanterUI()
		end
		
		-- Retry after a delay in a separate task
		task.spawn(function()
			task.wait(2)
			if Remotes and Remotes.CheckAutoEnchanterGamepass then
				checkGamepassOwnership() -- Recursive retry
			else
				warn("CheckAutoEnchanterGamepass remote still not available after retry")
			end
		end)
		return
	end
	
	local success, ownsGamepass = pcall(function()
		return Remotes.CheckAutoEnchanterGamepass:InvokeServer()
	end)
	
	if success then
		hasAutoEnchanterGamepass = ownsGamepass or false
		print("Gamepass ownership check successful:", hasAutoEnchanterGamepass)
	else
		hasAutoEnchanterGamepass = false
		warn("Failed to check gamepass ownership:", ownsGamepass)
	end
	
	if components then
		updateAutoEnchanterUI()
	end
end

-- Populate mutator selection checkboxes
local function populateMutatorSelection()
	if not components or not components.MutatorSelectionFrame then return end
	
	-- Clear existing checkboxes
	for _, child in pairs(components.MutatorSelectionFrame:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	mutatorCheckboxes = {}

	-- Create a sorted list of mutations by chance
	local sortedMutations = {}
	for name, data in pairs(GameConfig.Mutations) do
		table.insert(sortedMutations, { name = name, config = data })
	end
	table.sort(sortedMutations, function(a, b)
		return a.config.Chance > b.config.Chance -- Sort from most common to rarest
	end)
	
	-- Add checkbox for each mutator
	for index, mutationData in ipairs(sortedMutations) do
		local mutatorName = mutationData.name
		local mutatorConfig = mutationData.config
		local isSelected = selectedTargetMutators[mutatorName] or false
		local entry, checkbox = EnchanterUI.CreateMutatorCheckboxEntry(mutatorName, mutatorConfig, isSelected)
		entry.LayoutOrder = index -- Set the layout order to match the sorted list
		entry.Parent = components.MutatorSelectionFrame
		mutatorCheckboxes[mutatorName] = checkbox
		
		-- Connect checkbox click
		checkbox.MouseButton1Click:Connect(function()
			if not hasAutoEnchanterGamepass then
				promptGamepassPurchase()
				return
			end
			
			if soundController then
				soundController:playUIClick()
			end
			
			selectedTargetMutators[mutatorName] = not (selectedTargetMutators[mutatorName] or false)
			local newState = selectedTargetMutators[mutatorName]
			
			checkbox.BackgroundColor3 = newState and Color3.fromRGB(88, 189, 88) or Color3.fromRGB(40, 40, 50)
			checkbox.Text = newState and "✓" or ""
			
			updateAutoEnchanterUI()
		end)
	end
end

-- Handle auto-enchanting progress updates
local function handleAutoEnchantingProgress(isRunning, attempts, totalSpent, progressText, newMutatorNames)
	if not components then return end
	
	isAutoEnchanting = isRunning
	updateAutoEnchanterUI()
	
	if isRunning then
		-- While running, show live progress and mutators
		components.ProgressLabel.Text = progressText
		if newMutatorNames then
			updateMutatorsDisplay(newMutatorNames, true)
		end
	else
		-- When stopped, show the final message and refresh the static item display.
		components.ProgressLabel.Text = progressText -- Show the final status (e.g., "Target achieved!")
		
		-- After a short delay, clear the final message
		task.delay(3, function()
			if not isAutoEnchanting then -- Make sure another session hasn't started
				components.ProgressLabel.Text = ""
			end
		end)
		
		-- Refresh the main display to show the final, static mutators
	updateSelectedItemDisplay()
	end
end

function EnchanterController:Start()
	print("[EnchanterController] Starting...")
	
	-- Create UI components
	components = EnchanterUI.Create(LocalPlayer.PlayerGui)
	
	-- Function to check if enchanter is unlocked and update UI accordingly
	local function updateEnchanterUI()
		local success, unlockedFeatures = pcall(function()
			return Remotes.GetUnlockedFeatures:InvokeServer()
		end)
		
		if success and unlockedFeatures then
			local isUnlocked = false
			for _, feature in ipairs(unlockedFeatures) do
				if feature == "Enchanter" then
					isUnlocked = true
					break
				end
			end
			
			print("[EnchanterController] Enchanter unlocked:", isUnlocked)
			
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
					if components and components.MainFrame then
						blackOutElement(components.MainFrame)
						print("[EnchanterController] UI blacked out on attempt", attempts + 1)
						break
					else
						attempts = attempts + 1
						task.wait(0.1)
					end
				end
				if attempts >= 10 then
					print("[EnchanterController] Failed to black out UI after 10 attempts")
				end
				-- Paint EnchantingArea parts neon black (recursive)
				local enchantingArea = workspace:FindFirstChild("EnchantingArea")
				if enchantingArea then
					local function paintBlackRecursive(obj)
						if obj:IsA("BasePart") then
							obj.Color = Color3.fromRGB(0, 0, 0)
							obj.Material = Enum.Material.Neon
							if obj:FindFirstChild("PointLight") then
								obj.PointLight.Color = Color3.fromRGB(0, 0, 0)
							end
						end
						for _, child in ipairs(obj:GetChildren()) do
							paintBlackRecursive(child)
						end
					end
					paintBlackRecursive(enchantingArea)
				end
			else
				-- Restore original EnchantingArea build if available
				local enchantingArea = workspace:FindFirstChild("EnchantingArea")
				if enchantingArea then
					local originalBuilds = ReplicatedStorage:FindFirstChild("OriginalBuilds")
					if originalBuilds then
						local originalEnchantingArea = originalBuilds:FindFirstChild("EnchantingArea")
						if originalEnchantingArea then
							enchantingArea:ClearAllChildren()
							for _, originalPart in pairs(originalEnchantingArea:GetChildren()) do
								local restoredPart = originalPart:Clone()
								restoredPart.Parent = enchantingArea
							end
							print("[EnchanterController] Restored EnchantingArea from original build (UI update)")
						else
							-- Fallback: restore normal colors
							local function restorePart(part)
								if part:IsA("BasePart") then
									part.Color = Color3.fromRGB(150, 100, 255)
									part.Material = Enum.Material.Neon
									if part:FindFirstChild("PointLight") then
										part.PointLight.Color = Color3.fromRGB(150, 100, 255)
									end
								end
								for _, child in pairs(part:GetChildren()) do
									restorePart(child)
								end
							end
							for _, part in pairs(enchantingArea:GetChildren()) do
								restorePart(part)
							end
						end
					end
				end
				print("[EnchanterController] UI restored to normal")
			end
		else
			print("[EnchanterController] Failed to get unlocked features:", success)
		end
	end
	
	-- Update UI initially (with delay to ensure UI is created)
	task.wait(1)
	updateEnchanterUI()
	
	-- Update UI when rebirth data changes
	Remotes.RebirthUpdated.OnClientEvent:Connect(function()
		task.wait(0.5) -- Small delay to ensure data is updated
		updateEnchanterUI()
	end)
	
	-- Continuously monitor UI and black out if needed
	task.spawn(function()
		while task.wait(2) do
			local success, unlockedFeatures = pcall(function()
				return Remotes.GetUnlockedFeatures:InvokeServer()
			end)
			
			if success and unlockedFeatures then
				local isUnlocked = false
				for _, feature in ipairs(unlockedFeatures) do
					if feature == "Enchanter" then
						isUnlocked = true
						break
					end
				end
				
				-- Paint EnchantingArea parts
				local enchantingArea = workspace:FindFirstChild("EnchantingArea")
				if enchantingArea then
					if isUnlocked then
						-- Restore from original build
						local originalBuilds = ReplicatedStorage:FindFirstChild("OriginalBuilds")
						if originalBuilds then
							local originalEnchantingArea = originalBuilds:FindFirstChild("EnchantingArea")
							if originalEnchantingArea then
								enchantingArea:ClearAllChildren()
								for _, originalPart in pairs(originalEnchantingArea:GetChildren()) do
									local restoredPart = originalPart:Clone()
									restoredPart.Parent = enchantingArea
								end
								print("[EnchanterController] Restored EnchantingArea from original build (monitor)")
							else
								-- Fallback: restore normal colors
								local function restorePart(part)
									if part:IsA("BasePart") then
										part.Color = Color3.fromRGB(150, 100, 255)
										part.Material = Enum.Material.Neon
										if part:FindFirstChild("PointLight") then
											part.PointLight.Color = Color3.fromRGB(150, 100, 255)
										end
									end
									for _, child in pairs(part:GetChildren()) do
										restorePart(child)
									end
								end
								for _, part in pairs(enchantingArea:GetChildren()) do
									restorePart(part)
								end
							end
						end
					else
						-- Paint EnchantingArea parts neon black (recursive)
						local function paintBlackRecursive(obj)
							if obj:IsA("BasePart") then
								obj.Color = Color3.fromRGB(0, 0, 0)
								obj.Material = Enum.Material.Neon
								if obj:FindFirstChild("PointLight") then
									obj.PointLight.Color = Color3.fromRGB(0, 0, 0)
								end
							end
							for _, child in ipairs(obj:GetChildren()) do
								paintBlackRecursive(child)
							end
						end
						paintBlackRecursive(enchantingArea)
					end
				end
				
				-- Also black out UI if it exists
				if not isUnlocked and components and components.MainFrame then
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
					
					blackOutElement(components.MainFrame)
				end
			end
		end
	end)
	
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

	-- Select Item button connection
	components.SelectItemButton.MouseButton1Click:Connect(function()
		if soundController then
			soundController:playUIClick()
		end
		showItemSelectionPopup()
	end)
	
	-- Note: Popup close button connection removed since we're using inventory UI now
	
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
			-- populateItemSelection() -- Not needed - only for popup refresh
			-- Re-equip if it was equipped before
			if wasEquipped then
				local itemName = selectedItem.itemName
				local itemInstanceName = selectedItem.itemInstance.Name
				Remotes.EquipItem:FireServer(itemName, itemInstanceName)
			end
			-- Note: Inventory reload moved to server-side or handled elsewhere 
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

	-- Note: Search box connection removed since we're using inventory UI now
	
	-- Auto-enchanting button connections
	components.AutoEnchantButton.MouseButton1Click:Connect(function()
		if not hasAutoEnchanterGamepass then
			promptGamepassPurchase()
			return
		end

		if isAutoEnchanting then return end
		
		-- Validate filteredItems and selectedItemIndex
		if not filteredItems or type(filteredItems) ~= "table" or #filteredItems == 0 then
			warn("No items available for auto-enchanting")
			if soundController then
				soundController:playUIClick()
			end
			return
		end
		
		if selectedItemIndex < 1 or selectedItemIndex > #filteredItems then
			warn("Invalid selected item index:", selectedItemIndex, "out of", #filteredItems)
			if soundController then
				soundController:playUIClick()
			end
			return
		end
		
		-- Check if remote exists
		if not Remotes.StartAutoEnchanting then
			warn("StartAutoEnchanting remote not available")
			return
		end
		
		-- Get selected target mutators
		local targetMutators = {}
		if selectedTargetMutators and type(selectedTargetMutators) == "table" then
			for mutatorName, selected in pairs(selectedTargetMutators) do
				if selected then
					table.insert(targetMutators, mutatorName)
				end
			end
		end
		
		if #targetMutators == 0 then
			warn("No target mutators selected for auto-enchanting")
			if soundController then
				soundController:playUIClick()
			end
			return
		end
		
		local selectedItem = filteredItems[selectedItemIndex]
		if not selectedItem then
			warn("Selected item is nil at index:", selectedItemIndex)
			if soundController then
				soundController:playUIClick()
			end
			return
		end
		
		if not selectedItem.itemInstance then
			warn("Selected item has no itemInstance")
			if soundController then
				soundController:playUIClick()
			end
			return
		end
		
		if soundController then
			soundController:playUIClick()
		end
		
		-- Start auto-enchanting with safety checks
		local success, err = pcall(function()
			Remotes.StartAutoEnchanting:FireServer(selectedItem.itemInstance, targetMutators, stopOnHigherRarity, matchAnyMode)
		end)
		
		if not success then
			warn("Failed to start auto-enchanting:", err)
		end
	end)
	
	components.StopAutoEnchantButton.MouseButton1Click:Connect(function()
		if soundController then
			soundController:playUIClick()
		end
		
		-- Check if remote exists
		if not Remotes.StopAutoEnchanting then
			warn("StopAutoEnchanting remote not available")
			return
		end
		
		Remotes.StopAutoEnchanting:FireServer()
	end)
	
	-- Connect "Or Higher" toggle switch
	components.OrHigherSwitch.MouseButton1Click:Connect(function()
		if not hasAutoEnchanterGamepass then
			promptGamepassPurchase()
			return
		end

		stopOnHigherRarity = not stopOnHigherRarity
		
		local knob = components.OrHigherSwitchKnob
		local sw = components.OrHigherSwitch
		
		if stopOnHigherRarity then
			sw.BackgroundColor3 = Color3.fromRGB(80, 170, 80)
			TweenService:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = UDim2.new(1, -18, 0.5, -8)}):Play()
		else
			sw.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
			TweenService:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = UDim2.new(0, 2, 0.5, -8)}):Play()
		end
	end)
	
	-- Connect auto-enchanting progress updates
	if Remotes.AutoEnchantingProgress then
		Remotes.AutoEnchantingProgress.OnClientEvent:Connect(handleAutoEnchantingProgress)
	else
		warn("AutoEnchantingProgress remote not available for connection")
	end

	-- Connect match mode switch
	components.MatchModeSwitch.MouseButton1Click:Connect(function()
		if not hasAutoEnchanterGamepass then
			promptGamepassPurchase()
			return
		end
		matchAnyMode = not matchAnyMode
		local knob = components.MatchModeSwitchKnob
		local sw = components.MatchModeSwitch
		local label = components.MatchModeFrame:FindFirstChild("MatchModeLabel")
		if matchAnyMode then
			sw.BackgroundColor3 = Color3.fromRGB(80, 170, 80)
			TweenService:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = UDim2.new(1, -18, 0.5, -8)}):Play()
			if label then label.Text = "Match Any (OR)" end
		else
			sw.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
			TweenService:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = UDim2.new(0, 2, 0.5, -8)}):Play()
			if label then label.Text = "Match All (AND)" end
		end
	end)
end

function EnchanterController:Show(itemsList)
	-- Check if enchanter is unlocked first
	local success, unlockedFeatures = pcall(function()
		return Remotes.GetUnlockedFeatures:InvokeServer()
	end)
	
	if success and unlockedFeatures then
		local isUnlocked = false
		for _, feature in ipairs(unlockedFeatures) do
			if feature == "Enchanter" then
				isUnlocked = true
				break
			end
		end
		
		if not isUnlocked then
					-- Show locked notification
		local ToastNotificationController = require(script.Parent.ToastNotificationController)
		if ToastNotificationController then
			ToastNotificationController.ShowToast("Enchanter unlocks at Rebirth 4!", "Error")
		end
			return
		end
	end
	
	if not components or type(itemsList) ~= "table" or #itemsList == 0 then return end
	
	availableItems = itemsList
	filteredItems = {}
	for i, item in ipairs(availableItems) do
		table.insert(filteredItems, item)
	end
	selectedItemIndex = 1 -- Start with first item selected
	isVisible = true
	hideOtherUIs(true)
	
	-- Hide the popup by default
	hideItemSelectionPopup()
	
	-- Update the selected item display
	updateSelectedItemDisplay()
	
	-- Initialize auto-enchanting features
	checkGamepassOwnership()
	populateMutatorSelection()
	updateAutoEnchanterUI()
	
	components.MainFrame.Visible = true
	-- Animate the UI appearing
	components.MainFrame.Size = UDim2.new(0, 0, 0, 0)
	components.MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	local showTween = TweenService:Create(
		components.MainFrame,
		TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{
			Size = UDim2.new(0.75, 0, 0.85, 0),
			Position = UDim2.new(0.125, 0, 0.075, 0)
		}
	)
	showTween:Play()
end

function EnchanterController:Hide()
	if not components then return end
	
	isVisible = false
	hideOtherUIs(false)
	hideInfoPopup() -- Hide the info popup
	hideItemSelectionPopup() -- Also hide the item selection popup
	
	-- Stop any ongoing auto-enchanting
	if isAutoEnchanting then
		Remotes.StopAutoEnchanting:FireServer()
	end
	
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
		-- Reset auto-enchanting state
		selectedTargetMutators = {}
		isAutoEnchanting = false
		mutatorCheckboxes = {}
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

-- Handle enchanter visual updates
Remotes.UpdateEnchanterVisual.OnClientEvent:Connect(function(isUnlocked)
	-- Paint EnchantingArea parts
	local enchantingArea = workspace:FindFirstChild("EnchantingArea")
	if enchantingArea then
		if isUnlocked then
			-- Restore from original build
			local originalBuilds = ReplicatedStorage:FindFirstChild("OriginalBuilds")
			if originalBuilds then
				local originalEnchantingArea = originalBuilds:FindFirstChild("EnchantingArea")
				if originalEnchantingArea then
					enchantingArea:ClearAllChildren()
					for _, originalPart in pairs(originalEnchantingArea:GetChildren()) do
						local restoredPart = originalPart:Clone()
						restoredPart.Parent = enchantingArea
					end
					print("[EnchanterController] Restored EnchantingArea from original build (monitor)")
				else
					-- Fallback: restore normal colors
					local function restorePart(part)
						if part:IsA("BasePart") then
							part.Color = Color3.fromRGB(150, 100, 255)
							part.Material = Enum.Material.Neon
							if part:FindFirstChild("PointLight") then
								part.PointLight.Color = Color3.fromRGB(150, 100, 255)
							end
						end
						for _, child in pairs(part:GetChildren()) do
							restorePart(child)
						end
					end
					for _, part in pairs(enchantingArea:GetChildren()) do
						restorePart(part)
					end
				end
			end
		end
		
		print("[EnchanterController] Painted EnchantingArea - Unlocked:", isUnlocked)
	end
end)

-- Debug function to manually recreate ProximityPrompt (for testing)
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.KeyCode == Enum.KeyCode.R and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
		print("[EnchanterController] Debug: Manually recreating Enchanter ProximityPrompt")
		Remotes.RecreateEnchanterPrompt:FireServer()
	end
end)

-- Handle gamepass purchase finished
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamepassId, wasPurchased)
	if gamepassId == GameConfig.AutoEnchanterGamepassId and wasPurchased then
		hasAutoEnchanterGamepass = true
		updateAutoEnchanterUI()
		-- Show celebration effects and notification
		local ToastNotificationController = require(script.Parent.ToastNotificationController)
		if ToastNotificationController then
			ToastNotificationController.ShowToast("Gamepass purchased! Auto-Enchanter is now enabled.", "Success")
		end
		if BoxAnimator then
			BoxAnimator.PlayCelebrationEffect()
		end
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