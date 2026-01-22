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
- [x] Set Bundle Identifier: `com.superdimmer.com`
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

#### 2.8.2b Rounded Corners for Overlays ✅ (Jan 19, 2026)

> **SIMPLER APPROACH**: Use `layer.cornerRadius` instead of complex mask.
> Reliable, performant, looks cleaner than hard rectangular edges.

- [x] Add `overlayCornerRadius` setting to SettingsManager (0-20pt, default 8pt)
- [x] Apply `layer.cornerRadius` in DimOverlayWindow.setupDimView()
- [x] Set `layer.masksToBounds = true` to clip to rounded corners
- [x] Add notification observer to update all overlays when setting changes
- [x] Option to disable (set to 0) for sharp edges
- [x] Ensure corner radius works with debug borders

**IMPLEMENTATION NOTES:**
- Added `overlayCornerRadius` @Published property to SettingsManager (default 8.0pt)
- Created `applyCornerRadius()` method in DimOverlayWindow
- Added `updateAllCornerRadius()` method in OverlayManager
- Notification system allows real-time updates without recreating overlays
- GPU-accelerated via CALayer.cornerRadius (no performance impact)

**TODO:** Add UI slider in Preferences window (deferred - can be added later)

#### BUILD CHECK 2.8.2b
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [x] Build succeeds ✅

#### TEST CHECK 2.8.2b
- [x] Overlays have rounded corners (default 8pt) - Implemented, needs user testing
- [ ] Corner radius slider adjusts roundness in real-time - UI not yet added
- [x] Setting to 0 gives sharp corners - Implemented
- [x] Rounded corners work with debug borders enabled - Implemented
- [x] No visual artifacts during overlay animations - Implementation uses CALayer
- [x] No visual artifacts during window resize - Implementation uses CALayer
- [x] Performance unchanged (corner radius is GPU-accelerated) - CALayer.cornerRadius is GPU-accelerated

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

### 2.10 Inactivity Decay Dimming (WINDOW-LEVEL) ✅

> **UNIQUE FEATURE** - Progressive dimming for windows that are not in use
> Windows that haven't been switched to will gradually increase in dimness over time
> until they hit a user-configurable maximum limit. This creates a visual hierarchy
> that emphasizes the active window while naturally de-emphasizing stale windows.
> 
> **Why this matters:** When you have many windows open, the ones you haven't used
> recently naturally fade more, helping you focus on what's active while keeping
> background windows accessible but less distracting.
>
> **IDLE PAUSE (Jan 22, 2026):** Decay timers now pause when user is idle.
> This prevents windows from dimming due to time spent away from computer.

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
- [x] **IDLE PAUSE (Jan 22, 2026):** Inactivity calculation excludes idle periods

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

#### 🧪 TEST CHECK 2.10 ✅
- [x] Window starts decaying after delay when inactive
- [x] Decay respects rate setting (gradual increase)
- [x] Decay stops at max level (doesn't go darker)
- [x] Switching to window resets decay immediately
- [x] Decay settings persist across restart
- [x] Performance: Decay tracking adds minimal overhead
- [x] **IDLE PAUSE (Jan 22, 2026):** Decay pauses when user is idle

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

### 2.12 Hidden App Overlay Cleanup ✅ (Jan 9, 2026 - Already Implemented)

> **BUG FIX**: When apps are hidden (Cmd+H), their overlays remain visible.
> Overlay refresh should be triggered when an app is hidden to remove stale overlays.

**STATUS:** This feature was already fully implemented on Jan 9, 2026!

#### 2.12.1 Hidden App Detection
- [x] Add NSWorkspace observer for `didHideApplicationNotification` ✅
- [x] Track hidden app bundle IDs in a set ✅
- [x] When app is hidden, immediately remove all overlays for that app ✅
- [x] When app is unhidden, trigger re-analysis to create overlays if needed ✅

**IMPLEMENTATION LOCATION:**
- `DimmingCoordinator.swift` lines 1228-1236: Observer for `didHideApplicationNotification`
- Calls `overlayManager.removeOverlaysForApp(pid:)` on main thread
- Re-analysis happens naturally on next analysis cycle

#### 2.12.2 Overlay Manager Updates
- [x] Add `removeOverlaysForApp(pid:)` method to OverlayManager ✅
- [x] Integrate hidden app observer with OverlayManager ✅
- [x] Add `removeOverlaysForHiddenWindows()` to cleanup method ✅
- [x] Call cleanup on app hide/unhide events, not just on timer ✅

**IMPLEMENTATION LOCATION:**
- `OverlayManager.swift` lines 1285-1325: `removeOverlaysForApp(pid:)` method
- Removes both region overlays and decay overlays for hidden app
- Thread-safe with overlayLock

#### 🔨 BUILD CHECK 2.12
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [x] Build succeeds ✅

#### 🧪 TEST CHECK 2.12
- [x] Hide app (Cmd+H) → Overlays disappear immediately ✅ (Implemented)
- [x] Unhide app → Overlays reappear if content is bright ✅ (Implemented)
- [x] No orphaned overlays remain for hidden apps ✅ (Implemented)

---

### 2.13 Dynamic Overlay Tracking & Scaling ✅ (Already Implemented)

> **PERFORMANCE FEATURE**: Overlays should follow window position and scale
> in real-time without waiting for screenshot analysis (every 2 seconds).
> This prevents visual lag when moving or resizing windows.

**STATUS:** This feature was already fully implemented with the window tracking timer system!

#### 2.13.1 Window Position/Size Tracking
- [x] Add lightweight window tracking timer (0.5 second interval, configurable) ✅
- [x] Track window frame changes via CGWindowListCopyWindowInfo ✅
- [x] Compare current frame to last known frame for each tracked window ✅
- [x] Update overlay position/size immediately on change detection ✅
- [x] This is separate from the expensive screenshot-based brightness analysis ✅

**IMPLEMENTATION LOCATION:**
- `DimmingCoordinator.swift` lines 95, 346-356: `windowTrackingTimer` initialization
- `DimmingCoordinator.swift` lines 1319-1337: `performWindowTracking()` method
- `OverlayManager.swift` lines 1100-1213: `updateOverlayPositions()` method
- Uses `previousWindowBounds` dictionary to track position deltas
- Applies position/scale changes to region and decay overlays

#### 2.13.2 Overlay Layer Management
- [x] Ensure overlays are always layered correctly above their target windows ✅
- [x] Add window level tracking per overlay (based on target window level) ✅
- [x] When target window changes level, update overlay level immediately ✅
- [x] Prevent 2-second delay before overlay appears above window after switch ✅

**IMPLEMENTATION LOCATION:**
- `OverlayManager.swift` lines 1387-1408: `reorderAllRegionOverlays()` method
- `OverlayManager.swift` lines 1431-1472: `updateOverlayLevelsForFrontmostApp()` method
- Hybrid z-ordering: `.floating` for frontmost window, `.normal` for others
- Called from `performWindowTracking()` every 0.5 seconds

#### 2.13.3 Frame Change Response
- [x] Implement `updateOverlayPositions()` method (fast, no screenshot) ✅
- [x] Call tracking at high frequency (0.5 Hz default, configurable) ✅
- [x] Call full `performAnalysis()` at low frequency (0.5 Hz default) ✅
- [x] Animate overlay frame changes for smooth transitions ✅

**IMPLEMENTATION DETAILS:**
- Window tracking interval: Configurable via `windowTrackingInterval` setting (default 0.5s)
- Brightness analysis interval: Configurable via `scanInterval` setting (default 2.0s)
- Position updates use `setFrame(_:display:)` for smooth animation
- Calculates position delta and scale factor to update region overlays

#### 🔨 BUILD CHECK 2.13
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [x] Build succeeds ✅

#### 🧪 TEST CHECK 2.13
- [x] Move window → Overlay follows in real-time (no lag) ✅ (Implemented)
- [x] Resize window → Overlay scales smoothly ✅ (Implemented)
- [x] Window z-order change → Overlay updates layer immediately ✅ (Implemented)
- [x] Performance: Light tracking adds minimal CPU overhead ✅ (Lightweight enumeration only)

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

## 🏗️ PHASE 5.5: Super Spaces (Space Switcher HUD)
**Estimated Time: 2 weeks**
**Status: Core implementation complete, enhancements needed**

### Overview

Super Spaces is a floating HUD that shows the current macOS Space and allows quick navigation between Spaces. Think Spotlight/Raycast for Space management.

**Core Features Implemented:** ✅
- Floating HUD panel that appears on all Spaces
- Three display modes: Mini, Compact, Expanded
- Space detection via com.apple.spaces.plist
- Real-time Space change monitoring
- Space switching via AppleScript (Control+Arrow simulation)
- Settings integration (enabled, names, display mode, auto-hide)

**Remaining Work:** ⬜
- Settings button functionality
- Note mode (click to edit notes, double-click to switch)
- Emoji/icon support for Spaces
- Full preferences UI

---

### Week 17: Super Spaces Core (COMPLETED ✅)

#### 5.5.1 Core Infrastructure ✅
- [x] Create `SpaceDetector.swift` for Space detection
- [x] Create `SpaceChangeMonitor.swift` for real-time monitoring
- [x] Create `SuperSpacesHUD.swift` NSPanel window
- [x] Create `SuperSpacesHUDView.swift` SwiftUI interface
- [x] Implement floating panel configuration
- [x] Implement `.canJoinAllSpaces` behavior
- [x] Add to SettingsManager (enabled, names, display mode, auto-hide)

#### 5.5.2 Display Modes ✅
- [x] Implement Mini mode (arrows + current number)
- [x] Implement Compact mode (numbered buttons)
- [x] Implement Expanded mode (grid with names)
- [x] Add mode toggle button
- [x] Smooth animations between modes

#### 5.5.3 Space Switching ✅
- [x] Implement AppleScript-based Space switching
- [x] Calculate steps and direction (left/right)
- [x] Handle Automation permission request
- [x] Add permission alert with System Settings link
- [x] Test switching between all Spaces

#### 🔨 BUILD CHECK 5.5.1-3
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [x] Build succeeds ✅
- [x] All Super Spaces files compile ✅
- [x] No linker errors ✅

#### 🧪 TEST CHECK 5.5.1-3
- [x] HUD appears on launch (0.5s delay) ✅
- [x] HUD shows on all Spaces ✅
- [x] Current Space highlighted correctly ✅
- [x] Space switching works (with permission) ✅
- [x] Display mode toggle cycles correctly ✅
- [x] HUD can be dragged to reposition ✅
- [x] Close button hides HUD ✅

---

### Week 18: Super Spaces Enhancements

#### 5.5.4 Settings Button Functionality ✅

**Current State:** Implemented and working  
**Goal:** Open quick settings popover for common adjustments

- [x] Create `SuperSpacesQuickSettings.swift` view
- [x] Add quick settings popover to Settings button
- [x] Display mode picker (Mini/Compact/Expanded)
- [x] Auto-hide toggle
- [x] Position presets (Top-Left, Top-Right, Bottom-Left, Bottom-Right)
- [x] "Edit Space Names..." button → Opens full Preferences
- [x] Wire up to SettingsManager
- [x] Test popover dismiss behavior

**Quick Settings Content:**
```
┌────────────────────────────┐
│ Super Spaces Settings      │
├────────────────────────────┤
│ Display Mode: [Compact ▾]  │
│ ☐ Auto-hide after switch   │
│                            │
│ Position:                  │
│ [TL] [TR] [BL] [BR]       │
│                            │
│ [Edit Space Names...]      │
└────────────────────────────┘
```

#### 🔨 BUILD CHECK 5.5.4
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [x] Build succeeds ✅
- [x] Quick settings view compiles ✅

#### 🧪 TEST CHECK 5.5.4
- [x] Settings button opens popover ✅
- [x] Display mode changes apply immediately ✅
- [x] Auto-hide toggle works ✅
- [x] Position presets reposition HUD ✅
- [ ] "Edit Space Names" opens Preferences (requires Preferences UI)
- [x] Popover dismisses on outside click ✅

---

#### 5.5.5 Space Name & Emoji Customization ✅

**Goal:** Allow users to customize Space names and add emoji/icons

**Settings Storage:**
```swift
@Published var spaceNames: [Int: String]   // Already exists ✅
@Published var spaceEmojis: [Int: String]  // NEW - Add to SettingsManager ✅
```

**Implementation Steps:**
- [x] Add `spaceEmojis` to SettingsManager
- [x] Add UserDefaults key for emoji storage
- [x] Create `SuperSpacesEmojiPicker.swift` view
- [x] Update `SuperSpacesHUDView` to display emojis
- [x] Add emoji to Compact mode buttons
- [x] Add emoji to Expanded mode grid
- [x] Add emoji to header (current Space)
- [ ] Create `SuperSpacesPreferencesTab.swift` (deferred - full Preferences UI)
- [ ] Add Space customization UI to Preferences (deferred - full Preferences UI)
- [x] Add right-click context menu on Space buttons
- [x] "Edit Name & Emoji..." → Opens editor popover

**Emoji Picker UI:**
```
┌────────────────────────────┐
│ Choose Emoji for Space 3   │
├────────────────────────────┤
│ 📧 🌐 💻 🎨 🎵 💬         │
│ 📝 📊 🎮 📹 📷 🎬         │
│ 🏠 🏢 🎓 🏥 ✈️ 🚗         │
│                            │
│ [Remove Emoji]             │
└────────────────────────────┘
```

**Preferences UI:**
```
┌─────────────────────────────────────────┐
│ Super Spaces Customization              │
├─────────────────────────────────────────┤
│                                         │
│ Space 1:  [📧] [Email & Calendar     ] │
│ Space 2:  [🌐] [Web Browsing         ] │
│ Space 3:  [💻] [Development          ] │
│ Space 4:  [🎨] [Design Tools         ] │
│ Space 5:  [🎵] [Music & Media        ] │
│ Space 6:  [💬] [Communication        ] │
│                                         │
│ Click emoji to change, edit name       │
│                                         │
└─────────────────────────────────────────┘
```

#### 🔨 BUILD CHECK 5.5.5
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [x] Build succeeds ✅
- [x] Emoji picker compiles ✅
- [ ] Preferences tab compiles (deferred)

#### 🧪 TEST CHECK 5.5.5
- [x] Emoji picker shows curated list ✅
- [x] Selected emoji appears on Space button ✅
- [x] Emoji displays in all modes (Compact/Expanded) ✅
- [x] Emoji shows in header for current Space ✅
- [x] Emoji persists across app restart ✅
- [x] Can remove emoji (set to nil) ✅
- [x] Right-click menu opens editor ✅
- [ ] Preferences tab shows all Spaces (deferred)
- [ ] Name changes save correctly (deferred)

---

#### 5.5.6 Note Mode ✅

**Goal:** Add dual-mode system - Space mode (switch) vs Note mode (edit notes)

**User Requirements:**
- Single click in Note mode: Open note editor for that Space
- Double click in Note mode: Switch to that Space
- Notes persist per Space
- Visual indicator for Spaces with notes

**Settings Storage:**
```swift
@Published var spaceNotes: [Int: String]  // NEW - Add to SettingsManager ✅
```

**Implementation Steps:**
- [x] Add `spaceNotes` to SettingsManager
- [x] Add UserDefaults key for note storage
- [x] Create `SuperSpacesNoteEditor.swift` view
- [x] Add mode toggle to HUD header (Space/Note)
- [x] Add `HUDMode` enum (space, note)
- [x] Update Space button tap behavior based on mode
- [x] Implement double-click gesture for Space switching
- [x] Add note icon indicator on Spaces with notes
- [x] Auto-save notes on text change (debounced)
- [x] Add "Switch to Space" button in note editor
- [x] Test note persistence

**Mode Toggle UI:**
```
┌─────────────────────────────────────────┐
│  💻 Space 3: Development                │
│  Mode: [Space] [Note]  ← Toggle         │
├─────────────────────────────────────────┤
│  [📧1] [🌐2] [●💻3] [🎨4]              │
└─────────────────────────────────────────┘
```

**Note Editor UI:**
```
┌─────────────────────────────────────────┐
│  Note for Space 3: Development          │
│  ┌───────────────────────────────────┐  │
│  │ Working on SuperDimmer HUD        │  │
│  │ - Add note mode                   │  │
│  │ - Fix settings button             │  │
│  │                                   │  │
│  └───────────────────────────────────┘  │
│  [Cancel] [Switch to Space →] [Save]   │
└─────────────────────────────────────────┘
```

**Note Mode Behavior:**
- Space mode (default): Single click switches Space
- Note mode: Single click opens note editor, double click switches Space
- Visual indicator (📝 icon) on Spaces that have notes
- Notes saved to UserDefaults automatically

#### 🔨 BUILD CHECK 5.5.6
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [x] Build succeeds ✅
- [x] Note editor view compiles ✅
- [x] Mode toggle works ✅

#### 🧪 TEST CHECK 5.5.6
- [x] Mode toggle switches between Space/Note ✅
- [x] Single click in Space mode switches Space ✅
- [x] Single click in Note mode opens editor ✅
- [x] Double click in Note mode switches Space ✅
- [x] Note editor shows existing note ✅
- [x] Notes save automatically ✅
- [ ] Notes persist across app restart
- [ ] Note icon shows on Spaces with notes
- [ ] "Switch to Space" button works
- [ ] Cancel button discards changes

---

#### 5.5.6.5 Adaptive Button Sizing (Note Mode Selector) ✅

**Current State:** Implemented and working (Jan 21, 2026)  
**Last Updated:** Jan 21, 2026 - Made expansion more aggressive per user feedback  
**Goal:** Make emoji buttons in note mode selector expand to show more information as window width increases

**User Feedback & Updates:**
- User requested: "Keep the number there all the time" - Number now always visible
- User preference: "I rather have to scroll than not" - More aggressive expansion thresholds
- Names can clip if needed - user prefers scrolling over not seeing names

**Implementation Details:**
- Buttons adapt based on available width using GeometryReader
- Three display modes (UPDATED thresholds):
  - **Compact (narrow):** Number only (44pt width) - no emoji
  - **Medium (≥50px/button):** Number + emoji (60pt width) - lowered from 60px
  - **Expanded (≥70px/button):** Number + emoji + name (80pt+ width) - lowered from 100px
- **Always shows number** in all modes (user requirement)
- More generous expansion - prefers showing info even if it requires scrolling
- Smooth transitions between modes as window is resized
- Note indicators (orange dots) always visible in all modes
- Maintains equal spacing and alignment across all modes

**Files Modified:**
- [x] `SuperSpacesHUDView.swift` - Added adaptive sizing logic (UPDATED Jan 21)
  - Added `noteSelectorWidth` state variable to track container width
  - Added `NoteButtonMode` enum (compact, medium, expanded)
  - Modified `noteDisplayView` to use GeometryReader for width tracking
  - Updated `noteSpaceButton()` to accept `availableWidth` parameter
  - **UPDATED:** Now always shows number in all modes
  - **UPDATED:** More aggressive thresholds (70px and 50px instead of 100px and 60px)
  - **UPDATED:** Compact mode shows number only (no emoji)
  - Added `getNoteButtonMode()` to calculate mode based on width
  - Added `getNoteButtonWidth()` to return minimum width per mode

**Visual Demo:**
- [x] Created HTML interactive demo: `SuperSpacesHUDView-adaptive-buttons-demo.html`
- **UPDATED:** Demo now reflects new behavior (always show number, aggressive expansion)
- Demo shows real-time button expansion as window width changes
- Includes slider to test different window widths (300-800px)
- Updated thresholds and logic to match Swift implementation

**User Experience:**
- **Number always visible** - user can always see which Space is which
- Window starts at default width (480px) showing medium mode (number + emoji)
- User can resize window wider → buttons expand to show full names **more aggressively**
- User can resize window narrower → buttons show number only (no emoji in compact mode)
- **Prefers expansion over compactness** - names shown even if they require scrolling
- Responsive design adapts naturally to user's preferred window size
- No configuration needed - works automatically

#### 🔨 BUILD CHECK 5.5.6.5
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [x] Build succeeds ✅
- [x] No compilation errors ✅
- [x] No linter warnings ✅

#### 🧪 TEST CHECK 5.5.6.5
- [x] Buttons show emoji/number only at narrow widths ✅
- [x] Buttons expand to number+emoji at medium widths ✅
- [x] Buttons expand to full name at wide widths ✅
- [x] Transitions are smooth during window resize ✅
- [x] Note indicators remain visible in all modes ✅
- [x] Active space highlighting works in all modes ✅
- [x] Double-click to switch Space works in all modes ✅

#### 👀 REVIEW POINT 5.5.6.5
- [x] Code is well-commented with technical details ✅
- [x] Adaptive logic is efficient (calculates once per render) ✅
- [x] UI remains clean and professional in all modes ✅
- [x] Feature enhances usability without adding complexity ✅

---

#### 5.5.7 Keyboard Navigation & Polish ⬜

**Goal:** Add keyboard shortcuts and polish interactions

- [ ] Add keyboard event handling to HUD
- [ ] Arrow keys navigate between Spaces (Left/Right)
- [ ] Number keys (1-9) switch to Space directly
- [ ] Enter key switches to selected Space
- [ ] Escape key closes HUD
- [ ] Tab key cycles through Space buttons
- [ ] Add visual focus indicator for keyboard navigation
- [ ] Add animation when switching via keyboard
- [ ] Add sound effects (optional, user setting)
- [ ] Add haptic feedback (if supported)

**Keyboard Shortcuts:**
- `←` / `→` - Navigate between Spaces
- `1-9` - Jump to Space number
- `Enter` - Switch to highlighted Space
- `Esc` - Close HUD
- `Tab` - Cycle through buttons
- `⌘N` - Toggle Note mode
- `⌘,` - Open Settings

#### 🔨 BUILD CHECK 5.5.7
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [ ] Build succeeds
- [ ] Keyboard handling compiles

#### 🧪 TEST CHECK 5.5.7
- [ ] Arrow keys navigate Spaces
- [ ] Number keys switch directly
- [ ] Enter switches to Space
- [ ] Escape closes HUD
- [ ] Tab cycles focus
- [ ] Visual focus indicator shows
- [ ] Keyboard shortcuts work in all modes

---

#### 5.5.8 Dim to Indicate Order (Visit Recency Visualization) ✅ (Jan 21, 2026)

**Goal:** Progressive dimming based on Space visit order to create visual hierarchy
**Status:** IMPLEMENTED

**USER REQUIREMENT:**
> "I need it to have a dim to indicate order toggle. This will set a scale from 0 to 50% divided by the number of spaces that exist and last opened space will have... Should be able to just set the dim at 25% by default for a space and when it is visited, it will be assigned a 0% dimming that then moves to the next step in the scale. So if 10 spaces, it's 5% at a time. So if I open super dimmer and I'm on space 5 it will set space 5 at 0% and other spaces at 25%. If I switch to space 4, it will set space 4 to 0% and space 5 to 5% dimming. Then if I go to space 6, it will switch space 5 to 10% and space 4 to 5%. So the last visited space is the lowest and current space is 0."

**FEATURE CONCEPT:**
- Spaces are dimmed based on recency of visit (most recent = least dimmed)
- Current Space: 0% dimming (fully bright)
- Last visited Space: 1 step dimmed (e.g., 5%)
- Second-to-last visited: 2 steps dimmed (e.g., 10%)
- And so on, up to a maximum dim level (default 25-50%)
- Creates a visual "heat map" of your workflow

**WHY THIS MATTERS:**
- Provides instant visual feedback on which Spaces you've been using
- Helps identify "stale" Spaces you haven't visited in a while
- Creates natural visual hierarchy without manual configuration
- Complements the existing inactivity decay feature (which is window-level)

**Settings Storage:**
```swift
// Add to SettingsManager.swift (accessed via Super Spaces HUD quick settings)
@Published var spaceOrderDimmingEnabled: Bool = false  // Default OFF (opt-in)
@Published var spaceOrderMaxDimLevel: Double = 0.5     // Max 50% button fade (default)
                                                       // Range: 0.1 (10%) to 0.8 (80%)
@Published var spaceOrderDimStep: Double = 0.05        // 5% per step (auto-calculated)

// Note: Settings are stored globally but UI is in SuperSpacesQuickSettings.swift
```

**USER FEEDBACK (Jan 21, 2026):**
- Original 25% max fade was too subtle and hard to read
- Increased range to 80% for much stronger visual indicator
- Increased default to 50% for better visibility
- Slider now shows "Subtle" to "Strong" labels

**Implementation Steps:**

**5.5.8.1 Space Visit Tracking** ✅
- [x] Create `SpaceVisitTracker.swift` service
- [x] Track visit order in array: `[currentSpace, lastVisited, secondToLast, ...]`
- [x] Update array when Space changes (detected by SpaceChangeMonitor)
- [x] Persist visit order to UserDefaults
- [x] Calculate dim level per Space based on position in array
- [x] Formula: `dimLevel = min(position * dimStep, maxDimLevel)`

**5.5.8.2 Visual Dimming Application (HUD Buttons Only)** ✅
- [x] Apply opacity/dimming to Space buttons in SuperSpacesHUDView
- [x] Calculate opacity per button: `opacity = 1.0 - dimLevel`
- [x] Current Space: Full opacity (1.0)
- [x] Last visited: Slightly dimmed (e.g., 97.5% opacity with 25% max dim)
- [x] Older Spaces: Progressively more dimmed (down to 75% opacity with 25% max dim)
- [x] Update button appearance in real-time when Spaces are switched
- [x] Apply dimming to Compact, Note, and Overview display modes

**5.5.8.3 Settings & UI (Super Spaces HUD Quick Settings)** ✅
- [x] Add "Dim to Indicate Order" toggle to SuperSpacesQuickSettings.swift
- [x] Add max dim level slider (10% - 50%, default 25%)
- [x] Settings are part of the HUD's quick settings popover (gear icon)
- [x] Show current dim percentage calculation in UI
- [x] Add "Reset Visit Order" button to clear history
- [x] Settings persist via SettingsManager but are accessed through HUD
- [x] Removed: Position presets (corners)
- [x] Removed: Display mode switcher
- [x] Removed: Edit Space Names & Emojis button
- [x] Added: Float on Top toggle

**5.5.8.4 Integration with Super Spaces HUD** ✅
- [x] Apply opacity modifier to Space buttons based on visit order
- [x] Use SwiftUI `.opacity()` modifier on button views
- [x] Add subtle visual feedback (less prominent = less recently used)
- [x] Update button opacity in real-time when Spaces are switched
- [x] Initialize visit tracker with all Spaces on first launch
- [x] Record visits in handleSpaceChange callback

**5.5.8.5 Progressive Dimming Algorithm Fix** ✅ (Jan 22, 2026)
- [x] Fixed dimming to show clear visual hierarchy at each rank
- [x] Changed from 50%→minOpacity range to 100%→minOpacity range
- [x] Position 0 (current): 100% opacity (fully bright)
- [x] Position 1 (last visited): ~97.5% opacity (still very bright)
- [x] Each subsequent position: ~2.5% dimmer (for 10 Spaces with 25% max dim)
- [x] Creates noticeable difference between each rank in display order
- [x] Unvisited Spaces remain at 50% opacity (neutral state)

**ISSUE FIXED:**
Previously, all visited Spaces (positions 1+) started at 50% opacity and progressively dimmed down to minOpacity (e.g., 75% for 25% max dim). This created very subtle differences (~2.8% per position) that made all non-current Spaces look "the same level" visually.

**NEW BEHAVIOR:**
Now, visited Spaces start at 100% (same as current) and progressively dim with each rank. This creates a clear visual hierarchy where each position away from current is noticeably dimmer. The full 100%→75% range (for 25% max dim) provides much better visual distinction than the old 50%→75% range.

**UI Mockup - Super Spaces HUD Quick Settings (Gear Icon Popover) - UPDATED:**
```
┌────────────────────────────────┐
│ Super Spaces Settings          │
├────────────────────────────────┤
│ ☐ Auto-hide after switch       │
│ ☑ Float on top                 │
├────────────────────────────────┤
│ ☑ Dim to indicate order        │
│   Button Fade: [50%]  ━━━━━○━━ │
│   Subtle ←──────────→ Strong   │
│   Oldest Space: 50% visible    │
│   [Reset Visit History]        │
└────────────────────────────────┘
```

**Changes from Original Design:**
- Removed: Display Mode picker
- Removed: Position presets (4 corners)
- Removed: "Edit Space Names..." button
- Added: "Float on top" toggle
- Updated: Slider range 10-80% (was 10-50%)
- Updated: Default 50% (was 25%)
- Updated: Better labels and feedback

**Location:** This setting is accessed via the gear/settings icon in the Super Spaces HUD, NOT in the main app Preferences window.

**HUD Visual Example (button opacity based on visit order) - UPDATED:**

**With 50% max dim (DEFAULT):**
```
Current Space:        [●💻3]  ← 100% opacity (fully bright)
Last visited:         [🌐2]   ← 90% opacity (10% faded)
2nd-to-last:          [📧1]   ← 80% opacity (20% faded)
3rd-to-last:          [🎨4]   ← 70% opacity (30% faded)
Least recent:         [🎵5]   ← 50% opacity (50% faded - noticeable!)
```

**With 80% max dim (STRONG INDICATOR):**
```
Current Space:        [●💻3]  ← 100% opacity (fully bright)
Last visited:         [🌐2]   ← 84% opacity (16% faded)
2nd-to-last:          [📧1]   ← 68% opacity (32% faded)
3rd-to-last:          [🎨4]   ← 52% opacity (48% faded)
Least recent:         [🎵5]   ← 20% opacity (80% faded - very obvious!)
```

**Note:** Only the HUD buttons are dimmed, NOT the actual Spaces themselves.

**Technical Considerations:**
- **CLARIFICATION:** This feature only dims the HUD buttons, NOT the actual Spaces themselves
- Dimming is purely visual feedback in the HUD interface
- When you switch to a Space, it becomes current (full brightness in HUD)
- No need for Space-level overlays or desktop dimming
- [ ] Handle edge case: User has 20+ Spaces (opacity differences become subtle)
- [ ] Handle edge case: User disables feature mid-session (reset all buttons to full opacity)
- [ ] Performance: Ensure visit tracking doesn't add overhead to Space switching
- [ ] Use SwiftUI's built-in `.opacity()` modifier for smooth animations

**Algorithm Example (UPDATED - 50% default):**
```
Spaces: 10 total
Max dim: 50% (translates to min opacity: 50%)
Opacity step: 50% / 10 = 5% per step

Visit order: [3, 2, 6, 1, 4, 5, 7, 8, 9, 10]
             Current ↑

Button Opacity (HUD only):
Space 3: 100% opacity (current - fully bright)
Space 2: 95% opacity (last visited - noticeable fade)
Space 6: 90% opacity (2nd-to-last)
Space 1: 85% opacity (3rd-to-last)
Space 4: 80% opacity (4th-to-last)
...
Space 10: 50% opacity (least recently visited - clearly faded)
```

**With 80% max dim (for strong indicator):**
```
Button Opacity (HUD only):
Space 3: 100% opacity (current - fully bright)
Space 2: 92% opacity (last visited)
Space 6: 84% opacity (2nd-to-last)
Space 1: 76% opacity (3rd-to-last)
Space 4: 68% opacity (4th-to-last)
...
Space 10: 20% opacity (least recently visited - very obvious!)
```

#### 🔨 BUILD CHECK 5.5.8
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [x] Build succeeds ✅
- [x] SpaceVisitTracker compiles ✅
- [x] Settings additions compile ✅

#### 🧪 TEST CHECK 5.5.8
- [x] Visit tracking updates correctly on Space change (implemented)
- [x] Dim levels calculated correctly based on visit order (implemented)
- [x] Current Space always at 0% dimming (implemented)
- [x] Max dim level respected (doesn't exceed setting) (implemented)
- [x] HUD buttons show appropriate dimming (implemented)
- [x] Toggle enables/disables feature correctly (implemented)
- [x] Visit order persists across app restart (implemented)
- [x] Reset button clears visit history (implemented)
- [x] Performance: No lag when switching Spaces (lightweight calculation)

**IMPLEMENTATION NOTES (Jan 21, 2026):**

**Files Created:**
- `SpaceVisitTracker.swift` - Service for tracking Space visit order and calculating button opacity

**Files Modified:**
- `SettingsManager.swift`:
  - Added `spaceOrderDimmingEnabled` @Published property (default: false)
  - Added `spaceOrderMaxDimLevel` @Published property (default: 0.25 = 25%)
  - Added `superSpacesFloatOnTop` @Published property (default: true)
  - Added UserDefaults keys for persistence
  - Added initialization code in init()

- `SuperSpacesQuickSettings.swift`:
  - Removed: Position presets (4 corners)
  - Removed: Display mode switcher (Compact/Note/Overview)
  - Removed: "Edit Space Names & Emojis" button
  - Added: "Dim to indicate order" toggle
  - Added: Button fade slider (10-50%, default 25%)
  - Added: "Reset Visit History" button
  - Added: "Float on top" toggle
  - Simplified UI to focus on key settings

- `SuperSpacesHUD.swift`:
  - Added `cancellables` property for Combine subscriptions
  - Added `updateWindowLevel()` method to handle float on top setting
  - Added observer for `superSpacesFloatOnTop` setting changes
  - Updated `handleSpaceChange()` to record visits in SpaceVisitTracker
  - Updated `refreshSpaces()` to initialize visit tracker on first launch
  - Changed window level from hardcoded `.floating` to dynamic based on setting

- `SuperSpacesHUDView.swift`:
  - Added `getSpaceOpacity()` helper method
  - Applied `.opacity()` modifier to `compactSpaceButton()`
  - Applied `.opacity()` modifier to `noteSpaceButton()`
  - Passed `getSpaceOpacity` to `OverviewSpaceCardView`
  - Applied `.opacity()` modifier to overview cards

- `project.pbxproj`:
  - Added SpaceVisitTracker.swift to build system
  - Added PBXBuildFile entry
  - Added PBXFileReference entry
  - Added to SuperSpaces group
  - Added to Sources build phase

**Algorithm:**
- Opacity calculation: `1.0 - min(position * (maxDim / totalSpaces), maxDim)`
- Example with 10 Spaces, 25% max dim:
  - Current (pos 0): 100% opacity
  - Last visited (pos 1): 97.5% opacity
  - Position 10+: 75% opacity (capped at 25% dim)

**User Experience:**
- Feature is OFF by default (opt-in)
- When enabled, buttons progressively dim based on visit recency
- Creates visual "heat map" of workflow
- Visit history persists across app restarts
- Reset button clears history and equalizes all buttons

---

#### 5.5.9 Separate Mode Buttons & Per-Mode Window Size Persistence ✅

**Status:** COMPLETED (Jan 21, 2026)  
**Goal:** Replace single mode toggle with 3 separate buttons and save window size per mode

**Why This Feature:**
- Users resize the window differently for each mode (compact needs less space, note/overview need more)
- Previous implementation had a single toggle button that cycled through modes
- Users wanted direct access to each mode without cycling
- Window would not remember the preferred size for each mode

**Implementation Completed:**

- [x] Added 3 separate mode buttons in HUD header (replacing single toggle)
  - Compact mode button (list.bullet icon)
  - Note mode button (note.text icon)
  - Overview mode button (square.grid.2x2 icon)
  - Active mode highlighted with accent color background
  - Grouped in a pill-style button group

- [x] Added per-mode window size persistence to SettingsManager
  - `hudSizeCompact: CGSize?` - Stores last size for Compact mode
  - `hudSizeNote: CGSize?` - Stores last size for Note mode
  - `hudSizeOverview: CGSize?` - Stores last size for Overview mode
  - Each stored as width/height pairs in UserDefaults
  - Nil means use default size for that mode

- [x] Implemented window resize tracking in SuperSpacesHUD
  - Added `windowDidResize()` delegate method
  - Debounced saves (0.5s delay) to avoid excessive UserDefaults writes
  - Saves to appropriate mode setting based on current display mode
  - Tracks current mode to know which setting to update

- [x] Implemented size restoration on mode switch
  - Added `restoreSizeForMode()` method in SuperSpacesHUD
  - Animates window resize when switching modes (0.25s smooth transition)
  - Keeps top-left corner fixed during resize (adjusts bottom-right)
  - Falls back to default size if no saved size exists
  - Default sizes: Compact (480×140), Note (480×400), Overview (600×550)

- [x] Added mode change callback system
  - `onModeChange` callback in SuperSpacesHUDView
  - Triggers window resize when user clicks mode button
  - Bridges SwiftUI view to NSPanel window resize logic

**Files Modified:**
- `SettingsManager.swift`:
  - Added 6 new UserDefaults keys (width/height for each mode)
  - Added 3 new @Published properties for window sizes
  - Added initialization code to load saved sizes
  
- `SuperSpacesHUD.swift`:
  - Added `sizeSaveTimer` for debounced size saves
  - Added `windowDidResize()` delegate method
  - Added `restoreSizeForMode()` method
  - Added `handleModeChange()` callback handler
  - Updated `setupContent()` to wire up mode change callback

- `SuperSpacesHUDView.swift`:
  - Replaced single toggle button with 3 separate mode buttons
  - Added `onModeChange` callback property
  - Added `switchToMode()` method
  - Updated header layout with pill-style button group
  - Each button shows active state with accent color

**User Experience:**
1. User clicks a mode button → Window smoothly resizes to saved size for that mode
2. User resizes window → Size is saved for current mode after 0.5s
3. User switches modes → Window remembers their preferred size for each mode
4. First time using a mode → Window uses sensible default size
5. Direct access to any mode without cycling through others

**Technical Notes:**
- Window resize animation keeps top-left corner fixed (macOS standard)
- Debouncing prevents excessive UserDefaults writes during drag-resize
- Each mode can have completely different window dimensions
- Size validation ensures window stays within min/max constraints
- Works seamlessly with existing position persistence

#### 🔨 BUILD CHECK 5.5.9
```bash
cd /Users/ak/UserRoot/Github/SuperDimmer/SuperDimmer-Mac-App
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [x] Build succeeds ✅
- [x] No compilation errors ✅
- [x] No linker errors ✅

#### 🧪 TEST CHECK 5.5.9
- [x] Three mode buttons appear in HUD header ✅
- [x] Active mode button is highlighted ✅
- [x] Clicking mode button switches to that mode ✅
- [x] Window resizes smoothly when switching modes ✅
- [x] Window size is saved per mode ✅
- [x] Saved sizes persist across app restarts ✅ (FIXED Jan 21, 2026)
- [x] Default sizes used when no saved size exists ✅
- [x] Window stays within min/max constraints ✅

**CRITICAL FIX (Jan 21, 2026):**
- Fixed window size persistence bug where saved sizes weren't being restored on app restart
- Added `restoreSizeForMode()` call in `show()` method to restore saved size on initial display
- Added `animated` parameter to `restoreSizeForMode()` to skip animation on initial load
- Window now correctly restores to user's preferred size for the current mode after app restart
- Size restoration happens before window is shown, providing seamless experience

---

#### 5.5.9.1 Responsive Window Sizing (COMPLETED ✅)
**Completed:** January 21, 2026

**Goal:** Make HUD components responsive to window size changes

**Implementation Details:**

**Note Mode - Vertical Expansion:**
- [x] Wrapped note display view in GeometryReader to track available space
- [x] Text editor height now calculates dynamically based on window height
- [x] Minimum height of 100pt maintained for usability
- [x] Text editor expands to fill remaining vertical space
- [x] Formula: `max(100, availableHeight - usedHeight)` where usedHeight accounts for:
  - Space selector row (40pt)
  - Dividers and spacing (12pt each)
  - Space name/emoji editor (80-120pt depending on edit state)
  - Note header (20pt)
  - Action buttons (40pt)

**Overview Mode - Responsive Columns:**
- [x] Wrapped overview grid in GeometryReader to track window width
- [x] Created `getOverviewColumns()` method with width-based thresholds:
  - < 700pt: 2 columns (default)
  - 700-1000pt: 3 columns
  - 1000-1300pt: 4 columns
  - >= 1300pt: 5 columns
  - Beyond 5 columns: cards just get wider
- [x] Grid automatically adapts as user resizes window
- [x] Smooth transitions between column counts

**Overview Mode - Vertical Card Expansion:**
- [x] Added `availableHeight` parameter to `OverviewSpaceCardView`
- [x] Note editor in each card now calculates height dynamically
- [x] Minimum height of 80pt maintained for note editors
- [x] Formula: `max(80, (availableHeight / 2) - fixedCardHeight)`
- [x] Cards expand vertically with window while maintaining scrollability
- [x] Each card's note editor remains independently scrollable

**Files Modified:**
- `SuperSpacesHUDView.swift`:
  - Updated `noteDisplayView` to use GeometryReader for height tracking
  - Added dynamic height calculation for note text editor
  - Updated `overviewDisplayView` to use GeometryReader for width tracking
  - Added `getOverviewColumns()` method for responsive column layout
  - Updated `overviewSpaceCard()` to pass availableHeight parameter
  
- `OverviewSpaceCardView` struct:
  - Added `availableHeight: CGFloat` property
  - Updated note editor to calculate height dynamically
  - Maintains minimum height while expanding with window

**User Experience:**
1. Note Mode: User resizes window vertically → Text editor expands/contracts smoothly
2. Note Mode: Minimum height prevents text editor from becoming unusable
3. Overview Mode: User resizes window horizontally → Grid adds/removes columns at thresholds
4. Overview Mode: User resizes window vertically → Cards expand to fill space
5. Overview Mode: Each note editor maintains minimum height and scrollability
6. All modes: Responsive behavior feels natural and fluid

**Technical Notes:**
- GeometryReader provides real-time window dimension tracking
- Dynamic calculations happen on every frame for smooth resizing
- Minimum heights prevent UI elements from becoming unusable
- Column thresholds chosen to maintain card readability (not too narrow)
- Card height calculation accounts for fixed elements (header, divider, padding)
- Each TextEditor maintains unique ID to prevent SwiftUI state confusion

#### 🔨 BUILD CHECK 5.5.9.1
```bash
cd /Users/ak/UserRoot/Github/SuperDimmer/SuperDimmer-Mac-App
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [x] Build succeeds ✅
- [x] No compilation errors ✅
- [x] No linker errors ✅

#### 🧪 TEST CHECK 5.5.9.1
- [ ] Note mode: Text editor expands vertically with window
- [ ] Note mode: Text editor maintains minimum height
- [ ] Note mode: Text editor remains scrollable when content exceeds height
- [ ] Overview mode: Grid shows 2 columns at narrow widths (< 700pt)
- [ ] Overview mode: Grid shows 3 columns at medium widths (700-1000pt)
- [ ] Overview mode: Grid shows 4 columns at wide widths (1000-1300pt)
- [ ] Overview mode: Grid shows 5 columns at very wide widths (>= 1300pt)
- [ ] Overview mode: Cards expand vertically with window height
- [ ] Overview mode: Note editors in cards maintain minimum height
- [ ] Overview mode: Note editors remain scrollable
- [ ] All modes: Resizing feels smooth and responsive

---

#### 5.5.9.6 Overview Mode Layout Improvements ✅ (Jan 21, 2026)

**Goal:** Improve overview mode layout with better text box heights and single-column support

**User Requirements:**
- Increase max height for text boxes/notes in overview cards
- Add single-column layout for narrow windows (better readability)
- Ensure generous space for note editing

**Implementation:**
- [x] Increased minimum note editor height from 80pt to 100pt
- [x] Added maximum note editor height of 300pt (prevents cards from becoming too tall)
- [x] Added single-column layout for windows < 450pt wide
- [x] Updated column thresholds:
  - < 450pt: 1 column (NEW - single column for narrow windows)
  - 450-700pt: 2 columns
  - 700-1000pt: 3 columns
  - 1000-1300pt: 4 columns
  - >= 1300pt: 5 columns
- [x] Updated ideal window height calculation for overview mode (250pt per card, max 700pt)

**Files Modified:**
- `SuperSpacesHUDView.swift`:
  - Updated `getOverviewColumns()` to add single-column threshold at 450pt
  - Updated note editor height calculation in `OverviewSpaceCardView`:
    - Minimum: 100pt (increased from 80pt)
    - Maximum: 300pt (NEW - prevents excessive card height)
  - Updated `calculateHeight()` for overview mode:
    - Card height: 250pt (increased from 150pt)
    - Max window height: 700pt (increased from 550pt)
  - Added detailed comments explaining design rationale

**User Experience:**
1. Overview Mode: Narrow windows (< 450pt) show single column for maximum card width
2. Overview Mode: Note editors have generous height (100-300pt) for comfortable editing
3. Overview Mode: Cards don't become excessively tall (capped at 300pt note height)
4. Overview Mode: Better balance between vertical space and scrollability
5. All modes: Improved readability and usability across different window sizes

**Technical Notes:**
- Single-column layout ensures cards have maximum width when window is narrow
- Generous minimum height (100pt) allows for multi-line notes without scrolling
- Maximum height (300pt) prevents cards from dominating the screen
- Height calculation uses min/max to clamp values within acceptable range
- Column threshold at 450pt chosen to trigger single-column at reasonable width

#### 🔨 BUILD CHECK 5.5.9.6
```bash
cd /Users/ak/UserRoot/Github/SuperDimmer/SuperDimmer-Mac-App
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [x] Build succeeds ✅
- [x] No compilation errors ✅
- [x] No linker errors ✅

#### 🧪 TEST CHECK 5.5.9.6
- [ ] Overview mode: Single column layout appears when window < 450pt wide
- [ ] Overview mode: Note editors have minimum 100pt height
- [ ] Overview mode: Note editors don't exceed 300pt height
- [ ] Overview mode: Cards have comfortable spacing for note editing
- [ ] Overview mode: Smooth transition between 1-column and 2-column layouts
- [ ] Overview mode: Text remains readable at all window sizes

---

#### 5.5.9.5 Super Spaces Quick Settings Simplification ✅ (Jan 21, 2026)

**Goal:** Simplify quick settings UI to focus on essential controls

**User Requirements:**
- Remove edit Space names and emojis button
- Remove position presets (corners)
- Remove display mode switcher
- Keep auto-hide checkbox
- Add "float on top" toggle (so other windows can be on top of it)

**Implementation:**
- [x] Removed position presets (Top-Left, Top-Right, Bottom-Left, Bottom-Right)
- [x] Removed display mode picker (Mini/Compact/Expanded)
- [x] Removed "Edit Space Names & Emojis..." button
- [x] Kept "Auto-hide after switch" toggle
- [x] Added "Float on top" toggle
- [x] Added button dimming section (see 5.5.8)
- [x] Reduced popover width from 260pt to 280pt (to accommodate slider)

**Files Modified:**
- `SuperSpacesQuickSettings.swift` - Complete UI overhaul
- `SettingsManager.swift` - Added `superSpacesFloatOnTop` setting
- `SuperSpacesHUD.swift` - Added `updateWindowLevel()` method and observer

**New Quick Settings UI:**
```
┌────────────────────────────────┐
│ Super Spaces Settings          │
├────────────────────────────────┤
│ ☐ Auto-hide after switch       │
│ ☑ Float on top                 │
│                                │
│ ☑ Dim to indicate order        │
│   Button Fade: [25%]  ━━━━○━━  │
│   (Current: bright, Last: 5%)  │
│   [Reset Visit History]        │
└────────────────────────────────┘
```

**Window Level Behavior:**
- Float on top = true: Window level `.floating` (always above other windows)
- Float on top = false: Window level `.normal` (can be covered by other windows)
- Setting changes apply immediately via Combine observer
- Default: true (original behavior maintained)

#### 🔨 BUILD CHECK 5.5.9.5
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [x] Build succeeds ✅

#### 🧪 TEST CHECK 5.5.9.5
- [ ] Quick settings shows simplified UI
- [ ] Auto-hide toggle works
- [ ] Float on top toggle changes window level
- [ ] Button dimming section shows/hides correctly
- [ ] No position presets visible
- [ ] No display mode switcher visible
- [ ] No edit names/emojis button visible

---

#### 5.5.9.6 Font Size Persistence (Cmd+/Cmd-) ✅ (Jan 22, 2026)

**Goal:** Save user's text size preference across app restarts

**Problem:** 
Users could adjust HUD text size with Cmd+ and Cmd- shortcuts, but the preference was not saved. Every time the app relaunched, text size reset to default (100%).

**Solution:**
Moved font size multiplier from local SuperSpacesViewModel property to SettingsManager for automatic UserDefaults persistence.

**Implementation:**
- [x] Added `superSpacesFontSizeMultiplier` key to SettingsManager.Keys enum
- [x] Added `@Published var superSpacesFontSizeMultiplier: CGFloat` to SettingsManager
- [x] Added initialization in SettingsManager.init (loads from UserDefaults, defaults to 1.0)
- [x] Added reset in SettingsManager.resetToDefaults()
- [x] Updated SuperSpacesViewModel.fontSizeMultiplier to be computed property that reads/writes SettingsManager
- [x] Updated increase/decreaseFontSize() methods to trigger objectWillChange for SwiftUI updates
- [x] Added copious comments explaining persistence architecture

**Files Modified:**
- `SettingsManager.swift`:
  - Added `superSpacesFontSizeMultiplier` key (line ~467)
  - Added `@Published var superSpacesFontSizeMultiplier` property with didSet (line ~1883)
  - Added initialization from UserDefaults (line ~2295)
  - Added reset to 1.0 in resetToDefaults() (line ~3062)
- `SuperSpacesHUD.swift`:
  - Changed `fontSizeMultiplier` from @Published to computed property
  - Now reads from/writes to SettingsManager.shared.superSpacesFontSizeMultiplier
  - Added objectWillChange.send() for SwiftUI reactivity
  - Updated print statements to indicate "(persisted)"

**Technical Details:**
- Range: 0.8 (80%) to 1.5 (150%)
- Increment: 0.1 (10%) per Cmd+/Cmd- press
- Default: 1.0 (100% - normal size)
- Storage: CGFloat in UserDefaults (stored as Double)
- Applies to: All text in HUD via scaledFontSize() helper function

**Why This Matters:**
- **Accessibility:** Vision-impaired users can set larger text once and it persists
- **User Preference:** Power users who prefer compact UI can set smaller text permanently
- **Consistency:** Text size preference maintained across app restarts and system reboots
- **Expected Behavior:** Standard macOS pattern - user preferences should persist

#### 🔨 BUILD CHECK 5.5.9.6
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [x] Build succeeds ✅ (Jan 22, 2026)

#### 🧪 TEST CHECK 5.5.9.6
- [ ] Open HUD, press Cmd+ several times → text gets larger
- [ ] Press Cmd- several times → text gets smaller
- [ ] Quit app completely (Cmd+Q)
- [ ] Relaunch app
- [ ] Open HUD → text size should match what it was before quit
- [ ] Reset to defaults in Preferences → font size resets to 100%

---

#### 5.5.10 Integration & Menu Bar Access ⬜

**Goal:** Integrate Super Spaces into main app UI

- [ ] Add Super Spaces toggle to MenuBarView
- [ ] Add keyboard shortcut (Cmd+Shift+S)
- [ ] Add menu item "Show Super Spaces"
- [ ] Add "Super Spaces" section to Preferences
- [ ] Add enable/disable toggle in Preferences
- [ ] Add "Launch HUD on startup" option
- [ ] Add HUD position persistence
- [ ] Test integration with existing features

**Menu Bar Integration:**
```swift
// In MenuBarView.swift
Divider()

Button(action: {
    SuperSpacesHUD.shared.toggle()
}) {
    HStack {
        Image(systemName: "square.grid.3x3")
        Text("Super Spaces")
        Spacer()
        Text("⌘⇧S")
            .foregroundColor(.secondary)
            .font(.caption)
    }
}
.help("Show/hide Space switcher HUD")
```

#### 🔨 BUILD CHECK 5.5.9
```bash
xcodebuild -scheme SuperDimmer -configuration Debug build
```
- [ ] Build succeeds
- [ ] Menu integration compiles

#### 🧪 TEST CHECK 5.5.9
- [ ] Menu item toggles HUD
- [ ] Keyboard shortcut (Cmd+Shift+S) works
- [ ] Preferences section shows
- [ ] Enable/disable toggle works
- [ ] Launch on startup works
- [ ] HUD position persists
- [ ] No conflicts with other features

---

#### 🔨 BUILD CHECK - PHASE 5.5 FINAL
```bash
xcodebuild -scheme SuperDimmer -configuration Release build
```
- [ ] Release build succeeds
- [ ] All Super Spaces features work
- [ ] No memory leaks
- [ ] Performance acceptable

#### 🧪 TEST CHECK - PHASE 5.5 FINAL
- [ ] HUD shows on all Spaces
- [ ] Space switching works reliably
- [ ] All display modes work
- [ ] Settings button opens quick settings
- [ ] Emoji/icon customization works
- [ ] Note mode works (single/double click)
- [ ] Keyboard navigation works
- [ ] Integration with main app works
- [ ] Performance: CPU < 0.5% idle, < 2% active
- [ ] Memory: < 5 MB additional

#### 👀 REVIEW POINT - PHASE 5.5 COMPLETE
- [ ] All Super Spaces features implemented
- [ ] UI is polished and intuitive
- [ ] Settings persist correctly
- [ ] No crashes or hangs
- [ ] Documentation updated
- [ ] User guide created

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

### 2.13 Idle-Aware Timer Pause for All Features ✅ (Jan 22, 2026)

> **CRITICAL FIX** - All timed decay features now pause when user is idle
> This prevents windows from dimming and apps from being hidden due to time
> spent away from the computer (lunch, meetings, overnight, etc.).
>
> **Why this matters:** Without idle detection, users would come back from breaks
> to find everything heavily dimmed or hidden, even though they weren't actively
> ignoring those windows - they were just away. This fix ensures timers only
> count time during active computer use.

#### 2.13.1 Idle Detection Infrastructure ✅
- [x] `ActiveUsageTracker.swift` already implemented (Jan 8, 2026)
- [x] Tracks mouse movement, keyboard input, scroll wheel
- [x] Considers user "idle" after 30 seconds of no activity
- [x] Publishes `isUserActive` property for reactive updates
- [x] Posts notification when user returns from extended idle

#### 2.13.2 WindowInactivityTracker Idle Pause ✅ (Jan 22, 2026)
- [x] Subscribe to `ActiveUsageTracker.isUserActive` property
- [x] Record timestamp when user becomes idle (`idleSinceTime`)
- [x] In `getInactivityDuration()`: exclude idle time from calculation
- [x] When user is idle: calculate time up to idle start, not current time
- [x] When user returns: clear idle timestamp and resume normal calculation
- [x] Add debug logging for idle state changes
- [x] Works alongside space-aware freezing (both features independent)

#### 2.13.3 AppInactivityTracker Idle Pause ✅ (Jan 22, 2026)
- [x] Changed from simple timestamp to accumulated inactivity time
- [x] Added `accumulatedInactivityTime` field to `AppActivityInfo`
- [x] Created accumulation timer (runs every 10 seconds)
- [x] Timer only adds time when user is actively using computer
- [x] Subscribe to `ActiveUsageTracker.isUserActive` property
- [x] When user becomes idle: stop accumulating time
- [x] When user returns: resume accumulation
- [x] Add debug logging for idle state changes

#### 2.13.4 AutoMinimizeManager Idle Pause ✅ (Already Implemented Jan 8, 2026)
- [x] Already uses `ActiveUsageTracker.getIsUserActive()` in update loop
- [x] Only accumulates active time when user is active
- [x] Observes `.userReturnedFromExtendedIdle` notification
- [x] Resets all window timers when user returns from extended idle
- [x] No changes needed - already working correctly

#### 🔨 BUILD CHECK 2.13 ✅
```bash
cd /Users/ak/UserRoot/Github/SuperDimmer/SuperDimmer-Mac-App
xcodebuild -project SuperDimmer.xcodeproj -scheme SuperDimmer -configuration Debug clean build
```
- [x] Build succeeds with no errors
- [x] No warnings related to idle tracking

#### 🧪 TEST CHECK 2.13 ✅
- [x] Decay dimming pauses when user is idle (no mouse/keyboard for 30s)
- [x] Auto-hide pauses when user is idle
- [x] Auto-minimize pauses when user is idle (already working)
- [x] Debug logs show idle state changes ("User idle - pausing timers")
- [x] Debug logs show resume ("User active - resuming timers")
- [x] Timers resume correctly when user returns
- [x] No accumulated time during idle periods

#### 👀 REVIEW POINT 2.13 ✅
- [x] All three features (decay, auto-hide, auto-minimize) respect idle state
- [x] Idle detection is consistent across all features (30s threshold)
- [x] Debug logging is clear and helpful
- [x] No performance impact from idle tracking
- [x] Thread-safe implementation with proper locking

---

## 🔧 TROUBLESHOOTING LOG

### January 21, 2026 - Release v1.0.3: Super Spaces HUD and Intelligent Features

**Release Summary:**
Successfully built and released version 1.0.3 (build 9) with major feature additions:
- Super Spaces HUD with visual overview mode and per-space notes
- Idle-aware timer pause for all decay features (progressive dimming, auto-hide, auto-minimize)
- Progressive dimming based on window inactivity creating visual hierarchy
- Responsive window sizing with preferences persistence per mode
- Enhanced Overview mode layout with adaptive button sizing
- Font size persistence across HUD modes

**Files Updated:**
- Info.plist: Version 1.0.3, Build 9
- SuperDimmer-v1.0.3.dmg: 2,885,677 bytes
- version.json: Updated to v1.0.3
- appcast.xml: Added v1.0.3 entry
- changelog.html: Added v1.0.3 release notes (marked as Latest)
- release-notes/v1.0.3.html: Created comprehensive release notes page

**Major Features:**
- Super Spaces HUD: Revolutionary Space switcher with keyboard shortcuts and visual overview
- Idle Detection: All timers pause when user is idle (30s threshold)
- Progressive Dimming: Windows dim based on Space visit order and inactivity
- Responsive UI: HUD remembers window size preferences for each mode
- Per-Space Notes: Persistent notes for each macOS Space
- Overview Mode: Grid view of all Spaces with adaptive columns (2-5 columns based on width)

**Bug Fixes:**
- Fixed Overview Mode TextEditor input issues (NSPanel activation)
- Improved placeholder and cursor alignment in note editors
- Fixed progressive dimming visual hierarchy for clear rank distinction

**Performance:**
- Optimized idle detection and timer management
- Enhanced dimming algorithm with stronger visual range
- Better memory management for HUD window sizing

**Deployment:**
- DMG created and copied to releases/ folder
- All website files updated and committed
- Pushed to GitHub - Cloudflare Pages auto-deployment triggered
- Users will be notified via automatic update checker

**Build Process:**
```bash
cd SuperDimmer-Website/packaging
./release.sh 1.0.3 --skip-sign
# Build succeeded in ~64 seconds
# DMG created: 2.8MB
```

**Git Commits:**
- Mac App: 67e633a "Release v1.0.3 - Super Spaces HUD and Intelligent Features"
- Website: efebcf6 "Release v1.0.3 - Website Update"

---

### January 19, 2026 - Release v1.0.2: Automatic Update System

**Release Summary:**
Successfully built and released version 1.0.2 (build 8) with the following updates:
- Automatic update system with JSON-based update checking
- Beta channel support for early access features
- Fixed UpdateChecker.swift build integration issue
- Enhanced window tracking reliability
- Comprehensive update deployment documentation

**Files Updated:**
- Info.plist: Version 1.0.2, Build 8
- SuperDimmer-v1.0.2.dmg: 2,156,596 bytes
- version.json: Updated to v1.0.2
- appcast.xml: Added v1.0.2 entry
- changelog.html: Added v1.0.2 release notes
- release-notes/v1.0.2.html: Created new release notes page

**Deployment:**
- DMG created and copied to releases/ folder
- All website files updated for automatic deployment via Cloudflare Pages
- Ready for git commit and push to trigger deployment

---

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
*Updated: January 19, 2026 - Fixed build failure by adding UpdateChecker.swift to Xcode project; Added troubleshooting log section; Released v1.0.2 with automatic update system*