local NumberFormatter = {}

-- Format a number with appropriate suffix (K, M, B, T, Qa, Qi, Sx, Sp, Oc, No, Dc)
function NumberFormatter.FormatNumber(value, options)
	options = options or {}
	local decimals = options.decimals or 1
	local forceInteger = options.forceInteger or false
	
	-- Convert to number if it's a string
	if type(value) == "string" then
		value = tonumber(value) or 0
	end
	
	if not value or value ~= value then -- Check for nil and NaN
		return "0"
	end
	
	value = math.abs(value) -- Handle negative numbers by taking absolute value
	
	if value >= 1e33 then
		return string.format("%." .. decimals .. "fDc", value / 1e33)
	elseif value >= 1e30 then
		return string.format("%." .. decimals .. "fNo", value / 1e30)
	elseif value >= 1e27 then
		return string.format("%." .. decimals .. "fOc", value / 1e27)
	elseif value >= 1e24 then
		return string.format("%." .. decimals .. "fSp", value / 1e24)
	elseif value >= 1e21 then
		return string.format("%." .. decimals .. "fSx", value / 1e21)
	elseif value >= 1e18 then
		return string.format("%." .. decimals .. "fQi", value / 1e18)
	elseif value >= 1e15 then
		return string.format("%." .. decimals .. "fQa", value / 1e15)
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
	
	-- Convert to number if it's a string
	if type(value) == "string" then
		value = tonumber(value) or 0
	end
	
	if not value or value ~= value then
		return "0%"
	end
	
	if value >= 100 then
		return string.format("%.0f%%", value)
	elseif value >= 10 then
		return string.format("%.1f%%", value)
	elseif value >= 1 then
		return string.format("%.2f%%", value)
	elseif value >= 0.1 then
		return string.format("%.3f%%", value)
	elseif value >= 0.01 then
		return string.format("%.4f%%", value)
	elseif value >= 0.001 then
		return string.format("%.5f%%", value)
	elseif value >= 0.0001 then
		return string.format("%.6f%%", value)
	elseif value >= 0.00001 then
		return string.format("%.7f%%", value)
	elseif value >= 0.000001 then
		return string.format("%.8f%%", value)
	elseif value >= 0.0000001 then
		return string.format("%.9f%%", value)
	elseif value >= 0.00000001 then
		return string.format("%.10f%%", value)
	elseif value >= 0.000000001 then
		return string.format("%.11f%%", value)
	elseif value >= 0.0000000001 then
		return string.format("%.12f%%", value)
	elseif value >= 0.00000000001 then
		return string.format("%.13f%%", value)
	elseif value >= 0.000000000001 then
		return string.format("%.14f%%", value)
	elseif value >= 0.0000000000001 then
		return string.format("%.15f%%", value)
	elseif value >= 0.00000000000001 then
		return string.format("%.16f%%", value)
	elseif value >= 0.000000000000001 then
		return string.format("%.17f%%", value)
	elseif value >= 0.0000000000000001 then
		return string.format("%.18f%%", value)
	elseif value >= 0.00000000000000001 then
		return string.format("%.19f%%", value)
	elseif value >= 0.000000000000000001 then
		return string.format("%.20f%%", value)
	else
		return string.format("%.21f%%", value)
	end
end

-- Format size/multiplier (always shows decimals)
function NumberFormatter.FormatSize(value, options)
	options = options or {}
	local decimals = options.decimals or 2
	
	-- Convert to number if it's a string
	if type(value) == "string" then
		value = tonumber(value) or 0
	end
	
	if not value or value ~= value then
		return "0.00"
	end
	
	return string.format("%." .. decimals .. "f", value)
end

-- Format count/integer (no decimals, with suffixes for large numbers)
function NumberFormatter.FormatCount(value)
	-- Convert to number if it's a string
	if type(value) == "string" then
		value = tonumber(value) or 0
	end
	
	if not value or value ~= value then
		return "0"
	end
	
	return NumberFormatter.FormatNumber(value, {decimals = 0, forceInteger = true})
end

-- Parse formatted numbers back to full numeric values
function NumberFormatter.ParseFormattedNumber(formattedString)
	if not formattedString or type(formattedString) ~= "string" then
		return 0
	end
	
	-- Remove any non-alphanumeric characters except decimal points and spaces
	local cleanString = string.gsub(formattedString, "[^%w%.%s]", "")
	
	-- Extract the number and suffix - improved regex to handle various formats
	local number, suffix = string.match(cleanString, "([%d%.]+)%s*([%a]*)")
	
	if not number then
		return 0
	end
	
	local numericValue = tonumber(number)
	if not numericValue then
		return 0
	end
	
	-- Apply multiplier based on suffix (matching FormatNumber exactly)
	local multiplier = 1
	if suffix and suffix ~= "" then
		-- Convert to uppercase for comparison, but handle mixed case from formatting
		local upperSuffix = string.upper(suffix)
		if upperSuffix == "K" then
			multiplier = 1e3
		elseif upperSuffix == "M" then
			multiplier = 1e6
		elseif upperSuffix == "B" then
			multiplier = 1e9
		elseif upperSuffix == "T" then
			multiplier = 1e12
		elseif upperSuffix == "QA" then
			multiplier = 1e15
		elseif upperSuffix == "QI" then
			multiplier = 1e18
		elseif upperSuffix == "SX" then
			multiplier = 1e21
		elseif upperSuffix == "SP" then
			multiplier = 1e24
		elseif upperSuffix == "OC" then
			multiplier = 1e27
		elseif upperSuffix == "NO" then
			multiplier = 1e30
		elseif upperSuffix == "DC" then
			multiplier = 1e33
		end
	end
	
	local result = numericValue * multiplier
	return result
end

return NumberFormatter