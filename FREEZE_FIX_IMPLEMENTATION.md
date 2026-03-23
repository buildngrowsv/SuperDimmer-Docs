# SuperDimmer Freeze Fix Implementation

## Root Causes Confirmed

After analyzing the code, I've identified the exact causes of the freeze:

### 1. **Overlay Accumulation** (PRIMARY CAUSE)
**File**: `OverlayManager.swift` lines 929-932

The code explicitly states:
```swift
// CRITICAL: DO NOT destroy stale overlays!
// Let them live with dimLevel=0. The memory cost is minimal
```

**Problem**: This assumption is WRONG. The logs show:
- `decayOverlays.count=14`
- `decayOverlays.count=17`
- Growing without bound

With rapid idle/active cycling creating new overlays constantly, this accumulates hundreds of hidden overlays, each consuming memory and requiring window server updates.

### 2. **Rapid Idle/Active Cycling** (SECONDARY CAUSE)
**File**: `ActiveUsageTracker.swift` lines 139-152

The event monitors fire on EVERY mouse movement and keystroke, triggering:
- `WindowInactivityTracker` to publish `@Published` property changes
- `AppInactivityTracker` to publish `@Published` property changes  
- SwiftUI to update views
- This happens dozens of times per second

The logs show:
```
⏸️ WindowInactivityTracker: User idle - pausing decay timers
▶️ WindowInactivityTracker: User active - resuming decay timers (was idle for 0s)
```

The "0s" indicates this is happening in rapid succession, not real idle periods.

### 3. **AutoMinimizeManager Loop** (TERTIARY CAUSE)
**File**: `AutoMinimizeManager.swift` lines 93-101

The fix exists but may not be working correctly:
```swift
private var currentlyMinimizing = Set<CGWindowID>()
```

The logs show Chrome windows being minimized repeatedly, suggesting:
- The set isn't being cleared after minimization completes
- Or the check isn't being enforced before minimization

## Comprehensive Fix

### Fix 1: Add Decay Overlay Cleanup (CRITICAL)

**File**: `OverlayManager.swift` in `applyDecayDimming()` after line 881

Replace the comment on lines 929-932 with actual cleanup:

```swift
// CLEANUP: Remove overlays for windows that no longer exist
// Build set of current window IDs from decisions
let currentWindowIDs = Set(decisions.map { $0.windowID })

// Find stale overlays (windows that closed or are no longer tracked)
let staleOverlayIDs = Set(self.decayOverlays.keys).subtracting(currentWindowIDs)

// Remove stale overlays
for staleID in staleOverlayIDs {
    if let staleOverlay = self.decayOverlays.removeValue(forKey: staleID) {
        print("🗑️ Removing stale decay overlay for window \(staleID)")
        self.safeHideOverlay(staleOverlay)
    }
}
```

**Why this works**:
- Only keeps overlays for windows that exist in current decisions
- Uses existing `safeHideOverlay()` method which properly cleans up
- Prevents accumulation while maintaining stability

### Fix 2: Add Debouncing to Idle State Changes (HIGH PRIORITY)

**File**: `ActiveUsageTracker.swift` after line 90

Add new properties:
```swift
/// Minimum time between state changes (prevent rapid toggling)
private let minStateChangeInterval: TimeInterval = 2.0
private var lastStateChangeTime: Date = Date()
private var lastPublishedState: Bool = true
```

**File**: `ActiveUsageTracker.swift` in `updateIdleState()` replace lines 226-236 with:

```swift
// Update published properties on main thread
DispatchQueue.main.async { [weak self] in
    guard let self = self else { return }
    
    self.idleTime = timeSinceActivity
    let newActiveState = timeSinceActivity < self.activeThreshold
    
    // DEBOUNCE: Only publish state change if enough time has passed
    // AND the state actually changed
    let now = Date()
    if newActiveState != self.lastPublishedState &&
       now.timeIntervalSince(self.lastStateChangeTime) >= self.minStateChangeInterval {
        self.isUserActive = newActiveState
        self.lastPublishedState = newActiveState
        self.lastStateChangeTime = now
        
        // Track idle state for detecting returns
        self.lock.lock()
        self.wasIdle = !self.isUserActive
        self.lock.unlock()
    }
}
```

**Why this works**:
- Prevents publishing state changes more than once per 2 seconds
- Eliminates the rapid idle/active cycling
- Still tracks idle time for extended idle detection
- Only publishes when state ACTUALLY changes

### Fix 3: Enforce AutoMinimizeManager Check (MEDIUM PRIORITY)

**File**: `AutoMinimizeManager.swift` 

Find the function that actually minimizes windows (search for "📥 AutoMinimizeManager: Minimized").

Before the minimization code, add:

```swift
// CRITICAL: Check if already minimizing
guard !currentlyMinimizing.contains(windowID) else {
    print("⚠️ Window \(windowID) already being minimized, skipping")
    continue  // or return, depending on context
}

// Mark as being minimized
currentlyMinimizing.insert(windowID)
```

After the minimization completes (or in a completion handler):

```swift
// Clear the flag after 2 seconds (enough time for AppleScript to complete)
DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
    self?.lock.lock()
    self?.currentlyMinimizing.remove(windowID)
    self?.lock.unlock()
}
```

### Fix 4: Add Safety Check to applyDecayDimming (LOW PRIORITY)

**File**: `OverlayManager.swift` in `applyDecayDimming()` at line 855

Add throttling to prevent too-frequent calls:

```swift
// THROTTLE: Prevent too-frequent calls
private var lastDecayApplyTime: CFAbsoluteTime = 0
private let minDecayApplyInterval: CFAbsoluteTime = 0.5  // 500ms minimum

func applyDecayDimming(_ decisions: [DecayDimmingDecision]) {
    // Check throttle
    let now = CFAbsoluteTimeGetCurrent()
    guard now - lastDecayApplyTime >= minDecayApplyInterval else {
        print("⏭️ applyDecayDimming: Throttled (too soon since last call)")
        return
    }
    lastDecayApplyTime = now
    
    // ... rest of function
}
```

## Implementation Order

1. **Fix 1 (Overlay Cleanup)** - Do this FIRST, it's the primary cause
2. **Fix 2 (Idle Debouncing)** - Do this SECOND, it's the secondary cause  
3. **Fix 3 (AutoMinimize Check)** - Do this THIRD, it's causing user-visible issues
4. **Fix 4 (Throttling)** - Do this LAST, it's a safety net

## Testing After Each Fix

### After Fix 1:
```bash
# Monitor overlay count
tail -f /tmp/superdimmer_debug.log | grep "decayOverlays.count"

# Should see count stay stable or decrease, not constantly increase
```

### After Fix 2:
```bash
# Monitor idle state changes
tail -f /tmp/superdimmer_debug.log | grep "User idle\|User active"

# Should see changes every 2+ seconds, not constantly
```

### After Fix 3:
```bash
# Monitor Chrome minimization
tail -f /tmp/superdimmer_debug.log | grep "AutoMinimizeManager"

# Should see each window minimized once, not repeatedly
```

### After Fix 4:
```bash
# Monitor applyDecayDimming calls
tail -f /tmp/superdimmer_debug.log | grep "applyDecayDimming"

# Should see calls at least 500ms apart
```

## Expected Results

After all fixes:
- ✅ Overlay count stays stable (matches number of windows)
- ✅ No rapid idle/active cycling in logs
- ✅ CPU usage < 10% when idle
- ✅ No repeated window minimization
- ✅ No "Fetch Current User Activity" deadline misses
- ✅ Memory stable around 150-200 MB
- ✅ App remains responsive

## Rollback Plan

If any fix causes issues:

1. Comment out the fix
2. Rebuild and test
3. Document the issue
4. Try alternative approach

The fixes are independent, so you can apply them one at a time and roll back individually if needed.

## Additional Monitoring

Add this to `DimmingCoordinator.performAnalysisCycle()` around line 600:

```swift
// Monitor overlay health
let regionCount = overlayManager.currentRegionOverlayCount
let decayCount = overlayManager.decayOverlays.count
let totalOverlays = overlayManager.overlayCount

if totalOverlays > 50 {
    print("⚠️ WARNING: High overlay count! region=\(regionCount), decay=\(decayCount), total=\(totalOverlays)")
}
```

This will alert you if overlays start accumulating again.
