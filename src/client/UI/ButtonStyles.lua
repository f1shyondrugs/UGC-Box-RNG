-- ButtonStyles.lua
-- Modern, playful button styles for simulator games

local TweenService = game:GetService("TweenService")

local ButtonStyles = {}

-- Modern simulator game button styles
ButtonStyles.Styles = {
	-- Primary action button (buy, upgrade, etc.)
	Primary = {
		BackgroundColor = Color3.fromRGB(255, 193, 7), -- Bright yellow
		TextColor = Color3.fromRGB(0, 0, 0), -- Black text
		StrokeColor = Color3.fromRGB(255, 235, 59), -- Lighter yellow stroke
		Gradient = {
			ColorSequence.new{
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 235, 59)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 193, 7))
			},
			90 -- Rotation
		},
		HoverColor = Color3.fromRGB(255, 235, 59),
		HoverStrokeColor = Color3.fromRGB(255, 255, 255)
	},
	
	-- Success/positive action button
	Success = {
		BackgroundColor = Color3.fromRGB(76, 175, 80), -- Green
		TextColor = Color3.fromRGB(255, 255, 255), -- White text
		StrokeColor = Color3.fromRGB(129, 199, 132), -- Lighter green stroke
		Gradient = {
			ColorSequence.new{
				ColorSequenceKeypoint.new(0, Color3.fromRGB(129, 199, 132)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(76, 175, 80))
			},
			90 -- Rotation
		},
		HoverColor = Color3.fromRGB(129, 199, 132),
		HoverStrokeColor = Color3.fromRGB(200, 230, 201)
	},
	
	-- Danger/warning button
	Danger = {
		BackgroundColor = Color3.fromRGB(244, 67, 54), -- Red
		TextColor = Color3.fromRGB(255, 255, 255), -- White text
		StrokeColor = Color3.fromRGB(239, 154, 154), -- Lighter red stroke
		Gradient = {
			ColorSequence.new{
				ColorSequenceKeypoint.new(0, Color3.fromRGB(239, 154, 154)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(244, 67, 54))
			},
			90 -- Rotation
		},
		HoverColor = Color3.fromRGB(239, 154, 154),
		HoverStrokeColor = Color3.fromRGB(255, 235, 238)
	},
	
	-- Info/secondary button
	Info = {
		BackgroundColor = Color3.fromRGB(33, 150, 243), -- Blue
		TextColor = Color3.fromRGB(255, 255, 255), -- White text
		StrokeColor = Color3.fromRGB(144, 202, 249), -- Lighter blue stroke
		Gradient = {
			ColorSequence.new{
				ColorSequenceKeypoint.new(0, Color3.fromRGB(144, 202, 249)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(33, 150, 243))
			},
			90 -- Rotation
		},
		HoverColor = Color3.fromRGB(144, 202, 249),
		HoverStrokeColor = Color3.fromRGB(227, 242, 253)
	},
	
	-- Purple/magical button
	Magical = {
		BackgroundColor = Color3.fromRGB(156, 39, 176), -- Purple
		TextColor = Color3.fromRGB(255, 255, 255), -- White text
		StrokeColor = Color3.fromRGB(206, 147, 216), -- Lighter purple stroke
		Gradient = {
			ColorSequence.new{
				ColorSequenceKeypoint.new(0, Color3.fromRGB(206, 147, 216)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(156, 39, 176))
			},
			90 -- Rotation
		},
		HoverColor = Color3.fromRGB(206, 147, 216),
		HoverStrokeColor = Color3.fromRGB(243, 229, 245)
	},
	
	-- Disabled button
	Disabled = {
		BackgroundColor = Color3.fromRGB(158, 158, 158), -- Gray
		TextColor = Color3.fromRGB(117, 117, 117), -- Dark gray text
		StrokeColor = Color3.fromRGB(189, 189, 189), -- Lighter gray stroke
		Gradient = {
			ColorSequence.new{
				ColorSequenceKeypoint.new(0, Color3.fromRGB(189, 189, 189)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(158, 158, 158))
			},
			90 -- Rotation
		},
		HoverColor = Color3.fromRGB(158, 158, 158),
		HoverStrokeColor = Color3.fromRGB(189, 189, 189)
	},
	
	-- Navigation button style (dark theme with subtle accent)
	Navigation = {
		BackgroundColor = Color3.fromRGB(45, 45, 65), -- Dark blue-gray
		TextColor = Color3.fromRGB(255, 255, 255), -- White text
		StrokeColor = Color3.fromRGB(80, 80, 120), -- Subtle blue accent
		Gradient = {
			ColorSequence.new{
				ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 80, 120)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(45, 45, 65))
			},
			90 -- Rotation
		},
		HoverColor = Color3.fromRGB(60, 60, 85), -- Lighter on hover
		HoverStrokeColor = Color3.fromRGB(100, 100, 140) -- Brighter accent on hover
	}
}

-- Apply a button style to a TextButton
function ButtonStyles.ApplyStyle(button, styleName, options)
	local style = ButtonStyles.Styles[styleName]
	if not style then
		warn("Button style not found:", styleName)
		return
	end
	
	options = options or {}
	
	-- Set basic properties
	button.BackgroundColor3 = style.BackgroundColor
	button.TextColor3 = style.TextColor
	
	-- Create or update corner
	local corner = button:FindFirstChild("UICorner")
	if not corner then
		corner = Instance.new("UICorner")
		corner.Parent = button
	end
	corner.CornerRadius = UDim.new(0, options.cornerRadius or 12)
	
	-- Create or update stroke
	local stroke = button:FindFirstChild("UIStroke")
	if not stroke then
		stroke = Instance.new("UIStroke")
		stroke.Parent = button
	end
	stroke.Color = style.StrokeColor
	stroke.Thickness = options.strokeThickness or 2
	stroke.Transparency = options.strokeTransparency or 0.3
	
	-- Create or update gradient
	local gradient = button:FindFirstChild("UIGradient")
	if not gradient then
		gradient = Instance.new("UIGradient")
		gradient.Parent = button
	end
	gradient.Color = style.Gradient[1]
	gradient.Rotation = style.Gradient[2]
	
	-- Store style info for hover effects
	button:SetAttribute("ButtonStyle", styleName)
	button:SetAttribute("HoverColor", style.HoverColor)
	button:SetAttribute("HoverStrokeColor", style.HoverStrokeColor)
	
	-- Add hover effects if not disabled
	if not options.disableHover then
		ButtonStyles.AddHoverEffects(button)
	end
	
	return button
end

-- Add hover effects to a button
function ButtonStyles.AddHoverEffects(button)
	-- Remove existing connections
	if button:GetAttribute("HoverConnected") then
		return -- Already connected
	end
	
	button:SetAttribute("HoverConnected", true)
	
	-- Store original colors
	local originalBackground = button.BackgroundColor3
	local originalStroke = button:FindFirstChild("UIStroke")
	local originalStrokeColor = originalStroke and originalStroke.Color or Color3.fromRGB(255, 255, 255)
	
	-- Hover effects
	button.MouseEnter:Connect(function()
		local hoverColor = button:GetAttribute("HoverColor")
		local hoverStrokeColor = button:GetAttribute("HoverStrokeColor")
		
		if hoverColor then
			TweenService:Create(button, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundColor3 = hoverColor
			}):Play()
		end
		
		if originalStroke and hoverStrokeColor then
			TweenService:Create(originalStroke, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Color = hoverStrokeColor,
				Transparency = 0.1
			}):Play()
		end
	end)
	
	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = originalBackground
		}):Play()
		
		if originalStroke then
			TweenService:Create(originalStroke, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Color = originalStrokeColor,
				Transparency = 0.3
			}):Play()
		end
	end)
	
	-- Click effect (scale down slightly)
	button.MouseButton1Down:Connect(function()
		local currentSize = button.Size
		TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(currentSize.X.Scale * 0.95, currentSize.X.Offset * 0.95, currentSize.Y.Scale * 0.95, currentSize.Y.Offset * 0.95)
		}):Play()
	end)
	
	button.MouseButton1Up:Connect(function()
		local currentSize = button.Size
		TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(currentSize.X.Scale / 0.95, currentSize.X.Offset / 0.95, currentSize.Y.Scale / 0.95, currentSize.Y.Offset / 0.95)
		}):Play()
	end)
end

-- Create a button with a specific style
function ButtonStyles.CreateButton(parent, text, styleName, options)
	options = options or {}
	
	local button = Instance.new("TextButton")
	button.Name = options.name or "StyledButton"
	button.Size = options.size or UDim2.new(0, 200, 0, 50)
	button.Position = options.position or UDim2.new(0.5, -100, 0.5, -25)
	button.Text = text
	button.Font = options.font or Enum.Font.GothamBold
	button.TextSize = options.textSize or 18
	button.TextScaled = options.textScaled or false
	button.AutoButtonColor = false -- We handle our own hover effects
	button.ZIndex = options.zIndex or 1
	button.Parent = parent
	
	-- Apply the style
	ButtonStyles.ApplyStyle(button, styleName, options)
	
	return button
end

-- Update button style (useful for state changes)
function ButtonStyles.UpdateStyle(button, newStyleName, options)
	ButtonStyles.ApplyStyle(button, newStyleName, options)
end

return ButtonStyles 