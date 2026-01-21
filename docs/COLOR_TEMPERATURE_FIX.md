# Color Temperature Fix - January 21, 2026

## Problem

The color temperature feature was not producing any visible color changes on the display, even when enabled and adjusted.

## Root Cause

The implementation was using `CGSetDisplayTransferByFormula` with the formula:
```
output = min + (max - min) * pow(input, gamma)
```

With parameters:
- min = 0.0
- gamma = 1.0
- max = RGB multiplier (e.g., 0.4 for blue at 3000K)

**Why this didn't work:**
While mathematically this should scale the output by the RGB multiplier, the formula-based approach doesn't reliably produce visible color shifts on macOS. The gamma formula is designed for gamma correction, not color tinting.

## Solution

Changed to use `CGSetDisplayTransferByTable` instead, which directly sets the gamma lookup table (LUT). This is the standard approach used by f.lux and other color temperature apps.

### How the Fix Works

1. **Create Gamma Tables**: Build arrays of 256 values (0.0 to 1.0) for each RGB channel
2. **Apply Gamma Curve**: Use standard 2.2 gamma curve: `output = (input / 255) ^ (1/2.2)`
3. **Apply Color Temperature**: Multiply each gamma-corrected value by the RGB multiplier
4. **Set Tables**: Use `CGSetDisplayTransferByTable` to apply the modified lookup tables

### Example at 3000K (Warm/Orange)

RGB multipliers from Kelvin-to-RGB algorithm:
- Red: 1.0 (full red)
- Green: 0.7 (reduced green)  
- Blue: 0.4 (heavily reduced blue)

The gamma table for blue channel will have all values scaled by 0.4, effectively reducing blue light output by 60% and creating the warm orange tint.

## Code Changes

**File**: `SuperDimmer-Mac-App/SuperDimmer/ColorTemperature/ColorTemperatureManager.swift`

**Function**: `applyTemperature(_ kelvin: Double)`

### Before
```swift
let result = CGSetDisplayTransferByFormula(
    displayID,
    0.0, 1.0, Float(rgb.red),    // Red: min, gamma, max
    0.0, 1.0, Float(rgb.green),  // Green: min, gamma, max
    0.0, 1.0, Float(rgb.blue)    // Blue: min, gamma, max
)
```

### After
```swift
// Create gamma tables (256 entries)
let tableSize = 256
var redTable = [CGGammaValue](repeating: 0, count: tableSize)
var greenTable = [CGGammaValue](repeating: 0, count: tableSize)
var blueTable = [CGGammaValue](repeating: 0, count: tableSize)

// Build the gamma tables with color temperature applied
let gamma = 2.2
for i in 0..<tableSize {
    let normalized = Double(i) / Double(tableSize - 1)
    let gammaAdjusted = pow(normalized, 1.0 / gamma)
    
    // Apply color temperature multipliers
    redTable[i] = Float(gammaAdjusted * rgb.red)
    greenTable[i] = Float(gammaAdjusted * rgb.green)
    blueTable[i] = Float(gammaAdjusted * rgb.blue)
}

// Apply the gamma tables
let result = CGSetDisplayTransferByTable(
    displayID,
    UInt32(tableSize),
    &redTable,
    &greenTable,
    &blueTable
)
```

## UI Improvement: Inverted Slider

After the initial fix, we discovered the slider direction was counterintuitive:
- Scientifically: Lower Kelvin = Warmer colors
- User expectation: Sliding RIGHT should make things warmer

**Solution**: Inverted the slider binding so:
- **Slider LEFT** (sun icon) = 6500K = Neutral/Standard display
- **Slider RIGHT** (flame icon) = 1900K = Warm/Orange/Red tint

The inversion is done in the UI layer using a computed binding:
```swift
Slider(value: Binding(
    get: { 8400 - settings.colorTemperature }, // Invert: 6500K→1900, 1900K→6500
    set: { settings.colorTemperature = 8400 - $0 }
), in: 1900...6500)
```

This keeps the internal Kelvin values scientifically correct while making the UI intuitive.

## Testing

To test the fix:

1. Launch SuperDimmer
2. Enable "Color Temperature" in the menu bar or preferences
3. Slide RIGHT toward the flame icon - display should become warm/orange/red
4. Slide LEFT toward the sun icon - display should return to neutral/standard
5. At full RIGHT (1900K internally), the display should be very warm/orange
6. At full LEFT (6500K internally), the display should be normal/neutral

## Technical Notes

- **Gamma value**: Using 2.2 as the standard gamma for macOS displays
- **Table size**: 256 entries is the standard for macOS gamma tables
- **RGB algorithm**: Using Tanner Helland's Kelvin-to-RGB algorithm based on CIE color matching functions
- **Restoration**: `CGDisplayRestoreColorSyncSettings()` properly restores original gamma when disabled

## References

- f.lux implementation approach
- Tanner Helland's Kelvin-to-RGB algorithm: https://tannerhelland.com/2012/09/18/convert-temperature-rgb-algorithm-code.html
- Apple's Core Graphics Display Services documentation
