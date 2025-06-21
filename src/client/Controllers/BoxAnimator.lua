local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.Modules.GameConfig)
local ItemValueCalculator = require(ReplicatedStorage.Shared.Modules.ItemValueCalculator)
local CameraShaker = require(script.Parent.CameraShaker)

local BoxAnimator = {}

function BoxAnimator.PlayAddictiveAnimation(boxPart, itemConfig, mutationName, mutationConfig, size)
	local isShiny = mutationName == "Shiny"
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
	if mutationConfig then
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
			if size >= 2.5 then
				CameraShaker.Shake(pulseDuration + 0.2, 0.05 + (size / 250) * (i / pulses))
			end
			tweenUp:Play()
			task.wait(pulseDuration)
		end
		
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

			local colorTween = TweenService:Create(boxPart, TweenInfo.new(flashDuration), {Color = color})
			colorTween:Play()
			
			CameraShaker.Shake(flashDuration, 0.1 + (i * 0.05))
			
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
	
		if mutationConfig then
			if size >= 2.5 then
				CameraShaker.Shake(0.5 + size / 100, 0.4 + size / 80)
			end
			if isShiny then
				light.Color = mutationConfig.Color
			end
			
			local mutationParticles = Instance.new("ParticleEmitter")
			mutationParticles.Rate = 0
			mutationParticles.Lifetime = NumberRange.new(0.5, 1.5)
			mutationParticles.Speed = NumberRange.new(8, 15)
			mutationParticles.SpreadAngle = Vector2.new(360, 360)
			mutationParticles.Color = ColorSequence.new(mutationConfig.Color)
			mutationParticles.Parent = boxPart
			mutationParticles:Emit(50)
			Debris:AddItem(mutationParticles, 2)
	
			local mutationFlash = TweenService:Create(boxPart, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 5, true), {Color = mutationConfig.Color})
			mutationFlash:Play()
			task.wait(0.4)
			mutationFlash:Cancel()
		end
		
		shakeTween:Cancel()
		if glowTween then glowTween:Cancel() end
		if rotationTween then rotationTween:Cancel() end
		
		-- STAGE 3: The Launch & Explosion
		local launchPos = boxPart.Position + Vector3.new(0, 6, 0)
		local launchTween = TweenService:Create(boxPart, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = launchPos})
		launchTween:Play()
		launchTween.Completed:Wait()

		task.wait(0.1) -- Hang time

		CameraShaker.Shake(0.5, 1.2) -- The big explosion shake!

		if isShiny then
			light.Brightness = 100
			light.Range = 50
			Debris:AddItem(light, 1)
			Debris:AddItem(shineGui, 1)
		end
	
		local explosionColor = (mutationConfig and mutationConfig.Color) or GameConfig.Rarities[itemConfig.Rarity].Color
		particleEmitter.Color = ColorSequence.new(explosionColor)
		particleEmitter:Emit(250)
		
		boxPart.Transparency = 1 -- Vanish within the explosion
	end)

	-- Recalculate duration to match new sequence
	local duration = actualScaleDuration + 2.5 -- Base time for rarity cycle
	if mutationConfig then duration = duration + 0.4 end
	duration = duration + 0.3 -- Launch and explosion time
	
	return duration
end

function BoxAnimator.AnimateFloatingText(position, itemName, itemConfig, mutationName, mutationConfig, size)
	size = size or 1 -- Default size to 1 if nil
	local rarityName = itemConfig.Rarity
	local rarityConfig = GameConfig.Rarities[rarityName]
	
	-- Constructing the text
	local mainText = itemName
	if mutationName then
		mainText = mutationName .. " " .. mainText
	end
	
	local mutationConfig = mutationName and GameConfig.Mutations[mutationName]
	local valueText = ItemValueCalculator.GetFormattedValue(itemConfig, mutationConfig, size)

	local fullText = string.format("%s\nSize: %.2f | Value: %s\n(%s)", mainText, size, valueText, rarityName)
	
	-- Determine color and size
	local textColor = mutationConfig and mutationConfig.Color or rarityConfig.Color
	
	local raritySizeMap = {
		Common = 18,
		Uncommon = 22,
		Rare = 26,
		Epic = 32,
		Legendary = 38,
	}
	local baseSize = raritySizeMap[rarityName] or 28
	
	-- Apply multipliers for size and mutation
	local sizeMultiplier = 1 + math.log(size) / 2.5
	local mutationMultiplier = mutationName and 1.2 or 1
	
	local finalSize = baseSize * sizeMultiplier * mutationMultiplier

	if size >= 2.5 then
		local shakeStrength = math.clamp((size - 2.5) / 50, 0.1, 2)
		CameraShaker.Shake(0.7 + shakeStrength, shakeStrength)
	end

	-- Create floating text part
	local textPart = Instance.new("Part")
	textPart.Anchored = true
	textPart.CanCollide = false
	textPart.Size = Vector3.new(1, 1, 1)
	textPart.Position = position
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

	Debris:AddItem(textPart, 3.5)
	
	-- STAGE 4: The Grand Reveal (Punch-in text animation)
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.Text = fullText
	textLabel.TextColor3 = textColor
	textLabel.BackgroundTransparency = 1
	textLabel.Font = Enum.Font.FredokaOne
	textLabel.TextTransparency = 1 -- Start invisible
	textLabel.Parent = billboardGui
	
	-- Punch-in animation
	textLabel.Size = UDim2.fromScale(0.1, 0.1)
	local punchInTween = TweenService:Create(textLabel, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.fromScale(1, 1),
		TextTransparency = 0
	})
	
	-- Tweens for float up
	local floatPosition = position + Vector3.new(0, 15, 0)
	local floatTween = TweenService:Create(textPart, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = floatPosition})
	
	punchInTween:Play()
	punchInTween.Completed:Connect(function()
		floatTween:Play()
	end)
end

return BoxAnimator 