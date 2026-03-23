# SuperDimmer Payment Integration Plan

> Created 2026-03-23 by Builder 8 (BridgeSwarm T11).
> Based on AUDIT-2026-03-23.md findings and existing research in REFERENCE_APPS_DEEP_ANALYSIS.md.

---

## 1. Payment Provider Comparison

| Criteria | Paddle SDK | LemonSqueezy | Stripe + Custom | Mac App Store |
|----------|-----------|--------------|-----------------|---------------|
| **Commission** | ~5% + $0.50 | 5% + $0.50 | 2.9% + $0.30 | 15-30% |
| **Tax handling** | Full MoR (they handle all global VAT/sales tax) | Full MoR | You handle tax or add TaxJar | Apple handles |
| **macOS SDK** | Yes (v4.x, proven by BetterDisplay) | Yes (newer, less battle-tested) | No native SDK — web checkout only | StoreKit built-in |
| **License key system** | Built-in (generation, activation, deactivation, hardware binding) | Built-in | Must build yourself | Receipt validation |
| **Trial management** | Built-in (days-based, feature-gated) | Built-in | Must build yourself | No trials for paid apps |
| **Sandboxing required** | No | No | No | Yes — may break screen capture |
| **Setup time** | 1-2 days | 1-2 days | 3-5 days | 2-3 days + App Review |
| **Used by competitors** | BetterDisplay (direct competitor) | Emerging | Rare for macOS apps | MonitorControlLite |
| **Monthly fee** | None | None | None | $99/yr Apple Dev |

### Recommendation: **Paddle SDK**

Rationale:
1. Already researched extensively in REFERENCE_APPS_DEEP_ANALYSIS.md
2. Proven in the exact same product category (BetterDisplay uses Paddle)
3. Full MoR eliminates tax compliance burden globally
4. Native macOS SDK with license key management built-in
5. No sandboxing requirement — critical because SuperDimmer uses CGWindowListCreateImage which has sandbox restrictions
6. $12 × 0.05 = $0.60 fee per sale → $11.40 net revenue per license

---

## 2. Pricing Strategy

### Current Plan (from pricing.html)

| Tier | Price | Features |
|------|-------|----------|
| **Free** | $0 | Basic global dimming, menu bar control, manual dim level slider |
| **Pro** | $12 one-time | Intelligent per-window dimming, per-region dimming, active/inactive window differentiation, Super Spaces, app exclusions, color temperature, auto-hide |

### Recommended Adjustments

- **Keep $12 price point** — it's low enough for impulse purchase, competitive with BetterDisplay ($18)
- **Add 7-day Pro trial** — Paddle supports this natively. Let users experience Pro features, then gate them after trial expires
- **Consider $15-18 in 3 months** after establishing reviews and user base

### Feature Gating Matrix

| Feature | Free | Trial | Pro |
|---------|------|-------|-----|
| Global dim level slider | ✅ | ✅ | ✅ |
| Menu bar icon + basic controls | ✅ | ✅ | ✅ |
| Launch at login | ✅ | ✅ | ✅ |
| Intelligent per-window dimming | ❌ | ✅ | ✅ |
| Per-region bright spot detection | ❌ | ✅ | ✅ |
| Active/inactive window differentiation | ❌ | ✅ | ✅ |
| Super Spaces (per-desktop configs) | ❌ | ✅ | ✅ |
| App exclusions | ❌ | ✅ | ✅ |
| Color temperature adjustment | ❌ | ✅ | ✅ |
| Auto-hide dimming | ❌ | ✅ | ✅ |

This aligns with existing code comments — `differentiateActiveInactive` and `intelligentDimmingEnabled` are already marked as "Pro feature - gated by license" in SettingsManager.swift.

---

## 3. Implementation Steps

### Phase 1: Paddle Account Setup (Day 1, ~2 hours)

1. Create Paddle account at paddle.com
2. Set up product:
   - Product name: "SuperDimmer Pro"
   - Price: $12 one-time
   - Trial: 7 days
3. Get credentials:
   - Vendor ID
   - Product ID
   - API key
   - SDK token
4. Download Paddle.framework for macOS

### Phase 2: LicenseManager Implementation (Day 1-2, ~6 hours)

**File to create:** `SuperDimmer-Mac-App/SuperDimmer/Services/LicenseManager.swift`

The PRD (PRODUCT_REQUIREMENTS_DOCUMENT.md:921) and FILE_STRUCTURE_AND_COMPONENTS.md:968 already have a skeleton design:

```swift
// LicenseManager.swift
// The design already exists in FILE_STRUCTURE docs — key states:
// - .free (no license, no trial)
// - .trial(daysRemaining: Int)
// - .pro (valid license activated)
// - .expired (trial ended, no license)
```

Implementation tasks:
1. Add Paddle.framework to Xcode project (drag into Frameworks group)
2. Create `LicenseManager.swift` with:
   - Paddle SDK initialization with vendor/product IDs
   - License state enum: `.free`, `.trial(daysRemaining)`, `.pro`, `.expired`
   - `activateLicense(key: String)` method
   - `deactivateLicense()` method
   - `checkLicenseState()` on app launch
   - `@Published var licenseState` for SwiftUI binding
3. Store license state in UserDefaults with Paddle validation on each launch

### Phase 3: FeatureGate Implementation (Day 2, ~3 hours)

**File to create:** `SuperDimmer-Mac-App/SuperDimmer/Services/FeatureGateService.swift`

Already designed in FILE_STRUCTURE_AND_COMPONENTS.md:1020:

```swift
// FeatureGateService checks license state before allowing Pro features
// Called throughout app wherever Pro features are used
// Dependencies: LicenseManager
```

Implementation:
1. Create `FeatureGateService` that wraps `LicenseManager`
2. Add `isProFeatureAvailable` computed property
3. Add gate checks in:
   - `SettingsManager.swift` — `differentiateActiveInactive` setter (line 825)
   - `SettingsManager.swift` — `intelligentDimmingEnabled` setter (line 842)
   - `PreferencesView.swift` — disable Pro UI elements when free
   - `MenuBarView.swift` — show "Upgrade to Pro" badge
4. When user toggles a gated feature while on free tier, show upgrade prompt

### Phase 4: License UI (Day 2-3, ~4 hours)

**Files to modify:**
- `PreferencesView.swift` — Add "License" tab with:
  - Current license status display
  - License key text field + "Activate" button
  - "Buy License" button → opens Paddle checkout
  - "Deactivate" button for transferring license
- `MenuBarView.swift` — Add subtle "Pro" badge or "Upgrade" item in menu
- `AppDelegate.swift` — Initialize Paddle SDK on app launch

**New file:** `SuperDimmer-Mac-App/SuperDimmer/Preferences/LicenseView.swift`
- SwiftUI view for license management
- Shows trial countdown when in trial mode
- Shows "All Pro features unlocked" when licensed

### Phase 5: Website Update (Day 3, ~1 hour)

**File to modify:** `SuperDimmer-Website/pricing.html`
- Change "Get Pro License" href from `/#download` to Paddle checkout URL
- Add "Enter License Key" link for existing customers

**File to modify:** `SuperDimmer-Website/index.html`
- Update download CTA to clarify "Download Free" vs "Buy Pro ($12)"

### Phase 6: Testing (Day 3, ~2 hours)

1. Test with Paddle sandbox environment
2. Verify feature gating:
   - Free tier: only global dimming works
   - Trial: all features, countdown visible
   - Pro: all features, no countdown
   - Expired trial: reverts to free tier
3. Test license activation/deactivation flow
4. Test edge cases: offline activation, license transfer, app reinstall

---

## 4. Required Code Changes Summary

| File | Change | Type |
|------|--------|------|
| `Services/LicenseManager.swift` | **CREATE** — Paddle SDK wrapper, license state management | New file |
| `Services/FeatureGateService.swift` | **CREATE** — Feature gating logic | New file |
| `Preferences/LicenseView.swift` | **CREATE** — License management UI | New file |
| `Settings/SettingsManager.swift` | **MODIFY** — Add feature gate checks to Pro properties | Edit |
| `Preferences/PreferencesView.swift` | **MODIFY** — Add License tab, disable Pro controls when free | Edit |
| `MenuBar/MenuBarView.swift` | **MODIFY** — Add upgrade prompt / Pro badge | Edit |
| `App/AppDelegate.swift` | **MODIFY** — Initialize Paddle SDK on launch | Edit |
| `App/SuperDimmerApp.swift` | **MODIFY** — Inject LicenseManager into environment | Edit |
| Xcode project | **MODIFY** — Add Paddle.framework dependency | Edit |
| `SuperDimmer-Website/pricing.html` | **MODIFY** — Update "Get Pro License" href | Edit |
| `SuperDimmer-Website/index.html` | **MODIFY** — Clarify free vs pro download CTAs | Edit |

---

## 5. Effort Estimate

| Phase | Task | Hours |
|-------|------|-------|
| 1 | Paddle account setup | 2 |
| 2 | LicenseManager.swift | 6 |
| 3 | FeatureGateService.swift | 3 |
| 4 | License UI views | 4 |
| 5 | Website updates | 1 |
| 6 | Testing | 2 |
| **Total** | | **18 hours (~2-3 focused days)** |

### Dependencies / Blockers

- **Paddle account creation**: Requires bank account / payment info for payouts
- **Developer ID certificate**: Already present in `Certs/` — good
- **Notarization**: Verify DMG is notarized with `spctl --assess` before shipping with Paddle SDK bundled

---

## 6. Revenue Projection

At $12 per license, $11.40 net after Paddle fees:

| Monthly sales | Monthly revenue | Annual revenue |
|---------------|----------------|----------------|
| 10 licenses | $114 | $1,368 |
| 25 licenses | $285 | $3,420 |
| 50 licenses | $570 | $6,840 |
| 100 licenses | $1,140 | $13,680 |

BetterDisplay (comparable product, $18 price point) has 500K+ downloads. Even capturing 1% of that market at $12 would be significant. The 7-day trial is critical for conversion — users who experience per-region dimming will feel the loss when it reverts to global-only.

---

## 7. Next Steps

1. **Immediate**: Create Paddle developer account
2. **This week**: Implement LicenseManager + FeatureGate (Phases 2-3)
3. **This week**: Add License UI and update website (Phases 4-5)
4. **Before release**: Test full flow with Paddle sandbox (Phase 6)
5. **Post-launch**: Monitor conversion rate, consider price adjustment after 30 days

---

*Plan created 2026-03-23 by Builder 8. References: REFERENCE_APPS_DEEP_ANALYSIS.md, PRODUCT_REQUIREMENTS_DOCUMENT.md, FILE_STRUCTURE_AND_COMPONENTS.md, AUDIT-2026-03-23.md.*
