# Super Spaces HUD Refinements Checklist
## Secondary Build Checklist for UX Improvements
### Version 1.0 | January 21, 2026

---

## 📋 Overview

This checklist addresses critical UX refinements for the Super Spaces HUD based on user feedback:
1. **Position Persistence**: Remember and restore HUD position across app restarts
2. **UI Artifact Fix**: Remove outline/faded artifact causing cropping issues
3. **Smart Button Sizing**: Equal-width buttons based on longest Space name
4. **Default Space Names**: Pre-populate with "Desktop 1", "Desktop 2", etc.
5. **Default Emojis**: Assign preset emojis for up to 16 Spaces
6. **Emoji Picker UI**: Replace text field with visual emoji picker
7. **Expanded Overview Mode**: New mode showing all Spaces with all notes simultaneously

---

## 🔧 PHASE 1: Position Persistence & UI Fixes

### 1.1 HUD Position Persistence ⬜
**Goal**: Save and restore HUD window position across app launches

#### Implementation Tasks:
- [ ] Add `lastHUDPosition` property to `SettingsManager`
  - [ ] Create `Keys.lastHUDPosition` enum case
  - [ ] Add `@Published var lastHUDPosition: CGPoint?` property
  - [ ] Add `didSet` observer to save to UserDefaults
  - [ ] Load from UserDefaults in `init()`

- [ ] Update `SuperSpacesHUD.swift` to save position
  - [ ] Add `NSWindowDelegate` conformance to `SuperSpacesHUD`
  - [ ] Implement `windowDidMove(_:)` delegate method
  - [ ] Save `frame.origin` to `SettingsManager.shared.lastHUDPosition`
  - [ ] Debounce saves (only save after 0.5s of no movement)

- [ ] Update `SuperSpacesHUD.swift` to restore position
  - [ ] In `init()`, check for `SettingsManager.shared.lastHUDPosition`
  - [ ] If position exists, use `setFrameOrigin(_:)` to restore
  - [ ] Validate position is on-screen (handle multi-monitor changes)
  - [ ] If invalid, fall back to default position (top-right)

- [ ] Add position validation helper
  - [ ] Create `isPositionValid(_:)` method
  - [ ] Check if position is within any screen's visible frame
  - [ ] Account for menu bar and dock areas
  - [ ] Return false if completely off-screen

#### Build & Test:
- [ ] 🔨 Build succeeds with no errors
- [ ] 🧪 Open HUD, move it, close app, reopen → HUD appears at last position
- [ ] 🧪 Move HUD to different screen, restart → Position persists
- [ ] 🧪 Disconnect external monitor, restart → HUD appears on main screen
- [ ] 🧪 Position persists across multiple app restarts

---

### 1.2 Fix UI Artifact (Outline/Faded Top) ⬜
**Goal**: Remove visual artifact causing cropping and obscuring settings button

#### Investigation Tasks:
- [ ] Identify source of outline artifact
  - [ ] Check `SuperSpacesHUD.swift` window styling
  - [ ] Review `NSPanel` configuration (level, styleMask, titlebarAppearsTransparent)
  - [ ] Check for duplicate/overlapping views in hierarchy
  - [ ] Inspect `VisualEffectView` configuration

- [ ] Likely culprits to check:
  - [ ] `panel.titlebarAppearsTransparent = true` (might be showing title bar)
  - [ ] `panel.styleMask` includes `.titled` or `.closable` (adds chrome)
  - [ ] Missing `.borderless` style mask
  - [ ] `contentView` frame not matching window frame
  - [ ] Extra padding or safe area insets

#### Fix Implementation:
- [ ] Update `SuperSpacesHUD.swift` window configuration
  - [ ] Set `styleMask = [.nonactivatingPanel, .borderless]`
  - [ ] Ensure `titlebarAppearsTransparent = true`
  - [ ] Set `titleVisibility = .hidden`
  - [ ] Set `isMovableByWindowBackground = true`
  - [ ] Remove any title bar accessories

- [ ] Update `SuperSpacesHUDView.swift` layout
  - [ ] Remove any top padding that might be accounting for title bar
  - [ ] Ensure header view is at true top of content
  - [ ] Check `safeAreaInsets` aren't adding unwanted space
  - [ ] Verify `frame(width:height:)` matches actual content

- [ ] Adjust window sizing
  - [ ] Recalculate `calculateHeight()` if title bar space removed
  - [ ] Ensure settings button is fully visible in all modes
  - [ ] Test with different display modes

#### Build & Test:
- [ ] 🔨 Build succeeds with no errors
- [ ] 🧪 No outline or faded artifact at top of HUD
- [ ] 🧪 Settings button fully visible in Compact mode
- [ ] 🧪 Settings button fully visible in Note mode
- [ ] 🧪 No cropping of any UI elements
- [ ] 🧪 Window has clean, borderless appearance
- [ ] 🧪 Window still draggable by background

---

## 🎨 PHASE 2: Smart Button Sizing & Default Content

### 2.1 Equal-Width Space Buttons ⬜
**Goal**: All Space buttons same width, sized to fit longest Space name

#### Implementation Tasks:
- [ ] Add dynamic width calculation to `SuperSpacesHUDView`
  - [ ] Create `calculateMaxButtonWidth()` method
  - [ ] Iterate through all Spaces and their names
  - [ ] Measure text width using `NSString.size(withAttributes:)`
  - [ ] Account for emoji width (fixed ~20pt)
  - [ ] Account for number width (fixed ~20pt)
  - [ ] Account for note indicator (4pt circle + spacing)
  - [ ] Add padding (horizontal: 20pt total)
  - [ ] Set minimum width (e.g., 100pt)
  - [ ] Set maximum width (e.g., 200pt)
  - [ ] Return calculated width

- [ ] Update `compactSpaceButton` to use fixed width
  - [ ] Store `maxButtonWidth` as `@State` variable
  - [ ] Calculate on `onAppear` and when Space names change
  - [ ] Apply `.frame(width: maxButtonWidth)` to button content
  - [ ] Remove `.frame(width: 20)` from number (let it flex)
  - [ ] Ensure emoji and name still layout correctly

- [ ] Update HUD width calculation
  - [ ] In `calculateWidth()`, use `maxButtonWidth * spaceCount`
  - [ ] Add spacing between buttons (8pt * (spaceCount - 1))
  - [ ] Add horizontal padding (16pt on each side = 32pt total)
  - [ ] Set minimum width (e.g., 400pt)
  - [ ] Set maximum width (e.g., 800pt)
  - [ ] Enable horizontal scrolling if exceeds max

- [ ] Handle dynamic updates
  - [ ] Recalculate when Space names change
  - [ ] Recalculate when emojis change
  - [ ] Animate width changes smoothly
  - [ ] Use `.animation(.spring())` on width changes

#### Build & Test:
- [ ] 🔨 Build succeeds with no errors
- [ ] 🧪 All Space buttons have equal width
- [ ] 🧪 Button width accommodates longest Space name
- [ ] 🧪 Short names don't create tiny buttons
- [ ] 🧪 Long names don't get truncated (up to max width)
- [ ] 🧪 Width updates when names are edited
- [ ] 🧪 Width updates when emojis are added/removed
- [ ] 🧪 Horizontal scrolling works if buttons exceed window width

---

### 2.2 Default Space Names ⬜
**Goal**: Pre-populate all Spaces with "Desktop 1", "Desktop 2", etc.

#### Implementation Tasks:
- [ ] Add default name generation to `SettingsManager`
  - [ ] Create `generateDefaultSpaceName(for:)` method
  - [ ] Return "Desktop \(spaceNumber)" format
  - [ ] Handle up to 16 Spaces

- [ ] Add character limit for Space names
  - [ ] Define `maxSpaceNameLength` constant (e.g., 30 characters)
  - [ ] Add validation in name setter
  - [ ] Truncate names that exceed limit
  - [ ] Show character counter in edit UI (e.g., "15/30")
  - [ ] Prevent typing beyond limit in TextField

- [ ] Update `getSpaceName(_:)` in `SuperSpacesHUDView`
  - [ ] Check if custom name exists in `settings.spaceNames`
  - [ ] If not, return `generateDefaultSpaceName(for: spaceNumber)`
  - [ ] Remove `?? "Desktop"` fallback (always return a name)

- [ ] Ensure defaults don't persist to UserDefaults
  - [ ] Only save to `spaceNames` dictionary when user edits
  - [ ] Default names are generated on-the-fly
  - [ ] This keeps UserDefaults clean (only stores customizations)

- [ ] Update UI to distinguish default vs custom names
  - [ ] Optional: Show default names in lighter color
  - [ ] Optional: Add "(default)" hint in edit mode
  - [ ] Ensure editing a default name saves it as custom

- [ ] Add character limit enforcement in all edit UIs
  - [ ] Inline editing in Note mode
  - [ ] Card editing in Overview mode
  - [ ] Show warning when approaching limit
  - [ ] Visual feedback (red text) when at limit

#### Build & Test:
- [ ] 🔨 Build succeeds with no errors
- [ ] 🧪 All Spaces show "Desktop 1", "Desktop 2", etc. by default
- [ ] 🧪 Default names appear immediately on first launch
- [ ] 🧪 Editing a default name saves it as custom
- [ ] 🧪 Clearing a custom name reverts to default
- [ ] 🧪 Default names don't clutter UserDefaults
- [ ] 🧪 Works correctly for 1-16 Spaces
- [ ] 🧪 Space names cannot exceed 30 characters
- [ ] 🧪 Character counter shows in edit mode
- [ ] 🧪 Cannot type beyond limit
- [ ] 🧪 Visual feedback when approaching/at limit

---

### 2.3 Default Space Emojis ⬜
**Goal**: Assign preset emojis to each Space (1-16) on first launch

#### Implementation Tasks:
- [ ] Define default emoji set
  - [ ] Create `defaultSpaceEmojis` constant array in `SettingsManager`
  - [ ] Choose 16 distinct, recognizable emojis:
    ```swift
    private let defaultSpaceEmojis = [
        "💻", // 1: Work/Computer
        "🌐", // 2: Web/Internet
        "📧", // 3: Email/Communication
        "🎨", // 4: Design/Creative
        "🎵", // 5: Music/Media
        "💬", // 6: Chat/Social
        "📊", // 7: Data/Analytics
        "📝", // 8: Notes/Writing
        "🎮", // 9: Gaming
        "📚", // 10: Reading/Learning
        "🏠", // 11: Personal/Home
        "🛠️", // 12: Tools/Utilities
        "📱", // 13: Mobile/Apps
        "🎬", // 14: Video/Entertainment
        "🔬", // 15: Research/Science
        "🌟"  // 16: Misc/Other
    ]
    ```

- [ ] Add default emoji generation method
  - [ ] Create `getDefaultEmoji(for spaceNumber: Int) -> String?`
  - [ ] Return emoji from array if index valid (1-16)
  - [ ] Return nil if spaceNumber > 16

- [ ] Update `getSpaceEmoji(_:)` in `SuperSpacesHUDView`
  - [ ] Check if custom emoji exists in `settings.spaceEmojis`
  - [ ] If not, return `settings.getDefaultEmoji(for: spaceNumber)`
  - [ ] Ensure default emojis appear immediately

- [ ] Ensure defaults don't persist to UserDefaults
  - [ ] Only save to `spaceEmojis` dictionary when user edits
  - [ ] Default emojis are generated on-the-fly
  - [ ] Keeps UserDefaults clean

- [ ] Handle emoji clearing
  - [ ] When user removes emoji, remove from `spaceEmojis` dict
  - [ ] This causes default emoji to show again
  - [ ] Add "Reset to Default" option in emoji picker

#### Build & Test:
- [ ] 🔨 Build succeeds with no errors
- [ ] 🧪 All Spaces (1-16) show default emojis on first launch
- [ ] 🧪 Default emojis are distinct and recognizable
- [ ] 🧪 Editing an emoji saves it as custom
- [ ] 🧪 Clearing a custom emoji reverts to default
- [ ] 🧪 Default emojis don't clutter UserDefaults
- [ ] 🧪 Works correctly for 1-16 Spaces
- [ ] 🧪 Spaces beyond 16 have no default emoji (or repeat pattern)

---

## 🎯 PHASE 3: Visual Emoji Picker

### 3.1 Replace Text Field with Emoji Picker ⬜
**Goal**: Click button to open visual emoji picker instead of typing

#### Implementation Tasks:
- [ ] Update inline editing UI in `noteDisplayView`
  - [ ] Replace emoji `TextField` with emoji `Button`
  - [ ] Button shows current emoji (or "➕" if none)
  - [ ] Button has same size/styling as before (50px)
  - [ ] Clicking button opens emoji picker popover

- [ ] Reuse existing `SuperSpacesEmojiPicker` component
  - [ ] Already exists from previous implementation
  - [ ] Shows categorized emoji grid
  - [ ] Has "Remove Emoji" option
  - [ ] Update to add "Reset to Default" option

- [ ] Add popover presentation
  - [ ] Add `@State private var showInlineEmojiPicker = false`
  - [ ] Add `.popover(isPresented: $showInlineEmojiPicker)`
  - [ ] Position popover below emoji button
  - [ ] Pass current emoji as binding
  - [ ] Update emoji when selected
  - [ ] Close popover after selection

- [ ] Update emoji button styling
  - [ ] Show current emoji in button
  - [ ] Add subtle border/background
  - [ ] Show hover effect
  - [ ] Add tooltip: "Click to change emoji"
  - [ ] Highlight when popover open

- [ ] Handle emoji selection
  - [ ] Update `editingSpaceEmoji` when emoji selected
  - [ ] Auto-save if not in full edit mode
  - [ ] Close popover
  - [ ] Update button display immediately

#### Build & Test:
- [ ] 🔨 Build succeeds with no errors
- [ ] 🧪 Clicking emoji button opens visual picker
- [ ] 🧪 Emoji picker shows categorized grid
- [ ] 🧪 Selecting emoji updates display immediately
- [ ] 🧪 "Reset to Default" shows default emoji for that Space
- [ ] 🧪 "Remove Emoji" clears to default
- [ ] 🧪 Popover closes after selection
- [ ] 🧪 Emoji button shows current emoji
- [ ] 🧪 Works in both display and edit modes

---

## 📊 PHASE 4: Expanded Overview Mode

### 4.1 Add Expanded Overview Mode ⬜
**Goal**: New mode showing all Spaces with all notes in a scrollable view

#### Design Specifications:
```
┌─────────────────────────────────────────────────────────────┐
│  Super Spaces Overview                           [−] [×]    │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────────────────────────────────────────────────┐   │
│  │ [1] 💻 Desktop 1                    [Edit] [Switch] │   │
│  │ ┌──────────────────────────────────────────────────┐ │   │
│  │ │ Note: Working on SuperDimmer HUD...              │ │   │
│  │ │                                                  │ │   │
│  │ └──────────────────────────────────────────────────┘ │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ [2] 🌐 Desktop 2                    [Edit] [Switch] │   │
│  │ ┌──────────────────────────────────────────────────┐ │   │
│  │ │ Note: (empty)                                    │ │   │
│  │ │                                                  │ │   │
│  │ └──────────────────────────────────────────────────┘ │   │
│  └──────────────────────────────────────────────────────┘   │
│  ... (all Spaces shown)                                     │
└─────────────────────────────────────────────────────────────┘
```

#### Implementation Tasks:
- [ ] Add new display mode enum case
  - [ ] Update `DisplayMode` enum: add `.overview`
  - [ ] Update mode cycling: Compact → Note → Overview → Compact
  - [ ] Update `displayModeFromString` and `displayModeToString`
  - [ ] Update Quick Settings picker to include Overview

- [ ] Create `overviewDisplayView` in `SuperSpacesHUDView`
  - [ ] Use `ScrollView(.vertical)` for scrollable content
  - [ ] Use `VStack` with spacing for Space cards
  - [ ] Show all Spaces from `viewModel.allSpaces`
  - [ ] Each Space gets a card with:
    - [ ] Header: Number + Emoji + Name
    - [ ] Edit button (opens inline editing)
    - [ ] Switch button (switches to that Space)
    - [ ] Note display/editor (always visible)
    - [ ] Character count
    - [ ] Clear button (if note exists)

- [ ] Create Space card component
  - [ ] Create `overviewSpaceCard(for:)` method
  - [ ] Card background with border
  - [ ] Highlight current Space with accent color
  - [ ] Compact layout for efficiency
  - [ ] Note editor always expanded (no toggle)
  - [ ] All notes editable simultaneously

- [ ] Handle note editing in overview
  - [ ] Each Space has its own note binding
  - [ ] Use `@State` dictionary to track editing states
  - [ ] Debounced auto-save for each note independently
  - [ ] Show save indicator when saving
  - [ ] No need to "select" a Space to edit its note

- [ ] Handle name/emoji editing in overview
  - [ ] Each card has "Edit" button
  - [ ] Clicking opens inline editing for that card
  - [ ] Only one card editable at a time
  - [ ] Use `@State var editingSpaceInOverview: Int?`
  - [ ] Show emoji picker and name field inline
  - [ ] Save/Cancel buttons

- [ ] Update window sizing for overview mode
  - [ ] In `calculateWidth()`: return 700px for overview
  - [ ] In `calculateHeight()`: calculate based on Space count
  - [ ] Base height: 180px (header + padding)
  - [ ] Per-Space height: 140px (card with note)
  - [ ] Max height: 600px (then scroll)
  - [ ] Animate size changes smoothly

- [ ] Add expand/collapse button
  - [ ] Add button to header or footer
  - [ ] Icon: `arrow.up.left.and.arrow.down.right` (expand)
  - [ ] Icon: `arrow.down.right.and.arrow.up.left` (collapse)
  - [ ] Toggles between last mode and overview
  - [ ] Tooltip: "Expand to show all Spaces"

#### Build & Test:
- [ ] 🔨 Build succeeds with no errors
- [ ] 🧪 Overview mode shows all Spaces in scrollable list
- [ ] 🧪 Each Space card shows number, emoji, name
- [ ] 🧪 All notes visible and editable simultaneously
- [ ] 🧪 Clicking "Switch" button switches to that Space
- [ ] 🧪 Clicking "Edit" button enables inline editing for that card
- [ ] 🧪 Current Space highlighted in overview
- [ ] 🧪 Scrolling works smoothly with many Spaces
- [ ] 🧪 Window resizes correctly when entering/exiting overview
- [ ] 🧪 Notes auto-save independently
- [ ] 🧪 Expand button toggles to/from overview mode

---

### 4.2 Overview Mode Polish ⬜
**Goal**: Refine overview mode UX and performance

#### Implementation Tasks:
- [ ] Add keyboard shortcuts for overview
  - [ ] `⌘E` - Toggle expand/overview mode
  - [ ] `⌘↑` / `⌘↓` - Navigate between Space cards
  - [ ] `Enter` - Switch to focused Space
  - [ ] `Tab` - Focus next note field

- [ ] Add visual polish
  - [ ] Smooth animations when expanding/collapsing
  - [ ] Card hover effects
  - [ ] Current Space card has subtle glow/shadow
  - [ ] Empty notes show placeholder text
  - [ ] Loading state if many Spaces

- [ ] Optimize performance
  - [ ] Lazy load Space cards if > 10 Spaces
  - [ ] Debounce note saves per-Space
  - [ ] Batch UserDefaults writes
  - [ ] Use `LazyVStack` instead of `VStack`

- [ ] Add bulk actions (optional)
  - [ ] "Clear All Notes" button (with confirmation)
  - [ ] "Reset All Names" button (with confirmation)
  - [ ] "Export Notes" button (save to file)

#### Build & Test:
- [ ] 🔨 Build succeeds with no errors
- [ ] 🧪 Keyboard shortcuts work in overview mode
- [ ] 🧪 Animations are smooth and polished
- [ ] 🧪 Performance good with 16 Spaces
- [ ] 🧪 No lag when typing in multiple notes
- [ ] 🧪 Current Space clearly highlighted
- [ ] 🧪 Bulk actions work correctly (if implemented)

---

## 🎯 PHASE 5: Integration & Testing

### 5.1 Update Quick Settings ⬜
- [ ] Add Overview mode to display mode picker
- [ ] Update position presets to work with all modes
- [ ] Test all settings with all 3 modes

### 5.2 Update Settings Manager ⬜
- [ ] Ensure all new settings persist correctly
- [ ] Add migration for existing users (if needed)
- [ ] Test reset to defaults includes new settings

### 5.3 Comprehensive Testing ⬜
- [ ] Test with 1 Space (minimum)
- [ ] Test with 16 Spaces (maximum)
- [ ] Test with very long Space names
- [ ] Test with no emojis
- [ ] Test with all emojis customized
- [ ] Test position persistence across restarts
- [ ] Test on multiple monitors
- [ ] Test with external monitor disconnect/reconnect
- [ ] Test all keyboard shortcuts
- [ ] Test all mouse interactions
- [ ] Test memory usage with many notes

### 5.4 Documentation Updates ⬜
- [ ] Update BUILD_CHECKLIST.md with completion status
- [ ] Document new features in README
- [ ] Add screenshots of new modes
- [ ] Update keyboard shortcuts documentation

---

## 📝 Notes

### Default Emoji Rationale:
The 16 default emojis were chosen to represent common desktop use cases:
- Work/productivity (💻, 📧, 📝, 📊)
- Creative/media (🎨, 🎵, 🎬)
- Communication (💬, 📱)
- Learning/research (📚, 🔬)
- Entertainment (🎮, 🌐)
- Organization (🛠️, 🏠, 🌟)

### UI Artifact Investigation:
The outline/faded artifact is likely caused by:
1. NSPanel showing title bar chrome despite `titlebarAppearsTransparent = true`
2. Missing `.borderless` in `styleMask`
3. Safe area insets adding unwanted top padding

### Character Limits:
**Space Names**: 30 characters maximum
- Rationale: Long enough for descriptive names ("Development & Testing")
- Short enough to fit in buttons without excessive width
- Prevents UI layout issues
- Default names ("Desktop 1") are well within limit

**Space Notes**: 500 characters maximum (already implemented)
- Sufficient for reminders and quick notes
- Prevents performance issues with large text

### Performance Considerations:
- Overview mode with 16 Spaces showing 16 TextEditors could be heavy
- Use `LazyVStack` to defer rendering off-screen cards
- Debounce note saves to avoid excessive UserDefaults writes
- Consider pagination if > 16 Spaces supported in future

---

## ✅ Completion Criteria

This checklist is complete when:
- [ ] All checkboxes marked `[x]`
- [ ] All build checks pass
- [ ] All test checks pass
- [ ] HUD position persists across restarts
- [ ] No UI artifacts or cropping issues
- [ ] All Space buttons equal width, sized to longest name
- [ ] All Spaces have default names and emojis
- [ ] Emoji picker is visual (not text field)
- [ ] Overview mode shows all Spaces with all notes
- [ ] All features work smoothly together
- [ ] User feedback addressed completely

---

**Last Updated**: January 21, 2026
**Status**: Ready for Implementation
**Estimated Time**: 2-3 days
