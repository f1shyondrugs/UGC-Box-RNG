local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local Shared = ReplicatedStorage.Shared
local GameConfig = require(Shared.Modules.GameConfig)
local Remotes = require(Shared.Remotes.Remotes)
local ItemValueCalculator = require(Shared.Modules.ItemValueCalculator)

local EnchanterService = {}

-- Import PlayerDataService for saving data
local PlayerDataService = require(script.Parent.PlayerDataService)

-- Helper function to calculate a single item's value
local function calculateSingleItemValue(itemInstance, itemConfig)
	local mutationConfigs = ItemValueCalculator.GetMutationConfigs(itemInstance)
	local size = itemInstance:GetAttribute("Size") or 1
	return ItemValueCalculator.GetValue(itemConfig, mutationConfigs, size)
end

-- Handle ProximityPrompt trigger
local function onEnchanterPromptTriggered(player, promptPart)
	-- Check if player has an inventory
	local inventory = player:FindFirstChild("Inventory")
	if not inventory then
		Remotes.Notify:FireClient(player, "Inventory not found.", "Error")
		return
	end
	
	-- Get all items from inventory
	local availableItems = {}
	for _, itemInstance in pairs(inventory:GetChildren()) do
		if itemInstance:IsA("StringValue") then
			local itemName = itemInstance:GetAttribute("ItemName") or itemInstance.Name
			local itemConfig = GameConfig.Items[itemName]
			if itemConfig then
				table.insert(availableItems, {
					itemName = itemName,
					itemConfig = itemConfig,
					itemInstance = itemInstance,
					value = calculateSingleItemValue(itemInstance, itemConfig)
				})
			end
		end
	end
	
	if #availableItems == 0 then
		Remotes.Notify:FireClient(player, "You need at least one item to use the Enchanter!", "Error")
		return
	end
	
	-- Open the enchanter GUI with all available items
	Remotes.OpenEnchanter:FireClient(player, availableItems)
end

-- Get enchanter data for a specific item
local function getEnchanterData(player, itemInstance)
	local inventory = player:FindFirstChild("Inventory")
	if not inventory or not itemInstance or itemInstance.Parent ~= inventory then
		warn("Player " .. player.Name .. " tried to get enchanter data for invalid item.")
		return nil
	end
	
	-- Get item information
	local itemName = itemInstance:GetAttribute("ItemName") or itemInstance.Name
	local itemConfig = GameConfig.Items[itemName]
	if not itemConfig then
		warn("Item config not found for: " .. itemName)
		return nil
	end
	
	return {
		itemName = itemName,
		itemConfig = itemConfig,
		itemInstance = itemInstance
	}
end

-- Reroll mutators for an item
local function rerollMutators(player, itemInstance)
	local inventory = player:FindFirstChild("Inventory")
	if not inventory or not itemInstance or itemInstance.Parent ~= inventory then
		warn("Player " .. player.Name .. " tried to reroll mutators for invalid item.")
		return
	end
	
	-- Get item information
	local itemName = itemInstance:GetAttribute("ItemName") or itemInstance.Name
	local itemConfig = GameConfig.Items[itemName]
	if not itemConfig then
		warn("Item config not found for: " .. itemName)
		return
	end
	
	-- Use item value as reroll cost
	local cost = calculateSingleItemValue(itemInstance, itemConfig)
	local currentRobux = player:GetAttribute("RobuxValue") or 0
	
	if currentRobux < cost then
		Remotes.Notify:FireClient(player, "You don't have enough R$ to reroll this item's mutators! Cost: " .. cost, "Error")
		return
	end
	
	-- Deduct money
	PlayerDataService.UpdatePlayerRobux(player, currentRobux - cost)
	
	-- Generate new mutators using the same system as box opening
	local newMutations = {}
	
	-- Create a sorted list of mutations, rarest first (same as in BoxService)
	local sortedMutations = {}
	for name, data in pairs(GameConfig.Mutations) do
		table.insert(sortedMutations, {name = name, chance = data.Chance})
	end
	table.sort(sortedMutations, function(a, b)
		return a.chance < b.chance
	end)

	-- Roll for each mutation independently - items can get multiple mutations
	for _, mutationInfo in ipairs(sortedMutations) do
		-- Roll a decimal between 0 and 100 to support fractional chances
		local roll = math.random() * 100
		if roll <= mutationInfo.chance then
			table.insert(newMutations, mutationInfo.name)
		end
	end
	
	-- Apply new mutations to item
	if #newMutations > 0 then
		-- Store mutations as a JSON string to support multiple mutations
		itemInstance:SetAttribute("Mutations", HttpService:JSONEncode(newMutations))
		-- Also store first mutation for backward compatibility
		itemInstance:SetAttribute("Mutation", newMutations[1])
	else
		-- Remove mutations if none rolled
		itemInstance:SetAttribute("Mutations", nil)
		itemInstance:SetAttribute("Mutation", nil)
	end
	
	-- Update player's RAP since item value may have changed
	PlayerDataService.UpdatePlayerRAP(player)
	
	-- Save player data
	PlayerDataService.Save(player)
	
	-- Notify player of success
	if #newMutations > 0 then
		local mutationText = table.concat(newMutations, ", ")
		Remotes.Notify:FireClient(player, "✨ Mutators rerolled! New mutators: " .. mutationText, "Success")
	else
		Remotes.Notify:FireClient(player, "Mutators rerolled! No new mutators this time.", "Info")
	end
	
	-- Close the enchanter GUI and reopen with updated item
	task.wait(0.5) -- Small delay to let the notification show
	Remotes.OpenEnchanter:FireClient(player, itemInstance)
end

-- Get mutator probabilities for info display
local function getMutatorProbabilities(player)
	-- Return a copy of the mutations table for client display
	local probabilities = {}
	for mutatorName, mutatorConfig in pairs(GameConfig.Mutations) do
		probabilities[mutatorName] = {
			Chance = mutatorConfig.Chance,
			ValueMultiplier = mutatorConfig.ValueMultiplier,
			Color = mutatorConfig.Color
		}
	end
	return probabilities
end

-- Setup the ProximityPrompt in the workspace
local function setupEnchanterPrompt()
	-- Create ProximityPrompts folder if it doesn't exist
	local promptsFolder = workspace:FindFirstChild("ProximityPrompts")
	if not promptsFolder then
		promptsFolder = Instance.new("Folder")
		promptsFolder.Name = "ProximityPrompts"
		promptsFolder.Parent = workspace
	end
	
	-- Check if EnchanterMain already exists
	local enchanterMain = promptsFolder:FindFirstChild("EnchanterMain")
	if not enchanterMain then
		-- Create the EnchanterMain part
		enchanterMain = Instance.new("Part")
		enchanterMain.Name = "EnchanterMain"
		enchanterMain.Size = Vector3.new(6, 8, 6)
		enchanterMain.Position = Vector3.new(25, 4, 0) -- Position it somewhere in the world
		enchanterMain.Anchored = true
		enchanterMain.Material = Enum.Material.Neon
		enchanterMain.Color = Color3.fromRGB(150, 100, 255) -- Purple color for enchanter
		enchanterMain.Shape = Enum.PartType.Block
		enchanterMain.Parent = promptsFolder
		
		-- Add a glowing effect
		local pointLight = Instance.new("PointLight")
		pointLight.Color = Color3.fromRGB(150, 100, 255)
		pointLight.Brightness = 2
		pointLight.Range = 15
		pointLight.Parent = enchanterMain
	end
	
	-- Create or update the ProximityPrompt
	local existingPrompt = enchanterMain:FindFirstChildOfClass("ProximityPrompt")
	if existingPrompt then
		existingPrompt:Destroy()
	end
	
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Use Enchanter"
	prompt.ObjectText = "Item Enchanter"
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.RequiresLineOfSight = false
	prompt.MaxActivationDistance = 8
	prompt.Parent = enchanterMain
	
	-- Connect the prompt trigger
	prompt.Triggered:Connect(function(player)
		onEnchanterPromptTriggered(player, enchanterMain)
	end)
	
	print("[EnchanterService] Enchanter ProximityPrompt setup at position:", enchanterMain.Position)
end

function EnchanterService.Start()
	-- Setup the ProximityPrompt
	setupEnchanterPrompt()
	
	-- Connect remote events
	Remotes.GetEnchanterData.OnServerInvoke = getEnchanterData
	Remotes.RerollMutators.OnServerEvent:Connect(rerollMutators)
	Remotes.GetMutatorProbabilities.OnServerInvoke = getMutatorProbabilities
	
	print("[EnchanterService] Started successfully!")
end

return EnchanterService 