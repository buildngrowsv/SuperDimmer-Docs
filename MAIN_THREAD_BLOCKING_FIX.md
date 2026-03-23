# MAIN THREAD BLOCKING FIX: AutoMinimizeManager

## 🔴 CRITICAL BUG FOUND

**Date:** January 26, 2026  
**Status:** CONFIRMED via sample analysis  
**Severity:** HIGH - Causes UI unresponsiveness  

---

## 📊 Diagnostic Evidence

### Sample Output:
```
Main thread (2647 samples = 100% of time):
  AutoMinimizeManager.updateAndCheck() (line 242)
    → AutoMinimizeManager.checkAndMinimizeWindows() (line 399)
      → AutoMinimizeManager.minimizeWindow(windowID:appName:) (line 466)
        → NSAppleScript.executeAndReturnError
          → mach_msg2_trap (WAITING for IPC response)
```

**Translation:** Main thread is blocked waiting for AppleScript to complete, making UI unresponsive.

---

## 🐛 The Bug

**File:** `AutoMinimizeManager.swift`  
**Lines:** 176-177, 399, 466

### Current Code (BUGGY):

**Timer (line 176-177):**
```swift
updateTimer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] _ in
    self?.updateAndCheck()  // ← Runs on MAIN THREAD
}
```

**Minimize call (line 399):**
```swift
minimizeWindow(windowID: window.id, appName: window.info.ownerName)  // ← Called on MAIN THREAD
```

**AppleScript execution (line 466):**
```swift
let result = scriptObject.executeAndReturnError(&error)  // ← BLOCKS main thread
```

### Why This Causes Unresponsiveness:

1. Timer fires on main thread every 10 seconds
2. Calls `updateAndCheck()` on main thread
3. Calls `checkAndMinimizeWindows()` on main thread
4. Calls `minimizeWindow()` on main thread
5. **Executes AppleScript synchronously** on main thread
6. AppleScript sends IPC message to target app
7. **Waits for response** (can take 1-5 seconds)
8. **Main thread blocked** → UI frozen
9. User clicks are queued but not processed
10. Eventually completes, processes queued clicks
11. **Result:** App feels unresponsive, delayed reactions

**Symptoms:**
- UI doesn't respond immediately
- Clicks are delayed/queued
- No spinning wheel (not a full hang, just slow)
- Eventually processes actions
- Happens every 10 seconds

---

## ✅ The Fix

### Move AppleScript Execution to Background Thread

**File:** `AutoMinimizeManager.swift`  
**Line:** 399-401

**Change:**
```swift
// OLD (BUGGY):
if !alreadyMinimizing {
    minimizeWindow(windowID: window.id, appName: window.info.ownerName)
    minimizedCount += 1
}

// NEW (FIXED):
if !alreadyMinimizing {
    // Execute AppleScript on background thread to avoid blocking main thread
    // AppleScript can take 1-5 seconds to complete, which would freeze UI
    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
        self?.minimizeWindow(windowID: window.id, appName: window.info.ownerName)
    }
    minimizedCount += 1
}
```

**Why this works:**
- AppleScript executes on background thread
- Main thread remains responsive
- UI continues to work normally
- No delay in user interactions
- AppleScript still completes successfully

**Trade-off:**
- `minimizedCount` might not be accurate immediately (incremented before actual minimization)
- But this is just for logging, not critical

---

## 🎯 Alternative Fix: Move Entire Timer to Background

**File:** `AutoMinimizeManager.swift`  
**Line:** 176-178

**Change:**
```swift
// OLD:
updateTimer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] _ in
    self?.updateAndCheck()
}

// NEW:
// Create timer on background queue to avoid blocking main thread
let queue = DispatchQueue(label: "com.superdimmer.autominimize", qos: .utility)
updateTimer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] _ in
    queue.async {
        self?.updateAndCheck()
    }
}
```

**Why this works:**
- Entire update/check cycle runs on background thread
- Main thread never touched by AutoMinimizeManager
- More comprehensive fix

**Trade-off:**
- Need to ensure thread-safety in all methods
- Lock usage becomes more critical

---

## 🎯 Recommended Fix: Hybrid Approach

Move just the AppleScript execution to background, keep the rest on main thread for simplicity.

### Implementation:

**File:** `AutoMinimizeManager.swift`  
**Line:** 395-402

```swift
// MAIN THREAD BLOCKING FIX (Jan 26, 2026):
// Execute AppleScript on background thread to avoid blocking main thread.
// AppleScript can take 1-5 seconds to complete, which would freeze UI.
//
// Root cause: Timer runs on main thread, calls minimizeWindow() which executes
// AppleScript synchronously, blocking main thread while waiting for IPC response.
//
// Found via sample analysis showing main thread blocked in mach_msg2_trap
// while executing NSAppleScript.executeAndReturnError.
lock.lock()
let alreadyMinimizing = currentlyMinimizing.contains(window.id)
lock.unlock()

if !alreadyMinimizing {
    // Execute on background thread to keep UI responsive
    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
        self?.minimizeWindow(windowID: window.id, appName: window.info.ownerName)
    }
    minimizedCount += 1
}
```

---

## 🧪 Testing the Fix

### Before Fix:
```bash
# Run app
# Wait for timer to fire (every 10 seconds)
# Try to click UI elements
# → Delayed response (1-5 seconds)
# → Clicks queued and processed later
# → Feels frozen but no spinning wheel
```

### After Fix:
```bash
# Run app
# Wait for timer to fire (every 10 seconds)
# Try to click UI elements
# → Immediate response
# → No delay
# → UI remains responsive
```

### Verification:
1. Run app with fix applied
2. Monitor with Activity Monitor
3. Watch CPU usage when timer fires
4. Click UI elements immediately after timer fires
5. Should respond instantly (no delay)
6. Check Console logs for "Minimized window" messages
7. Verify windows are still being minimized

---

## 📝 Why This Wasn't Caught Earlier

1. **Timing-dependent:** Only noticeable when timer fires
2. **Not a full hang:** UI eventually responds, just delayed
3. **No error message:** AppleScript completes successfully
4. **Intermittent:** Only happens every 10 seconds
5. **Subtle:** Users might not notice 1-2 second delays

---

## 🔍 How We Found It

1. User reported unresponsiveness (not full freeze)
2. Captured sample while unresponsive
3. Analyzed sample output
4. Found main thread blocked in AppleScript execution
5. Traced to `AutoMinimizeManager.minimizeWindow()`
6. Identified synchronous AppleScript on main thread

**Sample analysis was key - showed exactly where main thread was blocked!**

---

## ✅ Action Items

- [ ] Apply fix (move AppleScript to background thread)
- [ ] Build and test
- [ ] Verify UI remains responsive during timer
- [ ] Monitor for 30 minutes
- [ ] Check that windows are still minimized correctly
- [ ] Add logging for AppleScript timing
- [ ] Document in code comments
- [ ] Update TROUBLESHOOTING_LOG.md

---

## 🎓 Lessons Learned

1. **Never block main thread** with synchronous operations
2. **AppleScript is slow** - always run on background thread
3. **Sample analysis reveals blocking** even without full hang
4. **Timers run on main thread** by default
5. **IPC operations can take seconds** - treat as async

---

## 📚 Related Documentation

- `ADVANCED_FREEZE_DEBUGGING_GUIDE.md` - Debugging techniques
- `DEADLOCK_FIX_ACCESSIBILITYFOCUSOBSERVER.md` - Previous fix
- `MACOS_CRASH_DEBUGGING_BEST_PRACTICES.md` - Best practices

---

## 🔗 Related Issues

This is different from the previous deadlock:
- **Deadlock:** Thread waiting for lock it already holds
- **This issue:** Thread blocked waiting for IPC response

Both cause unresponsiveness, but for different reasons.

---

*Created: January 26, 2026*  
*Bug found via: sample analysis*  
*Fix verified: Pending*
