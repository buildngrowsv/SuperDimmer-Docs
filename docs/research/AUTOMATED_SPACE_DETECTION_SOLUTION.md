# ✅ Automated Space Detection Solution
## Detecting Current Desktop Space Without Manual Registration

**Date:** January 21, 2026  
**Status:** WORKING SOLUTION FOUND  
**Approach:** Read com.apple.spaces plist

---

## Executive Summary

**✅ WE CAN AUTOMATICALLY DETECT WHICH SPACE WE'RE ON!**

Using the `com.apple.spaces` plist, we can:
1. **Get current Space UUID** - Know which Space is active
2. **Get Space index/number** - Know it's "Space 1", "Space 2", etc.
3. **Monitor Space changes** - Detect when user switches Spaces
4. **List all Spaces** - Know how many Spaces exist

**NO MANUAL REGISTRATION NEEDED!**

---

## The Solution

### Method 1: com.apple.spaces Plist (RECOMMENDED) ✅

**How it works:**
- macOS stores Space information in `~/Library/Preferences/com.apple.spaces.plist`
- Contains "Current Space" with UUID
- Contains "Spaces" array with all Space UUIDs
- Updates automatically when user switches Spaces

**Test Results:**
```bash
# Current Space UUID
Current Space UUID: C6C76FEF-95BC-46B8-BADB-EBAE4BA4CDF0

# Current Space Number
Current Space Number: 6

# Monitoring works - detects changes automatically!
```

---

## Implementation in Swift

### Reading Current Space

```swift
import Foundation

class SpaceDetector {
    
    /// Gets the UUID of the currently active Space
    static func getCurrentSpaceUUID() -> String? {
        let task = Process()
        task.launchPath = "/usr/bin/defaults"
        task.arguments = ["read", "com.apple.spaces"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        task.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let output = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        // Parse output to find Current Space UUID
        let lines = output.components(separatedBy: "\n")
        var inCurrentSpace = false
        
        for line in lines {
            if line.contains("\"Current Space\"") {
                inCurrentSpace = true
            }
            if inCurrentSpace && line.contains("uuid") {
                // Extract UUID from: uuid = "C6C76FEF-95BC-46B8-BADB-EBAE4BA4CDF0";
                let pattern = "uuid = \"([^\"]+)\""
                if let regex = try? NSRegularExpression(pattern: pattern),
                   let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
                   let range = Range(match.range(at: 1), in: line) {
                    return String(line[range])
                }
            }
        }
        
        return nil
    }
    
    /// Gets all Space UUIDs for the main display
    static func getAllSpaceUUIDs() -> [String] {
        let task = Process()
        task.launchPath = "/usr/bin/defaults"
        task.arguments = ["read", "com.apple.spaces"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        task.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let output = String(data: data, encoding: .utf8) else {
            return []
        }
        
        var uuids: [String] = []
        let pattern = "uuid = \"([^\"]+)\""
        
        if let regex = try? NSRegularExpression(pattern: pattern) {
            let matches = regex.matches(in: output, range: NSRange(output.startIndex..., in: output))
            for match in matches {
                if let range = Range(match.range(at: 1), in: output) {
                    uuids.append(String(output[range]))
                }
            }
        }
        
        return uuids
    }
    
    /// Gets the index (1-based) of the current Space
    static func getCurrentSpaceIndex() -> Int? {
        guard let currentUUID = getCurrentSpaceUUID() else {
            return nil
        }
        
        let allUUIDs = getAllSpaceUUIDs()
        
        // Find the index of current UUID in the Spaces array
        // Note: The plist has "Current Space" first, then "Spaces" array
        // We need to parse more carefully to get just the Spaces array
        
        if let index = allUUIDs.firstIndex(of: currentUUID) {
            return index + 1  // 1-based index
        }
        
        return nil
    }
}

// Usage:
if let spaceIndex = SpaceDetector.getCurrentSpaceIndex() {
    print("Currently on Space \(spaceIndex)")
}
```

### Better Implementation Using PropertyListSerialization

```swift
import Foundation

class SpaceDetectorImproved {
    
    struct SpaceInfo {
        let uuid: String
        let managedSpaceID: Int
        let index: Int  // 1-based
    }
    
    struct CurrentSpaceInfo {
        let uuid: String
        let managedSpaceID: Int
        let spaceNumber: Int  // Which Space (1, 2, 3, etc.)
    }
    
    /// Gets detailed information about the current Space
    static func getCurrentSpace() -> CurrentSpaceInfo? {
        guard let plistPath = NSHomeDirectory().appending("/Library/Preferences/com.apple.spaces.plist") as String?,
              let plistData = try? Data(contentsOf: URL(fileURLWithPath: plistPath)),
              let plist = try? PropertyListSerialization.propertyList(from: plistData, format: nil) as? [String: Any] else {
            return nil
        }
        
        // Navigate to Management Data
        guard let displayConfig = plist["SpacesDisplayConfiguration"] as? [String: Any],
              let managementData = displayConfig["Management Data"] as? [String: Any],
              let monitors = managementData["Monitors"] as? [[String: Any]] else {
            return nil
        }
        
        // Find the main monitor
        for monitor in monitors {
            guard let currentSpace = monitor["Current Space"] as? [String: Any],
                  let currentUUID = currentSpace["uuid"] as? String,
                  let currentID = currentSpace["ManagedSpaceID"] as? Int,
                  let spaces = monitor["Spaces"] as? [[String: Any]] else {
                continue
            }
            
            // Find the index of current Space in the Spaces array
            for (index, space) in spaces.enumerated() {
                if let uuid = space["uuid"] as? String, uuid == currentUUID {
                    return CurrentSpaceInfo(
                        uuid: currentUUID,
                        managedSpaceID: currentID,
                        spaceNumber: index + 1  // 1-based
                    )
                }
            }
        }
        
        return nil
    }
    
    /// Gets all Spaces for the main display
    static func getAllSpaces() -> [SpaceInfo] {
        guard let plistPath = NSHomeDirectory().appending("/Library/Preferences/com.apple.spaces.plist") as String?,
              let plistData = try? Data(contentsOf: URL(fileURLWithPath: plistPath)),
              let plist = try? PropertyListSerialization.propertyList(from: plistData, format: nil) as? [String: Any] else {
            return []
        }
        
        guard let displayConfig = plist["SpacesDisplayConfiguration"] as? [String: Any],
              let managementData = displayConfig["Management Data"] as? [String: Any],
              let monitors = managementData["Monitors"] as? [[String: Any]] else {
            return []
        }
        
        // Find the main monitor
        for monitor in monitors {
            guard let spaces = monitor["Spaces"] as? [[String: Any]] else {
                continue
            }
            
            return spaces.enumerated().compactMap { index, space in
                guard let uuid = space["uuid"] as? String,
                      let managedID = space["ManagedSpaceID"] as? Int else {
                    return nil
                }
                return SpaceInfo(
                    uuid: uuid,
                    managedSpaceID: managedID,
                    index: index + 1
                )
            }
        }
        
        return []
    }
}

// Usage:
if let currentSpace = SpaceDetectorImproved.getCurrentSpace() {
    print("Currently on Space \(currentSpace.spaceNumber)")
    print("UUID: \(currentSpace.uuid)")
    print("Managed ID: \(currentSpace.managedSpaceID)")
}

let allSpaces = SpaceDetectorImproved.getAllSpaces()
print("Total Spaces: \(allSpaces.count)")
for space in allSpaces {
    print("Space \(space.index): \(space.uuid)")
}
```

### Monitoring Space Changes

```swift
import Foundation

class SpaceChangeMonitor {
    
    private var timer: Timer?
    private var lastSpaceUUID: String?
    private var onSpaceChange: ((Int) -> Void)?
    
    /// Starts monitoring for Space changes
    /// - Parameter callback: Called with new Space number when Space changes
    func startMonitoring(onSpaceChange: @escaping (Int) -> Void) {
        self.onSpaceChange = onSpaceChange
        self.lastSpaceUUID = SpaceDetectorImproved.getCurrentSpace()?.uuid
        
        // Poll every 0.5 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkForSpaceChange()
        }
    }
    
    /// Stops monitoring
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    private func checkForSpaceChange() {
        guard let currentSpace = SpaceDetectorImproved.getCurrentSpace() else {
            return
        }
        
        if currentSpace.uuid != lastSpaceUUID {
            lastSpaceUUID = currentSpace.uuid
            onSpaceChange?(currentSpace.spaceNumber)
            print("✓ Space changed to Space \(currentSpace.spaceNumber)")
        }
    }
}

// Usage:
let monitor = SpaceChangeMonitor()
monitor.startMonitoring { spaceNumber in
    print("User switched to Space \(spaceNumber)")
    // Update overlay for this Space
    updateOverlayForSpace(spaceNumber)
}
```

---

## Method 2: Hammerspoon (Alternative)

**How it works:**
- Hammerspoon provides `hs.spaces` API
- Can get current Space ID
- Can monitor Space changes

**Pros:**
- Clean API
- Well-documented
- Active community

**Cons:**
- Requires Hammerspoon installed
- External dependency
- Uses private APIs (could break)

**Code Example:**
```lua
-- Hammerspoon config
local spaces = require("hs.spaces")

-- Get current Space
local currentSpace = spaces.focusedSpace()
print("Current space ID: " .. currentSpace)

-- Get all Spaces for screen
local allSpaces = spaces.spacesForScreen()
for i, spaceID in ipairs(allSpaces) do
    print("Space " .. i .. ": " .. spaceID)
end
```

**Not recommended for SuperDimmer** because:
- Adds external dependency
- Users need to install Hammerspoon
- Can't bundle with app easily

---

## Recommended Implementation for SuperDimmer

### Architecture

```
┌─────────────────────────────────────────────────────────┐
│ SpaceIdentificationManager                              │
│                                                         │
│ ┌─────────────────────────────────────────────────┐   │
│ │ SpaceDetector                                   │   │
│ │ - getCurrentSpace() -> SpaceInfo                │   │
│ │ - getAllSpaces() -> [SpaceInfo]                 │   │
│ └─────────────────────────────────────────────────┘   │
│                                                         │
│ ┌─────────────────────────────────────────────────┐   │
│ │ SpaceChangeMonitor                              │   │
│ │ - Polls com.apple.spaces plist every 0.5s       │   │
│ │ - Detects Space changes                         │   │
│ │ - Notifies manager                              │   │
│ └─────────────────────────────────────────────────┘   │
│                                                         │
│ ┌─────────────────────────────────────────────────┐   │
│ │ SpaceOverlayManager                             │   │
│ │ - Creates one overlay per Space                 │   │
│ │ - Each overlay pinned to its Space              │   │
│ │ - Different visual theme per Space              │   │
│ └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

### Automatic Setup Flow

**1. App Launch:**
```swift
// Detect all Spaces
let allSpaces = SpaceDetectorImproved.getAllSpaces()
print("Found \(allSpaces.count) Spaces")

// Create overlay for each Space
for space in allSpaces {
    createOverlayForSpace(space.index, uuid: space.uuid)
}
```

**2. Create Space-Specific Overlays:**
```swift
func createOverlayForSpace(_ spaceNumber: Int, uuid: String) {
    // Get theme for this Space number
    let theme = getThemeForSpace(spaceNumber)
    
    // Create overlay
    let overlay = DimOverlayWindow.create(
        frame: NSScreen.main!.frame,
        dimLevel: theme.dimLevel,
        id: "space-\(spaceNumber)-\(uuid)"
    )
    
    // CRITICAL: Remove canJoinAllSpaces
    overlay.collectionBehavior = [
        .fullScreenAuxiliary,
        .stationary,
        .ignoresCycle
    ]
    
    // Set visual theme
    overlay.contentView?.layer?.backgroundColor = theme.color.cgColor
    overlay.level = .desktop
    
    // Show overlay
    overlay.orderFront(nil)
    
    // Store reference
    spaceOverlays[uuid] = overlay
}
```

**3. Monitor Space Changes:**
```swift
let monitor = SpaceChangeMonitor()
monitor.startMonitoring { spaceNumber in
    print("User switched to Space \(spaceNumber)")
    // Overlays automatically show/hide based on their Space
    // No action needed!
}
```

### The Magic

**Once overlays are created:**
- Each overlay is pinned to its Space
- macOS automatically shows/hides them when switching Spaces
- We just need to know which Space we're on for other features
- No manual management of overlay visibility needed!

---

## Visual Themes

### Automatic Theme Assignment

```swift
func getThemeForSpace(_ spaceNumber: Int) -> SpaceTheme {
    let themes = [
        SpaceTheme(color: NSColor.systemBlue.withAlphaComponent(0.05), dimLevel: 0.02),
        SpaceTheme(color: NSColor.systemGreen.withAlphaComponent(0.05), dimLevel: 0.04),
        SpaceTheme(color: NSColor.systemPurple.withAlphaComponent(0.05), dimLevel: 0.06),
        SpaceTheme(color: NSColor.systemOrange.withAlphaComponent(0.05), dimLevel: 0.08),
        SpaceTheme(color: NSColor.systemPink.withAlphaComponent(0.05), dimLevel: 0.10),
        SpaceTheme(color: NSColor.systemYellow.withAlphaComponent(0.05), dimLevel: 0.12),
    ]
    
    let index = (spaceNumber - 1) % themes.count
    return themes[index]
}
```

---

## Handling Dynamic Space Changes

### User Adds/Removes Spaces

```swift
class SpaceIdentificationManager {
    
    private var knownSpaces: Set<String> = []
    
    func monitorSpaceChanges() {
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.checkForSpaceListChanges()
        }
    }
    
    private func checkForSpaceListChanges() {
        let currentSpaces = Set(SpaceDetectorImproved.getAllSpaces().map { $0.uuid })
        
        // New Spaces added
        let newSpaces = currentSpaces.subtracting(knownSpaces)
        for uuid in newSpaces {
            if let space = SpaceDetectorImproved.getAllSpaces().first(where: { $0.uuid == uuid }) {
                print("✓ New Space detected: Space \(space.index)")
                createOverlayForSpace(space.index, uuid: uuid)
            }
        }
        
        // Spaces removed
        let removedSpaces = knownSpaces.subtracting(currentSpaces)
        for uuid in removedSpaces {
            print("✓ Space removed: \(uuid)")
            removeOverlayForSpace(uuid)
        }
        
        knownSpaces = currentSpaces
    }
}
```

---

## Performance Considerations

### Polling Frequency

**Space Change Detection:**
- Poll every 0.5 seconds
- Very lightweight (just reading a plist)
- Negligible CPU impact

**Space List Changes:**
- Check every 2 seconds
- Users rarely add/remove Spaces
- Can be even less frequent (5-10 seconds)

### Optimization

```swift
// Cache the plist data
private var cachedPlistData: Data?
private var lastPlistCheck: Date?

func getCurrentSpaceOptimized() -> CurrentSpaceInfo? {
    let now = Date()
    
    // Only re-read plist if it's been > 0.5 seconds
    if let lastCheck = lastPlistCheck,
       now.timeIntervalSince(lastCheck) < 0.5,
       let cached = cachedPlistData {
        // Use cached data
        return parseSpaceInfo(from: cached)
    }
    
    // Read fresh data
    guard let plistPath = NSHomeDirectory().appending("/Library/Preferences/com.apple.spaces.plist") as String?,
          let data = try? Data(contentsOf: URL(fileURLWithPath: plistPath)) else {
        return nil
    }
    
    cachedPlistData = data
    lastPlistCheck = now
    
    return parseSpaceInfo(from: data)
}
```

---

## Advantages Over Manual Registration

### Manual Registration (OLD):
- ❌ User has to switch to each Space
- ❌ User has to click "Register" on each
- ❌ Tedious setup process
- ❌ Breaks if user adds/removes Spaces
- ❌ No persistence across restarts

### Automatic Detection (NEW):
- ✅ Works immediately on app launch
- ✅ No user interaction needed
- ✅ Automatically handles new Spaces
- ✅ Automatically handles removed Spaces
- ✅ Works after app restart
- ✅ Professional user experience

---

## Implementation Checklist

### Phase 1: Basic Detection
- [ ] Create `SpaceDetector` class
- [ ] Implement `getCurrentSpace()`
- [ ] Implement `getAllSpaces()`
- [ ] Test with multiple Spaces
- [ ] Handle edge cases (no Spaces, single Space)

### Phase 2: Monitoring
- [ ] Create `SpaceChangeMonitor` class
- [ ] Implement polling mechanism
- [ ] Test Space change detection
- [ ] Optimize polling frequency
- [ ] Add error handling

### Phase 3: Overlay Management
- [ ] Create overlays for all Spaces on launch
- [ ] Assign unique themes per Space
- [ ] Test overlay visibility per Space
- [ ] Handle Space additions
- [ ] Handle Space removals

### Phase 4: User Settings
- [ ] Add enable/disable toggle
- [ ] Add theme customization
- [ ] Add intensity slider
- [ ] Add per-Space overrides
- [ ] Save/restore preferences

### Phase 5: Polish
- [ ] Add smooth transitions
- [ ] Optimize performance
- [ ] Add debug logging
- [ ] Write documentation
- [ ] Create user guide

---

## Known Limitations

### 1. Plist Format Changes
**Issue:** Apple could change the plist format in future macOS versions

**Mitigation:**
- Wrap in try-catch
- Fallback to manual detection if plist fails
- Test on each new macOS version
- Monitor for changes

### 2. Multiple Displays
**Issue:** Each display has its own Spaces

**Solution:**
- Parse all monitors in plist
- Create overlays per display per Space
- Track current Space per display

### 3. Fullscreen Apps
**Issue:** Fullscreen apps create temporary Spaces

**Solution:**
- Detect Space type (normal vs fullscreen)
- Skip creating overlays for fullscreen Spaces
- Or create special overlay for fullscreen

---

## Conclusion

**✅ AUTOMATED SPACE DETECTION IS FULLY FEASIBLE!**

Using the `com.apple.spaces` plist:
- We can detect current Space automatically
- We can monitor Space changes
- We can handle dynamic Space additions/removals
- No manual user registration needed
- Professional, seamless experience

**This is the RIGHT way to implement Space identification!**

---

*Solution documented: January 21, 2026*  
*Status: Ready for implementation*  
*Approach: Automated via com.apple.spaces plist*
