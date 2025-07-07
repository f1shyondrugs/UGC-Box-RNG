local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local NavigationUI = require(script.Parent.Parent.UI.NavigationUI)

local NavigationController = {}

local navigationUI = nil
local soundController = nil

-- References to individual controllers for their toggle functions
local controllers = {}

function NavigationController.Start(parentGui, soundControllerRef)
	soundController = soundControllerRef
	
	-- Create the navigation UI with error handling
	local success, result = pcall(function()
		return NavigationUI.Create(parentGui)
	end)
	
	if success and result then
		navigationUI = result
	else
		warn("❌ NavigationController: Failed to create NavigationUI")
		warn("❌ Error: " .. tostring(result))
		return
	end
	
	-- Connect navigation buttons to placeholder functions
	-- These will be overridden when individual controllers register
	NavigationUI.ConnectButton(navigationUI, "Inventory", function()
		if soundController then soundController:playUIClick() end
		if controllers.Inventory then
			controllers.Inventory.toggle()
		end
	end)
	
	NavigationUI.ConnectButton(navigationUI, "Collection", function()
		if soundController then soundController:playUIClick() end
		if controllers.Collection then
			controllers.Collection.toggle()
		end
	end)
	
	NavigationUI.ConnectButton(navigationUI, "Upgrade", function()
		if soundController then soundController:playUIClick() end
		if controllers.Upgrade then
			controllers.Upgrade.toggle()
		end
	end)
	
	NavigationUI.ConnectButton(navigationUI, "Settings", function()
		if soundController then soundController:playUIClick() end
		if controllers.Settings then
			controllers.Settings.toggle()
		end
	end)

	NavigationUI.ConnectButton(navigationUI, "AutoOpen", function()
		if soundController then soundController:playUIClick() end
		if controllers.AutoOpen then
			print("Calling AutoOpenController.toggle()")
			controllers.AutoOpen.toggle()
		end
	end)

	NavigationUI.ConnectButton(navigationUI, "Shop", function()
		if soundController then soundController:playUIClick() end
		if controllers.Shop then
			controllers.Shop.toggle()
		end
	end)

	NavigationUI.ConnectButton(navigationUI, "Rebirth", function()
		if soundController then soundController:playUIClick() end
		if controllers.Rebirth then
			controllers.Rebirth.toggle()
		end
	end)
end

-- Function for individual controllers to register their toggle functions
function NavigationController.RegisterController(controllerName, toggleFunction)
	controllers[controllerName] = {
		toggle = toggleFunction
	}
	print("Registered controller: " .. controllerName)
end

-- Function to add notifications to navigation buttons
function NavigationController.SetNotification(buttonName, visible)
	if navigationUI then
		NavigationUI.AddNotification(navigationUI, buttonName, visible)
	end
end

-- Function to update button icons
function NavigationController.SetIcon(buttonName, icon)
	if navigationUI then
		NavigationUI.SetButtonIcon(navigationUI, buttonName, icon)
	end
end

return NavigationController 