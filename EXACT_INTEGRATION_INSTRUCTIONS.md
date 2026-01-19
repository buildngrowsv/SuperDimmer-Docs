# Exact Integration Instructions for UpdateChecker

## ✅ File Already Created
`/Users/ak/UserRoot/Github/SuperDimmer/SuperDimmer-Mac-App/SuperDimmer/Services/UpdateChecker.swift`

## 📝 Files to Edit

### 1. SuperDimmerApp.swift

**File:** `/Users/ak/UserRoot/Github/SuperDimmer/SuperDimmer-Mac-App/SuperDimmer/App/SuperDimmerApp.swift`

**Location:** After line 96, add an `init()` method

**Add this code:**

```swift
// ================================================================
// MARK: - Initialization
// ================================================================

/**
 Initialize the app and start automatic update checking.
 
 WHY IN INIT:
 - We want to check for updates as soon as the app launches
 - UpdateChecker respects 24-hour interval so won't spam checks
 - Silent check - only shows alert if update available
 */
init() {
    // Check for updates automatically on launch
    // This is silent unless an update is available
    // Respects 24-hour check interval to avoid excessive requests
    UpdateChecker.shared.checkForUpdatesAutomatically()
}
```

**Result:** UpdateChecker will run automatically on app launch

---

### 2. MenuBarView.swift

**File:** `/Users/ak/UserRoot/Github/SuperDimmer/SuperDimmer-Mac-App/SuperDimmer/MenuBar/MenuBarView.swift`

**Location:** In the `footerSection` variable (around line 916-953)

**Current code (lines 916-953):**

```swift
private var footerSection: some View {
    HStack(spacing: 16) {
        // Preferences button - full area clickable
        Button(action: {
            openPreferences()
        }) {
            HStack(spacing: 6) {
                Image(systemName: "gear")
                Text("Preferences")
            }
            .font(.subheadline)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .foregroundColor(.primary)
        
        Spacer()
        
        // Quit button - full area clickable
        Button(action: {
            quitApp()
        }) {
            HStack(spacing: 6) {
                Image(systemName: "power")
                Text("Quit")
            }
            .font(.subheadline)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .foregroundColor(.secondary)
        .keyboardShortcut("q", modifiers: .command)
    }
    .padding(.horizontal, 16)
}
```

**Replace with:**

```swift
private var footerSection: some View {
    VStack(spacing: 8) {
        // Top row: Preferences and Quit
        HStack(spacing: 16) {
            // Preferences button - full area clickable
            Button(action: {
                openPreferences()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "gear")
                    Text("Preferences")
                }
                .font(.subheadline)
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .foregroundColor(.primary)
            
            Spacer()
            
            // Quit button - full area clickable
            Button(action: {
                quitApp()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "power")
                    Text("Quit")
                }
                .font(.subheadline)
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .foregroundColor(.secondary)
            .keyboardShortcut("q", modifiers: .command)
        }
        
        // Bottom row: Check for Updates
        HStack {
            Button(action: {
                checkForUpdates()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.down.circle")
                    Text("Check for Updates...")
                }
                .font(.caption)
                .padding(.vertical, 3)
                .padding(.horizontal, 6)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .foregroundColor(.secondary)
            
            Spacer()
        }
    }
    .padding(.horizontal, 16)
}
```

**Then add the action method around line 1061 (after `quitApp()`):**

```swift
/**
 Checks for app updates manually.
 Shows result even if up to date (so user gets feedback).
 */
private func checkForUpdates() {
    UpdateChecker.shared.checkForUpdatesManually()
}
```

**Result:** Users can click "Check for Updates..." in the menu bar popover

---

### 3. Add to Xcode Project

1. Open `/Users/ak/UserRoot/Github/SuperDimmer/SuperDimmer-Mac-App/SuperDimmer.xcodeproj` in Xcode
2. Look at Project Navigator (left sidebar)
3. Find the `Services` folder
4. Check if `UpdateChecker.swift` appears there with a blue icon
5. If NOT visible or has grey icon:
   - Right-click on `Services` folder → "Add Files to SuperDimmer..."
   - Navigate to `UpdateChecker.swift`
   - **UNCHECK** "Copy items if needed" (file is already in correct location)
   - **CHECK** SuperDimmer target
   - Click "Add"

---

## 🧪 Testing Checklist

### Build Test
```bash
cd /Users/ak/UserRoot/Github/SuperDimmer/SuperDimmer-Mac-App
xcodebuild -scheme SuperDimmer -configuration Debug clean build 2>&1 | head -n 100
```

Expected: No errors

### Runtime Test 1: Automatic Check on Launch
1. Build and run app
2. Check Xcode console - should see:
   ```
   🔍 UpdateChecker: Running automatic update check...
      Fetching version.json from https://superdimmer.app/version.json
      HTTP 200
      📱 Current version: 1.0.1 (build 7)
      🌐 Remote version:  1.0.0 (build 1)
      ✅ App is up to date
   ```
3. No alert should appear (since app is current)

### Runtime Test 2: Manual Check
1. Click menu bar icon to open popover
2. Look for "Check for Updates..." button at bottom
3. Click it
4. Should show alert: "You're Up to Date"

### Runtime Test 3: Simulate Update Available
```bash
# Temporarily update version.json to trigger update alert
cd /Users/ak/UserRoot/Github/SuperDimmer/SuperDimmer-Website

# Backup original
cp version.json version.json.backup

# Create test version
cat > version.json << 'EOF'
{
  "version": "2.0.0",
  "build": 99,
  "downloadURL": "https://superdimmer.app/releases/SuperDimmer-v1.0.1.dmg",
  "releaseNotesURL": "https://superdimmer.app/release-notes/v1.0.1.html",
  "minSystemVersion": "13.0",
  "releaseDate": "2026-01-19"
}
EOF

# Commit and push
git add version.json
git commit -m "Test: Simulate update available"
git push

# Wait for Cloudflare to deploy (60 seconds)
echo "Waiting 60 seconds for Cloudflare deployment..."
sleep 60

# Now test the app
echo "✅ Ready to test! Run your app and check for updates."
echo "You should see 'Update Available' alert."
echo ""
echo "After testing, restore original version.json:"
echo "  mv version.json.backup version.json"
echo "  git add version.json"
echo "  git commit -m 'Restore version.json after testing'"
echo "  git push"
```

Expected results:
1. Click "Check for Updates..."
2. Alert shows: "SuperDimmer 2.0.0 is now available"
3. Click "Download" → Opens browser to DMG
4. Click "Release Notes" → Opens release notes page
5. Click "Later" → Dismisses alert

### Restore After Testing
```bash
cd /Users/ak/UserRoot/Github/SuperDimmer/SuperDimmer-Website
mv version.json.backup version.json
git add version.json
git commit -m "Restore version.json after testing"
git push
```

---

## ✅ Verification Checklist

- [ ] UpdateChecker.swift compiles without errors
- [ ] App builds successfully
- [ ] App launches without crashes
- [ ] Console shows update check on launch
- [ ] No alert appears when app is current
- [ ] "Check for Updates..." button visible in popover footer
- [ ] Manual check shows "You're Up to Date" alert
- [ ] Test with version 2.0.0 shows "Update Available"
- [ ] "Download" button opens browser
- [ ] DMG downloads correctly
- [ ] "Release Notes" button opens release notes
- [ ] "Later" button dismisses alert
- [ ] Restored version.json after testing

---

## 🐛 Troubleshooting

### Build Error: "Cannot find 'UpdateChecker' in scope"
**Solution:** Add UpdateChecker.swift to Xcode project (see step 3 above)

### Build Error: Syntax error in SuperDimmerApp.swift
**Solution:** Make sure `init()` is placed at the correct indentation level, after line 96

### Runtime: Update check doesn't run
**Solution:** Check console for errors. Verify version.json URL is accessible:
```bash
curl https://superdimmer.app/version.json
```

### Runtime: Alert doesn't show
**Solution:** 
1. Check console logs for HTTP errors
2. Verify JSON parsing (check format matches VersionInfo struct)
3. Test version comparison logic

### Button not visible in popover
**Solution:** Check that footerSection replacement was done correctly. The VStack should contain both rows.

---

## 📊 What This Gives You

✅ **Automatic checks** - App checks for updates every 24 hours on launch  
✅ **Manual checks** - Users can check anytime via menu  
✅ **User-friendly** - Clear alerts with Download/Later options  
✅ **Silent when current** - No annoyance if already up to date  
✅ **Release notes** - Users can read what's new before downloading  
✅ **Secure** - HTTPS + Apple notarization  
✅ **Simple** - No Sparkle complexity, no key management  
✅ **Fast to deploy** - Just update version.json and push to GitHub  

---

## 🚀 Next Steps After Integration

1. **Test thoroughly** - All scenarios above
2. **Update BUILD_CHECKLIST.md** - Mark update checking as complete
3. **Document release process** - How to update version.json when releasing
4. **Ship it!** - Your first release will have working updates
5. **Consider Sparkle later** - If you want auto-install (not just download)

---

*Created: January 19, 2026*  
*Ready to implement*
