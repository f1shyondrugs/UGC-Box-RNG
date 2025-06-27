# Bobolox RNG Game

This is a box-opening RNG game created for Roblox and managed with Rojo.

## Gameplay Loop

1.  **Currency:** You start with a set amount of cash and receive more periodically.
2.  **Buy Boxes:** A UI allows you to buy different types of crates.
3.  **Open Boxes & Get Items:** Opening a crate gives you a random item with a specific rarity. The result is displayed on your screen with a notification and a camera shake.
4.  **Inventory:** A separate UI displays all the items you own.
5.  **Sell Items:** You can sell items directly from your inventory to earn more cash.
6.  **Player Stats:** Your stats, like cash, are displayed on the screen.
7.  **Nameplates:** Player nameplates are displayed above their characters.

## Project Structure

-   `src/shared`: Contains shared code between the client and server. [ReplicatedStorage.Shared]
    -   `Modules/`: Contains shared modules like `GameConfig.lua`, `Box.lua`, and `ItemValueCalculator.lua`.
    -   `Remotes/`: Contains `Remotes.lua` for remote event and function definitions.
-   `src/server`: Manages all the backend logic. [ServerScriptService.Server]
    -   `Main.server.lua`: The main entry point for the server.
    -   `Services/`: Contains various services to handle game logic.
        -   `PlayerDataService.lua`: Manages player data.
        -   `AdminService.lua`: Provides admin commands and functionality.
        -   `BoxService.lua`: Handles box opening logic.
        -   `CollisionService.lua`: Manages game collisions.
        -   `InventoryService.lua`: Manages player inventories.
-   `src/client`: Handles the user interface and client-side logic. [StarterPlayerScripts.Client]
    -   `Main.client.lua`: The main entry point for the client.
    -   `Controllers/`: Contains various controllers for client-side logic.
        -   `CameraShaker.lua`: Shakes the camera during events.
        -   `InventoryController.lua`: Manages the inventory UI.
        -   `NameplateController.lua`: Manages player nameplates.
        -   `Notifier.lua`: Displays notifications to the player.
        -   `BoxAnimator.lua`: Handles box opening animations.
    -   `UI/`: Contains the UI components.
        -   `NameplateUI.lua`: The UI for player nameplates.
        -   `StatsUI.lua`: The UI for player stats.
        -   `BuyButtonUI.lua`: The UI for buying boxes.
        -   `InventoryUI.lua`: The UI for the player's inventory.

## How to Play

1.  Open the project in Roblox Studio using the Rojo plugin.
2.  Start a playtest session.
3.  The UI will appear on your screen to buy boxes.
4.  An inventory panel will show your items.
5.  Enjoy the game!

# RNG Simulator

A Roblox RNG (Random Number Generator) game where players can:
- Purchase and open crates to collect rare UGC items
- Build an inventory of unique cosmetic items
- Equip items to customize their avatar
- View their collection progress
- Upgrade their gameplay experience with various enhancements

## 🚀 New Features

### ⚡ Upgrade System
The game now includes a comprehensive upgrade system that allows players to enhance their gameplay experience:

#### Available Upgrades:
1. **More Inventory Slots** 🎒
   - Increases your inventory capacity beyond the default 50 slots
   - Starts at 50 slots, +5 slots per level
   - Maximum level 100 (550 total slots)
   - Cost scaling: 1000 R$ base cost with 5x exponential scaling

2. **Multi-Crate Opening** 📦
   - Unlock the ability to open multiple crates simultaneously
   - Starts at 1 box, +1 box per level
   - Maximum level 4 (5 boxes total)
   - Cost scaling: 10000 R$ base cost with 5x exponential scaling

3. **Faster Cooldowns** ⚡
   - Reduces the cooldown between crate purchases
   - Starts at 0.5s cooldown, -0.05s per level
   - Maximum level 8 (0.1s minimum cooldown)
   - Cost scaling: 2500 R$ base cost with 3.5x exponential scaling

#### Upgrade Features:
- **Persistent Progress**: All upgrades are saved using DataStore
- **Real-time Effects**: Upgrades immediately affect gameplay systems
- **Visual Feedback**: Clean UI showing current level, effects, and costs
- **Smart Affordability**: Buttons show when you can't afford upgrades
- **Mobile-Friendly**: Responsive design that works on all devices

### 🎮 Gameplay Features
- **Crate Opening**: Open crates to discover rare UGC cosmetic items
- **Inventory Management**: Store and organize your collected items
- **Avatar Customization**: Equip items to change your appearance
- **Collection Tracking**: Track your discovery progress across all items
- **Item Trading**: Lock valuable items to prevent accidental sales
- **Statistics**: View your total value, boxes opened, and progress

### 🎨 UI/UX Features
- **Modern Dark Theme**: Clean, professional interface
- **Responsive Design**: Works perfectly on desktop and mobile
- **Smooth Animations**: Polished tweening and visual effects
- **Sound Integration**: Audio feedback for all interactions
- **Accessibility**: Large touch targets for mobile users

## 🛠️ Technical Architecture

### Client-Side Structure
```
src/client/
├── Controllers/
│   ├── UpgradeController.lua      # Manages upgrade UI and interactions
│   ├── InventoryController.lua    # Handles inventory with upgrade limits
│   ├── CollectionController.lua   # Item collection tracking
│   └── ...
├── UI/
│   ├── UpgradeUI.lua             # Upgrade system interface
│   ├── InventoryUI.lua           # Dynamic inventory display
│   └── ...
└── Main.client.lua               # Updated with upgrade integration
```

### Server-Side Structure
```
src/server/Services/
├── UpgradeService.lua            # Core upgrade logic and persistence
├── PlayerDataService.lua         # Enhanced with upgrade data storage
├── BoxService.lua                # Updated to use upgrade limits
└── ...
```

### Shared Modules
```
src/shared/Modules/
├── UpgradeConfig.lua             # Upgrade definitions and calculations
├── GameConfig.lua                # Game configuration and items
└── ...
```

## 🔧 Development Setup

This project uses [Rojo](https://rojo.space/) for development workflow:

1. Install Rojo and dependencies
2. Run `rojo serve` to start the development server
3. Connect from Roblox Studio using the Rojo plugin
4. Make changes to the source files and sync to see updates

### Key Files for Upgrades:
- `UpgradeConfig.lua` - Define new upgrades and their scaling
- `UpgradeService.lua` - Server-side upgrade logic
- `UpgradeUI.lua` - Client-side interface (matches Collection GUI style)
- `PlayerDataService.lua` - Handles upgrade data persistence

## 📈 Future Enhancements

The upgrade system is designed to be easily extensible. Planned future upgrades include:
- **Luck Boost**: Increase rare item drop rates
- **Auto-Sell**: Automatically sell common items
- **Better Rewards**: Improve crate reward quality
- **Special Effects**: Cosmetic enhancements and animations

Note: **Faster Cooldowns** has been implemented as the third core upgrade!

## 🎯 Core Mechanics

- **Economy**: R$ currency system with balanced pricing
- **RNG**: Weighted random rewards with multiple rarity tiers
- **Progression**: Level-based upgrades with exponential costs
- **Persistence**: All player data saved securely with DataStore
- **Scalability**: Modular architecture supports easy feature additions 