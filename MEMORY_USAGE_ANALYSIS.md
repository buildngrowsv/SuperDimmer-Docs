# SuperDimmer Memory Usage Analysis

**Date:** January 25, 2026  
**Current Memory Usage:** 298.1 MB (0.23% of system)  
**Status:** ⚠️ HIGH - Needs optimization

---

## Executive Summary

SuperDimmer is using **298 MB of memory**, which is higher than expected for a menu bar utility. The primary culprits are:

1. **Screen capture operations** - Full-resolution screenshots being held in memory
2. **Overlay window accumulation** - Windows never being deallocated, just hidden
3. **Multiple high-frequency timers** - Running constantly even when not needed
4. **Pixel data retention** - Large bitmap contexts not being released

---

## Memory Hotspots (Ranked by Impact)

### 🔴 CRITICAL: Screen Capture Service

**Location:** `ScreenCaptureService.swift`

**Problem:**
- Captures full-resolution screenshots (e.g., 6400x3600 = 23 million pixels)
- Each capture creates a CGImage that's ~92 MB for a 6K display
- Even though we downsample for analysis, the FULL image is captured first
- CGWindowListCreateImage limitation: Can't capture at reduced resolution directly

**Current Flow:**
```
1. Capture full 6400x3600 → 92 MB CGImage
2. Downsample to 100x56 → 0.02 MB CGImage  
3. Analyze the small image
4. Discard both images
```

**Memory Impact:** ~100-200 MB per analysis cycle

**Solutions:**
- ✅ Already downsampling for analysis (line 446-456)
- ❌ Can't avoid full capture (macOS API limitation)
- ⚠️ Need to ensure images are released immediately after use
- ⚠️ Consider reducing capture frequency when idle

---

### 🔴 CRITICAL: Overlay Window Accumulation

**Location:** `OverlayManager.swift`

**Problem:**
- Overlays are NEVER deallocated (by design to prevent crashes)
- Hidden overlays stay in memory forever
- Each overlay window = ~500 KB + backing store
- With 50+ region overlays created over time = 25+ MB

**Current Strategy (lines 972-992):**
```swift
private func safeHideOverlay(_ overlay: DimOverlayWindow) {
    // Remove animations
    overlay.setDimLevel(0.0, animated: false)
    overlay.orderOut(nil)
    // DON'T close - let ARC deallocate
}
```

**Problem with Current Strategy:**
- Overlays ARE removed from dictionaries (line 1031, 1035)
- But they're never actually deallocated
- They accumulate in memory as "zombie" windows

**Memory Impact:** ~25-50 MB for accumulated overlays

**Solutions:**
- ✅ Already avoiding NSWindow.close() (prevents crashes)
- ❌ Need better cleanup strategy
- ⚠️ Consider periodic purge of hidden overlays
- ⚠️ Implement overlay pooling with max size

---

### 🟡 HIGH: Brightness Analysis Pixel Data

**Location:** `BrightnessAnalysisEngine.swift`

**Problem:**
- Creates large pixel buffers for analysis (line 391)
- Each buffer = width × height × 4 bytes
- For 80×80 analysis = 25 KB per analysis
- Multiple buffers created during grid analysis

**Current Flow (lines 299-342):**
```swift
private func getPixelBrightnessData(from image: CGImage, targetSize: Int) -> PixelBrightnessData? {
    let width = targetSize  // 80
    let height = targetSize  // 80
    let bytesPerPixel = 4
    let bytesPerRow = width * bytesPerPixel
    
    guard let context = CGContext(...) else { return nil }
    context.draw(image, in: CGRect(...))
    
    let buffer = data.bindMemory(to: UInt8.self, capacity: width * height * bytesPerPixel)
    var pixels = [Float](repeating: 0, count: width * height)
    // ... calculate luminance
}
```

**Memory Impact:** ~5-10 MB during analysis cycles

**Solutions:**
- ✅ Already using small analysis resolution (80×80)
- ⚠️ Could reuse pixel buffers instead of allocating new ones
- ⚠️ Use autoreleasepool around analysis operations

---

### 🟡 HIGH: Multiple High-Frequency Timers

**Location:** Multiple services

**Problem:**
- Multiple timers running simultaneously:
  - `analysisTimer`: Every 2.0s (heavy - screenshots)
  - `windowTrackingTimer`: Every 0.5s (medium - window enumeration)
  - `highFrequencyTrackingTimer`: Every 0.033s / 30fps (light - position updates)
  - `accumulationTimer`: Every 10s (light - inactivity tracking)
  - `updateTimer`: Auto-minimize checks

**Memory Impact:** ~10-20 MB for timer overhead and queued operations

**Solutions:**
- ✅ High-frequency timer only runs when windows are moving (line 108)
- ⚠️ Could pause all timers when user is idle
- ⚠️ Could reduce frequency when no overlays are visible

---

### 🟢 MEDIUM: Region Detection Pixel Masks

**Location:** `BrightRegionDetector.swift`

**Problem:**
- Creates binary masks for connected component analysis (line 214)
- Each mask = width × height booleans
- For 80×80 = 6,400 booleans = ~6 KB
- Multiple masks during flood fill operations

**Memory Impact:** ~5 MB during region detection

**Solutions:**
- ✅ Already using small analysis resolution
- ⚠️ Could use bit arrays instead of bool arrays (8× smaller)

---

## Recommended Optimizations (Priority Order)

### 1. **Immediate Release of Screen Captures** ⭐⭐⭐

**Impact:** Could save 50-100 MB

**Implementation:**
```swift
// In DimmingCoordinator.swift - wrap analysis in autoreleasepool
func performAnalysisCycle() {
    autoreleasepool {
        guard let image = ScreenCaptureService.shared.captureMainDisplay() else { return }
        
        // Immediately downsample and release original
        guard let smallImage = ScreenCaptureService.shared.downsample(image, factor: 0.015) else { return }
        // Original image released here
        
        // Analyze small image
        let brightness = BrightnessAnalysisEngine.shared.averageLuminance(of: smallImage)
        // Small image released here
    }
    // All autoreleased objects released here
}
```

---

### 2. **Overlay Pool with Maximum Size** ⭐⭐⭐

**Impact:** Could save 20-40 MB

**Implementation:**
```swift
// In OverlayManager.swift
private var overlayPool: [DimOverlayWindow] = []
private let maxPoolSize = 20  // Maximum hidden overlays to keep

private func safeHideOverlay(_ overlay: DimOverlayWindow) {
    overlay.setDimLevel(0.0, animated: false)
    overlay.orderOut(nil)
    
    // Add to pool if under limit
    if overlayPool.count < maxPoolSize {
        overlayPool.append(overlay)
    } else {
        // Pool is full - let this one deallocate
        // (Don't call close, just remove all references)
    }
}

private func getOrCreateOverlay(frame: CGRect, dimLevel: CGFloat, id: String) -> DimOverlayWindow {
    // Try to reuse from pool
    if let pooled = overlayPool.popLast() {
        pooled.setFrame(frame, display: false)
        pooled.overlayID = id
        return pooled
    }
    
    // Create new if pool is empty
    return DimOverlayWindow.create(frame: frame, dimLevel: dimLevel, id: id)
}
```

---

### 3. **Pause Timers When Idle** ⭐⭐

**Impact:** Could save 10-20 MB + reduce CPU usage

**Implementation:**
```swift
// In DimmingCoordinator.swift
private func handleUserIdleStateChanged(_ isIdle: Bool) {
    if isIdle {
        // Pause heavy operations when user is idle
        analysisTimer?.invalidate()
        analysisTimer = nil
        
        // Keep window tracking at reduced frequency
        windowTrackingTimer?.invalidate()
        windowTrackingTimer = Timer.scheduledTimer(
            withTimeInterval: 2.0,  // Slower when idle
            repeats: true
        ) { [weak self] _ in
            self?.performWindowTracking()
        }
    } else {
        // Resume normal operation
        startAnalysisTimer()
        startWindowTrackingTimer()
    }
}
```

---

### 4. **Reuse Pixel Buffers** ⭐

**Impact:** Could save 5-10 MB

**Implementation:**
```swift
// In BrightnessAnalysisEngine.swift
private var pixelBufferCache: [UInt8]?
private let maxBufferSize = 80 * 80 * 4

private func getPixelBrightnessData(from image: CGImage, targetSize: Int) -> PixelBrightnessData? {
    let bufferSize = targetSize * targetSize * 4
    
    // Reuse buffer if same size
    if pixelBufferCache == nil || pixelBufferCache!.count != bufferSize {
        pixelBufferCache = [UInt8](repeating: 0, count: bufferSize)
    }
    
    guard let context = CGContext(
        data: &pixelBufferCache!,
        width: targetSize,
        height: targetSize,
        ...
    ) else { return nil }
    
    // ... rest of function
}
```

---

### 5. **Reduce Capture Frequency When Stable** ⭐

**Impact:** Could save 10-20 MB + reduce CPU

**Implementation:**
```swift
// In DimmingCoordinator.swift
private var consecutiveUnchangedCycles = 0
private var lastBrightnessResults: [CGWindowID: Float] = [:]

func performAnalysisCycle() {
    let results = analyzeAllWindows()
    
    // Check if brightness changed significantly
    var hasSignificantChange = false
    for (windowID, brightness) in results {
        if let last = lastBrightnessResults[windowID] {
            if abs(brightness - last) > 0.05 {  // 5% change threshold
                hasSignificantChange = true
                break
            }
        }
    }
    
    if hasSignificantChange {
        consecutiveUnchangedCycles = 0
        // Keep normal frequency
    } else {
        consecutiveUnchangedCycles += 1
        
        // After 5 stable cycles, reduce frequency
        if consecutiveUnchangedCycles >= 5 {
            analysisTimer?.invalidate()
            analysisTimer = Timer.scheduledTimer(
                withTimeInterval: 5.0,  // Slower when stable
                repeats: true
            ) { [weak self] _ in
                self?.performAnalysisCycle()
            }
        }
    }
    
    lastBrightnessResults = results
}
```

---

## Expected Results After Optimization

| Optimization | Current | After | Savings |
|-------------|---------|-------|---------|
| Autoreleasepool for captures | 298 MB | 248 MB | 50 MB |
| Overlay pool (max 20) | 248 MB | 218 MB | 30 MB |
| Pause timers when idle | 218 MB | 203 MB | 15 MB |
| Reuse pixel buffers | 203 MB | 198 MB | 5 MB |
| Adaptive capture frequency | 198 MB | 188 MB | 10 MB |
| **TOTAL** | **298 MB** | **~190 MB** | **~110 MB** |

**Target:** Under 200 MB (36% reduction)

---

## Monitoring & Validation

### Add Memory Logging

```swift
// In DimmingCoordinator.swift
func performAnalysisCycle() {
    let memoryBefore = getMemoryUsage()
    
    autoreleasepool {
        // ... analysis code
    }
    
    let memoryAfter = getMemoryUsage()
    let delta = memoryAfter - memoryBefore
    
    if delta > 10_000_000 {  // 10 MB increase
        print("⚠️ Memory increased by \(delta / 1_000_000) MB during analysis")
    }
}

private func getMemoryUsage() -> UInt64 {
    var info = mach_task_basic_info()
    var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
    
    let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
        $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
            task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
        }
    }
    
    return kerr == KERN_SUCCESS ? info.resident_size : 0
}
```

---

## Additional Notes

### Why 298 MB is High

For comparison, similar menu bar utilities:
- **Monitor Control:** ~50-80 MB
- **Bartender:** ~60-100 MB  
- **Alfred:** ~80-120 MB
- **Rectangle:** ~40-60 MB

SuperDimmer is 3-5× higher than comparable apps.

### Why We Can't Just "Fix" Screen Capture

The macOS API `CGWindowListCreateImage` doesn't support capturing at reduced resolution. We MUST capture at full resolution, then downsample. This is a fundamental limitation.

However, we can ensure the full-resolution image is released IMMEDIATELY after downsampling.

### Why Overlays Aren't Closed

Previous attempts to call `NSWindow.close()` on overlays caused `EXC_BAD_ACCESS` crashes in Core Animation. The current strategy of hiding without closing is safer, but leads to accumulation. The overlay pool approach balances safety and memory usage.

---

## Implementation Plan

1. **Phase 1 (Immediate):** Autoreleasepool + Memory logging
2. **Phase 2 (Next):** Overlay pool implementation  
3. **Phase 3 (Soon):** Idle detection and timer pausing
4. **Phase 4 (Later):** Buffer reuse and adaptive frequency

Each phase should be tested independently to verify memory reduction without introducing crashes or bugs.
