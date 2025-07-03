local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.Modules.GameConfig)
local ItemValueCalculator = require(ReplicatedStorage.Shared.Modules.ItemValueCalculator)
local CameraShaker = require(script.Parent.CameraShaker)

local BoxAnimator = {}

-- Reference to settings controller (will be set from main client)
local settingsController = nil

-- Helper function to properly color any BasePart (including UnionParts)
local function setPartColor(part, color, useLight)
	-- Enable UsePartColor for UnionOperations
	if part:IsA("UnionOperation") then
		part.UsePartColor = true
	end
	
	-- Try to set the direct color first
	local success, error = pcall(function()
		part.Color = color
	end)
	
	-- If direct color setting failed or we want enhanced lighting effects
	if not success or useLight then
		-- Create or update a colored light for visual effect
		local existingLight = part:FindFirstChild("ColorLight")
		if not existingLight then
			existingLight = Instance.new("PointLight")
			existingLight.Name = "ColorLight"
			existingLight.Range = 8
			existingLight.Brightness = 1.5
			existingLight.Parent = part
		end
		existingLight.Color = color
		
		-- Also try to set the material to Neon for better color visibility
		pcall(function()
			part.Material = Enum.Material.Neon
		end)
	end
end

-- Helper function to create a color tween that works with any BasePart
local function createColorTween(part, tweenInfo, targetColor, useLight)
	-- Enable UsePartColor for UnionOperations
	if part:IsA("UnionOperation") then
		part.UsePartColor = true
	end
	
	if useLight or part:IsA("UnionOperation") then
		-- For UnionParts or when we want enhanced effects, use lighting
		local light = part:FindFirstChild("ColorLight")
		if not light then
			light = Instance.new("PointLight")
			light.Name = "ColorLight"
			light.Range = 8
			light.Brightness = 0
			light.Parent = part
		end
		
		-- Set material for better effect
		pcall(function()
			part.Material = Enum.Material.Neon
		end)
		
		-- Tween the light color and brightness
		local lightTween = TweenService:Create(light, tweenInfo, {
			Color = targetColor,
			Brightness = 1.5
		})
		
		-- Also try to tween the part color directly as backup
		local colorTween = TweenService:Create(part, tweenInfo, {Color = targetColor})
		
		-- Play both tweens
		lightTween:Play()
		colorTween:Play()
		
		return lightTween -- Return the light tween as primary
	else
		-- For regular Parts, use normal color tweening
		return TweenService:Create(part, tweenInfo, {Color = targetColor})
	end
end

-- Set reference to settings controller
function BoxAnimator.SetSettingsController(settings)
	settingsController = settings
end

-- Check if effects are disabled
local function areEffectsDisabled()
	return settingsController and settingsController.AreEffectsDisabled() or false
end

function BoxAnimator.PlayAddictiveAnimation(boxPart, itemConfig, mutationNames, mutationConfigs, size, soundController, isOwnCrate)
	-- Skip animation if effects are disabled
	if areEffectsDisabled() then
		return 0.1 -- Return minimal duration
	end
	
	-- Default to own crate if not specified (backwards compatibility)
	if isOwnCrate == nil then
		isOwnCrate = true
	end
	
	-- Check for special mutations in the array
	local isShiny = false
	local isRainbow = false
	for _, mutationName in ipairs(mutationNames or {}) do
		if mutationName == "Shiny" then
			isShiny = true
		elseif mutationName == "Rainbow" then
			isRainbow = true
		end
	end
	
	size = size or 1 -- Default size to 1 if nil

	-- New, more impactful scaling logic
	local scaleMultiplier = 1 + math.log(size) / 2
	local scaleUpDuration = 0.5 + size / 20 -- Increased duration for more impact

	-- Calculate duration first, accounting for the faster pulse animation
	local actualScaleDuration = scaleUpDuration * 0.5
	local duration = actualScaleDuration + 0.5 -- Short pause after combined animation
	local rarities = {"Common", "Uncommon", "Rare", "Epic", "Legendary"}
	for i, rarityName in ipairs(rarities) do
		duration = duration + 0.4 -- Lengthened from 0.2
		if rarityName == itemConfig.Rarity then
			break
		end
	end
	duration = duration + 0.2 -- Pause after rarity cycle
	if mutationConfigs and #mutationConfigs > 0 then
		duration = duration + 0.4 -- Mutation flash
	end

	-- Run animation in a coroutine
	task.spawn(function()
		local light, shineGui, shinyParticles, rotationTween, glowTween
		local particleEmitter = Instance.new("ParticleEmitter")
		particleEmitter.Rate = 0
		particleEmitter.Lifetime = NumberRange.new(0.5, 1.5)
		particleEmitter.Speed = NumberRange.new(8, 15)
		particleEmitter.SpreadAngle = Vector2.new(360, 360)
		particleEmitter.Parent = boxPart

		-- Create shiny-exclusive effects FIRST if needed
		if isShiny then
			light = Instance.new("PointLight")
			light.Brightness = 0
			light.Range = 15
			light.Color = Color3.fromRGB(255, 255, 150)
			light.Parent = boxPart

			shineGui = Instance.new("BillboardGui")
			shineGui.Adornee = boxPart
			shineGui.Size = UDim2.fromScale(12, 12)
			shineGui.AlwaysOnTop = true
			
			local shineImage = Instance.new("ImageLabel")
			shineImage.Image = "rbxassetid://253415113"
			shineImage.BackgroundTransparency = 1
			shineImage.Size = UDim2.fromScale(1, 1)
			shineImage.ImageColor3 = Color3.fromRGB(255, 255, 100)
			shineImage.Parent = shineGui
			
			rotationTween = TweenService:Create(shineImage, TweenInfo.new(8, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {Rotation = 360})
			
			shineGui.Parent = boxPart
			
			shinyParticles = Instance.new("ParticleEmitter")
			shinyParticles.Texture = "rbxassetid://6227289435"
			shinyParticles.Color = ColorSequence.new(Color3.fromRGB(255, 255, 127))
			shinyParticles.LightEmission = 1
			shinyParticles.Lifetime = NumberRange.new(1.5, 3)
			shinyParticles.Speed = NumberRange.new(1, 3)
			shinyParticles.SpreadAngle = Vector2.new(360, 360)
			shinyParticles.Rate = 25
			shinyParticles.Parent = boxPart
			
			glowTween = TweenService:Create(light, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Brightness = 12})
		end
		
		local rainbowTween
		if isRainbow then
			rainbowTween = coroutine.create(function()
				while true do
					local hue = tick() % 5 / 5
					setPartColor(boxPart, Color3.fromHSV(hue, 1, 1), true)
					task.wait(0.1)
				end
			end)
			coroutine.resume(rainbowTween)
		end
		
		-- Combined shaking and scaling animation (for ALL boxes)
		local shakeTween = TweenService:Create(boxPart, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Orientation = Vector3.new(5, 5, 5)})
		shakeTween:Play()

		if isShiny then
			rotationTween:Play()
			glowTween:Play()
		end

		-- Gradual "pulsing" scale-up animation
		local pulses = 1 + math.floor(math.log(size) * 1.5)
		local pulseDuration = (scaleUpDuration / pulses) * 0.5 -- Make each pulse 50% faster
		local startSize = boxPart.Size
		local finalSize = boxPart.Size * scaleMultiplier
		local sizeStep = (finalSize - startSize) / pulses

		for i = 1, pulses do
			local pulseTargetSize = startSize + sizeStep * i
			local tweenUp = TweenService:Create(boxPart, TweenInfo.new(pulseDuration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = pulseTargetSize})
			if size >= 2.5 and isOwnCrate then
				-- Only shake camera for own crates to avoid disrupting other players
				CameraShaker.Shake(pulseDuration + 0.2, 0.05 + (size / 250) * (i / pulses))
			end
			soundController:playGrowingBox() -- Play growing sound
			tweenUp:Play()
			task.wait(pulseDuration)
		end
		
		soundController:stopGrowingBox() -- Stop growing sound
		task.wait(actualScaleDuration) 
		task.wait(0.2) -- Short pause after animation

		-- STAGE 2: Rarity Roulette
		local finalRarityIndex = 0
		for i, rarityName in ipairs(rarities) do
			if rarityName == itemConfig.Rarity then
				finalRarityIndex = i
				break
			end
		end

		for i = 1, finalRarityIndex do
			local rarityName = rarities[i]
			local color = GameConfig.Rarities[rarityName].Color
			local isFinalRarity = (i == finalRarityIndex)
			
			local flashDuration = 0.3
			local waitDuration = 0.4 - (i * 0.05) -- Gets faster
			if isFinalRarity then
				waitDuration = 0.6 -- Pause on the final color
			end

			-- Don't override rainbow color during rarity roulette
			if not isRainbow then
				local colorTween = createColorTween(boxPart, TweenInfo.new(flashDuration), color, true)
				colorTween:Play()
			end
			
			-- Only shake camera for own crates
			if isOwnCrate then
			CameraShaker.Shake(flashDuration, 0.1 + (i * 0.05))
			end
			
			local genericParticles = Instance.new("ParticleEmitter")
			genericParticles.Rate = 0
			genericParticles.Lifetime = NumberRange.new(0.5, 1.5)
			genericParticles.Speed = NumberRange.new(8, 15)
			genericParticles.SpreadAngle = Vector2.new(360, 360)
			genericParticles.Color = ColorSequence.new(color)
			genericParticles.Parent = boxPart
			genericParticles:Emit(15 + i*5)
			Debris:AddItem(genericParticles, 2)
	
			if isShiny then light.Color = color end
			task.wait(waitDuration)
		end
		
		task.wait(0.2)
	
		if mutationConfigs and #mutationConfigs > 0 then
			if size >= 2.5 and isOwnCrate then
				-- Only shake camera for own crates during mutation effects
				CameraShaker.Shake(0.5 + size / 100, 0.4 + size / 80)
			end
			if isShiny then
				light.Color = mutationConfigs[1].Color
			end
			
			local mutationParticles = Instance.new("ParticleEmitter")
			mutationParticles.Rate = 0
			mutationParticles.Lifetime = NumberRange.new(0.5, 1.5)
			mutationParticles.Speed = NumberRange.new(8, 15)
			mutationParticles.SpreadAngle = Vector2.new(360, 360)
			mutationParticles.Color = ColorSequence.new(mutationConfigs[1].Color)
			mutationParticles.Parent = boxPart
			mutationParticles:Emit(50)
			Debris:AddItem(mutationParticles, 2)
	
			-- Don't override rainbow color during mutation flash
			if not isRainbow then
				local mutationFlash = createColorTween(boxPart, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 5, true), mutationConfigs[1].Color, true)
				mutationFlash:Play()
				task.wait(0.4)
				mutationFlash:Cancel()
			else
				task.wait(0.4) -- Still wait for the same duration
			end
		end
		
		shakeTween:Cancel()
		if glowTween then glowTween:Cancel() end
		if rotationTween then rotationTween:Cancel() end
		if rainbowTween then coroutine.close(rainbowTween) end
		
		-- STAGE 3: The Launch & Explosion
		local launchPos = boxPart.Position + Vector3.new(0, 6, 0)
		local launchTween = TweenService:Create(boxPart, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = launchPos})
		launchTween:Play()
		launchTween.Completed:Wait()

		task.wait(0.1) -- Hang time

		-- Only do the big explosion shake for own crates
		if isOwnCrate then
		CameraShaker.Shake(0.5, 1.2) -- The big explosion shake!
		end

		if isShiny then
			light.Brightness = 100
			light.Range = 50
			Debris:AddItem(light, 1)
			Debris:AddItem(shineGui, 1)
		end
	
		local explosionColor = (mutationConfigs and mutationConfigs[1] and mutationConfigs[1].Color) or GameConfig.Rarities[itemConfig.Rarity].Color
		particleEmitter.Color = ColorSequence.new(explosionColor)
		particleEmitter:Emit(250)
		
		boxPart.Transparency = 1 -- Vanish within the explosion
		
		-- Clean up the ColorLight if it exists
		local colorLight = boxPart:FindFirstChild("ColorLight")
		if colorLight then
			colorLight:Destroy()
		end
	end)

	-- Recalculate duration to match new sequence
	local duration = actualScaleDuration + 2.5 -- Base time for rarity cycle
	if mutationConfigs and #mutationConfigs > 0 then duration = duration + 0.4 end
	duration = duration + 0.3 -- Launch and explosion time
	
	return duration
end

function BoxAnimator.AnimateFloatingText(position, itemName, itemConfig, mutationNames, mutationConfigs, size, soundController, isOwnCrate)
	-- Skip animation if effects are disabled
	if areEffectsDisabled() then
		return -- Exit early
	end
	
	-- Default to own crate if not specified (backwards compatibility)
	if isOwnCrate == nil then
		isOwnCrate = true
	end
	
	size = size or 1 -- Default size to 1 if nil
	local rarityName = itemConfig.Rarity
	local rarityConfig = GameConfig.Rarities[rarityName]
	
	-- Check for Rainbow mutation
	local hasRainbow = false
	if mutationNames then
		for _, mutationName in ipairs(mutationNames) do
			if mutationName == "Rainbow" then
				hasRainbow = true
				break
			end
		end
	end
	
	-- Constructing the enhanced text with item focus
	local itemDisplayName = itemName
	
	-- Build mutation prefix if any
	local mutationText = ""
	if mutationNames and #mutationNames > 0 then
		local mutationIcons = {
			["Shiny"] = "✨",
			["Glowing"] = "💡", 
			["Rainbow"] = "🌈",
			["Corrupted"] = "🔮",
			["Stellar"] = "⭐",
			["Quantum"] = "🌀",
			["Unknown"] = "❓"
		}
		
		local mutationParts = {}
		for _, mutationName in ipairs(mutationNames) do
			local icon = mutationIcons[mutationName] or "•"
			table.insert(mutationParts, icon .. " " .. mutationName)
		end
		mutationText = table.concat(mutationParts, " ")
		itemDisplayName = mutationText .. " " .. itemName
	end
	
	local valueText = ItemValueCalculator.GetFormattedValue(itemConfig, mutationConfigs, size)
	local typeText = itemConfig.Type or "UGC Item"

	-- Enhanced format showing item as a complete entity with rarity-specific styling
	local rarityEmojis = {
		Common = "⚪",
		Uncommon = "🟢", 
		Rare = "🔵",
		Epic = "🟣",
		Legendary = "🟠",
		Mythical = "🟡",
		Celestial = "🔷",
		Divine = "✨",
		Transcendent = "🌟",
		Ethereal = "💫",
		Quantum = "🌀"
	}
	
	local rarityEmoji = rarityEmojis[rarityName] or "⚫"
	local itemTypeEmoji = "📦" -- Default item emoji
	
	-- Special item type emojis based on type
	if typeText == "Hat" then
		itemTypeEmoji = "🎩"
	elseif typeText == "Shirt" then
		itemTypeEmoji = "👕"
	elseif typeText == "Pants" then
		itemTypeEmoji = "👖"
	elseif typeText == "Shoes" then
		itemTypeEmoji = "👟"
	elseif typeText == "Face" then
		itemTypeEmoji = "😎"
	elseif typeText == "Back" then
		itemTypeEmoji = "🎒"
	elseif typeText == "Front" then
		itemTypeEmoji = "⚔️"
	elseif typeText == "Shoulders" then
		itemTypeEmoji = "🛡️"
	end
	
	local fullText
	if isOwnCrate then
		fullText = string.format("═══ %s ═══\n💰 %s • 📏 %.2fx", 
		itemDisplayName,
		valueText,
		size
	)
	else
		-- For other players' crates, show a more subtle format without full stats
		fullText = string.format("👁️ %s", itemDisplayName)
	end
	
	-- Determine color and size
	local textColor = (mutationConfigs and mutationConfigs[1] and mutationConfigs[1].Color) or rarityConfig.Color
	
	local raritySizeMap = {
		Common = 18,
		Uncommon = 22,
		Rare = 26,
		Epic = 32,
		Legendary = 38,
		Mythical = 44,
		Celestial = 50,
		Divine = 56,
		Transcendent = 62,
		Ethereal = 68,
		Quantum = 74,
	}
	local baseSize = raritySizeMap[rarityName] or 28
	
	-- Apply multipliers for size and mutation
	local sizeMultiplier = 1 + math.log(size) / 2.5
	local mutationMultiplier = (mutationNames and #mutationNames > 0) and (1.2 + (#mutationNames - 1) * 0.1) or 1
	
	-- Reduce size for other players' crates to be less intrusive
	local otherPlayerMultiplier = isOwnCrate and 1 or 0.6
	
	-- Apply floating text size setting
	local textSizeMultiplier = 1.0
	if settingsController and settingsController.GetFloatingTextSize then
		textSizeMultiplier = settingsController.GetFloatingTextSize()
	end
	
	local finalSize = baseSize * sizeMultiplier * mutationMultiplier * otherPlayerMultiplier * textSizeMultiplier

	if size >= 2.5 and isOwnCrate then
		-- Only shake camera for own crates during floating text
		local shakeStrength = math.clamp((size - 2.5) / 50, 0.1, 2)
		CameraShaker.Shake(0.7 + shakeStrength, shakeStrength)
	end

	-- Create the actual UGC item display
	local itemModel = Instance.new("Model")
	itemModel.Name = "FloatingItem"
	itemModel.Parent = workspace
	
	local itemPart = Instance.new("Part")
	itemPart.Name = "ItemPart"
	itemPart.Anchored = true
	itemPart.CanCollide = false
	itemPart.Size = Vector3.new(2, 2, 2) * size * textSizeMultiplier -- Apply size and text size scaling
	itemPart.Position = position + Vector3.new(0, 3, 0) -- Start slightly above the box
	itemPart.Shape = Enum.PartType.Block
	itemPart.Material = Enum.Material.Neon
	itemPart.Color = textColor
	itemPart.Parent = itemModel
	
	-- Get the preloaded UGC item from ReplicatedStorage
	local displayPart = itemPart -- Default to our created part
	local actualUGCItem = nil
	
	-- Try to get preloaded UGC item
	local ugcFolder = game.ReplicatedStorage:FindFirstChild("PreloadedUGC")
	local preloadedItem = ugcFolder and ugcFolder:FindFirstChild(itemName)
	
	if preloadedItem then
		-- Clone the preloaded UGC item
		actualUGCItem = preloadedItem:Clone()
		actualUGCItem.Parent = itemModel
		
		local handle = actualUGCItem:FindFirstChild("Handle")
		if handle then
			handle.Anchored = true
			handle.CanCollide = false
			handle.Position = itemPart.Position
			
			-- Scale the handle properly
			if handle:FindFirstChild("Mesh") or handle:FindFirstChild("SpecialMesh") then
				local mesh = handle:FindFirstChild("Mesh") or handle:FindFirstChild("SpecialMesh")
				if mesh then
					mesh.Scale = mesh.Scale * size * textSizeMultiplier
				end
			else
				handle.Size = handle.Size * size * textSizeMultiplier
			end
			
			displayPart = handle
			itemPart.Transparency = 1 -- Hide the default part
		else
			-- Fallback if no handle found
			warn("Preloaded UGC item has no Handle:", itemName)
		end
	else
		-- Fallback: create item-type specific visual representations
		print("No preloaded UGC found for:", itemName, "- creating fallback visual")
		
		-- Create enhanced item-type specific visual representations
		local itemType = itemConfig.Type or "UGC Item"
		itemPart.Material = Enum.Material.Plastic
		itemPart.Color = textColor
		
		-- Combined scaling for fallback items
		local combinedScale = size * textSizeMultiplier
		
		if itemType == "Hat" then
			-- Create a hat-like shape with multiple parts
			itemPart.Shape = Enum.PartType.Cylinder
			itemPart.Size = Vector3.new(0.3, 1.8, 1.8) * combinedScale
			itemPart.CFrame = CFrame.new(itemPart.Position) * CFrame.Angles(math.rad(90), 0, 0)
			
			-- Add a brim
			local brim = Instance.new("Part")
			brim.Shape = Enum.PartType.Cylinder
			brim.Size = Vector3.new(0.1, 2.2, 2.2) * combinedScale
			brim.Position = itemPart.Position + Vector3.new(0, -0.2 * combinedScale, 0)
			brim.CFrame = CFrame.new(brim.Position) * CFrame.Angles(math.rad(90), 0, 0)
			brim.Material = Enum.Material.Plastic
			brim.Color = textColor
			brim.Anchored = true
			brim.CanCollide = false
			brim.Parent = itemModel
			
		elseif itemType == "Shirt" then
			-- Create a shirt-like shape with sleeves
			itemPart.Shape = Enum.PartType.Block
			itemPart.Size = Vector3.new(2.2, 2.8, 0.8) * combinedScale
			
			-- Add sleeves
			for i = -1, 1, 2 do
				local sleeve = Instance.new("Part")
				sleeve.Shape = Enum.PartType.Block
				sleeve.Size = Vector3.new(0.6, 1.5, 0.6) * combinedScale
				sleeve.Position = itemPart.Position + Vector3.new(i * 1.4 * combinedScale, 0.3 * combinedScale, 0)
				sleeve.Material = Enum.Material.Plastic
				sleeve.Color = textColor
				sleeve.Anchored = true
				sleeve.CanCollide = false
				sleeve.Parent = itemModel
			end
			
		elseif itemType == "Pants" then
			-- Create pants with legs
			itemPart.Shape = Enum.PartType.Block
			itemPart.Size = Vector3.new(2, 1.5, 1) * combinedScale
			
			-- Add legs
			for i = -1, 1, 2 do
				local leg = Instance.new("Part")
				leg.Shape = Enum.PartType.Block
				leg.Size = Vector3.new(0.8, 2, 0.8) * combinedScale
				leg.Position = itemPart.Position + Vector3.new(i * 0.6 * combinedScale, -1.75 * combinedScale, 0)
				leg.Material = Enum.Material.Plastic
				leg.Color = textColor
				leg.Anchored = true
				leg.CanCollide = false
				leg.Parent = itemModel
			end
			
		elseif itemType == "Shoes" then
			-- Create a pair of shoes
			for i = -1, 1, 2 do
				local shoe = Instance.new("Part")
				shoe.Shape = Enum.PartType.Block
				shoe.Size = Vector3.new(1.2, 0.6, 2.5) * combinedScale
				shoe.Position = itemPart.Position + Vector3.new(i * 0.7 * combinedScale, 0, 0)
				shoe.Material = Enum.Material.Plastic
				shoe.Color = textColor
				shoe.Anchored = true
				shoe.CanCollide = false
				shoe.Parent = itemModel
			end
			itemPart.Transparency = 1 -- Hide the main part
			
		elseif itemType == "Face" then
			-- Create glasses/face accessory
			itemPart.Shape = Enum.PartType.Block
			itemPart.Size = Vector3.new(2, 0.4, 0.6) * combinedScale
			
			-- Add lenses
			for i = -1, 1, 2 do
				local lens = Instance.new("Part")
				lens.Shape = Enum.PartType.Ball
				lens.Size = Vector3.new(0.6, 0.6, 0.2) * combinedScale
				lens.Position = itemPart.Position + Vector3.new(i * 0.5 * combinedScale, 0, 0.2 * combinedScale)
				lens.Material = Enum.Material.Neon
				lens.Color = textColor
				lens.Transparency = 0.3
				lens.Anchored = true
				lens.CanCollide = false
				lens.Parent = itemModel
			end
			
		elseif itemType == "Back" then
			-- Create a backpack
			itemPart.Shape = Enum.PartType.Block
			itemPart.Size = Vector3.new(1.8, 2.2, 1.2) * combinedScale
			
			-- Add straps
			for i = -1, 1, 2 do
				local strap = Instance.new("Part")
				strap.Shape = Enum.PartType.Block
				strap.Size = Vector3.new(0.2, 1.5, 0.2) * combinedScale
				strap.Position = itemPart.Position + Vector3.new(i * 0.6 * combinedScale, 0.5 * combinedScale, -0.7 * combinedScale)
				strap.Material = Enum.Material.Plastic
				strap.Color = textColor
				strap.Anchored = true
				strap.CanCollide = false
				strap.Parent = itemModel
			end
			
		elseif itemType == "Front" then
			-- Create a tool/weapon
			itemPart.Shape = Enum.PartType.Block
			itemPart.Size = Vector3.new(0.4, 2.5, 0.4) * combinedScale
			
			-- Add a blade/head
			local head = Instance.new("Part")
			head.Shape = Enum.PartType.Wedge
			head.Size = Vector3.new(0.6, 1, 0.6) * combinedScale
			head.Position = itemPart.Position + Vector3.new(0, 1.75 * combinedScale, 0)
			head.Material = Enum.Material.Plastic
			head.Color = textColor
			head.Anchored = true
			head.CanCollide = false
			head.Parent = itemModel
			
		else
			-- Enhanced default shape
			itemPart.Shape = Enum.PartType.Ball
			itemPart.Material = Enum.Material.Neon
			
			-- Add some orbiting particles
			local orbit = Instance.new("Part")
			orbit.Shape = Enum.PartType.Ball
			orbit.Size = Vector3.new(0.2, 0.2, 0.2) * combinedScale
			orbit.Position = itemPart.Position + Vector3.new(1.5 * combinedScale, 0, 0)
			orbit.Material = Enum.Material.Neon
			orbit.Color = textColor
			orbit.Anchored = true
			orbit.CanCollide = false
			orbit.Parent = itemModel
		end
		
		displayPart = itemPart
	end
	
	-- Apply REAL mutation effects to ALL parts of the item
	local function applyMutationToAllParts(mutation, itemObject)
		-- Get all parts of the item (UGC accessory or fallback parts)
		local partsToModify = {}
		
		if actualUGCItem then
			-- For real UGC items, modify all BaseParts in the accessory
			for _, descendant in pairs(actualUGCItem:GetDescendants()) do
				if descendant:IsA("BasePart") then
					table.insert(partsToModify, descendant)
				end
			end
		else
			-- For fallback items, modify all parts in the item model
			for _, child in pairs(itemModel:GetChildren()) do
				if child:IsA("BasePart") then
					table.insert(partsToModify, child)
				end
			end
		end
		
		-- Apply the mutation effect to all parts
		for _, part in pairs(partsToModify) do
			if mutation == "Shiny" then
				-- REAL SHINY: Mirror-like reflective material
				part.Material = Enum.Material.Neon
				part.Reflectance = 0.9
				part.Color = Color3.fromRGB(255, 255, 200) -- Golden shiny tint
				
				-- Add sparkle particles
				local sparkles = Instance.new("ParticleEmitter")
				sparkles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
				sparkles.Color = ColorSequence.new(Color3.fromRGB(255, 255, 100))
				sparkles.Rate = 15
				sparkles.Lifetime = NumberRange.new(0.8, 1.5)
				sparkles.Speed = NumberRange.new(2, 4)
				sparkles.Parent = part
				
			elseif mutation == "Glowing" then
				-- REAL GLOWING: Neon material with intense light emission
				part.Material = Enum.Material.Neon
				part.Color = Color3.fromRGB(100, 255, 255) -- Cyan glow
				
				-- Add multiple point lights for intense glow
				local pointLight = Instance.new("PointLight")
				pointLight.Color = Color3.fromRGB(100, 255, 255)
				pointLight.Brightness = 3
				pointLight.Range = 15 * size
				pointLight.Parent = part
				
				-- Add surface light for additional glow
				local surfaceLight = Instance.new("SurfaceLight")
				surfaceLight.Color = Color3.fromRGB(100, 255, 255)
				surfaceLight.Brightness = 2
				surfaceLight.Range = 10 * size
				surfaceLight.Face = Enum.NormalId.Front
				surfaceLight.Parent = part
				
			elseif mutation == "Corrupted" then
				-- REAL CORRUPTED: Distorted materials and dark energy
				part.Material = Enum.Material.ForceField
				part.Color = Color3.fromRGB(80, 0, 80) -- Dark purple corruption
				part.Transparency = 0.2 -- Slightly see-through
				
				-- Add corruption particles
				local corruptParticles = Instance.new("ParticleEmitter")
				corruptParticles.Color = ColorSequence.new(Color3.fromRGB(100, 0, 100))
				corruptParticles.Rate = 25
				corruptParticles.Lifetime = NumberRange.new(1, 3)
				corruptParticles.Speed = NumberRange.new(3, 8)
				corruptParticles.VelocityInheritance = 0.5
				corruptParticles.Parent = part
				
			elseif mutation == "Stellar" then
				-- REAL STELLAR: Cosmic starry appearance
				part.Material = Enum.Material.Neon
				part.Color = Color3.fromRGB(200, 200, 255) -- Stellar blue-white
				part.Reflectance = 0.4
				
				-- Add starfield particles
				local stellarParticles = Instance.new("ParticleEmitter")
				stellarParticles.Texture = "rbxasset://textures/particles/stars.png"
				stellarParticles.Color = ColorSequence.new(Color3.fromRGB(200, 200, 255))
				stellarParticles.Rate = 12
				stellarParticles.Lifetime = NumberRange.new(2, 4)
				stellarParticles.Speed = NumberRange.new(1, 3)
				stellarParticles.Parent = part
				
				-- Add cosmic glow
				local cosmicLight = Instance.new("PointLight")
				cosmicLight.Color = Color3.fromRGB(200, 200, 255)
				cosmicLight.Brightness = 1.5
				cosmicLight.Range = 12 * size
				cosmicLight.Parent = part
				
			elseif mutation == "Quantum" then
				-- REAL QUANTUM: Phase-shifting translucent material
				part.Material = Enum.Material.ForceField
				part.Transparency = 0.4
				part.Color = Color3.fromRGB(50, 20, 80) -- Deep quantum purple
				
				-- Add quantum distortion particles
				local quantumParticles = Instance.new("ParticleEmitter")
				quantumParticles.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 20, 80)),
					ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 50, 150)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 20, 80))
				})
				quantumParticles.Rate = 30
				quantumParticles.Lifetime = NumberRange.new(1, 2)
				quantumParticles.Speed = NumberRange.new(5, 12)
				quantumParticles.Parent = part
				
			elseif mutation == "Rainbow" then
				-- REAL RAINBOW: Will be handled by animation thread below
				part.Material = Enum.Material.Neon
				part.Reflectance = 0.3
				
			elseif mutation == "Unknown" then
				-- REAL UNKNOWN: Void-like material
				part.Material = Enum.Material.Neon
				part.Color = Color3.fromRGB(0, 0, 0) -- Pure black
				part.Transparency = 0.1
				
				-- Add void particles
				local voidParticles = Instance.new("ParticleEmitter")
				voidParticles.Color = ColorSequence.new(Color3.fromRGB(20, 20, 20))
				voidParticles.Rate = 40
				voidParticles.Lifetime = NumberRange.new(0.5, 1.5)
				voidParticles.Speed = NumberRange.new(8, 15)
				voidParticles.Parent = part
				
				-- Add dark energy field
				local voidLight = Instance.new("PointLight")
				voidLight.Color = Color3.fromRGB(50, 0, 50)
				voidLight.Brightness = 0.5
				voidLight.Range = 8 * size
				voidLight.Parent = part
			end
		end
	end
	
	-- Apply all mutations to the item
	if mutationNames and #mutationNames > 0 then
		for _, mutationName in ipairs(mutationNames) do
			applyMutationToAllParts(mutationName, actualUGCItem or itemModel)
		end
	end

	-- Create floating text part
	local textPart = Instance.new("Part")
	textPart.Anchored = true
	textPart.CanCollide = false
	textPart.Size = Vector3.new(1, 1, 1)
	textPart.Position = position + Vector3.new(0, 6, 0) -- Position text above the item
	textPart.Transparency = 1
	textPart.Parent = workspace

	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Size = UDim2.new(12, 0, 5, 0)
	billboardGui.AlwaysOnTop = true
	billboardGui.Parent = textPart

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.Text = fullText
	textLabel.TextColor3 = textColor
	textLabel.BackgroundTransparency = 1
	textLabel.Font = Enum.Font.FredokaOne
	textLabel.TextSize = finalSize
	textLabel.Parent = billboardGui
	
	-- Add a glowing outline
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 2
	stroke.Color = textColor
	stroke.Transparency = 0.5 -- This makes it a "glow"
	stroke.Parent = textLabel

	-- Clean up both text and item after animation
	Debris:AddItem(textPart, 3.5)
	Debris:AddItem(itemModel, 4.0) -- Give item slightly more time
	
	-- STAGE 4: The Grand Reveal (Punch-in text animation)
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.Text = fullText
	textLabel.TextColor3 = textColor
	textLabel.BackgroundTransparency = 1
	textLabel.Font = Enum.Font.FredokaOne
	textLabel.TextTransparency = 1 -- Start invisible
	textLabel.Parent = billboardGui
	
	-- Play the reward sound when the text appears
	if soundController then
		soundController:playRewardSound(rarityName)
	end
	
	-- Start rainbow text animation if item has Rainbow mutation
	local rainbowTextThread = nil
	if hasRainbow then
		rainbowTextThread = coroutine.create(function()
			while textLabel.Parent do
				local hue = (tick() * 2) % 5 / 5 -- Faster rainbow cycle
				local rainbowColor = Color3.fromHSV(hue, 1, 1)
				textLabel.TextColor3 = rainbowColor
				stroke.Color = rainbowColor
				task.wait(0.05) -- Smooth rainbow animation
			end
		end)
		coroutine.resume(rainbowTextThread)
	end
	
	-- Punch-in animation
	textLabel.Size = UDim2.fromScale(0.1, 0.1)
	local punchInTween = TweenService:Create(textLabel, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.fromScale(1, 1),
		TextTransparency = 0
	})
	
	-- Start item rotation animation
	local rotationThread = nil
	if itemModel then
		rotationThread = coroutine.create(function()
			local rotationSpeed = 2 -- Rotations per second
			local startTime = tick()
			while itemModel.Parent do
				local elapsed = tick() - startTime
				local rotationY = (elapsed * rotationSpeed * 360) % 360
				
				-- Apply rotation to the entire item model
				if actualUGCItem then
					-- Rotate the whole UGC item
					local cf = CFrame.new(actualUGCItem.Handle.Position) * CFrame.Angles(0, math.rad(rotationY), 0)
					actualUGCItem.Handle.CFrame = cf
				else
					-- Rotate just the display part
					displayPart.CFrame = CFrame.new(displayPart.Position) * CFrame.Angles(0, math.rad(rotationY), 0)
				end
				
				task.wait(0.03) -- Smooth rotation
			end
		end)
		coroutine.resume(rotationThread)
	end
	
	-- Rainbow effect for ALL PARTS if it has Rainbow mutation
	local itemRainbowThread = nil
	if hasRainbow and itemModel then
		itemRainbowThread = coroutine.create(function()
			-- Get all parts to apply rainbow effect to
			local rainbowParts = {}
			if actualUGCItem then
				for _, descendant in pairs(actualUGCItem:GetDescendants()) do
					if descendant:IsA("BasePart") then
						table.insert(rainbowParts, descendant)
					end
				end
			else
				for _, child in pairs(itemModel:GetChildren()) do
					if child:IsA("BasePart") then
						table.insert(rainbowParts, child)
					end
				end
			end
			
			while itemModel.Parent do
				local hue = (tick() * 2) % 5 / 5
				local rainbowColor = Color3.fromHSV(hue, 1, 1)
				
				-- Apply rainbow color to ALL parts
				for _, part in pairs(rainbowParts) do
					part.Color = rainbowColor
				end
				
				task.wait(0.05)
			end
		end)
		coroutine.resume(itemRainbowThread)
	end

	-- Tweens for float up (both text and item)
	local floatPosition = position + Vector3.new(0, 15, 0)
	local floatTween = TweenService:Create(textPart, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = floatPosition})
	
	local itemFloatPosition = position + Vector3.new(0, 12, 0)
	local itemFloatTween = nil
	if itemModel then
		if actualUGCItem then
			itemFloatTween = TweenService:Create(actualUGCItem.Handle, TweenInfo.new(3.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = itemFloatPosition})
		else
			itemFloatTween = TweenService:Create(displayPart, TweenInfo.new(3.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = itemFloatPosition})
		end
	end
	
	punchInTween:Play()
	punchInTween.Completed:Connect(function()
		floatTween:Play()
		if itemFloatTween then
			itemFloatTween:Play()
		end
	end)
	
	-- Clean up all animations when destroyed
	task.delay(4.0, function()
		if rainbowTextThread then
			coroutine.close(rainbowTextThread)
		end
		if rotationThread then
			coroutine.close(rotationThread)
		end
		if itemRainbowThread then
			coroutine.close(itemRainbowThread)
		end
	end)
end

-- Create floating error text for inventory full messages
function BoxAnimator.AnimateFloatingErrorText(position, message)
	-- Skip animation if effects are disabled
	if areEffectsDisabled() then
		return
	end
	
	-- Create floating text part
	local textPart = Instance.new("Part")
	textPart.Anchored = true
	textPart.CanCollide = false
	textPart.Size = Vector3.new(1, 1, 1)
	textPart.Position = position + Vector3.new(0, 4, 0) -- Start above the box
	textPart.Transparency = 1
	textPart.Parent = workspace

	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Size = UDim2.new(10, 0, 3, 0)
	billboardGui.AlwaysOnTop = true
	billboardGui.Parent = textPart

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.Text = message
	textLabel.TextColor3 = Color3.fromRGB(255, 100, 100) -- Red error color
	textLabel.BackgroundTransparency = 1
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextSize = 24
	textLabel.TextStrokeTransparency = 0.5
	textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	textLabel.TextTransparency = 1 -- Start invisible
	textLabel.Parent = billboardGui
	
	-- Add a red glowing outline
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 3
	stroke.Color = Color3.fromRGB(255, 50, 50)
	stroke.Transparency = 0.3
	stroke.Parent = textLabel

	-- Clean up after animation
	local Debris = game:GetService("Debris")
	Debris:AddItem(textPart, 3.5)
	
	-- Punch-in animation
	textLabel.Size = UDim2.fromScale(0.1, 0.1)
	local punchInTween = TweenService:Create(textLabel, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.fromScale(1, 1),
		TextTransparency = 0
	})
	
	-- Float up animation
	local floatPosition = position + Vector3.new(0, 12, 0)
	local floatTween = TweenService:Create(textPart, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = floatPosition})
	
	-- Fade out animation
	local fadeOutTween = TweenService:Create(textLabel, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		TextTransparency = 1
	})
	
	-- Play animations in sequence
	punchInTween:Play()
	punchInTween.Completed:Connect(function()
		floatTween:Play()
		task.wait(2) -- Show for 2 seconds
		fadeOutTween:Play()
	end)
end

-- Create floating notification text for general notifications
function BoxAnimator.AnimateFloatingNotification(message, messageType)
	-- Skip animation if effects are disabled
	if areEffectsDisabled() then
		return
	end
	
	-- Get player's character position
	local LocalPlayer = game:GetService("Players").LocalPlayer
	local character = LocalPlayer.Character
	if not character or not character.PrimaryPart then
		return
	end
	
	local position = character.PrimaryPart.Position + Vector3.new(0, 5, 0)
	
	-- Create floating text part
	local textPart = Instance.new("Part")
	textPart.Anchored = true
	textPart.CanCollide = false
	textPart.Size = Vector3.new(1, 1, 1)
	textPart.Position = position
	textPart.Transparency = 1
	textPart.Parent = workspace

	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Size = UDim2.new(12, 0, 4, 0)
	billboardGui.AlwaysOnTop = true
	billboardGui.Parent = textPart

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.Text = message
	textLabel.BackgroundTransparency = 1
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextSize = 28
	textLabel.TextStrokeTransparency = 0.3
	textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	textLabel.TextTransparency = 1 -- Start invisible
	textLabel.TextWrapped = true
	textLabel.Parent = billboardGui
	
	-- Set colors based on message type
	local strokeColor
	if messageType == "Error" then
		textLabel.TextColor3 = Color3.fromRGB(255, 100, 100) -- Red
		strokeColor = Color3.fromRGB(255, 50, 50)
	elseif messageType == "Success" then
		textLabel.TextColor3 = Color3.fromRGB(100, 255, 100) -- Green
		strokeColor = Color3.fromRGB(50, 255, 50)
	else -- Info or default
		textLabel.TextColor3 = Color3.fromRGB(100, 150, 255) -- Blue
		strokeColor = Color3.fromRGB(50, 100, 255)
	end
	
	-- Add a glowing outline
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 3
	stroke.Color = strokeColor
	stroke.Transparency = 0.2
	stroke.Parent = textLabel

	-- Clean up after animation
	local Debris = game:GetService("Debris")
	Debris:AddItem(textPart, 4)
	
	-- Punch-in animation
	textLabel.Size = UDim2.fromScale(0.1, 0.1)
	local punchInTween = TweenService:Create(textLabel, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.fromScale(1, 1),
		TextTransparency = 0
	})
	
	-- Float up animation
	local floatPosition = position + Vector3.new(0, 15, 0)
	local floatTween = TweenService:Create(textPart, TweenInfo.new(3.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = floatPosition})
	
	-- Fade out animation
	local fadeOutTween = TweenService:Create(textLabel, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		TextTransparency = 1
	})
	
	-- Play animations in sequence
	punchInTween:Play()
	punchInTween.Completed:Connect(function()
		floatTween:Play()
		task.wait(2.3) -- Show for 2.3 seconds
		fadeOutTween:Play()
	end)
end

-- Create fireworks celebration effect (e.g., for gamepass purchase)
function BoxAnimator.PlayCelebrationEffect()
	-- Skip if effects disabled
	if areEffectsDisabled() then return end
	local Players = game:GetService("Players")
	local LocalPlayer = Players.LocalPlayer
	local character = LocalPlayer and LocalPlayer.Character
	if not character or not character.PrimaryPart then return end

	local basePosition = character.PrimaryPart.Position
	-- Configure fireworks parameters
	local colors = {
		Color3.fromRGB(255, 100, 100),
		Color3.fromRGB(100, 255, 100),
		Color3.fromRGB(100, 150, 255),
		Color3.fromRGB(255, 255, 100),
		Color3.fromRGB(255, 100, 255),
	}

	local Debris = game:GetService("Debris")
	local TweenService = game:GetService("TweenService")

	-- Spawn a double ring of fireworks (10 total)
	local total = 10
	for i = 1, total do
		local angle = math.rad((i - 1) * 360 / total)
		local radius = (i % 2 == 0) and 4 or 6 -- alternate inner/outer rings
		local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
		local part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.Size = Vector3.new(0.5, 0.5, 0.5)
		part.Transparency = 1
		part.Position = basePosition + offset + Vector3.new(0, 2, 0)
		part.Parent = workspace

		local attachment = Instance.new("Attachment")
		attachment.Parent = part

		local emitter = Instance.new("ParticleEmitter")
		emitter.Enabled = false
		emitter.Texture = "rbxassetid://248625108" -- spark texture
		emitter.Color = ColorSequence.new(colors[i % 5 + 1] or Color3.new(1,1,1))
		emitter.LightEmission = 0.85
		emitter.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 0)})
		emitter.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})
		emitter.Speed = NumberRange.new(35, 45)
		emitter.Lifetime = NumberRange.new(1.2, 1.6)
		emitter.Rate = 0
		emitter.Rotation = NumberRange.new(0, 360)
		emitter.RotSpeed = NumberRange.new(-180, 180)
		emitter.SpreadAngle = Vector2.new(360, 360)
		emitter.Parent = attachment

		-- Play emitter after slight stagger
		delay((i - 1) * 0.08, function()
			emitter:Emit(180)
		end)

		Debris:AddItem(part, 4)
	end

	-- Central upward burst after ring
	task.delay(0.6, function()
		local centerPart = Instance.new("Part")
		centerPart.Anchored = true
		centerPart.CanCollide = false
		centerPart.Size = Vector3.new(0.5, 0.5, 0.5)
		centerPart.Transparency = 1
		centerPart.Position = basePosition + Vector3.new(0, 2, 0)
		centerPart.Parent = workspace

		local attach = Instance.new("Attachment")
		attach.Parent = centerPart

		local upEmitter = Instance.new("ParticleEmitter")
		upEmitter.Enabled = false
		upEmitter.Texture = "rbxassetid://248625108"
		upEmitter.Color = ColorSequence.new(Color3.fromRGB(255,255,255))
		upEmitter.LightEmission = 0.9
		upEmitter.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,0.4),NumberSequenceKeypoint.new(1,0)})
		upEmitter.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)})
		upEmitter.Speed = NumberRange.new(55,65)
		upEmitter.Lifetime = NumberRange.new(1,1.4)
		upEmitter.Rate = 0
		upEmitter.SpreadAngle = Vector2.new(10,10)
		upEmitter.Parent = attach

		upEmitter:Emit(250)
		Debris:AddItem(centerPart, 4)
	end)

	-- Optional: small camera shake or sound could be added here if desired
end

return BoxAnimator 