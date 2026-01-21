# Per-Space Visual Identification Feasibility
## Making Users Aware of Which Desktop Space They're On

**Date:** January 21, 2026  
**Status:** Research Complete  
**Question:** Can we visually identify which desktop Space a user is on by applying different overlays/backgrounds per Space?

---

## Executive Summary

**YES! This is feasible using multiple approaches** ✅

The key insight: While we can't set different **wallpapers** per Space programmatically, we **CAN** create **Space-specific overlay windows** by removing the `canJoinAllSpaces` behavior.

**Best Approach:** Create overlay windows that are pinned to specific Spaces, each with different visual characteristics (color tint, pattern, dim level, etc.)

---

## The Problem Statement

**User Need:**
Users want to know which desktop Space they're currently on without having to:
- Open Mission Control
- Count their swipes
- Remember which apps are on which Space

**Proposed Solution:**
Apply a subtle visual indicator (background overlay, tint, dim level) that's unique to each Space.

---

## Technical Feasibility Analysis

### Approach 1: Space-Specific Overlay Windows ✅ FEASIBLE

#### How It Works

By default, our overlay windows use this collection behavior:

```swift
// Current SuperDimmer overlays (DimOverlayWindow.swift, line 194-199)
self.collectionBehavior = [
    .canJoinAllSpaces,          // Appear on all virtual desktops ← REMOVE THIS
    .fullScreenAuxiliary,       // Work alongside fullscreen apps
    .stationary,                // Don't move when other windows are dragged
    .ignoresCycle               // Not included in Cmd+Tab or Cmd+`
]
```

**To make a window Space-specific:**

```swift
// Space-specific overlay
self.collectionBehavior = [
    // .canJoinAllSpaces ← REMOVED! Window now stays on one Space
    .fullScreenAuxiliary,
    .stationary,
    .ignoresCycle
]
```

#### Implementation Strategy

**Create one overlay per Space with unique visual characteristics:**

```swift
// SpaceIdentificationManager.swift (NEW)
final class SpaceIdentificationManager {
    
    // Visual themes for each Space
    enum SpaceTheme {
        case space1  // Subtle blue tint
        case space2  // Subtle green tint
        case space3  // Subtle purple tint
        case space4  // Subtle orange tint
        // ... more as needed
        
        var tintColor: NSColor {
            switch self {
            case .space1: return NSColor.systemBlue.withAlphaComponent(0.05)
            case .space2: return NSColor.systemGreen.withAlphaComponent(0.05)
            case .space3: return NSColor.systemPurple.withAlphaComponent(0.05)
            case .space4: return NSColor.systemOrange.withAlphaComponent(0.05)
            }
        }
        
        var dimLevel: CGFloat {
            switch self {
            case .space1: return 0.02  // Very subtle
            case .space2: return 0.04
            case .space3: return 0.06
            case .space4: return 0.08
            }
        }
    }
    
    // Track which overlay belongs to which Space
    private var spaceOverlays: [SpaceTheme: DimOverlayWindow] = [:]
    
    // Create Space-specific identification overlays
    func setupSpaceIdentification(numberOfSpaces: Int = 4) {
        let themes: [SpaceTheme] = [.space1, .space2, .space3, .space4]
        
        for (index, theme) in themes.prefix(numberOfSpaces).enumerated() {
            // Create a full-screen overlay for this Space
            guard let screen = NSScreen.main else { continue }
            
            let overlay = createSpaceOverlay(
                for: screen,
                theme: theme,
                spaceIndex: index
            )
            
            spaceOverlays[theme] = overlay
            overlay.orderFront(nil)
            
            print("✓ Created Space \(index + 1) overlay with \(theme)")
        }
    }
    
    private func createSpaceOverlay(
        for screen: NSScreen,
        theme: SpaceTheme,
        spaceIndex: Int
    ) -> DimOverlayWindow {
        
        let overlay = DimOverlayWindow(
            contentRect: screen.frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        // CRITICAL: Remove canJoinAllSpaces so it stays on ONE Space
        overlay.collectionBehavior = [
            // .canJoinAllSpaces ← NOT INCLUDED!
            .fullScreenAuxiliary,
            .stationary,
            .ignoresCycle
        ]
        
        // Configure as transparent, click-through overlay
        overlay.isOpaque = false
        overlay.backgroundColor = .clear
        overlay.hasShadow = false
        overlay.ignoresMouseEvents = true
        overlay.level = .desktop  // Below all windows, above wallpaper
        
        // Create the tinted view
        let view = NSView(frame: screen.frame)
        view.wantsLayer = true
        view.layer?.backgroundColor = theme.tintColor.cgColor
        
        overlay.contentView = view
        
        return overlay
    }
}
```

#### How macOS Handles Space Assignment

**When you create a window without `canJoinAllSpaces`:**
1. The window is created on the **currently active Space**
2. It stays on that Space permanently (unless moved by user)
3. When you switch Spaces, the window doesn't follow

**Challenge:** We need to create overlays on DIFFERENT Spaces

**Solution:** Create them sequentially while programmatically switching Spaces (see below)

---

### Approach 2: Helper App Per Space ✅ FEASIBLE (But Complex)

#### Concept

Spawn a separate helper application for each Space:
- Each helper app creates its own overlay
- Helper apps communicate with main SuperDimmer via XPC
- Each helper naturally stays on the Space where it was launched

#### Architecture

```
┌─────────────────────────────────────────────────────────┐
│ SuperDimmer (Main App)                                  │
│ - Menu bar controller                                   │
│ - Settings management                                   │
│ - Coordinates helper apps                               │
└─────────────────┬───────────────────────────────────────┘
                  │
                  │ XPC Communication
                  │
      ┌───────────┼───────────┬───────────┐
      │           │           │           │
      ▼           ▼           ▼           ▼
┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐
│ Helper 1 │ │ Helper 2 │ │ Helper 3 │ │ Helper 4 │
│ Space 1  │ │ Space 2  │ │ Space 3  │ │ Space 4  │
│ Overlay  │ │ Overlay  │ │ Overlay  │ │ Overlay  │
└──────────┘ └──────────┘ └──────────┘ └──────────┘
```

#### Implementation

**1. Create Helper App Target in Xcode**

```swift
// SuperDimmerSpaceHelper.app
// Minimal app that creates one overlay and listens for commands

@main
struct SpaceHelperApp: App {
    @NSApplicationDelegateAdaptor(SpaceHelperDelegate.self) var delegate
    
    var body: some Scene {
        Settings {
            EmptyView()  // No UI
        }
    }
}

class SpaceHelperDelegate: NSObject, NSApplicationDelegate {
    var overlay: DimOverlayWindow?
    var xpcListener: NSXPCListener?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create overlay on this Space
        setupOverlay()
        
        // Setup XPC listener to receive commands from main app
        setupXPCListener()
    }
    
    func setupOverlay() {
        guard let screen = NSScreen.main else { return }
        
        // Create overlay WITHOUT canJoinAllSpaces
        overlay = DimOverlayWindow.create(
            frame: screen.frame,
            dimLevel: 0.05
        )
        
        // Remove canJoinAllSpaces
        overlay?.collectionBehavior = [
            .fullScreenAuxiliary,
            .stationary,
            .ignoresCycle
        ]
        
        overlay?.orderFront(nil)
    }
    
    func setupXPCListener() {
        xpcListener = NSXPCListener(machServiceName: "com.superdimmer.spacehelper")
        xpcListener?.delegate = self
        xpcListener?.resume()
    }
}
```

**2. Launch Helper Apps from Main App**

```swift
// In SuperDimmer main app
func launchSpaceHelpers(count: Int) {
    let helperURL = Bundle.main.bundleURL
        .appendingPathComponent("Contents/Library/LoginItems/SuperDimmerSpaceHelper.app")
    
    for spaceIndex in 0..<count {
        // Switch to Space (requires private API or user action)
        // Then launch helper
        
        let config = NSWorkspace.OpenConfiguration()
        config.activates = false  // Don't bring to front
        
        NSWorkspace.shared.openApplication(
            at: helperURL,
            configuration: config
        ) { app, error in
            if let error = error {
                print("Failed to launch helper: \(error)")
            } else {
                print("✓ Launched helper for Space \(spaceIndex + 1)")
            }
        }
        
        // Wait for helper to launch before switching to next Space
        Thread.sleep(forTimeInterval: 1.0)
    }
}
```

**3. XPC Communication**

```swift
// Protocol for communication
@objc protocol SpaceHelperProtocol {
    func setTintColor(_ color: NSColor)
    func setDimLevel(_ level: CGFloat)
    func hide()
    func show()
}

// Main app sends commands to helpers
class SpaceHelperController {
    var connections: [NSXPCConnection] = []
    
    func updateAllHelpers(dimLevel: CGFloat) {
        for connection in connections {
            let proxy = connection.remoteObjectProxy as? SpaceHelperProtocol
            proxy?.setDimLevel(dimLevel)
        }
    }
}
```

#### Pros and Cons

**Pros:**
- ✅ Clean separation - each helper is independent
- ✅ Crash isolation - one helper crash doesn't affect others
- ✅ Natural Space assignment - each helper stays on its launch Space
- ✅ Can run different code per Space if needed

**Cons:**
- ❌ Complex architecture - multiple processes to manage
- ❌ Launch coordination - need to switch Spaces to launch helpers
- ❌ Resource overhead - multiple app instances
- ❌ Debugging complexity - multiple processes
- ❌ Code signing - need to sign helper app separately

---

### Approach 3: Detect Space Changes and Update Single Overlay ❌ NOT FEASIBLE

**Idea:** Keep one overlay, detect Space changes, update its appearance

**Problem:** We can detect Space changes but can't identify WHICH Space we're on

```swift
// We have this (already implemented):
NSWorkspace.shared.notificationCenter.addObserver(
    name: NSWorkspace.activeSpaceDidChangeNotification
)

// But the notification gives us NO information about:
// - Which Space we switched FROM
// - Which Space we switched TO
// - Total number of Spaces
// - Space IDs or indices
```

**Verdict:** Not feasible without private APIs

---

## Recommended Implementation

### **Option A: Single-App with Space-Pinned Overlays** ✅ RECOMMENDED

**Why This is Best:**
- Simpler architecture (no helper apps)
- All code in one process
- Easier debugging
- Lower resource usage
- Easier to ship and maintain

**Implementation Plan:**

#### Phase 1: Create Space-Specific Overlays

```swift
// 1. User configures number of Spaces in Preferences
let numberOfSpaces = SettingsManager.shared.numberOfSpaces  // Default: 4

// 2. User manually switches to each Space and "registers" it
// UI shows: "Switch to Space 1 and click 'Register'"
// This creates the overlay on that Space

func registerCurrentSpace(index: Int, theme: SpaceTheme) {
    guard let screen = NSScreen.main else { return }
    
    let overlay = DimOverlayWindow.create(
        frame: screen.frame,
        dimLevel: theme.dimLevel,
        id: "space-\(index)"
    )
    
    // CRITICAL: Remove canJoinAllSpaces
    overlay.collectionBehavior = [
        .fullScreenAuxiliary,
        .stationary,
        .ignoresCycle
    ]
    
    // Set visual theme
    overlay.contentView?.layer?.backgroundColor = theme.tintColor.cgColor
    overlay.level = .desktop  // Below windows, above wallpaper
    
    overlay.orderFront(nil)
    
    spaceOverlays[index] = overlay
    
    print("✓ Registered Space \(index) with theme: \(theme)")
}
```

#### Phase 2: User Setup Flow

**Preferences > Space Identification Tab:**

```
┌─────────────────────────────────────────────────────────┐
│ Space Visual Identification                             │
├─────────────────────────────────────────────────────────┤
│                                                         │
│ ☑ Enable Space identification overlays                 │
│                                                         │
│ Number of Spaces: [4 ▾]                                │
│                                                         │
│ ─────────────────────────────────────────────────────  │
│                                                         │
│ Setup Instructions:                                     │
│ 1. Switch to each Space manually                       │
│ 2. Click "Register This Space" button                  │
│ 3. Choose visual theme for this Space                  │
│                                                         │
│ ┌─────────────────────────────────────────────────┐   │
│ │ Space 1: ✅ Registered (Blue tint)              │   │
│ │ Space 2: ✅ Registered (Green tint)             │   │
│ │ Space 3: ⚠️  Not registered yet                 │   │
│ │ Space 4: ⚠️  Not registered yet                 │   │
│ └─────────────────────────────────────────────────┘   │
│                                                         │
│ Currently on: Space ? (unknown until registered)       │
│                                                         │
│ [Register This Space]  [Choose Theme...]               │
│                                                         │
│ ─────────────────────────────────────────────────────  │
│                                                         │
│ Visual Themes:                                          │
│ ○ Subtle color tint (recommended)                      │
│ ○ Different dim levels                                 │
│ ○ Corner indicators                                    │
│ ○ Custom patterns                                      │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

#### Phase 3: Visual Theme Options

**Theme 1: Subtle Color Tints** (Recommended)
- Space 1: Very faint blue overlay (alpha 0.03)
- Space 2: Very faint green overlay (alpha 0.03)
- Space 3: Very faint purple overlay (alpha 0.03)
- Space 4: Very faint orange overlay (alpha 0.03)

**Theme 2: Varying Dim Levels**
- Space 1: 2% dim
- Space 2: 4% dim
- Space 3: 6% dim
- Space 4: 8% dim

**Theme 3: Corner Indicators**
- Small colored square in corner (e.g., top-right)
- Different color per Space
- Minimal and unobtrusive

**Theme 4: Edge Glow**
- Subtle colored glow around screen edges
- Different color per Space
- Uses gradient mask

#### Phase 4: Persistence

```swift
// Save Space overlay configuration
struct SpaceOverlayConfig: Codable {
    let spaceIndex: Int
    let theme: SpaceTheme
    let isRegistered: Bool
}

// On app launch, recreate overlays
func restoreSpaceOverlays() {
    // Problem: We don't know which Space we're on at launch
    // Solution: Recreate overlays lazily as user switches Spaces
    
    // Or: Show notification asking user to switch through Spaces
    // to reactivate overlays
}
```

---

## Alternative Visual Approaches

### 1. Desktop-Level Colored Overlay ✅

**What:** Full-screen colored overlay at desktop level (below all windows)

**Pros:**
- Doesn't interfere with windows
- Very subtle and non-intrusive
- Works with all apps

**Cons:**
- Might affect color perception slightly
- Some users may not like tinted displays

**Implementation:**
```swift
overlay.level = .desktop  // NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopWindow)))
overlay.contentView?.layer?.backgroundColor = NSColor.systemBlue.withAlphaComponent(0.05).cgColor
```

### 2. Menu Bar Indicator 🤔

**What:** Show Space number/color in menu bar

**Pros:**
- No overlay needed
- Always visible
- Easy to implement

**Cons:**
- Requires looking at menu bar
- Takes up menu bar space
- Not as immediate as background tint

**Implementation:**
```swift
// In MenuBarController
func updateSpaceIndicator(spaceIndex: Int) {
    statusItem.button?.title = "Space \(spaceIndex + 1)"
    // Or use colored dot icon
}
```

### 3. Corner Badge 🤔

**What:** Small colored badge in screen corner

**Pros:**
- Minimal visual impact
- Clear indicator
- Doesn't affect color perception

**Cons:**
- Might be overlooked
- Could interfere with corner hot corners
- Less subtle than tint

### 4. Wallpaper Overlay Pattern ✅

**What:** Subtle pattern overlay (dots, grid, texture) unique per Space

**Pros:**
- Very distinctive
- Doesn't affect colors
- Can be artistic/beautiful

**Cons:**
- More complex to implement
- Might be distracting
- File size for pattern images

---

## Technical Challenges and Solutions

### Challenge 1: Creating Overlays on Different Spaces

**Problem:** When we create a window, it appears on the current Space

**Solutions:**

**Option A: User-Assisted Setup** ✅ RECOMMENDED
- User manually switches to each Space
- Clicks "Register" button on each
- App creates overlay on that Space
- Simple and reliable

**Option B: Automated with AppleScript** ⚠️
```applescript
tell application "System Events"
    key code 124 using {control down}  -- Switch to next Space
end tell
```
- Brittle and unreliable
- Requires Accessibility permissions
- Might not work with all setups

**Option C: Private API** ❌
```objc
extern CGError CGSMoveWindowToWorkspace(CGSConnection cid, CGWindowID wid, int workspaceID);
```
- App Store rejection
- Unstable across macOS versions

### Challenge 2: Knowing Which Space We're On

**Problem:** No public API to get current Space ID

**Solutions:**

**Option A: Track During Registration** ✅
- When user registers Space, we know which one it is
- Store mapping: "Space 1 = Blue overlay"
- Don't need to query later

**Option B: Infer from Active Windows** 🤔
- Track which windows are visible
- Match against known window-to-Space assignments
- Unreliable with multiple monitors

**Option C: Private API** ❌
```objc
CGSGetActiveSpace(cid, &spaceID);
```
- App Store rejection

### Challenge 3: Overlay Persistence Across Restarts

**Problem:** Overlays are destroyed when app quits

**Solutions:**

**Option A: Re-registration on Launch** ✅
- Show notification: "Please switch through your Spaces to reactivate identification"
- User swipes through Spaces once
- Overlays recreate automatically

**Option B: Launch Helper Apps** 🤔
- Helper apps can be set to launch on login
- Each helper recreates its overlay
- More complex but automatic

---

## Comparison: Single App vs Helper Apps

| Aspect | Single App + Overlays | Helper App Per Space |
|--------|----------------------|---------------------|
| **Complexity** | ⭐⭐ Simple | ⭐⭐⭐⭐⭐ Complex |
| **Setup** | User switches + registers | Automated (with private API) or user-assisted |
| **Maintenance** | ⭐⭐⭐⭐⭐ Easy | ⭐⭐ Harder |
| **Resources** | ⭐⭐⭐⭐ Low | ⭐⭐ Higher (multiple processes) |
| **Reliability** | ⭐⭐⭐⭐ Good | ⭐⭐⭐ Good |
| **Debugging** | ⭐⭐⭐⭐⭐ Easy | ⭐⭐ Harder |
| **App Store** | ✅ Compatible | ✅ Compatible (if no private APIs) |
| **Crash Isolation** | ⭐⭐ One crash affects all | ⭐⭐⭐⭐ Isolated |

**Recommendation:** Start with **Single App + Overlays** approach. It's simpler, easier to maintain, and provides 90% of the value with 10% of the complexity.

---

## Proposed Feature Specification

### Feature: Space Visual Identification

**Goal:** Help users immediately know which desktop Space they're on

**Implementation:** Space-specific overlay windows with unique visual themes

**User Experience:**

1. **Setup (One-Time):**
   - User enables "Space Identification" in Preferences
   - User specifies number of Spaces (2-16)
   - User switches to each Space and clicks "Register This Space"
   - User chooses visual theme per Space (color tint, dim level, etc.)

2. **Daily Use:**
   - Each Space has subtle visual indicator
   - Indicator is always present but non-intrusive
   - User can instantly recognize which Space they're on
   - No performance impact (overlays are lightweight)

3. **Customization:**
   - Choose from preset themes or create custom
   - Adjust intensity (more/less subtle)
   - Enable/disable per Space
   - Reset all and re-register

**Settings:**

```swift
// Add to SettingsManager.swift
@Published var spaceIdentificationEnabled: Bool = false
@Published var numberOfSpaces: Int = 4
@Published var spaceThemeType: SpaceThemeType = .colorTint
@Published var spaceThemeIntensity: Double = 0.5  // 0.0 = very subtle, 1.0 = obvious
```

**UI Mockup:**

```
Preferences > Space Identification

┌─────────────────────────────────────────────────────────┐
│ ☑ Enable Space visual identification                   │
│                                                         │
│ Spaces to track: [4 ▾]  (2-16)                        │
│                                                         │
│ Visual style: [Subtle color tint ▾]                    │
│   • Subtle color tint                                  │
│   • Varying dim levels                                 │
│   • Corner indicators                                  │
│   • Edge glow                                          │
│                                                         │
│ Intensity: ████████░░░░ 60%                            │
│            Subtle ←→ Obvious                           │
│                                                         │
│ ─────────────────────────────────────────────────────  │
│                                                         │
│ Registered Spaces:                                      │
│                                                         │
│ ┌─────────────────────────────────────────────────┐   │
│ │ 🟦 Space 1: Blue tint    [Edit] [Unregister]   │   │
│ │ 🟩 Space 2: Green tint   [Edit] [Unregister]   │   │
│ │ 🟪 Space 3: Purple tint  [Edit] [Unregister]   │   │
│ │ ⚪ Space 4: Not registered yet                  │   │
│ └─────────────────────────────────────────────────┘   │
│                                                         │
│ [Register Current Space]                                │
│                                                         │
│ ℹ️ Switch to a Space and click "Register" to set up   │
│   its visual identification.                           │
│                                                         │
│ [Reset All and Re-register]                            │
└─────────────────────────────────────────────────────────┘
```

---

## Code Structure

### New Files to Create

```
SuperDimmer/
├── SpaceIdentification/
│   ├── SpaceIdentificationManager.swift    # Main coordinator
│   ├── SpaceOverlay.swift                  # Space-specific overlay window
│   ├── SpaceTheme.swift                    # Theme definitions
│   └── SpaceRegistrationView.swift         # SwiftUI setup UI
```

### Core Implementation

```swift
// SpaceIdentificationManager.swift
final class SpaceIdentificationManager {
    static let shared = SpaceIdentificationManager()
    
    private var overlays: [Int: SpaceOverlay] = [:]
    private var settings = SettingsManager.shared
    
    func registerCurrentSpace(index: Int, theme: SpaceTheme) {
        // Create overlay on current Space
    }
    
    func unregisterSpace(index: Int) {
        // Remove overlay
    }
    
    func updateTheme(for spaceIndex: Int, theme: SpaceTheme) {
        // Update existing overlay
    }
    
    func setEnabled(_ enabled: Bool) {
        // Show/hide all overlays
    }
}

// SpaceOverlay.swift
final class SpaceOverlay: DimOverlayWindow {
    var spaceIndex: Int
    var theme: SpaceTheme
    
    init(spaceIndex: Int, theme: SpaceTheme, screen: NSScreen) {
        self.spaceIndex = spaceIndex
        self.theme = theme
        
        super.init(
            contentRect: screen.frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        configureForSpace()
        applyTheme()
    }
    
    private func configureForSpace() {
        // CRITICAL: Remove canJoinAllSpaces
        self.collectionBehavior = [
            .fullScreenAuxiliary,
            .stationary,
            .ignoresCycle
        ]
        
        self.level = .desktop
        self.ignoresMouseEvents = true
        self.isOpaque = false
        self.backgroundColor = .clear
    }
    
    private func applyTheme() {
        // Apply visual theme
    }
}

// SpaceTheme.swift
enum SpaceThemeType: String, Codable {
    case colorTint
    case dimLevel
    case cornerIndicator
    case edgeGlow
}

struct SpaceTheme: Codable {
    let type: SpaceThemeType
    let color: CodableColor?
    let intensity: Double
    
    var overlayColor: NSColor {
        // Calculate overlay color based on theme
    }
}
```

---

## Recommendations

### For Immediate Implementation ✅

1. **Start with Single-App Approach**
   - Simpler to build and maintain
   - Good enough for MVP
   - Can always add helper apps later if needed

2. **Use Subtle Color Tints**
   - Most user-friendly
   - Least intrusive
   - Works well with any content

3. **Require User-Assisted Setup**
   - Reliable and simple
   - No private APIs needed
   - Clear user understanding of what's happening

4. **Desktop-Level Overlays**
   - Below all windows
   - Doesn't interfere with content
   - Always visible

### For Future Enhancement 🔮

1. **Helper App Approach**
   - If single-app approach has issues
   - If we need more isolation
   - If automatic setup becomes possible

2. **Smart Space Detection**
   - Track window positions
   - Infer Space from visible windows
   - Auto-detect number of Spaces

3. **Dynamic Themes**
   - Change theme based on time of day
   - Match system appearance
   - User-uploaded patterns

---

## Conclusion

**Q: Can we make users aware of which desktop Space they're on?**

**A: YES! ✅**

**Best Approach:**
- Create Space-specific overlay windows (remove `canJoinAllSpaces`)
- User registers each Space manually (one-time setup)
- Each Space gets unique visual theme (subtle color tint)
- Overlays persist on their assigned Spaces

**Why This Works:**
- Uses only public APIs (App Store compatible)
- Simple architecture (single app)
- Reliable (no private API dependencies)
- User-friendly (clear setup process)
- Performant (lightweight overlays)

**Next Steps:**
1. Create `SpaceIdentificationManager` class
2. Add UI to Preferences for setup
3. Implement overlay creation with Space-pinning
4. Design visual themes
5. Test with multiple Spaces
6. Add to PRD as new feature

---

*Research completed: January 21, 2026*  
*Researcher: AI Assistant*  
*Status: Ready for implementation*
