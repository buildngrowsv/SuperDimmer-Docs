# Spaces HUD - Remaining Work Analysis
## January 21, 2026

---

## Current Implementation Status ✅

### What's Already Built

1. **Core HUD Infrastructure** ✅
   - `SuperSpacesHUD.swift` - NSPanel floating window
   - `SuperSpacesHUDView.swift` - SwiftUI interface
   - `SpaceDetector.swift` - Space detection via plist
   - `SpaceChangeMonitor.swift` - Real-time Space change monitoring
   - Settings integration in SettingsManager

2. **Features Working** ✅
   - Floating HUD that appears on all Spaces
   - Three display modes: Mini, Compact, Expanded
   - Space switching via AppleScript (Control+Arrow simulation)
   - Current Space highlighting
   - Auto-updates when switching Spaces
   - Draggable positioning
   - Close button

3. **Settings Available** ✅
   - `superSpacesEnabled` - Enable/disable feature
   - `spaceNames` - Dictionary of custom Space names [Int: String]
   - `superSpacesDisplayMode` - "mini", "compact", "expanded"
   - `superSpacesAutoHide` - Auto-hide after switching

---

## Missing Features & Remaining Work

### 1. Settings Button Functionality ⬜

**Current State:**
- Settings button exists in footer (line 260-264 of SuperSpacesHUDView.swift)
- Currently has TODO comment: `/* TODO: Open preferences */`

**What It Should Do:**

#### Option A: Open Preferences Window to Super Spaces Tab
```swift
Button(action: {
    // Open main Preferences window
    // Navigate to Super Spaces tab
    NotificationCenter.default.post(
        name: NSNotification.Name("OpenPreferences"),
        object: nil,
        userInfo: ["tab": "superSpaces"]
    )
}) {
    Text("Settings")
        .font(.system(size: 10))
}
```

#### Option B: Show Quick Settings Popover
```swift
Button(action: {
    showQuickSettings.toggle()
}) {
    Text("Settings")
        .font(.system(size: 10))
}
.popover(isPresented: $showQuickSettings) {
    SuperSpacesQuickSettingsView()
        .frame(width: 300, height: 200)
}
```

**Quick Settings Popover Content:**
- Display mode picker (Mini/Compact/Expanded)
- Auto-hide toggle
- "Edit Space Names..." button → Opens full Preferences
- Position preset buttons (Top-Left, Top-Right, etc.)

**Recommendation:** Option B (Quick Settings Popover) for better UX
- Users can adjust common settings without leaving HUD
- Full preferences still accessible via "Edit Space Names..." button
- Faster workflow

---

### 2. Note Mode Feature ⬜ (NEW REQUIREMENT)

**User Request:**
> "I also want to have a note mode where user can click on a space once and it will switch to that note and they can double click and it will go to that space."

**Interpretation:**
This is a **dual-mode system** where the HUD can switch between:
1. **Space Mode** (current) - Click to switch Spaces
2. **Note Mode** (new) - Click to open/edit notes for that Space

**Implementation Design:**

#### Mode Toggle UI
Add a mode selector at the top of the HUD (similar row to header):

```
┌─────────────────────────────────────────┐
│  Current Space: Development             │
│  Mode: [Space] [Note]  ← New toggle     │
├─────────────────────────────────────────┤
│  [1] [2] [●3] [4] [5] [6]              │
└─────────────────────────────────────────┘
```

#### Note Mode Behavior

**Single Click:**
- Opens a note editor for that Space
- Shows existing note or empty editor
- Note is associated with Space number

**Double Click:**
- Switches to that Space (same as Space Mode single click)
- Useful for "go to Space with note"

**Note Storage:**
```swift
// In SettingsManager
@Published var spaceNotes: [Int: String] = [:]
// Key: Space number, Value: Note text
```

#### Note Editor UI

**Inline Editor (Recommended):**
```
┌─────────────────────────────────────────┐
│  Note for Space 3: Development          │
│  ┌───────────────────────────────────┐  │
│  │ Working on SuperDimmer HUD        │  │
│  │ - Add note mode                   │  │
│  │ - Fix settings button             │  │
│  │ - Add emoji support               │  │
│  │                                   │  │
│  └───────────────────────────────────┘  │
│  [Save] [Cancel] [Switch to Space →]   │
└─────────────────────────────────────────┘
```

**Separate Note Window (Alternative):**
- Opens a floating note window
- Stays on top like HUD
- Auto-saves on close

#### Implementation Files

**New File: `SuperSpacesNoteEditor.swift`**
```swift
struct SuperSpacesNoteEditor: View {
    @Binding var note: String
    let spaceNumber: Int
    let onSave: () -> Void
    let onCancel: () -> Void
    let onSwitchToSpace: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Text("Note for Space \(spaceNumber)")
                    .font(.headline)
                Spacer()
                Button("✕") { onCancel() }
            }
            
            // Text editor
            TextEditor(text: $note)
                .font(.system(size: 13))
                .frame(minHeight: 150)
                .border(Color.secondary.opacity(0.3))
            
            // Actions
            HStack {
                Button("Cancel", action: onCancel)
                Spacer()
                Button("Switch to Space →", action: onSwitchToSpace)
                Button("Save", action: onSave)
                    .keyboardShortcut(.return, modifiers: .command)
            }
        }
        .padding()
        .frame(width: 400, height: 300)
    }
}
```

**Update: `SuperSpacesHUDView.swift`**
```swift
// Add mode state
@State private var hudMode: HUDMode = .space
enum HUDMode {
    case space  // Click to switch Spaces
    case note   // Click to edit notes
}

// Add note editor state
@State private var editingNoteForSpace: Int?
@State private var noteText: String = ""

// Add mode toggle in header
HStack {
    // Existing header content...
    
    Spacer()
    
    // Mode toggle
    Picker("", selection: $hudMode) {
        Label("Space", systemImage: "square.grid.3x3").tag(HUDMode.space)
        Label("Note", systemImage: "note.text").tag(HUDMode.note)
    }
    .pickerStyle(.segmented)
    .frame(width: 150)
}

// Update Space button behavior
Button(action: {
    if hudMode == .space {
        // Single click: Switch to Space
        viewModel.switchToSpace(space.index)
    } else {
        // Single click: Edit note
        editingNoteForSpace = space.index
        noteText = getNote(for: space.index)
    }
}) {
    // Button content...
}
.simultaneousGesture(
    TapGesture(count: 2).onEnded {
        // Double click: Always switch to Space
        viewModel.switchToSpace(space.index)
    }
)
```

---

### 3. Space Emoji/Icon Support ⬜ (NEW REQUIREMENT)

**User Request:**
> "We should also allow the user to add an emoji or icon for the space and we would display it along with the name of the space."

**Implementation:**

#### Data Model Update
```swift
// In SettingsManager
@Published var spaceEmojis: [Int: String] = [:]
// Key: Space number, Value: Emoji string (e.g., "📧", "🌐", "💻")
```

#### UI Changes

**Compact Mode:**
```
Before: [1] [2] [●3] [4]
After:  [📧1] [🌐2] [●💻3] [🎨4]
```

**Expanded Mode:**
```
┌──────────┐
│  💻 3     │  ← Emoji + number
│   Dev    │  ← Name
└──────────┘
```

**Header:**
```
Before: Space 3: Development
After:  💻 Space 3: Development
```

#### Emoji Picker UI

**Option A: macOS Native Emoji Picker**
```swift
Button(action: {
    // Trigger macOS emoji picker (Cmd+Ctrl+Space)
    NSApp.orderFrontCharacterPalette(nil)
}) {
    Text(spaceEmojis[spaceNumber] ?? "➕")
        .font(.system(size: 24))
}
.help("Click to add emoji")
```

**Option B: Custom Emoji Picker**
```swift
struct EmojiPicker: View {
    @Binding var selectedEmoji: String?
    
    let commonEmojis = [
        "📧", "🌐", "💻", "🎨", "🎵", "💬",  // Common use cases
        "📝", "📊", "🎮", "📹", "📷", "🎬",  // Work/Media
        "🏠", "🏢", "🎓", "🏥", "✈️", "🚗"   // Locations
    ]
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6)) {
            ForEach(commonEmojis, id: \.self) { emoji in
                Button(emoji) {
                    selectedEmoji = emoji
                }
                .font(.system(size: 24))
            }
        }
    }
}
```

**Recommendation:** Option B (Custom Picker) for better UX
- Faster selection (no system dialog)
- Curated list of relevant emojis
- Consistent with app design

#### Settings UI for Emoji

**In Preferences > Super Spaces:**
```
┌─────────────────────────────────────────┐
│ Space Customization                     │
├─────────────────────────────────────────┤
│                                         │
│ Space 1:  [📧] [Email & Calendar     ] │
│ Space 2:  [🌐] [Web Browsing         ] │
│ Space 3:  [💻] [Development          ] │
│ Space 4:  [🎨] [Design Tools         ] │
│ Space 5:  [🎵] [Music & Media        ] │
│ Space 6:  [💬] [Communication        ] │
│                                         │
│ Click emoji to change                   │
│                                         │
└─────────────────────────────────────────┘
```

**Quick Edit in HUD:**
- Right-click on Space button → "Edit Name & Emoji..."
- Shows popover with emoji picker and name field
- Save button updates settings

---

## Implementation Priority

### Phase 1: Essential (Complete for MVP)
1. ✅ Core HUD infrastructure
2. ✅ Space detection and switching
3. ✅ Display modes (mini/compact/expanded)
4. ⬜ **Settings button functionality** (Quick Settings popover)
5. ⬜ **Space name customization UI** (in Preferences)

### Phase 2: New Features (User Requested)
6. ⬜ **Emoji/Icon support** (data model + UI)
7. ⬜ **Note mode** (mode toggle + note editor)
8. ⬜ **Double-click behavior** (switch to Space in note mode)

### Phase 3: Polish & Enhancement
9. ⬜ Keyboard shortcuts (Arrow keys to navigate, Enter to switch)
10. ⬜ Right-click context menu (Edit, Remove emoji, etc.)
11. ⬜ Space thumbnails (screenshot preview)
12. ⬜ Auto-detect app names (suggest names based on apps in Space)
13. ⬜ Position presets (corners, edges)
14. ⬜ Custom hotkey configuration

---

## Technical Considerations

### Settings Button Implementation

**Recommended Approach: Quick Settings Popover**

**Pros:**
- Faster workflow (no window switch)
- Contextual settings right in HUD
- Still allows access to full Preferences

**Cons:**
- More complex UI state management
- Need to handle popover dismissal

**Implementation:**
```swift
@State private var showQuickSettings = false

Button(action: {
    showQuickSettings.toggle()
}) {
    Image(systemName: "gear")
        .font(.system(size: 10))
}
.popover(isPresented: $showQuickSettings, arrowEdge: .bottom) {
    SuperSpacesQuickSettings(viewModel: viewModel)
        .frame(width: 280, height: 200)
}
```

### Note Mode Implementation

**Data Storage:**
- Use `UserDefaults` for simple text notes
- Consider Core Data if notes become complex
- Auto-save on text change (debounced)

**UI State:**
- Mode toggle affects all Space buttons
- Visual indicator when in Note mode
- Show note icon on Spaces that have notes

**Performance:**
- Load notes lazily (only when needed)
- Cache loaded notes in memory
- Debounce save operations

### Emoji/Icon Implementation

**Storage:**
- Store as String (emoji characters)
- Fallback to SF Symbol names if needed
- Validate emoji on load (handle missing/invalid)

**UI Rendering:**
- Use `.font(.system(size:))` for emoji sizing
- Ensure emoji renders correctly in all display modes
- Handle emoji width variations

---

## Files to Create/Modify

### New Files Needed
1. `SuperSpacesQuickSettings.swift` - Quick settings popover
2. `SuperSpacesNoteEditor.swift` - Note editing UI
3. `SuperSpacesEmojiPicker.swift` - Emoji selection UI
4. `SuperSpacesPreferencesTab.swift` - Full preferences UI

### Files to Modify
1. `SuperSpacesHUDView.swift`
   - Add mode toggle (Space/Note)
   - Add emoji display
   - Add double-click handling
   - Wire up settings button
   
2. `SuperSpacesHUD.swift`
   - Add note management methods
   - Add emoji management methods
   
3. `SettingsManager.swift`
   - Add `spaceNotes: [Int: String]`
   - Add `spaceEmojis: [Int: String]`
   - Add UserDefaults keys
   
4. `PreferencesView.swift`
   - Add Super Spaces tab
   - Add name/emoji editor
   - Add note management

---

## User Experience Flow

### Settings Button Flow

**User clicks Settings button:**
1. Quick Settings popover appears
2. Shows:
   - Display mode picker
   - Auto-hide toggle
   - Position presets
   - "Edit Space Names..." button
3. Changes apply immediately
4. Click outside to dismiss

**User clicks "Edit Space Names...":**
1. Opens main Preferences window
2. Navigates to Super Spaces tab
3. Shows full customization interface
4. Can edit names, emojis, notes

### Note Mode Flow

**User switches to Note mode:**
1. Clicks "Note" in mode toggle
2. All Space buttons show note icon if note exists
3. Single click opens note editor
4. Double click switches to that Space

**User edits note:**
1. Clicks Space button in Note mode
2. Note editor appears (inline or popover)
3. Types note text
4. Auto-saves on blur/close
5. Can click "Switch to Space" to go there

### Emoji Selection Flow

**User adds emoji:**
1. Right-clicks Space button → "Edit..."
2. Popover shows emoji picker + name field
3. Clicks emoji from grid
4. Emoji appears on Space button
5. Saves automatically

---

## Testing Checklist

### Settings Button
- [ ] Button opens quick settings popover
- [ ] Display mode changes apply immediately
- [ ] Auto-hide toggle works
- [ ] "Edit Space Names" opens Preferences
- [ ] Popover dismisses correctly

### Note Mode
- [ ] Mode toggle switches between Space/Note
- [ ] Single click in Note mode opens editor
- [ ] Double click in Note mode switches Space
- [ ] Notes save correctly
- [ ] Notes persist across app restart
- [ ] Note icon shows on Spaces with notes

### Emoji/Icon
- [ ] Emoji picker shows curated list
- [ ] Selected emoji appears on Space button
- [ ] Emoji displays correctly in all modes
- [ ] Emoji persists across app restart
- [ ] Can remove emoji (set to nil)
- [ ] Emoji renders in header when current Space

---

## Estimated Implementation Time

### Settings Button: 2-3 hours
- Create quick settings view
- Wire up to preferences
- Test all interactions

### Note Mode: 4-6 hours
- Add mode toggle UI
- Create note editor
- Implement double-click
- Add note storage
- Test all flows

### Emoji Support: 3-4 hours
- Add emoji picker UI
- Update all display modes
- Add emoji to settings
- Test rendering

**Total: 9-13 hours** for all three features

---

## Recommendations

### Immediate Next Steps
1. **Settings Button** - Quick win, improves UX immediately
2. **Emoji Support** - Visual appeal, easy to implement
3. **Note Mode** - More complex, but high value

### Settings Button Decision
**Recommendation: Quick Settings Popover**
- Best UX (no context switch)
- Common settings accessible
- Still allows full preferences access

### Note Mode Design Decision
**Recommendation: Inline Note Editor**
- Keeps user in HUD context
- Faster workflow
- Less window management

### Emoji Picker Decision
**Recommendation: Custom Curated Grid**
- Faster than system picker
- Better UX
- Consistent design

---

*Analysis completed: January 21, 2026*  
*Ready for implementation*
