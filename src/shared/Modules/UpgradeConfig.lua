local UpgradeConfig = {}

-- Upgrade definitions with scaling costs and effects
UpgradeConfig.Upgrades = {
	InventorySlots = {
		Name = "More Inventory Slots",
		Description = "Increases your inventory capacity",
		BaseCost = 1000,
		CostExponent = 5,
		BaseValue = 50, -- Starting inventory slots
		ValuePerLevel = 5, -- +5 slots per level
		MaxLevel = 100, -- Up to 550 slots total
		Icon = "🎒",
		Effects = function(level)
			return {
				CurrentSlots = 50 + (level * 5),
				NextSlots = 50 + ((level + 1) * 5)
			}
		end
	},
	
	MultiCrateOpening = {
		Name = "Multi-Crate Opening",
		Description = "Open multiple crates at once",
		BaseCost = 10000,
		CostExponent = 5,
		BaseValue = 1, -- Starting max boxes
		ValuePerLevel = 1, -- +1 box per level
		MaxLevel = 49, -- Up to 5 boxes total (1 + 4 levels)
		Icon = "📦",
		Effects = function(level)
			return {
				CurrentBoxes = math.min(1 + level, 5),
				NextBoxes = math.min(1 + level + 1, 5)
			}
		end
	},
	
	FasterCooldowns = {
		Name = "Faster Cooldowns",
		Description = "Reduces the cooldown between crate purchases",
		BaseCost = 1000,
		CostExponent = 5,
		BaseValue = 0.5, -- Starting cooldown in seconds
		ValuePerLevel = -0.05, -- -0.05 seconds per level
		MaxLevel = 10, -- Up to 0.1 second cooldown (0.5 - 8*0.05 = 0.1)
		Icon = "⚡",
		Effects = function(level)
			local currentCooldown = math.max(0.1, 0.5 - (level * 0.05)) -- Minimum 0.1 seconds
			local nextCooldown = math.max(0.1, 0.5 - ((level + 1) * 0.05))
			return {
				CurrentCooldown = string.format("%.2fs", currentCooldown),
				NextCooldown = string.format("%.2fs", nextCooldown),
				CurrentCooldownValue = currentCooldown,
				NextCooldownValue = nextCooldown
			}
		end
	}
}

-- Calculate upgrade cost for a specific level
function UpgradeConfig.GetUpgradeCost(upgradeId, level)
	local upgrade = UpgradeConfig.Upgrades[upgradeId]
	if not upgrade then return 0 end
	
	if level >= upgrade.MaxLevel then
		return nil -- Max level reached
	end
	
	return math.floor(upgrade.BaseCost * math.pow(level + 1, upgrade.CostExponent))
end

-- Get current upgrade effects
function UpgradeConfig.GetUpgradeEffects(upgradeId, level)
	local upgrade = UpgradeConfig.Upgrades[upgradeId]
	if not upgrade or not upgrade.Effects then return {} end
	
	return upgrade.Effects(level)
end

-- Check if upgrade is at max level
function UpgradeConfig.IsMaxLevel(upgradeId, level)
	local upgrade = UpgradeConfig.Upgrades[upgradeId]
	if not upgrade then return true end
	
	return level >= upgrade.MaxLevel
end

-- Get all upgrade IDs
function UpgradeConfig.GetAllUpgradeIds()
	local ids = {}
	for id, _ in pairs(UpgradeConfig.Upgrades) do
		table.insert(ids, id)
	end
	return ids
end

return UpgradeConfig 