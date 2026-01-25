# Memory Fix Implementation Plan

## Quick Win: Autoreleasepool Wrapping

The biggest issue is that screen captures are creating large CGImage objects that aren't being released immediately. Each capture can be 50-100 MB for a 6K display.

### Current Problem (Line 830-833 in DimmingCoordinator.swift)

```swift
// Capture window content
guard let windowImage = screenCapture.captureWindow(window.id) else {
    debugLog("⚠️ Could not capture window \(window.id) (\(window.ownerName))")
    continue
}

// Detect bright regions within this window
var brightRegions = regionDetector.detectBrightRegions(
    in: windowImage,  // windowImage is still in memory here
    threshold: threshold,
    gridSize: gridSize,
    minRegionSize: 4
)
```

The `windowImage` CGImage stays in memory until the autorelease pool drains (which might be at the end of the run loop, not immediately).

### Solution: Wrap Each Window Analysis in Autoreleasepool

```swift
// Cache miss - need to capture and analyze
cacheMisses += 1

// MEMORY FIX: Wrap capture and analysis in autoreleasepool
// This ensures windowImage is released immediately after analysis
autoreleasepool {
    // Capture window content
    guard let windowImage = screenCapture.captureWindow(window.id) else {
        debugLog("⚠️ Could not capture window \(window.id) (\(window.ownerName))")
        return  // Early return from autoreleasepool
    }
    
    // Detect bright regions within this window
    var brightRegions = regionDetector.detectBrightRegions(
        in: windowImage,
        threshold: threshold,
        gridSize: gridSize,
        minRegionSize: 4
    )
    
    // Filter out regions that are too small in pixel terms
    brightRegions = regionDetector.filterByMinimumSize(brightRegions, windowBounds: window.bounds)
    
    // Cache the results for next cycle
    analysisCache[window.id] = CachedAnalysis(
        regions: brightRegions,
        boundsHash: window.bounds.hashValue,
        wasFrontmost: isFrontmost,
        timestamp: Date(),
        ownerPID: window.ownerPID,
        windowName: window.ownerName
    )
    
    debugLog("🎯 Window '\(window.ownerName)': found \(brightRegions.count) bright regions (fresh analysis)")
    
    // Create decisions for each bright region
    for region in brightRegions {
        let regionRect = region.rect(in: window.bounds)
        let dimLevel = calculateRegionDimLevel(
            brightness: region.brightness,
            threshold: threshold,
            isActiveWindow: window.isActive
        )
        
        let decision = RegionDimmingDecision(
            windowID: window.id,
            windowName: window.ownerName,
            ownerPID: window.ownerPID,
            isFrontmostWindow: window.isActive,
            regionRect: regionRect,
            brightness: region.brightness,
            dimLevel: dimLevel,
            windowBounds: window.bounds
        )
        allRegionDecisions.append(decision)
    }
} // windowImage and all intermediate CGImages are released HERE
```

## Additional Quick Fixes

### 1. Wrap Full-Screen Capture in Autoreleasepool

In `performSimpleAnalysis()` around line 600:

```swift
// MEMORY FIX: Wrap capture in autoreleasepool
let brightness: Float? = autoreleasepool {
    guard let screenImage = screenCapture.captureMainDisplayForBrightnessAnalysis() else {
        return nil
    }
    return brightnessEngine.averageLuminance(of: screenImage)
} // screenImage released here

guard let brightness = brightness else {
    debugLog("⚠️ Could not capture or analyze screen")
    return
}
```

### 2. Wrap Per-Window Capture in Autoreleasepool

In `performPerWindowAnalysis()` around line 680:

```swift
for window in windows {
    // MEMORY FIX: Wrap each window's capture in autoreleasepool
    let brightness: Float? = autoreleasepool {
        guard let windowImage = screenCapture.captureWindow(window.id) else {
            return nil
        }
        return brightnessEngine.averageLuminance(of: windowImage)
    } // windowImage released here
    
    guard let brightness = brightness else {
        debugLog("⚠️ Could not capture window \(window.id)")
        continue
    }
    
    // Rest of analysis...
}
```

### 3. Add Memory Monitoring

Add this helper function to DimmingCoordinator:

```swift
// MARK: - Memory Monitoring

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

private func logMemoryUsage(label: String) {
    let usage = getMemoryUsage()
    let usageMB = Double(usage) / 1_000_000.0
    print("💾 Memory [\(label)]: \(String(format: "%.1f", usageMB)) MB")
}
```

Then add logging in `performAnalysisCycle()`:

```swift
func performAnalysisCycle() {
    logMemoryUsage(label: "Before Analysis")
    
    // ... existing analysis code ...
    
    logMemoryUsage(label: "After Analysis")
}
```

## Expected Impact

| Fix | Memory Saved | Difficulty |
|-----|-------------|-----------|
| Autoreleasepool in PerRegion | 50-80 MB | Easy |
| Autoreleasepool in PerWindow | 20-30 MB | Easy |
| Autoreleasepool in Simple | 10-20 MB | Easy |
| Memory monitoring | 0 MB (diagnostic) | Easy |
| **TOTAL** | **80-130 MB** | **1-2 hours** |

## Testing Plan

1. Build with memory logging enabled
2. Run app and watch console for memory readings
3. Switch between different modes (Simple, PerWindow, PerRegion)
4. Verify memory drops after each analysis cycle
5. Check Activity Monitor to confirm overall reduction

## Implementation Order

1. ✅ Add memory monitoring functions
2. ✅ Add autoreleasepool to PerRegion analysis (biggest impact)
3. ✅ Add autoreleasepool to PerWindow analysis
4. ✅ Add autoreleasepool to Simple analysis
5. ✅ Test and verify memory reduction
6. ✅ Commit changes

## Code Locations

- **DimmingCoordinator.swift**
  - Line ~600: `performSimpleAnalysis()`
  - Line ~680: `performPerWindowAnalysis()`
  - Line ~830: `performPerRegionAnalysis()`

All changes are in one file, making this a quick and safe fix.
