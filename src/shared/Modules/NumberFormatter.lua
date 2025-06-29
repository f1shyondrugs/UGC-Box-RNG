local NumberFormatter = {}

-- Format a number with appropriate suffix (K, M, B, T, Q)
function NumberFormatter.FormatNumber(value, options)
	options = options or {}
	local decimals = options.decimals or 1
	local forceInteger = options.forceInteger or false
	
	if not value or value ~= value then -- Check for nil and NaN
		return "0"
	end
	
	value = math.abs(value) -- Handle negative numbers by taking absolute value
	
	if value >= 1e15 then
		return string.format("%." .. decimals .. "fQ", value / 1e15)
	elseif value >= 1e12 then
		return string.format("%." .. decimals .. "fT", value / 1e12)
	elseif value >= 1e9 then
		return string.format("%." .. decimals .. "fB", value / 1e9)
	elseif value >= 1e6 then
		return string.format("%." .. decimals .. "fM", value / 1e6)
	elseif value >= 1e3 then
		return string.format("%." .. decimals .. "fK", value / 1e3)
	else
		if forceInteger or value == math.floor(value) then
			return string.format("%d", value)
		else
			return string.format("%." .. decimals .. "f", value)
		end
	end
end

-- Format currency (adds R$ prefix)
function NumberFormatter.FormatCurrency(value, options)
	return "R$" .. NumberFormatter.FormatNumber(value, options)
end

-- Format percentage
function NumberFormatter.FormatPercentage(value, options)
	options = options or {}
	local decimals = options.decimals or 1
	
	if not value or value ~= value then
		return "0%"
	end
	
	if value >= 10 then
		return string.format("%.1f%%", value)
	elseif value >= 1 then
		return string.format("%.2f%%", value)
	elseif value >= 0.1 then
		return string.format("%.3f%%", value)
	elseif value >= 0.01 then
		return string.format("%.4f%%", value)
	elseif value >= 0.001 then
		return string.format("%.5f%%", value)
	else
		return string.format("%.6f%%", value)
	end
end

-- Format size/multiplier (always shows decimals)
function NumberFormatter.FormatSize(value, options)
	options = options or {}
	local decimals = options.decimals or 2
	
	if not value or value ~= value then
		return "0.00"
	end
	
	return string.format("%." .. decimals .. "f", value)
end

-- Format count/integer (no decimals, with suffixes for large numbers)
function NumberFormatter.FormatCount(value)
	if not value or value ~= value then
		return "0"
	end
	
	return NumberFormatter.FormatNumber(value, {decimals = 0, forceInteger = true})
end

return NumberFormatter 