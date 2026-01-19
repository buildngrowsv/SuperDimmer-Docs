# SuperDimmer Auto-Update System: Current Status & Setup Guide

**Document Created:** January 19, 2026  
**Status:** Documentation/Planning Phase - Not Yet Implemented

---

## 📊 EXECUTIVE SUMMARY

### Current Status: **Simple JSON-Based Update Checking (Partially Set Up)**

**What's In Place:**
- ✅ Website structure with `version.json` file
- ✅ Appcast.xml file prepared (with placeholder signatures)
- ✅ DMG files in releases folder
- ✅ Cloudflare Pages deployment (auto-deploys from GitHub)
- ✅ Info.plist configured for simple updates (NOT Sparkle)

**What's NOT Implemented:**
- ❌ No `UpdateChecker.swift` or `UpdateManager.swift` in the app
- ❌ No Sparkle framework integrated
- ❌ No EdDSA keys generated
- ❌ No auto-update checking code in the app
- ❌ No "Check for Updates" menu item

**Bottom Line:** You have the **hosting infrastructure** ready (Cloudflare + GitHub), but the **app itself has NO update checking code** yet.

---

## 🔍 TWO APPROACHES AVAILABLE

### Option 1: Simple JSON Update Checker (Recommended to Start)

**Pros:**
- ✅ Simple to implement (100 lines of Swift)
- ✅ No third-party frameworks
- ✅ No cryptographic key management
- ✅ Fast to set up (1-2 hours)
- ✅ Works great for initial releases

**Cons:**
- ❌ User must manually download and install updates
- ❌ Less secure (relies only on HTTPS)
- ❌ No automatic installation

**How It Works:**
```
App Launch → Fetch version.json → Compare versions → Show alert → 
User clicks "Download" → Opens browser → User installs DMG manually
```

### Option 2: Sparkle Framework (Industry Standard)

**Pros:**
- ✅ Auto-installs updates (user just clicks "Install")
- ✅ More secure (EdDSA signature verification)
- ✅ Used by BetterDisplay, f.lux, Umbra, etc.
- ✅ Professional and polished

**Cons:**
- ❌ Complex setup (EdDSA keys, signing pipeline)
- ❌ Requires third-party framework
- ❌ More moving parts = more to maintain
- ❌ Setup time: 4-6 hours

**How It Works:**
```
App Launch → Sparkle checks appcast.xml → Downloads DMG → 
Verifies EdDSA signature → Installs update → Relaunches app
(All automatic after user clicks "Install")
```

---

## 🚀 QUICK START: Simple JSON Approach (Recommended First)

### Step 1: Create UpdateChecker.swift

Create `/Users/ak/UserRoot/Github/SuperDimmer/SuperDimmer-Mac-App/SuperDimmer/Services/UpdateChecker.swift`:

```swift
//
//  UpdateChecker.swift
//  SuperDimmer
//
//  PURPOSE:
//  Simple update checker that fetches version.json from our website
//  and alerts the user if a newer version is available.
//  
//  WHY THIS APPROACH:
//  - No third-party frameworks (Sparkle) needed initially
//  - Simple to implement and maintain
//  - User manually downloads DMG (acceptable for early releases)
//  - Can migrate to Sparkle later for auto-install
//
//  HOW IT WORKS:
//  1. On app launch (and periodically), fetch version.json from website
//  2. Compare remote version with current CFBundleShortVersionString
//  3. If newer version available, show alert with "Download" button
//  4. User clicks Download → Opens browser → Manually installs DMG
//
//  SECURITY:
//  - Relies on HTTPS (Cloudflare provides this)
//  - Website is from trusted GitHub repo (Cloudflare Pages)
//  - DMG is notarized by Apple (Gatekeeper validates)
//

import Foundation
import AppKit

/// Manages checking for app updates via simple JSON feed
/// No Sparkle framework needed - just URLSession and JSON parsing
final class UpdateChecker {
    
    // MARK: - Singleton
    
    static let shared = UpdateChecker()
    
    // MARK: - Configuration
    
    /// URL to version.json on our Cloudflare-hosted website
    /// This file is automatically updated by our release script
    private let versionURL = URL(string: "https://superdimmer.app/version.json")!
    
    /// How often to check for updates (24 hours)
    private let checkInterval: TimeInterval = 86400
    
    /// UserDefaults key for last check date
    private let lastCheckKey = "lastUpdateCheckDate"
    
    // MARK: - Types
    
    /// Structure matching version.json format on our website
    /// Example JSON:
    /// {
    ///   "version": "1.0.1",
    ///   "build": 7,
    ///   "downloadURL": "https://superdimmer.app/releases/SuperDimmer-v1.0.1.dmg",
    ///   "releaseNotesURL": "https://superdimmer.app/release-notes/v1.0.1.html",
    ///   "minSystemVersion": "13.0",
    ///   "releaseDate": "2026-01-10"
    /// }
    struct VersionInfo: Codable {
        let version: String              // User-facing version (e.g., "1.0.1")
        let build: Int                   // Build number (e.g., 7)
        let downloadURL: String          // Direct link to DMG
        let releaseNotesURL: String      // Link to release notes HTML
        let minSystemVersion: String?    // Minimum macOS version
        let releaseDate: String?         // Release date (for display)
    }
    
    // MARK: - Initialization
    
    private init() {
        // Private init for singleton pattern
    }
    
    // MARK: - Public Methods
    
    /// Check for updates automatically (respects check interval)
    /// Called on app launch - won't check if checked recently
    func checkForUpdatesAutomatically() {
        guard shouldCheckNow() else {
            print("⏱️ Skipping update check - checked recently")
            return
        }
        
        checkForUpdates(showUpToDateAlert: false)
    }
    
    /// Manually check for updates (from menu item)
    /// Always checks and shows result, even if up to date
    func checkForUpdatesManually() {
        checkForUpdates(showUpToDateAlert: true)
    }
    
    // MARK: - Private Methods
    
    /// Determine if we should check now based on last check time
    private func shouldCheckNow() -> Bool {
        guard let lastCheck = UserDefaults.standard.object(forKey: lastCheckKey) as? Date else {
            return true  // Never checked before
        }
        
        let timeSinceLastCheck = Date().timeIntervalSince(lastCheck)
        return timeSinceLastCheck >= checkInterval
    }
    
    /// Perform the actual update check
    /// - Parameter showUpToDateAlert: If true, show alert even when up to date
    private func checkForUpdates(showUpToDateAlert: Bool) {
        print("🔍 Checking for updates...")
        
        // Create URL request
        var request = URLRequest(url: versionURL)
        request.cachePolicy = .reloadIgnoringLocalCacheData  // Always fetch fresh
        
        // Fetch version.json
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            
            // Handle errors
            if let error = error {
                print("❌ Update check failed: \(error.localizedDescription)")
                return
            }
            
            // Parse JSON
            guard let data = data,
                  let remoteVersion = try? JSONDecoder().decode(VersionInfo.self, from: data) else {
                print("❌ Failed to parse version.json")
                return
            }
            
            // Update last check date
            UserDefaults.standard.set(Date(), forKey: self?.lastCheckKey ?? "")
            
            // Get current version from Info.plist
            let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
            let currentBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0"
            
            print("📱 Current version: \(currentVersion) (build \(currentBuild))")
            print("🌐 Remote version: \(remoteVersion.version) (build \(remoteVersion.build))")
            
            // Compare versions
            if self?.isNewer(remoteVersion.version, than: currentVersion) == true {
                print("✨ Update available!")
                DispatchQueue.main.async {
                    self?.showUpdateAlert(version: remoteVersion, currentVersion: currentVersion)
                }
            } else {
                print("✅ App is up to date")
                if showUpToDateAlert {
                    DispatchQueue.main.async {
                        self?.showUpToDateAlert(currentVersion: currentVersion)
                    }
                }
            }
        }.resume()
    }
    
    /// Compare two version strings (e.g., "1.0.1" vs "1.0.0")
    /// Returns true if remote is newer
    private func isNewer(_ remote: String, than current: String) -> Bool {
        // Use numeric comparison which handles version strings properly
        // "1.10.0" > "1.9.0" correctly
        return remote.compare(current, options: .numeric) == .orderedDescending
    }
    
    /// Show alert when update is available
    private func showUpdateAlert(version: VersionInfo, currentVersion: String) {
        let alert = NSAlert()
        alert.messageText = "Update Available"
        alert.informativeText = """
        SuperDimmer \(version.version) is now available.
        You're currently using version \(currentVersion).
        
        Would you like to download the update?
        """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Download")
        alert.addButton(withTitle: "Release Notes")
        alert.addButton(withTitle: "Later")
        
        let response = alert.runModal()
        
        if response == .alertFirstButtonReturn {
            // User clicked "Download"
            if let url = URL(string: version.downloadURL) {
                NSWorkspace.shared.open(url)
            }
        } else if response == .alertSecondButtonReturn {
            // User clicked "Release Notes"
            if let url = URL(string: version.releaseNotesURL) {
                NSWorkspace.shared.open(url)
            }
        }
        // User clicked "Later" - do nothing
    }
    
    /// Show alert when app is up to date (manual check only)
    private func showUpToDateAlert(currentVersion: String) {
        let alert = NSAlert()
        alert.messageText = "You're Up to Date"
        alert.informativeText = "SuperDimmer \(currentVersion) is the latest version."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}
```

### Step 2: Add to AppDelegate or SuperDimmerApp

In `/Users/ak/UserRoot/Github/SuperDimmer/SuperDimmer-Mac-App/SuperDimmer/App/SuperDimmerApp.swift`:

```swift
import SwiftUI

@main
struct SuperDimmerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        // Check for updates on app launch (automatic check)
        // This respects the 24-hour check interval
        UpdateChecker.shared.checkForUpdatesAutomatically()
    }
    
    var body: some Scene {
        // ... your existing scene
    }
}
```

### Step 3: Add Menu Item

In `/Users/ak/UserRoot/Github/SuperDimmer/SuperDimmer-Mac-App/SuperDimmer/MenuBar/MenuBarController.swift`:

Add to your menu items:

```swift
let updateItem = NSMenuItem(
    title: "Check for Updates...",
    action: #selector(checkForUpdates),
    keyEquivalent: ""
)
menu.addItem(updateItem)

@objc func checkForUpdates() {
    UpdateChecker.shared.checkForUpdatesManually()
}
```

### Step 4: Test It

```bash
# 1. Build the app
cd /Users/ak/UserRoot/Github/SuperDimmer/SuperDimmer-Mac-App
xcodebuild -scheme SuperDimmer -configuration Release clean build

# 2. Run it
open build/Build/Products/Release/SuperDimmer.app

# 3. Click menu bar → Check for Updates
# Should show "You're Up to Date" (since version.json still has 1.0.0)
```

### Step 5: Update Website for New Releases

When you release a new version:

```bash
# 1. Edit version.json
cd /Users/ak/UserRoot/Github/SuperDimmer/SuperDimmer-Website

# Update to new version:
cat > version.json << 'EOF'
{
  "version": "1.0.1",
  "build": 7,
  "downloadURL": "https://superdimmer.app/releases/SuperDimmer-v1.0.1.dmg",
  "releaseNotesURL": "https://superdimmer.app/release-notes/v1.0.1.html",
  "minSystemVersion": "13.0",
  "releaseDate": "2026-01-19"
}
EOF

# 2. Commit and push
git add version.json
git commit -m "Update version.json for v1.0.1"
git push

# Cloudflare auto-deploys in ~1 minute
# Users will see update alert on next check
```

---

## 🔐 ADVANCED: Sparkle Framework Setup (Future)

If you want automatic updates with one-click installation, here's what you need:

### Prerequisites

1. **Install Sparkle via SPM:**
   - Xcode → File → Add Package Dependencies
   - URL: `https://github.com/sparkle-project/Sparkle`
   - Version: `2.6.0` or later

2. **Generate EdDSA Keys:**
   ```bash
   # Download Sparkle tools
   cd ~/Downloads
   wget https://github.com/sparkle-project/Sparkle/releases/download/2.6.0/Sparkle-2.6.0.tar.xz
   tar -xf Sparkle-2.6.0.tar.xz
   cd Sparkle-2.6.0/bin
   
   # Generate keys (saves to Keychain + prints public key)
   ./generate_keys
   
   # IMPORTANT: Backup private key!
   ./generate_keys -x ~/SuperDimmer-sparkle-private-key.pem
   # Store this file securely - you'll need it for ALL updates
   ```

3. **Update Info.plist:**
   ```xml
   <key>SUFeedURL</key>
   <string>https://superdimmer.app/sparkle/appcast.xml</string>
   
   <key>SUPublicEDKey</key>
   <string>YOUR_PUBLIC_KEY_FROM_GENERATE_KEYS</string>
   
   <key>SUEnableAutomaticChecks</key>
   <true/>
   
   <key>SUScheduledCheckInterval</key>
   <integer>86400</integer>
   ```

4. **Sign Updates:**
   Every time you release a new DMG:
   ```bash
   cd ~/Downloads/Sparkle-2.6.0/bin
   ./sign_update /path/to/SuperDimmer-v1.0.1.dmg
   
   # Output: sparkle:edSignature="abc123..." length="12345678"
   # Copy this to appcast.xml
   ```

5. **Update Appcast.xml:**
   ```xml
   <item>
       <title>Version 1.0.1</title>
       <sparkle:version>7</sparkle:version>
       <sparkle:shortVersionString>1.0.1</sparkle:shortVersionString>
       <enclosure 
           url="https://superdimmer.app/releases/SuperDimmer-v1.0.1.dmg" 
           length="FILE_SIZE_IN_BYTES"
           sparkle:edSignature="SIGNATURE_FROM_SIGN_UPDATE=="/>
   </item>
   ```

---

## 📁 HOSTING: How Updates Work on Cloudflare

### Current Setup (Already Working)

```
GitHub Repo (SuperDimmer-Website)
    ↓ (auto-deploy on push)
Cloudflare Pages
    ↓ (serves via HTTPS)
https://superdimmer.app/
    ├── version.json           ← Simple updates check this
    ├── sparkle/
    │   └── appcast.xml        ← Sparkle checks this
    └── releases/
        ├── SuperDimmer-v1.0.0.dmg
        └── SuperDimmer-v1.0.1.dmg
```

### Adding New Releases

**It's literally just:**

1. Copy DMG to `SuperDimmer-Website/releases/`
2. Update `version.json` (simple) or `appcast.xml` (Sparkle)
3. `git add . && git commit -m "Release v1.0.1" && git push`
4. Wait 60 seconds for Cloudflare to deploy
5. Done! ✅

**Yes, the same DMG works for both:**
- Initial downloads (users visit website, click Download)
- Updates (app downloads DMG automatically)

The DMG is just a disk image with your .app inside. It works the same whether downloaded manually or by the update system.

---

## ✅ RECOMMENDED ACTION PLAN

### Phase 1: Get Basic Updates Working (This Week)

1. ✅ **Implement Simple JSON UpdateChecker** (1-2 hours)
   - Create `UpdateChecker.swift` (code provided above)
   - Add to AppDelegate
   - Add menu item
   - Test with current version

2. ✅ **Test Update Flow** (30 minutes)
   - Temporarily change version.json to "2.0.0"
   - Run app, should show "Update Available"
   - Click Download, should open browser
   - Verify DMG downloads correctly

3. ✅ **Document Release Process** (30 minutes)
   - How to build new version
   - How to update version.json
   - How to commit and push

### Phase 2: Add Sparkle (Later, When Needed)

Only do this if/when you want automatic installation:

1. Add Sparkle framework
2. Generate EdDSA keys (and backup!)
3. Create UpdateManager.swift
4. Update Info.plist with Sparkle keys
5. Update release script to sign with EdDSA
6. Test full auto-update flow

**Estimated Time:** 4-6 hours
**Best Time:** After first release is live and stable

---

## 🎯 QUICK ANSWERS TO YOUR QUESTIONS

### "Where are we with implementing auto-update?"

**Status:** Not yet implemented in the app itself. The hosting infrastructure (Cloudflare, version.json, appcast.xml) is ready, but there's NO update checking code in the Swift app yet.

### "What would go into setting it up?"

**Simple Approach (Recommended First):**
- Create `UpdateChecker.swift` (~100 lines)
- Call it on app launch
- Add "Check for Updates" menu item
- **Time: 1-2 hours**

**Sparkle Approach (Later):**
- Add Sparkle framework via SPM
- Generate EdDSA keys
- Create UpdateManager.swift
- Update Info.plist
- Sign all DMGs with EdDSA
- **Time: 4-6 hours + ongoing signing**

### "How would we save it on the domain?"

**Already done!** Your Cloudflare Pages site auto-deploys from GitHub. Just:
```bash
cp SuperDimmer-v1.0.1.dmg SuperDimmer-Website/releases/
git add . && git commit -m "Release v1.0.1" && git push
```

Cloudflare serves it at `https://superdimmer.app/releases/SuperDimmer-v1.0.1.dmg` automatically.

### "What needs to be set up for that?"

**For Simple JSON (Recommended):**
- ✅ Hosting: Already set up (Cloudflare)
- ✅ version.json: Already exists
- ❌ App code: Needs UpdateChecker.swift (provided above)

**For Sparkle:**
- ✅ Hosting: Already set up
- ✅ appcast.xml: Already exists (needs real signatures)
- ❌ EdDSA keys: Need to generate
- ❌ App code: Needs UpdateManager.swift + Sparkle framework
- ❌ Release pipeline: Needs to sign every DMG with EdDSA

### "Is the same DMG for install sufficient?"

**YES!** The DMG works for both:
- ✅ Manual downloads from website
- ✅ Automatic downloads via update system
- ✅ Sparkle auto-installs it

**Why it works:**
- DMG is just a container with your .app inside
- Both manual users and update systems extract the .app
- Sparkle can even replace a running app (quits, updates, relaunches)

---

## 📝 NEXT STEPS

### Immediate (Today/Tomorrow):

1. **Implement Simple JSON UpdateChecker**
   - Use code provided in Step 1 above
   - Add to app launch
   - Add menu item
   - Test it works

2. **Test the Flow**
   - Change version.json temporarily
   - Verify alert shows
   - Verify download link works

### Short-term (Before First Public Release):

3. **Document Release Process**
   - Create `RELEASE_PROCESS.md`
   - Step-by-step instructions
   - Include update checklist

4. **Verify Hosting**
   - Ensure superdimmer.app domain works
   - Test DMG download speed
   - Confirm HTTPS certificate

### Long-term (After Launch):

5. **Consider Sparkle**
   - Once you have users on v1.0.0
   - If manual updates are friction
   - When you have time for 4-6 hour implementation

---

## 📚 REFERENCE DOCUMENTS

- `/Users/ak/UserRoot/Github/SuperDimmer/docs/deployment/UPDATE_DEPLOYMENT_STRATEGY.md` - Full Sparkle guide
- `/Users/ak/UserRoot/Github/SuperDimmer/SuperDimmer-Website/UPDATE_SYSTEM_CHECKLIST.md` - Simple JSON approach
- `/Users/ak/UserRoot/Github/SuperDimmer/SuperDimmer-Website/sparkle/appcast.xml` - Sparkle feed (ready but unsigned)
- `/Users/ak/UserRoot/Github/SuperDimmer/SuperDimmer-Website/version.json` - JSON feed (ready to use)

---

**TLDR:**  
✅ Hosting is ready  
❌ App has no update code yet  
🎯 Start with simple JSON UpdateChecker (1-2 hours)  
🔮 Add Sparkle later if needed (4-6 hours)  
📦 Same DMG works for both approaches  
