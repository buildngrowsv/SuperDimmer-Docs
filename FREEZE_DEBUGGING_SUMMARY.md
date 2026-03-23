# SuperDimmer Freeze Debugging - Complete Summary

## 🎯 The Problem

Your app freezes with no errors in Xcode or Console. This is a common issue in macOS development that requires system-level debugging tools.

---

## 📚 Documentation Created

### 1. **ADVANCED_FREEZE_DEBUGGING_GUIDE.md** (Comprehensive)
   - Complete guide to all macOS debugging tools
   - Spindump, Instruments, Console.app, Thread Sanitizer
   - Step-by-step workflows
   - Common freeze patterns and solutions
   - **Read this for deep understanding**

### 2. **FREEZE_DEBUG_QUICK_START.md** (Quick Reference)
   - Fast action guide for when app is frozen
   - How to interpret spindump results
   - Common patterns and fixes
   - **Read this when you need to act fast**

### 3. **debug-freeze.sh** (Automation Script)
   - Captures all diagnostics automatically
   - Three modes: interactive, monitor, auto
   - Creates timestamped report folder
   - **Run this when debugging**

### 4. **AppLogger.swift** (Production Logging)
   - Structured logging with os_log
   - Integrates with Console.app
   - Performance measurement tools
   - **Add this to your codebase**

---

## 🚀 Quick Start: What to Do RIGHT NOW

### If App is Frozen Now:

```bash
cd /Users/ak/UserRoot/Github/SuperDimmer
./debug-freeze.sh
```

Press `y` when prompted. Check Desktop for results folder.

### If You Want to Monitor:

```bash
cd /Users/ak/UserRoot/Github/SuperDimmer
./debug-freeze.sh --monitor
```

This watches for freeze conditions and alerts you.

### If You Want Auto-Capture:

```bash
cd /Users/ak/UserRoot/Github/SuperDimmer
./debug-freeze.sh --auto
```

This automatically captures when freeze is detected.

---

## 🔍 The Tools Explained

### Tool 1: Spindump (PRIMARY TOOL)
**What:** Captures stack traces of all threads when frozen  
**When:** App is frozen right now  
**How:** `sudo spindump SuperDimmer -file ~/Desktop/spindump.txt`  
**Shows:** Exactly what code is blocking and why  

**This is the most important tool for freeze debugging.**

### Tool 2: Instruments (BEST FOR ANALYSIS)
**What:** Real-time profiling of CPU, threads, memory  
**When:** Freeze is reproducible  
**How:** Xcode → Product → Profile → Choose template  
**Shows:** Performance over time, thread states, hangs  

**Use "System Trace" for deadlocks, "Time Profiler" for CPU issues.**

### Tool 3: Console.app + os_log (PRODUCTION)
**What:** System-wide structured logging  
**When:** Need to see what happened before freeze  
**How:** Add AppLogger to code, view in Console.app  
**Shows:** Log sequence leading up to freeze  

**Best for understanding the sequence of events.**

### Tool 4: Thread Sanitizer (RACE CONDITIONS)
**What:** Detects threading issues at runtime  
**When:** Suspect race condition or deadlock  
**How:** Xcode → Edit Scheme → Diagnostics → Thread Sanitizer  
**Shows:** Data races, lock inversions, thread leaks  

**Catches issues before they become freezes.**

### Tool 5: Activity Monitor (QUICK CHECK)
**What:** Live resource monitoring  
**When:** Want quick status check  
**How:** Applications → Utilities → Activity Monitor  
**Shows:** CPU, memory, threads in real-time  

**Good for initial diagnosis.**

---

## 📊 Interpreting Results

### Spindump Patterns

#### Pattern 1: Deadlock (CPU 0%)
```
Thread 0: Blocked in NSLock.lock()
Thread 5: Blocked in NSLock.lock()
```
**Meaning:** Two threads waiting on each other's locks  
**Fix:** Acquire locks in consistent order, or redesign locking

#### Pattern 2: Infinite Loop (CPU 100%)
```
Thread 0: Running
  SuperDimmer  OverlayManager.applyDecayDimming() + 234
```
**Meaning:** Code stuck in loop  
**Fix:** Check loop conditions, add break conditions

#### Pattern 3: WindowServer Timeout
```
Thread 0: Blocked
  CoreGraphics  CGWindowListCreateImage
```
**Meaning:** Screen capture API hanging  
**Fix:** Use ModernScreenCaptureService (ScreenCaptureKit)

#### Pattern 4: Dispatch Queue Deadlock
```
Thread 0: Blocked in dispatch_sync
```
**Meaning:** Main thread waiting on itself  
**Fix:** Never use DispatchQueue.main.sync from main thread

---

## 🎯 Most Likely Causes in SuperDimmer

Based on your codebase analysis:

### 1. Overlay Accumulation (PRIMARY)
**File:** `OverlayManager.swift`  
**Issue:** Overlays not being cleaned up, count grows unbounded  
**Evidence:** Logs show `decayOverlays.count=14`, then `17`, growing  
**Fix:** Add cleanup logic in `applyDecayDimming()` (see FREEZE_FIX_IMPLEMENTATION.md)

### 2. Rapid Idle/Active Cycling (SECONDARY)
**File:** `ActiveUsageTracker.swift`  
**Issue:** Event monitors firing constantly, triggering SwiftUI updates  
**Evidence:** Logs show "User idle/active" with "0s" idle time  
**Fix:** Add debouncing (min 2s between state changes)

### 3. AutoMinimizeManager Loop (TERTIARY)
**File:** `AutoMinimizeManager.swift`  
**Issue:** Same windows minimized repeatedly  
**Evidence:** Logs show repeated minimization messages  
**Fix:** Enforce `currentlyMinimizing` check

### 4. CGWindowListCreateImage Timeout (MITIGATED)
**File:** `ScreenCaptureService.swift`  
**Issue:** Legacy API can timeout under load  
**Evidence:** Previous analysis showed timeouts  
**Fix:** Already implemented - use `useModernAPI = true`

---

## 📝 Step-by-Step Debugging Workflow

### Phase 1: Capture Diagnostics (5 minutes)
1. Run `./debug-freeze.sh` when frozen
2. Or use `--monitor` mode to watch for freezes
3. Check Desktop for results folder

### Phase 2: Analyze Spindump (10 minutes)
1. Open `spindump.txt`
2. Find "SuperDimmer" section
3. Look at Thread 0 (main thread) state
4. Check stack trace - where is it stuck?
5. Look for patterns (deadlock, loop, timeout)

### Phase 3: Review Logs (5 minutes)
1. Open `console-logs.txt`
2. Look at last 50 entries before freeze
3. Check for:
   - Rapid repeated messages
   - Growing counts
   - Warnings/errors
   - Last function called

### Phase 4: Identify Root Cause (10 minutes)
Based on spindump + logs, determine:
- Deadlock? → Two threads blocked on locks
- Infinite loop? → Thread running at 100% CPU
- Timeout? → Thread blocked in system call
- Resource exhaustion? → High memory/thread count

### Phase 5: Apply Fix (varies)
1. Check FREEZE_FIX_IMPLEMENTATION.md for known fixes
2. Or check ADVANCED_FREEZE_DEBUGGING_GUIDE.md for patterns
3. Apply fix to code
4. Test with monitoring enabled

### Phase 6: Verify Fix (30 minutes)
1. Run app with `./debug-freeze.sh --monitor`
2. Use app normally for 30 minutes
3. Check:
   - CPU stays < 20% when idle
   - Memory stable
   - No freeze alerts
   - No rapid log cycling

---

## 🛠️ Adding Production Logging

To catch issues before they become freezes, add structured logging:

### Step 1: Add AppLogger.swift to Xcode Project
1. Open Xcode
2. Right-click on Services folder
3. Add Files to "SuperDimmer"
4. Select `AppLogger.swift`

### Step 2: Add Logging to Key Functions

**In OverlayManager.swift:**
```swift
import os.log

func applyDecayDimming(_ decisions: [DecayDimmingDecision]) {
    AppLogger.overlay.info("applyDecayDimming START: decisions=\(decisions.count), overlays=\(self.decayOverlays.count)")
    
    // ... existing code ...
    
    AppLogger.overlay.info("applyDecayDimming END: overlays=\(self.decayOverlays.count)")
}
```

**In DimmingCoordinator.swift:**
```swift
import os.log

func performAnalysisCycle() {
    AppLogger.dimming.debug("performAnalysisCycle START")
    
    // ... existing code ...
    
    AppLogger.dimming.debug("performAnalysisCycle END")
}
```

**In ActiveUsageTracker.swift:**
```swift
import os.log

func updateIdleState() {
    let wasActive = isUserActive
    // ... calculate new state ...
    if wasActive != isUserActive {
        AppLogger.activity.info("User state changed: \(wasActive ? "active" : "idle") -> \(isUserActive ? "active" : "idle")")
    }
}
```

### Step 3: View Logs in Console.app
1. Open Console.app
2. Select your Mac
3. Search: `subsystem:com.superdimmer.app`
4. Run app and watch logs

### Step 4: Capture Logs for Analysis
```bash
# Save last 5 minutes to file
log show --predicate 'subsystem == "com.superdimmer.app"' --last 5m > ~/Desktop/app-logs.txt
```

---

## 🔧 Known Fixes Available

These fixes are documented in detail in `FREEZE_FIX_IMPLEMENTATION.md`:

### Fix 1: Overlay Cleanup (CRITICAL)
**Priority:** HIGH  
**File:** `OverlayManager.swift`  
**What:** Add cleanup logic to remove stale overlays  
**Impact:** Prevents accumulation and eventual freeze  

### Fix 2: Idle State Debouncing (HIGH)
**Priority:** HIGH  
**File:** `ActiveUsageTracker.swift`  
**What:** Add 2-second minimum between state changes  
**Impact:** Prevents rapid cycling and event queue backup  

### Fix 3: AutoMinimize Deduplication (MEDIUM)
**Priority:** MEDIUM  
**File:** `AutoMinimizeManager.swift`  
**What:** Enforce `currentlyMinimizing` check  
**Impact:** Prevents repeated minimization  

### Fix 4: Apply Throttling (LOW)
**Priority:** LOW  
**File:** `OverlayManager.swift`  
**What:** Add 500ms minimum between `applyDecayDimming` calls  
**Impact:** Safety net against runaway calls  

---

## 📖 Additional Resources

### Apple Documentation
- [WWDC 2023: Analyze hangs with Instruments](https://developer.apple.com/videos/play/wwdc2023/10248/)
- [WWDC 2022: Track down hangs with Xcode](https://developer.apple.com/videos/play/wwdc2022/10082/)
- [Unified Logging Guide](https://developer.apple.com/documentation/os/logging)

### Your Documentation
- `FREEZE_INVESTIGATION_GUIDE.md` - Original investigation
- `FREEZE_FIX_IMPLEMENTATION.md` - Specific fixes
- `FREEZE_FIX_APPLIED.md` - What's been applied
- `MACOS_CRASH_DEBUGGING_BEST_PRACTICES.md` - Crash debugging

---

## ✅ Recommended Action Plan

### Immediate (Today):
1. ✅ Run `./debug-freeze.sh --monitor` in background
2. ✅ Use app normally
3. ✅ When freeze occurs, capture diagnostics
4. ✅ Analyze spindump to identify root cause

### Short-term (This Week):
1. ⬜ Add AppLogger.swift to Xcode project
2. ⬜ Add logging to key functions
3. ⬜ Run with Console.app open
4. ⬜ Apply known fixes from FREEZE_FIX_IMPLEMENTATION.md
5. ⬜ Test with monitoring for 1 hour

### Medium-term (Next Week):
1. ⬜ Profile with Instruments System Trace
2. ⬜ Enable Thread Sanitizer during development
3. ⬜ Add performance measurements with signposts
4. ⬜ Review and optimize timer frequencies
5. ⬜ Add automated tests for freeze conditions

### Long-term (Ongoing):
1. ⬜ Monitor production logs via Console.app
2. ⬜ Set up automated freeze detection in CI
3. ⬜ Add telemetry for performance metrics
4. ⬜ Regular profiling sessions
5. ⬜ Keep documentation updated

---

## 🎓 Key Takeaways

1. **Spindump is your best friend** for freeze debugging
2. **os_log is essential** for production debugging
3. **Instruments shows patterns** over time
4. **Thread Sanitizer catches issues early**
5. **Freezes always have a cause** - the tools will find it

### The Golden Rule:
> **When your app freezes with no errors, the error is in the system state, not the code itself.**
> 
> You need to capture the system state (threads, locks, queues) to see what's wrong.

---

## 📞 Next Steps

1. **Read:** FREEZE_DEBUG_QUICK_START.md (5 minutes)
2. **Run:** `./debug-freeze.sh --monitor` (background)
3. **Wait:** For freeze to occur
4. **Analyze:** Spindump results
5. **Fix:** Apply appropriate fix
6. **Verify:** Monitor for 1 hour

**The spindump will tell you exactly what's wrong.**

---

*Created: January 26, 2026*
*Author: AI Assistant*
*For: SuperDimmer freeze debugging*
