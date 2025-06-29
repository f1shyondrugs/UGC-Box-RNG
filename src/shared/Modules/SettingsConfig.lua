local SettingsConfig = {}

-- Settings definitions with descriptions and default values
SettingsConfig.Settings = {
	DisableEffects = {
		Name = "Disable Effects",
		Description = "Turn off visual effects for better performance",
		DefaultValue = false,
		Icon = "✨",
		Category = "Performance"
	},
	
	HideOtherPlayers = {
		Name = "Hide Other Players",
		Description = "Hide other players for a cleaner experience",
		DefaultValue = false,
		Icon = "👤",
		Category = "Display"
	},
	
	ShowOthersCrates = {
		Name = "Show Others' Crates",
		Description = "See other players' crate opening animations",
		DefaultValue = false,
		Icon = "📦",
		Category = "Display"
	},
	
	FloatingTextSize = {
		Name = "Floating Text Size",
		Description = "Adjust the size of text that appears when opening crates",
		DefaultValue = 1.0,
		MinValue = 0.3,
		MaxValue = 2.0,
		Icon = "🔤",
		Category = "Display",
		Type = "Slider"
	}
}

-- Get all setting IDs
function SettingsConfig.GetAllSettingIds()
	local ids = {}
	for id, _ in pairs(SettingsConfig.Settings) do
		table.insert(ids, id)
	end
	return ids
end

-- Get setting by ID
function SettingsConfig.GetSetting(settingId)
	return SettingsConfig.Settings[settingId]
end

-- Get settings by category
function SettingsConfig.GetSettingsByCategory(category)
	local categorySettings = {}
	for id, setting in pairs(SettingsConfig.Settings) do
		if setting.Category == category then
			categorySettings[id] = setting
		end
	end
	return categorySettings
end

return SettingsConfig 