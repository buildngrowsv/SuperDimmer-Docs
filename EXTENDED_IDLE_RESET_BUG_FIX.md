# Extended Idle Reset Bug Fix
## SuperDimmer - January 24, 2026

---

## 🐛 The Bug

**Symptom:** After returning from extended idle (5+ minutes), apps were immediately hidden and windows minimized, causing the app to freeze/hang with repeated hide/minimize actions.

**User Experience:** User steps away for lunch, comes back, and the app goes crazy hiding apps and minimizing windows in a loop.

---

## 🔍 Root Cause

### The Logs Revealed

```
▶️ AppInactivityTracker: User active - resuming auto-hide timers (was idle for 251s)
🙈 AutoHideManager: Hid 1 inactive app(s)
📥 AutoMinimizeManager: Minimized 1 windows from 'Google Chrome'
🙈 AutoHideManager: Hid 1 inactive app(s)
📥 AutoMinimizeManager: Minimized 1 windows from 'Google Chrome'
```

The timers resumed, but apps were immediately hidden because **accumulated time was NOT reset**.

### The Missing Observer

**AutoMinimizeManager** (working correctly):
```swift
// Observe extended idle returns to reset all timers
NotificationCenter.default.publisher(for: .userReturnedFromExtendedIdle)
    .sink { [weak self] _ in
        self?.resetAllTimers()  // ✅ Resets accumulated time
    }
    .store(in: &cancellables)
```

**AppInactivityTracker** (MISSING):
```swift
// ❌ NO OBSERVER for .userReturnedFromExtendedIdle
// Result: Accumulated time persists after extended idle
```

### Why This Happened

When implementing idle detection (Jan 22, 2026), we added:
1. ✅ Pause accumulation during idle (via `isUserActive` check)
2. ✅ Resume accumulation when user returns
3. ❌ **FORGOT** to reset accumulated time after extended idle

The accumulation timer correctly paused during idle, but when the user returned:
- Timer resumed accumulating
- BUT old accumulated time was still there
- Apps immediately exceeded threshold and were hidden

---

## ✅ The Fix

Added observer for `userReturnedFromExtendedIdle` notification in `AppInactivityTracker`:

```swift
// CRITICAL FIX (Jan 24, 2026): Observe extended idle returns to reset timers
NotificationCenter.default.addObserver(
    self,
    selector: #selector(handleExtendedIdleReturn(_:)),
    name: .userReturnedFromExtendedIdle,
    object: nil
)
```

```swift
@objc private func handleExtendedIdleReturn(_ notification: Notification) {
    // Reset all accumulated times when user returns from extended idle
    lock.lock()
    defer { lock.unlock() }
    
    for (bundleID, var info) in appActivity {
        info.accumulatedInactivityTime = 0  // ✅ Reset to 0
        appActivity[bundleID] = info
    }
    
    let idleDuration = notification.userInfo?["idleDuration"] as? TimeInterval ?? 0
    print("🔄 AppInactivityTracker: Reset all \(appActivity.count) app timers (user returned from \(Int(idleDuration))s idle)")
}
```

---

## 📊 Behavior Comparison

### Before Fix (BROKEN)

| Time | Event | Accumulated Time | Result |
|------|-------|------------------|--------|
| 0:00 | Work starts | 0 min | ✅ Normal |
| 10:00 | Chrome inactive | 10 min | ✅ Normal |
| 15:00 | User goes idle | 15 min | ⏸️ Timer paused |
| 30:00 | User returns | **15 min** | ❌ **Immediately hidden!** |

**Problem:** Accumulated time from before idle persisted.

### After Fix (WORKING)

| Time | Event | Accumulated Time | Result |
|------|-------|------------------|--------|
| 0:00 | Work starts | 0 min | ✅ Normal |
| 10:00 | Chrome inactive | 10 min | ✅ Normal |
| 15:00 | User goes idle | 15 min | ⏸️ Timer paused |
| 30:00 | User returns | **0 min** | ✅ **Reset!** |
| 50:00 | Chrome still inactive | 20 min | ✅ Hidden after 20 min |

**Solution:** Accumulated time reset to 0 when user returns from extended idle.

---

## 🎯 What Extended Idle Reset Does

### The Setting: `autoMinimizeIdleResetTime` (default: 5 minutes)

**Purpose:** After being idle for this long, reset ALL timers when user returns.

**Why:** Prevents coming back from lunch/meetings to find everything hidden/minimized.

**Applies To:**
- ✅ Auto-Minimize (always did this)
- ✅ Auto-Hide (NOW fixed)
- ❌ Decay Dimming (doesn't need it - already pauses correctly)

### The Notification: `userReturnedFromExtendedIdle`

**Posted By:** `ActiveUsageTracker` when:
1. User was idle for 5+ minutes (configurable)
2. User becomes active again

**Observed By:**
- ✅ AutoMinimizeManager (resets window timers)
- ✅ AppInactivityTracker (NOW resets app timers)

---

## 🧪 Testing

### Test Scenario

1. Set auto-hide delay to 10 minutes
2. Open Chrome, switch to another app
3. Work for 8 minutes (Chrome accumulates 8 min)
4. Step away for 10 minutes (idle)
5. Return and immediately check

**Before Fix:**
- ❌ Chrome hidden immediately (had 8 min accumulated)
- ❌ App freezes with repeated hide actions

**After Fix:**
- ✅ Chrome visible (accumulated time reset to 0)
- ✅ Chrome only hides after 10 more minutes of active inactivity

---

## 🔧 Technical Details

### Files Modified

**AppInactivityTracker.swift:**
- Lines 147-174: Added observer for `userReturnedFromExtendedIdle`
- Lines 268-280: Added `handleExtendedIdleReturn()` method

### Integration

Works with existing features:
- **Idle Detection:** Timer pauses during idle (30s threshold)
- **Extended Idle Reset:** Timer resets after extended idle (5min threshold)
- **Space Awareness:** Timer pauses for apps on other spaces

### Flow

```
User goes idle (30s) → Timer pauses
User stays idle (5min) → Mark for reset
User returns → Post notification → Reset all timers
```

---

## 📈 Impact

### Before Fix

❌ App freezes after returning from idle
❌ Apps immediately hidden on return
❌ Poor user experience
❌ Users disable auto-hide

### After Fix

✅ Smooth return from idle
✅ Fresh start after breaks
✅ Predictable behavior
✅ Users can trust auto-hide

---

## 🎓 Lessons Learned

### Why This Was Missed

1. **Incomplete Feature Parity:** AutoMinimizeManager had this, AppInactivityTracker didn't
2. **Testing Gap:** Didn't test extended idle scenario thoroughly
3. **Documentation:** Extended idle reset was documented for auto-minimize only

### Prevention

1. **Feature Checklist:** Ensure all timed features have same behavior
2. **Integration Tests:** Test extended idle scenarios
3. **Code Review:** Check for notification observers in all trackers

---

## ✅ Verification

- [x] Build succeeds with no errors
- [x] Extended idle resets app timers
- [x] No immediate hiding on return
- [x] Works with idle detection
- [x] Works with space awareness
- [x] Logs show reset message
- [x] Documentation updated

---

## 📚 Related Issues

### The Three Idle-Related Bugs Fixed Today

1. **Idle Detection Not Working** (AUTO_HIDE_IDLE_BUG_FIX.md)
   - `getInactiveApps()` using wrong time calculation
   - Fixed: Use `accumulatedInactivityTime`

2. **Space Awareness Missing** (SPACE_AWARE_AUTO_HIDE.md)
   - Apps on other spaces accumulating time
   - Fixed: Only accumulate for apps on current space

3. **Extended Idle Reset Missing** (THIS FIX)
   - Accumulated time not reset after extended idle
   - Fixed: Observe `userReturnedFromExtendedIdle` notification

---

## 🎉 Conclusion

**Status:** ✅ Complete and Verified

Auto-hide now properly resets timers when user returns from extended idle (5+ minutes). This prevents the freeze/hang issue and provides a fresh start after breaks.

**Build:** Succeeds with no errors
**Tests:** Extended idle scenario passes
**User Experience:** Significantly improved

---

*Bug discovered and fixed: January 24, 2026*
*Build verified: SuperDimmer v1.0.4+*
*Related: AUTO_HIDE_IDLE_BUG_FIX.md, SPACE_AWARE_AUTO_HIDE.md*
