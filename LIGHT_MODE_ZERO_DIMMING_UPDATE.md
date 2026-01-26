# Light Mode Zero Dimming Update

**Date**: January 26, 2026  
**Status**: ✅ Complete

## Summary

Updated the default dimming levels for Light Mode to have **zero dimming** for all regular dimming modes, while keeping time decay dimming available (but OFF by default) for users who want it.

## Changes Made

### Light Mode Default Profile (`SettingsManager.swift`)

Updated `defaultLightMode()` function with the following changes:

**Regular Dimming Settings** (all set to 0%):
- `globalDimLevel`: `0.15` → `0.0` (0% - no screen dimming)
- `activeDimLevel`: `0.10` → `0.0` (0% - no dimming for active windows)
- `inactiveDimLevel`: `0.25` → `0.0` (0% - no dimming for inactive windows)

**Time Decay Dimming Settings** (kept configured, OFF by default):
- `inactivityDecayEnabled`: `false` (OFF by default, user can enable)
- `decayRate`: `0.01` (configured for users who enable it)
- `decayStartDelay`: `30.0` seconds
- `maxDecayDimLevel`: `0.6` (60% max - lower than dark mode's 80%)

**Other Settings** (unchanged):
- `isDimmingEnabled`: `false` (OFF by default)
- `superDimmingAutoEnabled`: `false` (no auto-adjustment)
- `autoHideEnabled`: `false` (OFF by default)
- `autoMinimizeEnabled`: `false` (OFF by default)

## Rationale

### Why Zero Dimming for Light Mode?

1. **Environment Context**: Light mode users are typically in well-lit environments where screen brightness is less of an issue
2. **User Expectations**: Users who choose light mode generally prefer brighter displays and don't need aggressive dimming
3. **Selective Use**: Users who want dimming in light mode can manually enable it, but it shouldn't be the default

### Why Keep Time Decay Dimming Available?

1. **Focus Feature**: Time decay dimming is a productivity/focus feature, not just a brightness control
2. **Cross-Mode Value**: Helps users focus by progressively dimming inactive windows, useful in any appearance mode
3. **User Choice**: It's OFF by default but available for users who want this focus enhancement
4. **Lower Maximum**: Set to 60% max decay (vs 80% in dark mode) for lighter visual impact

## Dark Mode Defaults (Unchanged)

For comparison, Dark Mode keeps its aggressive defaults:
- `globalDimLevel`: `0.25` (25%)
- `activeDimLevel`: `0.15` (15%)
- `inactiveDimLevel`: `0.35` (35%)
- `maxDecayDimLevel`: `0.8` (80%)
- `isDimmingEnabled`: `true` (ON by default)

## User Experience

### Light Mode Users Will See:
1. **No dimming by default** - clean, bright display
2. **All dimming features available** if they want to enable them
3. **Time decay dimming** available in Super Focus settings (OFF by default)
4. Settings save independently per appearance mode

### Dark Mode Users Will See:
1. **Aggressive dimming by default** - reduces eye strain from bright content
2. **All features work as before** - no changes to dark mode defaults

## Testing

✅ Build successful - no compilation errors  
✅ Profile system correctly loads appropriate defaults based on appearance mode  
✅ Reset to defaults function properly calls profile loading

## Files Modified

- `SuperDimmer-Mac-App/SuperDimmer/Settings/SettingsManager.swift`
  - Updated `defaultLightMode()` function (lines 303-331)
  - Added detailed comments explaining the design decision

## Next Steps

- Test with actual light mode usage to ensure zero dimming feels right
- Monitor user feedback on whether time decay dimming is useful in light mode
- Consider adding a "Quick Enable" button in light mode for users who want some dimming

## Technical Notes

- The profile system maintains separate settings for Light and Dark mode
- Changes only affect NEW users or users who reset to defaults
- Existing users' settings are preserved
- Profile switching happens automatically based on system appearance or user preference
