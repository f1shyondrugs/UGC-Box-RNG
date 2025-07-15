-- TutorialController.lua
-- Comprehensive tutorial system to guide new players through the game

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Shared = ReplicatedStorage.Shared
local Remotes = require(Shared.Remotes.Remotes)

local TutorialController = {}

-- Tutorial state
local tutorialState = {
    isActive = false,
    currentStep = 0,
    completedSteps = {},
    isNewPlayer = false
}

-- Tutorial steps configuration
local tutorialSteps = {
    {
        id = "welcome",
        title = "Welcome to UGC Box RNG!",
        description = "Let's get you started with the basics of the game.",
        position = UDim2.new(0.5, 0, 0.3, 0),
        target = nil,
        action = "click",
        duration = 3
    },
    {
        id = "crate_selection",
        title = "Select Your Crate Type",
        description = "Click the dropdown next to the buy button to choose different crate types. Each has different items and prices!",
        position = UDim2.new(0.5, 0, 0.55, 0),
        target = "CrateSelectionButton",
        action = "click",
        duration = 5
    },
    {
        id = "buy_button",
        title = "Buy Your First Crate!",
        description = "Click the yellow 'Buy UGC Crate' button to purchase your first crate. This is how you get items!",
        position = UDim2.new(0.35, 0, 0.55, 0),
        target = "BuyBoxButton",
        action = "click",
        duration = 5
    },
    {
        id = "inventory_intro",
        title = "Check Your Inventory",
        description = "Click the 📦 button to open your inventory and see your items.",
        position = UDim2.new(0.1, 0, 0.5, 0),
        target = "InventoryButton",
        action = "click",
        duration = 4
    },
    {
        id = "sell_items",
        title = "Sell Items for R$",
        description = "Select an item and click 'Sell' to convert it back to R$. This is how you make money!",
        position = UDim2.new(0.75, 0, 0.5, 0),
        target = nil,
        action = "info",
        duration = 12
    },
    {
        id = "upgrades_intro",
        title = "Upgrade Your Game",
        description = "Click the ⚡ button to access upgrades. These make you more powerful!",
        position = UDim2.new(0.1, 0, 0.5, 0),
        target = "UpgradeButton",
        action = "click",
        duration = 4
    },
    {
        id = "shop_intro",
        title = "Visit the Gamepass Shop",
        description = "Click the 🛒 button to purchase Extra Luck and buy Gamepasses!",
        position = UDim2.new(0.1, 0, 0.5, 0),
        target = "ShopButton",
        action = "click",
        duration = 4
    },
    {
        id = "rebirth_intro",
        title = "Rebirth System",
        description = "Click the 🌟 button to learn about rebirths. This is how you unlock better Crates and new Features!",
        position = UDim2.new(0.1, 0, 0.5, 0),
        target = "RebirthButton",
        action = "click",
        duration = 4
    },
    {
        id = "auto_open",
        title = "Auto- & Auto-Sell",
        description = "Click the 🤖 button to set up automatic crate opening and auto selling. Great for when you're AFK!",
        position = UDim2.new(0.1, 0, 0.5, 0),
        target = "AutoOpenButton",
        action = "click",
        duration = 4
    },
    {
        id = "settings",
        title = "Customize Your Experience",
        description = "Click the ⚙️ button to adjust settings like sound, notifications, and more.",
        position = UDim2.new(0.1, 0, 0.5, 0),
        target = "SettingsButton",
        action = "click",
        duration = 4
    },
    {
        id = "completion",
        title = "You're All Set!",
        description = "You now know the basics! Start buying crates, upgrading, and building your collection. Good luck!",
        position = UDim2.new(0.5, 0, 0.3, 0),
        target = nil,
        action = "complete",
        duration = 5
    }
}

-- UI Components
local tutorialUI = nil
local currentHighlight = nil
local currentHighlightData = nil -- Store additional highlight data

-- Create tutorial UI
local function createTutorialUI(parentGui)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TutorialGui"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = parentGui

    -- Tutorial overlay (full-screen semi-transparent background)
    local overlay = Instance.new("Frame")
    overlay.Name = "TutorialOverlay"
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.Position = UDim2.new(0, 0, 0, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.7
    overlay.BorderSizePixel = 0
    overlay.Visible = false
    overlay.ZIndex = 200
    overlay.Parent = screenGui
    
    -- Ensure overlay covers the entire screen including top bar
    overlay.AnchorPoint = Vector2.new(0, 0)
    
    -- Make the ScreenGui ignore GUI inset to cover the top bar area
    screenGui.IgnoreGuiInset = true

    -- Tutorial tooltip
    local tooltip = Instance.new("Frame")
    tooltip.Name = "TutorialTooltip"
    tooltip.Size = UDim2.new(0, 400, 0, 160)
    tooltip.Position = UDim2.new(0.5, -200, 0.3, -80)
    tooltip.BackgroundColor3 = Color3.fromRGB(25, 30, 45)
    tooltip.BorderSizePixel = 0
    tooltip.Visible = false
    tooltip.ZIndex = 201
    tooltip.Parent = screenGui
    
    -- Function to adjust tooltip size based on screen size
    local function adjustTooltipSize()
        local screenSize = workspace.CurrentCamera.ViewportSize
        local maxWidth = math.min(400, screenSize.X * 0.8) -- Max 80% of screen width
        local maxHeight = math.min(160, screenSize.Y * 0.3) -- Max 30% of screen height
        
        tooltip.Size = UDim2.new(0, maxWidth, 0, maxHeight)
        tooltip.Position = UDim2.new(0.5, -maxWidth/2, 0.3, -maxHeight/2)
    end
    
    -- Adjust size initially and on screen size changes
    adjustTooltipSize()
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(adjustTooltipSize)

    -- Add rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = tooltip

    -- Add stroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 193, 7)
    stroke.Thickness = 3
    stroke.Parent = tooltip

    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -20, 0, 30)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.Text = "Tutorial"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextColor3 = Color3.fromRGB(255, 193, 7)
    title.BackgroundTransparency = 1
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.ZIndex = 202
    title.Parent = tooltip

    -- Description
    local description = Instance.new("TextLabel")
    description.Name = "Description"
    description.Size = UDim2.new(1, -20, 0, 80)
    description.Position = UDim2.new(0, 10, 0, 45)
    description.Text = "Tutorial description"
    description.Font = Enum.Font.Gotham
    description.TextSize = 16
    description.TextColor3 = Color3.fromRGB(255, 255, 255)
    description.BackgroundTransparency = 1
    description.TextWrapped = true
    description.TextXAlignment = Enum.TextXAlignment.Center
    description.ZIndex = 202
    description.Parent = tooltip

    -- Progress indicator
    local progress = Instance.new("TextLabel")
    progress.Name = "Progress"
    progress.Size = UDim2.new(1, -20, 0, 20)
    progress.Position = UDim2.new(0, 10, 1, -25)
    progress.Text = "Step 1 of 10"
    progress.Font = Enum.Font.Gotham
    progress.TextSize = 12
    progress.TextColor3 = Color3.fromRGB(200, 200, 200)
    progress.BackgroundTransparency = 1
    progress.TextXAlignment = Enum.TextXAlignment.Center
    progress.ZIndex = 202
    progress.Parent = tooltip

    -- Skip button
    local skipButton = Instance.new("TextButton")
    skipButton.Name = "SkipButton"
    skipButton.Size = UDim2.new(0, 80, 0, 25)
    skipButton.Position = UDim2.new(1, -90, 0, 10)
    skipButton.Text = "Skip"
    skipButton.Font = Enum.Font.Gotham
    skipButton.TextSize = 12
    skipButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    skipButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    skipButton.ZIndex = 202
    skipButton.Parent = tooltip

    local skipCorner = Instance.new("UICorner")
    skipCorner.CornerRadius = UDim.new(0, 6)
    skipCorner.Parent = skipButton

    -- Back button
    local backButton = Instance.new("TextButton")
    backButton.Name = "BackButton"
    backButton.Size = UDim2.new(0, 60, 0, 25)
    backButton.Position = UDim2.new(0, 10, 1, -30)
    backButton.Text = "Back"
    backButton.Font = Enum.Font.Gotham
    backButton.TextSize = 12
    backButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    backButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    backButton.ZIndex = 202
    backButton.Parent = tooltip

    local backCorner = Instance.new("UICorner")
    backCorner.CornerRadius = UDim.new(0, 6)
    backCorner.Parent = backButton

    -- Next button
    local nextButton = Instance.new("TextButton")
    nextButton.Name = "NextButton"
    nextButton.Size = UDim2.new(0, 60, 0, 25)
    nextButton.Position = UDim2.new(1, -70, 1, -30)
    nextButton.Text = "Next"
    nextButton.Font = Enum.Font.GothamBold
    nextButton.TextSize = 12
    nextButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    nextButton.BackgroundColor3 = Color3.fromRGB(255, 193, 7)
    nextButton.ZIndex = 202
    nextButton.Parent = tooltip

    local nextCorner = Instance.new("UICorner")
    nextCorner.CornerRadius = UDim.new(0, 6)
    nextCorner.Parent = nextButton

    return {
        ScreenGui = screenGui,
        Overlay = overlay,
        Tooltip = tooltip,
        Title = title,
        Description = description,
        Progress = progress,
        SkipButton = skipButton,
        BackButton = backButton,
        NextButton = nextButton
    }
end

-- Create highlight effect with multiple visual indicators
local function createHighlight(target)
    if not target then return nil end
    
    print("[TutorialController] Creating highlight for target:", target.Name)
    
    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(255, 193, 7)
    highlight.FillTransparency = 0.3
    highlight.OutlineColor = Color3.fromRGB(255, 193, 7)
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = target
    
    -- Create a bright border frame around the target
    local borderFrame = Instance.new("Frame")
    borderFrame.Name = "TutorialBorder"
    borderFrame.Size = UDim2.new(1, 8, 1, 8)
    borderFrame.Position = UDim2.new(0, -4, 0, -4)
    borderFrame.BackgroundTransparency = 1
    borderFrame.BorderSizePixel = 3
    borderFrame.BorderColor3 = Color3.fromRGB(255, 255, 0)
    borderFrame.ZIndex = 999
    borderFrame.Parent = target
    
    -- Add rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = borderFrame
    
    -- Store original properties
    local originalColor = target.BackgroundColor3
    local originalTransparency = target.BackgroundTransparency
    
    -- Create pulsing animation for both border and background
    local function animateHighlight()
        while target.Parent and borderFrame.Parent do
            -- Animate border to bright yellow and make it thicker
            local borderTween1 = TweenService:Create(
                borderFrame,
                TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                {BorderSizePixel = 5, BorderColor3 = Color3.fromRGB(255, 255, 255)}
            )
            borderTween1:Play()
            
            -- Animate background if it's a GuiObject
            if target:IsA("GuiObject") then
                local bgTween1 = TweenService:Create(
                    target,
                    TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                    {BackgroundColor3 = Color3.fromRGB(255, 255, 0), BackgroundTransparency = 0.1}
                )
                bgTween1:Play()
            end
            
            task.wait(0.8)
            
            if not target.Parent or not borderFrame.Parent then break end
            
            -- Animate back to original
            local borderTween2 = TweenService:Create(
                borderFrame,
                TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                {BorderSizePixel = 3, BorderColor3 = Color3.fromRGB(255, 255, 0)}
            )
            borderTween2:Play()
            
            if target:IsA("GuiObject") then
                local bgTween2 = TweenService:Create(
                    target,
                    TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                    {BackgroundColor3 = originalColor, BackgroundTransparency = originalTransparency}
                )
                bgTween2:Play()
            end
            
            task.wait(0.8)
        end
    end
    
    -- Start animation in a separate thread
    task.spawn(animateHighlight)
    
    -- Store references for cleanup
    local highlightData = {
        BorderFrame = borderFrame,
        OriginalColor = originalColor,
        OriginalTransparency = originalTransparency,
        Target = target
    }
    
    print("[TutorialController] Highlight created successfully")
    return highlight, highlightData
end

-- Remove highlight
local function removeHighlight()
    if currentHighlight then
        print("[TutorialController] Removing highlight")
        
        -- Clean up border frame if it exists
        if currentHighlightData and currentHighlightData.BorderFrame then
            currentHighlightData.BorderFrame:Destroy()
        end
        
        -- Restore original background color if target still exists
        if currentHighlightData and currentHighlightData.Target and currentHighlightData.Target:IsA("GuiObject") then
            currentHighlightData.Target.BackgroundColor3 = currentHighlightData.OriginalColor
            currentHighlightData.Target.BackgroundTransparency = currentHighlightData.OriginalTransparency
        end
        
        currentHighlight:Destroy()
        currentHighlight = nil
        currentHighlightData = nil
    end
end

-- Find target element
local function findTarget(targetName)
    print("[TutorialController] Looking for target:", targetName)
    
    -- Look in PlayerGui
    local playerGui = LocalPlayer.PlayerGui
    if not playerGui then 
        print("[TutorialController] PlayerGui not found")
        return nil 
    end

    -- Search through all ScreenGuis
    for _, screenGui in ipairs(playerGui:GetChildren()) do
        if screenGui:IsA("ScreenGui") then
            print("[TutorialController] Searching in ScreenGui:", screenGui.Name)
            local target = screenGui:FindFirstChild(targetName, true)
            if target then
                print("[TutorialController] Found target:", target.Name, "Type:", target.ClassName)
                return target
            end
        end
    end

    print("[TutorialController] Target not found:", targetName)
    return nil
end

-- Show tutorial step
local function showTutorialStep(stepIndex)
    if stepIndex > #tutorialSteps then
        TutorialController.Complete()
        return
    end
    
    if stepIndex < 1 then
        return
    end

    local step = tutorialSteps[stepIndex]
    tutorialState.currentStep = stepIndex

    -- Update UI
    tutorialUI.Title.Text = step.title
    tutorialUI.Description.Text = step.description
    tutorialUI.Progress.Text = string.format("Step %d of %d", stepIndex, #tutorialSteps)
    
    -- Update button visibility
    tutorialUI.BackButton.Visible = stepIndex > 1
    tutorialUI.NextButton.Text = stepIndex == #tutorialSteps and "Finish" or "Next"
    
    -- Calculate safe position to prevent going out of frame
    local basePosition = step.position
    local screenSize = workspace.CurrentCamera.ViewportSize
    local tooltipSize = Vector2.new(tutorialUI.Tooltip.AbsoluteSize.X, tutorialUI.Tooltip.AbsoluteSize.Y)
    if tooltipSize.X == 0 or tooltipSize.Y == 0 then
        tooltipSize = Vector2.new(400, 160) -- Fallback size
    end
    
    -- Calculate safe X position
    local safeX = math.max(0.1, math.min(0.9, basePosition.X.Scale))
    local safeXOffset = basePosition.X.Offset
    if basePosition.X.Offset ~= 0 then
        -- If there's an offset, ensure it doesn't push the tooltip off screen
        local maxOffset = (screenSize.X - tooltipSize.X) / 2
        safeXOffset = math.max(-maxOffset, math.min(maxOffset, basePosition.X.Offset))
    end
    
    -- Calculate safe Y position
    local safeY = math.max(0.1, math.min(0.8, basePosition.Y.Scale))
    local safeYOffset = basePosition.Y.Offset
    if basePosition.Y.Offset ~= 0 then
        -- If there's an offset, ensure it doesn't push the tooltip off screen
        local maxOffset = (screenSize.Y - tooltipSize.Y) / 2
        safeYOffset = math.max(-maxOffset, math.min(maxOffset, basePosition.Y.Offset))
    end
    
    local targetPosition = UDim2.new(safeX, safeXOffset, safeY, safeYOffset)
    
    -- Animate the tooltip to the new position
    local tween = TweenService:Create(
        tutorialUI.Tooltip,
        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Position = targetPosition}
    )
    tween:Play()

    -- Show overlay and tooltip with fade-in animation
    tutorialUI.Overlay.Visible = true
    tutorialUI.Tooltip.Visible = true
    
    -- Fade in animation
    tutorialUI.Overlay.BackgroundTransparency = 1
    tutorialUI.Tooltip.BackgroundTransparency = 1
    
    local overlayTween = TweenService:Create(
        tutorialUI.Overlay,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundTransparency = 0.7}
    )
    overlayTween:Play()
    
    local tooltipTween = TweenService:Create(
        tutorialUI.Tooltip,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundTransparency = 0}
    )
    tooltipTween:Play()

    -- Handle target highlighting
    removeHighlight()
    if step.target then
        local target = findTarget(step.target)
        if target then
            currentHighlight, currentHighlightData = createHighlight(target)
        end
    end

    -- Auto-advance for info steps
    if step.action == "info" then
        task.delay(step.duration, function()
            if tutorialState.isActive then
                TutorialController.NextStep()
            end
        end)
    end
end

-- Connect button clicks to tutorial
local function connectTutorialClicks()
    local function onButtonClick(buttonName)
        if tutorialState.isActive then
            local currentStep = tutorialSteps[tutorialState.currentStep]
            if currentStep and currentStep.target == buttonName then
                TutorialController.NextStep()
            end
        end
    end

    -- Connect to navigation buttons
    local navigationGui = LocalPlayer.PlayerGui:FindFirstChild("NavigationGui")
    if navigationGui then
        local container = navigationGui:FindFirstChild("NavigationContainer")
        if container then
            for buttonName, _ in pairs({
                InventoryButton = true,
                ShopButton = true,
                UpgradeButton = true,
                RebirthButton = true,
                AutoOpenButton = true,
                SettingsButton = true
            }) do
                local button = container:FindFirstChild(buttonName)
                if button then
                    button.MouseButton1Click:Connect(function()
                        onButtonClick(buttonName)
                    end)
                end
            end
        end
    end

    -- Connect to buy button
    local buyButtonGui = LocalPlayer.PlayerGui:FindFirstChild("BuyButtonGui")
    if buyButtonGui then
        local buyButton = buyButtonGui:FindFirstChild("BuyBoxButton", true)
        if buyButton then
            buyButton.MouseButton1Click:Connect(function()
                onButtonClick("BuyBoxButton")
            end)
        end
    end

    -- Connect to crate selection button (if it exists)
    local buyButtonGui = LocalPlayer.PlayerGui:FindFirstChild("BuyButtonGui")
    if buyButtonGui then
        local crateSelectionButton = buyButtonGui:FindFirstChild("CrateSelectionButton", true)
        if crateSelectionButton then
            crateSelectionButton.MouseButton1Click:Connect(function()
                onButtonClick("CrateSelectionButton")
            end)
        end
    end
end

-- Tutorial stays visible when other GUIs are opened
local function setupGUIVisibilityHandling()
    -- Tutorial will remain visible even when other GUIs are opened
    -- This allows players to follow the tutorial while exploring the game
    print("[TutorialController] Tutorial will remain visible when other GUIs are opened")
end

-- Check if player is new (first time joining)
local function checkIfNewPlayer()
    print("[TutorialController] Checking if player is new...")
    
    -- Check if tutorial has been completed before
    local success, hasCompletedTutorial = pcall(function()
        return Remotes.CheckTutorialCompletion:InvokeServer()
    end)
    
    if success and hasCompletedTutorial then
        print("[TutorialController] Player has completed tutorial before, skipping")
        return false
    end
    
    -- Check if player has opened any boxes (primary check)
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if not leaderstats then 
        print("[TutorialController] No leaderstats found, showing tutorial")
        return true 
    end

    local boxesOpened = leaderstats:FindFirstChild("Boxes Opened")
    if not boxesOpened then 
        print("[TutorialController] No 'Boxes Opened' found, showing tutorial")
        return true 
    end

    local boxesValue = boxesOpened:FindFirstChild("Value")
    if not boxesValue then 
        print("[TutorialController] No 'Boxes Opened' value found, showing tutorial")
        return true 
    end

    local boxesOpenedCount = boxesValue.Value
    print("[TutorialController] Player has opened", boxesOpenedCount, "boxes")
    
    -- Only show tutorial if player has opened exactly 0 boxes
    if boxesOpenedCount == 0 then
        print("[TutorialController] Player is new (0 boxes opened), showing tutorial")
        return true
    else
        print("[TutorialController] Player has opened", boxesOpenedCount, "boxes, skipping tutorial")
        return false
    end
end

-- Start tutorial
function TutorialController.Start(parentGui)
    if tutorialState.isActive then return end

    print("[TutorialController] Starting tutorial...")

    -- Check if player is new
    tutorialState.isNewPlayer = checkIfNewPlayer()
    
    if not tutorialState.isNewPlayer then
        print("[TutorialController] Player is not new, skipping tutorial")
        return
    end

    -- Create UI
    tutorialUI = createTutorialUI(parentGui)
    tutorialState.isActive = true
    tutorialState.currentStep = 0

    -- Connect button clicks
    connectTutorialClicks()

    -- Setup GUI visibility handling
    setupGUIVisibilityHandling()

    -- Connect UI buttons
    tutorialUI.SkipButton.MouseButton1Click:Connect(function()
        TutorialController.Complete()
    end)

    tutorialUI.BackButton.MouseButton1Click:Connect(function()
        TutorialController.PreviousStep()
    end)

    tutorialUI.NextButton.MouseButton1Click:Connect(function()
        TutorialController.NextStep()
    end)

    -- Start first step
    task.wait(2) -- Wait for UI to load
    TutorialController.NextStep()

    print("[TutorialController] Tutorial started successfully")
end

-- Next step
function TutorialController.NextStep()
    if not tutorialState.isActive then return end

    local nextStep = tutorialState.currentStep + 1
    showTutorialStep(nextStep)
end

-- Previous step
function TutorialController.PreviousStep()
    if not tutorialState.isActive then return end

    local previousStep = tutorialState.currentStep - 1
    if previousStep >= 1 then
        showTutorialStep(previousStep)
    end
end

-- Complete tutorial
function TutorialController.Complete()
    if not tutorialState.isActive then return end

    print("[TutorialController] Completing tutorial...")

    -- Hide UI with fade out animation
    if tutorialUI then
        local overlayTween = TweenService:Create(
            tutorialUI.Overlay,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {BackgroundTransparency = 1}
        )
        overlayTween:Play()
        
        local tooltipTween = TweenService:Create(
            tutorialUI.Tooltip,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {BackgroundTransparency = 1}
        )
        tooltipTween:Play()
        
        tooltipTween.Completed:Connect(function()
            tutorialUI.Overlay.Visible = false
            tutorialUI.Tooltip.Visible = false
        end)
    end

    -- Remove highlight
    removeHighlight()

    -- Mark as completed
    tutorialState.isActive = false
    tutorialState.completedSteps = {}

    -- Save tutorial completion
    local success, _ = pcall(function()
        Remotes.SaveTutorialCompletion:FireServer()
    end)

    if success then
        print("[TutorialController] Tutorial completion saved")
    else
        warn("[TutorialController] Failed to save tutorial completion")
    end

    print("[TutorialController] Tutorial completed")
end

-- Check if tutorial is active
function TutorialController.IsActive()
    return tutorialState.isActive
end

-- Get tutorial state
function TutorialController.GetState()
    return tutorialState
end

return TutorialController 