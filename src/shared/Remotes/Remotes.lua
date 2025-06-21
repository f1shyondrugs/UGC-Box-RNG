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
	SellItem = createRemote("RemoteEvent", "SellItem"),
	BoxLanded = createRemote("RemoteEvent", "BoxLanded"),
	UpdateBoxCount = createRemote("RemoteEvent", "UpdateBoxCount"),
	SellAllItems = createRemote("RemoteEvent", "SellAllItems"),
	ToggleItemLock = createRemote("RemoteEvent", "ToggleItemLock"),
	StartFreeCrateCooldown = createRemote("RemoteEvent", "StartFreeCrateCooldown"),
	
	-- Avatar/Equipment Remotes
	EquipItem = createRemote("RemoteEvent", "EquipItem"),
	UnequipItem = createRemote("RemoteEvent", "UnequipItem"),
	GetEquippedItems = createRemote("RemoteFunction", "GetEquippedItems"),
} 