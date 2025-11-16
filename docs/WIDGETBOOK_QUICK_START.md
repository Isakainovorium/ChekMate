# Widgetbook Quick Start Guide
## **Get Started in 5 Minutes**

**Last Updated:** January 15, 2025  
**Platforms:** iOS | Android | Web

---

## Quick Commands

### **Run Widgetbook**

```bash
# iOS Simulator (iPhone 15 Pro)
flutter run -d "iPhone 15 Pro" -t lib/widgetbook.dart

# Android Emulator
flutter run -d emulator-5554 -t lib/widgetbook.dart

# Web Browser (Chrome)
flutter run -d chrome -t lib/widgetbook.dart

# Auto-select device
flutter run -t lib/widgetbook.dart
```

### **Build for Distribution**

```bash
# iOS (TestFlight)
flutter build ios --release -t lib/widgetbook.dart

# Android (APK)
flutter build apk --release -t lib/widgetbook.dart

# Web (Hosting)
flutter build web --release -t lib/widgetbook.dart
```

---

## Installation (One-Time Setup)

### **Step 1: Add Package**

Add to `pubspec.yaml` under `dev_dependencies`:

```yaml
dev_dependencies:
  widgetbook: ^3.16.0
  widgetbook_annotation: ^3.2.0
  widgetbook_generator: ^3.8.0
```

Run:
```bash
flutter pub get
```

### **Step 2: Create Entry Point**

Create `lib/widgetbook.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:flutter_chekmate/core/theme/app_theme.dart';

// Import showcases
import 'widgetbook/showcases/form_components.dart';
import 'widgetbook/showcases/data_display_components.dart';
import 'widgetbook/showcases/feedback_components.dart';
import 'widgetbook/showcases/loading_components.dart';

void main() {
  runApp(const WidgetbookApp());
}

class WidgetbookApp extends StatelessWidget {
  const WidgetbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      appInfo: AppInfo(name: 'ChekMate Components'),
      directories: [
        WidgetbookCategory(
          name: 'Form Components',
          children: FormComponentShowcases.showcases,
        ),
        WidgetbookCategory(
          name: 'Data Display',
          children: DataDisplayComponentShowcases.showcases,
        ),
        WidgetbookCategory(
          name: 'Feedback',
          children: FeedbackComponentShowcases.showcases,
        ),
        WidgetbookCategory(
          name: 'Loading States',
          children: LoadingComponentShowcases.showcases,
        ),
      ],
      addons: [
        MaterialThemeAddon(
          themes: [
            WidgetbookTheme(name: 'Light', data: AppTheme.lightTheme),
            WidgetbookTheme(name: 'Dark', data: AppTheme.darkTheme),
          ],
        ),
        DeviceFrameAddon(
          devices: [
            Devices.ios.iPhone15Pro,
            Devices.ios.iPadPro11Inches,
            Devices.android.samsungGalaxyS20,
          ],
        ),
        TextScaleAddon(scales: [0.8, 1.0, 1.2, 1.5, 2.0]),
      ],
    );
  }
}
```

### **Step 3: Run**

```bash
flutter run -t lib/widgetbook.dart
```

---

## Common Use Cases

### **1. Browse Components**

1. Run Widgetbook: `flutter run -t lib/widgetbook.dart`
2. Navigate categories in left sidebar
3. Select component to view
4. Try different variants and use cases

### **2. Test on iOS Device**

```bash
# List iOS devices
flutter devices

# Run on specific device
flutter run -d "Your iPhone" -t lib/widgetbook.dart
```

### **3. Test Dark Mode**

1. Run Widgetbook
2. Click theme selector (top toolbar)
3. Select "ChekMate Dark"
4. All components update to dark theme

### **4. Test Different Screen Sizes**

1. Run Widgetbook
2. Click device frame selector
3. Choose device:
   - iPhone 15 Pro (393x852)
   - iPad Pro 11" (834x1194)
   - Samsung Galaxy S20 (360x800)

### **5. Test Text Scaling (Accessibility)**

1. Run Widgetbook
2. Click text scale selector
3. Choose scale: 0.8x, 1.0x, 1.2x, 1.5x, 2.0x
4. Verify component layout at different scales

### **6. Share with Client (Web)**

```bash
# Build for web
flutter build web --release -t lib/widgetbook.dart

# Deploy to Firebase Hosting
firebase deploy --only hosting

# Share URL with client
# Example: https://chekmate-widgetbook.web.app
```

---

## Customization

### **Add New Component Showcase**

1. Open showcase file (e.g., `widgetbook/showcases/form_components.dart`)
2. Add to `showcases` list:

```dart
WidgetbookComponent(
  name: 'YourComponent',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) => YourComponent(),
    ),
    WidgetbookUseCase(
      name: 'Variant',
      builder: (context) => YourComponent(variant: Variant.secondary),
    ),
  ],
),
```

3. Hot reload to see changes

### **Add Interactive Knobs**

```dart
WidgetbookUseCase(
  name: 'Interactive',
  builder: (context) => AppButton(
    onPressed: () {},
    child: Text(
      context.knobs.string(
        label: 'Button Text',
        initialValue: 'Click Me',
      ),
    ),
    isLoading: context.knobs.boolean(
      label: 'Loading',
      initialValue: false,
    ),
  ),
)
```

### **Add New Device Frame**

```dart
DeviceFrameAddon(
  devices: [
    Devices.ios.iPhone15Pro,
    Devices.ios.iPadPro11Inches,
    Devices.android.pixel5,
    // Add custom device
    const DeviceInfo(
      name: 'Custom Device',
      screenSize: Size(400, 800),
      pixelRatio: 2.0,
    ),
  ],
)
```

---

## Troubleshooting

### **Issue: "No devices found"**

**Solution:**
```bash
# Start iOS simulator
open -a Simulator

# Or start Android emulator
flutter emulators --launch <emulator-id>

# Then run Widgetbook
flutter run -t lib/widgetbook.dart
```

### **Issue: "Package widgetbook not found"**

**Solution:**
```bash
flutter pub get
flutter clean
flutter pub get
```

### **Issue: "Hot reload not working"**

**Solution:**
- Press `r` in terminal for hot reload
- Press `R` for hot restart
- Or use IDE hot reload button

### **Issue: "Component not showing"**

**Solution:**
1. Check component is imported in showcase file
2. Check component is added to `showcases` list
3. Check component is exported from `lib/shared/ui/index.dart`
4. Hot reload Widgetbook

### **Issue: "iOS build failed"**

**Solution:**
```bash
cd ios
pod install
cd ..
flutter clean
flutter run -t lib/widgetbook.dart
```

---

## Platform-Specific Tips

### **iOS**

- **Simulator:** Cmd+Shift+H for home button
- **Rotate:** Cmd+Left/Right arrow
- **Screenshot:** Cmd+S
- **Safe Area:** Components automatically respect notch/home indicator

### **Android**

- **Emulator:** Ctrl+Shift+H for home button
- **Rotate:** Ctrl+Left/Right arrow
- **Screenshot:** Ctrl+S
- **Back Button:** ESC key

### **Web**

- **Refresh:** Cmd/Ctrl+R
- **DevTools:** F12
- **Responsive:** Cmd/Ctrl+Shift+M (Chrome DevTools)
- **Full Screen:** F11

---

## Learn More

- **Full Integration Plan:** `docs/WIDGETBOOK_INTEGRATION_PLAN.md`
- **Component Guide:** `docs/COMPONENTS_GUIDE.md`
- **Widgetbook Docs:** https://docs.widgetbook.io/
- **Flutter Docs:** https://docs.flutter.dev/

---

## Checklist

- [ ] Install widgetbook package
- [ ] Create `lib/widgetbook.dart`
- [ ] Run on iOS simulator
- [ ] Run on Android emulator
- [ ] Run on web browser
- [ ] Test dark mode
- [ ] Test different devices
- [ ] Test text scaling
- [ ] Add custom component showcase
- [ ] Share with team/client

---

**Need Help?** Check the full integration plan: `docs/WIDGETBOOK_INTEGRATION_PLAN.md`

