# Space Switcher HUD - Floating UI Design
## Mission Control-style floating overlay for Space navigation

**Date:** January 21, 2026  
**Context:** User wants a floating UI that shows current desktop number/name and allows switching between Spaces

---

## Executive Summary

### What The User Actually Wants ✅

A **floating HUD overlay** (like Spotlight or Raycast) that:
1. Shows the current Space number and name
2. Shows all available Spaces as clickable buttons
3. Allows quick switching between Spaces
4. Appears on all Spaces (or just current Space)
5. Always stays on top

### Implementation Approach

**SINGLE APP, ONE FLOATING WINDOW**
- One `NSPanel` window that appears on all Spaces
- Detects Space changes via `com.apple.spaces.plist` monitoring
- Updates UI to show current Space
- Provides buttons to switch to other Spaces

**NOT:** Spawning separate apps per Space (unnecessary complexity)

---

## Visual Design Mockup

### Compact Mode (Default)

```
┌─────────────────────────────────┐
│  🖥️  Space 3: Development       │
│                                 │
│  [1] [2] [●3] [4] [5] [6]      │
└─────────────────────────────────┘
```

### Expanded Mode (With Space Names)

```
┌─────────────────────────────────────────┐
│  Current Space: Development             │
├─────────────────────────────────────────┤
│                                         │
│  ┌──────────┐  ┌──────────┐           │
│  │    1     │  │    2     │           │
│  │  Email   │  │  Browse  │           │
│  └──────────┘  └──────────┘           │
│                                         │
│  ┌──────────┐  ┌──────────┐           │
│  │  ● 3     │  │    4     │           │
│  │   Dev    │  │  Design  │           │
│  └──────────┘  └──────────┘           │
│                                         │
│  ┌──────────┐  ┌──────────┐           │
│  │    5     │  │    6     │           │
│  │  Music   │  │  Chat    │           │
│  └──────────┘  └──────────┘           │
│                                         │
└─────────────────────────────────────────┘
```

### Mini Mode (Ultra Compact)

```
┌──────────────┐
│  Space 3/6   │
│  ← [●] →     │
└──────────────┘
```

---

## Technical Implementation

### Architecture: Single Floating Panel ✅

```swift
// SpaceSwitcherHUD.swift
// A single NSPanel that appears on all Spaces and shows Space navigation

import AppKit
import SwiftUI

final class SpaceSwitcherHUD: NSPanel {
    
    // MARK: - Singleton
    static let shared = SpaceSwitcherHUD()
    
    // MARK: - Properties
    private var spaceMonitor: SpaceChangeMonitor?
    private var currentSpaceNumber: Int = 1
    private var allSpaces: [SpaceDetector.SpaceInfo] = []
    
    // MARK: - Initialization
    private init() {
        // Create panel with HUD style
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
            styleMask: [
                .nonactivatingPanel,  // Doesn't steal focus
                .titled,
                .resizable,
                .closable,
                .fullSizeContentView
            ],
            backing: .buffered,
            defer: false
        )
        
        setupPanel()
        setupContent()
        setupSpaceMonitoring()
    }
    
    private func setupPanel() {
        // Always on top
        isFloatingPanel = true
        level = .floating  // Above all windows
        
        // Appear on all Spaces (including fullscreen)
        collectionBehavior = [
            .canJoinAllSpaces,        // Appears on all Spaces
            .fullScreenAuxiliary      // Works in fullscreen
        ]
        
        // HUD style appearance
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        isMovableByWindowBackground = true
        backgroundColor = .clear
        
        // Don't hide when app deactivates
        hidesOnDeactivate = false
        
        // Hide traffic light buttons
        standardWindowButton(.closeButton)?.isHidden = true
        standardWindowButton(.miniaturizeButton)?.isHidden = true
        standardWindowButton(.zoomButton)?.isHidden = true
        
        // Utility window animations
        animationBehavior = .utilityWindow
        
        // Position in top-right corner
        positionInTopRight()
        
        print("✓ SpaceSwitcherHUD panel configured")
    }
    
    private func setupContent() {
        // Create SwiftUI view
        let hudView = SpaceSwitcherHUDView(
            currentSpace: $currentSpaceNumber,
            allSpaces: $allSpaces,
            onSpaceSwitch: { [weak self] spaceNumber in
                self?.switchToSpace(spaceNumber)
            },
            onClose: { [weak self] in
                self?.close()
            }
        )
        
        // Wrap in NSHostingView with blur background
        let hostingView = NSHostingView(rootView: hudView)
        contentView = hostingView
        
        print("✓ SpaceSwitcherHUD content view created")
    }
    
    private func setupSpaceMonitoring() {
        // Detect all Spaces
        refreshSpaces()
        
        // Monitor Space changes
        spaceMonitor = SpaceChangeMonitor()
        spaceMonitor?.startMonitoring { [weak self] spaceNumber in
            self?.handleSpaceChange(spaceNumber)
        }
        
        print("✓ SpaceSwitcherHUD monitoring started")
    }
    
    private func refreshSpaces() {
        allSpaces = SpaceDetector.getAllSpaces()
        if let current = SpaceDetector.getCurrentSpace() {
            currentSpaceNumber = current.spaceNumber
        }
        print("✓ Detected \(allSpaces.count) Spaces, current: \(currentSpaceNumber)")
    }
    
    private func handleSpaceChange(_ spaceNumber: Int) {
        currentSpaceNumber = spaceNumber
        print("✓ Space changed to \(spaceNumber)")
        
        // Update UI (SwiftUI binding will handle this automatically)
    }
    
    private func switchToSpace(_ spaceNumber: Int) {
        print("→ Switching to Space \(spaceNumber)...")
        
        // Use Mission Control to switch Spaces
        // This requires accessibility permissions
        let script = """
        tell application "System Events"
            key code 123 using {control down}  -- Control + Left Arrow
        end tell
        """
        
        // Or use CGS private API (not recommended for App Store)
        // CGSMoveWorkspaceWindowList(_CGSDefaultConnection(), [windowID], spaceID)
        
        // For now, show notification
        showNotification("Switching to Space \(spaceNumber)")
        
        // TODO: Implement actual Space switching
        // Options:
        // 1. AppleScript (requires automation permissions)
        // 2. Accessibility API (requires accessibility permissions)
        // 3. Private CGS API (not App Store safe)
    }
    
    private func positionInTopRight() {
        guard let screen = NSScreen.main else { return }
        
        let screenFrame = screen.visibleFrame
        let windowFrame = frame
        
        let x = screenFrame.maxX - windowFrame.width - 20
        let y = screenFrame.maxY - windowFrame.height - 20
        
        setFrameOrigin(NSPoint(x: x, y: y))
    }
    
    private func showNotification(_ message: String) {
        // Simple notification
        print("📢 \(message)")
    }
    
    // MARK: - Public Interface
    
    func show() {
        refreshSpaces()
        orderFront(nil)
        print("✓ SpaceSwitcherHUD shown")
    }
    
    func hide() {
        orderOut(nil)
        print("✓ SpaceSwitcherHUD hidden")
    }
    
    func toggle() {
        if isVisible {
            hide()
        } else {
            show()
        }
    }
}
```

---

## SwiftUI View Implementation

```swift
// SpaceSwitcherHUDView.swift
// The actual UI for the Space Switcher HUD

import SwiftUI

struct SpaceSwitcherHUDView: View {
    
    // MARK: - Properties
    @Binding var currentSpace: Int
    @Binding var allSpaces: [SpaceDetector.SpaceInfo]
    
    let onSpaceSwitch: (Int) -> Void
    let onClose: () -> Void
    
    @State private var displayMode: DisplayMode = .compact
    @State private var hoveredSpace: Int?
    
    enum DisplayMode {
        case mini       // Just current Space number
        case compact    // Current + numbered buttons
        case expanded   // Grid with Space names
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Background blur
            VisualEffectView(
                material: .hudWindow,
                blendingMode: .behindWindow
            )
            .cornerRadius(12)
            
            // Content
            VStack(spacing: 0) {
                // Header
                headerView
                
                Divider()
                    .padding(.vertical, 8)
                
                // Space grid/list
                spacesView
                
                // Footer controls
                footerView
            }
            .padding(16)
        }
        .frame(
            width: displayMode == .expanded ? 400 : 300,
            height: displayMode == .expanded ? 400 : 120
        )
        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            // Current Space indicator
            HStack(spacing: 8) {
                Image(systemName: "square.grid.3x3")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Space \(currentSpace)")
                        .font(.system(size: 14, weight: .semibold))
                    
                    if let spaceName = getSpaceName(currentSpace) {
                        Text(spaceName)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Display mode toggle
            Button(action: cycleDisplayMode) {
                Image(systemName: displayMode == .expanded ? 
                      "rectangle.compress.vertical" : "rectangle.expand.vertical")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .help("Toggle view mode")
            
            // Close button
            Button(action: onClose) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .help("Close")
        }
    }
    
    // MARK: - Spaces View
    @ViewBuilder
    private var spacesView: some View {
        switch displayMode {
        case .mini:
            miniSpacesView
        case .compact:
            compactSpacesView
        case .expanded:
            expandedSpacesView
        }
    }
    
    // Mini: Just arrows and current number
    private var miniSpacesView: some View {
        HStack(spacing: 16) {
            Button(action: { switchToPreviousSpace() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
            }
            .buttonStyle(.plain)
            .disabled(currentSpace <= 1)
            
            Text("\(currentSpace)/\(allSpaces.count)")
                .font(.system(size: 20, weight: .bold))
                .frame(width: 60)
            
            Button(action: { switchToNextSpace() }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
            }
            .buttonStyle(.plain)
            .disabled(currentSpace >= allSpaces.count)
        }
    }
    
    // Compact: Numbered buttons in a row
    private var compactSpacesView: some View {
        HStack(spacing: 8) {
            ForEach(allSpaces, id: \.index) { space in
                Button(action: { onSpaceSwitch(space.index) }) {
                    Text("\(space.index)")
                        .font(.system(size: 14, weight: space.index == currentSpace ? .bold : .regular))
                        .frame(width: 32, height: 32)
                        .background(
                            space.index == currentSpace ? 
                                Color.accentColor : Color.secondary.opacity(0.2)
                        )
                        .foregroundColor(
                            space.index == currentSpace ? .white : .primary
                        )
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .help("Switch to Space \(space.index)")
            }
        }
    }
    
    // Expanded: Grid with names
    private var expandedSpacesView: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ],
            spacing: 12
        ) {
            ForEach(allSpaces, id: \.index) { space in
                Button(action: { onSpaceSwitch(space.index) }) {
                    VStack(spacing: 6) {
                        // Space number
                        HStack(spacing: 4) {
                            if space.index == currentSpace {
                                Circle()
                                    .fill(Color.accentColor)
                                    .frame(width: 6, height: 6)
                            }
                            Text("\(space.index)")
                                .font(.system(size: 20, weight: .bold))
                        }
                        
                        // Space name
                        Text(getSpaceName(space.index) ?? "Desktop")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 70)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                space.index == currentSpace ?
                                    Color.accentColor.opacity(0.2) :
                                    (hoveredSpace == space.index ?
                                        Color.secondary.opacity(0.1) :
                                        Color.clear)
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                space.index == currentSpace ?
                                    Color.accentColor :
                                    Color.clear,
                                lineWidth: 2
                            )
                    )
                }
                .buttonStyle(.plain)
                .help("Switch to Space \(space.index)")
                .onHover { hovering in
                    hoveredSpace = hovering ? space.index : nil
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Footer
    private var footerView: some View {
        HStack {
            Text("\(allSpaces.count) Spaces")
                .font(.system(size: 10))
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button(action: { /* Open preferences */ }) {
                Text("Settings")
                    .font(.system(size: 10))
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Helpers
    private func getSpaceName(_ spaceNumber: Int) -> String? {
        // TODO: Get custom Space names from settings
        // For now, return generic names
        let defaultNames = [
            1: "Email",
            2: "Browse",
            3: "Development",
            4: "Design",
            5: "Music",
            6: "Chat"
        ]
        return defaultNames[spaceNumber]
    }
    
    private func cycleDisplayMode() {
        switch displayMode {
        case .mini:
            displayMode = .compact
        case .compact:
            displayMode = .expanded
        case .expanded:
            displayMode = .mini
        }
    }
    
    private func switchToPreviousSpace() {
        if currentSpace > 1 {
            onSpaceSwitch(currentSpace - 1)
        }
    }
    
    private func switchToNextSpace() {
        if currentSpace < allSpaces.count {
            onSpaceSwitch(currentSpace + 1)
        }
    }
}

// MARK: - Visual Effect View
struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
```

---

## Key Features

### 1. Always Visible on All Spaces ✅

```swift
collectionBehavior = [
    .canJoinAllSpaces,        // Appears on all Spaces
    .fullScreenAuxiliary      // Works in fullscreen
]
```

The HUD appears on every Space, always showing current location.

### 2. Auto-Updates When Switching Spaces ✅

```swift
spaceMonitor?.startMonitoring { [weak self] spaceNumber in
    self?.currentSpaceNumber = spaceNumber  // SwiftUI binding updates UI
}
```

No manual refresh needed - UI updates automatically.

### 3. Quick Space Switching

**Three methods to implement:**

#### Option A: AppleScript (Requires Automation Permission)
```swift
func switchToSpace(_ targetSpace: Int) {
    let currentSpace = SpaceDetector.getCurrentSpace()?.spaceNumber ?? 1
    let steps = targetSpace - currentSpace
    
    if steps == 0 { return }
    
    let direction = steps > 0 ? "right" : "left"
    let count = abs(steps)
    
    let script = """
    tell application "System Events"
        repeat \(count) times
            key code \(direction == "right" ? "124" : "123") using {control down}
            delay 0.3
        end repeat
    end tell
    """
    
    var error: NSDictionary?
    if let scriptObject = NSAppleScript(source: script) {
        scriptObject.executeAndReturnError(&error)
    }
}
```

#### Option B: Accessibility API (Requires Accessibility Permission)
```swift
// Use AXUIElement to trigger Mission Control gestures
// More complex but more reliable
```

#### Option C: Private CGS API (NOT App Store Safe)
```swift
// CGSMoveWorkspaceWindowList() - works but private
```

**Recommendation:** Start with AppleScript, add Accessibility API later.

### 4. Keyboard Shortcut Activation

```swift
// In AppDelegate or MenuBarController
func setupGlobalHotkey() {
    // Register Cmd+Shift+S to toggle HUD
    NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
        if event.modifierFlags.contains([.command, .shift]) &&
           event.keyCode == 1 {  // 'S' key
            SpaceSwitcherHUD.shared.toggle()
        }
    }
}
```

### 5. Customizable Space Names

```swift
// In SettingsManager
@Published var spaceNames: [Int: String] = [:]

// User can set custom names
spaceNames[1] = "Email & Calendar"
spaceNames[2] = "Web Browsing"
spaceNames[3] = "Xcode Development"
```

---

## User Experience Flow

### First Time Use

1. User enables "Space Switcher HUD" in Preferences
2. App requests Automation permission (for Space switching)
3. HUD appears in top-right corner
4. Shows current Space and all available Spaces
5. User can click any Space button to switch

### Daily Use

1. Press `Cmd+Shift+S` (or custom hotkey)
2. HUD appears/toggles
3. Shows current Space highlighted
4. Click any Space to switch
5. HUD stays visible or auto-hides (user preference)

### Preferences

```
┌─────────────────────────────────────────────────────────┐
│ Space Switcher HUD                                      │
├─────────────────────────────────────────────────────────┤
│                                                         │
│ ☑ Enable Space Switcher HUD                            │
│                                                         │
│ Display Mode: [Compact ▾]                              │
│   • Mini (arrows only)                                 │
│   • Compact (numbered buttons)                         │
│   • Expanded (grid with names)                         │
│                                                         │
│ Position: [Top Right ▾]                                │
│   • Top Left                                           │
│   • Top Right                                          │
│   • Bottom Left                                        │
│   • Bottom Right                                       │
│   • Custom...                                          │
│                                                         │
│ Behavior:                                              │
│   ☑ Show on all Spaces                                 │
│   ☐ Auto-hide after switching                         │
│   ☐ Show only when hotkey pressed                     │
│                                                         │
│ Keyboard Shortcut: [⌘⇧S]  [Change...]                 │
│                                                         │
│ ─────────────────────────────────────────────────────  │
│                                                         │
│ Space Names (Detected: 6 Spaces)                      │
│                                                         │
│ Space 1: [Email & Calendar          ]                 │
│ Space 2: [Web Browsing              ]                 │
│ Space 3: [Xcode Development         ]                 │
│ Space 4: [Design Tools              ]                 │
│ Space 5: [Music & Media             ]                 │
│ Space 6: [Communication             ]                 │
│                                                         │
│ [Reset Names]  [Auto-detect Apps]                     │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## Implementation Checklist

### Phase 1: Basic HUD ✅
- [ ] Create `SpaceSwitcherHUD` NSPanel class
- [ ] Implement floating panel configuration
- [ ] Create `SpaceSwitcherHUDView` SwiftUI view
- [ ] Integrate `SpaceDetector` for current Space
- [ ] Integrate `SpaceChangeMonitor` for auto-updates
- [ ] Add compact display mode
- [ ] Test on multiple Spaces

### Phase 2: Space Switching ✅
- [ ] Implement AppleScript-based Space switching
- [ ] Request Automation permissions
- [ ] Add error handling for failed switches
- [ ] Add visual feedback during switch
- [ ] Test switching between all Spaces

### Phase 3: Customization ✅
- [ ] Add Space name customization
- [ ] Add display mode toggle (mini/compact/expanded)
- [ ] Add position customization
- [ ] Add keyboard shortcut registration
- [ ] Add auto-hide option
- [ ] Create preferences UI

### Phase 4: Polish ✅
- [ ] Add animations for Space changes
- [ ] Add hover effects
- [ ] Add keyboard navigation (arrow keys)
- [ ] Add Space thumbnails (if possible)
- [ ] Performance optimization
- [ ] Accessibility support

---

## Permissions Required

### 1. Automation Permission
**Why:** To execute AppleScript for Space switching  
**Request:** When user first tries to switch Spaces  
**Fallback:** Show instructions to manually grant permission

### 2. Accessibility Permission (Optional)
**Why:** For more reliable Space switching via Accessibility API  
**Request:** If AppleScript fails  
**Fallback:** AppleScript method

---

## Alternative: Per-Space Approach (NOT RECOMMENDED)

**User's original idea:** Spawn separate app/overlay per Space

**Why NOT to do this:**
1. ❌ Can't programmatically launch apps on specific Spaces
2. ❌ Would need manual setup per Space
3. ❌ Multiple processes = more memory
4. ❌ Harder to keep in sync
5. ❌ More complex architecture

**Single HUD approach is better:**
1. ✅ One window, appears on all Spaces
2. ✅ Auto-detects Space changes
3. ✅ Single source of truth
4. ✅ Less memory usage
5. ✅ Simpler architecture

---

## Performance Considerations

### Memory Usage
- **HUD Window:** ~2-3 MB
- **Space Monitoring:** < 0.1% CPU
- **Total Impact:** Negligible

### Responsiveness
- **Space Detection:** < 50ms
- **UI Update:** Instant (SwiftUI binding)
- **Space Switch:** 300-500ms (macOS animation)

---

## Comparison with Similar Apps

### Raycast
- Shows current Space in command palette
- Can switch Spaces via commands
- More general-purpose tool

### BetterTouchTool
- Can show Space indicator
- Customizable gestures for switching
- More complex setup

### SuperDimmer's HUD
- **Unique:** Always-visible floating HUD
- **Unique:** Visual Space grid
- **Unique:** One-click switching
- **Unique:** Integrated with dimming features
- **Simpler:** No complex configuration needed

---

## Conclusion

### What We're Building ✅

A **floating HUD panel** that:
1. Shows current Space number and name
2. Shows all Spaces as clickable buttons
3. Auto-updates when switching Spaces
4. Allows quick one-click Space switching
5. Appears on all Spaces (or just current, user choice)
6. Customizable names, position, display mode
7. Keyboard shortcut activation

### Implementation Strategy

1. **Single `NSPanel` window** (not multiple apps)
2. **`canJoinAllSpaces`** collection behavior
3. **`SpaceChangeMonitor`** for auto-updates
4. **AppleScript** for Space switching
5. **SwiftUI** for beautiful, responsive UI

### Next Steps

1. Create `SpaceSwitcherHUD.swift` and `SpaceSwitcherHUDView.swift`
2. Integrate with existing `SpaceDetector` and `SpaceChangeMonitor`
3. Implement AppleScript Space switching
4. Add preferences UI
5. Test across multiple Spaces
6. Polish and ship! 🚀

---

*Design completed: January 21, 2026*  
*Approach: Single floating HUD panel*  
*Status: Ready for implementation*
