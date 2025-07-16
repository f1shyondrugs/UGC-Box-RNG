-- Ensure all required remotes exist in ReplicatedStorage.Shared.Remotes before returning the Remotes table
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:FindFirstChild("Shared") or ReplicatedStorage:WaitForChild("Shared")
local RemotesFolder = Shared:FindFirstChild("Remotes") or Shared:WaitForChild("Remotes")

local requiredRemotes = {
    {type = "RemoteFunction", name = "GetAutoSettings"},
    {type = "RemoteEvent", name = "UpdateAutoSellSettings"},
    {type = "RemoteFunction", name = "CheckAutoOpenGamepass"},
    {type = "RemoteFunction", name = "CheckAutoSellGamepass"},
    {type = "RemoteEvent", name = "RequestBox"},
    {type = "RemoteEvent", name = "RequestOpen"},
    {type = "RemoteEvent", name = "SellItem"},
    {type = "RemoteEvent", name = "InventoryLoadComplete"},
    {type = "RemoteFunction", name = "GetPlayerSettings"},
    {type = "RemoteEvent", name = "SaveSetting"},
    {type = "RemoteFunction", name = "GetSelectedCrate"},
    {type = "RemoteEvent", name = "SaveSelectedCrate"},
    -- Add any other remotes you use here
}
for _, def in ipairs(requiredRemotes) do
    if not RemotesFolder:FindFirstChild(def.name) then
        local remote = Instance.new(def.type)
        remote.Name = def.name
        remote.Parent = RemotesFolder
    end
end

local Remotes = {}

local function createRemote(remoteType, name)
	local remote = script.Parent:FindFirstChild(name)
	if remote then
		return remote
	end

	remote = Instance.new(remoteType)
	remote.Name = name
	remote.Parent = script.Parent
	return remote
end

return {
	RequestBox = createRemote("RemoteEvent", "RequestBox"),
	RequestOpen = createRemote("RemoteEvent", "RequestOpen"),
	PlayAnimation = createRemote("RemoteEvent", "PlayAnimation"),
	AnimationComplete = createRemote("RemoteEvent", "AnimationComplete"),
	Notify = createRemote("RemoteEvent", "Notify"),
	ShowFloatingError = createRemote("RemoteEvent", "ShowFloatingError"),
	ShowFloatingNotification = createRemote("RemoteEvent", "ShowFloatingNotification"),
	ShowCelebrationEffect = createRemote("RemoteEvent", "ShowCelebrationEffect"),
	SellItem = createRemote("RemoteEvent", "SellItem"),
	BoxLanded = createRemote("RemoteEvent", "BoxLanded"),
	UpdateBoxCount = createRemote("RemoteEvent", "UpdateBoxCount"),
	SellAllItems = createRemote("RemoteEvent", "SellAllItems"),
	SellUnlockedItems = createRemote("RemoteEvent", "SellUnlockedItems"),
	ToggleItemLock = createRemote("RemoteEvent", "ToggleItemLock"),
	StartFreeCrateCooldown = createRemote("RemoteEvent", "StartFreeCrateCooldown"),
	InventoryLoadComplete = createRemote("RemoteEvent", "InventoryLoadComplete"),
	
	-- Rebirth System
	GetRebirthData = createRemote("RemoteFunction", "GetRebirthData"),
	GetUnlockedCrates = createRemote("RemoteFunction", "GetUnlockedCrates"),
	GetUnlockedFeatures = createRemote("RemoteFunction", "GetUnlockedFeatures"),
	PerformRebirth = createRemote("RemoteFunction", "PerformRebirth"),
	RebirthUpdated = createRemote("RemoteEvent", "RebirthUpdated"),
	
	-- Avatar/Equipment Remotes
	EquipItem = createRemote("RemoteEvent", "EquipItem"),
	UnequipItem = createRemote("RemoteEvent", "UnequipItem"),
	GetEquippedItems = createRemote("RemoteFunction", "GetEquippedItems"),
	EquipStatusChanged = createRemote("RemoteEvent", "EquipStatusChanged"),
	
	-- Asset Loading Remotes
	LoadAssetForPreview = createRemote("RemoteFunction", "LoadAssetForPreview"),
	
	-- Collection Remotes
	GetPlayerCollection = createRemote("RemoteFunction", "GetPlayerCollection"),
	
	-- Upgrade Remotes
	PurchaseUpgrade = createRemote("RemoteEvent", "PurchaseUpgrade"),
	GetUpgradeData = createRemote("RemoteFunction", "GetUpgradeData"),
	UpgradeUpdated = createRemote("RemoteEvent", "UpgradeUpdated"),
	MaxBoxesUpdated = createRemote("RemoteEvent", "MaxBoxesUpdated"),
	CooldownUpdated = createRemote("RemoteEvent", "CooldownUpdated"),
	
	-- Settings Remotes
	SaveSetting = createRemote("RemoteEvent", "SaveSetting"),
	GetPlayerSettings = createRemote("RemoteFunction", "GetPlayerSettings"),
	
	-- Enchanter Remotes
	OpenEnchanter = createRemote("RemoteEvent", "OpenEnchanter"),
	RerollMutators = createRemote("RemoteEvent", "RerollMutators"),
	GetEnchanterData = createRemote("RemoteFunction", "GetEnchanterData"),
	GetMutatorProbabilities = createRemote("RemoteFunction", "GetMutatorProbabilities"),
	
	-- Auto-Enchanter Remotes
	CheckAutoEnchanterGamepass = createRemote("RemoteFunction", "CheckAutoEnchanterGamepass"),
	StartAutoEnchanting = createRemote("RemoteEvent", "StartAutoEnchanting"),
	StopAutoEnchanting = createRemote("RemoteEvent", "StopAutoEnchanting"),
	AutoEnchantingProgress = createRemote("RemoteEvent", "AutoEnchantingProgress"),
	UpdateEnchanterVisual = createRemote("RemoteEvent", "UpdateEnchanterVisual"),
	RecreateEnchanterPrompt = createRemote("RemoteEvent", "RecreateEnchanterPrompt"),
	
	-- Auto-Open Remotes
	CheckAutoOpenGamepass = createRemote("RemoteFunction", "CheckAutoOpenGamepass"),
	
	-- Auto-Sell Remotes
	CheckAutoSellGamepass = createRemote("RemoteFunction", "CheckAutoSellGamepass"),
	AutoSellItem = createRemote("RemoteEvent", "AutoSellItem"),
	UpdateAutoSellSettings = createRemote("RemoteEvent", "UpdateAutoSellSettings"),
	
	-- Infinite Storage Remotes
	CheckInfiniteStorageGamepass = createRemote("RemoteFunction", "CheckInfiniteStorageGamepass"),
	
	-- New RemoteFunction
	GetAutoSettings = createRemote("RemoteFunction", "GetAutoSettings"),
	
	-- Selected Crate Remotes
	SaveSelectedCrate = createRemote("RemoteEvent", "SaveSelectedCrate"),
	GetSelectedCrate = createRemote("RemoteFunction", "GetSelectedCrate"),
	
	-- Tutorial Remotes
	SaveTutorialCompletion = createRemote("RemoteEvent", "SaveTutorialCompletion"),
	CheckTutorialCompletion = createRemote("RemoteFunction", "CheckTutorialCompletion"),
}