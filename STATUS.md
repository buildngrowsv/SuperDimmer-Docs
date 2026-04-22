# SuperDimmer Status

## Stage: Launch — v1.0.8 shipping today
## Revenue Model: Freemium — Free tier (basic global dimming) + Pro license at $12 one-time payment via Paddle SDK (infrastructure landed in v1.0.7, first Pro-gated feature shipping in v1.0.8)
## Current State:
- **v1.0.8 built 2026-04-22** (build 16) — **New Pro feature: Spread Windows Evenly**
  - One-click menu-bar action that distributes every visible window around concentric rectangular orbits with equal spacing
  - Idempotent (re-running after a spread is a no-op)
  - Center always holds a window; all four corners of the spread bounds are filled
  - Optional "Anchor Edges" mode preserves windows at screen edges
  - No new permissions required (Accessibility already granted for dimming)
  - Recording-safe exclusions (OBS, Loom, Zoom, FaceTime, Teams, Meet, QuickTime)
- v1.0.7 shipped 2026-03-02 — Zone Level dimming regression fix
- **v1.0.8 build is UNSIGNED** (no Developer ID certificate in keychain, no notarization credentials set). Before public release, re-run `packaging/release.sh 1.0.8` with `APPLE_ID`, `APPLE_APP_PASSWORD`, `APPLE_TEAM_ID` environment variables set — will produce a signed+notarized DMG and replace the current unsigned DMG.
- Website updated: release notes v1.0.8, changelog entry, Sparkle appcast, `version.json`, download links on `index.html` + `pricing.html`.
- App works: bright region detection, overlay dimming, color temperature, menu bar control, app exclusions, auto-hide, space awareness, **window spread (new)**
- Sparkle auto-update system working (appcast updated; Sparkle EdDSA signature still placeholder — `REPLACE_WITH_ACTUAL_SIGNATURE_FROM_SIGN_UPDATE_TOOL==` — must be regenerated via `sign_update` before users see the v1.0.8 update through Sparkle)
- **Paddle licensing live** (v1.0.7) — `Spread Windows Evenly` is the first Pro-gated feature to use `FeatureGateService.shared.checkAccess`
- No App Store listing — distributed as direct DMG download
## Tech Stack: Swift 5.9+, SwiftUI + AppKit, macOS 14.0+, Sparkle (auto-update), CGWindowListCreateImage (screen capture), AXUIElement + `_AXUIElementGetWindow` (window moves)
## Deployment: Direct download from website (DMG). Not on Mac App Store. Auto-update via Sparkle.
## Last Updated: 2026-04-22
