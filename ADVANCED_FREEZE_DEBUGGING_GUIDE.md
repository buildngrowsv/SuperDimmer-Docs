# Advanced Freeze Debugging Guide for SuperDimmer

## Problem: App Freezes with No Errors

When your macOS app freezes but Xcode and Console show no errors, you need to go deeper into system-level debugging tools. This guide covers professional techniques used by macOS developers.

---

## 🎯 Quick Diagnosis Checklist

Before diving into advanced tools, verify:

- [ ] CPU usage in Activity Monitor (is it 100% or 0%?)
- [ ] Memory usage (is it growing unbounded?)
- [ ] Thread count (is it growing?)
- [ ] Console.app shows any warnings/errors for your app
- [ ] The freeze is reproducible

---

## 🔧 Tool 1: Spindump (PRIMARY TOOL FOR FREEZES)

**What it does:** Captures detailed stack traces of ALL threads when your app is frozen, showing exactly what code is blocking.

### Method A: Via Activity Monitor (Easiest)

1. Open **Activity Monitor** (Applications → Utilities)
2. Find and select **SuperDimmer** in the process list
3. Click the **"..." (More)** button in the toolbar
4. Select **"Run Spindump"**
5. Wait 10-15 seconds while it captures data
6. Save the report to Desktop

### Method B: Via Terminal (More Control)

```bash
# Capture spindump for SuperDimmer specifically
sudo spindump SuperDimmer -file ~/Desktop/superdimmer-spindump.txt

# Or capture system-wide spindump (includes all processes)
sudo spindump -file ~/Desktop/system-spindump.txt
```

### What to Look For in Spindump

Open the `.txt` file and search for:

1. **"SuperDimmer" section** - shows all threads
2. **Thread states:**
   - `Blocked` - waiting on a lock/semaphore
   - `Running` - actively executing (CPU-bound)
   - `Waiting` - waiting for I/O or timer
3. **Stack traces** - shows function call chain

**Example of a deadlock:**
```
Thread 0 (Main Thread):
  0   libsystem_kernel.dylib  __psynch_cvwait
  1   libsystem_pthread.dylib pthread_cond_wait
  2   SuperDimmer             OverlayManager.applyDecayDimming() + 234
  3   SuperDimmer             DimmingCoordinator.performAnalysisCycle() + 567
```

This tells you the main thread is blocked in `applyDecayDimming()` waiting on a condition variable (lock).

---

## 🔧 Tool 2: Xcode Instruments (BEST FOR ONGOING ANALYSIS)

**What it does:** Real-time profiling of CPU, threads, memory, and hangs while your app runs.

### Setup

1. In Xcode, select **Product → Profile** (⌘I)
2. Choose one of these templates:

#### Template: Time Profiler
- **Use for:** CPU-bound freezes (100% CPU usage)
- **Shows:** Which functions are consuming CPU time
- **How:** Records call stacks at regular intervals

#### Template: System Trace
- **Use for:** Thread blocking, lock contention
- **Shows:** Thread states, context switches, system calls
- **How:** Kernel-level tracing of thread behavior

#### Template: Hangs
- **Use for:** Main thread responsiveness issues
- **Shows:** When main thread is blocked >250ms
- **How:** Automatically detects and highlights hangs

### Using Instruments

1. **Start recording** (red button)
2. **Reproduce the freeze** in your app
3. **Stop recording** (stop button)
4. **Analyze the timeline:**
   - Look for spikes in CPU usage
   - Look for gaps in main thread activity
   - Look for lock contention events

### Interpreting Results

**Time Profiler:**
- Sort by "Self Weight" to find hotspots
- Look for functions taking >100ms on main thread
- Check if same function appears repeatedly (infinite loop)

**System Trace:**
- Filter to "SuperDimmer" process
- Look at "Thread States" track
- Red sections = blocked/waiting
- Green sections = running

**Hangs:**
- Shows exact timestamp of each hang
- Click on hang to see stack trace
- Shows duration of hang

---

## 🔧 Tool 3: Console.app + os_log (BEST FOR PRODUCTION)

**What it does:** System-wide logging that persists even after crashes/freezes.

### Step 1: Add Structured Logging to Your Code

Replace `print()` statements with `os_log`:

```swift
import os.log

// Create a logger for your subsystem
private let logger = Logger(subsystem: "com.yourcompany.SuperDimmer", category: "OverlayManager")

// Use it throughout your code
logger.info("Starting applyDecayDimming with \(decisions.count) decisions")
logger.debug("Overlay count: \(self.decayOverlays.count)")
logger.warning("High overlay count detected: \(count)")
logger.error("Failed to create overlay: \(error.localizedDescription)")
```

**Why os_log is better than print():**
- Persists to system logs (survives crashes)
- Filterable by subsystem/category
- Includes timestamps, thread info, process info
- Low performance overhead
- Viewable in Console.app

### Step 2: Add Signposts for Performance Tracking

Signposts mark time intervals to measure performance:

```swift
import os.signpost

private let signposter = OSSignposter(subsystem: "com.yourcompany.SuperDimmer", category: "Performance")

func applyDecayDimming(_ decisions: [DecayDimmingDecision]) {
    // Mark the start of an operation
    let signpostID = signposter.makeSignpostID()
    let state = signposter.beginInterval("applyDecayDimming", id: signpostID)
    
    // ... your code ...
    
    // Mark the end
    signposter.endInterval("applyDecayDimming", state)
}
```

### Step 3: View Logs in Console.app

1. Open **Console.app** (Applications → Utilities)
2. Select your **Mac** in the sidebar
3. Click **Start** to begin streaming logs
4. In the search field, enter: `subsystem:com.yourcompany.SuperDimmer`
5. Reproduce the freeze
6. Review logs leading up to the freeze

**Pro tip:** Create a saved search for your subsystem:
- File → Save Search
- Name it "SuperDimmer Logs"
- Quick access in sidebar

### Step 4: Capture Logs During Freeze

```bash
# Capture last 5 minutes of logs to a file
log show --predicate 'subsystem == "com.yourcompany.SuperDimmer"' --last 5m > ~/Desktop/superdimmer-logs.txt

# Or capture logs in real-time
log stream --predicate 'subsystem == "com.yourcompany.SuperDimmer"'
```

---

## 🔧 Tool 4: Thread Sanitizer (BEST FOR RACE CONDITIONS)

**What it does:** Detects data races and threading issues at runtime.

### Enable in Xcode

1. Select your scheme → **Edit Scheme**
2. Go to **Run → Diagnostics**
3. Check **"Thread Sanitizer"**
4. Run your app

### What It Detects

- Data races (multiple threads accessing same variable)
- Use of uninitialized memory
- Thread leaks
- Lock order inversions (potential deadlocks)

**When it finds an issue:**
- Xcode pauses execution
- Shows both threads involved
- Highlights the conflicting code

**Warning:** Thread Sanitizer adds significant overhead (~5-10x slower). Only use when debugging threading issues.

---

## 🔧 Tool 5: Sample Process (QUICK SNAPSHOT)

**What it does:** Takes a 3-second snapshot of thread activity (lighter than spindump).

### Via Activity Monitor

1. Select **SuperDimmer** in Activity Monitor
2. Click **"..." → Sample Process**
3. Wait 3 seconds
4. Review the report

### Via Terminal

```bash
sample SuperDimmer 10 -file ~/Desktop/superdimmer-sample.txt
```

This captures 10 seconds of samples (default is 3).

---

## 🔧 Tool 6: Xcode Debug Gauges (REAL-TIME MONITORING)

**What it does:** Shows live CPU, memory, disk, and network usage while debugging.

### Enable

1. Run your app in Xcode (⌘R)
2. Open **Debug Navigator** (⌘7)
3. Watch the gauges in real-time

### What to Watch For

- **CPU gauge:** Should be <20% when idle
  - If 100%: CPU-bound infinite loop
  - If 0%: Deadlock or blocking I/O
- **Memory gauge:** Should be stable
  - If growing: Memory leak
- **Threads gauge:** Should be stable
  - If growing: Thread leak

**Click any gauge** to open Instruments for detailed profiling.

---

## 🔧 Tool 7: LLDB Debugging Commands

**What it does:** Inspect app state while frozen in debugger.

### Attach to Running Process

```bash
# Find the process ID
ps aux | grep SuperDimmer

# Attach LLDB
lldb -p <PID>
```

### Useful Commands When Attached

```lldb
# Show all threads and their states
thread list

# Show backtrace for all threads
thread backtrace all

# Switch to a specific thread
thread select 2

# Show variables in current frame
frame variable

# Continue execution
continue

# Pause execution (if running)
process interrupt
```

### Detect Deadlocks

```lldb
# Show all threads
thread list

# Look for threads in "waiting" state
# Then check what they're waiting on:
thread backtrace all | grep -A 5 "pthread_mutex_lock\|NSLock\|dispatch_sync"
```

---

## 🎯 Debugging Strategy: Step-by-Step

### Phase 1: Identify the Type of Freeze

1. **Run app until it freezes**
2. **Check Activity Monitor:**
   - CPU at 100%? → CPU-bound loop
   - CPU at 0%? → Deadlock or blocking I/O
   - Memory growing? → Memory leak causing slowdown

### Phase 2: Capture Diagnostic Data

**For CPU-bound freeze (100% CPU):**
1. Run **Instruments Time Profiler**
2. Reproduce freeze
3. Look for hot functions

**For deadlock (0% CPU):**
1. Run **spindump** while frozen
2. Look for threads in "Blocked" state
3. Identify which locks they're waiting on

**For intermittent freeze:**
1. Add **os_log** statements throughout code
2. Run app with **Console.app** open
3. Review logs when freeze occurs

### Phase 3: Narrow Down the Cause

Based on spindump/Instruments, you'll see one of:

**A. Main thread blocked on lock:**
```
Thread 0: Blocked in NSLock.lock()
Thread 3: Blocked in NSLock.lock()
```
→ **Deadlock:** Two threads waiting on each other's locks

**B. Main thread in tight loop:**
```
Thread 0: 99.9% in OverlayManager.applyDecayDimming()
```
→ **Infinite loop:** Logic error in loop condition

**C. Main thread waiting on background thread:**
```
Thread 0: Blocked in DispatchQueue.sync()
Thread 5: Running in ScreenCaptureService.captureMainDisplay()
```
→ **Blocking sync:** Main thread waiting for slow background work

### Phase 4: Fix and Verify

1. **Apply fix** based on root cause
2. **Re-run Instruments** to verify fix
3. **Monitor with os_log** for regressions

---

## 🔍 Common Freeze Patterns in SuperDimmer

Based on your codebase, here are likely culprits:

### Pattern 1: Lock Contention in OverlayManager

**Symptom:** Spindump shows multiple threads blocked in `NSLock.lock()`

**Files to check:**
- `OverlayManager.swift` - Uses locks for overlay dictionaries
- `DimmingCoordinator.swift` - Calls overlay methods from timers

**Fix:** Ensure locks are held for minimal time, never call sync operations while holding lock.

### Pattern 2: CGWindowListCreateImage Timeout

**Symptom:** Main thread blocked in `CGWindowListCreateImage` for >5 seconds

**Files to check:**
- `ScreenCaptureService.swift` line 288-293 (legacy API)

**Fix:** Already implemented - use `ModernScreenCaptureService` (ScreenCaptureKit) which is non-blocking.

### Pattern 3: Rapid Timer Firing

**Symptom:** CPU at 100%, Time Profiler shows timer callbacks

**Files to check:**
- `DimmingCoordinator.swift` - Multiple timers (2s, 500ms, 33ms)
- `ActiveUsageTracker.swift` - Event monitors firing constantly

**Fix:** Add throttling/debouncing to timer callbacks.

### Pattern 4: Overlay Accumulation

**Symptom:** Memory growing, CPU increasing, eventually freezes

**Files to check:**
- `OverlayManager.swift` - `decayOverlays` dictionary growing unbounded

**Fix:** Already documented in `FREEZE_FIX_IMPLEMENTATION.md` - add cleanup logic.

---

## 📋 Recommended Debugging Workflow for Your Issue

Since you've already tried basic debugging, here's the advanced approach:

### Step 1: Capture Spindump While Frozen (5 minutes)

```bash
# In one terminal, monitor for freeze
while true; do
  ps aux | grep SuperDimmer | grep -v grep
  sleep 1
done

# When it freezes, in another terminal:
sudo spindump SuperDimmer -file ~/Desktop/freeze-spindump.txt
```

**Analyze the spindump:**
- Find "SuperDimmer" section
- Look at Thread 0 (main thread) state
- Look at all thread states
- Identify what they're waiting on

### Step 2: Add Comprehensive Logging (15 minutes)

Add `os_log` statements to key functions:

```swift
// In OverlayManager.swift
private let logger = Logger(subsystem: "com.yourcompany.SuperDimmer", category: "OverlayManager")

func applyDecayDimming(_ decisions: [DecayDimmingDecision]) {
    logger.info("applyDecayDimming START: decisions=\(decisions.count), currentOverlays=\(self.decayOverlays.count)")
    
    // ... existing code ...
    
    logger.info("applyDecayDimming END: overlays=\(self.decayOverlays.count)")
}
```

Add to:
- `OverlayManager.applyDecayDimming()`
- `DimmingCoordinator.performAnalysisCycle()`
- `ActiveUsageTracker.updateIdleState()`
- `ScreenCaptureService.captureMainDisplay()`

### Step 3: Run with Console.app Open (10 minutes)

1. Open Console.app
2. Filter to your subsystem
3. Run SuperDimmer
4. Wait for freeze
5. Review last 100 log entries before freeze

**Look for:**
- Functions called in rapid succession
- Growing counts (overlay count, window count)
- Warnings or errors
- Last function called before freeze

### Step 4: Profile with Instruments (20 minutes)

1. Product → Profile → Choose "System Trace"
2. Start recording
3. Wait for freeze (or reproduce it)
4. Stop recording
5. Analyze:
   - Filter to SuperDimmer process
   - Look at Thread States track
   - Find when main thread stops responding
   - Check what it was doing before that

### Step 5: Check for Deadlocks (5 minutes)

If spindump shows threads blocked on locks:

```bash
# While app is frozen, attach LLDB
lldb -p $(pgrep SuperDimmer)

# In LLDB:
(lldb) thread backtrace all

# Look for:
# - Multiple threads in NSLock.lock()
# - Threads in dispatch_sync()
# - Threads in pthread_mutex_lock()
```

**Classic deadlock pattern:**
```
Thread 0: Waiting on lockA, holds lockB
Thread 5: Waiting on lockB, holds lockA
```

---

## 🚨 Emergency Debugging: App Frozen Right Now

If your app is frozen right now:

```bash
# 1. Capture spindump immediately
sudo spindump SuperDimmer -file ~/Desktop/emergency-spindump.txt

# 2. Capture sample
sample SuperDimmer 10 -file ~/Desktop/emergency-sample.txt

# 3. Capture logs
log show --predicate 'process == "SuperDimmer"' --last 5m > ~/Desktop/emergency-logs.txt

# 4. Check thread count
ps -M $(pgrep SuperDimmer) | wc -l

# 5. Check CPU usage per thread
ps -M $(pgrep SuperDimmer)

# 6. Kill the app
killall SuperDimmer
```

Then analyze the captured files.

---

## 📊 What to Look For in Each Tool

| Tool | Freeze Type | What to Check |
|------|-------------|---------------|
| **Spindump** | All types | Thread states, stack traces, blocked threads |
| **Instruments Time Profiler** | CPU-bound | Hot functions, call trees, self time |
| **Instruments System Trace** | Deadlock | Thread states, lock contention, context switches |
| **Instruments Hangs** | Main thread | Hang duration, stack trace at hang |
| **Console.app** | All types | Log sequence, growing counts, last function |
| **Activity Monitor** | All types | CPU %, memory, threads, energy |
| **Thread Sanitizer** | Race conditions | Data races, lock inversions |

---

## 🎓 Learning Resources

- [WWDC 2023: Analyze hangs with Instruments](https://developer.apple.com/videos/play/wwdc2023/10248/)
- [WWDC 2022: Track down hangs with Xcode](https://developer.apple.com/videos/play/wwdc2022/10082/)
- [Unified Logging Guide](https://developer.apple.com/documentation/os/logging)
- [Instruments Help](https://help.apple.com/instruments/mac/)

---

## ✅ Next Steps for SuperDimmer

Based on your previous investigation docs, I recommend:

1. **Immediate:** Run spindump next time it freezes
2. **Short-term:** Add os_log throughout the codebase
3. **Medium-term:** Profile with Instruments System Trace
4. **Long-term:** Enable Thread Sanitizer during development

The freeze is likely one of:
- Overlay accumulation causing WindowServer overload
- Deadlock between main thread and background threads
- CGWindowListCreateImage timeout (though you have the modern API now)
- Rapid timer firing causing event queue backup

**The spindump will tell us definitively which one it is.**

---

*Created: January 26, 2026*
*For: SuperDimmer freeze debugging*
