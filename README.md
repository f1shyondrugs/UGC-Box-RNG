# Bobolox RNG Game

This is a simple box-opening RNG game created for Roblox and managed with Rojo.

## Gameplay Loop

1.  **Currency:** You start with 100 cash and receive 1 cash every 5 seconds.
2.  **Buy Boxes:** A UI allows you to buy a "Common Crate" for 25 cash.
3.  **Open Boxes & Get Items:** Opening a crate gives you a random item with a specific rarity. The result is displayed on your screen.
4.  **Inventory:** A separate UI displays all the items you own.
5.  **Sell Items:** You can sell items directly from your inventory to earn more cash.

## Project Structure

-   `src/shared`: Contains the game configuration (`GameConfig.lua`) and remote event definitions (`Remotes.lua`).
-   `src/server`: Manages all the backend logic, including player data, box opening, and item selling.
-   `src/client`: Handles the user interface and client-side logic.

## How to Play

1.  Open the project in Roblox Studio using the Rojo plugin.
2.  Start a playtest session.
3.  The UI will appear on your screen to buy boxes.
4.  An inventory panel will show your items.
5.  Enjoy the game! 