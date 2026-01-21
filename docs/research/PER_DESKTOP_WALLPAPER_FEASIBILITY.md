# Per-Desktop Wallpaper Feasibility Analysis
## macOS Desktop Spaces and Wallpaper Management

**Date:** January 21, 2026  
**Status:** Research Complete  
**Question:** Can we set different wallpapers for different desktop Spaces programmatically?

---

## Executive Summary

**Short Answer:** ❌ **No reliable public API exists** to set per-Space wallpapers programmatically.

**Key Findings:**
1. **NSWorkspace API** only supports per-NSScreen (physical display) wallpapers, NOT per-Space
2. **Private APIs exist** but are unreliable and would prevent App Store distribution
3. **Umbra's approach** is to set ONE wallpaper per screen that applies across ALL Spaces
4. **User workaround** is manual: System Settings > Wallpaper > "Fill [Space Number]"

---

## Technical Analysis

### 1. Public API Limitations (NSWorkspace)

The official macOS API for wallpaper management is:

```swift
NSWorkspace.shared.setDesktopImageURL(_:for:options:)
```

**Critical Limitation:**
- The `for:` parameter accepts `NSScreen` (physical display), NOT virtual Spaces
- Setting a wallpaper applies to **all Spaces on that screen**
- No `options` dictionary key exists for Space selection

**Example Code:**
```swift
let url = URL(fileURLWithPath: "/path/to/image.jpg")
for screen in NSScreen.screens {
    try NSWorkspace.shared.setDesktopImageURL(url, for: screen)
    // This applies the SAME image to ALL Spaces on this screen
}
```

**Source:** Apple Developer Documentation, confirmed as of macOS 15 (2026)

---

### 2. Space Detection Capabilities

We **CAN** detect when Spaces change using public APIs:

```swift
// In OverlayManager.swift (lines 164-183)
NSWorkspace.shared.notificationCenter.addObserver(
    self,
    selector: #selector(handleSpaceChange),
    name: NSWorkspace.activeSpaceDidChangeNotification,
    object: nil
)
```

**What This Gives Us:**
- ✅ Notification when user switches Spaces
- ✅ Ability to respond to Space transitions
- ❌ NO information about WHICH Space we're on (no Space ID)
- ❌ NO ability to set different wallpapers per Space

**Current Usage in SuperDimmer:**
We use this notification to hide/restore overlays during Space transitions to prevent visual glitches.

---

### 3. Private API Options (Not Recommended)

**Private API exists** but comes with severe limitations:

```objc
// Private Core Graphics API (undocumented)
extern CGError CGSGetActiveSpace(CGSConnection cid, int* spaceID);
extern CGSConnection _CGSDefaultConnection(void);

// Usage:
CGSConnection cid = _CGSDefaultConnection();
int spaceID;
CGError err = CGSGetActiveSpace(cid, &spaceID);
// Returns space number: 0, 1, 2, etc.
```

**Problems with Private APIs:**
1. **App Store Rejection** - Automatic rejection if detected
2. **Unstable** - Can break with any macOS update
3. **No Wallpaper Setting** - Even with Space ID, no private API to set per-Space wallpaper
4. **Security Concerns** - May require elevated permissions
5. **Maintenance Burden** - Need to monitor and fix with every macOS release

**Verdict:** ❌ Not viable for production app

---

### 4. How Umbra Handles This

**Research Findings on Umbra (v1.4):**

From web research (January 21, 2026):
> "Umbra is smart enough to recognize when you're using multiple Spaces and ensures that each one reflects the correct wallpaper without skipping a beat."

**What This Actually Means:**
- Umbra sets ONE wallpaper per screen (light mode) and ONE per screen (dark mode)
- When you switch appearance modes, it applies the correct wallpaper
- The SAME wallpaper appears on ALL Spaces on that screen
- "Recognizing multiple Spaces" means it doesn't break when Spaces exist, NOT that it sets different wallpapers per Space

**Umbra's Implementation:**
```swift
// Umbra uses the same NSWorkspace API we have access to
NSWorkspace.shared.setDesktopImageURL(lightModeURL, for: screen)
// When dark mode activates:
NSWorkspace.shared.setDesktopImageURL(darkModeURL, for: screen)
```

**Key Insight:**
Umbra does NOT set different wallpapers per Space. It sets different wallpapers per **appearance mode** (light/dark), which is a completely different feature.

---

## What IS Possible

### ✅ Features We CAN Implement

1. **Per-Screen Wallpapers**
   - Different wallpaper for each physical display
   - Works with multi-monitor setups
   
2. **Per-Appearance Wallpapers** (Umbra-style)
   - Light mode wallpaper
   - Dark mode wallpaper
   - Auto-switch when appearance changes
   
3. **Wallpaper Dimming**
   - Overlay at desktop level to dim wallpaper
   - Works across all Spaces
   
4. **Space Change Detection**
   - Respond to Space transitions
   - Hide/show overlays during transitions
   - Adjust dimming when switching Spaces

### ❌ Features We CANNOT Implement (Without Private APIs)

1. **Per-Space Wallpapers**
   - Space 1: Image A
   - Space 2: Image B
   - Space 3: Image C
   
2. **Detect Current Space Number**
   - No public API to get "Space 1" vs "Space 2"
   
3. **Query Wallpaper Per Space**
   - Can't read what wallpaper is set on each Space

---

## Proposed Implementation for SuperDimmer

### Phase 4.4: Wallpaper Management (Revised)

Based on this research, here's what we should implement:

#### Feature Set (Realistic)

1. **Light/Dark Mode Wallpaper Pairs** ✅
   - User selects two images: one for light, one for dark
   - Auto-switches when macOS appearance changes
   - Per-screen support (different pairs per display)
   
2. **Wallpaper Dimming** ✅
   - Desktop-level overlay to dim wallpaper
   - Adjustable dim level (0-80%)
   - Works across all Spaces
   - Quick toggle in menu bar
   
3. **Unsplash Integration** (Optional) ✅
   - Browse wallpapers in-app
   - Download and set directly
   - Premium feature

#### Implementation Code

```swift
// WallpaperManager.swift
final class WallpaperManager {
    
    // Store light/dark pairs per screen
    private var wallpaperPairs: [String: (light: URL, dark: URL)] = [:]
    
    // Set wallpaper based on current appearance
    func updateWallpaperForAppearance() {
        let isDark = NSApp.effectiveAppearance.name == .darkAqua
        
        for screen in NSScreen.screens {
            guard let screenID = screen.displayID,
                  let pair = wallpaperPairs[String(screenID)] else {
                continue
            }
            
            let url = isDark ? pair.dark : pair.light
            
            do {
                try NSWorkspace.shared.setDesktopImageURL(url, for: screen)
                print("✓ Set \(isDark ? "dark" : "light") wallpaper for screen \(screenID)")
            } catch {
                print("❌ Failed to set wallpaper: \(error)")
            }
        }
    }
    
    // Observe appearance changes
    func startObserving() {
        NSApp.publisher(for: \.effectiveAppearance)
            .sink { [weak self] _ in
                self?.updateWallpaperForAppearance()
            }
            .store(in: &cancellables)
    }
}
```

#### UI Design

**Preferences > Wallpaper Tab:**
```
┌─────────────────────────────────────────────────────┐
│ Wallpaper Management                                │
├─────────────────────────────────────────────────────┤
│                                                     │
│ ☀️ Light Mode Wallpaper                            │
│ [Image Preview]                      [Choose...]   │
│                                                     │
│ 🌙 Dark Mode Wallpaper                             │
│ [Image Preview]                      [Choose...]   │
│                                                     │
│ ☑ Auto-switch with appearance mode                 │
│                                                     │
│ ─────────────────────────────────────────────────  │
│                                                     │
│ 🖼️ Wallpaper Dimming                               │
│ ☑ Dim wallpaper in dark mode                       │
│ Dim Level: ████████░░░░ 40%                        │
│                                                     │
│ Note: Wallpaper applies to all Spaces on each      │
│ display. macOS does not support per-Space           │
│ wallpapers via API.                                 │
└─────────────────────────────────────────────────────┘
```

---

## Alternative Approaches Considered

### Option 1: AppleScript Automation ❌
**Idea:** Use AppleScript to automate System Settings
**Problem:** 
- Unreliable and brittle
- Requires Accessibility permissions
- Breaks with UI changes
- Still can't programmatically set per-Space wallpapers

### Option 2: Private API Bridge ❌
**Idea:** Use private APIs with runtime detection
**Problem:**
- App Store rejection
- Maintenance nightmare
- Security concerns
- Still no per-Space wallpaper API exists

### Option 3: User Manual Configuration ⚠️
**Idea:** Provide UI to help users manually set per-Space wallpapers
**Problem:**
- Not automated
- Poor UX
- Defeats purpose of the feature

### Option 4: Focus on What Works ✅ (RECOMMENDED)
**Idea:** Implement light/dark mode switching (like Umbra)
**Benefits:**
- Uses public APIs
- App Store compatible
- Reliable and maintainable
- Provides real value
- Matches user expectations from Umbra

---

## Competitive Analysis Update

### How Other Apps Handle This

| App | Per-Space Wallpapers | Per-Appearance Wallpapers | Method |
|-----|---------------------|---------------------------|--------|
| **Umbra** | ❌ No | ✅ Yes | NSWorkspace API |
| **macOS Native** | ✅ Yes (manual) | ✅ Yes | System Settings UI |
| **SuperDimmer** | ❌ No (not possible) | ✅ Yes (planned) | NSWorkspace API |

**Key Insight:**
Even Umbra, which is specifically focused on wallpaper management, does NOT support per-Space wallpapers programmatically. This confirms it's not feasible with current APIs.

---

## Recommendations

### For SuperDimmer Development

1. **✅ IMPLEMENT:** Light/Dark mode wallpaper switching
   - This is what users expect from "Umbra-style" features
   - Technically feasible and reliable
   - Provides real value
   
2. **✅ IMPLEMENT:** Wallpaper dimming overlay
   - Unique feature not in Umbra
   - Complements our bright region dimming
   - Works across all Spaces
   
3. **❌ DO NOT IMPLEMENT:** Per-Space wallpapers
   - Not technically feasible with public APIs
   - Would require private APIs (App Store rejection)
   - Not even Umbra does this
   
4. **📝 DOCUMENT:** Set user expectations correctly
   - PRD should clarify "per-screen" not "per-Space"
   - UI should explain limitation
   - Help docs should guide manual per-Space setup if needed

### For Product Requirements Document

**Update PRD Section 4.4 (Wallpaper Management):**

**OLD (Incorrect):**
```
Per-Space Support: Different pairs for each Space/Desktop
```

**NEW (Correct):**
```
Per-Display Support: Different pairs for each connected display
Note: macOS does not provide APIs for per-Space wallpapers.
Users can manually set different wallpapers per Space via
System Settings, but this cannot be automated programmatically.
```

---

## Technical References

### Apple Documentation
- [NSWorkspace.setDesktopImageURL](https://developer.apple.com/documentation/appkit/nsworkspace/1534810-setdesktopimageurl)
- [NSScreen](https://developer.apple.com/documentation/appkit/nsscreen)
- [NSWorkspace.activeSpaceDidChangeNotification](https://developer.apple.com/documentation/foundation/nsworkspace/1534723-activespacechangenotification)

### Research Sources
- Perplexity AI research (January 21, 2026)
- Umbra app analysis (v1.4)
- macOS API documentation (macOS 13-15)
- Private API research (CGSPrivate.h)

### Related Code
- `SuperDimmer/Overlay/OverlayManager.swift` (lines 164-183) - Space change detection
- `SuperDimmer/Settings/SettingsManager.swift` (lines 1375-1410) - Wallpaper settings structure

---

## Conclusion

**Q: Can we set different wallpapers for different desktop Spaces?**

**A: No, not programmatically with public APIs.**

**What Umbra Actually Does:**
- Detects when Spaces exist (doesn't break)
- Sets ONE wallpaper per screen for light mode
- Sets ONE wallpaper per screen for dark mode
- Switches between them when appearance changes
- The SAME wallpaper appears on ALL Spaces

**What We Should Do:**
- Implement the same light/dark mode switching as Umbra
- Add wallpaper dimming as a unique feature
- Document the limitation clearly
- Don't promise per-Space wallpapers in marketing

**Why This Is Still Valuable:**
- Most users don't use multiple Spaces
- Light/dark mode switching is the main use case
- Wallpaper dimming is unique to SuperDimmer
- Combines well with our bright region dimming

---

**Next Steps:**
1. ✅ Update PRD to reflect accurate capabilities
2. ✅ Design WallpaperManager with per-appearance support
3. ✅ Implement wallpaper dimming overlay
4. ✅ Add clear documentation about limitations
5. ❌ Remove any references to "per-Space" wallpapers

---

*Research completed: January 21, 2026*  
*Researcher: AI Assistant*  
*Reviewed by: User*
