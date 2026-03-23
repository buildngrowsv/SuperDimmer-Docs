# PRODUCT-BRIEF: SuperDimmer

> **One-liner:** A macOS utility that intelligently dims bright regions of your screen — protecting your eyes while keeping the content you're focused on visible.

---

## Product Identity

| Field | Value |
|-------|-------|
| **App Name** | SuperDimmer |
| **Platform** | macOS 13.0+ (Ventura and later) |
| **Current Version** | v1.0.5 (shipped 2026-02-18) |
| **Repo** | `Github/SuperDimmer/` |
| **Distribution** | Direct DMG download (not Mac App Store) |
| **Website** | SuperDimmer-Website/ (in repo) |

---

## What It Does

SuperDimmer sits in your menu bar and automatically detects and dims bright areas of your screen. Unlike basic screen dimmers that just lower overall brightness, SuperDimmer uses intelligent region detection to dim only the parts that are too bright — so you can still see your IDE, terminal, or dark-themed apps clearly while white backgrounds and bright UI elements get toned down.

**Core user flow:**
1. Install from DMG, app appears in menu bar
2. Click menu bar icon to adjust dimming level
3. App automatically detects bright regions using screen capture
4. Overlays dim the bright areas while leaving dark content alone
5. Exclude specific apps from dimming
6. Color temperature adjustment for night use
7. Auto-hides when not needed, Space-aware for multiple desktops

**Why it matters:** Developers, writers, and knowledge workers spend 8-12+ hours daily staring at screens. Bright white backgrounds cause eye strain, headaches, and disrupt circadian rhythms. Dark mode doesn't work everywhere — SuperDimmer fills the gap by dimming what dark mode can't.

---

## Revenue Model

| Tier | Price | Details |
|------|-------|---------|
| **Free** | $0 | Basic global dimming |
| **Pro** | $12 (one-time) | Bright region detection, color temperature, app exclusions, Space awareness, auto-hide |

**Payment:** Paddle SDK (planned, not yet integrated). Direct sales outside App Store — no Apple 30% cut.

**Revenue potential:** Screen dimmer utilities have a dedicated niche audience (developers, night owls, people with photosensitivity). At $12 one-time with 1,000 purchases in year 1 = $12,000. Potential for subscription model ($3-5/mo) for recurring revenue.

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| **Frontend** | SwiftUI + AppKit (hybrid for macOS) |
| **Language** | Swift 5.9+ |
| **Screen Capture** | CGWindowListCreateImage (Core Graphics) |
| **Overlays** | NSWindow-based transparent overlays |
| **Auto-Update** | Sparkle framework |
| **Target** | macOS 13.0+ (Ventura) |

---

## Current State: Shipped, Needs Payment Integration

**What works (v1.0.5):**
- Bright region detection and overlay dimming
- Color temperature adjustment
- Menu bar control UI
- App exclusion list
- Auto-hide when not needed
- Space awareness (multiple desktops)
- Sparkle auto-update system
- Direct DMG distribution
- Website with pricing page

**What's blocking revenue:**
1. **Paddle SDK not integrated** — payment plan exists (PAYMENT-INTEGRATION-PLAN.md) but no code
2. **Pro features not gated** — all features currently available for free
3. **No license validation** — LicenseManager.swift exists but is in stub mode
4. **No Paddle account** — needs setup with bank account, tax info

**History of technical challenges (resolved):**
- Deadlock issues with screen capture → fixed
- Memory pressure from overlay rendering → optimized
- Overlay freeze on Space switch → fixed
- Multiple debugging cycles to stabilize the core dimming engine

---

## Competitive Landscape

| Competitor | Price | Differentiator |
|-----------|-------|----------------|
| f.lux | Free | Color temperature only, no region dimming |
| macOS Night Shift | Free (built-in) | Color temperature only, basic |
| HazeOver | $4.99 | Dims background windows, not bright regions |
| Shady | Free | Global screen dimming, no intelligence |
| **SuperDimmer** | **$12** | **Intelligent bright region detection, per-area dimming, color temp, app exclusions** |

**Our edge:** Only app that intelligently detects and dims bright regions specifically. Others are either global dimmers or color temperature shifters — SuperDimmer does targeted dimming.

---

## Next Steps to Revenue

1. **Set up Paddle account** — bank info, tax details, product listing (human, ~1 hour)
2. **Integrate Paddle SDK** — wire LicenseManager.swift to real Paddle API (agent, ~4-8 hours)
3. **Gate Pro features** — FeatureGateService.swift exists, needs real license checks (agent, ~2 hours)
4. **Update website** — purchase button should go to Paddle checkout (agent, ~1 hour)
5. **Marketing:** Product Hunt launch, developer community posts, SEO for "mac screen dimmer"

---

*Last updated: 2026-03-23 by Builder 5 (BridgeSwarm T3-B)*
