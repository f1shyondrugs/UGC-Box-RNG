local BoostersUI = require(script.Parent.Parent.UI.BoostersUI)
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage.Shared.Modules.GameConfig)

local BoostersController = {}

-- Utility to safely fetch the icon asset id for a gamepass
local function getGamepassIcon(gamepassId)
	local success, info = pcall(function()
		return MarketplaceService:GetProductInfo(gamepassId, Enum.InfoType.GamePass)
	end)
	if success and info and info.IconImageAssetId then
		return "rbxassetid://" .. info.IconImageAssetId
	end
	return nil -- caller will handle fallback
end

function BoostersController.Start(parent)
	local player = Players.LocalPlayer
	local isPremium = player.MembershipType == Enum.MembershipType.Premium

	-- Check ownership of the new luck gamepasses (falling back to whitelist)
	local ownsExtraLucky, ownsUltraLucky = false, false

	-- Whitelist devs automatically own all passes for testing
	for _, id in ipairs(GameConfig.GamepassWhitelist or {}) do
		if id == player.UserId then
			ownsExtraLucky = true
			ownsUltraLucky = true
			break
		end
	end

	if not ownsExtraLucky then
		local success, result = pcall(function()
			return MarketplaceService:UserOwnsGamePassAsync(player.UserId, GameConfig.ExtraLuckyGamepassId)
		end)
		ownsExtraLucky = success and result or false
	end

	if not ownsUltraLucky then
		local success, result = pcall(function()
			return MarketplaceService:UserOwnsGamePassAsync(player.UserId, GameConfig.UltraLuckyGamepassId)
		end)
		ownsUltraLucky = success and result or false
	end

	-- Fetch icons for the passes (with simple caching per run)
	local extraLuckyIcon = getGamepassIcon(GameConfig.ExtraLuckyGamepassId) or "rbxassetid://10977456288"
	local ultraLuckyIcon = getGamepassIcon(GameConfig.UltraLuckyGamepassId) or "rbxassetid://6026568193"

	local boosters = {
		{
			Name = "Premium Booster",
			Description = isPremium
				and "✨ Your luck is boosted by 10% when opening crates! ✨"
				or "Roblox Premium members get 10% more luck when opening crates!",
			Icon = "rbxasset://textures/ui/PlayerList/PremiumIcon@3x.png",
			Locked = not isPremium,
			LockIcon = "rbxassetid://6031094678", -- Lock icon
		},
		{
			Name = "Extra Lucky",
			Description = ownsExtraLucky
				and "🍀 Your crate luck is boosted by 25%! 🍀"
				or "Unlock 25% more luck when opening crates!",
			Icon = extraLuckyIcon,
			Locked = not ownsExtraLucky,
			LockIcon = "rbxassetid://6031094678",
			GamepassId = GameConfig.ExtraLuckyGamepassId,
		},
		{
			Name = "ULTRA Lucky",
			Description = ownsUltraLucky
				and "💎 Your crate luck is boosted by 40%! 💎"
				or "Unlock 40% more luck when opening crates!",
			Icon = ultraLuckyIcon,
			Locked = not ownsUltraLucky,
			LockIcon = "rbxassetid://6031094678",
			GamepassId = GameConfig.UltraLuckyGamepassId,
		},
	}

	local function onBoosterClick(booster)
		if not booster.Locked then return end

		if booster.Name == "Premium Booster" then
			MarketplaceService:PromptPremiumPurchase(player)
		elseif booster.GamepassId then
			MarketplaceService:PromptGamePassPurchase(player, booster.GamepassId)
		end
	end

	-- Create a dedicated ScreenGui for boosters
	local boostersGui = Instance.new("ScreenGui")
	boostersGui.Name = "BoostersGui"
	boostersGui.ResetOnSpawn = false
	boostersGui.IgnoreGuiInset = false
	boostersGui.Parent = parent

	BoostersUI.Create(boostersGui, boosters, onBoosterClick)
end

return BoostersController 