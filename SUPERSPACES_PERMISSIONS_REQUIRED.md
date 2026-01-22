# SuperSpaces: Required Permissions

## ⚠️ BOTH Permissions Are Required

SuperSpaces needs **TWO** permissions to switch between Spaces:

### 1. ✅ Accessibility Permission
**Status**: ❌ **NOT GRANTED** (this is your current issue)

**Why it's needed**:
- Allows SuperDimmer to send synthetic keyboard events
- Required for AppleScript to simulate Control+Arrow and Control+Number keypresses

**Error without it**:
```
NSAppleScriptErrorNumber = 1002
"SuperDimmer is not allowed to send keystrokes."
```

**How to grant**:
1. Open **System Settings** → **Privacy & Security** → **Accessibility**
2. Click the **lock** icon and authenticate
3. Find **SuperDimmer** in the list
4. Check the **box** next to SuperDimmer
5. Close Settings

---

### 2. ✅ Automation Permission (System Events)
**Status**: ✅ **GRANTED** (you already have this)

**Why it's needed**:
- Allows SuperDimmer to control the "System Events" app
- Required for AppleScript to tell System Events to press keys

**Error without it**:
```
NSAppleScriptErrorNumber = -1743
"Not authorized to send Apple events to System Events."
```

**How to verify**:
1. Open **System Settings** → **Privacy & Security** → **Automation**
2. Find **SuperDimmer** in the left list
3. Verify **System Events** is checked ✓

---

## Why Both Are Needed

Think of it like a chain:

```
SuperDimmer → AppleScript → System Events → Keyboard Event
     |              |              |              |
     └─────────────────────────────┴──────────────┘
           Automation                Accessibility
```

1. **Automation**: SuperDimmer tells System Events what to do
2. **Accessibility**: System Events actually sends the keystrokes

Without Automation: Can't talk to System Events  
Without Accessibility: Can't send keystrokes  
**Need both**: Space switching works! 🎉

---

## Current Status (Your System)

Based on your logs:

| Permission | Status | Action Needed |
|-----------|--------|---------------|
| Screen Recording | ✅ Granted | None |
| **Accessibility** | ❌ **Missing** | **Grant this now** |
| Automation (System Events) | ✅ Granted | None |
| Location | ❌ Not granted | Optional (for sunrise/sunset) |

---

## How to Fix Your Issue

**You need to grant Accessibility permission:**

1. **Quit SuperDimmer** (if running)
2. Open **System Settings**
3. Go to **Privacy & Security** → **Accessibility**
4. Click the **lock** icon (bottom left) and enter your password
5. Look for **SuperDimmer** in the list
6. **Check the box** next to SuperDimmer
7. Close Settings
8. **Relaunch SuperDimmer**
9. Try switching Spaces again

---

## Why This Wasn't Clear Before

The error message says "Automation Permission Required" but the actual issue is **Accessibility permission**. This is because:

1. AppleScript execution requires Automation ✓ (you have this)
2. Sending keystrokes requires Accessibility ✗ (you need this)

The error happens during keystroke sending, not during AppleScript execution, so it looks like an automation issue but it's actually accessibility.

---

## Updated Code (Jan 22, 2026)

The app now:
- ✅ Checks for Accessibility permission before trying to switch Spaces
- ✅ Shows the correct permission alert based on the error type
- ✅ Distinguishes between Accessibility (1002) and Automation (-1743) errors
- ✅ Opens the correct System Settings pane for each permission type

---

## Testing After Granting Permission

1. Launch SuperDimmer
2. Open the SuperSpaces HUD
3. Click a Space button
4. You should see the Space switch immediately
5. No error messages in the console

Expected log output:
```
→ SuperSpacesHUD: Switching to Space 4...
✓ SuperSpacesHUD: Space switch via Control+4 shortcut (instant)
```

Or if Control+Number shortcuts aren't enabled:
```
→ SuperSpacesHUD: Switching to Space 4...
⚠️ SuperSpacesHUD: Direct shortcut not enabled, falling back to cycling
✓ SuperSpacesHUD: Space switch initiated via AppleScript (slow)
```

---

**Date**: January 22, 2026  
**Issue**: Missing Accessibility Permission  
**Solution**: Grant Accessibility permission in System Settings  
**Status**: Ready to test after granting permission
