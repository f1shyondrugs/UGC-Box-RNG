local RunService = game:GetService("RunService")

local CameraShaker = {}
local activeShakes = {}

local function processShake(shake)
	local t = (tick() - shake.startTime) / shake.duration
	if t >= 1 then
		return nil -- This shake is over, request removal
	end

	local amplitude = shake.amplitude * (1 - t) -- Fade out
	local randomOffset = Vector3.new(
		math.random() * 2 - 1,
		math.random() * 2 - 1,
		math.random() * 2 - 1
	) * amplitude
	
	return randomOffset
end

function CameraShaker.Start()
	RunService.RenderStepped:Connect(function()
		if #activeShakes == 0 then return end
		
		local totalOffset = Vector3.new()
        local shakesToRemove = {}

		for i, shake in ipairs(activeShakes) do
            local offset = processShake(shake)
            if offset then
			    totalOffset = totalOffset + offset
            else
                table.insert(shakesToRemove, i)
            end
		end

        -- Remove finished shakes (iterate backwards to not mess up indices)
        for i = #shakesToRemove, 1, -1 do
            table.remove(activeShakes, shakesToRemove[i])
        end

        if totalOffset.Magnitude > 0 then
		    workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame * CFrame.new(totalOffset)
        end
	end)
end

function CameraShaker.Shake(duration, amplitude)
    local newShake = {
		startTime = tick(),
		duration = duration,
		amplitude = amplitude
	}
	table.insert(activeShakes, newShake)
end

return CameraShaker 