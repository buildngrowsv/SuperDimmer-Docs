# Integration Steps for UpdateChecker

## Files Created
✅ `/Users/ak/UserRoot/Github/SuperDimmer/SuperDimmer-Mac-App/SuperDimmer/Services/UpdateChecker.swift`

## Files That Need Editing

### 1. SuperDimmerApp.swift
**File:** `/Users/ak/UserRoot/Github/SuperDimmer/SuperDimmer-Mac-App/SuperDimmer/App/SuperDimmerApp.swift`

**Add this in the `init()` method:**

```swift
init() {
    // ... your existing initialization code ...
    
    // Check for updates on app launch (automatic check)
    // This respects the 24-hour check interval
    UpdateChecker.shared.checkForUpdatesAutomatically()
}
```

### 2. MenuBarController.swift
**File:** `/Users/ak/UserRoot/Github/SuperDimmer/SuperDimmer-Mac-App/SuperDimmer/MenuBar/MenuBarController.swift`

**Add menu item for manual update checks:**

Find where you create the menu items and add:

```swift
// Add separator before update check (optional but cleaner UI)
menu.addItem(NSMenuItem.separator())

// Add "Check for Updates..." menu item
let updateItem = NSMenuItem(
    title: "Check for Updates...",
    action: #selector(checkForUpdates),
    keyEquivalent: ""
)
updateItem.target = self
menu.addItem(updateItem)

// Add separator after (optional)
menu.addItem(NSMenuItem.separator())
```

**Add the action method:**

```swift
@objc private func checkForUpdates() {
    UpdateChecker.shared.checkForUpdatesManually()
}
```

### 3. Add to Xcode Project (If Not Already Added)

1. Open `SuperDimmer.xcodeproj` in Xcode
2. In Project Navigator, find `Services` folder
3. If `UpdateChecker.swift` is not shown with a blue icon, you need to add it:
   - Right-click on `Services` folder
   - "Add Files to SuperDimmer..."
   - Navigate to `UpdateChecker.swift`
   - Make sure "Copy items if needed" is UNCHECKED (it's already in the right place)
   - Make sure SuperDimmer target is checked
   - Click "Add"

---

## Testing Steps

### Test 1: Build and Run

```bash
cd /Users/ak/UserRoot/Github/SuperDimmer/SuperDimmer-Mac-App
xcodebuild -scheme SuperDimmer -configuration Debug clean build
```

Should compile without errors.

### Test 2: Check Console Output

Run the app and watch Xcode console. You should see:

```
🔍 UpdateChecker: Running automatic update check...
   Fetching version.json from https://superdimmer.com/version.json
   HTTP 200
   📱 Current version: 1.0.1 (build 7)
   🌐 Remote version:  1.0.0 (build 1)
   ✅ App is up to date
```

### Test 3: Manual Check

1. Run the app
2. Click menu bar icon
3. Click "Check for Updates..."
4. Should show alert: "You're Up to Date"

### Test 4: Simulate Update Available

Temporarily edit version.json to show newer version:

```bash
cd /Users/ak/UserRoot/Github/SuperDimmer/SuperDimmer-Website

# Backup original
cp version.json version.json.backup

# Create test version
cat > version.json << 'EOF'
{
  "version": "2.0.0",
  "build": 99,
  "downloadURL": "https://superdimmer.com/releases/SuperDimmer-v1.0.1.dmg",
  "releaseNotesURL": "https://superdimmer.com/release-notes/v1.0.1.html",
  "minSystemVersion": "13.0",
  "releaseDate": "2026-01-19"
}
EOF

# Commit and push (Cloudflare will deploy)
git add version.json
git commit -m "Test: Simulate update available"
git push

# Wait 60 seconds for Cloudflare to deploy
sleep 60

# Now run your app and check for updates
# Should show "Update Available" alert

# After testing, restore original
mv version.json.backup version.json
git add version.json
git commit -m "Restore version.json after testing"
git push
```

### Test 5: Verify Download

When you see "Update Available":
1. Click "Download" button
2. Should open browser to DMG file
3. DMG should download correctly

---

## Verification Checklist

- [ ] `UpdateChecker.swift` compiles without errors
- [ ] App launches without crashes
- [ ] Console shows update check on launch
- [ ] Menu bar has "Check for Updates..." item
- [ ] Clicking menu item shows alert
- [ ] Alert shows current version correctly
- [ ] Test with fake version shows "Update Available"
- [ ] "Download" button opens browser to DMG
- [ ] "Release Notes" button opens release notes page
- [ ] "Later" button dismisses alert

---

## Troubleshooting

### Issue: UpdateChecker.swift not found when building

**Solution:** Add the file to Xcode project (see step 3 above)

### Issue: "Check for Updates" menu item does nothing

**Solution:** Make sure `updateItem.target = self` is set

### Issue: Always shows "Up to Date" even with newer version.json

**Solution:** 
1. Check version.json is actually deployed (`curl https://superdimmer.com/version.json`)
2. Check version string comparison (1.0.1 vs 1.0.0)
3. Check console logs for HTTP errors

### Issue: App crashes on launch

**Solution:** Check console for error. Likely issues:
- URL is malformed (check versionURL in UpdateChecker.swift)
- JSON parsing failed (check version.json format)

---

## Next Steps After Integration

1. **Test thoroughly** with all scenarios above
2. **Update BUILD_CHECKLIST.md** with update check status
3. **Create RELEASE_PROCESS.md** documenting how to update version.json
4. **Consider adding to app UI** (Settings → About section showing version + "Check for Updates" button)
5. **Monitor first release** to ensure users can update successfully

---

## Future: Migrating to Sparkle

If you later want automatic installation (not just manual download):

1. Keep UpdateChecker.swift as fallback
2. Add Sparkle framework via SPM
3. Generate EdDSA keys
4. Create UpdateManager.swift (wrapper around Sparkle)
5. Update Info.plist with Sparkle keys
6. Sign all DMGs with sign_update tool
7. Both systems can coexist during transition

See: `/docs/deployment/UPDATE_DEPLOYMENT_STRATEGY.md`

---

*Document Created: January 19, 2026*
*Ready to integrate and test*
