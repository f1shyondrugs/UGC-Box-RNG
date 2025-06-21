local ItemValueCalculator = {}

function ItemValueCalculator.GetValue(itemConfig, mutationConfig, size)
    if not itemConfig then return 0 end

    local baseValue = itemConfig.Value or 0
    size = size or 1

    -- Apply mutation multiplier
    if mutationConfig then
        baseValue = baseValue * mutationConfig.ValueMultiplier
    end

    -- Apply size multiplier
    baseValue = baseValue * size

    local finalValue = math.floor(baseValue)
    return math.max(1, finalValue)
end

function ItemValueCalculator.GetFormattedValue(itemConfig, mutationConfig, size)
    local value = ItemValueCalculator.GetValue(itemConfig, mutationConfig, size)
    return string.format("R$%d", value)
end

-- Calculate RAP (Recent Average Price) for a collection of items
function ItemValueCalculator.CalculateRAP(inventory)
    local totalValue = 0
    local itemCount = 0
    
    for _, item in pairs(inventory) do
        if item.ItemName and item.ItemConfig then
            local value = ItemValueCalculator.GetValue(item.ItemConfig, item.MutationConfig, item.Size)
            totalValue = totalValue + value
            itemCount = itemCount + 1
        end
    end
    
    return totalValue, itemCount
end

function ItemValueCalculator.GetFormattedRAP(totalValue)
    if totalValue >= 1000000 then
        return string.format("R$%.1fM", totalValue / 1000000)
    elseif totalValue >= 1000 then
        return string.format("R$%.1fK", totalValue / 1000)
    else
        return string.format("R$%d", totalValue)
    end
end

return ItemValueCalculator 