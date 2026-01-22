# SuperDimmer Logo and Branding

## Logo Design

### Concept
The SuperDimmer logo features a sun/moon hybrid symbol representing intelligent brightness control:
- **Left side**: Bright sun with rays (daytime, full brightness)
- **Right side**: Crescent moon (nighttime, dimmed)
- **Gradient**: Warm amber (#e8a838) to orange (#d4762c)
- **Background**: Dark (#0a0908) for consistency with app theme

### Symbolism
- **Sun/Moon Duality**: Represents adaptive brightness control across different lighting conditions
- **Circular Design**: Clean, modern, works at all sizes (16px to 1024px)
- **Warm Colors**: Matches the app's eye-comfort theme (warm amber accents reduce eye strain)
- **Professional**: macOS Big Sur/Ventura design language - rounded, gradient-rich, depth

## Files Generated

### Website Assets
Located in: `/SuperDimmer-Website/assets/`
- `logo-icon.png` (512x512) - Square icon for navigation, favicon base
- `logo-full.png` (800x width) - Full logo with "SuperDimmer" text and tagline
- `favicon.ico` (32x32) - Browser favicon

### App Assets
Located in: `/SuperDimmer-Mac-App/SuperDimmer/Resources/`
- `AppIcon-16.png` - Menu bar icon (retina: 32px actual)
- `AppIcon-32.png` - Menu bar icon standard
- `AppIcon-64.png` - Small icon
- `AppIcon-128.png` - Medium icon
- `AppIcon-256.png` - Large icon
- `AppIcon-512.png` - Retina icon
- `AppIcon-1024.png` - High-res source for App Store, marketing

### Source Files
Located in: `/Users/ak/.cursor/projects/.../assets/`
- `superdimmer-logo-icon.png` (original AI-generated)
- `superdimmer-logo-full.png` (original with text)

## Usage Guidelines

### Website
1. **Navigation**: Use `logo-icon.png` (28x28px) next to "SuperDimmer" text
2. **Hero Section**: Can use `logo-full.png` for marketing headers
3. **Favicon**: Automatically loads `favicon.ico`
4. **Meta Tags**: Apple touch icon uses `logo-icon.png`

### macOS App
1. **Menu Bar Icon**: Use `AppIcon-32.png` (appears at 16pt but needs 32px for retina)
2. **Dock Icon**: Xcode will use Asset Catalog (AppIcon.appiconset)
3. **About Window**: Can display larger sizes (256px, 512px)
4. **Notifications**: System uses appropriate size from iconset

### Color Scheme
- **Primary Gradient**: `#e8a838` → `#d4762c` → `#c45c3a`
- **Background**: `#0a0908` (dark charcoal)
- **Text on Logo**: `#f5f2eb` (warm off-white)

### Typography (for logo text)
- **Font**: Playfair Display (serif, elegant)
- **Tagline**: DM Sans (sans-serif, clean)
- **Weight**: Medium to Semi-Bold for primary text

## Removed Elements

### Emojis (Replaced with Icons/Images)
- ❌ `🖥️` (Super Spaces) → Real screenshot image
- ❌ `📊` (Progressive Dimming) → Real visualization image
- ❌ `⏸️` (Idle-Aware Timers) → SVG pause/play icon
- ❌ `☀️ → 🌙` (Color Temperature) → SVG sun/moon icons
- ❌ `📝` (Notes) → SVG document icon

All capability cards now use either:
1. Real product screenshots (Super Spaces, Progressive Dimming)
2. Professional SVG icons (Idle-Aware Timers, Color Temperature)
3. CSS animations (existing features)

## Next Steps for App Integration

### Xcode Asset Catalog
1. Open Xcode project
2. Navigate to `SuperDimmer/Resources/Assets.xcassets`
3. Select `AppIcon.appiconset`
4. Drag the generated `AppIcon-*.png` files to appropriate slots:
   - 16pt (1x): AppIcon-16.png
   - 16pt (2x): AppIcon-32.png
   - 32pt (1x): AppIcon-32.png
   - 32pt (2x): AppIcon-64.png
   - 128pt (1x): AppIcon-128.png
   - 128pt (2x): AppIcon-256.png
   - 256pt (1x): AppIcon-256.png
   - 256pt (2x): AppIcon-512.png
   - 512pt (1x): AppIcon-512.png
   - 512pt (2x): AppIcon-1024.png

### Menu Bar Icon
For menu bar, may want a simplified monochrome version:
- Extract just the sun/moon symbol
- Make it work in both light and dark menu bar modes
- System will apply tinting automatically

## Brand Consistency

All visual assets now follow the warm amber theme:
- No emojis (inconsistent across platforms)
- Professional icons and screenshots
- Consistent color palette
- Modern macOS design language
- Scalable vector graphics where possible

## File Sizes
- Website favicon: 2 KB
- Logo icon (512px): ~45 KB
- Logo full (800px): ~65 KB
- Each app icon size: 2-100 KB (depending on resolution)

Total: ~350 KB for complete icon set across all sizes and platforms.
