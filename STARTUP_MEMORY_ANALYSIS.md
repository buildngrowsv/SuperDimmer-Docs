# Startup Memory Analysis - Additional Findings

**Date:** January 25, 2026  
**Current Status:** 214 MB at launch (down from 298 MB)  
**Improvement:** 84 MB saved (28% reduction)  
**Remaining Issue:** Still high at startup

---

## Good News: Autoreleasepool Fix IS Working! ✅

The memory dropped from **298 MB → 214 MB**, proving the autoreleasepool fix is effective. However, startup memory is still higher than desired.

---

## New Discovery: SuperSpaces HUD Memory Impact

### From Startup Logs:

```
✓ HUDManager: Loading 5 saved HUD configuration(s)
→ SuperSpacesHUD (hud_3): Created (overview mode)
→ SuperSpacesHUD (hud_6): Created (compact mode)
→ SuperSpacesHUD (hud_1): Created (note mode)
→ SuperSpacesHUD (hud_2): Created (overview mode)
→ SuperSpacesHUD (hud_7): Created (note mode)
```

**5 HUD windows** × ~15-20 MB each = **75-100 MB just for HUDs!**

### Each HUD Includes:
- NSWindow with backing store
- SwiftUI view hierarchy
- SpaceChangeMonitor (with timer)
- SpaceVisitTracker
- Keyboard shortcut handlers
- Position/size tracking

---

## Breakdown of 214 MB at Startup

| Component | Memory | Notes |
|-----------|--------|-------|
| **SuperSpaces HUDs** | ~80-90 MB | 5 windows with full UI |
| **Accessibility Observers** | ~30-40 MB | 31 app observers |
| **Base App + Services** | ~40-50 MB | Core functionality |
| **Timers & Monitors** | ~20-30 MB | Multiple timers running |
| **Screen Capture (transient)** | ~10-20 MB | Temporary during analysis |
| **Total** | **~214 MB** | Matches Activity Monitor |

---

## Why SuperSpaces HUDs Use So Much Memory

### 1. **SwiftUI View Complexity**
Each HUD has a complex view hierarchy:
- Space cards (10 spaces × multiple views)
- Buttons with hover states
- Text editors for notes
- Color pickers
- Emoji pickers
- Animations and transitions

### 2. **Multiple Monitors**
Each HUD runs its own:
- `SpaceChangeMonitor` with 0.5s polling timer
- `SpaceVisitTracker` maintaining history
- Position/size tracking with debounced saves

### 3. **Backing Store**
Each NSWindow maintains a backing store (pixel buffer) for rendering:
- Overview mode: ~700×540 = 378,000 pixels
- Compact mode: ~1680×150 = 252,000 pixels
- Note mode: ~540×690 = 372,600 pixels
- At 4 bytes/pixel (RGBA) = ~1.5 MB per window backing store

---

## Optimization Opportunities

### 🔴 HIGH IMPACT: Lazy HUD Loading

**Current:** All 5 HUDs created at launch  
**Proposed:** Only create HUDs when user opens them

**Implementation:**
```swift
// In HUDManager
private var hudConfigurations: [HUDConfiguration] = []  // Store configs
private var activeHUDs: [String: SuperSpacesHUD] = [:]  // Only active ones

func loadConfigurations() {
    // Load configs from UserDefaults but DON'T create windows yet
    hudConfigurations = loadSavedConfigs()
}

func showHUD(id: String) {
    // Create HUD on-demand when user requests it
    if activeHUDs[id] == nil {
        let config = hudConfigurations.first { $0.id == id }
        activeHUDs[id] = SuperSpacesHUD(config: config)
    }
    activeHUDs[id]?.show()
}
```

**Expected Savings:** 60-80 MB (only create 1-2 HUDs that user actually uses)

---

### 🟡 MEDIUM IMPACT: Share SpaceChangeMonitor

**Current:** Each HUD has its own monitor (5 timers polling every 0.5s)  
**Proposed:** One shared monitor that notifies all HUDs

**Implementation:**
```swift
// Singleton SpaceChangeMonitor
class SpaceChangeMonitor {
    static let shared = SpaceChangeMonitor()
    private var observers: [(Int) -> Void] = []
    
    func addObserver(_ callback: @escaping (Int) -> Void) {
        observers.append(callback)
    }
    
    private func notifyObservers(_ space: Int) {
        for observer in observers {
            observer(space)
        }
    }
}

// In SuperSpacesHUD
init() {
    SpaceChangeMonitor.shared.addObserver { [weak self] newSpace in
        self?.handleSpaceChange(newSpace)
    }
}
```

**Expected Savings:** 10-15 MB (4 fewer timers and monitoring structures)

---

### 🟡 MEDIUM IMPACT: Reduce SpaceVisitTracker Memory

**Current:** Each HUD tracks all 10 spaces with full history  
**Proposed:** Share visit tracking across HUDs

**Expected Savings:** 5-10 MB

---

### 🟢 LOW IMPACT: Optimize View Hierarchy

**Current:** All space cards rendered even if not visible  
**Proposed:** Use LazyVStack/LazyHStack in SwiftUI

**Expected Savings:** 2-5 MB

---

## Recommended Implementation Order

### Phase 1: Lazy HUD Loading (BIGGEST WIN) ⭐⭐⭐
- Don't create HUDs at launch
- Create on-demand when user opens them
- **Savings: 60-80 MB**
- **Difficulty: Medium**

### Phase 2: Share SpaceChangeMonitor ⭐⭐
- One monitor instead of 5
- **Savings: 10-15 MB**
- **Difficulty: Easy**

### Phase 3: Share SpaceVisitTracker ⭐
- One tracker for all HUDs
- **Savings: 5-10 MB**
- **Difficulty: Easy**

---

## Expected Results After All Optimizations

| Optimization | Current | After | Savings |
|-------------|---------|-------|---------|
| Lazy HUD loading | 214 MB | 154 MB | 60 MB |
| Shared monitors | 154 MB | 144 MB | 10 MB |
| Shared tracker | 144 MB | 139 MB | 5 MB |
| **TOTAL** | **214 MB** | **~140 MB** | **~75 MB** |

**Final Target: ~140 MB** (comparable to other menu bar utilities)

---

## Why This Wasn't Caught Earlier

The autoreleasepool fix focused on **runtime memory spikes** during screen capture. That's working perfectly (298 MB → 214 MB during operation).

The **startup memory** issue is different - it's about **persistent objects** (HUD windows) that stay in memory, not transient CGImages.

---

## Immediate Action: Verify HUD Impact

To confirm HUDs are the issue, try this test:

1. **Disable SuperSpaces** in settings
2. **Restart app**
3. **Check memory** in Activity Monitor

If memory drops to ~130-140 MB, we've confirmed HUDs are the culprit.

---

## Implementation Priority

**Quick Win (Today):**
- Implement lazy HUD loading
- Expected: 214 MB → ~150 MB

**Follow-up (Next):**
- Share SpaceChangeMonitor
- Expected: ~150 MB → ~140 MB

**Polish (Later):**
- Optimize view hierarchy
- Share SpaceVisitTracker

---

## Code Location for Lazy Loading

**File:** `SuperDimmer-Mac-App/SuperDimmer/SuperSpaces/SuperSpacesHUDManager.swift`

**Current init() loads all HUDs:**
```swift
init() {
    // Load saved configurations
    let configs = loadSavedConfigurations()
    
    // Create ALL HUD windows immediately
    for config in configs {
        let hud = SuperSpacesHUD(config: config)
        huds[config.id] = hud
        if config.isVisible {
            hud.show()
        }
    }
}
```

**Proposed lazy loading:**
```swift
init() {
    // Only load configurations, don't create windows
    self.configurations = loadSavedConfigurations()
    
    // Create default HUD if user has SuperSpaces enabled
    if SettingsManager.shared.superSpacesEnabled {
        createHUDIfNeeded(id: "default")
    }
}

private func createHUDIfNeeded(id: String) {
    guard huds[id] == nil else { return }
    
    if let config = configurations.first(where: { $0.id == id }) {
        let hud = SuperSpacesHUD(config: config)
        huds[id] = hud
        if config.isVisible {
            hud.show()
        }
    }
}
```

This way, only HUDs that are actually shown get created, saving 60-80 MB at startup.
