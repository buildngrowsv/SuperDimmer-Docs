# SuperDimmer — Code Signing & Notarization Setup Guide

> Created 2026-03-23 by Builder 2 (BridgeSwarm).
> BridgeMind Task: 955760f0

---

## Why Direct Distribution (Not App Store)

SuperDimmer uses:
- `CGWindowListCreateImage` for screen capture (intelligent dimming)
- Private `CGSSpace` APIs for desktop space tracking (Super Spaces)
- `com.apple.security.device.screen-capture` entitlement

These are **incompatible with App Store sandboxing**. Direct distribution via Developer ID signing + Apple notarization is the correct path. This is the same approach used by BetterDisplay, Bartender, and many other macOS utilities.

---

## Current Status

| Component | Status | Notes |
|-----------|--------|-------|
| Developer ID Application certificate | **In keychain** | `Developer ID Application: Rolf Dergham (HHHHZ6UV26)` |
| Private key for certificate | **MISSING** | Needs .p12 import from original Mac |
| Entitlements file | **Ready** | `SuperDimmer.entitlements` with screen-capture |
| Build pipeline script | **Ready** | `packaging/CodeSigningAndNotarizationPipelineForDirectDistribution.sh` |
| Verification script | **Ready** | `packaging/VerifyCodeSigningEnvironmentSetup.sh` |
| Notarization credentials | **Not configured** | Need APPLE_ID and app-specific password |

---

## Setup Steps (One-Time)

### Step 1: Get the Developer ID Private Key

The certificate exists in the keychain but without its private key, signing is impossible.

**Option A — Import from original Mac (preferred):**

On the Mac where the certificate was originally created:
1. Open **Keychain Access**
2. Go to **My Certificates** (left sidebar)
3. Find **"Developer ID Application: Rolf Dergham (HHHHZ6UV26)"**
4. Right-click → **Export Items** → Save as `.p12`
5. Set a password when prompted
6. Transfer the `.p12` file to this Mac
7. Import:
   ```bash
   security import /path/to/DeveloperID.p12 -k ~/Library/Keychains/login.keychain-db
   ```

**Option B — Revoke and recreate:**

If you can't access the original Mac:
1. Go to [Apple Developer Certificates](https://developer.apple.com/account/resources/certificates)
2. **Revoke** the existing Developer ID Application certificate
3. Click **+** → **Developer ID Application**
4. Create a CSR on THIS Mac (Keychain Access → Certificate Assistant → Request...)
5. Upload the CSR, download the new `.cer`
6. Double-click to install (private key auto-links since CSR was made here)

### Step 2: Set Up Notarization Credentials

Create an app-specific password:
1. Go to [appleid.apple.com](https://appleid.apple.com)
2. Sign in → **Sign-In and Security** → **App-Specific Passwords**
3. Generate a new password, label it "SuperDimmer Notarization"

Set environment variables (add to `~/.zshrc` or `~/.bash_profile`):
```bash
export APPLE_ID="your-apple-id@email.com"
export APPLE_APP_PASSWORD="xxxx-xxxx-xxxx-xxxx"
export APPLE_TEAM_ID="HHHHZ6UV26"
```

### Step 3: Verify Everything

Run the verification script:
```bash
cd SuperDimmer-Website/packaging
./VerifyCodeSigningEnvironmentSetup.sh
```

All checks should show ✓ PASS.

### Step 4 (Optional): Install create-dmg

For polished DMG installers with icon positioning:
```bash
brew install create-dmg
```

---

## Building a Signed Release

Once setup is complete, building a signed + notarized release is one command:

```bash
cd SuperDimmer-Website/packaging

# Full production release (sign + notarize):
./CodeSigningAndNotarizationPipelineForDirectDistribution.sh

# With explicit version:
./CodeSigningAndNotarizationPipelineForDirectDistribution.sh --version 1.0.8

# Testing (sign but skip notarization):
./CodeSigningAndNotarizationPipelineForDirectDistribution.sh --skip-notarize

# Just check environment:
./CodeSigningAndNotarizationPipelineForDirectDistribution.sh --preflight-only
```

The pipeline:
1. Validates the signing environment (preflight)
2. Builds Release configuration with Developer ID signing overrides
3. Verifies code signature and entitlements
4. Creates DMG with Applications folder alias
5. Signs the DMG
6. Submits to Apple for notarization (1-5 min)
7. Staples notarization ticket to DMG
8. Copies to `releases/` folder

After the pipeline completes:
```bash
git add SuperDimmer-Website/releases/SuperDimmer-vX.Y.Z.dmg
git add SuperDimmer-Website/version.json
git commit -m "Release vX.Y.Z"
git push
```
Cloudflare auto-deploys → superdimmer.com serves the new version.

---

## How Code Signing Works (Technical Reference)

### Why xcodebuild Overrides (Not Project Settings)

The Xcode project has signing disabled (`CODE_SIGNING_ALLOWED=NO`, `CODE_SIGN_IDENTITY="-"`) because:
- Development builds don't need signing (slows iteration)
- Different developers may have different certificates
- CI/CD environments may use different signing methods

The pipeline script overrides these at build time:
```
CODE_SIGN_IDENTITY="Developer ID Application: Rolf Dergham (HHHHZ6UV26)"
DEVELOPMENT_TEAM="HHHHZ6UV26"
CODE_SIGNING_REQUIRED=YES
CODE_SIGNING_ALLOWED=YES
CODE_SIGN_STYLE=Manual
ENABLE_HARDENED_RUNTIME=YES
OTHER_CODE_SIGN_FLAGS="--options=runtime"
```

### Signing Order

Apple requires inside-out signing:
1. Sign all embedded frameworks/dylibs first
2. Sign the main app bundle last
3. Sign the DMG container separately

### Hardened Runtime

Required for notarization. Restricts the app from:
- Loading arbitrary dylibs
- Injecting code into other processes
- Accessing certain APIs without entitlements

Our entitlements grant `com.apple.security.device.screen-capture` which allows screen capture while still enforcing the hardened runtime.

### Notarization

Apple scans the signed app for:
- Valid Developer ID signature
- Hardened runtime enabled
- No known malware patterns
- All code paths signed

If approved, Apple issues a ticket. Stapling embeds this ticket in the DMG so Gatekeeper can verify offline.

---

## Troubleshooting

### "errSecInternalComponent" during signing
The private key is in the keychain but locked. Unlock:
```bash
security unlock-keychain ~/Library/Keychains/login.keychain-db
```

### "The signature of the binary is invalid"
Frameworks were signed after the main app. The pipeline handles this correctly (inside-out order).

### "Unable to upload" during notarization
Check internet connection and credentials. Verify app-specific password hasn't expired.

### Gatekeeper still shows warning after notarization
Ensure stapling succeeded. Verify with:
```bash
spctl --assess --type open --context context:primary-signature -v SuperDimmer-vX.Y.Z.dmg
```

---

## File Inventory

| File | Purpose |
|------|---------|
| `SuperDimmer-Website/packaging/CodeSigningAndNotarizationPipelineForDirectDistribution.sh` | Main pipeline — build + sign + notarize + package |
| `SuperDimmer-Website/packaging/VerifyCodeSigningEnvironmentSetup.sh` | Environment check — verify all prereqs |
| `SuperDimmer-Website/packaging/build-release.sh` | Legacy build script (superseded by pipeline) |
| `SuperDimmer-Website/packaging/create-dmg.sh` | DMG creation helper (called by legacy scripts) |
| `SuperDimmer-Website/packaging/release.sh` | Legacy release script (superseded by pipeline) |
| `Certs/developerID_application.cer` | Developer ID cert file (already imported) |
| `Certs/SuperDimmerCertificateSigningRequest.certSigningRequest` | CSR used to generate the cert |
| `SuperDimmer-Mac-App/SuperDimmer/Supporting Files/SuperDimmer.entitlements` | App entitlements (screen-capture) |

---

*Guide created 2026-03-23 by Builder 2. BridgeMind task 955760f0.*
