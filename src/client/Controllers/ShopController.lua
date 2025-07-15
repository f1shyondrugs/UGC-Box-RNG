local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local NavigationController = require(script.Parent.NavigationController)
local ShopUI = require(script.Parent.Parent.UI.ShopUI)
local Shared = ReplicatedStorage.Shared
local GameConfig = require(Shared.Modules.GameConfig)

local ShopController = {}

local ui = nil
local isVisible = false
local soundController = nil

-- Animation settings
local ANIMATION_TIME = 0.3
local EASE_INFO = TweenInfo.new(ANIMATION_TIME, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local hiddenUIs = {}

-- Check gamepass ownership with whitelist support
local function checkGamepassOwnership(gamepassId)
	-- Check whitelist first
	for _, id in ipairs(GameConfig.GamepassWhitelist or {}) do
		if id == LocalPlayer.UserId then
			return true
		end
	end
	
	-- Client-side MarketplaceService may not expose UserOwnsGamePassAsync.
	if MarketplaceService.UserOwnsGamePassAsync then
		local success, owns = pcall(function()
			return MarketplaceService:UserOwnsGamePassAsync(LocalPlayer.UserId, gamepassId)
		end)
		if success then
			return owns
		end
	end
	
	-- Fallback: assume not owned (UI will prompt purchase; server will validate.)
	return false
end

-- Get gamepass icon
local function getGamepassIcon(gamepassId)
	local success, info = pcall(function()
		return MarketplaceService:GetProductInfo(gamepassId, Enum.InfoType.GamePass)
	end)
	if success and info and info.IconImageAssetId then
		return "rbxassetid://" .. info.IconImageAssetId
	end
	return "rbxassetid://6031094678" -- Default lock icon
end

local function hideOtherUIs(show)
	local playerGui = LocalPlayer:WaitForChild("PlayerGui")
	if show then
		for _, gui in pairs(playerGui:GetChildren()) do
			if gui:IsA("ScreenGui") and gui.Name ~= "ShopGui" then
				-- Don't hide tutorial GUI
				if gui.Name == "TutorialGui" then
					continue
				end
				
				if gui.Enabled then
					hiddenUIs[gui] = true
					gui.Enabled = false
				end
			end
		end
	else
		for gui, _ in pairs(hiddenUIs) do
			if gui and gui.Parent then
				gui.Enabled = true
			end
		end
		hiddenUIs = {}
	end
end

-- Toggle shop visibility
local function toggleShop()
	if not ui then return end
	
	isVisible = not isVisible
	
	if isVisible then
		hideOtherUIs(true)
		ui.MainFrame.Visible = true
		
		-- Animate in
		ui.MainFrame.Size = UDim2.new(0, 0, 0, 0)
		ui.MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
		
		local showTween = TweenService:Create(ui.MainFrame, EASE_INFO, {
			Size = UDim2.new(0.6, 0, 0.75, 0),
			Position = UDim2.new(0.2, 0, 0.125, 0)
		})
		showTween:Play()
	else
		-- Animate out
		local hideTween = TweenService:Create(ui.MainFrame, EASE_INFO, {
			Size = UDim2.new(0, 0, 0, 0),
			Position = UDim2.new(0.5, 0, 0.5, 0)
		})
		hideTween:Play()
		hideTween.Completed:Connect(function()
			ui.MainFrame.Visible = false
			hideOtherUIs(false)
		end)
	end
end

-- Create gamepass cards
local function createGamepasses()
	if not ui then return end
	
	-- Premium check
	local isPremium = LocalPlayer.MembershipType == Enum.MembershipType.Premium

	-- Create ULTRA Lucky gamepass (full width, always at top)
	local ultraLuckyOwned = checkGamepassOwnership(GameConfig.UltraLuckyGamepassId)
	ui.CreateGamepassCard({
		Name = "ULTRA Lucky",
		Icon = getGamepassIcon(GameConfig.UltraLuckyGamepassId),
		Price = ultraLuckyOwned and "OWNED" or "199 R$",
		ButtonText = ultraLuckyOwned and "✓ Owned" or "Buy Now",
		ButtonColor = ultraLuckyOwned and Color3.fromRGB(100, 100, 100) or Color3.fromRGB(255, 100, 50),
		AccentColor = Color3.fromRGB(255, 100, 50),
		LayoutOrder = 0,
		UltraLucky = true,
		OnClick = ultraLuckyOwned and nil or function()
			if soundController then soundController:playUIClick() end
			MarketplaceService:PromptGamePassPurchase(LocalPlayer, GameConfig.UltraLuckyGamepassId)
		end
	})
	
	-- Auto-Open (2 wide)
	local autoOpenOwned = checkGamepassOwnership(GameConfig.AutoOpenGamepassId)
	ui.CreateGamepassCard({
		Name = "Auto-Open",
		Icon = getGamepassIcon(GameConfig.AutoOpenGamepassId),
		Price = autoOpenOwned and "OWNED" or "99 R$",
		ButtonText = autoOpenOwned and "✓ Owned" or "Buy Now",
		ButtonColor = autoOpenOwned and Color3.fromRGB(100, 100, 100) or Color3.fromRGB(50, 150, 255),
		AccentColor = Color3.fromRGB(50, 150, 255),
		LayoutOrder = 1,
		OnClick = autoOpenOwned and nil or function()
			if soundController then soundController:playUIClick() end
			MarketplaceService:PromptGamePassPurchase(LocalPlayer, GameConfig.AutoOpenGamepassId)
		end
	})
	
	-- Auto-Sell (2 wide)
	local autoSellOwned = checkGamepassOwnership(GameConfig.AutoSellGamepassId)
	ui.CreateGamepassCard({
		Name = "Auto-Sell",
		Icon = getGamepassIcon(GameConfig.AutoSellGamepassId),
		Price = autoSellOwned and "OWNED" or "99 R$",
		ButtonText = autoSellOwned and "✓ Owned" or "Buy Now",
		ButtonColor = autoSellOwned and Color3.fromRGB(100, 100, 100) or Color3.fromRGB(255, 150, 50),
		AccentColor = Color3.fromRGB(255, 150, 50),
		LayoutOrder = 2,
		OnClick = autoSellOwned and nil or function()
			if soundController then soundController:playUIClick() end
			MarketplaceService:PromptGamePassPurchase(LocalPlayer, GameConfig.AutoSellGamepassId)
		end
	})
	
	-- Infinite Storage
	local infiniteStorageOwned = checkGamepassOwnership(GameConfig.InfiniteStorageGamepassId)
	ui.CreateGamepassCard({
		Name = "Infinite Storage",
		Icon = getGamepassIcon(GameConfig.InfiniteStorageGamepassId),
		Price = infiniteStorageOwned and "OWNED" or "49 R$",
		ButtonText = infiniteStorageOwned and "✓ Owned" or "Buy Now",
		ButtonColor = infiniteStorageOwned and Color3.fromRGB(100, 100, 100) or Color3.fromRGB(100, 255, 100),
		AccentColor = Color3.fromRGB(100, 255, 100),
		LayoutOrder = 3,
		OnClick = infiniteStorageOwned and nil or function()
			if soundController then soundController:playUIClick() end
			MarketplaceService:PromptGamePassPurchase(LocalPlayer, GameConfig.InfiniteStorageGamepassId)
		end
	})
	
	-- Auto-Enchant
	local autoEnchanterOwned = checkGamepassOwnership(GameConfig.AutoEnchanterGamepassId)
	ui.CreateGamepassCard({
		Name = "Auto-Enchant",
		Icon = getGamepassIcon(GameConfig.AutoEnchanterGamepassId),
		Price = autoEnchanterOwned and "OWNED" or "99 R$",
		ButtonText = autoEnchanterOwned and "✓ Owned" or "Buy Now",
		ButtonColor = autoEnchanterOwned and Color3.fromRGB(100, 100, 100) or Color3.fromRGB(150, 100, 255),
		AccentColor = Color3.fromRGB(150, 100, 255),
		LayoutOrder = 4,
		OnClick = autoEnchanterOwned and nil or function()
			if soundController then soundController:playUIClick() end
			MarketplaceService:PromptGamePassPurchase(LocalPlayer, GameConfig.AutoEnchanterGamepassId)
		end
	})
	
	-- Extra Lucky
	local extraLuckyOwned = checkGamepassOwnership(GameConfig.ExtraLuckyGamepassId)
	ui.CreateGamepassCard({
		Name = "Extra Lucky",
		Icon = getGamepassIcon(GameConfig.ExtraLuckyGamepassId),
		Price = extraLuckyOwned and "OWNED" or "129 R$",
		ButtonText = extraLuckyOwned and "✓ Owned" or "Buy Now",
		ButtonColor = extraLuckyOwned and Color3.fromRGB(100, 100, 100) or Color3.fromRGB(100, 255, 150),
		AccentColor = Color3.fromRGB(100, 255, 150),
		LayoutOrder = 5,
		OnClick = extraLuckyOwned and nil or function()
			if soundController then soundController:playUIClick() end
			MarketplaceService:PromptGamePassPurchase(LocalPlayer, GameConfig.ExtraLuckyGamepassId)
		end
	})
	
	-- Roblox Premium Advantage (full width)
	ui.CreateGamepassCard({
		Name = "ROBLOX PREMIUM ADVANTAGE",
		Icon = "rbxasset://textures/ui/PlayerList/PremiumIcon@3x.png",
		Price = isPremium and "ACTIVE" or "Subscribe to Premium",
		ButtonText = isPremium and "✓ Active" or "Get Premium",
		ButtonColor = isPremium and Color3.fromRGB(100, 100, 100) or Color3.fromRGB(255, 200, 50),
		AccentColor = Color3.fromRGB(255, 200, 50),
		LayoutOrder = 6,
		OnClick = isPremium and nil or function()
			if soundController then soundController:playUIClick() end
			MarketplaceService:PromptPremiumPurchase(LocalPlayer)
		end
	})
	
	-- Calculate and set the height of the gridContainer after all grid items are added
	local gridLayout = ui.GridContainer:FindFirstChildOfClass("UIGridLayout")
	local numGridItems = #ui.GridContainer:GetChildren() - 1 -- Subtract 1 for the UIGridLayout itself
	local cellsPerRow = gridLayout.FillDirectionMaxCells
	
	local numRows = math.ceil(numGridItems / cellsPerRow)
	local totalCellHeight = numRows * gridLayout.CellSize.Y.Offset
	local totalPaddingHeight = (numRows > 0 and numRows - 1 or 0) * gridLayout.CellPadding.Y.Offset
	
	ui.GridContainer.Size = UDim2.new(1, 0, 0, totalCellHeight + totalPaddingHeight)
end

-- Refresh shop when purchases complete
local function onGamepassPurchased()
	-- Clear existing cards
	for _, child in pairs(ui.ContentFrame:GetChildren()) do
		if child:IsA("Frame") and child.Name:match("Card$") then
			child:Destroy()
		end
	end
	
	-- Recreate cards with updated ownership
	createGamepasses()
end

function ShopController.Start(parentGui, soundControllerRef)
	soundController = soundControllerRef
	
	-- Create UI
	ui = ShopUI.Create(parentGui)
	
	-- Register with NavigationController
	NavigationController.RegisterController("Shop", function()
		toggleShop()
	end)
	
	-- Connect close button
	ui.CloseButton.MouseButton1Click:Connect(function()
		if soundController then soundController:playUIClick() end
		if isVisible then toggleShop() end
	end)
	
	-- Create initial gamepass cards
	createGamepasses()
	
	-- Listen for gamepass purchases
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamepassId, wasPurchased)
		if player == LocalPlayer and wasPurchased then
			onGamepassPurchased()
			if soundController then soundController:playUIClick() end
		end
	end)
	
	-- Listen for premium purchases
	MarketplaceService.PromptPremiumPurchaseFinished:Connect(function(player)
		if player == LocalPlayer then
			onGamepassPurchased()
			if soundController then soundController:playUIClick() end
		end
	end)
end

return ShopController 