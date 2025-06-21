-- NameplateController.lua
-- This controller manages creating, updating, and cleaning up player nameplates.

local Players = game:GetService("Players")
local NameplateUI = require(script.Parent.UI.NameplateUI)

local NameplateController = {}

local activeNameplates = {} -- Keep track of nameplates to manage connections

local function setupNameplate(player)
	player.CharacterAdded:Connect(function(character)
		-- Clean up old nameplate if it exists, to prevent duplicates
		if activeNameplates[player.UserId] then
			activeNameplates[player.UserId].BillboardGui:Destroy()
			activeNameplates[player.UserId] = nil
		end

		local head = character:WaitForChild("Head")
		local leaderstats = player:WaitForChild("leaderstats")
		local rapStat = leaderstats:WaitForChild("RAP")
		
		-- Create the UI
		local uiComponents = NameplateUI.Create(player)
		uiComponents.BillboardGui.Parent = head
		
		-- Initial update
		NameplateUI.UpdateRAP(uiComponents, rapStat.Value)
		
		-- Listen for changes to the RAP stat
		local connection = rapStat.Changed:Connect(function(newValue)
			NameplateUI.UpdateRAP(uiComponents, newValue)
		end)
		
		-- Store for cleanup
		activeNameplates[player.UserId] = {
			BillboardGui = uiComponents.BillboardGui,
			Connection = connection
		}
	end)
end

function NameplateController.Start()
	-- Handle players joining the game
	Players.PlayerAdded:Connect(setupNameplate)
	
	-- Handle players already in the game when the script starts
	for _, player in ipairs(Players:GetPlayers()) do
		task.spawn(setupNameplate, player)
		-- Also handle if their character is already loaded
		if player.Character then
			setupNameplate(player)
			player.CharacterAdded:Send() -- Manually trigger to create the nameplate
		end
	end
	
	-- Handle players leaving
	Players.PlayerRemoving:Connect(function(player)
		if activeNameplates[player.UserId] then
			activeNameplates[player.UserId].Connection:Disconnect()
			activeNameplates[player.UserId] = nil
		end
	end)

	print("NameplateController Started.")
end

return NameplateController 