# Lottie Animations for ChekMate

This directory contains Lottie animation files (.json) used throughout the ChekMate app.

## Required Animation Files

### Loading Animations
- `loading.json` - General loading spinner
- `loading_dots.json` - Dots loading animation
- `loading_circle.json` - Circle loading animation

### Success/Error States
- `success.json` - Success checkmark animation
- `error.json` - Error animation
- `warning.json` - Warning animation

### Social Interactions
- `like.json` - Like/heart animation (for posts)
- `heart.json` - Heart animation (alternative)
- `favorite.json` - Favorite/star animation
- `bookmark.json` - Bookmark animation

### Empty States
- `empty_box.json` - Empty box animation
- `no_data.json` - No data available
- `no_messages.json` - No messages
- `no_notifications.json` - No notifications

### Actions
- `swipe_up.json` - Swipe up indicator
- `swipe_left.json` - Swipe left indicator
- `swipe_right.json` - Swipe right indicator
- `checkmark.json` - Checkmark animation

### Celebrations
- `confetti.json` - Confetti celebration
- `celebration.json` - General celebration

## Where to Find Lottie Animations

### Free Sources
1. **LottieFiles** (https://lottiefiles.com/)
   - Largest collection of free Lottie animations
   - Search for specific animations by keyword
   - Download as JSON files

2. **IconScout** (https://iconscout.com/lottie-animations)
   - High-quality free and premium animations
   - Curated collections

3. **Lordicon** (https://lordicon.com/)
   - Animated icons in Lottie format
   - Free tier available

### Recommended Searches on LottieFiles

For each animation type, search for:

**Loading:**
- "loading spinner"
- "loading dots"
- "circular loading"

**Success/Error:**
- "success checkmark"
- "error cross"
- "warning alert"

**Social:**
- "heart like"
- "bookmark save"
- "favorite star"

**Empty States:**
- "empty box"
- "no data"
- "empty state"

**Actions:**
- "swipe gesture"
- "checkmark done"
- "tap gesture"

**Celebrations:**
- "confetti"
- "celebration"
- "party"

## Installation Instructions

1. Download the desired Lottie animation from LottieFiles or other sources
2. Save the `.json` file to this directory (`assets/animations/`)
3. Use the exact filename as specified in the list above
4. The animations are already configured in `pubspec.yaml` under assets

## Usage in Code

```dart
import 'package:flutter_chekmate/shared/ui/animations/lottie_animations.dart';

// Simple usage
LottieAnimation.asset(
  LottieAnimations.loading,
  width: 100,
  height: 100,
)

// With custom controls
LottieAnimation.asset(
  LottieAnimations.success,
  width: 150,
  height: 150,
  repeat: false,
  onLoaded: (composition) {
    print('Animation loaded!');
  },
)

// Pre-built widgets
LoadingAnimation(size: 100, message: 'Loading...')
SuccessAnimation(size: 150, message: 'Success!')
ErrorAnimation(size: 150, message: 'Error occurred')

// Interactive animations
AnimatedLikeButton(
  isLiked: true,
  likeCount: 42,
  onTap: () {},
)

AnimatedBookmarkButton(
  isBookmarked: false,
  onTap: () {},
)
```

## Animation Guidelines

### Performance
- Keep animation file sizes under 100KB when possible
- Use simple animations for frequently used components (like buttons)
- Use complex animations sparingly for special moments

### Design Consistency
- Match animations to app's color scheme
- Ensure animations work in both light and dark modes
- Keep animation durations reasonable (0.5-2 seconds)

### Accessibility
- Don't rely solely on animations to convey information
- Provide text alternatives for important animations
- Consider users with motion sensitivity (provide option to disable)

## Customization

To customize animation colors dynamically:

```dart
Lottie.asset(
  'assets/animations/loading.json',
  delegates: LottieDelegates(
    values: [
      ValueDelegate.color(
        ['**'],
        value: Theme.of(context).primaryColor,
      ),
    ],
  ),
)
```

## Testing

Test animations on:
- Different screen sizes (phone, tablet)
- Light and dark themes
- Different performance levels (low-end devices)
- With reduced motion settings enabled

## License

Ensure all downloaded animations have appropriate licenses for commercial use.
LottieFiles provides license information for each animation.

## Support

For issues with animations:
1. Check the animation file is valid JSON
2. Verify the file path in pubspec.yaml
3. Test with a simple Lottie animation first
4. Check console for error messages

## Future Additions

Consider adding animations for:
- Match/connection success
- Message sent/received
- Profile completion
- Achievement unlocked
- New follower
- Story posted
- Video uploaded

