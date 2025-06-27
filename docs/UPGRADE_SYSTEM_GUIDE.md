# Upgrade System Developer Guide

This guide explains how the upgrade system works and how to add new upgrades to the game.

## 🏗️ Architecture Overview

The upgrade system consists of several key components:

1. **UpgradeConfig.lua** - Defines all available upgrades
2. **UpgradeService.lua** - Server-side logic for handling purchases and persistence
3. **UpgradeUI.lua** - Client-side user interface
4. **UpgradeController.lua** - Client-side logic and event handling
5. **PlayerDataService.lua** - Data persistence integration

## 📋 Adding a New Upgrade

### Step 1: Define the Upgrade in UpgradeConfig.lua

```lua
-- Add to UpgradeConfig.Upgrades table
LuckBoost = {
    Name = "Luck Boost",
    Description = "Increases your chance of getting rare items",
    BaseCost = 1000,
    CostExponent = 1.8,
    BaseValue = 1, -- Starting multiplier
    ValuePerLevel = 0.1, -- +10% per level
    MaxLevel = 10, -- Up to 200% luck
    Icon = "🍀",
    Effects = function(level)
        return {
            CurrentMultiplier = string.format("%.1fx", 1 + (level * 0.1)),
            NextMultiplier = string.format("%.1fx", 1 + ((level + 1) * 0.1))
        }
    end
}
```

### Step 2: Add Server-side Logic

In **UpgradeService.lua**, add functions to get the upgrade value:

```lua
-- Add new function to get luck multiplier
function UpgradeService.GetPlayerLuckMultiplier(player)
    local upgradeLevel = UpgradeService.GetPlayerUpgradeLevel(player, "LuckBoost")
    local upgrade = UpgradeConfig.Upgrades.LuckBoost
    return upgrade.BaseValue + (upgradeLevel * upgrade.ValuePerLevel)
end
```

### Step 3: Integrate with Game Systems

Update the relevant game systems to use the new upgrade. For example, in **BoxService.lua**:

```lua
-- When determining rewards, apply luck multiplier
local function openBox(player, boxPart)
    -- ... existing code ...
    
    -- Get luck multiplier from upgrades
    local UpgradeService = require(script.Parent.UpgradeService)
    local luckMultiplier = UpgradeService.GetPlayerLuckMultiplier(player)
    
    -- Apply luck to rare item chances
    for itemName, baseChance in pairs(boxConfig.Rewards) do
        local adjustedChance = baseChance * luckMultiplier
        -- Use adjustedChance in your random selection logic
    end
    
    -- ... rest of the function ...
end
```

### Step 4: Update UI (Optional)

If your upgrade has special display requirements, update **UpgradeUI.lua**:

```lua
-- In UpdateUpgradeFrame function, add special case:
if upgradeId == "LuckBoost" then
    effectText = "Current: " .. upgradeData.effects.CurrentMultiplier .. " → Next: " .. upgradeData.effects.NextMultiplier
end
```

## 🎨 UI Design Guidelines

The upgrade system follows the Collection GUI design patterns:

### Colors
- **Background**: `Color3.fromRGB(25, 30, 40)`
- **Accent**: `Color3.fromRGB(35, 40, 55)`
- **Text**: `Color3.fromRGB(255, 255, 255)`
- **Success**: `Color3.fromRGB(50, 150, 50)`
- **Error**: `Color3.fromRGB(150, 50, 50)`
- **Info**: `Color3.fromRGB(100, 200, 255)`

### Fonts
- **Headers**: `Enum.Font.SourceSansBold`
- **Body**: `Enum.Font.SourceSans`

### Sizing
- **Corner Radius**: 8-16px depending on element size
- **Padding**: 15px between elements
- **Button Height**: 40px for upgrade buttons

## 🔧 Testing New Upgrades

1. **Start with low costs** for testing (like 10 R$)
2. **Test edge cases** like max level and insufficient funds
3. **Verify persistence** by rejoining the game
4. **Check mobile compatibility** with touch interfaces
5. **Test upgrade effects** in actual gameplay

## 📊 Cost Scaling Examples

Different upgrade types should use different cost scaling:

```lua
-- Linear scaling (good for simple upgrades)
CostExponent = 1.0  -- 100, 200, 300, 400...

-- Moderate scaling (recommended for most upgrades)
CostExponent = 1.5  -- 100, 245, 464, 756...

-- Aggressive scaling (for powerful upgrades)
CostExponent = 2.0  -- 100, 400, 900, 1600...

-- Gentle scaling (for cosmetic upgrades)
CostExponent = 1.2  -- 100, 139, 188, 247...
```

## 🛡️ Security Considerations

- All upgrade purchases are validated server-side
- Player data is sanitized before saving
- Upgrade effects are calculated server-side only
- Client UI is purely cosmetic - never trust client calculations

## 🔄 Data Migration

When adding new upgrades to existing games:

1. **Default values**: All new upgrades start at level 0
2. **Backward compatibility**: Old save data works with new upgrades
3. **Graceful degradation**: Missing upgrade data defaults to level 0

## 📈 Performance Tips

- **Cache upgrade values** when possible (avoid repeated calculations)
- **Use events** to update systems when upgrades change
- **Minimize server calls** by batching upgrade data requests
- **Optimize UI updates** to only refresh when necessary

## 🐛 Common Issues

### "Upgrade not showing in UI"
- Check that the upgrade is defined in UpgradeConfig.lua
- Verify the UpgradeUI.CreateUpgradeFrame handles your upgrade type
- Ensure the server is returning the upgrade data correctly

### "Upgrade effects not applying"
- Make sure the game system is checking the upgrade value
- Verify the UpgradeService function returns the correct value
- Check that the upgrade is being loaded from save data

### "Cost calculation wrong"
- Double-check the BaseCost and CostExponent values
- Test the UpgradeConfig.GetUpgradeCost function
- Ensure level counting starts from 0 or 1 consistently

## 🎯 Best Practices

1. **Start small**: Add simple upgrades before complex ones
2. **Test thoroughly**: Every upgrade should be tested at each level
3. **Document effects**: Clear descriptions help players understand value
4. **Balance carefully**: Avoid making upgrades too powerful or too weak
5. **Follow patterns**: Use existing upgrades as templates for consistency
6. **Consider mobile**: Ensure all upgrades work well on touch devices 