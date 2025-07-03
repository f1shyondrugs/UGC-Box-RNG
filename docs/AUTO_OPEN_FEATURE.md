# Auto-Open Feature

## Overview
The Auto-Open feature is a premium gamepass-protected functionality that allows players to automatically open crates and manage their inventory with intelligent auto-selling capabilities.

## Requirements
- **Auto-Open Gamepass (ID: 1290860985)**: Players must own this gamepass to use the feature
- **Sufficient funds**: Players need enough R$ to purchase the selected crates
- **Crate selection**: A crate must be selected in the main UI before auto-opening begins

## Location
The Auto-Open button is located to the left of the navigation panel, alongside other UI elements. It's always visible but functionality requires the gamepass.

## Features

### Auto-Opening Settings
- **Crates to Auto-Open**: Set how many crates to open automatically (1-100)
- **Stop Below R$**: Set a minimum currency threshold to stop auto-opening
- **Auto-Sell Below Size**: Automatically sell items smaller than the specified size (1-10)
- **Auto-Sell Below Value**: Automatically sell items worth less than the specified R$ amount
- **Auto-Sell Mutations**: Select specific mutations to automatically sell

### Smart Auto-Selling
The system automatically evaluates each item received and sells it if it matches any of these criteria:
- Item size is below the threshold
- Item value is below the threshold  
- Item has a selected mutation for auto-selling

### Settings Persistence
All settings are saved locally and restored when the player rejoins the game.

## Usage

### For Players Without Gamepass
1. Click the "🤖 Auto-Open (Purchase)" button
2. A Roblox gamepass purchase prompt will appear
3. Complete the purchase to unlock the feature

### For Players With Gamepass
1. Click the "🤖 Auto-Open: OFF/ON" button to open settings
2. Configure your preferences:
   - Enable/disable the feature with the toggle
   - Set the number of crates to open
   - Set your money threshold
   - Configure auto-sell parameters
   - Select mutations to auto-sell
3. Close the settings panel to save changes
4. The feature will automatically run every 2 seconds when enabled

## Technical Details

### File Structure
- **UI**: `src/client/UI/AutoOpenUI.lua`
- **Controller**: `src/client/Controllers/AutoOpenController.lua`
- **Server Service**: `src/server/Services/AutoOpenService.lua`
- **Configuration**: Auto-Open gamepass ID is stored in `GameConfig.lua`

### Integration Points
- Uses existing `Remotes.RequestBox` for crate opening
- Uses existing `Remotes.SellItem` for auto-selling
- Integrates with the BuyButton UI for crate selection
- Follows the established UI styling patterns

### Safety Features
- Gamepass verification on both client and server
- Money threshold checking to prevent overspending
- Error handling for network requests
- Settings validation and bounds checking

## Customization
Server owners can modify:
- Gamepass ID in `GameConfig.lua`
- Auto-opening frequency (currently 2 seconds)
- Default settings values
- UI positioning and styling
- Auto-sell criteria logic 