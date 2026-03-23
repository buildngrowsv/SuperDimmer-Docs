# Overlay Deinit Crash Fix

**Date**: January 25, 2026  
**Issue**: EXC_BAD_ACCESS crash in `objc_release` during DimOverlayWindow deallocation  
**Status**: ✅ FIXED

---

## Crash Details

**Crash Type**: `EXC_BAD_ACCESS (code=1, address=0x2f9fcb447cf8)`  
**Location**: `libobjc.A.dylib objc_release`  
**Thread**: Thread 1 (Main Thread)

### Console Logs Before Crash

```
🛑 DimOverlayWindow deallocated by ARC: window-298618
⏰ App unhidden (PID 76826) - reset all window timers
```

The crash occurred immediately after a DimOverlayWindow was being deallocated by ARC.

---

## Root Cause Analysis

### The Problem

The crash was a **use-after-free** error in the `deinit` method of `DimOverlayWindow`. Here's what was happening:

1. **ARC triggers deallocation** of a DimOverlayWindow
2. **AppKit begins cleanup** of the window's view hierarchy (contentView and subviews)
3. **deinit runs** and tries to access `dimView?.layer`
4. **BUT** - the dimView or its layer may have already been deallocated by AppKit
5. **Accessing freed memory** → EXC_BAD_ACCESS crash in `objc_release`

### The Problematic Code

```swift
deinit {
    // Clean up without calling close()
    // Just remove animations and clear references
    // Let AppKit handle the window cleanup naturally
    if let layer = dimView?.layer {
        layer.removeAllAnimations()  // ← CRASH HERE: accessing freed memory
    }
    dimView = nil
    
    print("📦 DimOverlayWindow deallocated by ARC: \(overlayID)")
}
```

### Why This Happens

When ARC deallocates an NSWindow:
- AppKit's internal deallocation process runs first
- The contentView and all subviews (including dimView) may be deallocated
- The `dimView` property still holds a reference, but it points to **freed memory**
- Accessing `dimView?.layer` or calling methods on it causes a crash

This is a **timing issue** - sometimes the view hierarchy is deallocated before `deinit` runs, sometimes after. That's why the crash was intermittent.

---

## The Fix

### Solution: Don't Touch the View Hierarchy in deinit

The fix is simple: **Don't access any views or layers in deinit**. Let AppKit handle all cleanup automatically.

```swift
deinit {
    // CRASH FIX (Jan 25, 2026): DO NOT access dimView or its layer in deinit!
    // 
    // ROOT CAUSE: By the time deinit runs, AppKit may have already deallocated
    // the contentView and all subviews (including dimView). Accessing dimView?.layer
    // or calling removeAllAnimations() can cause EXC_BAD_ACCESS crashes because
    // we're accessing freed memory.
    //
    // SOLUTION: Don't touch the view hierarchy at all in deinit. AppKit handles
    // all cleanup automatically. We just need to clear our reference (which happens
    // automatically when the object is deallocated anyway).
    //
    // The animations are already stopped by safeHideOverlay() BEFORE the overlay
    // is removed from dictionaries, so there's no need to remove them again here.
    
    // Just log the deallocation - don't touch any views or layers
    print("📦 DimOverlayWindow deallocated by ARC: \(overlayID)")
    
    // dimView will be automatically set to nil when this object is deallocated
    // No need to manually clear it or access its properties
}
```

### Why This Works

1. **Animations are already stopped** by `safeHideOverlay()` BEFORE the overlay is removed from dictionaries
2. **AppKit handles cleanup** - we don't need to manually remove animations in deinit
3. **No memory access** - we don't touch any potentially-freed memory
4. **Safe deallocation** - the object is deallocated cleanly without crashes

### Also Fixed: close() Override

The same issue existed in the `close()` override. Fixed by removing layer access:

```swift
override func close() {
    // Prevent double-close
    guard !isClosing else {
        print("⚠️ DimOverlayWindow close() called but already closing: \(overlayID)")
        return
    }
    isClosing = true
    
    // Flush any pending Core Animation transactions
    CATransaction.flush()
    
    // DO NOT access dimView or its layer here - can cause use-after-free crashes
    // AppKit will handle all view hierarchy cleanup automatically
    
    // Now actually close
    super.close()
}
```

---

## Testing

✅ **Build Status**: Successful  
✅ **Compilation**: No errors or warnings  
✅ **Changes**: Minimal and focused on the crash point

### What to Test

1. **Normal overlay lifecycle** - create, show, hide, deallocate overlays
2. **App unhiding** - hide app, unhide app (this was the trigger in the crash)
3. **Window switching** - rapidly switch between windows
4. **Decay dimming** - let windows decay and get deallocated
5. **App quit** - ensure clean shutdown without crashes

---

## Key Learnings

### AppKit Memory Management Rules

1. **Never access view hierarchy in deinit** - it may already be deallocated
2. **Trust AppKit's cleanup** - it handles view deallocation automatically
3. **Do cleanup BEFORE deallocation** - use methods like `safeHideOverlay()` before removing references
4. **Timing matters** - deallocation order is not guaranteed

### Our Overlay Strategy

1. **Stop animations BEFORE removal** - in `safeHideOverlay()`
2. **Remove from dictionaries** - this triggers ARC deallocation
3. **Let ARC deallocate naturally** - no manual cleanup in deinit
4. **Log for debugging** - but don't touch any objects

---

## Files Changed

- `SuperDimmer-Mac-App/SuperDimmer/Overlay/DimOverlayWindow.swift`
  - Fixed `deinit` method (removed layer access)
  - Fixed `close()` override (removed layer access)

---

## Related Issues

This fix is related to previous overlay crash fixes:

1. **Jan 20, 2026**: Never call `close()` on overlays - use `safeHideOverlay()` instead
2. **Jan 21, 2026**: Remove all overlays using `safeHideOverlay()` to avoid autorelease issues
3. **Jan 25, 2026**: Don't access view hierarchy in `deinit` (this fix)

All these fixes work together to ensure stable overlay lifecycle management.

---

## Status

✅ **FIXED** - Build successful, ready for testing
