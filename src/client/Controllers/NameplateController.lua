-- NameplateController.lua
-- This controller manages creating, updating, and cleaning up player nameplates.

local Players = game:GetService("Players")
local NameplateUI = require(script.Parent.Parent.UI.NameplateUI)

local NameplateController = {}

local activeNameplates = {} -- Keep track of nameplates to manage connections

local function createNameplateForCharacter(player, character)
	-- Clean up old nameplate if it exists, to prevent duplicates
	if activeNameplates[player.UserId] then
		if activeNameplates[player.UserId].Connection then
			activeNameplates[player.UserId].Connection:Disconnect()
		end
		if activeNameplates[player.UserId].BillboardGui then
			activeNameplates[player.UserId].BillboardGui:Destroy()
		end
		activeNameplates[player.UserId] = nil
	end

	local head = character:WaitForChild("Head")
	
	-- Create the UI
	local uiComponents = NameplateUI.Create(player)
	uiComponents.BillboardGui.Parent = head
	
	-- Initial update using player attribute
	local rapValue = player:GetAttribute("RAPValue") or 0
	NameplateUI.UpdateRAP(uiComponents, rapValue, player)
	
	-- Listen for changes to the RAP attribute
	local connection = player:GetAttributeChangedSignal("RAPValue"):Connect(function()
		local newValue = player:GetAttribute("RAPValue") or 0
		NameplateUI.UpdateRAP(uiComponents, newValue, player)
	end)
	
	-- Store for cleanup
	activeNameplates[player.UserId] = {
		BillboardGui = uiComponents.BillboardGui,
		Connection = connection
	}
end

local function setupPlayer(player)
	-- Create nameplate when character is added (or respawns)
	player.CharacterAdded:Connect(function(character)
		createNameplateForCharacter(player, character)
	end)

	-- If character already exists, create nameplate immediately
	if player.Character then
		createNameplateForCharacter(player, player.Character)
	end
end

function NameplateController.Start()
	-- Handle players joining the game
	Players.PlayerAdded:Connect(setupPlayer)
	
	-- Handle players already in the game when the script starts
	for _, player in ipairs(Players:GetPlayers()) do
		setupPlayer(player)
	end
	
	-- Handle players leaving
	Players.PlayerRemoving:Connect(function(player)
		if activeNameplates[player.UserId] then
			if activeNameplates[player.UserId].Connection then
				activeNameplates[player.UserId].Connection:Disconnect()
			end
			if activeNameplates[player.UserId].BillboardGui then
				activeNameplates[player.UserId].BillboardGui:Destroy()
			end
			activeNameplates[player.UserId] = nil
		end
	end)

	print("NameplateController Started.")
end

return NameplateController 