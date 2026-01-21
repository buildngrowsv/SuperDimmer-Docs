# Super Spaces HUD - Settings Button Design
## What Should the Settings Button Do?

**Date:** January 21, 2026  
**Context:** Settings button exists in HUD footer but currently has TODO comment

---

## Recommendation: Quick Settings Popover ⭐

### Why This Approach?

**Best User Experience:**
- No context switch (stays in HUD)
- Instant access to common settings
- Still allows full preferences access
- Faster workflow

**Similar to:**
- Spotlight settings gear icon
- Raycast preferences shortcut
- macOS Control Center items

---

## Quick Settings Popover Design

### Visual Layout

```
┌────────────────────────────────┐
│ Super Spaces Settings          │
├────────────────────────────────┤
│                                │
│ Display Mode:                  │
│ ○ Mini  ● Compact  ○ Expanded │
│                                │
│ ☐ Auto-hide after switching    │
│                                │
│ Position:                      │
│ ┌────┬────┐                   │
│ │ TL │ TR │  ← Click to move  │
│ ├────┼────┤                   │
│ │ BL │ BR │                   │
│ └────┴────┘                   │
│                                │
│ ─────────────────────────────  │
│                                │
│ [Edit Space Names & Emojis...] │
│                                │
└────────────────────────────────┘
```

### Settings Included

1. **Display Mode Picker**
   - Mini (arrows only)
   - Compact (numbered buttons) ← Default
   - Expanded (grid with names)
   - Changes apply immediately

2. **Auto-Hide Toggle**
   - When enabled: HUD hides after switching Space
   - When disabled: HUD stays visible
   - Useful for quick Space hopping

3. **Position Presets**
   - Top-Left (TL)
   - Top-Right (TR) ← Default
   - Bottom-Left (BL)
   - Bottom-Right (BR)
   - Click to instantly reposition HUD

4. **Full Preferences Link**
   - "Edit Space Names & Emojis..." button
   - Opens main Preferences window
   - Navigates to Super Spaces tab
   - For detailed customization

---

## Implementation

### Code Structure

```swift
// SuperSpacesQuickSettings.swift
struct SuperSpacesQuickSettings: View {
    @ObservedObject var viewModel: SuperSpacesViewModel
    @EnvironmentObject var settings: SettingsManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            Text("Super Spaces Settings")
                .font(.headline)
            
            Divider()
            
            // Display Mode
            VStack(alignment: .leading, spacing: 8) {
                Text("Display Mode")
                    .font(.subheadline)
                
                Picker("", selection: $settings.superSpacesDisplayMode) {
                    Text("Mini").tag("mini")
                    Text("Compact").tag("compact")
                    Text("Expanded").tag("expanded")
                }
                .pickerStyle(.segmented)
            }
            
            // Auto-hide
            Toggle("Auto-hide after switching", isOn: $settings.superSpacesAutoHide)
                .font(.subheadline)
            
            // Position presets
            VStack(alignment: .leading, spacing: 8) {
                Text("Position")
                    .font(.subheadline)
                
                HStack(spacing: 8) {
                    Button("TL") { repositionHUD(.topLeft) }
                        .frame(maxWidth: .infinity)
                    Button("TR") { repositionHUD(.topRight) }
                        .frame(maxWidth: .infinity)
                }
                HStack(spacing: 8) {
                    Button("BL") { repositionHUD(.bottomLeft) }
                        .frame(maxWidth: .infinity)
                    Button("BR") { repositionHUD(.bottomRight) }
                        .frame(maxWidth: .infinity)
                }
            }
            
            Divider()
            
            // Full preferences link
            Button("Edit Space Names & Emojis...") {
                openFullPreferences()
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .frame(width: 280)
    }
    
    private func repositionHUD(_ position: HUDPosition) {
        SuperSpacesHUD.shared.reposition(to: position)
    }
    
    private func openFullPreferences() {
        NotificationCenter.default.post(
            name: NSNotification.Name("OpenPreferences"),
            object: nil,
            userInfo: ["tab": "superSpaces"]
        )
    }
}
```

### Integration in HUD

```swift
// In SuperSpacesHUDView.swift footer

@State private var showQuickSettings = false

private var footerView: some View {
    HStack {
        Text("\(viewModel.allSpaces.count) Spaces")
            .font(.system(size: 10))
            .foregroundColor(.secondary)
        
        Spacer()
        
        Button(action: {
            showQuickSettings.toggle()
        }) {
            Image(systemName: "gear")
                .font(.system(size: 10))
        }
        .buttonStyle(.plain)
        .help("Settings")
        .popover(isPresented: $showQuickSettings, arrowEdge: .bottom) {
            SuperSpacesQuickSettings(viewModel: viewModel)
                .environmentObject(SettingsManager.shared)
        }
    }
}
```

---

## Alternative Approaches (Not Recommended)

### Option B: Open Full Preferences Window

**Pros:**
- Simpler implementation
- All settings in one place
- No popover state management

**Cons:**
- Context switch (leaves HUD)
- Slower workflow
- More clicks required
- Window management overhead

**When to use:**
- For complex settings
- For settings that need more space
- For settings that require explanation

**Verdict:** ❌ Not ideal for quick adjustments

---

### Option C: Inline Settings in HUD

**Pros:**
- No popover needed
- Always visible
- Very fast access

**Cons:**
- Takes up HUD space
- Clutters interface
- Less room for Spaces
- Not scalable

**When to use:**
- For 1-2 critical settings
- When space is not a concern
- For always-visible toggles

**Verdict:** ❌ Makes HUD too busy

---

## User Flow

### Quick Settings Flow

1. **User clicks gear icon** in HUD footer
2. **Popover appears** below button
3. **User adjusts settings:**
   - Change display mode → HUD resizes immediately
   - Toggle auto-hide → Setting saves
   - Click position preset → HUD moves
4. **User clicks outside** or presses Esc
5. **Popover dismisses** automatically

**Time to adjust setting:** ~2 seconds ⚡

### Full Preferences Flow

1. **User clicks "Edit Space Names..."** in popover
2. **Main Preferences window opens**
3. **Super Spaces tab selected** automatically
4. **User customizes:**
   - Edit Space names
   - Add/change emojis
   - Edit notes
   - Advanced settings
5. **User closes Preferences**
6. **Changes apply** to HUD

**Time to customize:** ~30 seconds

---

## Settings Categories

### Quick Settings (Popover)
✅ Display mode  
✅ Auto-hide  
✅ Position presets  
✅ Link to full preferences

### Full Preferences (Window)
✅ Space names  
✅ Space emojis  
✅ Space notes  
✅ Enable/disable feature  
✅ Launch on startup  
✅ Keyboard shortcuts  
✅ Advanced options

---

## Implementation Priority

### Phase 1: Quick Settings Popover
1. Create `SuperSpacesQuickSettings.swift`
2. Add popover to Settings button
3. Wire up display mode picker
4. Wire up auto-hide toggle
5. Add position preset buttons
6. Add full preferences link

**Estimated time:** 2-3 hours

### Phase 2: Full Preferences Tab
1. Create `SuperSpacesPreferencesTab.swift`
2. Add to main PreferencesView
3. Add Space name editor
4. Add emoji picker
5. Add note editor
6. Add advanced settings

**Estimated time:** 4-6 hours

---

## Testing Checklist

### Quick Settings Popover
- [ ] Gear icon shows in footer
- [ ] Clicking gear opens popover
- [ ] Popover positioned correctly (below button)
- [ ] Display mode picker works
- [ ] Changes apply immediately to HUD
- [ ] Auto-hide toggle saves
- [ ] Position presets move HUD
- [ ] "Edit Names..." opens Preferences
- [ ] Clicking outside dismisses popover
- [ ] Esc key dismisses popover
- [ ] Popover doesn't block HUD interaction

### Full Preferences Integration
- [ ] Preferences window opens
- [ ] Super Spaces tab selected
- [ ] All settings visible
- [ ] Changes save correctly
- [ ] Changes apply to HUD
- [ ] Window closes cleanly

---

## Conclusion

**Recommended Implementation: Quick Settings Popover**

**Why:**
- Best user experience (no context switch)
- Fast access to common settings
- Clean, uncluttered interface
- Still allows full customization
- Industry standard pattern (Spotlight, Raycast, etc.)

**What to include:**
- Display mode picker
- Auto-hide toggle
- Position presets
- Link to full preferences

**What NOT to include:**
- Space name editor (too complex)
- Emoji picker (needs more space)
- Note editor (separate feature)
- Advanced settings (rarely changed)

**Next Steps:**
1. Implement quick settings popover
2. Test all interactions
3. Create full preferences tab
4. Document user flows

---

*Design completed: January 21, 2026*  
*Ready for implementation*
