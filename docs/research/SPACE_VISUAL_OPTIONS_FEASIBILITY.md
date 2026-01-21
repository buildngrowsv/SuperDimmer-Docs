# Space Visual Identification - What's Actually Possible
## Comprehensive Analysis of Options Now That We Can Detect Spaces

**Date:** January 21, 2026  
**Context:** We can now automatically detect which Space we're on via com.apple.spaces plist

---

## Executive Summary

Now that we can **automatically detect the current Space**, here's what we can actually do:

### ✅ FULLY FEASIBLE (Recommended)
1. **Desktop-level colored overlays** - Different subtle tint per Space
2. **Desktop-level pattern overlays** - Different texture/pattern per Space
3. **Corner/edge indicators** - Small visual markers per Space
4. **Animated transitions** - Fade effects when switching Spaces

### ⚠️ PARTIALLY FEASIBLE (With Limitations)
5. **Per-Space wallpapers** - Only via private APIs (not recommended)
6. **Wallpaper manipulation** - Can dim/tint existing wallpaper per Space

### ❌ NOT FEASIBLE (Public APIs)
7. **Setting different wallpapers per Space** - No public API

---

## Option 1: Desktop-Level Colored Overlays ✅ BEST OPTION

### What It Is
A full-screen transparent overlay at desktop level with a subtle color tint unique to each Space.

### How It Works
```swift
let overlay = DimOverlayWindow.create(
    frame: NSScreen.main!.frame,
    dimLevel: 0.0,  // No dimming, just color
    id: "space-\(spaceNumber)"
)

// CRITICAL: Desktop level (above wallpaper, below windows)
overlay.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopWindow)))

// Remove canJoinAllSpaces to pin to this Space
overlay.collectionBehavior = [
    .fullScreenAuxiliary,
    .stationary,
    .ignoresCycle
]

// Set unique color per Space
overlay.contentView?.layer?.backgroundColor = 
    NSColor.systemBlue.withAlphaComponent(0.03).cgColor  // Very subtle!

overlay.ignoresMouseEvents = true  // Click-through
overlay.orderFront(nil)
```

### Visual Examples

**Space 1:** Very subtle blue tint (3% alpha)
**Space 2:** Very subtle green tint (3% alpha)
**Space 3:** Very subtle purple tint (3% alpha)
**Space 4:** Very subtle orange tint (3% alpha)

### Pros
- ✅ Uses only public APIs
- ✅ Works reliably
- ✅ Very subtle and professional
- ✅ Doesn't interfere with windows
- ✅ Doesn't affect wallpaper colors significantly
- ✅ Easy to implement
- ✅ Low performance impact

### Cons
- ⚠️ Might be TOO subtle for some users
- ⚠️ Slight color shift on entire screen
- ⚠️ May not work well with all wallpapers

### User Settings
- Enable/disable per Space
- Adjust color per Space
- Adjust intensity (1-10% alpha)
- Choose from preset color schemes

---

## Option 2: Desktop-Level Pattern Overlays ✅ CREATIVE OPTION

### What It Is
Instead of solid colors, use subtle patterns/textures unique to each Space.

### How It Works
```swift
// Create pattern image
let patternImage = createPatternForSpace(spaceNumber)

// Create overlay with pattern
let overlay = DimOverlayWindow.create(...)
overlay.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopWindow)))

// Apply pattern as background
let patternView = NSView(frame: overlay.bounds)
patternView.wantsLayer = true
patternView.layer?.contents = patternImage
patternView.layer?.opacity = 0.05  // Very subtle
overlay.contentView = patternView
```

### Pattern Ideas

**Space 1:** Subtle diagonal lines (top-left to bottom-right)
**Space 2:** Subtle dots grid
**Space 3:** Subtle horizontal lines
**Space 4:** Subtle crosshatch
**Space 5:** Subtle circles
**Space 6:** Subtle hexagons

### Pros
- ✅ More distinctive than solid colors
- ✅ Can be very subtle yet recognizable
- ✅ Artistic/beautiful
- ✅ Works with any wallpaper
- ✅ Doesn't shift colors

### Cons
- ⚠️ More complex to implement
- ⚠️ Might be distracting if not subtle enough
- ⚠️ Pattern files increase app size
- ⚠️ May look weird with certain wallpapers

### Implementation
```swift
func createPatternForSpace(_ spaceNumber: Int) -> CGImage? {
    let size = CGSize(width: 100, height: 100)
    let renderer = NSGraphicsContext(bitmapImageRep: 
        NSBitmapImageRep(bitmapDataPlanes: nil,
                        pixelsWide: Int(size.width),
                        pixelsHigh: Int(size.height),
                        bitsPerSample: 8,
                        samplesPerPixel: 4,
                        hasAlpha: true,
                        isPlanar: false,
                        colorSpaceName: .deviceRGB,
                        bytesPerRow: 0,
                        bitsPerPixel: 0)!)
    
    NSGraphicsContext.current = renderer
    
    // Draw pattern based on Space number
    switch spaceNumber {
    case 1:
        // Diagonal lines
        NSColor.white.withAlphaComponent(0.1).setStroke()
        for i in stride(from: 0, to: 200, by: 20) {
            let path = NSBezierPath()
            path.move(to: CGPoint(x: CGFloat(i), y: 0))
            path.line(to: CGPoint(x: 0, y: CGFloat(i)))
            path.lineWidth = 1
            path.stroke()
        }
    case 2:
        // Dots
        NSColor.white.withAlphaComponent(0.1).setFill()
        for x in stride(from: 10, to: 100, by: 20) {
            for y in stride(from: 10, to: 100, by: 20) {
                let rect = CGRect(x: x, y: y, width: 2, height: 2)
                NSBezierPath(ovalIn: rect).fill()
            }
        }
    // ... more patterns
    default:
        break
    }
    
    return renderer?.cgContext.makeImage()
}
```

---

## Option 3: Corner/Edge Indicators ✅ MINIMAL OPTION

### What It Is
Small visual indicator in screen corner or edge, unique per Space.

### How It Works
```swift
// Small overlay in top-right corner
let cornerSize: CGFloat = 60
let screenFrame = NSScreen.main!.frame
let cornerFrame = CGRect(
    x: screenFrame.maxX - cornerSize - 20,
    y: screenFrame.maxY - cornerSize - 20,
    width: cornerSize,
    height: cornerSize
)

let indicator = DimOverlayWindow.create(
    frame: cornerFrame,
    dimLevel: 0.0,
    id: "space-indicator-\(spaceNumber)"
)

indicator.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopWindow)))
indicator.collectionBehavior = [.fullScreenAuxiliary, .stationary, .ignoresCycle]

// Create colored circle or shape
let view = NSView(frame: indicator.bounds)
view.wantsLayer = true
view.layer?.backgroundColor = getColorForSpace(spaceNumber).cgColor
view.layer?.cornerRadius = cornerSize / 2  // Circular
indicator.contentView = view
```

### Visual Examples

**Top-right corner:**
- Space 1: Blue dot
- Space 2: Green dot
- Space 3: Purple dot
- Space 4: Orange dot

**Or edge glow:**
- Space 1: Blue glow on left edge
- Space 2: Green glow on right edge
- Space 3: Purple glow on top edge
- Space 4: Orange glow on bottom edge

### Pros
- ✅ Very minimal, unobtrusive
- ✅ Doesn't affect screen content
- ✅ Clear visual indicator
- ✅ Easy to implement
- ✅ Works with any wallpaper

### Cons
- ⚠️ Might conflict with hot corners
- ⚠️ Small and might be missed
- ⚠️ Could be covered by windows

### User Settings
- Choose corner (top-left, top-right, bottom-left, bottom-right)
- Choose style (dot, square, triangle, edge glow)
- Adjust size (small, medium, large)
- Adjust opacity

---

## Option 4: Wallpaper Dimming Per Space ✅ PRACTICAL OPTION

### What It Is
Apply different dim levels to the wallpaper for each Space.

### How It Works
```swift
// Desktop-level overlay with varying opacity
let overlay = DimOverlayWindow.create(
    frame: NSScreen.main!.frame,
    dimLevel: getDimLevelForSpace(spaceNumber),  // Different per Space
    id: "space-dim-\(spaceNumber)"
)

overlay.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopWindow)))
overlay.collectionBehavior = [.fullScreenAuxiliary, .stationary, .ignoresCycle]

// Black overlay with varying opacity
overlay.contentView?.layer?.backgroundColor = 
    NSColor.black.withAlphaComponent(getDimLevelForSpace(spaceNumber)).cgColor
```

### Dim Levels Per Space

**Space 1:** 0% dim (original wallpaper)
**Space 2:** 10% dim (slightly darker)
**Space 3:** 20% dim (darker)
**Space 4:** 30% dim (quite dark)

### Pros
- ✅ Very distinctive
- ✅ Doesn't add colors
- ✅ Works with any wallpaper
- ✅ Clear visual difference
- ✅ Complements SuperDimmer's dimming feature

### Cons
- ⚠️ Makes some Spaces darker
- ⚠️ Might not be desired for all Spaces
- ⚠️ Could make desktop icons harder to see

---

## Option 5: Per-Space Wallpapers ❌ NOT RECOMMENDED

### What It Is
Set different actual wallpaper images for each Space.

### Why It's Not Feasible

**Public API Limitation:**
```swift
// This only works per NSScreen, NOT per Space
NSWorkspace.shared.setDesktopImageURL(url, for: screen)
// Sets wallpaper for ALL Spaces on this screen
```

**Private API Option (NOT RECOMMENDED):**
- Requires `CGSCopyManagedDisplaySpaces` and other private APIs
- Would cause App Store rejection
- Could break with macOS updates
- Unreliable and unsupported

### Verdict
❌ **Do not implement** - Use overlays instead

---

## Option 6: Wallpaper Tinting Per Space ✅ INTERESTING OPTION

### What It Is
Apply a colored tint to the existing wallpaper, different per Space.

### How It Works
```swift
let overlay = DimOverlayWindow.create(...)
overlay.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopWindow)))

// Apply blend mode for tinting
overlay.contentView?.layer?.backgroundColor = 
    NSColor.systemBlue.withAlphaComponent(0.15).cgColor

// Use blend mode to tint wallpaper
overlay.contentView?.layer?.compositingFilter = "multiplyBlendMode"
// Or: "overlayBlendMode", "colorBlendMode", etc.
```

### Visual Effect
The wallpaper appears tinted with the overlay color, creating a unique look per Space.

### Pros
- ✅ Very distinctive
- ✅ Creates unique atmosphere per Space
- ✅ More obvious than subtle overlays
- ✅ Can be beautiful

### Cons
- ⚠️ Significantly changes wallpaper appearance
- ⚠️ May clash with wallpaper colors
- ⚠️ Might be too much for some users
- ⚠️ Could affect readability of desktop icons

---

## Recommended Implementation Strategy

### Phase 1: Start Simple ✅
**Implement:** Desktop-level colored overlays (Option 1)

**Why:**
- Easiest to implement
- Most subtle and professional
- Works for everyone
- Good proof of concept

**Settings:**
```swift
// User can enable/disable
@Published var spaceIdentificationEnabled: Bool = false

// User can choose intensity
@Published var spaceIdentificationIntensity: Double = 0.03  // 3% alpha

// User can customize colors per Space
@Published var spaceColors: [Int: NSColor] = [
    1: .systemBlue,
    2: .systemGreen,
    3: .systemPurple,
    4: .systemOrange
]
```

### Phase 2: Add Options ✅
**Add:** Corner indicators (Option 3) as alternative

**Why:**
- Gives users choice
- More minimal option
- Doesn't affect screen colors

### Phase 3: Advanced Features ✅
**Add:** Pattern overlays (Option 2) and wallpaper dimming (Option 4)

**Why:**
- Power user features
- More customization
- Unique visual styles

---

## User Experience Design

### Preferences UI

```
┌─────────────────────────────────────────────────────────┐
│ Space Visual Identification                             │
├─────────────────────────────────────────────────────────┤
│                                                         │
│ ☑ Enable Space identification                          │
│                                                         │
│ Visual Style: [Colored Overlay ▾]                      │
│   • Colored Overlay (subtle tint)                      │
│   • Pattern Overlay (textures)                         │
│   • Corner Indicator (minimal)                         │
│   • Wallpaper Dimming (varying darkness)               │
│   • Wallpaper Tinting (color blend)                    │
│                                                         │
│ Intensity: ████░░░░░░░░ 30%                            │
│            Subtle ←→ Obvious                           │
│                                                         │
│ ─────────────────────────────────────────────────────  │
│                                                         │
│ Space Colors (Detected: 6 Spaces)                      │
│                                                         │
│ ┌─────────────────────────────────────────────────┐   │
│ │ 🔵 Space 1 [Blue ▾]    [Preview]               │   │
│ │ 🟢 Space 2 [Green ▾]   [Preview]               │   │
│ │ 🟣 Space 3 [Purple ▾]  [Preview]               │   │
│ │ 🟠 Space 4 [Orange ▾]  [Preview]               │   │
│ │ 🔴 Space 5 [Red ▾]     [Preview]               │   │
│ │ 🟡 Space 6 [Yellow ▾]  [Preview]               │   │
│ └─────────────────────────────────────────────────┘   │
│                                                         │
│ [Reset to Defaults]  [Preview All Spaces]              │
│                                                         │
│ ℹ️ Overlays automatically appear on each Space         │
│   Switch between Spaces to see the effect              │
└─────────────────────────────────────────────────────────┘
```

### First-Time Setup

**On first enable:**
1. Detect number of Spaces
2. Auto-assign colors
3. Create overlays for all Spaces
4. Show notification: "Space identification enabled! Switch between Spaces to see the effect."

**No manual registration needed!**

---

## Implementation Code Structure

### Files to Create

```
SuperDimmer/
├── SpaceIdentification/
│   ├── SpaceDetector.swift              # Reads com.apple.spaces plist
│   ├── SpaceChangeMonitor.swift         # Monitors Space changes
│   ├── SpaceIdentificationManager.swift # Main coordinator
│   ├── SpaceOverlay.swift               # Desktop-level overlay window
│   ├── SpaceTheme.swift                 # Theme definitions
│   └── SpaceIdentificationView.swift    # SwiftUI preferences UI
```

### Core Implementation

```swift
// SpaceIdentificationManager.swift
final class SpaceIdentificationManager {
    static let shared = SpaceIdentificationManager()
    
    private var overlays: [String: SpaceOverlay] = [:]  // UUID -> Overlay
    private var monitor: SpaceChangeMonitor?
    private var settings = SettingsManager.shared
    
    func enable() {
        // Detect all Spaces
        let allSpaces = SpaceDetector.getAllSpaces()
        print("✓ Detected \(allSpaces.count) Spaces")
        
        // Create overlay for each Space
        for space in allSpaces {
            createOverlay(for: space)
        }
        
        // Start monitoring for Space changes
        monitor = SpaceChangeMonitor()
        monitor?.startMonitoring { [weak self] spaceNumber in
            self?.handleSpaceChange(spaceNumber)
        }
        
        print("✓ Space identification enabled")
    }
    
    func disable() {
        // Remove all overlays
        for (_, overlay) in overlays {
            overlay.close()
        }
        overlays.removeAll()
        
        // Stop monitoring
        monitor?.stopMonitoring()
        monitor = nil
        
        print("✓ Space identification disabled")
    }
    
    private func createOverlay(for space: SpaceDetector.SpaceInfo) {
        guard let screen = NSScreen.main else { return }
        
        // Get theme for this Space
        let theme = getTheme(for: space.index)
        
        // Create overlay
        let overlay = SpaceOverlay(
            spaceIndex: space.index,
            spaceUUID: space.uuid,
            theme: theme,
            screen: screen
        )
        
        // Store reference
        overlays[space.uuid] = overlay
        
        print("✓ Created overlay for Space \(space.index)")
    }
    
    private func getTheme(for spaceIndex: Int) -> SpaceTheme {
        // Get user's custom color or use default
        if let customColor = settings.spaceColors[spaceIndex] {
            return SpaceTheme(
                color: customColor,
                intensity: settings.spaceIdentificationIntensity
            )
        }
        
        // Default color scheme
        let defaultColors: [NSColor] = [
            .systemBlue, .systemGreen, .systemPurple,
            .systemOrange, .systemRed, .systemYellow
        ]
        
        let colorIndex = (spaceIndex - 1) % defaultColors.count
        return SpaceTheme(
            color: defaultColors[colorIndex],
            intensity: settings.spaceIdentificationIntensity
        )
    }
    
    private func handleSpaceChange(_ spaceNumber: Int) {
        print("✓ User switched to Space \(spaceNumber)")
        // Overlays automatically show/hide based on their Space
        // No action needed!
    }
}
```

---

## Performance Considerations

### Overlay Performance
- **Memory:** ~1-2 MB per overlay
- **CPU:** Negligible (static overlays)
- **GPU:** Minimal (simple compositing)

### Monitoring Performance
- **CPU:** < 0.1% (polling plist every 0.5s)
- **I/O:** Minimal (small plist file)

### Total Impact
- **6 Spaces:** ~6-12 MB RAM, < 0.1% CPU
- **Completely acceptable** for this feature

---

## Conclusion

### What We Should Implement ✅

**Recommended approach:**
1. **Start with colored overlays** (Option 1)
   - Subtle, professional, works for everyone
   - Easy to implement
   - Good user experience

2. **Add corner indicators** (Option 3) as alternative
   - For users who want minimal impact
   - More obvious than subtle tints

3. **Later: Add patterns and dimming** (Options 2, 4)
   - Power user features
   - More customization options

### What We Should NOT Implement ❌

**Avoid:**
- Per-Space wallpaper setting (no public API)
- Private APIs (App Store rejection)
- Manual registration (bad UX)

### The Win

**With automatic Space detection + desktop-level overlays:**
- ✅ Fully automated setup
- ✅ Professional appearance
- ✅ Reliable and stable
- ✅ App Store compatible
- ✅ Great user experience
- ✅ Unique feature!

---

*Analysis completed: January 21, 2026*  
*Recommendation: Implement colored overlays first*  
*Status: Ready for implementation*
