local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local UnlockAnimationController = {}

-- Store original camera state
local originalCameraCFrame = nil
local originalCameraFieldOfView = nil

-- Animation settings
local ANIMATION_DURATION = 3 -- seconds
local TRANSITION_DURATION = 1 -- seconds
local FEATURE_POSITIONS = {
	Collection = Vector3.new(-25, 5, 0), -- Position near Collection area
	Enchanter = Vector3.new(25, 5, 0),  -- Position near Enchanter area
}

-- Function to save original camera state
local function saveOriginalCameraState()
	originalCameraCFrame = Camera.CFrame
	originalCameraFieldOfView = Camera.FieldOfView
end

-- Function to restore original camera state
local function restoreOriginalCameraState()
	if originalCameraCFrame and originalCameraFieldOfView then
		local restoreTween = TweenService:Create(
			Camera,
			TweenInfo.new(TRANSITION_DURATION, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{
				CFrame = originalCameraCFrame,
				FieldOfView = originalCameraFieldOfView
			}
		)
		restoreTween:Play()
	end
end

-- Function to animate feature unlock
local function animateFeatureUnlock(featureName)
	if not FEATURE_POSITIONS[featureName] then
		print("[UnlockAnimationController] No position defined for feature:", featureName)
		return
	end
	
	local targetPosition = FEATURE_POSITIONS[featureName]
	local targetCFrame = CFrame.new(targetPosition) * CFrame.Angles(math.rad(15), 0, 0)
	
	-- Move camera to feature
	local cameraTween = TweenService:Create(
		Camera,
		TweenInfo.new(TRANSITION_DURATION, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{
			CFrame = targetCFrame,
			FieldOfView = 50 -- Zoom in slightly
		}
	)
	cameraTween:Play()
	
	-- Wait for camera to reach position
	task.wait(TRANSITION_DURATION + 0.5)
	
	-- Animate the feature area (paint from black to colored)
	local featureArea = nil
	if featureName == "Collection" then
		featureArea = workspace:FindFirstChild("Collection")
	elseif featureName == "Enchanter" then
		featureArea = workspace:FindFirstChild("EnchantingArea")
	end
	
	if featureArea then
		-- Animate parts from black to colored
		local function animatePart(part)
			if part:IsA("BasePart") then
				local originalColor = nil
				if featureName == "Collection" then
					originalColor = Color3.fromRGB(100, 200, 255) -- Blue for collection
				elseif featureName == "Enchanter" then
					originalColor = Color3.fromRGB(150, 100, 255) -- Purple for enchanter
				end
				
				if originalColor then
					-- Start from black
					part.Color = Color3.fromRGB(20, 20, 20)
					part.Material = Enum.Material.Neon
					
					-- Animate to original color
					local colorTween = TweenService:Create(
						part,
						TweenInfo.new(ANIMATION_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{Color = originalColor}
					)
					colorTween:Play()
					
					-- Animate PointLight if it exists
					local pointLight = part:FindFirstChild("PointLight")
					if pointLight then
						local lightTween = TweenService:Create(
							pointLight,
							TweenInfo.new(ANIMATION_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{Color = originalColor, Brightness = 2}
						)
						lightTween:Play()
					end
				end
			end
			
			-- Recursively animate children
			for _, child in pairs(part:GetChildren()) do
				animatePart(child)
			end
		end
		
		-- Animate all parts in the feature area
		for _, part in pairs(featureArea:GetChildren()) do
			animatePart(part)
		end
		
		print("[UnlockAnimationController] Animated unlock for feature:", featureName)
	end
	
	-- Wait for animation to complete
	task.wait(ANIMATION_DURATION + 1)
	
	-- Restore camera
	restoreOriginalCameraState()
end

-- Function to show unlock celebration
local function showUnlockCelebration(featureName)
	-- Create celebration UI
	local playerGui = LocalPlayer:WaitForChild("PlayerGui")
	local celebrationGui = Instance.new("ScreenGui")
	celebrationGui.Name = "UnlockCelebration"
	celebrationGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	celebrationGui.Parent = playerGui
	
	-- Create celebration frame
	local celebrationFrame = Instance.new("Frame")
	celebrationFrame.Name = "CelebrationFrame"
	celebrationFrame.Size = UDim2.new(1, 0, 1, 0)
	celebrationFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	celebrationFrame.BackgroundTransparency = 0.8
	celebrationFrame.Parent = celebrationGui
	
	-- Create celebration text
	local celebrationText = Instance.new("TextLabel")
	celebrationText.Name = "CelebrationText"
	celebrationText.Size = UDim2.new(0, 600, 0, 100)
	celebrationText.Position = UDim2.new(0.5, -300, 0.4, -50)
	celebrationText.Text = "🔓 " .. featureName .. " UNLOCKED! 🔓"
	celebrationText.Font = Enum.Font.GothamBold
	celebrationText.TextSize = 36
	celebrationText.TextColor3 = Color3.fromRGB(255, 215, 0)
	celebrationText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	celebrationText.TextStrokeTransparency = 0
	celebrationText.BackgroundTransparency = 1
	celebrationText.ZIndex = 1000
	celebrationText.Parent = celebrationFrame
	
	-- Animate text appearance
	celebrationText.TextTransparency = 1
	local textTween = TweenService:Create(
		celebrationText,
		TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{TextTransparency = 0}
	)
	textTween:Play()
	
	-- Remove celebration after delay
	task.wait(3)
	celebrationGui:Destroy()
end

-- Main function to handle feature unlock animation
function UnlockAnimationController.PlayUnlockAnimation(featureName)
	print("[UnlockAnimationController] Starting unlock animation for:", featureName)
	
	-- Save original camera state
	saveOriginalCameraState()
	
	-- Show celebration
	showUnlockCelebration(featureName)
	
	-- Animate feature unlock
	animateFeatureUnlock(featureName)
end

-- Function to check for newly unlocked features after rebirth
function UnlockAnimationController.CheckForNewUnlocks(oldRebirthData, newRebirthData)
	if not oldRebirthData or not newRebirthData then
		return
	end
	
	local oldFeatures = oldRebirthData.unlockedFeatures or {}
	local newFeatures = newRebirthData.unlockedFeatures or {}
	
	-- Find newly unlocked features
	for _, newFeature in ipairs(newFeatures) do
		local wasUnlocked = false
		for _, oldFeature in ipairs(oldFeatures) do
			if oldFeature == newFeature then
				wasUnlocked = true
				break
			end
		end
		
		if not wasUnlocked then
			print("[UnlockAnimationController] New feature unlocked:", newFeature)
			-- Play unlock animation for this feature
			UnlockAnimationController.PlayUnlockAnimation(newFeature)
		end
	end
end

return UnlockAnimationController 