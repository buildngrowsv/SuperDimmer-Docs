# SuperDimmer - Product Requirements Document (PRD)
## Intelligent Region-Specific Screen Dimming for macOS
### Version 1.1 | January 12, 2026

---

## 📋 Document Information

| Item | Details |
|------|---------|
| **Product Name** | SuperDimmer |
| **Platform** | macOS (menu bar utility) |
| **Target macOS** | 13.0+ (Ventura and later) |
| **Business Model** | Freemium with Paddle licensing |
| **Development Stack** | Swift 5.9+, SwiftUI + AppKit |

---

## 🎯 Executive Summary

### The Problem

Users working in dark environments or with light sensitivity face a common frustration: **bright content islands appearing within dark-themed applications**. Examples include:

1. **Email apps** (Mail, Outlook, Gmail) - Dark UI but emails from others often have white backgrounds
2. **Web browsers** - Dark mode browser chrome, but many websites are blindingly white
3. **Extensions & widgets** - Mixed appearance themes within apps
4. **Document viewers** - White documents in dark-themed apps
5. **Chat apps** - Dark interface but embedded content/images may be bright

Existing brightness control apps offer only **full-screen uniform dimming** - they cannot selectively dim only the bright regions while leaving dark content at normal brightness.

### The Solution

**SuperDimmer** is the **first macOS app** to offer **intelligent, automatic, region-specific dimming** of bright content. It analyzes screen content in real-time and applies targeted dimming overlays only to areas that exceed a user-defined brightness threshold.

### Market Opportunity

- **Confirmed market gap** - No existing macOS app offers region-specific brightness detection and dimming
- **Growing dark mode adoption** - Most users now prefer dark themes, making bright content more jarring
- **Remote work normalization** - More users working in varied lighting conditions
- **Eye health awareness** - Increased concern about screen strain and blue light exposure

---

## 🚀 Product Vision

> **SuperDimmer:** Your eyes' intelligent shield against bright content - dimming what hurts, preserving what doesn't.

### Core Value Propositions

1. **Region-Specific Intelligence** - Only dims bright areas, dark content stays untouched
2. **Context-Aware Dimming** - Less dimming on active windows, more on background windows
3. **Zero Configuration Needed** - Works automatically out of the box with smart defaults
4. **Professional Polish** - Beautiful UI, smooth animations, seamless integration
5. **Complete Solution** - Combines bright spot dimming + wallpaper management + color temperature

---

## 👥 Target Users

### Primary Personas

| Persona | Description | Key Pain Points |
|---------|-------------|-----------------|
| **Night Owl Developer** | Works late in dark environment | Bright terminal output, white web docs, mixed-theme IDEs |
| **Light-Sensitive Professional** | Medical condition or preference | Any unexpected bright content causes discomfort |
| **Media Creative** | Video/photo editor in dark room | Need accurate colors but bright UI elements strain eyes |
| **Remote Worker** | Home office with varied lighting | Switching between light/dark environments |

### Secondary Personas

- Power users seeking granular control over display appearance
- Users with multiple monitors wanting different brightness zones
- Users who want automatic light/dark wallpaper switching (Umbra-style feature)

---

## 🎁 Feature Specification

### Feature Categories

```
┌─────────────────────────────────────────────────────────────────┐
│                    SuperDimmer Feature Map                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ CORE: Intelligent Bright Region Dimming                   │   │
│  │ • Real-time brightness detection                          │   │
│  │ • Intelligent Window Dimming (dims whole windows)         │   │
│  │ • Intelligent Zone Dimming (dims bright areas only)       │   │
│  │ • Active/inactive window differentiation                  │   │
│  │ • Inactivity decay dimming (window-level)                 │   │
│  │ • Dynamic overlay tracking (real-time position/scale)     │   │
│  │ • Hidden app overlay cleanup                              │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ FOCUS: Workspace Management                               │   │
│  │ • Auto-hide inactive apps (app-level)                     │   │
│  │ • Auto-minimize inactive windows (window-level)           │   │
│  │ • Configurable inactivity thresholds                      │   │
│  │ • Recently hidden apps list                               │   │
│  │ • Per-app exclusions with granular control                │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ COMFORT: Color Temperature & Scheduling                   │   │
│  │ • Blue light filter (f.lux-style)                         │   │
│  │ • Time-based scheduling                                   │   │
│  │ • Sunrise/sunset automation                               │   │
│  │ • Dark/Light mode integration                             │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ AESTHETICS: Wallpaper Management (Umbra-style)            │   │
│  │ • Light/dark wallpaper pairs                              │   │
│  │ • Automatic switching with appearance                     │   │
│  │ • Wallpaper dimming (dims desktop only)                   │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ PRO: Advanced Controls                                    │   │
│  │ • Per-app rules with granular exclusions                  │   │
│  │ • Separate exclusions for hide/minimize/dimming           │   │
│  │ • Per-display settings                                    │   │
│  │ • Keyboard shortcuts                                      │   │
│  │ • Scheduled profiles                                      │   │
│  │ • Settings presets (Balanced, Aggressive, Subtle)         │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ UX: Simplified Interface                                  │   │
│  │ • Clean menu bar with quick toggles only                  │   │
│  │ • All adjustments moved to Preferences                    │   │
│  │ • New distinctive menu bar icon                           │   │
│  │ • Settings presets and reset to defaults                  │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

### 🔥 CORE FEATURE: Intelligent Bright Region Dimming

**This is SuperDimmer's unique differentiator - no other app does this.**

#### Feature: Real-Time Brightness Detection

| Attribute | Specification |
|-----------|---------------|
| **Description** | Continuously analyze screen content to identify regions exceeding brightness threshold |
| **Scan Frequency** | 0.5 - 2 seconds (user configurable) |
| **Detection Method** | Luminance calculation using Rec. 709: `Y' = 0.2126×R + 0.7152×G + 0.0722×B` |
| **Granularity** | Grid-based sampling (configurable: per-window, per-region, per-pixel-block) |
| **Performance** | Accelerate/vImage framework for SIMD optimization |

**User Controls:**
- **Brightness Threshold Slider**: 0-100% (default: 85%)
  - "Only dim very bright content" → 95%
  - "Dim moderately bright content" → 70%
  - "Dim anything not truly dark" → 50%

#### Feature: Region-Specific Overlay Dimming

| Attribute | Specification |
|-----------|---------------|
| **Description** | Apply transparent dimming overlays only to detected bright regions |
| **Overlay Type** | NSWindow with `ignoresMouseEvents = true` (click-through) |
| **Window Level** | `.screenSaver` or custom CGWindowLevel (above content, below system UI) |
| **Behavior** | Joins all Spaces, works with fullscreen apps |
| **Animation** | Smooth fade in/out transitions (0.2-0.3s) |

**Dimming Levels:**
- Minimum dimming: 0% (effectively off)
- Maximum dimming: 80% (near black but content still visible)
- Default: 25% for active windows, 40% for inactive windows

#### Feature: Active vs Inactive Window Differentiation

| Attribute | Specification |
|-----------|---------------|
| **Description** | Apply different dimming intensity based on window focus state |
| **Detection** | Track `NSWorkspace.shared.frontmostApplication` |
| **Active Window** | Window belongs to frontmost app → lighter dimming |
| **Inactive Windows** | All other visible windows → heavier dimming |
| **Rationale** | Preserves visibility of content you're actively using |

**User Controls:**
- Active window dim amount: 0-50% (default: 15%)
- Inactive window dim amount: 0-80% (default: 35%)
- Option to disable differentiation (uniform dimming)

---

#### Feature: Inactivity Decay Dimming (WINDOW-LEVEL)

| Attribute | Specification |
|-----------|---------------|
| **Description** | Windows that haven't been switched to progressively increase in dimness over time until hitting a maximum limit |
| **Scope** | Per-window - each window tracks its own inactivity timer |
| **Decay Trigger** | Starts after configurable delay (default: 30 seconds of inactivity) |
| **Decay Rate** | Configurable: 0.01-0.10 per second (default: 0.02 = 2% per second) |
| **Maximum Level** | Configurable cap (default: 70% dimming) - never goes darker than this |
| **Reset Behavior** | Switching to a window immediately resets its decay to base inactive level |
| **Rationale** | Creates visual hierarchy emphasizing active work while naturally de-emphasizing stale windows |

**User Controls:**
- Enable/disable inactivity decay toggle
- Decay rate slider: Slow (0.01/sec) → Medium (0.02/sec) → Fast (0.05/sec)
- Decay start delay: 10 seconds → 120 seconds
- Maximum decay level: 40% → 90%

**Use Case Example:**
> You have 8 browser windows open. The 3 you've used in the last minute are at normal inactive dimming (35%).
> The 5 you haven't touched in 2+ minutes are progressively darker (40%, 50%, 60%...), 
> visually signaling which windows are "stale" vs "recently used."

---

#### Feature: Dynamic Overlay Tracking (NEW)

| Attribute | Specification |
|-----------|---------------|
| **Description** | Overlays follow window position and scale in real-time, separate from expensive screenshot analysis |
| **Tracking Frequency** | 5-10 Hz (every 0.1-0.2 seconds) for position/scale updates |
| **Analysis Frequency** | 0.5-2 Hz (every 0.5-2 seconds) for brightness analysis |
| **Implementation** | Lightweight CGWindowListCopyWindowInfo polling vs expensive screenshot capture |
| **Benefit** | No visible lag when moving/resizing windows; overlays "stick" to their target windows |

**User-Visible Behavior:**
- Window moved → Overlay follows immediately (no 2-second delay)
- Window resized → Overlay scales smoothly with animation
- Window changes z-order → Overlay updates layer immediately
- Much more responsive feel than waiting for screenshot analysis

**Technical Notes:**
- `updateOverlayFrames()` - fast method, no screenshot, called at high frequency
- `performAnalysis()` - slow method, takes screenshot, called at low frequency
- Both run on different timers for optimal performance

---

#### Feature: Hidden App Overlay Cleanup (NEW)

| Attribute | Specification |
|-----------|---------------|
| **Description** | When apps are hidden (Cmd+H), their overlays are immediately removed |
| **Detection** | NSWorkspace `didHideApplicationNotification` observer |
| **Behavior** | Hidden app → All overlays for that app removed instantly |
| **Restore** | When app is unhidden, re-analysis creates new overlays if needed |
| **Rationale** | Prevents orphaned overlays floating over hidden content |

**Why This Matters:**
> **BUG**: Previously, hiding an app (Cmd+H) would leave its dimming overlays visible,
> floating awkwardly over whatever was behind the window. This broke the user's mental
> model and made overlays seem buggy. Now overlays follow the same hide/show lifecycle
> as the windows they dim.

---

#### Feature: Separate Window vs Zone Dimming (NEW)

| Attribute | Specification |
|-----------|---------------|
| **Description** | Two independent intelligent dimming modes that can be enabled separately |
| **Window Dimming** | Analyzes entire window brightness, dims whole window if bright |
| **Zone Dimming** | Finds bright regions within windows, dims only those areas |
| **Independence** | Each can be enabled/disabled independently |
| **Combinations** | Neither (full-screen only), Window only, Zone only, or Both |

**User Controls:**
- "Intelligent Window Dimming" toggle - dims bright windows
- "Intelligent Zone Dimming" toggle - dims bright areas in windows
- When both enabled: zone dimming applies within window analysis context

**Use Cases:**
- **Window Only**: Simple, lower CPU, good for most users
- **Zone Only**: Maximum precision for dark mode apps with bright content (Mail, browsers)
- **Both**: Maximum coverage, higher CPU usage
- **Neither**: Simple full-screen overlay mode (like other dimming apps)

---

#### Feature: Auto-Hide Inactive Apps (APP-LEVEL)

| Attribute | Specification |
|-----------|---------------|
| **Description** | Automatically hide entire applications that haven't been used for a configurable duration |
| **Scope** | Per-app - operates at application level, not individual windows |
| **Hide Trigger** | App hasn't been in foreground for X minutes (default: 30 minutes) |
| **Implementation** | Uses `NSRunningApplication.hide()` - standard macOS hide behavior |
| **Exclusions** | User-defined exclusion list + optional system apps exclusion (Finder, etc.) |
| **Notification** | Optional notification when an app is auto-hidden |
| **Rationale** | Reduces visual clutter from forgotten apps without requiring manual intervention |

**User Controls:**
- Enable/disable auto-hide toggle
- Auto-hide delay: 5 minutes → 120 minutes
- Excluded apps list (bundle IDs)
- "Exclude system apps" checkbox
- Show notification on auto-hide toggle
- "Recently Auto-Hidden" list with quick unhide buttons

**Difference from Decay Dimming:**
| Aspect | Decay Dimming | Auto-Hide |
|--------|---------------|-----------|
| **Scope** | Per-window | Per-app |
| **Action** | Increases dimming overlay | Hides entire application |
| **Reversibility** | Automatic on window activation | Requires manual unhide or app switch |
| **Typical Delay** | Seconds | Minutes |
| **Use Case** | Visual de-emphasis | Workspace cleanup |

---

---

#### Feature: Granular App Exclusions (NEW)

| Attribute | Specification |
|-----------|---------------|
| **Description** | Different exclusion settings per app for different behaviors |
| **Exclusion Types** | Dimming, Auto-Hide, Auto-Minimize (each independent) |
| **UI** | Unified list with checkboxes per exclusion type |
| **Storage** | `AppExclusion` struct with per-behavior flags, stored as JSON |

**Exclusion Options Per App:**
- **Exclude from Dimming** - App's windows are never dimmed
- **Exclude from Auto-Hide** - App is never auto-hidden
- **Exclude from Auto-Minimize** - App's windows are never auto-minimized

**UI Example:**
```
┌─────────────────────────────────────────────────────────┐
│ Excluded Apps                                           │
├─────────────────────────────────────────────────────────┤
│ App Name         │ Dimming │ Auto-Hide │ Auto-Minimize │
├──────────────────┼─────────┼───────────┼───────────────┤
│ Adobe Photoshop  │   ☑     │    ☐      │      ☐        │
│ FaceTime         │   ☐     │    ☑      │      ☑        │
│ Finder           │   ☐     │    ☑      │      ☑        │
└─────────────────────────────────────────────────────────┘
```

**Why Granular Control:**
> Users may want an app excluded from dimming (color-critical work) but still
> auto-hidden when not in use. Or they may want an app to never be hidden
> (system monitoring) but still have its bright areas dimmed.

---

### 🌡️ COMFORT FEATURE: Color Temperature & Scheduling

**Similar to f.lux - provides blue light filtering for additional eye comfort.**

#### Feature: Color Temperature Adjustment

| Attribute | Specification |
|-----------|---------------|
| **Description** | Shift display color temperature to reduce blue light |
| **Implementation** | Gamma table manipulation via `CGSetDisplayTransferByTable` |
| **Temperature Range** | 6500K (daylight) → 1900K (candlelight) |
| **Default Presets** | Daylight (6500K), Sunset (4100K), Night (2700K), Bedtime (1900K) |

#### Feature: Time-Based Scheduling

| Attribute | Specification |
|-----------|---------------|
| **Description** | Automatically adjust color temperature based on time of day |
| **Schedule Types** | Manual times, Sunrise/Sunset (location-based), Custom profiles |
| **Transition** | Gradual shift over user-defined duration (default: 60 minutes) |
| **Location** | CoreLocation for sunrise/sunset calculation |

---

#### Feature: Dark/Light Mode Integration (NEW)

| Attribute | Specification |
|-----------|---------------|
| **Description** | Enable/disable SuperDimmer based on system appearance mode |
| **Modes** | Always On, Light Mode Only, Dark Mode Only, Follow System |
| **Implementation** | NSApp.effectiveAppearance observer |
| **Per-Mode Settings** | Different dim levels and thresholds for light vs dark mode |

**Appearance Modes:**
- **Always On** - Dimming active regardless of system appearance
- **Light Mode Only** - Dimming only active in Light Mode (disabled in Dark Mode)
- **Dark Mode Only** - Dimming only active in Dark Mode (disabled in Light Mode)
- **Follow System** - Same as "Always On" (for clarity in UI)

**Per-Mode Settings:**
- Light mode typically has brighter content → may need more aggressive dimming
- Dark mode typically has darker content → may need less dimming
- Users can configure different thresholds for each appearance mode

**User Controls:**
- Quick toggle in menu bar: "Dark Mode" / "Light Mode" / "Auto"
- Appearance mode picker in Preferences (General tab)
- Optional: Different dim levels per appearance mode

---

### 🖼️ AESTHETICS FEATURE: Wallpaper Management

**Inspired by Umbra - automatic wallpaper switching with appearance mode.**

#### Feature: Light/Dark Wallpaper Pairs

| Attribute | Specification |
|-----------|---------------|
| **Description** | Set different wallpapers for Light Mode and Dark Mode |
| **Switching** | Automatic when macOS appearance changes |
| **Per-Space Support** | Different pairs for each Space/Desktop |
| **Per-Display Support** | Different pairs for each connected display |

#### Feature: Wallpaper Dimming (ENHANCED)

| Attribute | Specification |
|-----------|---------------|
| **Description** | Apply dimming overlay specifically to desktop wallpaper, below all windows |
| **Window Level** | `.desktop` or equivalent - sits above wallpaper but below ALL windows |
| **Use Case** | Reduce bright wallpaper distraction without affecting windows |
| **Dim Amount** | 0-80% adjustable via slider |
| **Quick Access** | Toggle in main menu bar popover |
| **Per-Display** | Can set different dim levels per connected display |
| **Schedule** | Can follow color temperature schedule (dim wallpaper at night) |

**Implementation Notes:**
- Overlay at desktop level, NOT screenSaver level
- Must not interfere with click-through to desktop icons
- Must work with Spaces (one overlay per space if different wallpapers)

---

### 🎨 UX FEATURE: Simplified Interface (NEW)

**Inspired by user feedback to reduce complexity in the menu bar popover.**

#### Feature: Streamlined Menu Bar Popover

| Attribute | Specification |
|-----------|---------------|
| **Description** | Move all adjustment sliders to Preferences; menu bar shows only toggles and status |
| **Goal** | Reduce overwhelm, make app easier to understand at a glance |
| **Quick Actions** | Main toggles, status summary, link to Preferences |

**Menu Bar Popover Content (Simplified):**
```
┌────────────────────────────────────────┐
│  SuperDimmer                    Pro ✓  │
├────────────────────────────────────────┤
│  ☀️ Brightness Dimming        [ON/OFF] │
│     Dimming 25% | Threshold 85%        │
│                                        │
│  🌡️ Color Temperature         [ON/OFF] │
│     4800K (Sunset)                     │
│                                        │
│  🖼️ Wallpaper Dimming         [ON/OFF] │
│     30% dimmed                         │
│                                        │
│  ⏸️ Pause Dimming              [5min▾] │
│                                        │
├────────────────────────────────────────┤
│  ⚙️ Adjust Settings...                 │
│  ❌ Quit                               │
└────────────────────────────────────────┘
```

**What Moves to Preferences:**
- All sliders (dim level, threshold, etc.)
- Active/inactive window settings
- Inactivity decay settings
- Detection mode settings
- Excluded apps management
- Color temperature presets
- Schedule configuration

---

#### Feature: New Menu Bar Icon

| Attribute | Specification |
|-----------|---------------|
| **Description** | New distinctive icon to differentiate from other dimming/display apps |
| **Current** | Sun icon (too similar to f.lux, brightness controls) |
| **Options** | Moon with stars, Eye with rays, Contrast circle, Spotlight beam |
| **States** | Disabled (outline), Active (filled), Temperature active (tinted) |
| **Dark/Light** | Works on both light and dark menu bar backgrounds |

**Icon Design Considerations:**
- Should suggest "dimming" or "comfort" not "brightness increase"
- Avoid sun (f.lux, macOS), monitor (MonitorControl), moon alone (Night Shift)
- Consider: half-moon, eye with soft glow, adjustable iris, gradient circle

---

#### Feature: Settings Presets & Defaults (NEW)

| Attribute | Specification |
|-----------|---------------|
| **Description** | Pre-configured settings for common use cases |
| **Presets** | Balanced, Aggressive, Subtle, Custom |
| **Reset** | "Reset to Defaults" button in Preferences |
| **First Launch** | Sensible defaults with dimming OFF |

**Preset Definitions:**
- **Balanced** (default): 25% dim, 85% threshold, moderate decay
- **Aggressive**: 40% dim, 70% threshold, fast decay, zone dimming enabled
- **Subtle**: 15% dim, 95% threshold, slow/no decay, window dimming only
- **Custom**: User's current settings (saved automatically)

**User Controls:**
- Preset picker in Preferences (General tab)
- "Reset to Defaults" button
- Save current settings as custom preset

---

### ⚡ PRO FEATURES: Advanced Controls

**Premium features for power users - requires Pro license.**

#### Feature: Per-App Rules

| Attribute | Specification |
|-----------|---------------|
| **Description** | Customize dimming behavior for specific applications |
| **Rule Types** | Always dim, Never dim, Custom threshold, Custom dim amount |
| **App Selection** | Browse running apps or select from /Applications |

#### Feature: Per-Display Settings

| Attribute | Specification |
|-----------|---------------|
| **Description** | Different brightness thresholds and dim amounts per monitor |
| **Detection** | Automatic display identification |
| **Profiles** | Save and switch between display configurations |

#### Feature: Keyboard Shortcuts

| Attribute | Specification |
|-----------|---------------|
| **Description** | Quick access to common controls via keyboard |
| **Implementation** | Using KeyboardShortcuts library (like MonitorControlLite) |
| **Default Shortcuts** | Toggle on/off, increase/decrease dim, cycle presets |

#### Feature: Scheduled Profiles

| Attribute | Specification |
|-----------|---------------|
| **Description** | Different settings for different times/contexts |
| **Profile Examples** | "Daytime Work", "Evening Relaxation", "Movie Night", "Late Night Coding" |
| **Triggers** | Time-based, Location-based, Manual switching |

---

## 🏗️ Technical Architecture

### High-Level System Design

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     SuperDimmer System Architecture                      │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│   ┌──────────────────────────────────────────────────────────────────┐  │
│   │                        Menu Bar Interface                          │  │
│   │    [Icon] → Quick Toggles | Sliders | Settings | Preferences      │  │
│   └──────────────────────────────────────────────────────────────────┘  │
│                                    │                                     │
│                                    ▼                                     │
│   ┌──────────────────────────────────────────────────────────────────┐  │
│   │                      Settings Manager                              │  │
│   │    UserDefaults | Profiles | Per-App Rules | License State        │  │
│   └──────────────────────────────────────────────────────────────────┘  │
│                                    │                                     │
│           ┌────────────────────────┼────────────────────────┐           │
│           │                        │                        │           │
│           ▼                        ▼                        ▼           │
│   ┌──────────────┐      ┌──────────────────┐      ┌────────────────┐   │
│   │  Screen      │      │  Window          │      │  Appearance    │   │
│   │  Capture     │      │  Tracker         │      │  Observer      │   │
│   │  Service     │      │  Service         │      │  Service       │   │
│   │              │      │                  │      │                │   │
│   │CGWindowList  │      │CGWindowListCopy  │      │NSAppearance    │   │
│   │CreateImage   │      │WindowInfo        │      │EffectiveChange │   │
│   └──────┬───────┘      └────────┬─────────┘      └───────┬────────┘   │
│          │                       │                        │            │
│          └───────────────┬───────┴────────────────────────┘            │
│                          │                                              │
│                          ▼                                              │
│   ┌──────────────────────────────────────────────────────────────────┐  │
│   │                    Brightness Analysis Engine                      │  │
│   │                                                                    │  │
│   │   ┌────────────────┐   ┌────────────────┐   ┌────────────────┐   │  │
│   │   │  Downsampler   │──▶│  Luminance     │──▶│  Region        │   │  │
│   │   │  (vImage)      │   │  Calculator    │   │  Detector      │   │  │
│   │   │                │   │  (Rec. 709)    │   │  (Components)  │   │  │
│   │   └────────────────┘   └────────────────┘   └────────────────┘   │  │
│   │                                                                    │  │
│   └──────────────────────────────────────────────────────────────────┘  │
│                          │                                              │
│                          ▼                                              │
│   ┌──────────────────────────────────────────────────────────────────┐  │
│   │                     Overlay Manager                                │  │
│   │                                                                    │  │
│   │   • Creates/updates/removes DimOverlayWindow instances            │  │
│   │   • Manages window lifecycle and z-ordering                        │  │
│   │   • Animates opacity transitions                                   │  │
│   │   • Handles multi-display coordination                             │  │
│   │                                                                    │  │
│   └──────────────────────────────────────────────────────────────────┘  │
│                          │                                              │
│                          ▼                                              │
│   ┌──────────────────────────────────────────────────────────────────┐  │
│   │                     Color Temperature Engine                       │  │
│   │                                                                    │  │
│   │   • CGSetDisplayTransferByTable for gamma control                 │  │
│   │   • Kelvin → RGB gamma curve calculation                          │  │
│   │   • Smooth transition animations                                   │  │
│   │                                                                    │  │
│   └──────────────────────────────────────────────────────────────────┘  │
│                          │                                              │
│                          ▼                                              │
│   ┌──────────────────────────────────────────────────────────────────┐  │
│   │                     Wallpaper Manager                              │  │
│   │                                                                    │  │
│   │   • NSWorkspace wallpaper APIs                                    │  │
│   │   • AppleScript for appearance toggle (like f.lux)                │  │
│   │   • Per-space wallpaper configuration                              │  │
│   │                                                                    │  │
│   └──────────────────────────────────────────────────────────────────┘  │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

### Core Technical Components

#### 1. Screen Capture Service

**Purpose:** Capture screen content for brightness analysis

**Implementation Pattern (from research):**
```swift
// Based on BetterDisplay/MonitorControl approaches
// Requires Screen Recording permission

import CoreGraphics

final class ScreenCaptureService {
    
    /// Captures the entire main display for brightness analysis
    /// Uses CGDisplayCreateImage which requires Screen Recording permission
    /// Returns downsampled image for performance (analyzing full resolution not needed)
    func captureMainDisplay() -> CGImage? {
        let displayID = CGMainDisplayID()
        return CGDisplayCreateImage(displayID)
    }
    
    /// Captures a specific screen region for targeted analysis
    /// Useful for analyzing only visible window regions
    func captureRegion(_ rect: CGRect) -> CGImage? {
        return CGWindowListCreateImage(
            rect,
            .optionOnScreenOnly,
            kCGNullWindowID,
            [.bestResolution, .boundsIgnoreFraming]
        )
    }
}
```

**Key Learnings from Reference Apps:**
- **f.lux** and **MonitorControlLite** do NOT use screen capture - they modify gamma/overlays
- **SuperDimmer UNIQUELY requires screen capture** for brightness detection
- Must handle permission gracefully with clear user messaging

---

#### 2. Window Tracker Service

**Purpose:** Track visible windows and their ownership for active/inactive differentiation

**Implementation Pattern (from research):**
```swift
import AppKit
import CoreGraphics

/// Represents a visible window on screen with its metadata
/// Used to determine which windows need dimming and at what level
struct TrackedWindow {
    let windowID: CGWindowID       // Unique identifier for this window
    let ownerPID: pid_t            // Process ID of owning application
    let ownerName: String          // Application name (e.g., "Safari")
    let bounds: CGRect             // Window position and size
    let layer: Int                 // Window layer (z-order)
    let title: String              // Window title if available
    let isActive: Bool             // True if belongs to frontmost app
}

final class WindowTrackerService {
    
    /// Gets all visible windows with their metadata
    /// Filters out desktop elements, menu bar, dock, etc.
    func getVisibleWindows() -> [TrackedWindow] {
        let options: CGWindowListOption = [.optionOnScreenOnly, .excludeDesktopElements]
        guard let infoList = CGWindowListCopyWindowInfo(options, kCGNullWindowID) 
              as? [[String: Any]] else {
            return []
        }
        
        let frontmostPID = NSWorkspace.shared.frontmostApplication?.processIdentifier
        
        return infoList.compactMap { info -> TrackedWindow? in
            // Parse window info dict into TrackedWindow struct
            // Mark windows from frontmost app as "active"
        }
    }
}
```

---

#### 3. Brightness Analysis Engine

**Purpose:** Analyze captured screen regions to detect bright content

**Implementation Pattern (from research):**
```swift
import Accelerate
import CoreGraphics

/// Engine for detecting bright regions in screen captures
/// Uses Accelerate framework for high-performance SIMD operations
final class BrightnessAnalysisEngine {
    
    /// Brightness threshold - regions brighter than this trigger dimming
    /// Range 0.0-1.0, default 0.85 (85% brightness)
    var brightnessThreshold: Float = 0.85
    
    /// Calculates average luminance for a screen region using Rec. 709 formula
    /// Y' = 0.2126×R + 0.7152×G + 0.0722×B
    /// Returns value from 0.0 (black) to 1.0 (white)
    func averageLuminance(in image: CGImage, rect: CGRect) -> Float? {
        // 1. Extract pixels using vImage
        // 2. Apply luminance coefficients
        // 3. Return average
    }
    
    /// Detects distinct bright regions within an image
    /// Uses grid-based sampling for performance
    /// Returns bounding boxes of regions exceeding threshold
    func detectBrightRegions(in image: CGImage) -> [CGRect] {
        // 1. Downsample for performance
        // 2. Calculate luminance grid
        // 3. Threshold to binary
        // 4. Connected component analysis
        // 5. Return bounding rectangles
    }
}
```

**Performance Optimizations (learned from reference apps):**
- **Downsample first** - Don't analyze at full resolution
- **Grid sampling** - Check brightness at regular intervals, not every pixel
- **Cache results** - Only re-analyze when content likely changed
- **Background thread** - Don't block main thread during analysis

---

#### 4. Overlay Manager

**Purpose:** Create and manage transparent dimming overlay windows

**Implementation Pattern (from MonitorControlLite/Lunar):**
```swift
import AppKit

/// Transparent overlay window that dims content beneath it
/// Configured to be click-through so it doesn't interfere with mouse events
/// Appears on all Spaces and works with fullscreen apps
final class DimOverlayWindow: NSWindow {
    
    init(frame: CGRect, screen: NSScreen, dimLevel: CGFloat) {
        super.init(
            contentRect: frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false,
            screen: screen
        )
        
        // CRITICAL: These settings make the overlay non-intrusive
        // Learned from MonitorControlLite and Lunar implementations
        self.isOpaque = false
        self.backgroundColor = .clear
        self.hasShadow = false
        self.ignoresMouseEvents = true       // Let clicks pass through
        self.level = .screenSaver            // High z-order but below critical UI
        self.collectionBehavior = [
            .canJoinAllSpaces,               // Appear on all Spaces
            .fullScreenAuxiliary,            // Work with fullscreen apps
            .stationary                      // Don't move with window dragging
        ]
        
        // The dimming view - a black semi-transparent layer
        let dimView = NSView(frame: frame)
        dimView.wantsLayer = true
        dimView.layer?.backgroundColor = NSColor.black.withAlphaComponent(dimLevel).cgColor
        self.contentView = dimView
    }
    
    /// Animate opacity change for smooth transitions
    /// Prevents jarring sudden darkness changes
    func setDimLevel(_ level: CGFloat, animated: Bool = true) {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.duration = animated ? 0.25 : 0
        contentView?.layer?.add(animation, forKey: "opacity")
        contentView?.layer?.backgroundColor = NSColor.black.withAlphaComponent(level).cgColor
    }
}

/// Manages lifecycle of all overlay windows
/// Creates, updates, removes overlays as bright regions change
final class OverlayManager {
    private var activeOverlays: [CGWindowID: DimOverlayWindow] = [:]
    
    /// Update overlays based on detected bright regions
    /// Creates new overlays, updates existing ones, removes stale ones
    func updateOverlays(for brightRegions: [(window: TrackedWindow, regions: [CGRect])]) {
        // Implementation details...
    }
}
```

---

#### 5. Color Temperature Engine

**Purpose:** Adjust display color temperature for blue light filtering

**Implementation Pattern (from f.lux analysis):**
```swift
import CoreGraphics

/// Controls display color temperature via gamma table manipulation
/// Based on f.lux implementation approach
final class ColorTemperatureEngine {
    
    /// Current color temperature in Kelvin
    /// Range: 1900K (candlelight) to 6500K (daylight)
    private var currentTemperature: Int = 6500
    
    /// Apply color temperature to display using gamma tables
    /// Uses CGSetDisplayTransferByTable API
    func setTemperature(_ kelvin: Int, for displayID: CGDirectDisplayID) {
        // 1. Calculate RGB multipliers from Kelvin value
        // 2. Generate gamma table curves
        // 3. Apply via CGSetDisplayTransferByTable
    }
    
    /// Convert Kelvin temperature to RGB multipliers
    /// Algorithm based on Tanner Helland's approximation
    private func kelvinToRGB(_ kelvin: Int) -> (r: Float, g: Float, b: Float) {
        // Temperature conversion algorithm
    }
}
```

---

### Required Permissions & Entitlements

#### Entitlements File (SuperDimmer.entitlements)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" 
    "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Screen capture for brightness analysis (UNIQUE to SuperDimmer) -->
    <key>com.apple.security.device.screen-capture</key>
    <true/>
    
    <!-- Network for license validation and update checks -->
    <key>com.apple.security.network.client</key>
    <true/>
    
    <!-- AppleEvents for wallpaper/appearance control (like f.lux/Umbra) -->
    <key>com.apple.security.automation.apple-events</key>
    <true/>
    
    <!-- Location for sunrise/sunset (like f.lux) -->
    <key>com.apple.security.personal-information.location</key>
    <true/>
</dict>
</plist>
```

#### User Permission Requests

| Permission | Purpose | When Requested |
|------------|---------|----------------|
| **Screen Recording** | Capture screen for brightness analysis | First launch or when enabling bright region detection |
| **Location** | Calculate sunrise/sunset times | When enabling "Automatic" color temperature schedule |
| **Automation/AppleEvents** | Toggle appearance mode, set wallpapers | When using wallpaper switching features |

**Permission Handling Strategy:**
- Request permissions just-in-time, not at launch
- Provide clear explanations of why each permission is needed
- Gracefully degrade features if permission denied
- Show settings deep-link to manually grant permissions

---

### Info.plist Key Settings

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
    "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Bundle Identity -->
    <key>CFBundleIdentifier</key>
    <string>com.superdimmer.app</string>
    <key>CFBundleName</key>
    <string>SuperDimmer</string>
    <key>CFBundleDisplayName</key>
    <string>SuperDimmer</string>
    
    <!-- Version -->
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    
    <!-- Menu Bar App (no dock icon) - like all reference apps -->
    <key>LSUIElement</key>
    <true/>
    
    <!-- App Category - same as reference apps -->
    <key>LSApplicationCategoryType</key>
    <string>public.app-category.utilities</string>
    
    <!-- Minimum macOS -->
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    
    <!-- Application Type -->
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    
    <!-- Permission Descriptions -->
    <key>NSScreenCaptureUsageDescription</key>
    <string>SuperDimmer needs screen access to detect bright areas and apply intelligent dimming.</string>
    
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>SuperDimmer uses your location to calculate sunrise and sunset times for automatic color temperature adjustments.</string>
    
    <key>NSAppleEventsUsageDescription</key>
    <string>SuperDimmer needs this permission to change wallpapers and toggle between Light and Dark mode.</string>
    
    <!-- Sparkle Auto-Updates (like BetterDisplay, f.lux, Umbra) -->
    <key>SUFeedURL</key>
    <string>https://superdimmer.com/sparkle/appcast.xml</string>
    <key>SUPublicEDKey</key>
    <string>[EdDSA public key goes here]</string>
    <key>SUEnableAutomaticChecks</key>
    <true/>
    
    <!-- Graceful termination -->
    <key>NSSupportsAutomaticTermination</key>
    <true/>
    <key>NSSupportsSuddenTermination</key>
    <true/>
    
    <!-- Copyright -->
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2026 SuperDimmer. All rights reserved.</string>
</dict>
</plist>
```

---

## 💰 Business Model & Licensing

### Model: Freemium with Paddle

**Why Paddle? (based on reference app analysis)**

| Factor | Paddle | Mac App Store |
|--------|--------|---------------|
| Commission | ~5% + $0.50 | 15-30% |
| Screen Recording | ✅ Allowed | ⚠️ May limit |
| Private APIs | ✅ Allowed | ❌ Prohibited |
| Trial Support | ✅ Built-in | ❌ Not supported |
| License Flexibility | ✅ Full control | ❌ Apple's rules |

**BetterDisplay uses Paddle successfully** with a similar freemium model.

### Tier Structure

#### Free Tier (No License Required)

| Feature | Included |
|---------|----------|
| Full-screen uniform dimming | ✅ |
| Basic brightness threshold | ✅ |
| Menu bar controls | ✅ |
| Single display support | ✅ |
| Basic keyboard shortcuts | ✅ |

#### Pro License ($19.99 one-time)

| Feature | Pro Only |
|---------|----------|
| Intelligent region detection | ⭐ |
| Active/inactive differentiation | ⭐ |
| Per-app rules | ⭐ |
| Multi-display support | ⭐ |
| Color temperature control | ⭐ |
| Wallpaper management | ⭐ |
| Scheduled profiles | ⭐ |
| Priority support | ⭐ |

### License Implementation (Paddle SDK)

```swift
import Paddle

/// Handles license validation and feature gating
/// Based on BetterDisplay's Paddle implementation
final class LicenseManager {
    
    enum LicenseState {
        case unlicensedFree        // Free tier only
        case trialActive(daysLeft: Int)
        case proActivated
        case trialExpired
    }
    
    private let paddle: Paddle
    var currentState: LicenseState = .unlicensedFree
    
    /// Check if a Pro feature should be available
    func isProFeatureAvailable() -> Bool {
        switch currentState {
        case .proActivated, .trialActive:
            return true
        case .unlicensedFree, .trialExpired:
            return false
        }
    }
    
    /// Activate license with key from Paddle
    func activateLicense(_ key: String) async throws {
        // Paddle SDK activation
    }
}
```

---

## 🎨 User Interface Design

### Menu Bar Presence

Like all reference apps (BetterDisplay, f.lux, Umbra, MonitorControlLite), SuperDimmer is a **menu bar app** with no dock icon.

#### Menu Bar Icon States

| State | Icon Appearance |
|-------|-----------------|
| Disabled | Outline/empty sun icon |
| Active (dimming) | Filled sun icon with dim effect |
| Color temp active | Sun icon with warm tint |
| Overlay active | Sun icon with half-shaded |

### Menu Bar Dropdown

```
┌────────────────────────────────────────┐
│  SuperDimmer                    Pro ✓  │
├────────────────────────────────────────┤
│  ☀️ Brightness Detection     [Toggle]  │
│     Threshold: ████████░░ 80%          │
│                                        │
│  👁️ Active Window Dim         15%     │
│     Inactive Window Dim       35%      │
│                                        │
├────────────────────────────────────────┤
│  🌡️ Color Temperature        [Toggle]  │
│     Current: 4800K (Sunset)            │
│     ████████████░░░ ←→                 │
│                                        │
├────────────────────────────────────────┤
│  🖼️ Wallpaper Auto-Switch    [Toggle]  │
│                                        │
├────────────────────────────────────────┤
│  ⚙️ Preferences...                     │
│  📊 About SuperDimmer                  │
│  ❌ Quit                               │
└────────────────────────────────────────┘
```

### Preferences Window

**Tabs:**
1. **General** - Enable/disable, launch at login, keyboard shortcuts
2. **Brightness** - Threshold, dim amounts, scan frequency
3. **Color** - Temperature schedules, presets, transition duration
4. **Wallpaper** - Light/dark pairs, per-space settings
5. **Apps** - Per-app rules and exclusions
6. **Displays** - Per-display settings
7. **License** - Pro activation, trial status

---

## 📅 Implementation Phases

### Phase 1: Foundation (MVP) - 4 weeks

**Goal:** Working menu bar app with basic full-screen dimming

| Task | Description | Priority |
|------|-------------|----------|
| Xcode project setup | Swift, SwiftUI + AppKit, proper entitlements | P0 |
| Menu bar app skeleton | NSStatusItem, basic dropdown | P0 |
| Full-screen overlay | DimOverlayWindow implementation | P0 |
| Basic controls | On/off toggle, dim level slider | P0 |
| Permission handling | Screen Recording request flow | P0 |
| Persistence | UserDefaults for settings | P0 |

**Deliverable:** App that can dim entire screen with adjustable opacity

---

### Phase 2: Intelligent Detection - 3 weeks

**Goal:** Detect bright regions and dim them specifically

| Task | Description | Priority |
|------|-------------|----------|
| Screen capture service | CGWindowListCreateImage integration | P0 |
| Brightness analysis | vImage/Accelerate luminance calculation | P0 |
| Window tracking | CGWindowListCopyWindowInfo integration | P0 |
| Per-window overlays | Multiple overlay windows | P0 |
| Active/inactive logic | Frontmost app detection | P0 |
| Performance optimization | Downsampling, caching, throttling | P1 |

**Deliverable:** Working intelligent region-specific dimming

---

### Phase 3: Comfort Features - 2 weeks

**Goal:** Color temperature control and scheduling

| Task | Description | Priority |
|------|-------------|----------|
| Gamma table engine | CGSetDisplayTransferByTable | P0 |
| Temperature UI | Slider with presets | P0 |
| Schedule system | Time-based profiles | P1 |
| Location service | CoreLocation for sunrise/sunset | P1 |
| Smooth transitions | Animated temperature changes | P1 |

**Deliverable:** f.lux-style color temperature control

---

### Phase 4: Wallpaper Features - 2 weeks

**Goal:** Umbra-style wallpaper management

| Task | Description | Priority |
|------|-------------|----------|
| Wallpaper manager | NSWorkspace wallpaper APIs | P0 |
| Light/dark pairs | UI for setting pairs | P0 |
| Auto-switching | Appearance change observer | P0 |
| Wallpaper dimming | Desktop overlay option | P1 |
| Per-space support | Space detection and config | P2 |

**Deliverable:** Automatic wallpaper switching with appearance

---

### Phase 5: Pro Features & Polish - 3 weeks

**Goal:** Premium features and production polish

| Task | Description | Priority |
|------|-------------|----------|
| Paddle integration | License validation, trial, activation | P0 |
| Per-app rules | Rule engine and UI | P0 |
| Multi-display | Per-display settings | P0 |
| Keyboard shortcuts | KeyboardShortcuts framework | P1 |
| Sparkle updates | Auto-update integration | P1 |
| Preferences polish | Beautiful settings window | P1 |
| Onboarding | First-run experience | P1 |

**Deliverable:** Feature-complete Pro version

---

### Phase 6: Launch Preparation - 2 weeks

**Goal:** Marketing-ready release

| Task | Description | Priority |
|------|-------------|----------|
| Website | Landing page with purchase | P0 |
| Documentation | Help docs, FAQ | P0 |
| App notarization | Apple notarization for Gatekeeper | P0 |
| Sparkle appcast | Update feed setup | P0 |
| Beta testing | TestFlight or manual distribution | P1 |
| Marketing materials | Screenshots, video demo | P1 |

**Deliverable:** Publicly launchable product

---

## ⚡ Performance Requirements

| Metric | Target | Measurement |
|--------|--------|-------------|
| CPU usage (idle) | < 0.5% | Activity Monitor |
| CPU usage (active analysis) | < 5% | Activity Monitor |
| Memory footprint | < 50 MB | Activity Monitor |
| Analysis cycle time | < 100ms | Instruments |
| Overlay creation time | < 16ms | Frame timing |
| Time to first dim | < 2 seconds | User-perceived |

### Performance Strategies

1. **Downsample captures** - Analyze at 1/4 or 1/8 resolution
2. **Grid sampling** - Don't analyze every pixel
3. **Change detection** - Skip analysis if screen unchanged
4. **Background processing** - Never block main thread
5. **Lazy overlay creation** - Don't create overlays until needed
6. **Recycle overlay windows** - Reuse instead of create/destroy

---

## 🧪 Testing Requirements

### Unit Tests

- Luminance calculation accuracy
- Region detection algorithms
- Window tracking logic
- Settings persistence
- License state transitions

### Integration Tests

- Screen capture permission flow
- Overlay window behavior
- Multi-display scenarios
- Appearance change response
- Wallpaper switching

### Manual Test Scenarios

| Scenario | Expected Behavior |
|----------|-------------------|
| Open white webpage in dark browser | Bright region detected and dimmed |
| Switch between apps | Active/inactive dim levels swap |
| Add external display | New display detected and handled |
| Enter fullscreen mode | Overlays follow correctly |
| Fast window switching | No flickering or lag |
| System sleep/wake | State preserved, resumes correctly |

---

## 📚 Dependencies & Frameworks

### Apple Frameworks

| Framework | Purpose |
|-----------|---------|
| SwiftUI | Modern UI components |
| AppKit | NSWindow, NSStatusItem, menu bar |
| CoreGraphics | Screen capture, display control |
| Accelerate | vImage for fast image processing |
| CoreLocation | Sunrise/sunset calculation |
| ServiceManagement | Launch at login |

### Third-Party Libraries

| Library | Purpose | License |
|---------|---------|---------|
| **Paddle SDK** | License management | Commercial (free to integrate) |
| **Sparkle** | Auto-updates | MIT |
| **KeyboardShortcuts** | Keyboard shortcut recording | MIT |

### Open Source References

- **MonitorControl** (https://github.com/MonitorControl/MonitorControl) - Overlay and gamma techniques
- **Lunar** (if available) - Advanced display control patterns

---

## 🔐 Security Considerations

1. **Screen Recording Permission** - Only capture when actively analyzing; never record or store
2. **License Validation** - Paddle handles securely; no license keys stored in plain text
3. **Network Communication** - HTTPS only; certificate pinning for license API
4. **Code Signing** - Developer ID for distribution; hardened runtime
5. **Notarization** - Required for Gatekeeper on macOS 10.15+

---

## 📊 Success Metrics

### Launch Targets (First 90 Days)

| Metric | Target |
|--------|--------|
| Downloads | 5,000+ |
| Pro conversions | 5-10% |
| Trial starts | 30% |
| Trial-to-paid | 20% |
| Support tickets | < 2% of users |
| Crash-free rate | 99.5% |

### Long-term Goals (Year 1)

| Metric | Target |
|--------|--------|
| Active users | 25,000+ |
| Pro licenses sold | 2,500+ |
| Revenue | $50,000+ |
| App Store rating | 4.5+ stars |
| User retention (30-day) | 60%+ |

---

## 📝 Appendices

### Appendix A: Competitive Feature Matrix

| Feature | SuperDimmer | Lunar | MonitorControl | f.lux | Umbra |
|---------|------------|-------|----------------|-------|-------|
| Region-specific dimming | ✅ **UNIQUE** | ❌ | ❌ | ❌ | ❌ |
| Full-screen dimming | ✅ | ✅ | ✅ | ✅ | ❌ |
| Active/inactive differentiation | ✅ **UNIQUE** | ❌ | ❌ | ❌ | ❌ |
| Inactivity decay dimming | ✅ **UNIQUE** | ❌ | ❌ | ❌ | ❌ |
| Auto-hide inactive apps | ✅ **UNIQUE** | ❌ | ❌ | ❌ | ❌ |
| Color temperature | ✅ | ✅ | ❌ | ✅ | ❌ |
| Wallpaper switching | ✅ | ❌ | ❌ | ❌ | ✅ |
| DDC/CI hardware control | ❌ | ✅ | ✅ | ❌ | ❌ |
| Per-app rules | ✅ | ✅ | ❌ | ✅ | ❌ |

### Appendix B: Reference App Licensing Comparison

| App | Method | Commission | Notes |
|-----|--------|------------|-------|
| BetterDisplay | Paddle SDK | ~5% | Freemium, trial, perpetual |
| MonitorControlLite | Mac App Store | 15-30% | Paid upfront |
| f.lux | Freeware | 0% | Donations only |
| Umbra | Gumroad (PWYW) | ~5% | Pay what you want |

**Recommendation:** Follow BetterDisplay's Paddle approach for maximum flexibility and revenue.

### Appendix C: Technical Reference Links

- Apple CGWindow: https://developer.apple.com/documentation/coregraphics/quartz_window_services
- Accelerate vImage: https://developer.apple.com/documentation/accelerate/vimage
- NSWindow Levels: https://developer.apple.com/documentation/appkit/nswindow/level
- Paddle SDK: https://developer.paddle.com/
- Sparkle: https://sparkle-project.org/documentation/

---

*Document Version: 1.1*  
*Last Updated: January 12, 2026*  
*Status: Ready for Development*

**Changelog v1.1 (January 12, 2026):**
- Added Dynamic Overlay Tracking feature (real-time position/scale updates)
- Added Hidden App Overlay Cleanup (remove overlays when app is hidden)
- Split intelligent dimming into separate Window and Zone modes
- Added Granular App Exclusions (per-app exclusions for dimming/hide/minimize)
- Added Dark/Light Mode Integration (enable/disable based on appearance)
- Enhanced Wallpaper Dimming feature (desktop-level overlay, quick toggle)
- Added Simplified Menu Bar UI (move sliders to Preferences)
- Added New Menu Bar Icon requirement
- Added Settings Presets & Defaults (Balanced, Aggressive, Subtle, Reset)
