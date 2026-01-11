# SuperDimmer: Crash Reporting & Distribution Strategy

## Executive Summary

### App Store Eligibility: NO ❌

SuperDimmer **cannot be distributed via the Mac App Store** due to its use of the `com.apple.security.device.screen-capture` entitlement.

**Why:**
- Screen capture entitlement requires running **outside the App Store sandbox**
- Apple's sandbox restrictions prevent apps from capturing screen content
- This is the same reason f.lux, BetterDisplay, MonitorControl, Umbra, and similar apps are NOT on the Mac App Store

### TestFlight for macOS: LIMITED VALUE

While TestFlight **does support macOS apps** (since macOS 12), it has limitations for SuperDimmer:
- TestFlight builds are sandboxed (same as App Store)
- Screen capture won't work correctly in TestFlight builds
- TestFlight crash reports require the sandbox restrictions that break our app

**Recommendation:** TestFlight is NOT suitable for SuperDimmer's core functionality testing.

### Recommended Distribution Strategy

1. **Direct Distribution** via DMG on superdimmer.com (current approach ✅)
2. **Sparkle Framework** for auto-updates (already integrated ✅)
3. **Sentry SDK** for automatic crash reporting (added January 11, 2026)
4. **Developer ID Notarization** for Gatekeeper approval (configured ✅)

---

## Crash Reporting Strategy

Since we can't use TestFlight/App Store crash reports, we need our own solution.

### Primary Solution: Sentry SDK

**Why Sentry:**
- Industry-standard crash reporting for macOS/iOS apps
- Used by major apps: Slack, Discord, Figma, 1Password, etc.
- Automatic symbolication (no manual dSYM upload needed)
- Real-time crash alerts and analytics
- Free tier available (5K events/month)
- Open-source and privacy-respecting

### Setup Instructions

#### 1. Add Sentry via Swift Package Manager

```
In Xcode:
1. File → Add Package Dependencies
2. Enter: https://github.com/getsentry/sentry-cocoa
3. Select version 8.x or later (e.g., 8.30.0)
4. Add to SuperDimmer target
```

#### 2. Create Sentry Project

1. Go to https://sentry.io and create account
2. Create new project → Select "Apple" platform
3. Copy your DSN from project settings

#### 3. Configure DSN

Option A: Environment variable (recommended for security):
```bash
# In ~/.zshrc
export SENTRY_DSN="https://your-key@your-org.ingest.sentry.io/project-id"
```

Option B: Directly in code (simpler):
Edit `CrashReportingManager.swift` and replace:
```swift
return "YOUR_SENTRY_DSN_HERE"
```
with your actual DSN.

#### 4. Uncomment Implementation

In `CrashReportingManager.swift`, uncomment the following sections:
- `import Sentry` at the top
- All `/* // SENTRY IMPLEMENTATION */` blocks

#### 5. Upload Debug Symbols

For symbolicated crash reports, configure dSYM upload:

```bash
# Install sentry-cli
brew install getsentry/tools/sentry-cli

# Configure
sentry-cli login
sentry-cli projects list

# In your build script or Xcode build phase:
sentry-cli upload-dif --org YOUR_ORG --project YOUR_PROJECT path/to/dSYMs
```

Or use Sentry's automatic upload via build phase script.

### Privacy Considerations

1. **User Opt-Out**: Users can disable crash reporting in Preferences
2. **No PII**: Crash reports contain NO personal information, screen content, or file data
3. **Privacy Policy**: Update superdimmer.com/privacy.html to mention crash reporting

Add to privacy policy:
> **Crash Reports:** SuperDimmer collects anonymous crash reports to help us fix bugs. 
> These reports include technical information about your device and the app's state at 
> the time of the crash. No personal information, screen content, or files are included.
> You can opt-out of crash reporting in Preferences → Privacy.

---

## Alternative Crash Reporting Options

### Apple's Built-in Crash Reporting (Limited)

For apps distributed outside the App Store, macOS still generates crash reports in:
```
~/Library/Logs/DiagnosticReports/
```

**Limitations:**
- Requires users to manually send you the .crash files
- Not automatic
- Not symbolicated (need dSYMs to read)
- Users rarely know to do this

**How to request from users:**
1. Ask them to open Console.app
2. Go to Crash Reports
3. Find SuperDimmer crashes
4. Right-click → Share

### PLCrashReporter (Self-Hosted)

Open-source crash reporter you can self-host:
- https://github.com/microsoft/plcrashreporter
- More control over data
- More setup work
- Need your own server

**Not recommended** unless you have specific compliance requirements.

---

## Current SuperDimmer Crash Issues

Based on `TROUBLESHOOTING_LOG.md`, recent crash patterns include:

### 1. EXC_BAD_ACCESS in objc_release (FIXED)
- **Cause**: Rapid create/destroy of NSWindow overlay objects
- **Solution**: Hide/show overlays instead of destroying them
- **Status**: Fixed in v1.0.1

### 2. Toggle Crashes (FIXED)
- **Cause**: Race conditions with async overlay operations
- **Solution**: Removed async dispatches, use synchronous show/hide
- **Status**: Fixed in v1.0.1

### 3. Decay Overlay Crashes (FIXED)
- **Cause**: DispatchQueue.main.sync deadlock + rapid creation
- **Solution**: Use async dispatch, hide instead of destroy
- **Status**: Fixed in v1.0.1

### If Users Report New Crashes

With Sentry integrated, crashes will automatically appear in the Sentry dashboard.
Until then, ask users to provide:

1. **Steps to reproduce** (what were they doing?)
2. **macOS version** (System Settings → General → About)
3. **SuperDimmer version** (Menu bar icon → right-click → About)
4. **Crash log** from Console.app → Crash Reports → SuperDimmer

---

## Distribution Checklist

### For Each Release:

1. [ ] Build Release configuration
2. [ ] Code sign with Developer ID Application certificate
3. [ ] Notarize with Apple
4. [ ] Create DMG using `packaging/release.sh X.Y.Z`
5. [ ] Verify DMG opens without Gatekeeper warning on clean Mac
6. [ ] Upload dSYMs to Sentry
7. [ ] Update appcast.xml for Sparkle
8. [ ] Push to GitHub (Cloudflare Pages auto-deploys)

### One-Time Setup:

- [x] Developer ID certificate
- [x] Sparkle for auto-updates  
- [x] Cloudflare Pages hosting
- [ ] **Sentry project** ← TO DO
- [ ] **Configure SENTRY_DSN** ← TO DO
- [ ] **Uncomment Sentry code** ← TO DO (after adding SPM package)

---

## Files Modified/Created

| File | Purpose |
|------|---------|
| `SuperDimmer/Services/CrashReportingManager.swift` | New crash reporting service |
| `SuperDimmer/App/AppDelegate.swift` | Initialize crash reporting on launch |
| `docs/CRASH_REPORTING_AND_DISTRIBUTION.md` | This documentation |

---

*Created: January 11, 2026*
*SuperDimmer v1.0.1+*
