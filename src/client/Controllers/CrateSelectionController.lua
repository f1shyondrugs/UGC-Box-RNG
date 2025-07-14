local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local Shared = ReplicatedStorage.Shared

local GameConfig = require(Shared.Modules.GameConfig)
local CrateSelectionUI = require(script.Parent.Parent.UI.CrateSelectionUI)
local Remotes = require(Shared.Remotes.Remotes)

local CrateSelectionController = {}
CrateSelectionController.ClassName = "CrateSelectionController"

-- State
local components = nil
local isVisible = false
local crateCards = {}
local selectedCrate = "FreeCrate" -- Default selection
local modelConnections = {}
local hiddenUIs = {}

-- Store for rotation tweens
local rotationTweens = {}

local function hideOtherUIs(show)
	local playerGui = LocalPlayer:WaitForChild("PlayerGui")
	if show then
		for _, gui in pairs(playerGui:GetChildren()) do
			if gui:IsA("ScreenGui") and gui ~= (components and components.ScreenGui) then
				if gui.Enabled then
					hiddenUIs[gui] = true
					gui.Enabled = false
				end
			end
		end
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
	else
		for gui, _ in pairs(hiddenUIs) do
			if gui and gui.Parent then
				gui.Enabled = true
			end
		end
		hiddenUIs = {}
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
	end
end

function CrateSelectionController:Start()
	print("[CrateSelectionController] Starting...")
	
	-- Create UI components
	components = CrateSelectionUI.Create(LocalPlayer.PlayerGui)
	
	-- Set up connections
	self:SetupConnections()
	
	-- Load selected crate from server
	self:LoadSelectedCrateFromServer()
	
	-- Initialize crates
	self:InitializeCrates()
	
	print("[CrateSelectionController] Started successfully!")
end

function CrateSelectionController:SetupConnections()
	-- Close button connection
	components.CloseButton.MouseButton1Click:Connect(function()
		self:Hide()
	end)
	
	-- Handle UI scaling when viewport changes
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		if components.UpdateScale then
			components.UpdateScale()
		end
	end)
end

function CrateSelectionController:LoadSelectedCrateFromServer()
	-- Load selected crate from server
	local success, serverSelectedCrate = pcall(function()
		return Remotes.GetSelectedCrate:InvokeServer()
	end)
	
	if success and serverSelectedCrate then
		-- Validate that the crate exists in GameConfig
		if GameConfig.Boxes[serverSelectedCrate] then
			selectedCrate = serverSelectedCrate
			print("[CrateSelectionController] Loaded selected crate from server:", serverSelectedCrate)
		else
			print("[CrateSelectionController] Server returned invalid crate:", serverSelectedCrate .. ", using default")
			selectedCrate = "FreeCrate"
		end
	else
		print("[CrateSelectionController] Failed to load selected crate from server, using default")
		selectedCrate = "FreeCrate"
	end
end

function CrateSelectionController:InitializeCrates()
	if not GameConfig or not GameConfig.Boxes then
		warn("[CrateSelectionController] GameConfig or Boxes not found!")
		return
	end
	
	-- Get unlocked crates from server
	local unlockedCrates = {}
	local success, result = pcall(function()
		return Remotes.GetUnlockedCrates:InvokeServer()
	end)
	if success and result then
		unlockedCrates = result
	else
		-- Fallback to default unlocked crates
		unlockedCrates = {"FreeCrate", "StarterCrate", "PremiumCrate"}
	end
	
	-- Clear existing cards
	for _, card in pairs(crateCards) do
		card:Destroy()
	end
	crateCards = {}
	
	-- Gather and sort crates by price (FreeCrate always first)
	local crateList = {}
	for crateName, crateConfig in pairs(GameConfig.Boxes) do
		table.insert(crateList, {name = crateName, config = crateConfig})
	end
	table.sort(crateList, function(a, b)
		if a.name == "FreeCrate" then return true end
		if b.name == "FreeCrate" then return false end
		return (a.config.Price or 0) < (b.config.Price or 0)
	end)
	
	for i, crate in ipairs(crateList) do
		local crateName = crate.name
		local crateConfig = crate.config
		local isUnlocked = false
		
		-- Check if crate is unlocked
		for _, unlockedCrate in ipairs(unlockedCrates) do
			if unlockedCrate == crateName then
				isUnlocked = true
				break
			end
		end
		
		local isSelected = (crateName == selectedCrate)
		local card = CrateSelectionUI.CreateCrateCard(crateName, crateConfig, isSelected, isUnlocked)
		card.LayoutOrder = i
		card.Parent = components.CratesContainer
		
		local selectButton = card:FindFirstChild("SelectButton")
		if selectButton then
			selectButton.MouseButton1Click:Connect(function()
				if isUnlocked then
					self:SelectCrate(crateName)
				else
					-- Show locked message
					print("[CrateSelectionController] Crate " .. crateName .. " is locked!")
				end
			end)
		end
		
		local crateViewport = card:FindFirstChild("CrateViewport")
		self:LoadCrateModel(crateViewport, crateName, crateConfig)
		crateCards[crateName] = card
	end
end

function CrateSelectionController:LoadCrateModel(viewport, crateName, crateConfig)
	-- Create camera for viewport
	local camera = Instance.new("Camera")
	camera.Parent = viewport
	viewport.CurrentCamera = camera
	
	-- Try to find the crate model
	local crateModel = nil
	
	-- Check if there's a Models folder in ReplicatedStorage
	local modelsFolder = ReplicatedStorage:FindFirstChild("Models")
	if modelsFolder then
		local cratesFolder = modelsFolder:FindFirstChild("Crates")
		if cratesFolder then
			crateModel = cratesFolder:FindFirstChild(crateName)
		end
	end
	
	-- Fallback: create a simple crate if no model found
	if not crateModel then
		crateModel = self:CreateFallbackCrate(crateName, crateConfig)
	else
		-- Clone the model
		crateModel = crateModel:Clone()
	end
	
	-- Set up the model in viewport
	if crateModel then
		crateModel.Parent = viewport
		
			-- Position camera to show the model nicely
	local cf, size
	if crateModel:IsA("Model") then
		cf, size = crateModel:GetBoundingBox()
	else
		-- For UnionOperation or other objects, calculate bounding box manually
		if crateModel:IsA("BasePart") or crateModel:IsA("UnionOperation") then
			-- For BasePart or UnionOperation, use the object itself
			cf = crateModel.CFrame
			size = crateModel.Size
		else
			-- For other objects, try to find a BasePart
			local basePart = crateModel:FindFirstChildOfClass("BasePart")
			if basePart then
				cf = basePart.CFrame
				size = basePart.Size
			else
				-- Fallback for any object
				cf = CFrame.new()
				size = Vector3.new(4, 4, 4)
			end
		end
	end
	
	local distance = math.max(size.X, size.Y, size.Z) * 2
	camera.CFrame = CFrame.lookAt(cf.Position + Vector3.new(distance, distance * 0.5, distance), cf.Position)
		
		-- Optional: Set viewport lighting properties for better visuals
		viewport.Ambient = Color3.fromRGB(100, 100, 100)
		viewport.LightColor = Color3.fromRGB(255, 255, 255)
		viewport.LightDirection = Vector3.new(1, -1, -1)
		
		-- Add rotation animation
		self:StartModelRotation(crateModel, crateName)
	end
end

function CrateSelectionController:CreateFallbackCrate(crateName, crateConfig)
	local model = Instance.new("Model")
	model.Name = crateName
	
	local part = Instance.new("Part")
	part.Name = "CratePart"
	part.Size = Vector3.new(4, 4, 4)
	part.Material = Enum.Material.Wood
	part.BrickColor = BrickColor.new("Brown")
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = model
	
	-- Add a simple decal or texture
	local decal = Instance.new("Decal")
	decal.Texture = "rbxasset://textures/face.png"
	decal.Face = Enum.NormalId.Front
	decal.Parent = part
	
	return model
end

function CrateSelectionController:StartModelRotation(model, crateName)
	-- Stop existing rotation for this crate
	if rotationTweens[crateName] then
		rotationTweens[crateName]:Cancel()
	end
	
	-- Create rotation tween
	local rotationInfo = TweenInfo.new(
		8, -- Duration
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.InOut,
		-1, -- Repeat count (-1 = infinite)
		false -- Reverse
	)
	
	-- Get the part to rotate (handle UnionOperation properly)
	local partToRotate
	if model:IsA("BasePart") or model:IsA("UnionOperation") then
		partToRotate = model
	else
		partToRotate = model.PrimaryPart or model:FindFirstChildOfClass("Part")
	end
	
	local rotationTween = TweenService:Create(
		partToRotate,
		rotationInfo,
		{CFrame = partToRotate.CFrame * CFrame.Angles(0, math.rad(360), 0)}
	)
	
	rotationTweens[crateName] = rotationTween
	rotationTween:Play()
	
	-- Handle tween completion (for infinite rotation)
	rotationTween.Completed:Connect(function()
		if rotationTween == rotationTweens[crateName] then
			rotationTween:Play() -- Restart the tween
		end
	end)
end

function CrateSelectionController:SelectCrate(crateName)
	if crateName == selectedCrate then
		return -- Already selected
	end
	
	-- Update previous selection
	if crateCards[selectedCrate] then
		CrateSelectionUI.UpdateCardSelection(crateCards[selectedCrate], false)
	end
	
	-- Update new selection
	selectedCrate = crateName
	if crateCards[selectedCrate] then
		CrateSelectionUI.UpdateCardSelection(crateCards[selectedCrate], true)
	end
	
	-- Save selected crate to server for persistence
	if Remotes.SaveSelectedCrate then
		Remotes.SaveSelectedCrate:FireServer(crateName)
		print("[CrateSelectionController] Saved selected crate to server:", crateName)
	end
	
	-- Notify other systems of the selection change
	print("[CrateSelectionController] Selected crate:", crateName)
	
	-- Close the UI after selection for better UX
	task.wait(0.2) -- Small delay to show the selection change
	self:Hide()
end

function CrateSelectionController:GetSelectedCrate()
	return selectedCrate
end

function CrateSelectionController:SetSelectedCrateQuiet(crateName)
	-- Set the selected crate without UI updates or closing (used for initialization)
	if GameConfig.Boxes[crateName] then
		selectedCrate = crateName
		print("[CrateSelectionController] Quietly set selected crate to:", crateName)
		
		-- Update the UI selection state if crate cards exist
		if crateCards then
			for name, card in pairs(crateCards) do
				if card and card.Parent then
					local isSelected = (name == crateName)
					CrateSelectionUI.UpdateCardSelection(card, isSelected)
				end
			end
		end
		
		-- Save selected crate to server for persistence (even when set quietly)
		if Remotes.SaveSelectedCrate then
			Remotes.SaveSelectedCrate:FireServer(crateName)
			print("[CrateSelectionController] Saved selected crate to server (quiet):", crateName)
		end
	else
		warn("[CrateSelectionController] Cannot set unknown crate:", crateName)
	end
end

function CrateSelectionController:Show()
	if not components then return end
	
	isVisible = true
	hideOtherUIs(true)
	components.MainFrame.Visible = true
	
	-- Animate the UI appearing
	components.MainFrame.Size = UDim2.new(0, 0, 0, 0)
	components.MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	
	local showTween = TweenService:Create(
		components.MainFrame,
		TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{
			Size = UDim2.new(1, -60, 1, -60),
			Position = UDim2.new(0, 30, 0, 30)
		}
	)
	showTween:Play()
end

function CrateSelectionController:Hide()
	if not components then return end
	
	isVisible = false
	hideOtherUIs(false)
	
	-- Animate the UI disappearing
	local hideTween = TweenService:Create(
		components.MainFrame,
		TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In),
		{
			Size = UDim2.new(0, 0, 0, 0),
			Position = UDim2.new(0.5, 0, 0.5, 0)
		}
	)
	
	hideTween:Play()
	hideTween.Completed:Connect(function()
		components.MainFrame.Visible = false
	end)
end

function CrateSelectionController:Toggle()
	if isVisible then
		self:Hide()
	else
		self:Show()
	end
end

function CrateSelectionController:IsVisible()
	return isVisible
end

-- Clean up when controller is destroyed
function CrateSelectionController:Destroy()
	-- Stop all rotation tweens
	for crateName, tween in pairs(rotationTweens) do
		tween:Cancel()
	end
	rotationTweens = {}
	
	-- Clean up model connections
	for _, connection in pairs(modelConnections) do
		connection:Disconnect()
	end
	modelConnections = {}
	
	-- Destroy UI
	if components and components.ScreenGui then
		components.ScreenGui:Destroy()
	end
	
	print("[CrateSelectionController] Destroyed")
end

return CrateSelectionController 