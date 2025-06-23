local ItemValueCalculator = {}

function ItemValueCalculator.GetValue(itemConfig, mutationConfigs, size)
    if not itemConfig then return 0 end

    local baseValue = itemConfig.Value or 0
    size = size or 1

    -- Apply mutation multipliers - handle both single mutation (backward compatibility) and multiple mutations
    local totalMultiplier = 1
    if mutationConfigs then
        if type(mutationConfigs) == "table" and #mutationConfigs > 0 then
            -- Multiple mutations - multiply all multipliers together
            for _, mutationConfig in ipairs(mutationConfigs) do
                if mutationConfig and mutationConfig.ValueMultiplier then
                    totalMultiplier = totalMultiplier * mutationConfig.ValueMultiplier
                end
            end
        elseif mutationConfigs.ValueMultiplier then
            -- Single mutation (backward compatibility)
            totalMultiplier = mutationConfigs.ValueMultiplier
        end
    end
    
    baseValue = baseValue * totalMultiplier

    -- Apply size multiplier
    baseValue = baseValue * size

    local finalValue = math.floor(baseValue)
    return math.max(1, finalValue)
end

function ItemValueCalculator.GetFormattedValue(itemConfig, mutationConfigs, size)
    local value = ItemValueCalculator.GetValue(itemConfig, mutationConfigs, size)
    return string.format("R$%d", value)
end

-- Calculate RAP (Recent Average Price) for a collection of items
function ItemValueCalculator.CalculateRAP(inventory)
    local totalValue = 0
    local itemCount = 0
    
    for _, item in pairs(inventory) do
        if item.ItemName and item.ItemConfig then
            -- Handle both old MutationConfig and new MutationConfigs
            local mutationConfigs = item.MutationConfigs or (item.MutationConfig and {item.MutationConfig}) or nil
            local value = ItemValueCalculator.GetValue(item.ItemConfig, mutationConfigs, item.Size)
            totalValue = totalValue + value
            itemCount = itemCount + 1
        end
    end
    
    return totalValue, itemCount
end

function ItemValueCalculator.GetFormattedRAP(totalValue)
	if totalValue >= 1e15 then
		return string.format("R$%.1fQ", totalValue / 1e15)
	elseif totalValue >= 1e12 then
		return string.format("R$%.1fT", totalValue / 1e12)
	elseif totalValue >= 1e9 then
		return string.format("R$%.1fB", totalValue / 1e9)
	elseif totalValue >= 1e6 then
		return string.format("R$%.1fM", totalValue / 1e6)
	elseif totalValue >= 1e3 then
		return string.format("R$%.1fK", totalValue / 1e3)
	else
		return string.format("R$%d", totalValue)
	end
end

-- Helper function to get mutation configs from an item instance
function ItemValueCalculator.GetMutationConfigs(itemInstance)
    local GameConfig = require(script.Parent.GameConfig)
    
    -- Check for new multiple mutations format first
    local mutationsJson = itemInstance:GetAttribute("Mutations")
    if mutationsJson then
        local HttpService = game:GetService("HttpService")
        local success, mutations = pcall(function()
            return HttpService:JSONDecode(mutationsJson)
        end)
        if success and mutations and #mutations > 0 then
            local mutationConfigs = {}
            for _, mutationName in ipairs(mutations) do
                local mutationConfig = GameConfig.Mutations[mutationName]
                if mutationConfig then
                    table.insert(mutationConfigs, mutationConfig)
                end
            end
            return mutationConfigs
        end
    end
    
    -- Fallback to single mutation for backward compatibility
    local singleMutation = itemInstance:GetAttribute("Mutation")
    if singleMutation then
        local mutationConfig = GameConfig.Mutations[singleMutation]
        if mutationConfig then
            return {mutationConfig}
        end
    end
    
    return nil
end

-- Helper function to get formatted mutation names from an item instance
function ItemValueCalculator.GetMutationNames(itemInstance)
    -- Check for new multiple mutations format first
    local mutationsJson = itemInstance:GetAttribute("Mutations")
    if mutationsJson then
        local HttpService = game:GetService("HttpService")
        local success, mutations = pcall(function()
            return HttpService:JSONDecode(mutationsJson)
        end)
        if success and mutations and #mutations > 0 then
            return mutations
        end
    end
    
    -- Fallback to single mutation for backward compatibility
    local singleMutation = itemInstance:GetAttribute("Mutation")
    if singleMutation then
        return {singleMutation}
    end
    
    return {}
end

return ItemValueCalculator 