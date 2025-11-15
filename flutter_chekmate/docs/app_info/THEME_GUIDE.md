# ChekMate Theme Guide
## Complete Design System Documentation

**Version:** 1.0  
**Last Updated:** 2025-10-09  
**Status:** ✅ Complete

---

## 📋 TABLE OF CONTENTS

1. [Overview](#overview)
2. [Colors](#colors)
3. [Typography](#typography)
4. [Spacing](#spacing)
5. [Components](#components)
6. [Usage Examples](#usage-examples)
7. [Best Practices](#best-practices)

---

## 🎨 OVERVIEW

The ChekMate design system is built on three core files:

- **`app_colors.dart`** - Complete color palette
- **`app_spacing.dart`** - Spacing system (4px base unit)
- **`app_theme.dart`** - Material 3 theme configuration

All theme elements match the Figma design exactly.

---

## 🌈 COLORS

### Import
```dart
import 'package:flutter_chekmate/core/theme/app_colors.dart';
```

### Primary Colors
```dart
AppColors.primary    // #FF6B35 (Orange) - Main brand color
AppColors.pink       // #FF8FA3 (Pink) - Secondary brand color
```

### Neutral Colors
```dart
AppColors.surface       // #FFFFFF (White) - Card backgrounds
AppColors.background    // #F8F9FA (Light Gray) - Page backgrounds
AppColors.textPrimary   // #1A1A1A (Dark Gray) - Main text
AppColors.textSecondary // #6B7280 (Medium Gray) - Secondary text
AppColors.border        // #E5E7EB (Light Gray) - Borders
```

### Status Colors
```dart
AppColors.error    // #EF4444 (Red) - Errors
AppColors.success  // #10B981 (Green) - Success states
AppColors.warning  // #F59E0B (Amber) - Warnings
AppColors.info     // #3B82F6 (Blue) - Information
```

### Gradients
```dart
AppColors.primaryGradient  // Orange to Pink gradient
AppColors.surfaceGradient  // White to light gray gradient
```

### Usage Example
```dart
Container(
  color: AppColors.surface,
  child: Text(
    'Hello',
    style: TextStyle(color: AppColors.textPrimary),
  ),
)
```

---

## ✍️ TYPOGRAPHY

### Import
Typography is automatically available through `Theme.of(context).textTheme`.

### Text Styles

#### Headings
```dart
// H1 - 32px, Bold
Text('Heading 1', style: Theme.of(context).textTheme.displayLarge)

// H2 - 24px, Bold
Text('Heading 2', style: Theme.of(context).textTheme.displaySmall)

// H3 - 20px, SemiBold
Text('Heading 3', style: Theme.of(context).textTheme.headlineMedium)
```

#### Body Text
```dart
// Body - 14px, Regular
Text('Body text', style: Theme.of(context).textTheme.bodyMedium)

// Small - 12px, Regular
Text('Small text', style: Theme.of(context).textTheme.bodySmall)
```

#### Labels
```dart
// Button text - 14px, Medium
Text('Button', style: Theme.of(context).textTheme.labelLarge)

// Caption - 12px, Medium
Text('Caption', style: Theme.of(context).textTheme.labelMedium)
```

### Font Family
All text uses **Inter** font from Google Fonts.

### Usage Example
```dart
Column(
  children: [
    Text(
      'Welcome to ChekMate',
      style: Theme.of(context).textTheme.displayLarge,
    ),
    Text(
      'Find your perfect match',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: AppColors.textSecondary,
      ),
    ),
  ],
)
```

---

## 📏 SPACING

### Import
```dart
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
```

### Spacing Scale (4px base unit)
```dart
AppSpacing.xs   // 4px
AppSpacing.sm   // 8px
AppSpacing.md   // 16px
AppSpacing.lg   // 24px
AppSpacing.xl   // 32px
AppSpacing.xxl  // 48px
```

### Padding Helpers
```dart
// All sides
AppSpacing.paddingXS   // EdgeInsets.all(4)
AppSpacing.paddingSM   // EdgeInsets.all(8)
AppSpacing.paddingMD   // EdgeInsets.all(16)
AppSpacing.paddingLG   // EdgeInsets.all(24)
AppSpacing.paddingXL   // EdgeInsets.all(32)

// Horizontal only
AppSpacing.paddingHorizontalMD  // EdgeInsets.symmetric(horizontal: 16)

// Vertical only
AppSpacing.paddingVerticalMD    // EdgeInsets.symmetric(vertical: 16)
```

### Common Patterns
```dart
AppSpacing.pagePadding      // 16px horizontal, 24px vertical
AppSpacing.cardPadding      // 16px all sides
AppSpacing.listItemPadding  // 16px horizontal, 12px vertical
AppSpacing.buttonPadding    // 24px horizontal, 12px vertical
AppSpacing.inputPadding     // 16px horizontal, 12px vertical
```

### Border Radius
```dart
AppSpacing.radiusSM   // BorderRadius.circular(8)
AppSpacing.radiusMD   // BorderRadius.circular(12)
AppSpacing.radiusLG   // BorderRadius.circular(16)
AppSpacing.radiusXL   // BorderRadius.circular(24)
AppSpacing.radiusFull // BorderRadius.circular(999) - Fully rounded
```

### Gaps (for Row/Column)
```dart
Column(
  children: [
    Text('First'),
    AppSpacing.gapMD,  // 16px vertical gap
    Text('Second'),
  ],
)

Row(
  children: [
    Icon(Icons.star),
    AppSpacing.gapSM,  // 8px horizontal gap
    Text('Rating'),
  ],
)
```

### Usage Example
```dart
Container(
  padding: AppSpacing.cardPadding,
  decoration: BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppSpacing.radiusMD,
  ),
  child: Column(
    children: [
      Text('Title'),
      AppSpacing.gapSM,
      Text('Description'),
    ],
  ),
)
```

---

## 🧩 COMPONENTS

### Buttons

#### Elevated Button (Primary)
```dart
ElevatedButton(
  onPressed: () {},
  child: const Text('Primary Button'),
)
// Automatically uses AppColors.primary background
// Automatically uses AppSpacing.buttonPadding
// Automatically uses AppSpacing.radiusMD
```

#### Outlined Button (Secondary)
```dart
OutlinedButton(
  onPressed: () {},
  child: const Text('Secondary Button'),
)
```

#### Text Button
```dart
TextButton(
  onPressed: () {},
  child: const Text('Text Button'),
)
```

### Text Fields
```dart
TextField(
  decoration: InputDecoration(
    labelText: 'Email',
    hintText: 'Enter your email',
  ),
)
// Automatically uses AppSpacing.radiusMD
// Automatically uses AppSpacing.inputPadding
// Automatically uses AppColors.inputBackground
```

### Cards
```dart
Card(
  child: Padding(
    padding: AppSpacing.cardPadding,
    child: Text('Card content'),
  ),
)
// Automatically uses AppSpacing.radiusMD
// Automatically uses AppColors.surface
// Automatically uses AppColors.border
```

---

## 💡 USAGE EXAMPLES

### Complete Page Example
```dart
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Page'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Welcome',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            AppSpacing.gapMD,
            
            // Card
            Card(
              child: Padding(
                padding: AppSpacing.cardPadding,
                child: Column(
                  children: [
                    Text(
                      'Card Title',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    AppSpacing.gapSM,
                    Text(
                      'Card description',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            AppSpacing.gapLG,
            
            // Button
            ElevatedButton(
              onPressed: () {},
              child: const Text('Action'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Custom Widget Example
```dart
class CustomCard extends StatelessWidget {
  final String title;
  final String description;
  
  const CustomCard({
    required this.title,
    required this.description,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.radiusMD,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          AppSpacing.gapXS,
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## ✅ BEST PRACTICES

### 1. Always Use Theme Constants
❌ **Don't:**
```dart
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Color(0xFFFFFFFF),
    borderRadius: BorderRadius.circular(12),
  ),
)
```

✅ **Do:**
```dart
Container(
  padding: AppSpacing.paddingMD,
  decoration: BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppSpacing.radiusMD,
  ),
)
```

### 2. Use Theme Text Styles
❌ **Don't:**
```dart
Text(
  'Title',
  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
)
```

✅ **Do:**
```dart
Text(
  'Title',
  style: Theme.of(context).textTheme.displaySmall,
)
```

### 3. Use Gaps Instead of SizedBox
❌ **Don't:**
```dart
Column(
  children: [
    Text('First'),
    SizedBox(height: 16),
    Text('Second'),
  ],
)
```

✅ **Do:**
```dart
Column(
  children: [
    Text('First'),
    AppSpacing.gapMD,
    Text('Second'),
  ],
)
```

### 4. Leverage Material Components
Use Flutter's built-in components (ElevatedButton, TextField, Card) instead of building from scratch. They automatically use the theme.

### 5. Test on Theme Test Page
Navigate to `/theme-test` to see all theme elements and verify consistency.

---

## 🧪 TESTING

### View Theme Test Page
```bash
# Run the app
flutter run -d chrome

# Navigate to:
http://localhost:8080/#/theme-test
```

The theme test page shows:
- All colors with labels
- All typography styles
- Spacing scale visualization
- Component examples

---

## 📦 FILES

- **`lib/core/theme/app_colors.dart`** - Color constants
- **`lib/core/theme/app_spacing.dart`** - Spacing constants
- **`lib/core/theme/app_theme.dart`** - Theme configuration
- **`lib/features/theme_test/theme_test_page.dart`** - Theme test page

---

## 🎉 SUMMARY

The ChekMate design system provides:
- ✅ **11 colors** matching Figma exactly
- ✅ **6 text styles** with Inter font
- ✅ **6 spacing sizes** (4px base unit)
- ✅ **Consistent components** using Material 3
- ✅ **Easy to use** with simple imports
- ✅ **Well documented** with examples

**Always use the theme constants for consistency!** 🚀

