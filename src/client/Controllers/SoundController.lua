local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SoundConfig = require(ReplicatedStorage.Shared.Modules.SoundConfig)

local SoundController = {}
SoundController.__index = SoundController

-- Reference to settings controller (will be set when initialized)
local settingsController = nil

function SoundController.new()
	local self = setmetatable({}, SoundController)
	self.sounds = {}
	self:_preloadSounds()
	return self
end

-- Set reference to settings controller
function SoundController:setSettingsController(settings)
	settingsController = settings
end

-- Check if effects are disabled
local function areEffectsDisabled()
	return settingsController and settingsController.AreEffectsDisabled() or false
end

function SoundController:_preloadSounds()
	-- Store the sound IDs instead of sound objects for overlapping
	for name, id in pairs(SoundConfig.RewardSounds) do
		self.sounds[name] = id
	end

	self.sounds.UIClick = SoundConfig.UIClick
	self.sounds.BoxLand = SoundConfig.BoxLand
	self.sounds.BoxOpen = SoundConfig.BoxOpen
	self.sounds.SellItem = SoundConfig.SellItem
	self.sounds.GrowingBox = SoundConfig.GrowingBox
	
	-- Store the active growing box sound to allow stopping it
	self.currentGrowingBoxSound = nil
end

function SoundController:playMusic()
	self.music = Instance.new("Sound")
	self.music.SoundId = "rbxassetid://" .. SoundConfig.BackgroundMusic[math.random(1, #SoundConfig.BackgroundMusic)]
	self.music.Parent = SoundService
	self.music.Looped = true
	self.music.Volume = 0.5
	self.music:Play()
end

function SoundController:playUIClick()
	if areEffectsDisabled() then return end
	
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://" .. self.sounds.UIClick
	sound.Parent = SoundService
	sound:Play()
	
	-- Clean up the sound after it finishes
	sound.Ended:Connect(function()
		sound:Destroy()
	end)
end

function SoundController:playBoxLand()
	if areEffectsDisabled() then return end
	
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://" .. self.sounds.BoxLand
	sound.Parent = SoundService
	sound:Play()
	
	-- Clean up the sound after it finishes
	sound.Ended:Connect(function()
		sound:Destroy()
	end)
end

function SoundController:playBoxOpen()
	if areEffectsDisabled() then return end
	
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://" .. self.sounds.BoxOpen
	sound.Parent = SoundService
	sound:Play()
	
	-- Clean up the sound after it finishes
	sound.Ended:Connect(function()
		sound:Destroy()
	end)
end

function SoundController:playSellItem()
	if areEffectsDisabled() then return end
	
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://" .. self.sounds.SellItem
	sound.Parent = SoundService
	sound:Play()
	
	-- Clean up the sound after it finishes
	sound.Ended:Connect(function()
		sound:Destroy()
	end)
end

function SoundController:playGrowingBox()
	if areEffectsDisabled() then return end
	
	-- Stop any existing growing box sound
	if self.currentGrowingBoxSound then
		self.currentGrowingBoxSound:Stop()
		self.currentGrowingBoxSound:Destroy()
	end
	
	self.currentGrowingBoxSound = Instance.new("Sound")
	self.currentGrowingBoxSound.SoundId = "rbxassetid://" .. self.sounds.GrowingBox
	self.currentGrowingBoxSound.Parent = SoundService
	self.currentGrowingBoxSound:Play()
end

function SoundController:stopGrowingBox()
	if self.currentGrowingBoxSound then
		self.currentGrowingBoxSound:Stop()
		self.currentGrowingBoxSound:Destroy()
		self.currentGrowingBoxSound = nil
	end
end

function SoundController:playRewardSound(rarity)
	if areEffectsDisabled() then return end
	
	local soundId = self.sounds[rarity]
	if not soundId then
		warn("No sound found for rarity:", rarity)
		return
	end

	-- Create a new sound instance for overlapping
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://" .. soundId
	sound.Parent = SoundService

	-- Pitch adjustments based on rarity
	if rarity == "Uncommon" then
		sound.PlaybackSpeed = 1.2
	elseif rarity == "Celestial" then
		sound.PlaybackSpeed = 1.2
	elseif rarity == "Ethereal" then
		sound.PlaybackSpeed = 1.2
	else
		sound.PlaybackSpeed = 1
	end

	sound:Play()
	
	-- Clean up the sound after it finishes
	sound.Ended:Connect(function()
		sound:Destroy()
	end)
end

return SoundController 