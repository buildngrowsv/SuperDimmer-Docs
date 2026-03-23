# SuperDimmer Freeze Fix - Applied Changes

## Summary

Fixed the freeze/stuck issue caused by three interconnected problems:
1. **Overlay accumulation** - Decay overlays were never cleaned up
2. **Rapid idle/active cycling** - Event monitors firing constantly
3. **AutoMinimizeManager loop** - Windows being minimized repeatedly

## Changes Made

### 1. Overlay Cleanup (CRITICAL FIX)
**File**: `OverlayManager.swift` line 929

**Problem**: Comment said "DO NOT destroy stale overlays" and let them accumulate forever.

**Fix**: Added cleanup logic to remove overlays for windows that no longer exist:

```swift
// CLEANUP: Remove overlays for windows that no longer exist
let currentWindowIDs = Set(decisions.map { $0.windowID })
let staleOverlayIDs = Set(self.decayOverlays.keys).subtracting(currentWindowIDs)

if !staleOverlayIDs.isEmpty {
    print("🗑️ Cleaning up \(staleOverlayIDs.count) stale decay overlays")
    for staleID in staleOverlayIDs {
        if let staleOverlay = self.decayOverlays.removeValue(forKey: staleID) {
            self.safeHideOverlay(staleOverlay)
        }
    }
}
```

**Impact**: Prevents overlay count from growing indefinitely. With rapid idle/active cycling, this was creating hundreds of hidden overlays.

### 2. Idle State Debouncing (HIGH PRIORITY FIX)
**File**: `ActiveUsageTracker.swift` lines 90-110, 226-256

**Problem**: Event monitors fired on EVERY mouse movement, causing `isUserActive` to toggle dozens of times per second.

**Fix**: Added debouncing to only publish state changes if:
- At least 2 seconds have passed since last change
- The state actually changed (not just flickering)

```swift
// New properties
private let minStateChangeInterval: TimeInterval = 2.0
private var lastStateChangeTime: Date = Date()
private var lastPublishedState: Bool = true

// In updateIdleState()
let newActiveState = timeSinceActivity < self.activeThreshold

let now = Date()
let stateChanged = newActiveState != self.lastPublishedState
let enoughTimePassed = now.timeIntervalSince(self.lastStateChangeTime) >= self.minStateChangeInterval

if stateChanged && enoughTimePassed {
    self.isUserActive = newActiveState
    self.lastPublishedState = newActiveState
    self.lastStateChangeTime = now
    print("🔄 ActiveUsageTracker: State changed to \(newActiveState ? "ACTIVE" : "IDLE")")
}
```

**Impact**: Eliminates rapid idle/active cycling that was:
- Blocking the main thread
- Causing "Fetch Current User Activity" deadline misses
- Triggering overlay creation/destruction constantly

### 3. Decay Dimming Throttling (SAFETY FIX)
**File**: `OverlayManager.swift` lines 121-137, 852-862

**Problem**: `applyDecayDimming` was being called dozens of times per second during idle/active cycling.

**Fix**: Added throttling to limit calls to once per 500ms:

```swift
// New properties
private var lastDecayApplyTime: CFAbsoluteTime = 0
private let minDecayApplyInterval: CFAbsoluteTime = 0.5  // 500ms minimum

// In applyDecayDimming()
let now = CFAbsoluteTimeGetCurrent()
if now - lastDecayApplyTime < minDecayApplyInterval {
    return  // Too soon, skip this call
}
lastDecayApplyTime = now
```

**Impact**: Prevents excessive UI updates and window server strain. Decay dimming is gradual anyway, so 500ms is plenty fast.

### 4. AutoMinimizeManager Double-Check (SAFETY FIX)
**File**: `AutoMinimizeManager.swift` lines 408-426

**Problem**: AppleScript execution is slow (100-500ms), and during that time the next analysis cycle could start and try to minimize the same window again.

**Fix**: Added check at call site before even attempting to minimize:

```swift
// Check before calling minimizeWindow
lock.lock()
let alreadyMinimizing = currentlyMinimizing.contains(window.id)
lock.unlock()

if !alreadyMinimizing {
    minimizeWindow(windowID: window.id, appName: window.info.ownerName)
    minimizedCount += 1
}
```

**Impact**: Prevents the infinite loop where Chrome windows were being minimized repeatedly.

## Testing Instructions

### 1. Monitor Overlay Count
```bash
tail -f /tmp/superdimmer_debug.log | grep "decayOverlays.count"
```

**Expected**: Count should stay stable or decrease, matching the number of visible windows.

**Before fix**: Count would grow continuously (14, 17, 20, etc.)

### 2. Monitor Idle State Changes
```bash
tail -f /tmp/superdimmer_debug.log | grep "User idle\|User active\|State changed"
```

**Expected**: State changes every 2+ seconds, not constantly.

**Before fix**: Rapid toggling with "was idle for 0s"

### 3. Monitor Chrome Minimization
```bash
tail -f /tmp/superdimmer_debug.log | grep "AutoMinimizeManager"
```

**Expected**: Each window minimized once, not repeatedly.

**Before fix**: Same window ID appearing multiple times

### 4. Check Activity Monitor
- CPU usage should be < 10% when idle
- Memory should stabilize around 150-200 MB
- No "Fetch Current User Activity" warnings in Console

### 5. Visual Check
- No random overlays stuck on screen
- Overlays should disappear when windows close
- App should remain responsive

## Expected Results

After these fixes:
- ✅ No overlay accumulation
- ✅ No rapid idle/active cycling
- ✅ CPU usage < 10% when idle
- ✅ No repeated window minimization
- ✅ No main thread blocking
- ✅ Memory stable around 150-200 MB
- ✅ App remains responsive

## Rollback Instructions

If issues occur, revert the changes:

```bash
cd /Users/ak/UserRoot/Github/SuperDimmer
git diff HEAD -- SuperDimmer-Mac-App/SuperDimmer/Overlay/OverlayManager.swift
git diff HEAD -- SuperDimmer-Mac-App/SuperDimmer/Services/ActiveUsageTracker.swift
git diff HEAD -- SuperDimmer-Mac-App/SuperDimmer/Services/AutoMinimizeManager.swift

# To revert:
git checkout HEAD -- SuperDimmer-Mac-App/SuperDimmer/Overlay/OverlayManager.swift
git checkout HEAD -- SuperDimmer-Mac-App/SuperDimmer/Services/ActiveUsageTracker.swift
git checkout HEAD -- SuperDimmer-Mac-App/SuperDimmer/Services/AutoMinimizeManager.swift
```

## Next Steps

1. **Run the app** and monitor for 5-10 minutes
2. **Check logs** for any issues
3. **Test with multiple windows** open
4. **Test with Chrome** specifically (was being minimized repeatedly)
5. **Monitor memory** in Activity Monitor
6. **Check for responsiveness** - no spinning cursor

## Additional Monitoring

If you want to add more monitoring, add this to `DimmingCoordinator.performAnalysisCycle()`:

```swift
// Monitor overlay health
let regionCount = overlayManager.currentRegionOverlayCount
let decayCount = overlayManager.decayOverlays.count
let totalOverlays = overlayManager.overlayCount

if totalOverlays > 50 {
    print("⚠️ WARNING: High overlay count! region=\(regionCount), decay=\(decayCount), total=\(totalOverlays)")
}
```

## Files Modified

1. `SuperDimmer-Mac-App/SuperDimmer/Overlay/OverlayManager.swift`
   - Added overlay cleanup logic
   - Added throttling to applyDecayDimming

2. `SuperDimmer-Mac-App/SuperDimmer/Services/ActiveUsageTracker.swift`
   - Added idle state debouncing
   - Added state change logging

3. `SuperDimmer-Mac-App/SuperDimmer/Services/AutoMinimizeManager.swift`
   - Added double-check before minimization

## Build Status

✅ **Build succeeded** - No compilation errors

The app is ready to test with these fixes applied.
