local AvatarService = {}

local Players = game:GetService("Players")
local InsertService = game:GetService("InsertService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(script.Parent.Parent.Modules.GameConfig)

local equippedAccessories = {} -- [userId] = { [itemType] = { instance, assetId, itemInstance, effectsThread } }

local function applyMutationEffects(asset, itemInstance)
	-- Check for new multiple mutations format first
	local mutationsJson = itemInstance:GetAttribute("Mutations")
	local mutations = {}
	
	if mutationsJson then
		local HttpService = game:GetService("HttpService")
		local success, decodedMutations = pcall(function()
			return HttpService:JSONDecode(mutationsJson)
		end)
		if success and decodedMutations then
			mutations = decodedMutations
		end
	else
		-- Fallback to single mutation for backward compatibility
		local singleMutation = itemInstance:GetAttribute("Mutation")
		if singleMutation then
			mutations = {singleMutation}
		end
	end
	
	if #mutations == 0 then return nil end

	local allParts = {}
	for _, descendant in ipairs(asset:GetDescendants()) do
		if descendant:IsA("BasePart") then
			table.insert(allParts, descendant)
		end
	end

	if #allParts == 0 then return nil end
	
	-- Get the item size for scaling effects
	local itemSize = itemInstance:GetAttribute("Size") or 1
	local sizeMultiplier = math.max(0.5, math.min(itemSize, 10)) -- Clamp between 0.5 and 10 for reasonable scaling
	
	local effects = {}
	local primaryPart = allParts[1] -- Use the first part found for emitters
	
	-- Apply effects for each mutation
	for _, mutationName in ipairs(mutations) do
		local mutationConfig = GameConfig.Mutations[mutationName]
		if mutationConfig then
			if mutationName == "Glowing" then
				local light = Instance.new("PointLight")
				light.Color = mutationConfig.Color or Color3.fromRGB(255, 255, 0)
				light.Brightness = 2 * sizeMultiplier
				light.Range = 12 * sizeMultiplier
				light.Parent = primaryPart
				table.insert(effects, light)

			elseif mutationName == "Shiny" then
				-- Create a bright sparkle effect with attachment
				local attachment = Instance.new("Attachment")
				attachment.Parent = primaryPart
				
				local sparkles = Instance.new("ParticleEmitter")
				sparkles.Parent = attachment
				sparkles.Texture = "http://www.roblox.com/asset/?id=241650934" -- More reliable sparkle texture
				sparkles.Color = ColorSequence.new(mutationConfig.Color or Color3.fromRGB(255, 255, 255))
				sparkles.LightEmission = 1
				sparkles.Size = NumberSequence.new{
					NumberSequenceKeypoint.new(0, 0.1 * sizeMultiplier),
					NumberSequenceKeypoint.new(0.5, 0.3 * sizeMultiplier),
					NumberSequenceKeypoint.new(1, 0)
				}
				sparkles.Transparency = NumberSequence.new{
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(1, 1)
				}
				sparkles.Lifetime = NumberRange.new(0.8, 1.5)
				sparkles.Rate = math.floor(20 * sizeMultiplier)
				sparkles.Speed = NumberRange.new(2 * sizeMultiplier, 5 * sizeMultiplier)
				sparkles.SpreadAngle = Vector2.new(45, 45)
				sparkles.Enabled = true
				table.insert(effects, sparkles)
				table.insert(effects, attachment)

			elseif mutationName == "Rainbow" then
				local thread = coroutine.create(function()
					while task.wait(0.1) do
						local hue = tick() % 5 / 5
						local color = Color3.fromHSV(hue, 1, 1)
						for _, part in ipairs(allParts) do
							part.Color = color
							local specialMesh = part:FindFirstChildOfClass("SpecialMesh")
							if specialMesh then
								specialMesh.VertexColor = Vector3.new(color.r, color.g, color.b)
							end
						end
					end
				end)
				coroutine.resume(thread)
				table.insert(effects, thread) -- Store thread to be stopped later

			elseif mutationName == "Corrupted" then
				-- Create dark purple smoke effect
				local attachment = Instance.new("Attachment")
				attachment.Parent = primaryPart
				
				local smoke = Instance.new("ParticleEmitter")
				smoke.Parent = attachment
				smoke.Texture = "rbxasset://textures/particles/smoke_main.dds" -- Built-in smoke texture
				smoke.Color = ColorSequence.new{
					ColorSequenceKeypoint.new(0, Color3.fromRGB(85, 0, 255)),
					ColorSequenceKeypoint.new(0.5, Color3.fromRGB(50, 0, 150)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 0, 60))
				}
				smoke.LightEmission = 0.2
				smoke.Size = NumberSequence.new{
					NumberSequenceKeypoint.new(0, 0.3 * sizeMultiplier),
					NumberSequenceKeypoint.new(0.5, 1.0 * sizeMultiplier),
					NumberSequenceKeypoint.new(1, 1.5 * sizeMultiplier)
				}
				smoke.Transparency = NumberSequence.new{
					NumberSequenceKeypoint.new(0, 0.3),
					NumberSequenceKeypoint.new(0.7, 0.8),
					NumberSequenceKeypoint.new(1, 1)
				}
				smoke.Lifetime = NumberRange.new(1.5, 3)
				smoke.Rate = math.floor(15 * sizeMultiplier)
				smoke.Speed = NumberRange.new(1 * sizeMultiplier, 3 * sizeMultiplier)
				smoke.SpreadAngle = Vector2.new(30, 30)
				smoke.Drag = 2
				smoke.Enabled = true
				table.insert(effects, smoke)
				table.insert(effects, attachment)
				
			elseif mutationName == "Stellar" then
				local light = Instance.new("PointLight")
				light.Color = Color3.fromRGB(200, 225, 255)
				light.Brightness = 3 * sizeMultiplier
				light.Range = 15 * sizeMultiplier
				light.Parent = primaryPart
				table.insert(effects, light)
				
				-- Create twinkling star effect
				local attachment = Instance.new("Attachment")
				attachment.Parent = primaryPart
				
				local stars = Instance.new("ParticleEmitter")
				stars.Parent = attachment
				stars.Texture = "http://www.roblox.com/asset/?id=241650934" -- Sparkle texture works as stars
				stars.Color = ColorSequence.new{
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
					ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200, 225, 255)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 200, 255))
				}
				stars.LightEmission = 1
				stars.Size = NumberSequence.new{
					NumberSequenceKeypoint.new(0, 0.05 * sizeMultiplier),
					NumberSequenceKeypoint.new(0.5, 0.2 * sizeMultiplier),
					NumberSequenceKeypoint.new(1, 0)
				}
				stars.Transparency = NumberSequence.new{
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.8, 0.5),
					NumberSequenceKeypoint.new(1, 1)
				}
				stars.Lifetime = NumberRange.new(2, 4)
				stars.Rate = math.floor(12 * sizeMultiplier)
				stars.Speed = NumberRange.new(0.5 * sizeMultiplier, 2 * sizeMultiplier)
				stars.SpreadAngle = Vector2.new(60, 60)
				stars.Enabled = true
				table.insert(effects, stars)
				table.insert(effects, attachment)
				
			elseif mutationName == "Quantum" then
				-- Add a quantum glow effect along with the flickering
				local light = Instance.new("PointLight")
				light.Color = Color3.fromRGB(50, 20, 80)
				light.Brightness = 2 * sizeMultiplier
				light.Range = 10 * sizeMultiplier
				light.Parent = primaryPart
				table.insert(effects, light)
				
				-- Create quantum energy particles
				local attachment = Instance.new("Attachment")
				attachment.Parent = primaryPart
				
				local quantum = Instance.new("ParticleEmitter")
				quantum.Parent = attachment
				quantum.Texture = "http://www.roblox.com/asset/?id=241650934"
				quantum.Color = ColorSequence.new{
					ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 50, 150)),
					ColorSequenceKeypoint.new(0.5, Color3.fromRGB(50, 20, 80)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 10, 40))
				}
				quantum.LightEmission = 0.8
				quantum.Size = NumberSequence.new{
					NumberSequenceKeypoint.new(0, 0.1 * sizeMultiplier),
					NumberSequenceKeypoint.new(0.5, 0.15 * sizeMultiplier),
					NumberSequenceKeypoint.new(1, 0)
				}
				quantum.Transparency = NumberSequence.new{
					NumberSequenceKeypoint.new(0, 0.2),
					NumberSequenceKeypoint.new(1, 1)
				}
				quantum.Lifetime = NumberRange.new(0.5, 1.5)
				quantum.Rate = math.floor(25 * sizeMultiplier)
				quantum.Speed = NumberRange.new(1 * sizeMultiplier, 4 * sizeMultiplier)
				quantum.SpreadAngle = Vector2.new(90, 90)
				quantum.Enabled = true
				table.insert(effects, quantum)
				table.insert(effects, attachment)
				
				local thread = coroutine.create(function()
					local originalTransparencies = {}
					for _, part in ipairs(allParts) do
						originalTransparencies[part] = part.Transparency
					end
					
					while task.wait(math.random() * 0.2 + 0.1) do
						local part = allParts[math.random(#allParts)]
						if part then
							part.Transparency = 0.7
							task.wait(0.05)
							part.Transparency = originalTransparencies[part]
						end
					end
				end)
				coroutine.resume(thread)
				table.insert(effects, thread)

			elseif mutationName == "Unknown" then
				-- Create mysterious dark energy swirls
				local attachment = Instance.new("Attachment")
				attachment.Parent = primaryPart
				
				local swirl = Instance.new("ParticleEmitter")
				swirl.Parent = attachment
				swirl.Texture = "rbxasset://textures/particles/smoke_main.dds"
				swirl.Color = ColorSequence.new{
					ColorSequenceKeypoint.new(0, Color3.fromRGB(170, 0, 255)),
					ColorSequenceKeypoint.new(0.5, Color3.fromRGB(85, 0, 127)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
				}
				swirl.LightEmission = 0.3
				swirl.Size = NumberSequence.new{
					NumberSequenceKeypoint.new(0, 0.2 * sizeMultiplier),
					NumberSequenceKeypoint.new(0.5, 0.8 * sizeMultiplier),
					NumberSequenceKeypoint.new(1, 1.2 * sizeMultiplier)
				}
				swirl.Transparency = NumberSequence.new{
					NumberSequenceKeypoint.new(0, 0.2),
					NumberSequenceKeypoint.new(0.5, 0.6),
					NumberSequenceKeypoint.new(1, 1)
				}
				swirl.Lifetime = NumberRange.new(2, 4)
				swirl.Rate = math.floor(8 * sizeMultiplier)
				swirl.Speed = NumberRange.new(0.5 * sizeMultiplier, 2 * sizeMultiplier)
				swirl.SpreadAngle = Vector2.new(20, 20)
				swirl.Drag = 3
				swirl.RotSpeed = NumberRange.new(-180, 180)
				swirl.Enabled = true
				table.insert(effects, swirl)
				table.insert(effects, attachment)
			end
		end
	end

	return effects
end

local function unequipItemOfType(player, itemType)
	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	local userId = player.UserId
	if equippedAccessories[userId] and equippedAccessories[userId][itemType] then
		local data = equippedAccessories[userId][itemType]
		if data.instance then
			data.instance:Destroy()
		end
		-- Disconnect size listener to prevent memory leaks
		if data.sizeConnection then
			data.sizeConnection:Disconnect()
		end
		-- Stop any running coroutines for this item
		if data.effectsThread then
			for _, effect in ipairs(data.effectsThread) do
				if type(effect) == "thread" then
					coroutine.close(effect)
				end
			end
		end
		equippedAccessories[userId][itemType] = nil
	end
	
	-- For legacy clothing, find the specific clothing type and remove it
	for _, child in ipairs(humanoid:GetChildren()) do
		if (itemType == "Shirt" and child:IsA("Shirt")) or
		   (itemType == "Pants" and child:IsA("Pants")) or
		   (itemType == "TShirt" and child:IsA("TShirt")) then
			child:Destroy()
		end
	end
end

function AvatarService.GetEquippedItems(player)
    local equipped = {}
	if equippedAccessories[player.UserId] then
		for itemType, data in pairs(equippedAccessories[player.UserId]) do
			if data and data.itemInstance then
				equipped[itemType] = data.itemInstance
			end
		end
	end
	return equipped
end

function AvatarService.IsItemEquipped(player, itemInstance)
	if equippedAccessories[player.UserId] then
		for itemType, data in pairs(equippedAccessories[player.UserId]) do
			if data and data.itemInstance == itemInstance then
				return true
			end
		end
	end
	return false
end

function AvatarService.GetSerializableEquippedItems(player)
	local equippedData = {}
	if equippedAccessories[player.UserId] then
		for itemType, data in pairs(equippedAccessories[player.UserId]) do
			if data and data.itemInstance then
				-- Save the unique UUID instead of the instance itself
				equippedData[itemType] = data.itemInstance.Name
			end
		end
	end
	return equippedData
end

local function findFirstDescendantOfClass(instance, className)
	for _, descendant in ipairs(instance:GetDescendants()) do
		if descendant:IsA(className) then
			return descendant
		end
	end
	return nil
end

local function setupAccessoryAndEffects(humanoid, accessory, itemConfig, itemInstance)
	local partsToScale = {}
	for _, descendant in ipairs(accessory:GetDescendants()) do
		if descendant:IsA("BasePart") then
			local specialMesh = descendant:FindFirstChildOfClass("SpecialMesh")
			if specialMesh then
				table.insert(partsToScale, { part = specialMesh, originalValue = specialMesh.Scale, isMesh = true })
			else
				table.insert(partsToScale, { part = descendant, originalValue = descendant.Size, isMesh = false })
			end
		end
	end

	if #partsToScale == 0 then
		warn("Cannot find any parts to scale in accessory:", accessory.Name)
		humanoid:AddAccessory(accessory) -- Equip without scaling
		return {
			instance = accessory,
			assetId = itemConfig.AssetId,
			itemInstance = itemInstance,
			effectsThread = applyMutationEffects(accessory, itemInstance),
			sizeConnection = nil,
		}
	end

	local function updateScale()
		local currentSize = itemInstance:GetAttribute("Size") or 1
		for _, data in ipairs(partsToScale) do
			if data.isMesh then
				data.part.Scale = data.originalValue * currentSize
			else
				data.part.Size = data.originalValue * currentSize
			end
		end
	end

	-- Apply initial scale before equipping
	updateScale()
	
	-- Add the pre-scaled accessory to the character
	humanoid:AddAccessory(accessory)

	local sizeConnection = itemInstance:GetAttributeChangedSignal("Size"):Connect(updateScale)
	
	local equippedData = {
		instance = accessory, 
		assetId = itemConfig.AssetId, 
		itemInstance = itemInstance, 
		effectsThread = applyMutationEffects(accessory, itemInstance),
		sizeConnection = sizeConnection
	}
	
	return equippedData
end

function AvatarService.EquipItem(player, itemName, itemInstanceId)
    -- Find the item config using the item name (not the UUID)
    local itemConfig = GameConfig.Items[itemName]
    if not itemConfig or not itemConfig.AssetId or not itemConfig.Type then
        warn("Invalid item config for:", itemName)
        return false
    end
    
    -- Find the specific item instance by UUID
    local inventory = player:FindFirstChild("Inventory")
    local itemInstance = inventory and inventory:FindFirstChild(itemInstanceId)
    if not itemInstance then
        warn("Could not find item instance with UUID:", itemInstanceId)
        return false
    end
    
    -- Verify the item name matches (for safety)
    local storedItemName = itemInstance:GetAttribute("ItemName") or itemInstance.Name
    if storedItemName ~= itemName then
        warn("Item name mismatch. Expected:", itemName, "Got:", storedItemName)
        return false
    end
    
	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if not humanoid then 
		warn("Cannot equip item, humanoid not found for " .. player.Name)
		return false
	end

	-- Unequip any existing item of the same type
	unequipItemOfType(player, itemConfig.Type)

	local success, asset = pcall(function()
		return InsertService:LoadAsset(itemConfig.AssetId)
	end)

	if not success or not asset then
		warn("Failed to load assetId " .. tostring(itemConfig.AssetId) .. " for item " .. itemName)
		return false
	end

	local userId = player.UserId
	if not equippedAccessories[userId] then
		equippedAccessories[userId] = {}
	end

	if asset:IsA("Accessory") then
		equippedAccessories[userId][itemConfig.Type] = setupAccessoryAndEffects(humanoid, asset, itemConfig, itemInstance)
	elseif asset:IsA("Shirt") or asset:IsA("Pants") or asset:IsA("TShirt") then
		asset.Parent = player.Character
		equippedAccessories[userId][itemConfig.Type] = {instance = asset, assetId = itemConfig.AssetId, itemInstance = itemInstance, effectsThread = applyMutationEffects(asset, itemInstance)}
	elseif asset:IsA("Model") then -- Handle cases where UGC is a model
		local accessoryInModel = asset:FindFirstChildOfClass("Accessory")
		if accessoryInModel then
			accessoryInModel.Parent = nil -- Unparent from the temporary model
			equippedAccessories[userId][itemConfig.Type] = setupAccessoryAndEffects(humanoid, accessoryInModel, itemConfig, itemInstance)
			asset:Destroy()
		else
			warn("Model item '" .. itemName .. "' does not contain an Accessory.")
			asset:Destroy() -- Clean up the loaded model
			return false
		end
	else
		warn("Unsupported asset type for item '" .. itemName .. "': " .. asset.ClassName)
		asset:Destroy() -- Clean up
		return false
    end
    
    return true
end

function AvatarService.UnequipItem(player, itemType)
	unequipItemOfType(player, itemType)
    return true
end

function AvatarService.OnPlayerAdded(player)
    equippedAccessories[player.UserId] = {}
    
    player.CharacterAdded:Connect(function(character)
		-- When a character respawns, re-apply any accessories they had
		local humanoid = character:WaitForChild("Humanoid", 10)
		if not humanoid then return end
		
		-- Wait a moment for character to be set up
        task.wait(1) 

		-- Re-equip any items from previous life
		local playerEquipped = equippedAccessories[player.UserId]
		if playerEquipped then
			for itemType, data in pairs(playerEquipped) do
				if data and data.itemInstance and data.itemInstance.Parent then
					-- Get the actual item name and re-equip using UUID system
					local itemName = data.itemInstance:GetAttribute("ItemName") or data.itemInstance.Name
					local itemUUID = data.itemInstance.Name
					AvatarService.EquipItem(player, itemName, itemUUID)
				end
			end
		end
    end)
end

function AvatarService.OnPlayerRemoving(player)
    if equippedAccessories[player.UserId] then
        for _, data in pairs(equippedAccessories[player.UserId]) do
            if data.instance then
                data.instance:Destroy()
            end
        end
    end
    equippedAccessories[player.UserId] = nil
end

-- Initialize for players already in game
for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(AvatarService.OnPlayerAdded, player)
end

Players.PlayerAdded:Connect(AvatarService.OnPlayerAdded)
Players.PlayerRemoving:Connect(AvatarService.OnPlayerRemoving)

return AvatarService 