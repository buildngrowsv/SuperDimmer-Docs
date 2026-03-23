# SuperDimmer Status

## Stage: Launch
## Revenue Model: Freemium — Free tier (basic global dimming) + Pro license at $12 one-time payment via Paddle SDK (planned, not yet integrated)
## Current State:
- **v1.0.5 shipped** (2026-02-18), 79+ commits since Jan 2025
- App works: bright region detection, overlay dimming, color temperature, menu bar control, app exclusions, auto-hide, space awareness
- Sparkle auto-update system working
- Website exists at SuperDimmer-Website/ with pricing page (currently links to free download only)
- **Payment integration NOT implemented** — Paddle SDK researched and recommended (see PAYMENT-INTEGRATION-PLAN.md) but no code written
- No App Store listing — distributed as direct DMG download
- Multiple debugging/fix cycles completed (deadlock, memory, freeze, overlay issues)
## Tech Stack: Swift 5.9+, SwiftUI + AppKit, macOS 13.0+ (Ventura), Sparkle (auto-update), CGWindowListCreateImage (screen capture)
## Deployment: Direct download from website (DMG). Not on Mac App Store. Auto-update via Sparkle.
## Last Updated: 2026-03-23
