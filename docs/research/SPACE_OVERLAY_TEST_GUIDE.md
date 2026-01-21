# Space Overlay Test Guide
## How to Test Space-Specific Overlay Feasibility

**Date:** January 21, 2026  
**Purpose:** Validate that removing `canJoinAllSpaces` successfully pins overlays to individual Spaces

---

## Quick Start

### Option 1: Add Test Button to Menu Bar (Easiest)

1. **Add test file to Xcode:**
   - File > Add Files to "SuperDimmer"
   - Select `SpaceOverlayTest.swift`
   - Make sure it's added to the SuperDimmer target

2. **Add test button to MenuBarView.swift:**

```swift
// In MenuBarView.swift, add to the menu:

Button("🧪 Test Space Overlays") {
    SpaceOverlayTest.shared.runTest()
}
```

3. **Build and run the app**

4. **Click the test button in menu bar**

5. **Follow the on-screen instructions**

---

### Option 2: Call from App Launch (Quick Test)

Add this to `AppDelegate.swift` or `SuperDimmerApp.swift`:

```swift
// In applicationDidFinishLaunching or app init:

// Wait a moment for app to fully launch
DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
    SpaceOverlayTest.shared.runTest()
}
```

---

## Test Procedure

### Prerequisites

1. **You need at least 4 Spaces (virtual desktops)**
   - Open Mission Control (F3 or swipe up with 3 fingers)
   - Click the "+" button in top-right to add Spaces
   - Create at least 4 Spaces total

2. **Make sure you can switch between Spaces**
   - Swipe left/right with 3 fingers on trackpad
   - OR use Ctrl+→ and Ctrl+← on keyboard
   - OR use Mission Control to click between Spaces

### Step-by-Step Test

**1. Start the Test**
- Click "🧪 Test Space Overlays" in menu bar
- OR run the app if you added auto-launch code
- Read the instructions dialog

**2. Register Space 1**
- Make sure you're on Space 1 (your first desktop)
- Click "Register This Space"
- You should see a **blue tinted overlay** appear
- The overlay should have text: "Space 1 - Test Overlay"

**3. Register Space 2**
- Switch to Space 2 (swipe right or Ctrl+→)
- The dialog will prompt you to register Space 2
- Click "Register This Space"
- You should see a **green tinted overlay** appear
- The blue overlay should NOT be visible on Space 2

**4. Register Space 3**
- Switch to Space 3
- Click "Register This Space"
- You should see a **purple tinted overlay** appear
- Blue and green overlays should NOT be visible

**5. Register Space 4**
- Switch to Space 4
- Click "Register This Space"
- You should see an **orange tinted overlay** appear
- Other overlays should NOT be visible

**6. Verify the Results**
- Now switch between all 4 Spaces multiple times
- Check what you see on each Space

---

## Expected Results

### ✅ TEST PASSED (Success!)

**What you should see:**

| Space | Overlay Color | Text Label |
|-------|--------------|------------|
| Space 1 | Blue tint (15% alpha) | "Space 1 - Test Overlay" |
| Space 2 | Green tint (15% alpha) | "Space 2 - Test Overlay" |
| Space 3 | Purple tint (15% alpha) | "Space 3 - Test Overlay" |
| Space 4 | Orange tint (15% alpha) | "Space 4 - Test Overlay" |

**Key indicators:**
- Each Space shows ONLY its own colored overlay
- Switching Spaces shows different colors
- No Space shows multiple overlays
- Overlays don't "follow" you between Spaces

**What this means:**
- ✅ Removing `canJoinAllSpaces` successfully pins windows to Spaces
- ✅ We can create Space-specific overlays
- ✅ The feature is feasible to implement
- ✅ Ready to build the full feature!

---

### ❌ TEST FAILED (Problem)

**What you might see:**

**Scenario A: All overlays appear on all Spaces**
- Every Space shows blue + green + purple + orange overlays stacked
- All 4 colors visible at once on every Space

**Problem:** `canJoinAllSpaces` was not properly removed
**Solution:** Check `TestSpaceOverlay.configure()` - make sure `.canJoinAllSpaces` is NOT in the array

**Scenario B: No overlays appear**
- Overlays are created but not visible

**Problem:** Window level or opacity issue
**Solution:** Check:
- `self.level` is set correctly
- `self.isOpaque = false` is set
- `backgroundColor` has alpha > 0

**Scenario C: Overlays appear but all on Space 1**
- All 4 overlays created on the first Space only

**Problem:** Window creation happens before Space switch
**Solution:** Make sure you're actually switching Spaces between registrations

---

## Troubleshooting

### Problem: Can't see overlays at all

**Check:**
1. Are overlays actually created?
   - Look for console logs: "🎨 Created [Color] overlay for Space X"
   
2. Is window level correct?
   ```swift
   // Try different levels:
   self.level = .normal  // Try this first
   self.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopWindow)) + 1)
   ```

3. Is opacity visible?
   ```swift
   // Make it more obvious for testing:
   view.layer?.backgroundColor = color.withAlphaComponent(0.5).cgColor  // 50% instead of 15%
   ```

### Problem: Overlays appear on all Spaces

**Check:**
1. Is `canJoinAllSpaces` actually removed?
   ```swift
   // In TestSpaceOverlay.configure()
   print("Collection behavior: \(self.collectionBehavior)")
   // Should NOT include .canJoinAllSpaces
   ```

2. Try explicitly setting to default:
   ```swift
   self.collectionBehavior = .default  // Most restrictive
   ```

### Problem: Can't switch between Spaces

**Solutions:**
1. Enable Mission Control:
   - System Settings > Desktop & Dock
   - Make sure "Displays have separate Spaces" is checked (if using multiple monitors)

2. Enable keyboard shortcuts:
   - System Settings > Keyboard > Keyboard Shortcuts > Mission Control
   - Enable "Move left a space" and "Move right a space"

3. Use trackpad gestures:
   - System Settings > Trackpad > More Gestures
   - Enable "Swipe between full-screen applications"

---

## Cleanup

### Remove Test Overlays

**Option 1: Use Cleanup Button**
- Click "Cleanup Test" in the test dialog
- OR add a cleanup button to menu bar:
  ```swift
  Button("🧹 Cleanup Test") {
      SpaceOverlayTest.shared.cleanupTest()
  }
  ```

**Option 2: Restart App**
- Test overlays are not persisted
- Quitting and relaunching the app removes them

**Option 3: Manual Cleanup**
- Open Activity Monitor
- Find "SuperDimmer" process
- Force quit and relaunch

---

## What to Log

### Console Output to Watch For

**Successful test should show:**
```
============================================================
🧪 SPACE OVERLAY TEST - Starting
============================================================
🔧 Configured overlay for Space 1 - canJoinAllSpaces: REMOVED
🎨 Created Blue overlay for Space 1
✅ Registered Space 1 with Blue overlay
🔧 Configured overlay for Space 2 - canJoinAllSpaces: REMOVED
🎨 Created Green overlay for Space 2
✅ Registered Space 2 with Green overlay
🔧 Configured overlay for Space 3 - canJoinAllSpaces: REMOVED
🎨 Created Purple overlay for Space 3
✅ Registered Space 3 with Purple overlay
🔧 Configured overlay for Space 4 - canJoinAllSpaces: REMOVED
🎨 Created Orange overlay for Space 4
✅ Registered Space 4 with Orange overlay
============================================================
🧪 TEST COMPLETE - Switch between Spaces to verify
============================================================
```

---

## Next Steps After Test

### If Test PASSED ✅

1. **Document results:**
   - Take screenshots of each Space showing its unique overlay
   - Note any observations or edge cases
   - Confirm macOS version tested

2. **Plan full implementation:**
   - Use `SpaceOverlayTest.swift` as reference
   - Create production `SpaceIdentificationManager`
   - Design user-facing UI
   - Add to PRD as confirmed feature

3. **Consider enhancements:**
   - More subtle colors (3-5% alpha instead of 15%)
   - User-customizable themes
   - Persistence across app restarts
   - Auto-detection of number of Spaces

### If Test FAILED ❌

1. **Debug the issue:**
   - Check console logs for errors
   - Verify `canJoinAllSpaces` is removed
   - Test with different window levels
   - Try on different macOS versions

2. **Try alternative approaches:**
   - Helper app per Space (more complex)
   - Different collection behavior combinations
   - Private APIs (research only, not for production)

3. **Report findings:**
   - Document what didn't work
   - Note macOS version and hardware
   - Consider filing feedback with Apple

---

## Technical Notes

### Why This Test Works

**The key mechanism:**
```swift
// Default overlay behavior (appears on ALL Spaces):
self.collectionBehavior = [.canJoinAllSpaces, ...]

// Space-specific overlay (stays on ONE Space):
self.collectionBehavior = [/* .canJoinAllSpaces NOT included */]
```

**When you create a window:**
1. It's created on the **currently active Space**
2. If `canJoinAllSpaces` is set, it appears on all Spaces
3. If `canJoinAllSpaces` is NOT set, it stays on the creation Space

**This test validates:**
- We can create windows without `canJoinAllSpaces`
- Those windows stay on their creation Space
- We can create different windows on different Spaces
- Switching Spaces shows different windows

### macOS Versions

**Tested on:**
- macOS 13 (Ventura) - TBD
- macOS 14 (Sonoma) - TBD
- macOS 15 (Sequoia) - TBD

**Expected compatibility:**
- Should work on macOS 10.15+ (Catalina and later)
- `NSWindowCollectionBehavior` is a stable API
- No private APIs used

---

## FAQ

**Q: Do I need to test with exactly 4 Spaces?**
A: No, you can test with 2-16 Spaces. The test creates 4 overlays, but you can modify the code to test more or fewer.

**Q: Will this work with multiple monitors?**
A: Yes, but each monitor has its own set of Spaces. Test on your primary monitor first.

**Q: Can I change the overlay colors?**
A: Yes! Edit the `testColors` array in `SpaceOverlayTest.swift`:
```swift
private let testColors: [NSColor] = [
    NSColor.systemRed.withAlphaComponent(0.15),  // Change colors here
    NSColor.systemYellow.withAlphaComponent(0.15),
    // ... etc
]
```

**Q: The overlays are too obvious, can I make them more subtle?**
A: Yes! Change the alpha value:
```swift
NSColor.systemBlue.withAlphaComponent(0.05)  // 5% instead of 15%
```

**Q: Can I test this without building the whole app?**
A: Not easily. You need the app running to create NSWindows. But the test is self-contained and doesn't depend on other SuperDimmer features.

---

## Success Criteria

✅ **Test is successful if:**
- Each Space shows its unique colored overlay
- Overlays don't appear on other Spaces
- Switching Spaces reliably shows different overlays
- No crashes or errors
- Console logs show successful creation

❌ **Test fails if:**
- All overlays appear on all Spaces
- Overlays don't appear at all
- Overlays appear but on wrong Spaces
- Crashes or errors occur
- Inconsistent behavior when switching

---

## Reporting Results

**Please document:**
1. macOS version: _____________
2. Number of Spaces tested: _____________
3. Test result: ✅ PASSED / ❌ FAILED
4. Observations: _____________
5. Screenshots: (attach if possible)
6. Console logs: (copy relevant sections)

**Share findings in:**
- Project documentation
- GitHub issue/PR
- Team chat/email
- Research notes

---

*Test created: January 21, 2026*  
*Purpose: Validate Space-specific overlay feasibility*  
*Status: Ready to run*
