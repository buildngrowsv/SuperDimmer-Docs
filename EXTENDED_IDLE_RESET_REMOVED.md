# Extended Idle Reset Feature Removed

## Summary

Removed the "5-minute extended idle reset" feature as it was redundant with the existing idle-aware timer system.

## Why It Was Removed

### The Original Problem
The extended idle reset was added to prevent apps from being auto-hidden immediately after returning from breaks. The concern was:
- User goes to lunch
- Timers keep accumulating during lunch
- User returns to find everything hidden

### Why It's No Longer Needed
The app already has **idle-aware tracking** that solves this problem:

```swift
private func accumulateInactivityTime() {
    // Only accumulate if user is active
    guard activeUsageTracker.isUserActive else {
        return  // User is idle - don't accumulate ✅
    }
    // ... accumulate time ...
}
```

**Timers already stop during idle periods!** They don't accumulate when you're away from your computer.

### The Redundancy
With idle-aware tracking:
- User goes to lunch → `isUserActive = false`
- Timers pause (don't accumulate)
- User returns → timers resume from where they left off
- Apps hide after the full configured delay

The extended reset was giving a "fresh start" after breaks, but this wasn't necessary since timers already pause during breaks.

## What Changed

### Behavior Before Removal
```
9:00 AM - Chrome inactive, timer at 10 minutes
12:00 PM - Go to lunch (timer pauses at 10 min)
12:05 PM - Extended idle detected
1:00 PM - Return (timer resets to 0)
1:15 PM - Timer hits 15 min → Chrome auto-hides
```

### Behavior After Removal
```
9:00 AM - Chrome inactive, timer at 10 minutes
12:00 PM - Go to lunch (timer pauses at 10 min)
1:00 PM - Return (timer resumes from 10 min)
1:05 PM - Timer hits 15 min → Chrome auto-hides
```

**Result**: More consistent behavior. The timer truly represents "15 minutes of active inactivity" rather than being reset by breaks.

## Files Modified

1. **ActiveUsageTracker.swift**
   - Removed `wasIdle` property
   - Removed `checkForExtendedIdle()` method
   - Removed `checkForIdleReturn()` method
   - Removed `userReturnedFromExtendedIdle` notification
   - Simplified `recordActivity()` and `updateIdleState()`
   - Simplified `handleWakeFromSleep()`

2. **AppInactivityTracker.swift**
   - Removed observer for `userReturnedFromExtendedIdle`
   - Removed `handleExtendedIdleReturn()` method

3. **AutoMinimizeManager.swift**
   - Removed observer for `userReturnedFromExtendedIdle`
   - Removed `resetAllTimers()` method

4. **SettingsManager.swift**
   - Removed `autoMinimizeIdleResetTime` property
   - Removed from `Keys` enum
   - Removed from default profiles
   - Removed from `loadSettings()`
   - Removed from `applyProfile()`
   - Removed from `exportCurrentProfile()`
   - Removed from `resetToDefaults()`

5. **PreferencesView.swift**
   - Removed "Reset timers after idle" slider from UI

## User Impact

### Positive
- **Simpler**: One less setting to understand
- **More consistent**: Timer behavior is predictable
- **Less code**: Fewer potential bugs

### Neutral
- **Behavior change**: Timers continue from where they left off after breaks
- Users might notice apps hide sooner after returning from breaks if they were already close to the threshold

### Mitigation
If users find apps hiding too quickly after breaks, they can:
- Increase the auto-hide delay (e.g., from 15 to 20 minutes)
- Exclude specific apps from auto-hide
- Disable auto-hide entirely

## Testing

The build succeeded with no errors. Test by:

1. **Set auto-hide to 15 minutes**
2. **Use Chrome for 10 minutes, then switch away**
3. **Go idle for 5+ minutes** (walk away)
4. **Return and move mouse**
5. **Chrome should hide after 5 more minutes** (not 15)

This confirms timers resume from where they left off, not reset to zero.

## Code Cleanup

Total lines removed: ~150 lines across 5 files

The codebase is now simpler and easier to understand. The idle-aware tracking is sufficient to prevent the "surprise auto-hide after breaks" problem.

## Build Status

✅ **Build succeeded** - No compilation errors

The app is ready to test with the extended idle reset feature removed.
