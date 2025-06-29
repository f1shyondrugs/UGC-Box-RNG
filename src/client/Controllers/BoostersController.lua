local BoostersUI = require(script.Parent.Parent.UI.BoostersUI)
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local BoostersController = {}

function BoostersController.Start(parent)
	local player = Players.LocalPlayer
	local isPremium = player.MembershipType == Enum.MembershipType.Premium

	local boosters = {
		{
			Name = "Premium Booster",
			Description = isPremium
				and "✨ Your luck is boosted by 10% when opening crates! ✨"
				or "Roblox Premium members get 10% more luck when opening crates!",
			Icon = "rbxasset://textures/ui/PlayerList/PremiumIcon@3x.png",
			Locked = not isPremium,
			LockIcon = "rbxassetid://6031094678", -- Lock icon
		}
	}

	local function onBoosterClick(booster)
		if booster.Name == "Premium Booster" and booster.Locked then
			-- Prompt for Premium
			MarketplaceService:PromptPremiumPurchase(player)
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