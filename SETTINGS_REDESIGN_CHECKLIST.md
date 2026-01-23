# SuperDimmer Settings Redesign Checklist

## Summary of Changes
Reorganize the Settings UI to better explain dimming features and provide clearer mode switching between the 3 types of dimming.

## Current Dimming Types Found:

### 1. Full-Screen Adaptive Dimming (Super Dimming - Simple Mode)
- Single overlay covering entire screen
- Settings: `isDimmingEnabled`, `globalDimLevel`
- Auto mode: `superDimmingAutoEnabled`, `autoAdjustRange`
- No per-window analysis, just dims entire screen

### 2. Window-Level Adaptive Dimming
- `intelligentDimmingEnabled` = true + `detectionMode = .perWindow`
- Creates one overlay per window
- Analyzes entire window brightness
- Can differentiate active/inactive windows

### 3. Zone/Region Dimming
- `intelligentDimmingEnabled` = true + `detectionMode = .perRegion`
- Finds bright areas WITHIN windows
- Creates overlays for specific bright regions
- Most precise but highest CPU usage

---

## Phase 1: Sidebar Renaming
- [ ] Rename "Brightness" tab to "SuperDimmer" in sidebar
- [ ] Rename "Window Management" tab to "Super Focus" in sidebar
- [ ] Update icons if needed for new names

## Phase 2: Dimming Mode Selector
- [ ] Create a 3-button segmented control for dimming mode selection:
  - Full Screen Adaptive Dimming
  - Window Level Adaptive Dimming  
  - Zone Dimming
- [ ] Add clear descriptions for each mode when selected
- [ ] Update SettingsManager to store selected dimming mode as enum

## Phase 3: Conditional Settings Display

### Settings that appear for ALL modes:
- [ ] Master dimming toggle (on/off)
- [ ] Brightness Threshold slider
- [ ] Base Dim Level slider

### Settings that appear ONLY for Full Screen Adaptive Dimming:
- [ ] Auto Mode toggle
- [ ] Adjustment Range slider (when Auto Mode enabled)

### Settings that appear ONLY for Window Level & Zone Dimming:
- [ ] Different levels for active/inactive windows toggle
- [ ] Active Window dim level slider
- [ ] Inactive Window dim level slider

### Settings that appear when ANY adaptive/intelligent dimming is enabled:
- [ ] Performance Tuning section (scan interval, tracking interval)

## Phase 4: Enhanced Explanations
- [ ] Add explanatory text for Full Screen mode
- [ ] Add explanatory text for Window Level mode
- [ ] Add explanatory text for Zone mode
- [ ] Add "How it works" tooltips or info buttons
- [ ] Add visual diagram or icon for each mode

## Phase 5: UI Polish
- [ ] Ensure smooth transitions when switching modes
- [ ] Test all conditional visibility rules
- [ ] Verify settings persist correctly
- [ ] Update any related documentation

## Phase 6: Testing
- [ ] Test Full Screen mode works correctly
- [ ] Test Window Level mode works correctly  
- [ ] Test Zone mode works correctly
- [ ] Test mode switching doesn't cause crashes
- [ ] Test settings persist across app restarts
- [ ] Build and verify no compilation errors

---

## Implementation Notes

### Current Code Locations:
- `PreferencesView.swift` - Main UI for settings
- `SettingsManager.swift` - All settings storage
- `DimmingCoordinator.swift` - Orchestrates dimming behavior
- `OverlayManager.swift` - Manages overlay windows

### Key Settings Variables:
```swift
isDimmingEnabled: Bool           // Master toggle
globalDimLevel: Double           // Base dim level (0.0-0.8)
superDimmingAutoEnabled: Bool    // Auto mode for full-screen
autoAdjustRange: Double          // Auto adjustment range
intelligentDimmingEnabled: Bool  // Per-window/region mode
detectionMode: DetectionMode     // .perWindow or .perRegion
differentiateActiveInactive: Bool // Active/inactive differentiation
activeDimLevel: Double           // Level for active windows
inactiveDimLevel: Double         // Level for inactive windows
brightnessThreshold: Double      // When to trigger dimming
scanInterval: Double             // Screenshot frequency
windowTrackingInterval: Double   // Position tracking frequency
```

### Proposed New Setting:
```swift
enum DimmingType: String, Codable {
    case fullScreen = "fullScreen"
    case windowLevel = "windowLevel"  
    case zoneLevel = "zoneLevel"
}

dimmingType: DimmingType  // Single selection for mode
```

---

## Progress Log

### Started: January 23, 2026
- [x] Analyzed codebase to understand dimming features
- [x] Identified all related settings
- [x] Created this checklist

### Phase 1: Sidebar renaming - COMPLETE
- [x] Renamed "Brightness" to "SuperDimmer" in PreferenceSection enum
- [x] Renamed "Window Management" to "Super Focus" in PreferenceSection enum
- [x] Updated icons for new names

### Phase 2: Mode selector - COMPLETE
- [x] Added DimmingType enum (fullScreen, windowLevel, zoneLevel) to SettingsManager
- [x] Added dimmingType property with persistence
- [x] Added synchronization between dimmingType and underlying settings
- [x] Created 3-button mode selector (DimmingModeButton component)
- [x] Mode selector shows icon, label, and highlight state

### Phase 3: Conditional settings - COMPLETE
- [x] Common settings (dim level, threshold) appear for all modes
- [x] Auto adjustment settings only appear for fullScreen mode
- [x] Active/inactive window settings only appear for windowLevel & zoneLevel
- [x] Performance tuning only appears for windowLevel & zoneLevel

### Phase 4: Enhanced explanations - COMPLETE
- [x] Each DimmingType has short and detailed descriptions
- [x] Mode description panel shows when mode is selected
- [x] CPU usage indicator for each mode
- [x] Permission warning for modes requiring screen recording

### Phase 5: UI polish - COMPLETE
- [x] Renamed BrightnessPreferencesTab to SuperDimmerPreferencesTab
- [x] Renamed WindowManagementPreferencesTab to SuperFocusPreferencesTab
- [x] Build succeeds without errors

### Phase 6: Testing - PENDING
- [ ] Test Full Screen mode works correctly
- [ ] Test Window Level mode works correctly  
- [ ] Test Zone mode works correctly
- [ ] Test mode switching doesn't cause crashes
- [ ] Test settings persist across app restarts

---

## Outstanding Issues
- Need to verify behavior when switching modes at runtime
- Need to test permission warning behavior

---

## Next Steps
1. User testing of the new UI
2. May need to add observer for dimmingType changes in DimmingCoordinator
3. Consider adding visual preview/demo of each mode
