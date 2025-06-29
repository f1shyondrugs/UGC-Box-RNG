local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Box = {}
Box.__index = Box

function Box.new(owner: Player, crateId: string)
	local self = setmetatable({}, Box)

	-- Always use the same crate model from ReplicatedStorage.Models.Crates.Crate
	local customCrate = nil
	if ReplicatedStorage:FindFirstChild("Models") then
		local cratesFolder = ReplicatedStorage.Models:FindFirstChild("Crates")
		if cratesFolder then
			customCrate = cratesFolder:FindFirstChild("Crate")
		end
	end

	if customCrate then
		local crateClone = customCrate:Clone()
		local actualPart = nil
		if crateClone:IsA("BasePart") then
			actualPart = crateClone
		elseif crateClone:IsA("Model") then
			actualPart = crateClone.PrimaryPart or crateClone:FindFirstChildOfClass("BasePart")
			if not actualPart then
				warn("Custom crate model has no PrimaryPart or BasePart, using default Part")
				crateClone:Destroy()
				actualPart = nil
			end
		end
		if actualPart then
			actualPart.Anchored = true
			actualPart.CanCollide = false
			actualPart.Transparency = 1
			actualPart:SetAttribute("Owner", owner.UserId)
			local prompt = Instance.new("ProximityPrompt")
			prompt.ActionText = "Open Box"
			prompt.ObjectText = "Box"
			prompt.KeyboardKeyCode = Enum.KeyCode.E
			prompt.RequiresLineOfSight = false
			prompt.Parent = actualPart
			self.Part = actualPart
			self.Prompt = prompt
			if crateClone:IsA("Model") then
				self.Model = crateClone
			end
		else
			warn("Could not find usable part in custom crate, using default Part")
			if crateClone and crateClone.Parent then
				crateClone:Destroy()
			end
			actualPart = nil
		end
	end

	if not self.Part then
		warn("Custom crate model not found or unusable at ReplicatedStorage.Models.Crates.Crate, using default Part")
		local boxPart = Instance.new("Part")
		boxPart.Size = Vector3.new(4, 4, 4)
		boxPart.Anchored = true
		boxPart.CanCollide = false
		boxPart.Transparency = 1
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
	if self.Model then
		self.Model:Destroy()
	else
		self.Part:Destroy()
	end
end

function Box:SetParent(parent)
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