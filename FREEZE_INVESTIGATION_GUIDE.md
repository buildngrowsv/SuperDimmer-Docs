# SuperDimmer Freeze Investigation Guide

## Current Symptoms

Based on the logs you provided, the app is experiencing:

1. **Main thread blocking** - "Fetch Current User Activity" task is 17787ms past deadline
2. **Rapid idle/active cycling** - Toggling between idle and active states every few milliseconds
3. **Overlay accumulation** - Decay overlays growing to 14, 17+ without proper cleanup
4. **Repeated Chrome minimization** - AutoMinimizeManager minimizing same windows repeatedly
5. **Random overlays everywhere** - Visual indication of overlay management issues

## Root Causes Identified

### 1. **Idle Detection Loop** (CRITICAL)
The rapid idle/active cycling suggests `ActiveUsageTracker` is triggering repeatedly:

**Location**: `SuperDimmer-Mac-App/SuperDimmer/Services/ActiveUsageTracker.swift`

**Problem**: The event monitors (lines 139-152) are firing constantly, which triggers:
- `WindowInactivityTracker` pause/resume (lines 505-523)
- `AppInactivityTracker` pause/resume (lines 442-463)
- Both publish `@Published` properties that trigger SwiftUI updates
- This creates a feedback loop

**Evidence from logs**:
```
⏸️ WindowInactivityTracker: User idle - pausing decay timers
▶️ WindowInactivityTracker: User active - resuming decay timers (was idle for 0s)
⏸️ AppInactivityTracker: User idle - pausing auto-hide timers
▶️ AppInactivityTracker: User active - resuming auto-hide timers (was idle for 0s)
```

The "0s" idle time indicates this is happening in rapid succession, not real idle periods.

### 2. **Overlay Accumulation** (HIGH PRIORITY)
Decay overlays are being created but not properly cleaned up:

**Location**: `SuperDimmer-Mac-App/SuperDimmer/Overlay/OverlayManager.swift`

**Problem**: The `applyDecayDimming` method is creating new overlays without removing old ones:

**Evidence from logs**:
```
🔄 applyDecayDimming START [BG- (null)}] decisions=17
📦 Creating decay overlay: decay-117033
📦 Creating decay overlay: decay-2681
🔄 applyDecayDimming END - decayOverlays.count=14
... later ...
🔄 applyDecayDimming END - decayOverlays.count=17
```

The count keeps growing, indicating overlays aren't being removed when windows close or change.

### 3. **AutoMinimizeManager Loop** (HIGH PRIORITY)
Chrome windows are being minimized repeatedly:

**Location**: `SuperDimmer-Mac-App/SuperDimmer/Services/AutoMinimizeManager.swift`

**Problem**: Lines 93-101 show a fix was added for this exact issue, but it may not be working:

```swift
/// CRITICAL FIX (Jan 24, 2026): Track windows currently being minimized
/// to prevent infinite loop where same window gets minimized repeatedly
private var currentlyMinimizing = Set<CGWindowID>()
```

The fix exists, but the logs show it's still happening. This suggests:
- The `currentlyMinimizing` set isn't being cleared after minimization completes
- Or the window ID changes after minimization
- Or the check isn't being enforced

### 4. **Main Thread Blocking**
The "Fetch Current User Activity" deadline miss indicates the main thread is blocked.

**Likely cause**: One of these operations is running on the main thread:
- `applyDecayDimming` overlay creation (should be async)
- `ActiveUsageTracker` event processing
- `AutoMinimizeManager` AppleScript execution for minimization

## Investigation Steps

### Step 1: Check Activity Monitor
```bash
# Check CPU usage by thread
ps -M <PID> | head -20

# Check if main thread is at 100%
# If so, that confirms main thread blocking
```

### Step 2: Enable Debug Logging
The code has debug logging to `/tmp/superdimmer_debug.log`. Check this file:

```bash
tail -f /tmp/superdimmer_debug.log
```

Look for:
- Rapid "User idle/active" messages
- Overlay creation without corresponding removal
- Memory usage spikes

### Step 3: Check for Runaway Timers
Multiple timers are running:
- `DimmingCoordinator.analysisTimer` (every 2s)
- `DimmingCoordinator.windowTrackingTimer` (every 0.5s)
- `DimmingCoordinator.highFrequencyTrackingTimer` (every 33ms when active)
- `ActiveUsageTracker.idleCheckTimer` (every 1s)
- `AutoMinimizeManager.updateTimer` (every 10s)
- `AppInactivityTracker.accumulationTimer` (every 10s)

If any of these are firing too frequently or not being invalidated, they could cause the freeze.

### Step 4: Check Overlay Count
Add this to the debug output:

```swift
// In DimmingCoordinator.performAnalysisCycle()
print("📊 Overlay counts: region=\(overlayManager.currentRegionOverlayCount), decay=\(overlayManager.decayOverlays.count), full=\(overlayManager.overlayCount)")
```

This will show if overlays are accumulating.

### Step 5: Check for Deadlocks
The code uses multiple locks:
- `ScreenCaptureService.throttleLock` (line 90)
- `WindowInactivityTracker.lock` (line 88)
- `AppInactivityTracker.lock` (line 83)
- `AutoMinimizeManager.lock` (line 122)
- `ActiveUsageTracker.lock` (line 83)

If two threads try to acquire locks in different orders, you get a deadlock.

## Immediate Fixes to Try

### Fix 1: Disable Idle Tracking Temporarily
Comment out the idle tracking setup to see if that's the cause:

**File**: `WindowInactivityTracker.swift` line 132
```swift
// setupIdleTracking()  // TEMPORARILY DISABLED FOR TESTING
```

**File**: `AppInactivityTracker.swift` line 144
```swift
// setupIdleTracking()  // TEMPORARILY DISABLED FOR TESTING
```

Rebuild and test. If the freeze stops, you've found the culprit.

### Fix 2: Add Throttling to Idle State Changes
The idle/active state is changing too rapidly. Add debouncing:

**File**: `ActiveUsageTracker.swift` after line 90
```swift
/// Minimum time between state changes (prevent rapid toggling)
private let minStateChangeInterval: TimeInterval = 2.0
private var lastStateChangeTime: Date = Date()
```

**File**: `ActiveUsageTracker.swift` in `updateIdleState()` around line 230
```swift
// Only update if enough time has passed since last change
let now = Date()
if now.timeIntervalSince(lastStateChangeTime) < minStateChangeInterval {
    return
}
lastStateChangeTime = now
```

### Fix 3: Fix Overlay Cleanup
Ensure overlays are removed when windows close:

**File**: `OverlayManager.swift` in `applyDecayDimming`
Add cleanup at the start:
```swift
// Remove overlays for windows that no longer exist
let currentWindowIDs = Set(decisions.map { $0.windowID })
let staleOverlays = decayOverlays.keys.filter { !currentWindowIDs.contains($0) }
for staleID in staleOverlays {
    if let overlay = decayOverlays.removeValue(forKey: staleID) {
        overlay.close()
    }
}
```

### Fix 4: Fix AutoMinimizeManager Loop
Ensure the `currentlyMinimizing` check is actually enforced:

**File**: `AutoMinimizeManager.swift` in the minimize function
Before minimizing, check:
```swift
guard !currentlyMinimizing.contains(windowID) else {
    print("⚠️ Window \(windowID) already being minimized, skipping")
    return
}
currentlyMinimizing.insert(windowID)
```

After minimization completes:
```swift
DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
    self?.currentlyMinimizing.remove(windowID)
}
```

## Quick Emergency Stop

If the app is frozen and you need to stop it immediately:

```bash
# Force quit
killall SuperDimmer

# Or get PID and kill
ps aux | grep SuperDimmer
kill -9 <PID>
```

## Testing After Fixes

1. **Monitor logs**: `tail -f /tmp/superdimmer_debug.log`
2. **Check Activity Monitor**: CPU should be < 10% when idle
3. **Watch for rapid state changes**: Should not see idle/active cycling
4. **Count overlays**: Should match number of visible windows
5. **Test Chrome**: Open multiple Chrome windows, wait, verify they don't get minimized repeatedly

## Files to Read for Full Context

1. `SuperDimmer-Mac-App/SuperDimmer/Services/ActiveUsageTracker.swift` - Idle detection
2. `SuperDimmer-Mac-App/SuperDimmer/Services/WindowInactivityTracker.swift` - Decay timer management
3. `SuperDimmer-Mac-App/SuperDimmer/Services/AppInactivityTracker.swift` - Auto-hide timer management
4. `SuperDimmer-Mac-App/SuperDimmer/Services/AutoMinimizeManager.swift` - Window minimization
5. `SuperDimmer-Mac-App/SuperDimmer/Overlay/OverlayManager.swift` - Overlay lifecycle
6. `SuperDimmer-Mac-App/SuperDimmer/DimmingCoordinator/DimmingCoordinator.swift` - Main coordinator

## Next Steps

1. Try Fix 1 first (disable idle tracking) to isolate the issue
2. If that fixes it, implement Fix 2 (throttling)
3. Implement Fix 3 (overlay cleanup) regardless
4. Check if Fix 4 (AutoMinimizeManager) is needed based on logs
5. Run the app and monitor for 5-10 minutes
6. Check memory usage in Activity Monitor
7. Verify no rapid state changes in logs

## Expected Behavior After Fixes

- CPU usage < 10% when idle
- No rapid idle/active cycling in logs
- Overlay count matches visible window count
- No repeated minimization of same windows
- Main thread responsive (no deadline misses)
- Memory stable around 150-200 MB
