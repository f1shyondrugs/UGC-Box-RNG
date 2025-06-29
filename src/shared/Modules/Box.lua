local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Box = {}
Box.__index = Box

function Box.new(owner: Player)
	local self = setmetatable({}, Box)

	-- Try to get the custom crate model from ReplicatedStorage
	local customCrateSuccess, customCrate = pcall(function()
		return ReplicatedStorage.Models.Crates.Crate
	end)
	
	if customCrateSuccess and customCrate then
		-- Clone the custom crate
		local crateClone = customCrate:Clone()
		local actualPart = nil
		
		-- Handle different types of custom crates
		if crateClone:IsA("BasePart") then
			-- It's a UnionPart or regular Part
			actualPart = crateClone
		elseif crateClone:IsA("Model") then
			-- It's a Model, find the main part inside
			actualPart = crateClone.PrimaryPart or crateClone:FindFirstChildOfClass("BasePart")
			if not actualPart then
				warn("Custom crate model has no PrimaryPart or BasePart, using default Part")
				crateClone:Destroy()
				actualPart = nil
			end
		end
		
		if actualPart then
			-- Set up the properties on the actual part
			actualPart.Anchored = true -- Must be anchored for tweening
			actualPart.CanCollide = false -- No collisions during the animation
			actualPart.Transparency = 1 -- Start invisible
			actualPart:SetAttribute("Owner", owner.UserId)
			
			-- Create and attach the ProximityPrompt to the actual part
			local prompt = Instance.new("ProximityPrompt")
			prompt.ActionText = "Open Box"
			prompt.ObjectText = "Box"
			prompt.KeyboardKeyCode = Enum.KeyCode.E
			prompt.RequiresLineOfSight = false
			prompt.Parent = actualPart

			-- Store the actual part (not the model) for consistency
			self.Part = actualPart
			self.Prompt = prompt
			
			-- If it was a model, we need to keep track of it for cleanup
			if crateClone:IsA("Model") then
				self.Model = crateClone
			end
		else
			-- Fallback if we couldn't find a usable part
			warn("Could not find usable part in custom crate, using default Part")
			if crateClone and crateClone.Parent then
				crateClone:Destroy()
			end
			actualPart = nil
		end
	end
	
	-- Fallback to the original method if custom crate failed
	if not self.Part then
		warn("Custom crate model not found or unusable at ReplicatedStorage.Models.Crates.Crate, using default Part")
		
		local boxPart = Instance.new("Part")
		boxPart.Size = Vector3.new(4, 4, 4)
		boxPart.Anchored = true -- Must be anchored for tweening
		boxPart.CanCollide = false -- No collisions during the animation
		boxPart.Transparency = 1 -- Start invisible
		boxPart:SetAttribute("Owner", owner.UserId)
		
		local prompt = Instance.new("ProximityPrompt")
		prompt.ActionText = "Open Box"
		prompt.ObjectText = "Box"
		prompt.KeyboardKeyCode = Enum.KeyCode.E
		prompt.RequiresLineOfSight = false
		prompt.Parent = boxPart

		self.Part = boxPart
		self.Prompt = prompt
	end

	return self
end

function Box:Destroy()
	-- Destroy the model if it exists, otherwise just the part
	if self.Model then
		self.Model:Destroy()
	else
		self.Part:Destroy()
	end
end

function Box:SetParent(parent)
	-- Set parent of the model if it exists, otherwise just the part
	if self.Model then
		self.Model.Parent = parent
	else
		self.Part.Parent = parent
	end
end

function Box:SetPosition(position)
	self.Part.Position = position
end

return Box 