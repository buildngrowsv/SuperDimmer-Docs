# NOTIFICATION STORM FIX: Multiple SpaceChangeMonitor Instances

## 🔴 CRITICAL BUG FOUND

**Date:** January 26, 2026  
**Status:** CONFIRMED via logs and code analysis  
**Severity:** CRITICAL - Causes CPU spike, input lag, keyboard hang  

---

## 📊 Diagnostic Evidence

### User Logs Show:
```
✓ SpaceChangeMonitor: Space changed: 5 -> 6  (×6 times!)
✓ SpaceVisitTracker: Recorded visit to Space 6  (×6 times!)
✓ SpaceChangeMonitor: Space changed: 6 -> 5  (×7 times!)
✓ SpaceVisitTracker: Recorded visit to Space 5  (×6 times!)
```

### CPU Status:
```
PID: 36082
CPU: 55.5%  (should be < 5%)
State: RX (running, high priority)
```

### Symptoms:
- Keyboard appears to hang/stuck
- Alt key seems held down
- UI unresponsive during space change
- High CPU usage
- Repeated log messages

---

## 🐛 The Bug

**Root Cause:** **THREE separate instances** of `SpaceChangeMonitor` are created, each registering for the same notification.

### Instances Found:

**1. DimmingCoordinator.swift (line 1350):**
```swift
spaceMonitor = SpaceChangeMonitor()
spaceMonitor?.startMonitoring { [weak self] newSpaceNumber in
    // Notify WindowInactivityTracker of space change
    ...
}
```

**2. AppInactivityTracker.swift (line 567):**
```swift
let spaceMonitor = SpaceChangeMonitor()
spaceMonitor.startMonitoring { [weak self] newSpaceNumber in
    // Handle space change
    ...
}
```

**3. SuperSpacesHUD.swift (line 720):**
```swift
spaceMonitor = SpaceChangeMonitor()
spaceMonitor?.startMonitoring { [weak self] spaceNumber in
    self?.handleSpaceChange(spaceNumber)
}
```

### Why This Causes Problems:

1. **Single notification** → **3 observers** registered
2. Space changes from 5 → 6
3. `NSWorkspace.activeSpaceDidChangeNotification` fires **once**
4. **All 3 monitors** receive the notification
5. Each monitor:
   - Prints "Space changed"
   - Calls its callback
   - Triggers downstream work (overlay updates, timer changes, HUD updates)
6. **Result:** 3x the work for every space change
7. If callbacks trigger more notifications → **cascade effect**
8. CPU spikes to 55%
9. Event queue backs up → keyboard/input lag

### Additional Problem:

Each monitor also has a **polling timer** (0.5s interval), so you have:
- 3 notification observers
- 3 polling timers
- All checking the same thing
- All firing callbacks

---

## ✅ The Fix

### Option 1: Singleton Pattern (RECOMMENDED)

Make `SpaceChangeMonitor` a singleton so only ONE instance exists.

**File:** `SpaceChangeMonitor.swift`

**Add after line 48:**
```swift
final class SpaceChangeMonitor {
    
    // MARK: - Singleton
    
    /// Shared instance (SINGLETON FIX - Jan 26, 2026)
    /// Multiple instances were causing notification storms.
    /// Now only one monitor exists, with multiple callbacks.
    static let shared = SpaceChangeMonitor()
    
    // Make init private to enforce singleton
    private init() {}
    
    // MARK: - Properties
    
    /// Callbacks invoked when Space changes
    /// Changed from single callback to array to support multiple observers
    private var spaceChangeCallbacks: [(Int) -> Void] = []
```

**Update startMonitoring (line 101):**
```swift
/// Registers a callback for Space changes
/// Multiple callbacks can be registered
func addObserver(_ callback: @escaping (Int) -> Void) {
    spaceChangeCallbacks.append(callback)
    
    // Start monitoring if not already started
    if !isMonitoring {
        startMonitoringInternal()
    }
}

private func startMonitoringInternal() {
    guard !isMonitoring else { return }
    
    self.isMonitoring = true
    
    // Get initial Space
    if let currentSpace = SpaceDetector.getCurrentSpace() {
        lastKnownSpace = currentSpace.spaceNumber
        print("✓ SpaceChangeMonitor: Initial Space: \(currentSpace.spaceNumber)")
    }
    
    // Register for NSWorkspace Space change notifications
    NSWorkspace.shared.notificationCenter.addObserver(
        self,
        selector: #selector(handleWorkspaceSpaceChange),
        name: NSWorkspace.activeSpaceDidChangeNotification,
        object: nil
    )
    
    // Start polling timer as fallback
    DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }
        
        self.pollingTimer = Timer.scheduledTimer(
            withTimeInterval: 0.5,
            repeats: true
        ) { [weak self] _ in
            self?.checkForSpaceChange()
        }
        
        if let timer = self.pollingTimer {
            RunLoop.main.add(timer, forMode: .common)
            print("✓ SpaceChangeMonitor: Polling timer scheduled")
        }
    }
    
    print("✓ SpaceChangeMonitor: Started monitoring")
}
```

**Update notifyObservers (around line 240):**
```swift
private func notifyObservers(newSpace: Int) {
    // Call all registered callbacks
    for callback in spaceChangeCallbacks {
        callback(newSpace)
    }
}
```

**Update all call sites:**

**DimmingCoordinator.swift (line 1350):**
```swift
// OLD:
spaceMonitor = SpaceChangeMonitor()
spaceMonitor?.startMonitoring { [weak self] newSpaceNumber in

// NEW:
SpaceChangeMonitor.shared.addObserver { [weak self] newSpaceNumber in
```

**AppInactivityTracker.swift (line 567):**
```swift
// OLD:
let spaceMonitor = SpaceChangeMonitor()
spaceMonitor.startMonitoring { [weak self] newSpaceNumber in

// NEW:
SpaceChangeMonitor.shared.addObserver { [weak self] newSpaceNumber in
```

**SuperSpacesHUD.swift (line 720):**
```swift
// OLD:
spaceMonitor = SpaceChangeMonitor()
spaceMonitor?.startMonitoring { [weak self] spaceNumber in

// NEW:
SpaceChangeMonitor.shared.addObserver { [weak self] spaceNumber in
```

---

### Option 2: Remove Duplicate Monitors (SIMPLER)

Only keep ONE monitor and have it notify all interested parties.

**Keep only:** DimmingCoordinator's monitor  
**Remove:** AppInactivityTracker and SuperSpacesHUD monitors  
**Instead:** Have DimmingCoordinator notify them via NotificationCenter

---

## 🎯 Recommended Fix: Option 1 (Singleton)

**Why:**
- Clean architecture
- Each component can still register independently
- Only one actual monitor running
- No notification storms
- Easy to add more observers later

**Implementation Steps:**
1. Modify `SpaceChangeMonitor` to be singleton
2. Change `startMonitoring` to `addObserver`
3. Support multiple callbacks
4. Update all 3 call sites
5. Test space changes

---

## 🧪 Testing the Fix

### Before Fix:
```bash
# Switch spaces
# → 3-6 log messages per change
# → CPU spikes to 55%
# → Keyboard lag
# → Input feels stuck
```

### After Fix:
```bash
# Switch spaces
# → 1 log message per change
# → CPU stays < 5%
# → No keyboard lag
# → Smooth operation
```

### Verification:
1. Run app with fix
2. Switch between spaces multiple times
3. Check logs - should see ONE message per change
4. Monitor CPU - should stay low
5. Test keyboard - should be responsive
6. No input lag

---

## 📝 Why This Wasn't Caught Earlier

1. **Gradual addition:** Monitors added over time to different components
2. **Works individually:** Each monitor works fine alone
3. **Subtle interaction:** Problem only visible when all running together
4. **No error message:** Just performance degradation
5. **Intermittent:** Only happens during space changes

---

## 🔍 How We Found It

1. User reported keyboard hang during space change
2. Checked logs - saw repeated messages
3. Counted occurrences - 6-7 times per change
4. Searched codebase for `SpaceChangeMonitor()`
5. Found 3 separate instances
6. Confirmed each registers for same notification

---

## ✅ Action Items

- [ ] Apply singleton pattern to SpaceChangeMonitor
- [ ] Update all 3 call sites
- [ ] Build and test
- [ ] Switch spaces multiple times
- [ ] Verify only 1 log message per change
- [ ] Monitor CPU usage
- [ ] Test keyboard responsiveness
- [ ] Document in code comments

---

## 🎓 Lessons Learned

1. **Singletons for system observers** - Only one should listen to system notifications
2. **Check for duplicate observers** - Multiple observers = multiple callbacks
3. **Log analysis reveals patterns** - Repeated messages indicate problem
4. **CPU spikes during events** - Sign of runaway loop
5. **Input lag = event queue backup** - Too much work on main thread

---

## 📚 Related Documentation

- `DEADLOCK_FIX_ACCESSIBILITYFOCUSOBSERVER.md` - Lock issues
- `MAIN_THREAD_BLOCKING_FIX.md` - AppleScript blocking
- `TWO_BUGS_FIXED_SUMMARY.md` - Previous fixes

---

## 🔗 Related Issues

This is the **third performance bug** found today:
1. **Deadlock:** Recursive lock acquisition
2. **Blocking:** Synchronous AppleScript on main thread
3. **Notification storm:** Multiple observers for same notification

All found using the same debugging tools! 🎯

---

*Created: January 26, 2026*  
*Bug found via: Log analysis + code search*  
*Fix verified: Pending*
