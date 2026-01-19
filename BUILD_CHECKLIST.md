# SuperDimmer Build Checklist
## Step-by-Step Implementation Guide with Verification Checkpoints
### Version 1.1 | January 12, 2026

---

## 📋 How to Use This Checklist

Each phase contains:
- **Tasks** with checkboxes `[ ]` → Mark `[x]` when complete
- **Build Checks** 🔨 → Verify xcodebuild succeeds
- **Test Checks** 🧪 → Manual or automated testing
- **Review Points** 👀 → Code review / quality checks

**Rule:** Do NOT proceed to next phase until all checks in current phase pass.

---

## 🏗️ PHASE 0: Project Setup & Environment
**Estimated Time: 1 day**

### 0.1 Development Environment
- [x] Xcode 15.0+ installed and updated
- [x] macOS 14.0+ (Sonoma) on development machine
- [ ] Apple Developer account active (for signing)
- [x] Git repository initialized with .gitignore
- [x] Mac app pushed to GitHub: https://github.com/ak/SuperDimmer ✅ (Jan 8, 2026)

### 0.2 Create Xcode Project
- [x] Create new macOS App project in Xcode
- [x] Set Product Name: `SuperDimmer`
- [x] Set Bundle Identifier: `com.superdimmer.app`
- [x] Set Interface: SwiftUI
- [x] Set Language: Swift
- [x] Set minimum deployment target: macOS 13.0
- [x] Save project to `/Users/ak/UserRoot/Github/SuperDimmer/SuperDimmer-Mac-App/`

### 0.3 Project Configuration
- [x] Configure app as menu bar only (LSUIElement = true in Info.plist)
- [x] Set app category: `public.app-category.utilities`
- [ ] Configure code signing (Developer ID for distribution)
- [x] Set up build configurations (Debug, Release)
- [x] Create SuperDimmer.entitlements file

### 0.4 Initial Entitlements Setup
- [x] Add `com.apple.security.device.screen-capture` entitlement
- [x] Add `com.apple.security.network.client` entitlement
- [x] Add `com.apple.security.automation.apple-events` entitlement
- [x] Add `com.apple.security.personal-information.location` entitlement

#### 🔨 BUILD CHECK 0.1
```bash
cd /Users/ak/UserRoot/Github/SuperDimmer/SuperDimmer-Mac-App
xcodebuild -scheme SuperDimmer -configuration Debug build 2>&1 | head -n 50
```
- [x] Build succeeds with no errors
- [x] Build succeeds with no warnings (or only expected warnings)

#### 🧪 TEST CHECK 0.1
- [x] App launches from Xcode
- [x] App appears in menu bar (no dock icon)
- [x] App quits cleanly

#### 👀 REVIEW POINT 0.1
- [x] Info.plist has all required keys
- [x] Entitlements file is properly linked to target
- [x] Bundle identifier matches intended value

---

## 🏗️ PHASE 1: Foundation (MVP)
**Estimated Time: 4 weeks**

### Week 1: Menu Bar Infrastructure

#### 1.1 Menu Bar App Structure
- [x] Create `SuperDimmerApp.swift` with @main entry point
- [x] Create `MenuBarController.swift` for NSStatusItem management
- [x] Implement basic menu bar icon (sun symbol)
- [x] Create dropdown menu with placeholder items
- [x] Add "Quit" menu item with ⌘Q shortcut

#### 🔨 BUILD CHECK 1.1
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build 2>&1 | tail -n 20
```
- [x] Build succeeds
- [x] No linker errors

#### 🧪 TEST CHECK 1.1
- [x] Menu bar icon appears on launch
- [x] Clicking icon shows dropdown menu (popover)
- [x] Quit command terminates app
- [x] App shows no dock icon

---

#### 1.2 Settings Management
- [x] Create `SettingsManager.swift` for UserDefaults wrapper
- [x] Define settings keys enum for type safety
- [x] Implement `isDimmingEnabled: Bool` setting
- [x] Implement `globalDimLevel: Double` setting (0.0-1.0)
- [x] Implement `brightnessThreshold: Double` setting (0.0-1.0)
- [x] Add settings change notification system

#### 🔨 BUILD CHECK 1.2
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [x] Build succeeds
- [x] No compiler warnings about optionals

#### 🧪 TEST CHECK 1.2
- [x] Settings persist after app restart
- [x] Default values load correctly on first launch
- [x] Settings changes notify observers

---

### Week 2: Basic Overlay System

#### 1.3 Overlay Window Foundation
- [x] Create `DimOverlayWindow.swift` (NSWindow subclass)
- [x] Configure borderless, transparent window
- [x] Set `ignoresMouseEvents = true` (click-through)
- [x] Set window level to `.screenSaver`
- [x] Configure `collectionBehavior` for all Spaces
- [x] Implement dim level property with animation

#### 🔨 BUILD CHECK 1.3
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [x] Build succeeds
- [x] NSWindow subclass compiles correctly

#### 🧪 TEST CHECK 1.3
- [x] Overlay window appears on screen
- [x] Overlay is click-through (can click items beneath)
- [x] Overlay dims content visibly
- [x] Overlay opacity can be changed

---

#### 1.4 Overlay Manager
- [x] Create `OverlayManager.swift` singleton
- [x] Implement full-screen overlay creation for each display
- [x] Implement overlay enable/disable methods
- [x] Handle display configuration changes
- [x] Add support for multi-monitor (create overlay per display)

#### 🔨 BUILD CHECK 1.4
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [x] Build succeeds

#### 🧪 TEST CHECK 1.4
- [x] Full-screen overlay covers entire display
- [ ] Overlay works on external monitors (not tested yet)
- [x] Disabling removes overlay completely
- [x] Re-enabling recreates overlay (no crashes!)

---

### Week 3: Menu Bar UI Integration

#### 1.5 Basic Controls UI
- [x] Create `MenuBarView.swift` (SwiftUI view for popover)
- [x] Implement master on/off toggle
- [x] Implement dim level slider (0-100%)
- [x] Wire controls to SettingsManager
- [x] Wire controls to OverlayManager
- [x] Add visual feedback for current state

#### 🔨 BUILD CHECK 1.5
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [x] Build succeeds
- [ ] SwiftUI previews render

#### 🧪 TEST CHECK 1.5
- [x] Toggle turns dimming on/off immediately
- [x] Slider adjusts dim level in real-time
- [x] UI reflects persisted state on launch

---

#### 1.6 Menu Bar Icon States
- [x] Create icon assets for different states
- [x] Implement icon state: Disabled (outline)
- [x] Implement icon state: Active (filled)
- [x] Update icon based on dimming enabled state
- [x] Support both light and dark menu bar

#### 🔨 BUILD CHECK 1.6
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [x] Build succeeds
- [x] Asset catalog has no warnings

#### 🧪 TEST CHECK 1.6
- [ ] Icon changes when toggling dimming
- [ ] Icon visible on light menu bar
- [ ] Icon visible on dark menu bar

---

### Week 4: Permission Handling & Polish

#### 1.7 Screen Recording Permission
- [x] Create `PermissionManager.swift`
- [x] Implement screen recording permission check
- [x] Implement permission request flow
- [x] Create user-facing permission explanation UI
- [x] Add deep link to System Settings → Privacy
- [x] Handle permission denied gracefully

#### 🔨 BUILD CHECK 1.7
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [x] Build succeeds
- [x] Privacy string present in Info.plist

#### 🧪 TEST CHECK 1.7
- [ ] Permission prompt appears when needed
- [ ] App functions correctly after permission granted
- [ ] App shows helpful message if permission denied
- [ ] Settings link opens correct System Settings pane

---

#### 1.8 Launch at Login
- [x] Add ServiceManagement framework
- [x] Create `LaunchAtLoginManager.swift`
- [x] Implement launch at login toggle
- [x] Add UI toggle in preferences
- [ ] Test login item registration

#### 🔨 BUILD CHECK 1.8
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [x] Build succeeds
- [x] ServiceManagement framework linked

#### 🧪 TEST CHECK 1.8
- [ ] Toggle adds app to login items
- [ ] Toggle removes app from login items
- [ ] Setting persists across app restarts

---

#### 1.9 Phase 1 Integration Testing

#### 🔨 BUILD CHECK - PHASE 1 FINAL
```bash
xcodebuild -scheme SuperDimmer -configuration Release build
```
- [ ] Release build succeeds
- [ ] No compiler warnings
- [ ] App size is reasonable (< 10 MB)

#### 🧪 TEST CHECK - PHASE 1 FINAL
- [ ] Fresh install works (delete app data, reinstall)
- [ ] All menu bar controls work
- [ ] Dimming persists across app restart
- [ ] Multi-monitor setup works
- [ ] Performance: CPU < 1% when idle
- [ ] Performance: Memory < 30 MB

#### 👀 REVIEW POINT - PHASE 1 COMPLETE
- [ ] Code follows Swift naming conventions
- [ ] All files have descriptive headers
- [ ] Comments explain "why" not just "what"
- [ ] No force unwraps without justification
- [ ] Error handling is comprehensive

---

## 🏗️ PHASE 2: Intelligent Detection
**Estimated Time: 3 weeks**

### Week 5: Screen Capture Service

#### 2.1 Screen Capture Implementation
- [x] Create `ScreenCaptureService.swift`
- [x] Implement `captureMainDisplay() -> CGImage?`
- [x] Implement `captureRegion(_ rect: CGRect) -> CGImage?`
- [x] Add capture throttling (max frequency)
- [x] Handle capture permission errors gracefully

#### 🔨 BUILD CHECK 2.1
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [x] Build succeeds
- [x] CoreGraphics properly linked

#### 🧪 TEST CHECK 2.1
- [ ] Screen capture returns valid CGImage
- [ ] Capture works with permission granted
- [ ] Capture fails gracefully without permission
- [ ] Capture throttling works correctly

---

#### 2.2 Brightness Analysis Engine
- [x] Create `BrightnessAnalysisEngine.swift`
- [x] Implement luminance calculation (Rec. 709)
- [x] Implement `averageLuminance(in: CGImage, rect: CGRect) -> Float`
- [x] Use Accelerate/vDSP for performance
- [x] Add downsampling for efficiency

#### 🔨 BUILD CHECK 2.2
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [x] Build succeeds
- [x] Accelerate framework linked

#### 🧪 TEST CHECK 2.2
- [ ] White image returns luminance ~1.0
- [ ] Black image returns luminance ~0.0
- [ ] Mixed content returns expected range
- [ ] Performance: Analysis < 50ms for full screen

---

### Week 6: Window Tracking

#### 2.3 Window Tracker Service
- [x] Create `WindowTrackerService.swift`
- [x] Create `TrackedWindow` struct with metadata
- [x] Implement `getVisibleWindows() -> [TrackedWindow]`
- [x] Parse CGWindowListCopyWindowInfo results
- [x] Filter out system UI, dock, menu bar

#### 🔨 BUILD CHECK 2.3
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [x] Build succeeds

#### 🧪 TEST CHECK 2.3
- [ ] Returns list of visible windows
- [ ] Window bounds are accurate
- [ ] Owner PID and name are correct
- [ ] System UI is filtered out

---

#### 2.4 Active Window Detection
- [x] Implement frontmost app tracking via NSWorkspace
- [x] Mark windows as active/inactive based on owner PID
- [x] Add notification observer for app activation changes
- [x] Cache frontmost app to reduce lookups

#### 🔨 BUILD CHECK 2.4
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [x] Build succeeds

#### 🧪 TEST CHECK 2.4
- [ ] Correct app identified as frontmost
- [ ] Windows marked correctly as active/inactive
- [ ] State updates when switching apps
- [ ] Performance: Tracking adds minimal overhead

---

### Week 7: Per-Window Dimming

#### 2.5 Per-Window Analysis Loop
- [x] Create `DimmingCoordinator.swift` (main controller)
- [x] Implement analysis loop with configurable interval
- [x] Analyze brightness per visible window
- [x] Compare against threshold setting
- [x] Generate dimming decisions per window

#### 🔨 BUILD CHECK 2.5
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [x] Build succeeds

#### 🧪 TEST CHECK 2.5
- [ ] Analysis loop runs at configured interval
- [ ] Bright windows detected correctly
- [ ] Dark windows not flagged for dimming
- [ ] Threshold setting affects detection

---

#### 2.6 Per-Window Overlays
- [x] Modify OverlayManager for per-window overlays
- [x] Create/update/remove overlays based on analysis
- [x] Apply active window dim level to active windows
- [x] Apply inactive window dim level to inactive windows
- [x] Implement smooth transition animations

#### 🔨 BUILD CHECK 2.6
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [x] Build succeeds

#### 🧪 TEST CHECK 2.6
- [ ] Per-window overlays appear correctly positioned
- [ ] Overlays track window movement
- [ ] Overlays resize with windows
- [ ] Active/inactive dim levels applied correctly
- [ ] Transitions are smooth, not jarring

---

### 2.7 Per-Region Detection Mode (NEW!)

> **KILLER FEATURE** - This is what differentiates SuperDimmer from other dimming apps!
> Instead of dimming entire windows, we can detect and dim specific BRIGHT AREAS within windows.
> Example: Dark mode Mail app with a bright white email open - only the email content gets dimmed.

#### 2.7.1 Detection Mode Settings
- [x] Add `DetectionMode` enum (perWindow, perRegion)
- [x] Add `detectionMode` property to SettingsManager
- [x] Add `regionGridSize` setting (4-16, default 8)
- [x] Persist detection mode to UserDefaults

#### 2.7.2 BrightRegionDetector Service
- [x] Create `BrightRegionDetector.swift`
- [x] Create brightness grid from image (NxN cells)
- [x] Implement threshold comparison per cell
- [x] Find connected components (adjacent bright cells)
- [x] Calculate bounding boxes for regions
- [x] Merge overlapping/adjacent regions

#### 2.7.3 Per-Region Coordinator Updates
- [x] Add `performPerRegionAnalysis()` to DimmingCoordinator
- [x] Switch between modes based on `detectionMode` setting
- [x] Generate `RegionDimmingDecision` structs
- [x] Calculate dim level per region based on brightness

#### 2.7.4 Per-Region Overlay Management
- [x] Add `RegionDimmingDecision` struct to OverlayManager
- [x] Add `regionOverlays` dictionary
- [x] Implement `applyRegionDimmingDecisions()`
- [x] Create overlays for each bright region
- [x] Include region overlays in hide/show/remove methods

#### 2.7.5 UI for Detection Mode
- [x] Add mode picker (Per Window / Per Region) to MenuBarView
- [x] Add grid precision slider for per-region mode
- [x] Show description text for selected mode

#### 🔨 BUILD CHECK 2.7
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [x] Build succeeds

#### 🧪 TEST CHECK 2.7
- [x] Mode picker switches correctly
- [x] Per-region mode detects bright areas in dark windows
- [x] Mail app test: bright email content detected separately
- [x] Grid precision slider affects detection granularity
- [x] Region overlays appear only on bright areas

---

### 2.8 Multiple Windows & Enhancements (Jan 8, 2026)

> **USER FEEDBACK**: Only one Mail window was being dimmed when multiple windows were visible.
> Fixed by analyzing ALL visible windows, not just the active one.

#### 2.8.1 Multiple Windows Dimming
- [x] Modified `performPerRegionAnalysis()` to analyze ALL visible windows
- [x] Removed `isActive` filter that limited analysis to frontmost window only
- [x] Region overlays now created for bright regions across ALL windows
- [x] Debug logging shows "Analyzing ALL N visible windows"

#### 2.8.2 Feathered/Blurred Edges (REMOVED - Use Rounded Corners Instead)
- [x] ~~Added `edgeBlurEnabled` setting~~ (removed - unreliable)
- [x] ~~Added `edgeBlurRadius` setting~~ (removed)
- [x] ~~Implemented `setEdgeBlur(enabled:radius:)`~~ (stubbed - does nothing)
- [x] ~~Created `createFeatheredMaskImage()`~~ (removed)
- [x] ~~Updated OverlayManager to apply edge blur~~ (removed)
- [x] ~~Added "Soft Edges" toggle~~ (removed from UI)

> **NOTE**: Mask-based feathered edges caused visual artifacts during animations.
> Replaced with simple corner radius (see 2.8.2b below).

#### 2.8.2b Rounded Corners for Overlays (NEW)

> **SIMPLER APPROACH**: Use `layer.cornerRadius` instead of complex mask.
> Reliable, performant, looks cleaner than hard rectangular edges.

- [ ] Add `overlayCornerRadius` setting to SettingsManager (0-20pt, default 8pt)
- [ ] Apply `layer.cornerRadius` in DimOverlayWindow.setupDimView()
- [ ] Set `layer.masksToBounds = true` to clip to rounded corners
- [ ] Add corner radius slider to Preferences (Brightness tab)
- [ ] Option to disable (set to 0) for sharp edges
- [ ] Ensure corner radius works with debug borders

#### BUILD CHECK 2.8.2b
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [ ] Build succeeds

#### TEST CHECK 2.8.2b
- [ ] Overlays have rounded corners (default 8pt)
- [ ] Corner radius slider adjusts roundness in real-time
- [ ] Setting to 0 gives sharp corners
- [ ] Rounded corners work with debug borders enabled
- [ ] No visual artifacts during overlay animations
- [ ] No visual artifacts during window resize
- [ ] Performance unchanged (corner radius is GPU-accelerated)

#### 2.8.3 Excluded Apps Feature
- [x] Added `excludedAppBundleIDs` setting to SettingsManager
- [x] Modified WindowTrackerService to filter out excluded apps
- [x] Created `ExcludedAppsPreferencesTab` in PreferencesView
- [x] Implemented running apps picker for quick exclusion
- [x] Added manual bundle ID entry field
- [x] Shows excluded apps in MenuBarView with "Manage" link

#### 2.8.4 SwiftUI AttributeGraph Warnings Fix
- [x] Fixed "AttributeGraph: cycle detected" warnings in MenuBarView
- [x] Used `DispatchQueue.main.async` to defer state changes from view updates
- [x] Applied fix to intelligent mode toggle handler

#### 🔨 BUILD CHECK 2.8
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [x] Build succeeds

#### 🧪 TEST CHECK 2.8
- [x] Multiple windows are all analyzed in per-region mode
- [x] ~~Soft edges toggle~~ (removed - see 2.8.2b Rounded Corners)
- [x] ~~Blur radius slider~~ (removed - see 2.8.2b Rounded Corners)
- [ ] Excluded apps no longer get dimmed
- [ ] No AttributeGraph cycle warnings in console

---

#### 2.9 UI Updates for Intelligent Mode ✅ (Jan 8, 2026)
- [x] Add threshold slider to MenuBarView (already existed)
- [x] Add active window dim slider
- [x] Add inactive window dim slider
- [x] Add toggle for active/inactive differentiation
- [x] Show real-time detection status indicator

#### 🔨 BUILD CHECK 2.9
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [x] Build succeeds
- [ ] SwiftUI previews render

#### 🧪 TEST CHECK 2.9
- [x] All new controls are functional
- [x] Threshold changes affect detection immediately
- [x] Dim level changes apply immediately

---

### 2.10 Inactivity Decay Dimming (WINDOW-LEVEL)

> **UNIQUE FEATURE** - Progressive dimming for windows that are not in use
> Windows that haven't been switched to will gradually increase in dimness over time
> until they hit a user-configurable maximum limit. This creates a visual hierarchy
> that emphasizes the active window while naturally de-emphasizing stale windows.
> 
> **Why this matters:** When you have many windows open, the ones you haven't used
> recently naturally fade more, helping you focus on what's active while keeping
> background windows accessible but less distracting.

#### 2.10.1 Decay Dimming Settings ✅ (Jan 8, 2026)
- [x] Add `inactivityDecayEnabled` setting to SettingsManager
- [x] Add `decayRate` setting (0.005-0.05 per second, default 0.01 = 1% per second)
- [x] Add `decayStartDelay` setting (seconds before decay starts, default 30 seconds)
- [x] Add `maxDecayDimLevel` setting (0.4-0.9, default 0.6 = 60% max dimming)
- [x] Persist decay settings to UserDefaults

#### 2.10.2 Window Inactivity Tracker ✅ (Jan 8, 2026)
- [x] Create `WindowInactivityTracker.swift`
- [x] Track `lastActiveTimestamp` per window ID
- [x] Update timestamp when window becomes active (frontmost app's windows)
- [x] Calculate `timeSinceLastActive` for each tracked window
- [x] Register/cleanup windows during analysis cycle

#### 2.10.3 Decay Dimming Logic in Coordinator ✅ (Jan 8, 2026)
- [x] Add `applyInactivityDecay()` method to DimmingCoordinator
- [x] Formula: `baseDimLevel + (decayRate * max(0, timeSinceActive - decayStartDelay))`
- [x] Clamp result to `maxDecayDimLevel`
- [x] Apply decay on top of existing inactive window dim level
- [x] Reset decay when window becomes active again

#### 2.10.4 Decay Dimming UI ✅ (Jan 8, 2026)
- [x] Add "Inactivity Decay" toggle to MenuBarView
- [x] Add decay rate slider with descriptive labels (Slow/Medium/Fast)
- [x] Add max decay level slider (40% - 90%)
- [x] Displays delay value in description text
- [ ] Show current decay status per window (optional debug view) - deferred

#### 🔨 BUILD CHECK 2.10
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [x] Build succeeds

#### 🧪 TEST CHECK 2.10
- [ ] Window starts decaying after delay when inactive
- [ ] Decay respects rate setting (gradual increase)
- [ ] Decay stops at max level (doesn't go darker)
- [ ] Switching to window resets decay immediately
- [ ] Decay settings persist across restart
- [ ] Performance: Decay tracking adds minimal overhead

---

### 2.11 Auto-Hide Inactive Apps (APP-LEVEL)

> **PRODUCTIVITY FEATURE** - Automatically hide apps that haven't been used for a while
> Unlike decay dimming (which is per-window), this feature operates at the APP level.
> After an app hasn't been in the foreground for a configurable duration, it gets hidden.
> This reduces visual clutter and helps focus on actively used applications.
>
> **Why this matters:** Over the course of a workday, many apps accumulate on screen
> that you opened briefly but forgot about. Auto-hiding them keeps your workspace clean
> without requiring manual intervention.

#### 2.11.1 Auto-Hide Settings
- [ ] Add `autoHideEnabled` setting to SettingsManager
- [ ] Add `autoHideDelay` setting (minutes before hiding, default 30 minutes)
- [ ] Add `autoHideExcludedApps` setting (Set<String> of bundle IDs)
- [ ] Add `autoHideExcludeSystemApps` setting (default true - Finder, etc.)
- [ ] Persist auto-hide settings to UserDefaults

#### 2.11.2 App Inactivity Tracker
- [ ] Create `AppInactivityTracker.swift` service
- [ ] Track `lastForegroundTimestamp` per bundle ID
- [ ] Update timestamp when app becomes frontmost (NSWorkspace observer)
- [ ] Calculate `timeSinceLastForeground` for each running app
- [ ] Maintain list of apps that should be auto-hidden

#### 2.11.3 Auto-Hide Logic
- [ ] Create `AutoHideManager.swift` service
- [ ] Implement `hideApp(bundleID:)` using NSRunningApplication.hide()
- [ ] Check inactivity timer periodically (every 60 seconds)
- [ ] Skip excluded apps (user-defined + system apps if setting enabled)
- [ ] Skip apps with unsaved changes (if detectable via Accessibility)
- [ ] Log auto-hide actions for user transparency

#### 2.11.4 Auto-Hide UI
- [ ] Add "Auto-Hide Inactive Apps" toggle to Preferences
- [ ] Add auto-hide delay slider (5 min - 120 min)
- [ ] Add excluded apps list editor (reuse ExcludedAppsPreferencesTab pattern)
- [ ] Add "Exclude system apps" checkbox
- [ ] Show notification when app is auto-hidden (optional)
- [ ] Add "Recently Auto-Hidden" list with "Unhide" buttons

#### 🔨 BUILD CHECK 2.11
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [ ] Build succeeds

#### 🧪 TEST CHECK 2.11
- [ ] Apps are hidden after inactivity delay
- [ ] Excluded apps are never auto-hidden
- [ ] Using app resets its inactivity timer
- [ ] Auto-hide settings persist across restart
- [ ] Notification shown when app hidden (if enabled)
- [ ] Hidden apps can be unhidden from list

---

#### 2.12 Phase 2 Integration Testing

### 2.12 Hidden App Overlay Cleanup ⬜ (NEW)

> **BUG FIX**: When apps are hidden (Cmd+H), their overlays remain visible.
> Overlay refresh should be triggered when an app is hidden to remove stale overlays.

#### 2.12.1 Hidden App Detection
- [ ] Add NSWorkspace observer for `didHideApplicationNotification`
- [ ] Track hidden app bundle IDs in a set
- [ ] When app is hidden, immediately remove all overlays for that app
- [ ] When app is unhidden, trigger re-analysis to create overlays if needed

#### 2.12.2 Overlay Manager Updates
- [ ] Add `removeOverlaysForApp(bundleID:)` method to OverlayManager
- [ ] Integrate hidden app observer with OverlayManager
- [ ] Add `removeOverlaysForHiddenWindows()` to cleanup method
- [ ] Call cleanup on app hide/unhide events, not just on timer

#### 🔨 BUILD CHECK 2.12
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [ ] Build succeeds

#### 🧪 TEST CHECK 2.12
- [ ] Hide app (Cmd+H) → Overlays disappear immediately
- [ ] Unhide app → Overlays reappear if content is bright
- [ ] No orphaned overlays remain for hidden apps

---

### 2.13 Dynamic Overlay Tracking & Scaling ⬜ (NEW)

> **PERFORMANCE FEATURE**: Overlays should follow window position and scale
> in real-time without waiting for screenshot analysis (every 2 seconds).
> This prevents visual lag when moving or resizing windows.

#### 2.13.1 Window Position/Size Tracking
- [ ] Add lightweight window tracking timer (0.1-0.2 second interval)
- [ ] Track window frame changes via CGWindowListCopyWindowInfo
- [ ] Compare current frame to last known frame for each tracked window
- [ ] Update overlay position/size immediately on change detection
- [ ] This is separate from the expensive screenshot-based brightness analysis

#### 2.13.2 Overlay Layer Management
- [ ] Ensure overlays are always layered correctly above their target windows
- [ ] Add window level tracking per overlay (based on target window level)
- [ ] When target window changes level, update overlay level immediately
- [ ] Prevent 2-second delay before overlay appears above window after switch

#### 2.13.3 Frame Change Response
- [ ] Implement `updateOverlayFrames()` method (fast, no screenshot)
- [ ] Call `updateOverlayFrames()` at high frequency (5-10 Hz)
- [ ] Call full `performAnalysis()` at low frequency (0.5-2 Hz)
- [ ] Animate overlay frame changes for smooth transitions

#### 🔨 BUILD CHECK 2.13
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [ ] Build succeeds

#### 🧪 TEST CHECK 2.13
- [ ] Move window → Overlay follows in real-time (no lag)
- [ ] Resize window → Overlay scales smoothly
- [ ] Window z-order change → Overlay updates layer immediately
- [ ] Performance: Light tracking adds minimal CPU overhead

---

### 2.14 Separate Window vs Zone Dimming Modes ⬜ (NEW)

> **UX IMPROVEMENT**: Split "Intelligent Mode" into two clear options:
> 1. Intelligent Window Dimming - dims entire windows based on brightness
> 2. Intelligent Zone Dimming - dims specific bright areas within windows
> Users should be able to enable one, the other, both, or neither independently.

#### 2.14.1 Settings Updates
- [ ] Rename `intelligentDimmingEnabled` to `intelligentWindowDimmingEnabled`
- [ ] Add `intelligentZoneDimmingEnabled` setting
- [ ] Both can be enabled independently
- [ ] If neither enabled, use simple full-screen overlay mode

#### 2.14.2 UI Updates
- [ ] Replace single "Intelligent Mode" toggle with two separate toggles
- [ ] "Intelligent Window Dimming" - dims bright windows
- [ ] "Intelligent Zone Dimming" - dims bright areas in windows
- [ ] Clear descriptions for each mode

#### 2.14.3 Coordinator Updates
- [ ] Update DimmingCoordinator to respect both settings independently
- [ ] When window dimming enabled: analyze and dim whole windows
- [ ] When zone dimming enabled: find bright regions within windows
- [ ] When both enabled: combine (zone dimming within window dimming)

#### 🔨 BUILD CHECK 2.14
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [ ] Build succeeds

#### 🧪 TEST CHECK 2.14
- [ ] Window dimming only → Whole windows dimmed
- [ ] Zone dimming only → Only bright areas dimmed
- [ ] Both enabled → Bright zones in all windows dimmed
- [ ] Neither enabled → Full-screen overlay only

---

### 2.15 Expanded Exclusion Lists ⬜ (NEW)

> **PRO FEATURE**: Different exclusion lists (or checkboxes) for different behaviors:
> - Exclude from auto-hide
> - Exclude from auto-minimize
> - Exclude from dimming
> Each app can have independent settings for each behavior.

#### 2.15.1 Settings Updates
- [ ] Keep existing `excludedAppBundleIDs` (for dimming)
- [ ] Keep existing `autoHideExcludedApps` (for auto-hide)
- [ ] Keep existing `autoMinimizeExcludedApps` (for auto-minimize)
- [ ] Create unified `AppExclusion` struct with per-behavior flags
- [ ] Add `appExclusions: [String: AppExclusion]` dictionary keyed by bundleID

#### 2.15.2 AppExclusion Data Model
- [ ] Create `AppExclusion` struct with:
  - `excludeFromDimming: Bool`
  - `excludeFromAutoHide: Bool`
  - `excludeFromAutoMinimize: Bool`
- [ ] Migration: Convert existing arrays to new format on first launch
- [ ] Persist as JSON in UserDefaults

#### 2.15.3 UI Updates
- [ ] Create unified "Excluded Apps" tab in Preferences
- [ ] Show list of apps with checkboxes for each exclusion type
- [ ] Allow adding apps from running apps or Applications folder
- [ ] Visual columns: App Name | Dimming | Auto-Hide | Auto-Minimize

#### 🔨 BUILD CHECK 2.15
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [ ] Build succeeds

#### 🧪 TEST CHECK 2.15
- [ ] App excluded from dimming → Not dimmed, still auto-hides
- [ ] App excluded from auto-hide → Dimmed, not auto-hidden
- [ ] App excluded from all → No SuperDimmer actions
- [ ] Migration from old format works

---

#### 🔨 BUILD CHECK - PHASE 2 FINAL
```bash
xcodebuild -scheme SuperDimmer -configuration Release build
```
- [ ] Release build succeeds
- [ ] No new warnings introduced

#### 🧪 TEST CHECK - PHASE 2 FINAL
- [ ] Open white webpage in dark browser → dims correctly
- [ ] Switch active app → dim levels swap
- [ ] Resize window → overlay tracks
- [ ] Close window → overlay removed
- [ ] Open new window → overlay created if bright
- [ ] Hidden app → overlays removed
- [ ] Window moved → overlay follows in real-time
- [ ] Performance: CPU < 5% during active analysis
- [ ] Performance: Memory < 50 MB with many overlays

#### 👀 REVIEW POINT - PHASE 2 COMPLETE
- [ ] Dimming coordinator logic is clean
- [ ] No memory leaks with overlay creation/destruction
- [ ] Error handling for edge cases (hidden windows, etc.)
- [ ] Overlay tracking is responsive

---

## 🏗️ PHASE 3: Color Temperature
**Estimated Time: 2 weeks**
**NOTE: Basic implementation completed early (Jan 7, 2026) - advanced features pending**

### Week 8: Gamma Control

#### 3.1 Color Temperature Engine
- [x] Create `ColorTemperatureManager.swift` (named Manager not Engine)
- [x] Implement Kelvin to RGB conversion (Tanner Helland algorithm)
- [x] Implement `applyTemperature(_ kelvin: Double)`
- [x] Use CGSetDisplayTransferByFormula API
- [ ] Handle multi-display independently (applies to all currently)

#### 🔨 BUILD CHECK 3.1
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [x] Build succeeds

#### 🧪 TEST CHECK 3.1
- [x] 6500K shows no color shift (daylight)
- [x] 2700K shows warm orange tint
- [x] 1900K shows strong warm tint
- [ ] Changes apply to correct display (currently applies to all)

---

#### 3.2 Temperature Presets
- [x] Define preset temperatures (Daylight, Sunset, Night, Candlelight)
- [x] Create TemperaturePreset enum with Kelvin values
- [x] Implement preset selection UI (buttons in MenuBarView)
- [x] Add custom temperature slider (1900K-6500K)

#### 🔨 BUILD CHECK 3.2
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [x] Build succeeds

#### 🧪 TEST CHECK 3.2
- [x] Presets apply correct temperatures
- [x] Custom slider works across full range
- [x] UI shows current temperature/preset

---

### Week 9: Scheduling

#### 3.3 Time-Based Scheduling ✅ (Jan 8, 2026)
- [x] Create `ScheduleManager.swift`
- [x] Implement manual time schedule (start time, end time)
- [x] Add day/night temperature settings
- [x] Implement gradual transition over duration
- [x] Use Timer for schedule checking
- [x] Add Schedule UI in Preferences (ColorPreferencesTab)

#### 🔨 BUILD CHECK 3.3
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [x] Build succeeds

#### 🧪 TEST CHECK 3.3
- [ ] Schedule triggers at configured time
- [ ] Transition is gradual, not instant
- [x] Schedule persists across restart

---

#### 3.4 Sunrise/Sunset Automation ✅ (Jan 8, 2026)
- [x] Add CoreLocation framework (already in project.yml)
- [x] Create `LocationService.swift`
- [x] Request location permission
- [x] Calculate sunrise/sunset times (NOAA Solar Calculator algorithm)
- [x] Auto-adjust schedule based on location
- [x] Integrated with ScheduleManager

#### 🔨 BUILD CHECK 3.4
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [x] Build succeeds
- [x] CoreLocation linked
- [x] Privacy string in Info.plist

#### 🧪 TEST CHECK 3.4
- [ ] Location permission request shows
- [ ] Sunrise/sunset times calculated correctly
- [ ] Schedule follows sun times
- [x] Works without location (falls back to manual)

---

#### 3.5 Color Temperature UI ✅ (Jan 8, 2026)
- [x] Add temperature section to MenuBarView
- [x] Add enable/disable toggle for color temp
- [x] Add preset buttons (Day, Sunset, Night, Candle)
- [x] Add temperature slider (1900K-6500K)
- [x] Add schedule configuration in Preferences
- [x] Day/Night temperature sliders
- [x] Manual schedule time pickers
- [x] Sunrise/sunset toggle
- [x] Transition duration slider

#### 🔨 BUILD CHECK 3.5
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [x] Build succeeds

#### 🧪 TEST CHECK 3.5
- [x] All temperature controls functional
- [x] Toggle enables/disables color shift
- [x] Schedule UI is intuitive

---

#### 🔨 BUILD CHECK - PHASE 3 FINAL
```bash
xcodebuild -scheme SuperDimmer -configuration Release build
```
- [ ] Release build succeeds

#### 🧪 TEST CHECK - PHASE 3 FINAL
- [ ] Color temperature + dimming work together
- [ ] Schedule triggers reliably
- [ ] Location-based schedule works
- [ ] Performance unchanged from Phase 2

#### 👀 REVIEW POINT - PHASE 3 COMPLETE
- [ ] Gamma restoration on quit (reset to default)
- [ ] No color artifacts or flickering
- [ ] Schedule edge cases handled (midnight crossing, DST)

---

## 🏗️ PHASE 4: Wallpaper Features
**Estimated Time: 2 weeks**

### Week 10: Wallpaper Management

#### 4.1 Wallpaper Service
- [ ] Create `WallpaperManager.swift`
- [ ] Implement get current wallpaper URL
- [ ] Implement set wallpaper for space
- [ ] Handle per-display wallpapers
- [ ] Use NSWorkspace wallpaper APIs

#### 🔨 BUILD CHECK 4.1
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [ ] Build succeeds

#### 🧪 TEST CHECK 4.1
- [ ] Can read current wallpaper
- [ ] Can set new wallpaper
- [ ] Works on multiple displays

---

#### 4.2 Light/Dark Wallpaper Pairs
- [ ] Create data model for wallpaper pairs
- [ ] Implement pair storage/retrieval
- [ ] Create UI for selecting light wallpaper
- [ ] Create UI for selecting dark wallpaper
- [ ] Save pairs in UserDefaults/files

#### 🔨 BUILD CHECK 4.2
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [ ] Build succeeds

#### 🧪 TEST CHECK 4.2
- [ ] Can select light and dark wallpapers
- [ ] Pairs persist across restart
- [ ] Can have multiple pairs (per space)

---

### Week 11: Auto-Switching

#### 4.3 Appearance Observer
- [ ] Create `AppearanceObserver.swift`
- [ ] Observe system appearance changes
- [ ] Detect Light Mode ↔ Dark Mode switch
- [ ] Trigger wallpaper switch on change

#### 🔨 BUILD CHECK 4.3
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [ ] Build succeeds

#### 🧪 TEST CHECK 4.3
- [ ] Appearance change detected reliably
- [ ] Wallpaper switches when mode changes
- [ ] Works with "Auto" appearance setting

---

#### 4.4 Wallpaper Dimming ⬜ (ENHANCED)
- [ ] Implement desktop-only overlay (sits below all windows)
- [ ] Create overlay at window level `.desktop` or equivalent
- [ ] Add wallpaper dim amount setting (0-80%)
- [ ] Add wallpaper dim toggle to main menu bar UI
- [ ] Wire to schedule system (dim wallpaper at night)
- [ ] Support per-display wallpaper dimming

#### 🔨 BUILD CHECK 4.4
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [ ] Build succeeds

#### 🧪 TEST CHECK 4.4
- [ ] Wallpaper dimmed, windows NOT affected
- [ ] Dim level adjustable via slider
- [ ] Toggle enables/disables immediately
- [ ] Works on all connected displays

---

#### 4.5 Wallpaper UI
- [ ] Add wallpaper section to Preferences
- [ ] Add auto-switch toggle
- [ ] Add wallpaper pair selector
- [ ] Add wallpaper dim slider
- [ ] Add preview thumbnails

#### 🔨 BUILD CHECK 4.5
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [ ] Build succeeds

#### 🧪 TEST CHECK 4.5
- [ ] UI is intuitive and polished
- [ ] Thumbnails show correctly
- [ ] All controls functional

---

#### 🔨 BUILD CHECK - PHASE 4 FINAL
```bash
xcodebuild -scheme SuperDimmer -configuration Release build
```
- [ ] Release build succeeds

#### 🧪 TEST CHECK - PHASE 4 FINAL
- [ ] All wallpaper features work together
- [ ] Switch appearance → wallpaper changes
- [ ] Wallpaper dimming works correctly
- [ ] No visual glitches during switch

#### 👀 REVIEW POINT - PHASE 4 COMPLETE
- [ ] Wallpaper permissions handled (AppleEvents)
- [ ] Edge cases: missing wallpaper files, permission denied

---

## 🏗️ PHASE 5: Pro Features & Licensing
**Estimated Time: 3 weeks**

### Week 12: Paddle Integration

#### 5.1 Paddle SDK Setup
- [ ] Create Paddle developer account
- [ ] Get Paddle SDK framework
- [ ] Add Paddle.framework to project
- [ ] Configure product in Paddle dashboard
- [ ] Create `LicenseManager.swift`

#### 🔨 BUILD CHECK 5.1
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [ ] Build succeeds
- [ ] Paddle framework linked

#### 🧪 TEST CHECK 5.1
- [ ] Paddle SDK initializes without error
- [ ] Can communicate with Paddle API (sandbox)

---

#### 5.2 License Validation
- [ ] Implement license key validation
- [ ] Implement trial period management
- [ ] Store license state securely
- [ ] Create license state enum (Free, Trial, Pro, Expired)
- [ ] Add license check on app launch

#### 🔨 BUILD CHECK 5.2
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [ ] Build succeeds

#### 🧪 TEST CHECK 5.2
- [ ] Valid license activates Pro features
- [ ] Invalid license shows error
- [ ] Trial countdown works
- [ ] License persists across restart

---

#### 5.3 Feature Gating
- [ ] Create `FeatureGate.swift`
- [ ] Define Pro-only features list
- [ ] Gate intelligent detection (Pro)
- [ ] Gate per-app rules (Pro)
- [ ] Gate multi-display (Pro)
- [ ] Gate color temperature (Pro)
- [ ] Gate wallpaper features (Pro)
- [ ] Show upgrade prompts for gated features

#### 🔨 BUILD CHECK 5.3
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [ ] Build succeeds

#### 🧪 TEST CHECK 5.3
- [ ] Free tier: Only full-screen dim works
- [ ] Pro tier: All features unlocked
- [ ] Upgrade prompts show correctly

---

### Week 13: Per-App Rules

#### 5.4 App Rules Engine
- [ ] Create `AppRulesManager.swift`
- [ ] Create `AppRule` data model
- [ ] Implement rule types: Always dim, Never dim, Custom
- [ ] Store rules with app bundle ID
- [ ] Apply rules during dimming analysis

#### 🔨 BUILD CHECK 5.4
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [ ] Build succeeds

#### 🧪 TEST CHECK 5.4
- [ ] "Never dim" rule prevents dimming for app
- [ ] "Always dim" forces dimming regardless of brightness
- [ ] Custom threshold works per-app

---

#### 5.5 App Rules UI
- [ ] Create app list view showing running apps
- [ ] Create rule editor sheet
- [ ] Allow browsing /Applications for apps
- [ ] Show rule status in list
- [ ] Add to Preferences window

#### 🔨 BUILD CHECK 5.5
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [ ] Build succeeds

#### 🧪 TEST CHECK 5.5
- [ ] Can add/edit/delete rules
- [ ] Rules list shows correctly
- [ ] App icons display

---

### Week 14: Keyboard Shortcuts & Polish

#### 5.6 Keyboard Shortcuts
- [ ] Add KeyboardShortcuts library (SPM)
- [ ] Create `KeyboardShortcutsManager.swift`
- [ ] Implement toggle dimming shortcut
- [ ] Implement increase/decrease dim shortcuts
- [ ] Add shortcut configuration UI
- [ ] Use standard shortcut recording control

#### 🔨 BUILD CHECK 5.6
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [ ] Build succeeds
- [ ] SPM dependency resolves

#### 🧪 TEST CHECK 5.6
- [ ] Shortcuts trigger actions globally
- [ ] Shortcuts can be customized
- [ ] Shortcuts don't conflict with system

---

#### 5.7 Sparkle Auto-Updates
- [ ] Add Sparkle framework (SPM)
- [ ] Configure SUFeedURL in Info.plist
- [ ] Generate EdDSA key pair
- [ ] Add public key to Info.plist
- [ ] Create `UpdateManager.swift`
- [ ] Add update check menu item

#### 🔨 BUILD CHECK 5.7
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [ ] Build succeeds
- [ ] Sparkle linked

#### 🧪 TEST CHECK 5.7
- [ ] Manual update check works
- [ ] Sparkle UI shows correctly
- [ ] Test with local appcast

---

#### 5.8 Preferences Window Polish
- [ ] Create full Preferences window (SwiftUI)
- [ ] Implement tab navigation
- [ ] Polish General tab
- [ ] Polish Brightness tab
- [ ] Polish Color tab
- [ ] Polish Wallpaper tab
- [ ] Polish Apps tab
- [ ] Polish Displays tab
- [ ] Polish License tab
- [ ] Add About section

#### 🔨 BUILD CHECK 5.8
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [ ] Build succeeds

#### 🧪 TEST CHECK 5.8
- [ ] All tabs navigate correctly
- [ ] All settings save correctly
- [ ] UI is beautiful and polished

---

### 5.9 Simplified Menu Bar UI ⬜ (NEW)

> **UX IMPROVEMENT**: Move all adjustment sliders to Preferences.
> Menu bar popover should be simple: toggles, status, and quick access.
> This reduces overwhelm and makes the app easier to understand.

#### 5.9.1 Menu Bar UI Simplification
- [ ] Remove all sliders from MenuBarView (move to Preferences)
- [ ] Keep only: Master toggle, Status indicator, Quick actions
- [ ] Show summary of current settings (e.g., "Dimming: 25%, Threshold: 85%")
- [ ] Add "Adjust Settings..." button that opens Preferences
- [ ] Keep Temporary Disable section (important for quick access)
- [ ] Keep Excluded Apps count (link to Preferences)

#### 5.9.2 Menu Bar Quick Settings
- [ ] Main dimming toggle (ON/OFF)
- [ ] Color temperature toggle (ON/OFF)
- [ ] Wallpaper dimming toggle (ON/OFF)
- [ ] Dark/Light mode toggle (new)
- [ ] Current status summary

#### 5.9.3 New Menu Bar Icon ⬜ (NEW)
- [ ] Design new icon (not sun - differentiate from other apps)
- [ ] Options: moon, eye, contrast, brightness, spotlight
- [ ] Create SF Symbol-based icon or custom asset
- [ ] Add icon states: disabled, active, temperature active
- [ ] Support both light and dark menu bar

#### 🔨 BUILD CHECK 5.9
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [ ] Build succeeds

#### 🧪 TEST CHECK 5.9
- [ ] Menu bar popover is simpler
- [ ] All settings accessible from Preferences
- [ ] New icon is distinctive and clear
- [ ] Quick toggles work correctly

---

### 5.10 Dark/Light Mode Support ⬜ (NEW)

> **FEATURE**: Allow users to enable/disable SuperDimmer based on system appearance.
> Options: Always On, Only in Light Mode, Only in Dark Mode, Follow System

#### 5.10.1 Appearance Mode Settings
- [ ] Add `appearanceMode` setting: always, lightOnly, darkOnly, system
- [ ] When "lightOnly": disable dimming in dark mode automatically
- [ ] When "darkOnly": disable dimming in light mode automatically
- [ ] When "system": enable dimming regardless of appearance
- [ ] Add appearance observer (NSApp.effectiveAppearance)

#### 5.10.2 UI Updates
- [ ] Add appearance mode picker to Preferences (General tab)
- [ ] Add quick toggle in menu bar: "Dark Mode" / "Light Mode" / "Auto"
- [ ] Show current appearance state in status

#### 5.10.3 Appearance-Based Auto-Adjustments
- [ ] Option to use different dim levels for light vs dark mode
- [ ] Light mode: typically need more dimming (content is brighter)
- [ ] Dark mode: typically need less dimming
- [ ] User can configure different thresholds per mode

#### 🔨 BUILD CHECK 5.10
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [ ] Build succeeds

#### 🧪 TEST CHECK 5.10
- [ ] "Light Only" mode disables dimming in dark mode
- [ ] "Dark Only" mode disables dimming in light mode
- [ ] Appearance toggle works
- [ ] Different settings per mode work

---

### 5.11 Default Settings & Reset ⬜ (NEW)

> **UX IMPROVEMENT**: Provide sensible defaults and easy reset option.
> Users should be able to restore defaults without reinstalling.

#### 5.11.1 Default Settings Profile
- [ ] Document all default values in code comments
- [ ] Create "Balanced" defaults that work for most users
- [ ] Create "Aggressive" preset (more dimming, lower threshold)
- [ ] Create "Subtle" preset (less dimming, higher threshold)
- [ ] Add "Reset to Defaults" button in Preferences

#### 5.11.2 Settings Presets
- [ ] Add preset system: Balanced, Aggressive, Subtle, Custom
- [ ] Save current settings as custom preset
- [ ] Load preset with one click
- [ ] Presets stored in UserDefaults

#### 5.11.3 First Launch Defaults
- [ ] Review and optimize first-launch experience
- [ ] Dimming OFF by default (user must consciously enable)
- [ ] Show recommended settings based on display brightness
- [ ] Offer preset selection during onboarding

#### 🔨 BUILD CHECK 5.11
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [ ] Build succeeds

#### 🧪 TEST CHECK 5.11
- [ ] Reset to defaults works
- [ ] Presets apply correctly
- [ ] First launch shows sensible state

---

#### 🔨 BUILD CHECK - PHASE 5 FINAL
```bash
xcodebuild -scheme SuperDimmer -configuration Release build
```
- [ ] Release build succeeds
- [ ] App size reasonable (< 20 MB with frameworks)

#### 🧪 TEST CHECK - PHASE 5 FINAL
- [ ] Full free → Pro upgrade flow works
- [ ] License activation/deactivation works
- [ ] All Pro features gated correctly
- [ ] Shortcuts work system-wide
- [ ] Update mechanism works

#### 👀 REVIEW POINT - PHASE 5 COMPLETE
- [ ] No license bypass possible
- [ ] Graceful handling of network errors (license check)
- [ ] All UI strings are polished

---

## 🏗️ PHASE 6: Launch Preparation
**Estimated Time: 2 weeks**

### Week 15: Distribution Setup

#### 6.1 Code Signing & Notarization
- [ ] Configure Developer ID signing
- [ ] Enable hardened runtime
- [ ] Test app runs with hardened runtime
- [ ] Create notarization script
- [ ] Submit for notarization
- [ ] Verify notarization succeeds
- [ ] Staple notarization ticket

#### 🔨 BUILD CHECK 6.1
```bash
xcodebuild -scheme SuperDimmer -configuration Release archive
```
- [ ] Archive creates successfully
- [ ] Archive is properly signed

#### 🧪 TEST CHECK 6.1
- [ ] App runs on clean macOS (no dev tools)
- [ ] No Gatekeeper warnings
- [ ] Notarization ticket stapled

---

#### 6.2 Sparkle Appcast Setup
- [ ] Create appcast.xml template
- [ ] Set up hosting for appcast (S3, GitHub, etc.)
- [ ] Create release notes format
- [ ] Generate delta updates (optional)
- [ ] Test update flow end-to-end

#### 🧪 TEST CHECK 6.2
- [ ] Appcast accessible at SUFeedURL
- [ ] Update downloads correctly
- [ ] Signature verification passes

---

#### 6.3 Website & Purchase Flow
- [x] Create landing page for superdimmer.com ✅ (Jan 8, 2026 - marketing website created)
- [ ] Deploy website to hosting (Cloudflare Pages recommended)
- [ ] Integrate Paddle checkout
- [ ] Set up license key delivery
- [ ] Create download page with DMG/ZIP links
- [ ] Test full purchase → download → activate flow

**Website Status (Jan 8, 2026):**
- Repository: https://github.com/ak/SuperDimmer-Website
- Features: Hero section, features grid, how-it-works flow, pricing tiers (Free/Pro), CTA, footer
- Design: Dark theme with warm amber accents, Cormorant Garamond + Sora typography
- Tech: Pure HTML/CSS, responsive, CSS animations

**Recommended Hosting Options:**
| Option | Pros | Cons | Best For |
|--------|------|------|----------|
| **Cloudflare Pages** ⭐ | Free, fast global CDN, auto-deploys from GitHub, free SSL, DDoS protection | Limited build minutes (500/mo free) | Static sites, best overall |
| **GitHub Pages** | Free, simple, already on GitHub | No server functions, slower CDN | Very simple static sites |
| **Vercel** | Fast, excellent DX, serverless functions | Limited bandwidth on free tier | If you need serverless |
| **Netlify** | Easy forms/functions, good DX | Limited bandwidth (100GB/mo) | If you need forms |

**Recommendation: Cloudflare Pages** - Best for a marketing site with potential for future growth.

#### 🧪 TEST CHECK 6.3
- [ ] Website loads correctly on production domain
- [ ] Paddle checkout works (sandbox)
- [ ] License delivered after purchase
- [ ] Download link works

---

### Week 16: Final Testing & Launch

#### 6.4 Beta Testing
- [ ] Create beta distribution (separate signing)
- [ ] Recruit beta testers (5-10)
- [ ] Gather feedback
- [ ] Fix critical issues
- [ ] Iterate on UX concerns

#### 🧪 TEST CHECK 6.4
- [ ] All beta-reported bugs fixed
- [ ] No crash reports
- [ ] Performance acceptable

---

#### 6.5 Documentation
- [ ] Write getting started guide
- [ ] Write FAQ
- [ ] Document all features
- [ ] Create troubleshooting guide
- [ ] Add permission help docs

---

#### 6.6 Marketing Materials
- [ ] Create app icon (final polish)
- [ ] Create screenshots for website
- [ ] Create demo video
- [ ] Write press kit
- [ ] Prepare launch announcement

---

#### 6.7 Pre-Launch Verification

#### 🔨 BUILD CHECK - FINAL RELEASE
```bash
xcodebuild -scheme SuperDimmer -configuration Release archive -archivePath SuperDimmer.xcarchive
```
- [ ] Final archive builds
- [ ] Archive exports for distribution
- [ ] DMG/ZIP created for download

#### 🧪 FINAL TEST CHECKLIST
- [ ] Fresh install on clean Mac
- [ ] All permissions work correctly
- [ ] Free tier functions correctly
- [ ] Purchase and activate Pro license
- [ ] All Pro features work
- [ ] Update from older version works
- [ ] Quit and restart maintains state
- [ ] Works on multiple macOS versions (13, 14)
- [ ] Works on Intel and Apple Silicon
- [ ] CPU usage acceptable (< 5% active, < 0.5% idle)
- [ ] Memory usage acceptable (< 50 MB)
- [ ] No crashes in 24-hour soak test

#### 👀 FINAL REVIEW
- [ ] All code reviewed
- [ ] All strings localized (or English-only noted)
- [ ] Privacy policy created
- [ ] Terms of service created
- [ ] Support email configured

---

## ✅ LAUNCH CHECKLIST

- [ ] Final release build created
- [ ] Notarization complete
- [ ] Appcast published
- [ ] Website live
- [ ] Paddle checkout live (not sandbox)
- [ ] Download link active
- [ ] Support email ready
- [ ] Social media announcement prepared
- [ ] **🚀 LAUNCH!**

---

## 📊 Post-Launch Monitoring

### First 24 Hours
- [ ] Monitor crash reports (Sentry)
- [ ] Monitor support emails
- [ ] Monitor social media mentions
- [ ] Check download counts
- [ ] Check conversion rates

### First Week
- [ ] Release patch if critical issues
- [ ] Respond to all support requests
- [ ] Gather feature requests
- [ ] Plan v1.1 based on feedback

---

## 🔧 TROUBLESHOOTING LOG

### January 19, 2026 - Build Failure: UpdateChecker.swift Not Included in Xcode Project

**Issue:**
Build was failing with multiple "cannot find 'UpdateChecker' in scope" errors in:
- MenuBarView.swift (lines 1108, 1116)
- PreferencesView.swift (lines 225, 231)
- SettingsManager.swift (line 491)
- SuperDimmerApp.swift (line 119)

**Root Cause:**
The `UpdateChecker.swift` file existed in the `SuperDimmer/Services/` directory but was not included in the Xcode project file (`project.pbxproj`). This meant the Swift compiler couldn't find the class during compilation.

**Solution:**
Added `UpdateChecker.swift` to the Xcode project by editing `project.pbxproj`:
1. Added PBXFileReference entry with ID `UC9876543210FEDCBA987654`
2. Added file to Services group (PBXGroup section)
3. Added PBXBuildFile entry with ID `UC1234567890ABCDEF123456`
4. Added to Sources build phase (PBXSourcesBuildPhase section)

**Verification:**
```bash
cd /Users/ak/UserRoot/Github/SuperDimmer/SuperDimmer-Mac-App
xcodebuild -project SuperDimmer.xcodeproj -scheme SuperDimmer -configuration Release build
# Result: BUILD SUCCEEDED ✅
```

**Lessons Learned:**
- When adding new Swift files to the project via file system (not Xcode), they must be manually added to `project.pbxproj`
- Always verify new service files are included in the build by checking for them in the project file
- Use `grep UpdateChecker.swift project.pbxproj` to verify file is registered in the project

---

*Checklist Version: 1.1*
*Created: January 7, 2026*
*Updated: January 19, 2026 - Fixed build failure by adding UpdateChecker.swift to Xcode project; Added troubleshooting log section*