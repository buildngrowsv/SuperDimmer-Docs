# DEADLOCK FIX: AccessibilityFocusObserver

## 🔴 CRITICAL BUG FOUND

**Date:** January 26, 2026  
**Status:** CONFIRMED via spindump/sample analysis  
**Severity:** CRITICAL - Causes app freeze  

---

## 📊 Diagnostic Evidence

### Sample Output:
```
8672 Thread_87423303   DispatchQueue_1: com.apple.main-thread  (serial)
  closure #3 in AccessibilityFocusObserver.setupAppTrackingNotifications()  (line 268)
    → AccessibilityFocusObserver.addObserverForApp(pid:)  (line 309)
      → _pthread_mutex_firstfit_lock_wait  (BLOCKED)
        → __psynch_mutexwait
```

**Translation:** Main thread is BLOCKED waiting for a mutex (lock) that it already holds.

---

## 🐛 The Bug

**File:** `AccessibilityFocusObserver.swift`  
**Lines:** 266-270 (caller) and 309-311 (callee)

### Current Code (BUGGY):

**Caller (lines 266-270):**
```swift
self.observerLock.lock()  // ← ACQUIRES LOCK
if self.shouldTrackApp(app) && !self.trackedPIDs.contains(app.processIdentifier) {
    self.addObserverForApp(pid: app.processIdentifier)  // ← CALLS METHOD WHILE HOLDING LOCK
}
self.observerLock.unlock()
```

**Callee (lines 309-311):**
```swift
private func addObserverForApp(pid: pid_t) {
    // Check if already tracked (with lock)
    observerLock.lock()  // ← TRIES TO ACQUIRE SAME LOCK AGAIN = DEADLOCK!
    let alreadyTracked = trackedPIDs.contains(pid)
    observerLock.unlock()
    
    guard !alreadyTracked else { return }
    // ...
}
```

### Why This Deadlocks:

1. Main thread acquires `observerLock` at line 266
2. While holding the lock, calls `addObserverForApp` at line 268
3. `addObserverForApp` tries to acquire `observerLock` at line 309
4. **DEADLOCK:** Main thread is waiting for a lock it already holds
5. App freezes completely

**Note:** `NSLock` is NOT recursive - it cannot be locked twice by the same thread.

---

## ✅ The Fix

### Option 1: Use NSRecursiveLock (RECOMMENDED)

Change the lock type to allow recursive locking:

**Line ~88:**
```swift
// OLD:
private let observerLock = NSLock()

// NEW:
private let observerLock = NSRecursiveLock()
```

**Why this works:**
- `NSRecursiveLock` allows the same thread to acquire the lock multiple times
- Each `lock()` must be matched with an `unlock()`
- Simple one-line fix
- No logic changes needed

### Option 2: Remove Redundant Lock in Caller (ALTERNATIVE)

Check the PID without holding the lock in the caller:

**Lines 266-270:**
```swift
// OLD:
self.observerLock.lock()
if self.shouldTrackApp(app) && !self.trackedPIDs.contains(app.processIdentifier) {
    self.addObserverForApp(pid: app.processIdentifier)
}
self.observerLock.unlock()

// NEW:
if self.shouldTrackApp(app) {
    // addObserverForApp handles its own locking
    self.addObserverForApp(pid: app.processIdentifier)
}
```

**Why this works:**
- `addObserverForApp` already checks if PID is tracked (with its own lock)
- No need to check in the caller
- Removes the outer lock acquisition
- Prevents deadlock

**Trade-off:** Small race condition window where two threads could both call `addObserverForApp` for the same PID, but `addObserverForApp` handles this with its own check.

### Option 3: Extract Check to Separate Method (SAFEST)

Create a lock-free check method:

**Add new method:**
```swift
private func isAlreadyTracked(_ pid: pid_t) -> Bool {
    observerLock.lock()
    defer { observerLock.unlock() }
    return trackedPIDs.contains(pid)
}
```

**Update caller (lines 266-270):**
```swift
if self.shouldTrackApp(app) && !self.isAlreadyTracked(app.processIdentifier) {
    self.addObserverForApp(pid: app.processIdentifier)
}
```

**Update callee (lines 309-311):**
```swift
private func addObserverForApp(pid: pid_t) {
    // Check if already tracked (using helper method)
    guard !isAlreadyTracked(pid) else { return }
    
    // ... rest of method (no lock acquisition here)
}
```

**Why this works:**
- Separates the check from the add operation
- Each method acquires lock independently
- No nested locking
- Clear separation of concerns

---

## 🎯 Recommended Fix: Option 1 (NSRecursiveLock)

**Reason:** Simplest, safest, one-line change.

### Implementation:

**File:** `AccessibilityFocusObserver.swift`  
**Line:** ~88

```swift
// DEADLOCK FIX (Jan 26, 2026):
// Changed from NSLock to NSRecursiveLock to allow same thread to acquire lock multiple times.
// This fixes deadlock when setupAppTrackingNotifications() calls addObserverForApp()
// while holding the lock.
//
// Root cause: Main thread acquired observerLock at line 266, then called addObserverForApp()
// at line 268 which tried to acquire the same lock at line 309, causing deadlock.
//
// NSRecursiveLock allows recursive locking by the same thread, preventing this issue.
private let observerLock = NSRecursiveLock()
```

---

## 🧪 Testing the Fix

### Before Fix:
```bash
# Run app
# Wait for app activation notification
# → App freezes immediately
# → CPU at 0%
# → Main thread blocked in mutex_wait
```

### After Fix:
```bash
# Run app
# Wait for app activation notification
# → App continues running
# → CPU normal
# → No freeze
```

### Verification:
1. Run app with fix applied
2. Switch between applications multiple times
3. Open new applications
4. Monitor with `./debug-freeze.sh --monitor`
5. Should see no freeze alerts
6. Check logs for "Added AX observer for PID" messages

---

## 📝 Why This Wasn't Caught Earlier

1. **Timing-dependent:** Only happens when app activation notification fires
2. **Race condition:** Depends on notification timing
3. **No error message:** Deadlocks are silent - no crash, no error
4. **Thread sanitizer might not catch:** Recursive locking isn't always flagged
5. **Requires specific scenario:** App must receive activation notification

---

## 🔍 How We Found It

1. User reported freeze with no errors
2. Ran `./debug-freeze.sh` to capture diagnostics
3. Analyzed `sample.txt` output
4. Found main thread blocked in `_pthread_mutex_firstfit_lock_wait`
5. Traced stack to `AccessibilityFocusObserver.addObserverForApp`
6. Reviewed code and found nested lock acquisition
7. Confirmed deadlock pattern

**This is exactly why spindump/sample analysis is essential for freeze debugging!**

---

## ✅ Action Items

- [ ] Apply fix (change NSLock to NSRecursiveLock)
- [ ] Build and test
- [ ] Verify no freeze when switching apps
- [ ] Monitor for 30 minutes with `--monitor`
- [ ] Add test case for app activation
- [ ] Consider adding lock acquisition logging (debug builds)
- [ ] Document in code comments
- [ ] Update TROUBLESHOOTING_LOG.md

---

## 🎓 Lessons Learned

1. **Always use recursive locks** when methods call each other while holding locks
2. **Spindump is invaluable** for finding deadlocks
3. **Deadlocks are silent** - no errors, just freeze
4. **Lock ordering matters** - document lock acquisition patterns
5. **Test notification handlers** - they run on main thread and can cause issues

---

## 📚 Related Documentation

- `ADVANCED_FREEZE_DEBUGGING_GUIDE.md` - How we diagnosed this
- `FREEZE_DEBUG_QUICK_START.md` - Quick reference
- `MACOS_CRASH_DEBUGGING_BEST_PRACTICES.md` - Lock best practices

---

*Created: January 26, 2026*  
*Bug found via: spindump/sample analysis*  
*Fix verified: Pending*
