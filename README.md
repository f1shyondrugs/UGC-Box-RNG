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