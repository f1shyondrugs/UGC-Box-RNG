local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local ToastNotificationController = {}

-- Reference to settings controller (will be set from main client)
local settingsController = nil

-- Set reference to settings controller
function ToastNotificationController.SetSettingsController(settings)
	settingsController = settings
end

-- Check if effects are disabled
local function areEffectsDisabled()
	return settingsController and settingsController.AreEffectsDisabled() or false
end

-- Toast container
local toastContainer = nil
local activeToasts = {}

-- Create the toast container
local function createToastContainer(parent)
	-- Create a ScreenGui for the toast container
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ToastNotificationGui"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = parent
	
	toastContainer = Instance.new("Frame")
	toastContainer.Name = "ToastContainer"
	toastContainer.Size = UDim2.new(0, 400, 1, 0)
	toastContainer.Position = UDim2.new(1, -420, 0, 20) -- Top right corner
	toastContainer.BackgroundTransparency = 1
	toastContainer.Parent = screenGui
	
	-- Create a layout for stacking toasts
	local listLayout = Instance.new("UIListLayout")
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding = UDim.new(0, 10)
	listLayout.Parent = toastContainer
	
	-- Align to top
	local alignPosition = Instance.new("UIPadding")
	alignPosition.PaddingTop = UDim.new(0, 20)
	alignPosition.Parent = toastContainer
	
	print("[ToastNotificationController] Toast container created successfully")
end

-- Create a single toast notification
local function createToast(message, messageType, parent)
	local toast = Instance.new("Frame")
	toast.Name = "Toast"
	toast.Size = UDim2.new(1, 0, 0, 60)
	toast.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	toast.BorderSizePixel = 0
	toast.Parent = parent
	
	-- Add rounded corners
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = toast
	
	-- Add stroke
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 2
	stroke.Parent = toast
	
	-- Set colors based on message type
	if messageType == "Error" then
		stroke.Color = Color3.fromRGB(255, 100, 100) -- Red
		toast.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
	elseif messageType == "Success" then
		stroke.Color = Color3.fromRGB(100, 255, 100) -- Green
		toast.BackgroundColor3 = Color3.fromRGB(30, 60, 30)
	else -- Info or default
		stroke.Color = Color3.fromRGB(100, 150, 255) -- Blue
		toast.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
	end
	
	-- Add shadow effect
	local shadow = Instance.new("Frame")
	shadow.Name = "Shadow"
	shadow.Size = UDim2.new(1, 4, 1, 4)
	shadow.Position = UDim2.new(0, 2, 0, 2)
	shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	shadow.BorderSizePixel = 0
	shadow.ZIndex = toast.ZIndex - 1
	shadow.Parent = toast
	
	local shadowCorner = Instance.new("UICorner")
	shadowCorner.CornerRadius = UDim.new(0, 8)
	shadowCorner.Parent = shadow
	
	-- Text label
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Text"
	textLabel.Size = UDim2.new(1, -20, 1, 0)
	textLabel.Position = UDim2.new(0, 10, 0, 0)
	textLabel.Text = message
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.BackgroundTransparency = 1
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextSize = 16
	textLabel.TextWrapped = true
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.TextYAlignment = Enum.TextYAlignment.Center
	textLabel.Parent = toast
	
	-- Icon based on message type
	local icon = Instance.new("TextLabel")
	icon.Name = "Icon"
	icon.Size = UDim2.new(0, 20, 0, 20)
	icon.Position = UDim2.new(1, -30, 0.5, -10)
	icon.BackgroundTransparency = 1
	icon.Font = Enum.Font.GothamBold
	icon.TextSize = 16
	icon.TextColor3 = Color3.fromRGB(255, 255, 255)
	icon.Parent = toast
	
	if messageType == "Error" then
		icon.Text = "X"
	elseif messageType == "Success" then
		icon.Text = "✓"
	else -- Info
		icon.Text = "ℹ"
	end
	
	return toast
end

-- Show a toast notification
function ToastNotificationController.ShowToast(message, messageType)
	print("[ToastNotificationController] ShowToast called with:", message, messageType)
	
	-- Skip if effects are disabled
	-- if areEffectsDisabled() then
	-- 	print("[ToastNotificationController] Effects disabled, skipping toast")
	-- 	return
	-- end
	
	if not toastContainer then
		warn("Toast container not initialized")
		return
	end
	
	print("[ToastNotificationController] Creating toast...")
	-- Create the toast
	local toast = createToast(message, messageType, toastContainer)
	
	-- Set initial state (off-screen to the right)
	toast.Position = UDim2.new(1, 0, 0, 0)
	toast.Size = UDim2.new(1, 0, 0, 0)
	
	-- Add to active toasts
	table.insert(activeToasts, toast)
	
	-- Slide in animation
	local slideInTween = TweenService:Create(toast, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 0, 60)
	})
	
	-- Auto-remove after delay
	local removeDelay = 4.0 -- Show for 4 seconds
	if messageType == "Error" then
		removeDelay = 5.0 -- Show errors longer
	elseif messageType == "Success" then
		removeDelay = 3.5 -- Show success messages shorter
	end
	
	-- Slide out animation
	local slideOutTween = TweenService:Create(toast, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.new(1, 0, 0, 0)
	})
	
	-- Play slide in
	slideInTween:Play()
	
	-- Schedule removal
	task.delay(removeDelay, function()
		if toast and toast.Parent then
			slideOutTween:Play()
			slideOutTween.Completed:Connect(function()
				if toast and toast.Parent then
					toast:Destroy()
					-- Remove from active toasts
					for i, activeToast in ipairs(activeToasts) do
						if activeToast == toast then
							table.remove(activeToasts, i)
							break
						end
					end
				end
			end)
		end
	end)
end

-- Initialize the toast system
function ToastNotificationController.Start(parentGui)
	print("[ToastNotificationController] Starting with parentGui:", parentGui)
	createToastContainer(parentGui)
	print("[ToastNotificationController] Started, toastContainer:", toastContainer)
end

-- Clear all active toasts
function ToastNotificationController.ClearAll()
	for _, toast in ipairs(activeToasts) do
		if toast and toast.Parent then
			toast:Destroy()
		end
	end
	activeToasts = {}
end

return ToastNotificationController 