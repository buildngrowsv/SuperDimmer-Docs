# SuperDimmer Freeze Debugging Workflow

## 🔄 Visual Workflow

```
┌─────────────────────────────────────────────────────────────┐
│                    APP FREEZES                              │
│                  (No errors shown)                          │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│              STEP 1: QUICK DIAGNOSIS                        │
│                                                             │
│  Open Activity Monitor:                                     │
│  ├─ CPU at 100%? → CPU-bound issue (infinite loop)        │
│  ├─ CPU at 0%?   → Deadlock/blocking                      │
│  └─ Memory growing? → Memory leak causing slowdown         │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│         STEP 2: CAPTURE DIAGNOSTICS                         │
│                                                             │
│  Run: ./debug-freeze.sh                                     │
│                                                             │
│  This captures:                                             │
│  ✓ Spindump (thread states)                                │
│  ✓ Sample (performance snapshot)                           │
│  ✓ Console logs (last 5 minutes)                           │
│  ✓ Process info (CPU, memory, threads)                     │
│  ✓ Activity Monitor data                                   │
│  ✓ Recent crash/hang logs                                  │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│         STEP 3: ANALYZE SPINDUMP                            │
│                                                             │
│  Open: ~/Desktop/SuperDimmer-Debug-*/spindump.txt           │
│                                                             │
│  Look for:                                                  │
│  ├─ Thread 0 (main) state: Blocked/Running/Waiting        │
│  ├─ Stack trace: Which function is stuck?                 │
│  └─ Other threads: Are they blocked too?                  │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│         STEP 4: IDENTIFY PATTERN                            │
│                                                             │
│  ┌──────────────────────────────────────────────┐          │
│  │ Pattern A: DEADLOCK (CPU 0%)                 │          │
│  │ Thread 0: Blocked in NSLock.lock()           │          │
│  │ Thread 5: Blocked in NSLock.lock()           │          │
│  │ → Two threads waiting on each other          │          │
│  └──────────────────────────────────────────────┘          │
│                                                             │
│  ┌──────────────────────────────────────────────┐          │
│  │ Pattern B: INFINITE LOOP (CPU 100%)          │          │
│  │ Thread 0: Running                            │          │
│  │   SuperDimmer  OverlayManager.func() + 234   │          │
│  │ → Code stuck in loop                         │          │
│  └──────────────────────────────────────────────┘          │
│                                                             │
│  ┌──────────────────────────────────────────────┐          │
│  │ Pattern C: WINDOWSERVER TIMEOUT              │          │
│  │ Thread 0: Blocked                            │          │
│  │   CoreGraphics  CGWindowListCreateImage      │          │
│  │ → Screen capture API hanging                 │          │
│  └──────────────────────────────────────────────┘          │
│                                                             │
│  ┌──────────────────────────────────────────────┐          │
│  │ Pattern D: DISPATCH DEADLOCK                 │          │
│  │ Thread 0: Blocked in dispatch_sync           │          │
│  │ → Main thread waiting on itself              │          │
│  └──────────────────────────────────────────────┘          │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│         STEP 5: APPLY FIX                                   │
│                                                             │
│  Pattern A (Deadlock):                                      │
│  → Acquire locks in consistent order                        │
│  → Or redesign to avoid nested locking                      │
│                                                             │
│  Pattern B (Infinite Loop):                                 │
│  → Check loop conditions                                    │
│  → Add break conditions                                     │
│  → Review logic errors                                      │
│                                                             │
│  Pattern C (WindowServer Timeout):                          │
│  → Use ModernScreenCaptureService                           │
│  → Set useModernAPI = true                                  │
│                                                             │
│  Pattern D (Dispatch Deadlock):                             │
│  → Never use DispatchQueue.main.sync from main thread      │
│  → Use .async instead                                       │
│                                                             │
│  See FREEZE_FIX_IMPLEMENTATION.md for specific fixes        │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│         STEP 6: VERIFY FIX                                  │
│                                                             │
│  Run: ./debug-freeze.sh --monitor                           │
│                                                             │
│  Monitor for 30-60 minutes:                                 │
│  ✓ CPU stays < 20% when idle                               │
│  ✓ Memory stable                                           │
│  ✓ No freeze alerts                                        │
│  ✓ No rapid log cycling                                    │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
                    ┌───────────────┐
                    │  ISSUE FIXED  │
                    └───────────────┘
```

---

## 🎯 Decision Tree: Which Tool to Use?

```
                    ┌─────────────────┐
                    │  What's wrong?  │
                    └─────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
        ▼                   ▼                   ▼
┌──────────────┐   ┌──────────────┐   ┌──────────────┐
│ App frozen   │   │ Freeze is    │   │ Need to see  │
│ RIGHT NOW    │   │ reproducible │   │ what happens │
│              │   │ but not now  │   │ before freeze│
└──────────────┘   └──────────────┘   └──────────────┘
        │                   │                   │
        ▼                   ▼                   ▼
┌──────────────┐   ┌──────────────┐   ┌──────────────┐
│  SPINDUMP    │   │ INSTRUMENTS  │   │ CONSOLE.APP  │
│              │   │              │   │  + os_log    │
│ ./debug-     │   │ Product →    │   │              │
│ freeze.sh    │   │ Profile      │   │ Add AppLogger│
│              │   │              │   │ to code      │
└──────────────┘   └──────────────┘   └──────────────┘
```

---

## 📊 Tool Comparison Matrix

| Tool | When to Use | Speed | Detail | Overhead |
|------|-------------|-------|--------|----------|
| **Spindump** | Frozen now | Fast (15s) | High | None |
| **Sample** | Quick check | Fast (3-10s) | Medium | None |
| **Instruments** | Reproducible | Slow (ongoing) | Very High | Low |
| **Console.app** | Before freeze | Fast (instant) | Medium | None |
| **Thread Sanitizer** | Development | Slow (ongoing) | Very High | High |
| **Activity Monitor** | Quick status | Instant | Low | None |

---

## 🔍 Spindump Analysis Flowchart

```
┌─────────────────────────────────────┐
│  Open spindump.txt                  │
│  Search for "SuperDimmer"           │
└─────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────┐
│  Find Thread 0 (Main Thread)        │
│  What is the State?                 │
└─────────────────────────────────────┘
              │
    ┌─────────┼─────────┐
    │         │         │
    ▼         ▼         ▼
┌────────┐ ┌────────┐ ┌────────┐
│Blocked │ │Running │ │Waiting │
└────────┘ └────────┘ └────────┘
    │         │         │
    ▼         ▼         ▼
┌────────┐ ┌────────┐ ┌────────┐
│Look at │ │Look at │ │Look at │
│what    │ │CPU %   │ │what    │
│it's    │ │        │ │it's    │
│waiting │ │        │ │waiting │
│for     │ │        │ │for     │
└────────┘ └────────┘ └────────┘
    │         │         │
    ▼         ▼         ▼
┌────────┐ ┌────────┐ ┌────────┐
│NSLock? │ │100%?   │ │I/O?    │
│Mutex?  │ │Infinite│ │Timer?  │
│Sync?   │ │loop!   │ │Network?│
└────────┘ └────────┘ └────────┘
    │         │         │
    ▼         ▼         ▼
┌────────┐ ┌────────┐ ┌────────┐
│Check   │ │Check   │ │Check   │
│other   │ │stack   │ │if      │
│threads │ │trace   │ │timeout │
│for     │ │for loop│ │is      │
│same    │ │logic   │ │expected│
│lock    │ │        │ │        │
└────────┘ └────────┘ └────────┘
    │         │         │
    ▼         ▼         ▼
┌────────┐ ┌────────┐ ┌────────┐
│DEADLOCK│ │INFINITE│ │TIMEOUT │
│        │ │LOOP    │ │        │
└────────┘ └────────┘ └────────┘
```

---

## 🛠️ SuperDimmer-Specific Debugging Path

```
┌─────────────────────────────────────────────────────────────┐
│              SUPERDIMMER FREEZE                             │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
              ┌─────────────────────────┐
              │  Run ./debug-freeze.sh  │
              └─────────────────────────┘
                            │
                            ▼
              ┌─────────────────────────┐
              │  Check spindump.txt     │
              │  for stuck function     │
              └─────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
        ▼                   ▼                   ▼
┌──────────────┐   ┌──────────────┐   ┌──────────────┐
│ Stuck in     │   │ Stuck in     │   │ Stuck in     │
│ OverlayMgr   │   │ ActiveUsage  │   │ ScreenCapture│
│              │   │ Tracker      │   │ Service      │
└──────────────┘   └──────────────┘   └──────────────┘
        │                   │                   │
        ▼                   ▼                   ▼
┌──────────────┐   ┌──────────────┐   ┌──────────────┐
│ Check        │   │ Check        │   │ Check        │
│ console-logs │   │ console-logs │   │ if using     │
│ for overlay  │   │ for rapid    │   │ legacy API   │
│ count growth │   │ idle/active  │   │              │
└──────────────┘   └──────────────┘   └──────────────┘
        │                   │                   │
        ▼                   ▼                   ▼
┌──────────────┐   ┌──────────────┐   ┌──────────────┐
│ Apply Fix 1: │   │ Apply Fix 2: │   │ Set          │
│ Add overlay  │   │ Add debounce │   │ useModernAPI │
│ cleanup      │   │ (2s min)     │   │ = true       │
└──────────────┘   └──────────────┘   └──────────────┘
        │                   │                   │
        └───────────────────┼───────────────────┘
                            │
                            ▼
              ┌─────────────────────────┐
              │ Test with --monitor     │
              │ for 30-60 minutes       │
              └─────────────────────────┘
                            │
                            ▼
              ┌─────────────────────────┐
              │  Verify:                │
              │  ✓ CPU < 20%            │
              │  ✓ Memory stable        │
              │  ✓ No freeze alerts     │
              └─────────────────────────┘
```

---

## 📋 Checklist Format

### Before Debugging:
- [ ] Activity Monitor open showing SuperDimmer
- [ ] Console.app open with filter: `subsystem:com.superdimmer.app`
- [ ] Terminal ready with debug script
- [ ] Note current CPU/memory usage

### During Freeze:
- [ ] Note exact time of freeze
- [ ] Check CPU % (0% or 100%?)
- [ ] Check memory usage
- [ ] Run `./debug-freeze.sh`
- [ ] Wait for capture to complete (~20 seconds)

### After Capture:
- [ ] Open SUMMARY.txt
- [ ] Read spindump.txt (search for "SuperDimmer")
- [ ] Check console-logs.txt (last 50 lines)
- [ ] Review process-info.txt (thread count)
- [ ] Identify pattern (deadlock/loop/timeout)

### Applying Fix:
- [ ] Locate problematic file/function
- [ ] Check FREEZE_FIX_IMPLEMENTATION.md
- [ ] Apply appropriate fix
- [ ] Add logging with AppLogger
- [ ] Build and test

### Verification:
- [ ] Run with `--monitor` for 30 minutes
- [ ] Check CPU stays < 20%
- [ ] Check memory stable
- [ ] Check no rapid log cycling
- [ ] Test all major features
- [ ] Mark issue as resolved

---

## 🎓 Learning Path

### Beginner:
1. Read: FREEZE_DEBUG_QUICK_START.md
2. Run: `./debug-freeze.sh --help`
3. Practice: Run script in interactive mode
4. Learn: How to read spindump (4 patterns)

### Intermediate:
1. Read: ADVANCED_FREEZE_DEBUGGING_GUIDE.md
2. Use: Instruments Time Profiler
3. Add: AppLogger to codebase
4. Learn: Console.app filtering

### Advanced:
1. Use: Instruments System Trace
2. Enable: Thread Sanitizer
3. Master: LLDB debugging commands
4. Learn: Lock ordering and deadlock prevention

---

*Created: January 26, 2026*
*For: SuperDimmer freeze debugging*
