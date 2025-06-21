-- CollisionService.lua
-- This service sets up all necessary collision groups for the game.
-- It should be run once when the server starts.

local PhysicsService = game:GetService("PhysicsService")

local CollisionService = {}

function CollisionService.Start()
	local groupName = "FallingBox"

	-- Register the collision group, wrapped in a pcall in case the script re-runs.
	local success, result = pcall(function()
		PhysicsService:RegisterCollisionGroup(groupName)
	end)
	if not success and not string.find(result, "already exists") then
		warn("Failed to create collision group:", result)
		return
	end

	-- Set the group to NOT collide with itself.
	PhysicsService:CollisionGroupSetCollidable(groupName, groupName, false)
	
	print("Collision group '" .. groupName .. "' configured successfully.")
end

return CollisionService 