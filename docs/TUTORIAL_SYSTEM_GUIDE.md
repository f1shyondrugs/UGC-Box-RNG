# Tutorial System Guide

## Overview

The tutorial system is designed to help new players understand the game and encourage them to stay engaged. It provides an interactive step-by-step guide through the game's core features.

## Components

### TutorialController
- **Location**: `src/client/Controllers/TutorialController.lua`
- **Purpose**: Interactive step-by-step tutorial that guides new players through the game's core features
- **Features**:
  - Highlights UI elements with visual effects
  - Step-by-step instructions
  - Progress tracking
  - Skip functionality
  - Automatic detection of new players

## Server-Side Services

### TutorialService
- **Location**: `src/server/Services/TutorialService.lua`
- **Purpose**: Handles tutorial completion tracking
- **Features**:
  - Tutorial completion validation
  - Player data management

## How It Works

### For New Players
1. **Automatic Detection**: System detects players who haven't opened any boxes
2. **Interactive Tutorial**: Step-by-step guide through core features
3. **Visual Highlights**: UI elements are highlighted to guide attention
4. **Progress Tracking**: Players can see their progress through the tutorial
5. **Skip Option**: Players can skip the tutorial if desired
6. **GUI Awareness**: Tutorial automatically hides when other GUIs are opened

### For Returning Players
- Tutorial is automatically skipped for players who have already opened boxes
- No interference with existing gameplay

## Tutorial Steps

The tutorial covers these key areas:
1. Welcome introduction
2. Crate selection (choosing different crate types)
3. Buying first crate
4. Checking inventory
5. Selling items
6. Upgrades system
7. Robux shop (premium crates)
8. Rebirth system
9. Auto-open feature
10. Settings customization
11. Completion message

## Integration

The tutorial system is automatically integrated into the main client script:

```lua
-- In src/client/Main.client.lua
TutorialController.Start(PlayerGui)
```

And the server service is started in the main server script:

```lua
-- In src/server/Main.server.lua
TutorialService.Start()
```

## Benefits

1. **Reduced Player Churn**: New players understand the game better
2. **Clear Direction**: Players know exactly what to do next
3. **Non-Intrusive**: Only shows for new players
4. **Comprehensive Coverage**: Covers all major game features
5. **Visual Guidance**: Highlights important UI elements

## Customization

### Adding New Tutorial Steps
Edit the `tutorialSteps` table in `TutorialController.lua`:

```lua
{
    id = "new_step",
    title = "New Feature",
    description = "Description of the new feature",
    position = UDim2.new(0.5, 0, 0.3, 0),
    target = "TargetButtonName",
    action = "click",
    duration = 4
}
```

### Modifying Tutorial Behavior
- **New Player Detection**: Modify the `checkIfNewPlayer()` function
- **Step Duration**: Adjust the `duration` field in tutorial steps
- **UI Positioning**: Change the `position` field for different screen layouts
- **Target Elements**: Update the `target` field to highlight different UI elements

## Technical Details

### Tutorial State Management
- Tracks current step and completion status
- Prevents multiple tutorial instances
- Handles player disconnection gracefully

### UI Components
- **Overlay**: Semi-transparent background to focus attention
- **Tooltip**: Larger information box (400x160) with step details
- **Highlights**: Visual effects on target UI elements
- **Progress**: Step counter and navigation buttons
- **GUI Integration**: Automatically hides when other GUIs are opened

### Server Communication
- Saves tutorial completion status
- Validates tutorial progress
- Handles tutorial completion events

## Future Enhancements

1. **Data Persistence**: Save tutorial completion to DataStore
2. **Tutorial Customization**: Allow players to replay specific sections
3. **Multi-language Support**: Localize tutorial text
4. **Analytics**: Track tutorial completion rates
5. **Advanced Targeting**: More sophisticated UI element detection
6. **Mobile Optimization**: Better touch interface support 