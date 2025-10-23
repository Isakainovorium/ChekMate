# SVG Icons for ChekMate

This directory contains all SVG icon assets used throughout the ChekMate app.

## Why SVG Icons?

### Advantages over PNG/Raster Icons
1. **Scalability** - Perfect quality at any size (no pixelation)
2. **File Size** - Typically 50-90% smaller than PNG equivalents
3. **Theme Support** - Easy color customization via code
4. **Accessibility** - Better semantic labeling support
5. **Performance** - Faster rendering and lower memory usage

### Performance Benefits
- **PNG Icon Set (100 icons @ 3 sizes):** ~2-3 MB
- **SVG Icon Set (100 icons):** ~200-400 KB
- **Memory Savings:** 80-90% reduction
- **Load Time:** 3-5x faster

## Icon Categories

### Navigation Icons (10 icons)
- `home.svg` / `home_filled.svg`
- `explore.svg` / `explore_filled.svg`
- `messages.svg` / `messages_filled.svg`
- `profile.svg` / `profile_filled.svg`
- `notifications.svg` / `notifications_filled.svg`

### Action Icons (15 icons)
- `like.svg` / `like_filled.svg`
- `comment.svg`
- `share.svg`
- `bookmark.svg` / `bookmark_filled.svg`
- `send.svg`
- `add.svg`
- `search.svg`
- `filter.svg`
- `settings.svg`
- `edit.svg`
- `delete.svg`
- `more.svg`
- `close.svg`
- `back.svg`
- `forward.svg`

### Media Icons (9 icons)
- `camera.svg`
- `gallery.svg`
- `video.svg`
- `microphone.svg`
- `play.svg`
- `pause.svg`
- `volume.svg`
- `mute.svg`
- `image.svg`

### Social Icons (8 icons)
- `match.svg`
- `swipe_right.svg`
- `swipe_left.svg`
- `super_like.svg`
- `rewind.svg`
- `boost.svg`
- `verified.svg`
- `premium.svg`

### Profile Icons (8 icons)
- `age.svg`
- `location.svg`
- `height.svg`
- `education.svg`
- `work.svg`
- `interests.svg`
- `lifestyle.svg`
- `relationship_goal.svg`

### Utility Icons (20 icons)
- `info.svg`
- `help.svg`
- `warning.svg`
- `error.svg`
- `success.svg`
- `lock.svg` / `unlock.svg`
- `eye.svg` / `eye_off.svg`
- `calendar.svg`
- `clock.svg`
- `star.svg` / `star_filled.svg`
- `flag.svg`
- `block.svg`
- `link.svg`
- `copy.svg`
- `download.svg`
- `upload.svg`
- `refresh.svg`

### Emoji/Reaction Icons (6 icons)
- `smile.svg`
- `laugh.svg`
- `love_emoji.svg`
- `sad.svg`
- `angry.svg`
- `wow.svg`

### Brand Icons (3 icons)
- `logo.svg`
- `logo_small.svg`
- `wordmark.svg`

**Total:** ~80 icons

## Where to Find Free SVG Icons

### Recommended Sources

1. **Heroicons** (https://heroicons.com/)
   - MIT License (free for commercial use)
   - Clean, modern design
   - Outline and solid variants
   - Perfect for social apps

2. **Feather Icons** (https://feathericons.com/)
   - MIT License
   - Minimalist, consistent style
   - 280+ icons
   - Great for utility icons

3. **Ionicons** (https://ionic.io/ionicons)
   - MIT License
   - iOS and Material Design variants
   - 1,300+ icons
   - Excellent for mobile apps

4. **Material Symbols** (https://fonts.google.com/icons)
   - Apache 2.0 License
   - Google's official icon set
   - Outlined, rounded, sharp variants
   - 2,500+ icons

5. **Tabler Icons** (https://tabler-icons.io/)
   - MIT License
   - 4,200+ icons
   - Consistent 24x24 grid
   - Modern, clean design

6. **Lucide** (https://lucide.dev/)
   - ISC License
   - Fork of Feather Icons
   - 1,000+ icons
   - Community-driven

### Premium Sources (Optional)

1. **Streamline** (https://www.streamlinehq.com/)
   - Paid, but high quality
   - 100,000+ icons
   - Consistent design system

2. **Nucleo** (https://nucleoapp.com/)
   - One-time purchase
   - 30,000+ icons
   - Professional quality

## Icon Guidelines

### Design Specifications
- **Size:** 24x24px viewBox (standard)
- **Stroke Width:** 2px (consistent)
- **Style:** Outline or filled (not mixed)
- **Color:** Single color (black #000000)
- **Format:** SVG 1.1 or SVG 2.0

### File Naming Convention
- Use lowercase with underscores: `icon_name.svg`
- Filled variants: `icon_name_filled.svg`
- Active states: `icon_name_active.svg`
- Examples:
  - `home.svg` (outline)
  - `home_filled.svg` (filled/active)

### Optimization
Before adding icons to the project, optimize them:

1. **SVGO** (Command Line)
   ```bash
   npm install -g svgo
   svgo icon_name.svg
   ```

2. **SVGOMG** (Web Tool)
   - Visit: https://jakearchibald.github.io/svgomg/
   - Upload SVG
   - Adjust settings
   - Download optimized version

3. **Optimization Settings**
   - Remove comments
   - Remove metadata
   - Remove hidden elements
   - Merge paths (when possible)
   - Round/rewrite numbers
   - Remove unnecessary attributes

### Color Customization
Icons should be designed in black (#000000) so they can be easily recolored in code:

```dart
SvgIcon(
  AppIcons.home,
  color: Theme.of(context).primaryColor,
)
```

## Usage in Code

### Basic Usage
```dart
import 'package:flutter_chekmate/shared/ui/icons/svg_icon.dart';
import 'package:flutter_chekmate/shared/ui/icons/app_icons.dart';

// Simple icon
SvgIcon(AppIcons.home, size: 24)

// Colored icon
SvgIcon(
  AppIcons.like,
  size: 24,
  color: Colors.red,
)

// Themed icon (adapts to light/dark mode)
ThemedSvgIcon(AppIcons.settings, size: 24)
```

### Icon Button
```dart
SvgIconButton(
  assetPath: AppIcons.share,
  onPressed: () => sharePost(),
  tooltip: 'Share',
)
```

### Icon with Badge
```dart
SvgIconWithBadge(
  assetPath: AppIcons.notifications,
  badgeCount: 5,
  showBadge: true,
)
```

### Animated Icon
```dart
AnimatedSvgIcon(
  AppIcons.like,
  onTap: () => likePost(),
)
```

## Adding New Icons

### Step 1: Download Icon
1. Visit one of the recommended sources
2. Search for the icon you need
3. Download as SVG

### Step 2: Optimize
1. Use SVGO or SVGOMG to optimize
2. Ensure viewBox is 24x24
3. Remove unnecessary attributes
4. Ensure color is black (#000000)

### Step 3: Add to Project
1. Save to `assets/icons/` directory
2. Use proper naming convention
3. Add path to `lib/shared/ui/icons/app_icons.dart`

### Step 4: Update Constants
```dart
// In app_icons.dart
static const String newIcon = '$_basePath/new_icon.svg';
```

### Step 5: Test
```dart
// Test in your widget
SvgIcon(AppIcons.newIcon, size: 24)
```

## Testing Icons

### Visual Testing
1. Test in light and dark themes
2. Test at different sizes (16, 24, 32, 48)
3. Test with different colors
4. Test on different screen densities

### Performance Testing
1. Check load time
2. Monitor memory usage
3. Test with many icons on screen

## Troubleshooting

### Icon Not Displaying
- Check file path in `app_icons.dart`
- Verify file exists in `assets/icons/`
- Ensure `pubspec.yaml` includes `assets/icons/`
- Run `flutter pub get`

### Icon Color Not Changing
- Ensure SVG uses `fill="currentColor"` or `fill="#000000"`
- Remove hardcoded colors from SVG
- Use `colorFilter` parameter

### Icon Looks Blurry
- Check viewBox size (should be 24x24)
- Ensure SVG is properly optimized
- Verify size parameter matches design

## License

All icons in this directory should be properly licensed for commercial use.
Document the source and license for each icon set used.

## Support

For issues with SVG icons:
1. Check this README
2. Verify icon optimization
3. Test with a known-working icon
4. Check Flutter console for errors

