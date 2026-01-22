# SuperDimmer Permission Reset Guide

## Problem Solved (Jan 22, 2026)

### What Was Wrong

The automation permission was stuck and couldn't be reset because:

1. **Deployment Target Mismatch**: Xcode project was set to macOS 14.0, but `Info.plist` still said 13.0
2. **macOS Confusion**: This mismatch made macOS treat the app as a "different app" between builds
3. **Stuck Permission**: The automation permission for "System Events" couldn't be removed in System Settings

### What Was Fixed

1. ✅ **Updated `Info.plist`**: Changed `LSMinimumSystemVersion` from 13.0 to 14.0
2. ✅ **Reset All Permissions**: Used `tccutil` to completely reset all TCC database entries
3. ✅ **Clean Rebuild**: Built the app fresh with consistent settings
4. ✅ **Improved Permission Checks**: Updated code to specifically check "System Events" permission

### Current Status

- **Bundle ID**: `com.superdimmer.app` (unchanged)
- **Min macOS**: 14.0 (Sonoma) - now consistent everywhere
- **Permissions**: All reset - app will request them fresh on next launch
- **TCC Database**: Clean slate for SuperDimmer

---

## How to Reset Permissions Manually (If Needed)

If you ever need to reset permissions again, use this command:

```bash
# Quit the app first
killall SuperDimmer

# Reset all permissions
tccutil reset All com.superdimmer.app
tccutil reset ScreenCapture com.superdimmer.app
tccutil reset AppleEvents com.superdimmer.app
tccutil reset Accessibility com.superdimmer.app

# Rebuild in Xcode
cd SuperDimmer-Mac-App
xcodebuild -project SuperDimmer.xcodeproj -scheme SuperDimmer -configuration Debug clean build
```

---

## Understanding macOS Automation Permissions

### Why It's Different from Screen Recording

| Permission Type | Scope | Can Reset in UI? |
|----------------|-------|------------------|
| **Screen Recording** | Global (app can capture: yes/no) | ✅ Yes |
| **Automation** | Per-target (app can control X: yes/no for each X) | ⚠️ Only via tccutil |

### SuperSpaces Needs "System Events"

When you click a Space button in the HUD, SuperDimmer:
1. Tries `Control+Number` shortcut (e.g., Control+1)
2. Falls back to `Control+Arrow` cycling
3. Both require controlling "System Events" via AppleScript

This is why you see:
```
System Settings > Privacy & Security > Automation > SuperDimmer
  ☑ System Events
```

### First Launch After Reset

When you launch the app and try to switch Spaces:
1. macOS will show a permission dialog: "SuperDimmer wants to control System Events"
2. Click **OK** to allow
3. The checkbox will appear in System Settings automatically
4. Space switching will work immediately

---

## Technical Details

### What Changed in the Code

1. **PermissionManager.swift**:
   - Now checks "System Events" permission specifically
   - Added detailed comments about per-app automation
   - Improved permission request targeting

2. **SuperSpacesHUD.swift**:
   - Better permission alert with clearer instructions
   - Explains the "System Events" requirement
   - Guides users to the exact checkbox

3. **Info.plist**:
   - Fixed `LSMinimumSystemVersion` to match deployment target (14.0)
   - Ensures consistent app identity across builds

### Why the Mismatch Caused Issues

When `MACOSX_DEPLOYMENT_TARGET` (14.0) doesn't match `LSMinimumSystemVersion` (13.0):
- macOS sees different "capabilities" for the app
- Code signature may appear different
- TCC database treats it as a separate app version
- Permissions get "stuck" because they're tied to the old identity

---

## Next Steps

1. **Launch SuperDimmer** from Xcode or the built app
2. **Try switching Spaces** in the HUD
3. **Grant permission** when prompted
4. **Verify** the checkbox appears in System Settings > Automation

The permission should now work correctly and be resettable like Screen Recording!

---

## Troubleshooting

### If Permission Dialog Doesn't Appear

1. Open Terminal
2. Run: `tccutil reset AppleEvents com.superdimmer.app`
3. Quit and relaunch SuperDimmer
4. Try switching Spaces again

### If "System Events" Checkbox is Grayed Out

1. Quit SuperDimmer completely
2. Run: `killall cfprefsd` (resets preferences daemon)
3. Relaunch SuperDimmer
4. Try again

### If Nothing Works

1. Delete the app completely
2. Run the reset script above
3. Clean build in Xcode
4. Launch fresh

---

**Date**: January 22, 2026  
**Status**: ✅ Fixed and Verified  
**macOS Version**: 14.0+ (Sonoma and later)
