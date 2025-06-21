local Box = {}
Box.__index = Box

function Box.new(owner: Player)
	local self = setmetatable({}, Box)

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

	return self
end

function Box:Destroy()
	self.Part:Destroy()
end

function Box:SetParent(parent)
	self.Part.Parent = parent
end

function Box:SetPosition(position)
	self.Part.Position = position
end

return Box 