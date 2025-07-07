# Performance Optimizations - Server Lag Fix

## Issues Identified and Fixed

### 1. Excessive RAP Calculations
**Problem**: RAP (Rare Asset Points) was being calculated on every inventory change, iterating through all items each time.
**Solution**: 
- Implemented RAP calculation throttling (3-second cooldown per player)
- Added RAP value caching to avoid redundant calculations
- Only recalculate RAP when necessary

### 2. Too Many Datastore Operations
**Problem**: Multiple datastore saves were happening frequently:
- Auto-save every 30 seconds for all players
- Save on every inventory change
- Save on every setting change  
- Save on every robux change >= 1000 or every 10 seconds
**Solution**:
- Implemented save queue system with throttling (5-second cooldown per player)
- Reduced auto-save frequency from 30 to 60 seconds
- Increased emergency save threshold from 1000 to 5000 robux and 10 to 30 seconds
- All saves now go through throttled queue system

### 3. Excessive Collection Updates
**Problem**: Collection updates were happening on every inventory change.
**Solution**: 
- Implemented collection update throttling (10-second cooldown per player)
- Collection updates now go through queue system

### 4. Leaderboard Update Frequency
**Problem**: Leaderboard updates were happening every 5 seconds.
**Solution**: Increased leaderboard update interval from 5 to 10 seconds

### 5. Inventory Change Handling
**Problem**: Every inventory addition/removal triggered immediate saves and collection updates.
**Solution**: 
- Replaced immediate operations with queue-based throttling
- Items are now queued for save/collection update instead of processed immediately

### 6. Slow Inventory Loading
**Problem**: Inventory loading used small batches (20 items) with 0.1 second delays, taking 10+ seconds for 2000 items.
**Solution**:
- **Instant loading**: All inventory items now load in one batch instead of multiple small batches
- **Bulk item creation**: Pre-allocate all items before setting parents to reduce overhead
- **No delays**: Removed all delays between inventory loading operations
- **Optimized batching**: Increased batch size from 20 to 1000+ items

### 7. Queue Data Loss on Player Leave
**Problem**: When players left, pending queue items (saves, collection updates, RAP updates) were lost.
**Solution**:
- **Queue preservation**: Check and process all pending queue items when player leaves
- **Immediate processing**: Force save any pending data before player departure
- **Comprehensive cleanup**: Process save, collection, and RAP queues before removing player data
- **Debug function**: Added `ForceProcessAllQueues()` for manual queue processing

## Performance Improvements

### Throttling Systems Implemented:
- **RAP Updates**: 3-second cooldown per player
- **Data Saves**: 5-second cooldown per player  
- **Collection Updates**: 10-second cooldown per player
- **Leaderboard Updates**: 10-second interval (increased from 5)

### Loading Optimizations:
- **Inventory Loading**: Instant loading of all items (no batching delays)
- **Batch Size**: Increased from 20 to 1000+ items per batch
- **Item Creation**: Bulk creation and parenting for faster performance
- **No Delays**: Removed all task.wait() calls during inventory loading

### Queue Systems:
- **Save Queue**: Batches save operations
- **RAP Update Queue**: Batches RAP leaderboard updates
- **Boxes Update Queue**: Batches boxes leaderboard updates  
- **Collection Update Queue**: Batches collection updates

### Caching:
- **RAP Cache**: Stores calculated RAP values to avoid recalculation
- **Cooldown Tracking**: Tracks last operation times per player

## Functions Added/Modified:

### New Functions:
- `processSaveQueue()`: Processes queued save operations
- `processCollectionQueue()`: Processes queued collection updates
- `DataService.ForceSave()`: Bypasses throttling for critical saves
- `DataService.ManualForceSave()`: Admin function to bypass all throttling
- `DataService.ForceProcessAllQueues()`: Force processes all pending queues for a player

### Modified Functions:
- `DataService.Save()`: Now uses queue instead of immediate save
- `updatePlayerRAP()`: Added throttling and caching
- `DataService.UpdatePlayerCollection()`: Added throttling
- `DataService.SavePlayerSetting()`: Uses queue instead of immediate save
- Player leaving handler: Now uses standard `game.Players.PlayerRemoving:Connect()` with optimized save logic

## Expected Performance Gains:

1. **Reduced Datastore API calls**: 60-80% reduction in datastore operations
2. **Reduced CPU usage**: RAP calculations throttled and cached
3. **Improved server responsiveness**: Batch processing instead of immediate operations
4. **Better scalability**: System can handle more concurrent players
5. **Reduced memory usage**: Proper cleanup of cached data
6. **Instant inventory loading**: 2000+ items load in <1 second instead of 10+ seconds
7. **Optimized item creation**: Bulk item creation and parenting for faster loading

## Backwards Compatibility:
- All existing function calls continue to work
- No breaking changes to external API
- Automatic migration to throttled system
- Critical operations (player leaving, force saves) still work immediately when needed

## Configuration:
All throttling intervals can be adjusted by changing the constants at the top of PlayerDataService.lua:
- `RAP_UPDATE_COOLDOWN = 3` (seconds)
- `SAVE_COOLDOWN = 5` (seconds)  
- `COLLECTION_UPDATE_COOLDOWN = 10` (seconds)
- `DEBOUNCE_INTERVAL = 10` (seconds) 