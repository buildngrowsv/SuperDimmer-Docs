# Freeze Debugging Quick Start

## 🚨 App is Frozen RIGHT NOW?

Run this immediately:

```bash
cd /Users/ak/UserRoot/Github/SuperDimmer
./debug-freeze.sh
```

Press `y` when prompted. This will capture everything you need.

---

## 📊 Want to Monitor and Auto-Capture?

```bash
cd /Users/ak/UserRoot/Github/SuperDimmer
./debug-freeze.sh --monitor
```

This watches the app and alerts you when it detects freeze conditions. You can then choose to capture diagnostics.

---

## 🤖 Want Fully Automatic Capture?

```bash
cd /Users/ak/UserRoot/Github/SuperDimmer
./debug-freeze.sh --auto
```

This automatically captures diagnostics when it detects a freeze (CPU at 0% or 100% for >5 seconds).

---

## 📁 Where Are the Results?

Look on your Desktop for a folder named:
```
SuperDimmer-Debug-YYYYMMDD-HHMMSS/
```

**Start with this file:**
```
SUMMARY.txt
```

**Then read this (most important):**
```
spindump.txt
```

---

## 🔍 What to Look For in Spindump

Open `spindump.txt` and search for `SuperDimmer`. You'll see sections like:

```
Process:         SuperDimmer [12345]
Path:            /Applications/SuperDimmer.app/Contents/MacOS/SuperDimmer
...

Thread 0 (Main Thread):
  State: Blocked
  0   libsystem_kernel.dylib  __psynch_cvwait
  1   libsystem_pthread.dylib pthread_cond_wait
  2   SuperDimmer             OverlayManager.applyDecayDimming() + 234
  3   SuperDimmer             DimmingCoordinator.performAnalysisCycle() + 567
```

### Key Things to Check:

**1. Thread State:**
- `Blocked` = Waiting on a lock (possible deadlock)
- `Running` = Actively executing (infinite loop if CPU is 100%)
- `Waiting` = Waiting for I/O or timer

**2. Stack Trace:**
- Shows the function call chain
- Top function is where it's stuck
- Look for your code (SuperDimmer functions)

**3. Multiple Threads Blocked:**
If you see multiple threads in "Blocked" state, you likely have a deadlock:
```
Thread 0: Blocked in NSLock.lock() in OverlayManager
Thread 5: Blocked in NSLock.lock() in DimmingCoordinator
```

**4. Main Thread in Tight Loop:**
If main thread is "Running" and CPU is 100%:
```
Thread 0: Running
  SuperDimmer  OverlayManager.applyDecayDimming() + 234
```
This indicates an infinite loop in that function.

---

## 🔧 Common Patterns and Fixes

### Pattern 1: Deadlock (CPU at 0%)

**Spindump shows:**
```
Thread 0: Blocked in NSLock.lock()
Thread 5: Blocked in NSLock.lock()
```

**Fix:** Two threads waiting on each other's locks. Need to:
- Ensure locks are always acquired in same order
- Or use a single lock for related operations
- Or redesign to avoid nested locking

### Pattern 2: Infinite Loop (CPU at 100%)

**Spindump shows:**
```
Thread 0: Running
  SuperDimmer  OverlayManager.applyDecayDimming() + 234
```

**Fix:** Logic error in loop condition. Check:
- `while` loop conditions
- `for` loop ranges
- Recursive calls without base case

### Pattern 3: WindowServer Timeout

**Spindump shows:**
```
Thread 0: Blocked
  CoreGraphics  CGWindowListCreateImage
```

**Fix:** Screen capture API hanging. Use the modern API:
- Enable `useModernAPI = true` in ScreenCaptureService
- Ensure ModernScreenCaptureService is initialized

### Pattern 4: Dispatch Queue Deadlock

**Spindump shows:**
```
Thread 0: Blocked in dispatch_sync
```

**Fix:** Main thread waiting on itself. Never call:
```swift
DispatchQueue.main.sync { ... }  // From main thread
```

Use `async` instead.

---

## 📝 Next Steps After Capturing

1. **Read SUMMARY.txt** - Quick overview
2. **Read spindump.txt** - Find the stuck thread
3. **Read console-logs.txt** - See what happened before freeze
4. **Check process-info.txt** - Look for resource issues

Then:

5. **Identify the pattern** (deadlock, loop, timeout, etc.)
6. **Find the problematic code** (use stack trace)
7. **Apply the fix** (see FREEZE_FIX_IMPLEMENTATION.md)
8. **Test** with monitoring enabled

---

## 🎯 Most Likely Culprits in SuperDimmer

Based on previous analysis:

1. **Overlay accumulation** → Memory/CPU grows → Eventually freezes
   - File: `OverlayManager.swift`
   - Fix: Add cleanup logic (see FREEZE_FIX_IMPLEMENTATION.md)

2. **Rapid idle/active cycling** → Event queue backup → Freeze
   - File: `ActiveUsageTracker.swift`
   - Fix: Add debouncing (see FREEZE_FIX_IMPLEMENTATION.md)

3. **AutoMinimizeManager loop** → AppleScript timeout → Freeze
   - File: `AutoMinimizeManager.swift`
   - Fix: Enforce deduplication check

4. **CGWindowListCreateImage timeout** → WindowServer blocks → Freeze
   - File: `ScreenCaptureService.swift`
   - Fix: Use ModernScreenCaptureService (already implemented)

---

## 📚 Full Documentation

For comprehensive debugging guide:
```
ADVANCED_FREEZE_DEBUGGING_GUIDE.md
```

For specific fixes:
```
FREEZE_FIX_IMPLEMENTATION.md
```

---

## 💡 Pro Tips

1. **Run monitor mode overnight:**
   ```bash
   ./debug-freeze.sh --monitor > freeze-monitor.log 2>&1 &
   ```
   Check in the morning if it caught anything.

2. **Compare multiple captures:**
   If you capture diagnostics at different times, compare the spindumps to see if it's always stuck in the same place.

3. **Check Console.app in real-time:**
   Open Console.app, filter to "SuperDimmer", and watch logs as you use the app. You'll see patterns before the freeze.

4. **Use Activity Monitor:**
   Keep Activity Monitor open showing SuperDimmer. Watch for:
   - CPU spikes
   - Memory growth
   - Thread count increases

5. **Enable Instruments during development:**
   Profile → System Trace while developing. Catch issues before they become freezes.

---

## ❓ Still Stuck?

If the freeze is intermittent or hard to reproduce:

1. **Add extensive logging:**
   ```swift
   import os.log
   let logger = Logger(subsystem: "com.yourcompany.SuperDimmer", category: "Debug")
   logger.info("Function X started")
   ```

2. **Enable Thread Sanitizer:**
   Xcode → Edit Scheme → Run → Diagnostics → Thread Sanitizer
   (Will catch race conditions and potential deadlocks)

3. **Run with Instruments System Trace:**
   Product → Profile → System Trace
   (Shows thread states over time)

4. **Check system logs:**
   ```bash
   log show --predicate 'process == "SuperDimmer"' --last 1h
   ```

---

*Created: January 26, 2026*
*For: SuperDimmer freeze debugging*
