local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local InsertService = game:GetService("InsertService")

local ItemValueCalculator = require(ReplicatedStorage.Shared.Modules.ItemValueCalculator)
local GameConfig = require(ReplicatedStorage.Shared.Modules.GameConfig)
local NumberFormatter = require(ReplicatedStorage.Shared.Modules.NumberFormatter)
local boxesLeaderboardStore = DataStoreService:GetOrderedDataStore("BoxesLeaderboard_V1")

local BoxesLeaderboardService = {}

local LEADERBOARD_UPDATE_INTERVAL = 30 -- Reduced from 60 to 30 seconds for more frequent updates
local TOP_N_PLAYERS = 100

local leaderboardPart = nil
local surfaceGui = nil
local listFrame = nil
local statusLabel = nil
local leaderboardData = nil

local function createLeaderboardGUI()
	local leaderboardsFolder = Workspace:FindFirstChild("leaderboards")
	if not leaderboardsFolder then
		leaderboardsFolder = Instance.new("Folder")
		leaderboardsFolder.Name = "leaderboards"
		leaderboardsFolder.Parent = Workspace
	end

	leaderboardPart = leaderboardsFolder:FindFirstChild("BoxesLeaderboard")
	if not leaderboardPart then
		leaderboardPart = Instance.new("Part")
		leaderboardPart.Name = "BoxesLeaderboard"
		leaderboardPart.Size = Vector3.new(18, 30, 1)
		leaderboardPart.Position = Vector3.new(20, 15, -20) -- Position next to RAP leaderboard
		leaderboardPart.Anchored = true
		leaderboardPart.Parent = leaderboardsFolder
	end

	surfaceGui = leaderboardPart:FindFirstChildOfClass("SurfaceGui")
	if not surfaceGui then
		surfaceGui = Instance.new("SurfaceGui")
		surfaceGui.Name = "BoxesLeaderboardGui"
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
	backgroundFrame.BackgroundColor3 = Color3.fromRGB(86, 64, 44) -- Specified bg color
	backgroundFrame.BorderColor3 = Color3.fromRGB(75, 57, 47) -- Specified border color
	backgroundFrame.BorderSizePixel = 3

	local titleLabel = backgroundFrame:FindFirstChild("Title") or Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Parent = backgroundFrame
	titleLabel.Size = UDim2.new(1, 0, 0.1, 0)
	titleLabel.Text = "TOP 100 BOXES"
	titleLabel.Font = Enum.Font.Highway
	titleLabel.TextSize = 80
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.BackgroundColor3 = Color3.fromRGB(75, 57, 47) -- Specified toppart color
	titleLabel.BorderColor3 = Color3.fromRGB(75, 57, 47) -- Specified border color
	titleLabel.BorderSizePixel = 3

	listFrame = backgroundFrame:FindFirstChild("ListFrame") or Instance.new("ScrollingFrame")
	listFrame.Name = "ListFrame"
	listFrame.Parent = backgroundFrame
	listFrame.Position = UDim2.new(0, 0, 0.1, 0)
	listFrame.Size = UDim2.new(1, 0, 0.9, 0)
	listFrame.BackgroundColor3 = Color3.fromRGB(86, 64, 44) -- Specified bg color
	listFrame.BorderSizePixel = 0
	listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	listFrame.ScrollBarThickness = 12

	local uiListLayout = listFrame:FindFirstChildOfClass("UIListLayout") or Instance.new("UIListLayout")
	uiListLayout.Parent = listFrame
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Padding = UDim.new(0, 8)

	-- Header
	local headerFrame = listFrame:FindFirstChild("Header") or Instance.new("Frame")
	headerFrame.Name = "Header"
	headerFrame.Parent = listFrame
	headerFrame.BackgroundColor3 = Color3.fromRGB(75, 57, 47) -- Specified toppart color
	headerFrame.Size = UDim2.new(1, -12, 0, 50) -- Leave space for scrollbar
	headerFrame.LayoutOrder = 0

	local rankHeader = headerFrame:FindFirstChild("Rank") or Instance.new("TextLabel")
	rankHeader.Name = "Rank"
	rankHeader.Parent = headerFrame
	rankHeader.Size = UDim2.new(0.15, 0, 1, 0)
	rankHeader.Text = "Rank"
	rankHeader.Font = Enum.Font.SourceSansBold
	rankHeader.TextSize = 36
	rankHeader.TextColor3 = Color3.fromRGB(200, 200, 200)
	rankHeader.BackgroundTransparency = 1

	local nameHeader = headerFrame:FindFirstChild("Name") or Instance.new("TextLabel")
	nameHeader.Name = "Name"
	nameHeader.Parent = headerFrame
	nameHeader.Position = UDim2.new(0.15, 0, 0, 0)
	nameHeader.Size = UDim2.new(0.55, 0, 1, 0)
	nameHeader.Text = "Player"
	nameHeader.Font = Enum.Font.SourceSansBold
	nameHeader.TextSize = 36
	nameHeader.TextColor3 = Color3.fromRGB(200, 200, 200)
	nameHeader.BackgroundTransparency = 1

	local boxesHeader = headerFrame:FindFirstChild("Boxes") or Instance.new("TextLabel")
	boxesHeader.Name = "Boxes"
	boxesHeader.Parent = headerFrame
	boxesHeader.Position = UDim2.new(0.7, 0, 0, 0)
	boxesHeader.Size = UDim2.new(0.3, 0, 1, 0)
	boxesHeader.Text = "Boxes"
	boxesHeader.Font = Enum.Font.SourceSansBold
	boxesHeader.TextSize = 36
	boxesHeader.TextColor3 = Color3.fromRGB(200, 200, 200)
	boxesHeader.BackgroundTransparency = 1

	statusLabel = listFrame:FindFirstChild("Status") or Instance.new("TextLabel")
	statusLabel.Name = "Status"
	statusLabel.Parent = listFrame
	statusLabel.Size = UDim2.new(1, 0, 0, 70)
	statusLabel.Text = "Loading..."
	statusLabel.Font = Enum.Font.SourceSans
	statusLabel.TextSize = 40
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
		pages = boxesLeaderboardStore:GetSortedAsync(false, TOP_N_PLAYERS)
	end)

	if not success then
		warn("Could not get boxes leaderboard pages: " .. tostring(err))
		statusLabel.Text = "Error loading leaderboard data."
		return
	end

	local topPage = pages:GetCurrentPage()
	if #topPage == 0 then
		statusLabel.Text = "No players on the leaderboard yet."
		return
	end
	
	leaderboardData = topPage
	local leaderboardValue = ReplicatedStorage:FindFirstChild("BoxesLeaderboardData") or Instance.new("StringValue")
	leaderboardValue.Name = "BoxesLeaderboardData"
	leaderboardValue.Value = HttpService:JSONEncode(leaderboardData)
	leaderboardValue.Parent = ReplicatedStorage
	
	statusLabel.Visible = false

	-- 3. Populate the list with the top N players
	local rank = 0
	local listLayout = listFrame:FindFirstChildOfClass("UIListLayout")
	local padding = listLayout.Padding.Offset
	local totalContentHeight = 0

	for _, entry in ipairs(topPage) do
		rank = rank + 1
		local userId = tonumber(entry.key)
		local boxesValue = entry.value
		
		-- Fetch player info with pcalls for safety
		local playerName = "[Deleted User]"
		local nameSuccess, nameResult = pcall(function() return Players:GetNameFromUserIdAsync(userId) end)
		if nameSuccess then playerName = nameResult end

		local avatarUrl, isReady
		local avatarSuccess, avatarResult = pcall(function() return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100) end)
		if avatarSuccess then avatarUrl, isReady = avatarResult, true end
		
		-- Define sizes based on rank
		local entryHeight, rankTextSize, avatarSize, nameTextSize, boxesTextSize
		if rank <= 3 then
			entryHeight = 85
			rankTextSize = 38
			avatarSize = 72
			nameTextSize = 34
			boxesTextSize = 34
		else
			entryHeight = 70
			rankTextSize = 34
			avatarSize = 60
			nameTextSize = 30
			boxesTextSize = 30
		end
		totalContentHeight = totalContentHeight + entryHeight

		-- Create GUI elements for the entry
		local entryFrame = Instance.new("Frame")
		entryFrame.Name = "Entry" .. rank
		entryFrame.Parent = listFrame
		entryFrame.Size = UDim2.new(1, -12, 0, entryHeight)
		entryFrame.BackgroundColor3 = rank % 2 == 1 and Color3.fromRGB(96, 74, 54) or Color3.fromRGB(106, 84, 64) -- Lighter variations of bg color
		entryFrame.BorderSizePixel = 0
		entryFrame.LayoutOrder = rank

		local rankLabel = Instance.new("TextLabel")
		rankLabel.Name = "Rank"
		rankLabel.Parent = entryFrame
		rankLabel.Size = UDim2.new(0.15, 0, 1, 0)
		rankLabel.Text = "#" .. rank
		rankLabel.Font = Enum.Font.SourceSansBold
		rankLabel.TextSize = rankTextSize
		if rank == 1 then
			rankLabel.TextColor3 = Color3.fromRGB(255, 215, 0) -- Gold
		elseif rank == 2 then
			rankLabel.TextColor3 = Color3.fromRGB(192, 192, 192) -- Silver
		elseif rank == 3 then
			rankLabel.TextColor3 = Color3.fromRGB(205, 127, 50) -- Bronze
		else
			rankLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		end
		rankLabel.TextXAlignment = Enum.TextXAlignment.Center
		rankLabel.BackgroundTransparency = 1

		local avatarImage = Instance.new("ImageLabel")
		avatarImage.Name = "Avatar"
		avatarImage.Parent = entryFrame
		avatarImage.Position = UDim2.new(0.15, 10, 0.5, -(avatarSize / 2))
		avatarImage.Size = UDim2.new(0, avatarSize, 0, avatarSize)
		avatarImage.Image = avatarUrl or ""
		avatarImage.BackgroundTransparency = 1
		avatarImage.ClipsDescendants = true
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 12)
		corner.Parent = avatarImage

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Name = "Name"
		nameLabel.Parent = entryFrame
		local nameOffset = 10 + avatarSize + 10 -- avatar offset + avatar size + padding
		nameLabel.Position = UDim2.new(0.15, nameOffset, 0, 0)
		nameLabel.Size = UDim2.new(0.55, -nameOffset, 1, 0)
		nameLabel.Text = playerName
		nameLabel.Font = Enum.Font.SourceSans
		nameLabel.TextSize = nameTextSize
		nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.BackgroundTransparency = 1

		local boxesLabel = Instance.new("TextLabel")
		boxesLabel.Name = "Boxes"
		boxesLabel.Parent = entryFrame
		boxesLabel.Position = UDim2.new(0.7, 0, 0, 0)
		boxesLabel.Size = UDim2.new(0.3, -10, 1, 0)
		boxesLabel.Text = NumberFormatter.FormatCount(boxesValue)
		boxesLabel.Font = Enum.Font.SourceSansSemibold
		boxesLabel.TextSize = boxesTextSize
		boxesLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		boxesLabel.TextXAlignment = Enum.TextXAlignment.Right
		boxesLabel.BackgroundTransparency = 1
	end
	
	-- Update canvas size
	local numEntries = #topPage
	if numEntries > 0 then
		local headerHeight = listFrame:FindFirstChild("Header").Size.Y.Offset
		listFrame.CanvasSize = UDim2.new(0, 0, 0, headerHeight + (numEntries * padding) + totalContentHeight)
	end
end

function BoxesLeaderboardService.Start()
	createLeaderboardGUI()
	
	-- Initial update
	task.spawn(function()
		-- Small delay to ensure player data is loaded
		task.wait(1)
		pcall(updateLeaderboard)
	end)

	-- Periodic updates
	task.spawn(function()
		while true do
			task.wait(LEADERBOARD_UPDATE_INTERVAL)
			pcall(updateLeaderboard)
		end
	end)
end

return BoxesLeaderboardService 