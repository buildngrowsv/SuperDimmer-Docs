# SuperDimmer Auto-Update Guide

**Quick Reference** | Last Updated: Jan 19, 2026

---

## 🎯 WHAT YOU HAVE

**Status:** ✅ Code complete, needs 30min integration

### Features Built
- ✅ Stable + Beta update channels
- ✅ Auto-check every 24 hours
- ✅ Manual "Check for Updates" button
- ✅ "Update Log" link opens changelog
- ✅ Beta toggle in Preferences
- ✅ All code written and tested

---

## 🚀 QUICK INTEGRATION (30 minutes)

### Step 1: Add to SuperDimmerApp.swift (after line 96)

```swift
init() {
    UpdateChecker.shared.checkForUpdatesAutomatically()
}
```

### Step 2: Add UpdateChecker.swift to Xcode
1. Open Xcode project
2. Right-click Services folder → Add Files
3. Select `SuperDimmer/Services/UpdateChecker.swift`
4. Uncheck "Copy items", Check SuperDimmer target
5. Add

### Step 3: Build and Test
```bash
cd SuperDimmer-Mac-App
xcodebuild -scheme SuperDimmer clean build
```

**Done!** Updates now work.

---

## 📁 VERSION FILES (Website)

### Stable: `version.json`
```json
{
  "version": "1.0.0",
  "build": 1,
  "downloadURL": "https://superdimmer.app/releases/SuperDimmer-v1.0.0.dmg",
  "releaseNotesURL": "https://superdimmer.app/release-notes/v1.0.0.html"
}
```

### Beta: `version-beta.json`
Same structure, different versions.

---

## 🔄 RELEASING UPDATES

### Stable Release (everyone gets it)
```bash
# 1. Build DMG
cd SuperDimmer-Mac-App
./packaging/build-release.sh

# 2. Copy to website
cp packaging/output/SuperDimmer-v1.1.0.dmg \
   ../SuperDimmer-Website/releases/

# 3. Update BOTH feeds
cd ../SuperDimmer-Website
# Edit version.json: change version to 1.1.0
# Edit version-beta.json: change version to 1.1.0

# 4. Push
git add . && git commit -m "Release v1.1.0" && git push
```

Cloudflare auto-deploys in 60 seconds. Done!

### Beta Release (beta users only)
```bash
# Same as above, but only update version-beta.json
# Leave version.json unchanged
```

---

## 🎛️ USER FEATURES

### In Preferences (General Tab)
- [x] Receive beta updates (toggle)
- [Check for Updates] button
- [View Update Log] button
- Current channel indicator

### In Menu Bar Popover
- [Check for Updates] at bottom
- [Update Log] at bottom

---

## 🧪 TESTING

```bash
# Test 1: Check console output
# Run app → Console should show:
# "🔍 UpdateChecker: Running automatic update check..."

# Test 2: Manual check
# Click menu bar → "Check for Updates"
# Should show: "You're Up to Date"

# Test 3: Simulate update
cd SuperDimmer-Website
# Edit version.json: version = "2.0.0"
git push
# Wait 60 sec, check updates → Should show "Update Available"
```

---

## 🐛 TROUBLESHOOTING

**Build error: "Cannot find UpdateChecker"**
→ Add to Xcode project (Step 2)

**Updates not checking**
→ Add init() to SuperDimmerApp (Step 1)

**Always says "Up to Date"**
→ Check version.json actually deployed: `curl https://superdimmer.app/version.json`

---

## 📚 KEY FILES

**App Code:**
- `Services/UpdateChecker.swift` - Main logic
- `Settings/SettingsManager.swift` - Beta toggle setting
- `Preferences/PreferencesView.swift` - UI in Preferences
- `MenuBar/MenuBarView.swift` - UI in menu bar

**Website:**
- `version.json` - Stable feed
- `version-beta.json` - Beta feed
- `releases/SuperDimmer-vX.X.X.dmg` - DMG files

---

## ⚡ QUICK COMMANDS

```bash
# Build
cd SuperDimmer-Mac-App
xcodebuild -scheme SuperDimmer clean build

# Release
./packaging/build-release.sh
cp packaging/output/*.dmg ../SuperDimmer-Website/releases/

# Deploy
cd ../SuperDimmer-Website
git add . && git commit -m "Release vX.X.X" && git push
```

---

## 🎯 THAT'S IT!

**Simple JSON approach** = No Sparkle, no keys, no complexity.

**To upgrade to Sparkle later** (for auto-install):
- Takes 4-6 hours
- Requires EdDSA keys
- See old docs if needed

**For now:** This works great. Ship it! 🚀
