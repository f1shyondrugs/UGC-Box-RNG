local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

local ItemValueCalculator = require(ReplicatedStorage.Shared.Modules.ItemValueCalculator)
local rapLeaderboardStore = DataStoreService:GetOrderedDataStore("RAPLeaderboard_V1")

local LeaderboardService = {}

local LEADERBOARD_UPDATE_INTERVAL = 300 -- 5 minutes in seconds
local TOP_N_PLAYERS = 100

local leaderboardPart = nil
local surfaceGui = nil
local listFrame = nil
local statusLabel = nil

local function createLeaderboardGUI()
	local leaderboardsFolder = Workspace:FindFirstChild("leaderboards")
	if not leaderboardsFolder then
		leaderboardsFolder = Instance.new("Folder")
		leaderboardsFolder.Name = "leaderboards"
		leaderboardsFolder.Parent = Workspace
	end

	leaderboardPart = leaderboardsFolder:FindFirstChild("RAPLeaderboard")
	if not leaderboardPart then
		leaderboardPart = Instance.new("Part")
		leaderboardPart.Name = "RAPLeaderboard"
		leaderboardPart.Size = Vector3.new(12, 20, 1)
		leaderboardPart.Position = Vector3.new(0, 10, -20)
		leaderboardPart.Anchored = true
		leaderboardPart.Parent = leaderboardsFolder
	end

	surfaceGui = leaderboardPart:FindFirstChildOfClass("SurfaceGui")
	if not surfaceGui then
		surfaceGui = Instance.new("SurfaceGui")
		surfaceGui.Name = "RAPLeaderboardGui"
		surfaceGui.Parent = leaderboardPart
		surfaceGui.Face = Enum.NormalId.Front
		surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		surfaceGui.PixelsPerStud = 50
	end
    surfaceGui.Enabled = true

	local backgroundFrame = surfaceGui:FindFirstChild("Background") or Instance.new("Frame")
	backgroundFrame.Name = "Background"
	backgroundFrame.Parent = surfaceGui
	backgroundFrame.Size = UDim2.new(1, 0, 1, 0)
	backgroundFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
	backgroundFrame.BorderColor3 = Color3.fromRGB(80, 80, 120)
	backgroundFrame.BorderSizePixel = 2

	local titleLabel = backgroundFrame:FindFirstChild("Title") or Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Parent = backgroundFrame
	titleLabel.Size = UDim2.new(1, 0, 0.1, 0)
	titleLabel.Text = "TOP 100 RAP"
	titleLabel.Font = Enum.Font.SourceSansBold
	titleLabel.TextSize = 48
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
	titleLabel.BorderColor3 = Color3.fromRGB(80, 80, 120)
	titleLabel.BorderSizePixel = 2

	listFrame = backgroundFrame:FindFirstChild("ListFrame") or Instance.new("ScrollingFrame")
	listFrame.Name = "ListFrame"
	listFrame.Parent = backgroundFrame
	listFrame.Position = UDim2.new(0, 0, 0.1, 0)
	listFrame.Size = UDim2.new(1, 0, 0.9, 0)
	listFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
	listFrame.BorderSizePixel = 0
	listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	listFrame.ScrollBarThickness = 8

	local uiListLayout = listFrame:FindFirstChildOfClass("UIListLayout") or Instance.new("UIListLayout")
	uiListLayout.Parent = listFrame
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Padding = UDim.new(0, 5)

	-- Header
	local headerFrame = listFrame:FindFirstChild("Header") or Instance.new("Frame")
	headerFrame.Name = "Header"
	headerFrame.Parent = listFrame
	headerFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
	headerFrame.Size = UDim2.new(1, -8, 0, 35) -- Leave space for scrollbar
	headerFrame.LayoutOrder = 0

	local rankHeader = headerFrame:FindFirstChild("Rank") or Instance.new("TextLabel")
	rankHeader.Name = "Rank"
	rankHeader.Parent = headerFrame
	rankHeader.Size = UDim2.new(0.15, 0, 1, 0)
	rankHeader.Text = "Rank"
	rankHeader.Font = Enum.Font.SourceSansBold
	rankHeader.TextSize = 28
	rankHeader.TextColor3 = Color3.fromRGB(200, 200, 200)
	rankHeader.BackgroundTransparency = 1

	local nameHeader = headerFrame:FindFirstChild("Name") or Instance.new("TextLabel")
	nameHeader.Name = "Name"
	nameHeader.Parent = headerFrame
	nameHeader.Position = UDim2.new(0.15, 0, 0, 0)
	nameHeader.Size = UDim2.new(0.55, 0, 1, 0)
	nameHeader.Text = "Player"
	nameHeader.Font = Enum.Font.SourceSansBold
	nameHeader.TextSize = 28
	nameHeader.TextColor3 = Color3.fromRGB(200, 200, 200)
	nameHeader.BackgroundTransparency = 1

	local rapHeader = headerFrame:FindFirstChild("RAP") or Instance.new("TextLabel")
	rapHeader.Name = "RAP"
	rapHeader.Parent = headerFrame
	rapHeader.Position = UDim2.new(0.7, 0, 0, 0)
	rapHeader.Size = UDim2.new(0.3, 0, 1, 0)
	rapHeader.Text = "RAP"
	rapHeader.Font = Enum.Font.SourceSansBold
	rapHeader.TextSize = 28
	rapHeader.TextColor3 = Color3.fromRGB(200, 200, 200)
	rapHeader.BackgroundTransparency = 1

	statusLabel = listFrame:FindFirstChild("Status") or Instance.new("TextLabel")
	statusLabel.Name = "Status"
	statusLabel.Parent = listFrame
	statusLabel.Size = UDim2.new(1, 0, 0, 50)
	statusLabel.Text = "Loading..."
	statusLabel.Font = Enum.Font.SourceSans
	statusLabel.TextSize = 32
	statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	statusLabel.BackgroundTransparency = 1
	statusLabel.LayoutOrder = 1
end

local function updateLeaderboard()
	if not listFrame then return end

	-- 1. Clear existing entries and show loading status
	for _, child in ipairs(listFrame:GetChildren()) do
		if child:IsA("Frame") and child.Name ~= "Header" then
			child:Destroy()
		end
	end
	statusLabel.Visible = true
	statusLabel.Text = "Loading..."

	-- 2. Get top 100 from OrderedDataStore
	local pages
	local success, err = pcall(function()
		pages = rapLeaderboardStore:GetSortedAsync(false, TOP_N_PLAYERS)
	end)

	if not success then
		warn("Could not get leaderboard pages: " .. tostring(err))
		statusLabel.Text = "Error loading leaderboard data."
		return
	end

	local topPage = pages:GetCurrentPage()
	if #topPage == 0 then
		statusLabel.Text = "No players on the leaderboard yet."
		return
	end
	
	statusLabel.Visible = false

	-- 3. Populate the list with the top N players
	local rank = 0
	for _, entry in ipairs(topPage) do
		rank = rank + 1
		local userId = tonumber(entry.key)
		local rapValue = entry.value
		
		-- Fetch player info with pcalls for safety
		local playerName = "[Deleted User]"
		local nameSuccess, nameResult = pcall(function() return Players:GetNameFromUserIdAsync(userId) end)
		if nameSuccess then playerName = nameResult end

		local avatarUrl, isReady
		local avatarSuccess, avatarResult = pcall(function() return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48) end)
		if avatarSuccess then avatarUrl, isReady = avatarResult, true end
		
		-- Create GUI elements for the entry
		local entryFrame = Instance.new("Frame")
		entryFrame.Name = "Entry" .. rank
		entryFrame.Parent = listFrame
		entryFrame.Size = UDim2.new(1, -8, 0, 42)
		entryFrame.BackgroundColor3 = rank % 2 == 1 and Color3.fromRGB(35, 35, 55) or Color3.fromRGB(40, 40, 60)
		entryFrame.BorderSizePixel = 0
		entryFrame.LayoutOrder = rank

		local rankLabel = Instance.new("TextLabel")
		rankLabel.Name = "Rank"
		rankLabel.Parent = entryFrame
		rankLabel.Size = UDim2.new(0.15, 0, 1, 0)
		rankLabel.Text = "#" .. rank
		rankLabel.Font = Enum.Font.SourceSansBold
		rankLabel.TextSize = 26
		rankLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		rankLabel.TextXAlignment = Enum.TextXAlignment.Center
		rankLabel.BackgroundTransparency = 1

		local avatarImage = Instance.new("ImageLabel")
		avatarImage.Name = "Avatar"
		avatarImage.Parent = entryFrame
		avatarImage.Position = UDim2.new(0.15, 5, 0.5, -18)
		avatarImage.Size = UDim2.new(0, 36, 0, 36)
		avatarImage.Image = avatarUrl or ""
		avatarImage.BackgroundTransparency = 1
		avatarImage.ClipsDescendants = true
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 8)
		corner.Parent = avatarImage

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Name = "Name"
		nameLabel.Parent = entryFrame
		nameLabel.Position = UDim2.new(0.15, 45, 0, 0)
		nameLabel.Size = UDim2.new(0.55, -45, 1, 0)
		nameLabel.Text = playerName
		nameLabel.Font = Enum.Font.SourceSans
		nameLabel.TextSize = 24
		nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.BackgroundTransparency = 1

		local rapLabel = Instance.new("TextLabel")
		rapLabel.Name = "RAP"
		rapLabel.Parent = entryFrame
		rapLabel.Position = UDim2.new(0.7, 0, 0, 0)
		rapLabel.Size = UDim2.new(0.3, -5, 1, 0)
		rapLabel.Text = ItemValueCalculator.GetFormattedRAP(rapValue)
		rapLabel.Font = Enum.Font.SourceSansSemibold
		rapLabel.TextSize = 24
		rapLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		rapLabel.TextXAlignment = Enum.TextXAlignment.Right
		rapLabel.BackgroundTransparency = 1
	end
	
	-- Update canvas size
	local listLayout = listFrame:FindFirstChildOfClass("UIListLayout")
	local numEntries = #topPage
	local entryHeight = 42
	local padding = listLayout.Padding.Offset
	listFrame.CanvasSize = UDim2.new(0, 0, 0, 35 + padding + (numEntries * (entryHeight + padding)))
end


function LeaderboardService.Start()
	createLeaderboardGUI()
	
	-- Initial update
	task.wait(5) -- Wait a bit for players to load in
	updateLeaderboard()

	-- Periodic updates
	task.spawn(function()
		while true do
			task.wait(LEADERBOARD_UPDATE_INTERVAL)
			pcall(updateLeaderboard)
		end
	end)
end

return LeaderboardService