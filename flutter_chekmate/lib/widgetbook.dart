import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:widgetbook/widgetbook.dart';

// Import ChekMate theme and components
import 'package:flutter_chekmate/core/theme/app_theme.dart';

// Import showcase files
import 'package:flutter_chekmate/widgetbook/showcases/form_components.dart';
import 'package:flutter_chekmate/widgetbook/showcases/data_display_components.dart';
import 'package:flutter_chekmate/widgetbook/showcases/feedback_components.dart';
import 'package:flutter_chekmate/widgetbook/showcases/loading_components.dart';
import 'package:flutter_chekmate/widgetbook/showcases/layout_components.dart';
import 'package:flutter_chekmate/widgetbook/showcases/navigation_components.dart';
import 'package:flutter_chekmate/widgetbook/showcases/advanced_components.dart';
import 'package:flutter_chekmate/widgetbook/showcases/animation_components.dart';


void main() {
  runApp(const WidgetbookApp());
}

class WidgetbookApp extends StatelessWidget {
  const WidgetbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      // Component Directories
      directories: [
        WidgetbookCategory(
          name: 'Form Components',
          children: FormComponentShowcases.showcases,
        ),
        WidgetbookCategory(
          name: 'Layout Components',
          children: LayoutComponentShowcases.showcases,
        ),
        WidgetbookCategory(
          name: 'Navigation Components',
          children: NavigationComponentShowcases.showcases,
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
          name: 'Advanced Components',
          children: AdvancedComponentShowcases.showcases,
        ),
        WidgetbookCategory(
          name: 'Animation Components',
          children: AnimationComponentShowcases.showcases,
        ),
        WidgetbookCategory(
          name: 'Loading States',
          children: LoadingComponentShowcases.showcases,
        ),
      ],
      
      // Addons for customization
      addons: [
        // Theme Addon - ChekMate Light/Dark themes
        MaterialThemeAddon(
          themes: [
            WidgetbookTheme(
              name: 'ChekMate Light',
              data: AppTheme.lightTheme,
            ),
            WidgetbookTheme(
              name: 'ChekMate Dark',
              data: AppTheme.darkTheme,
            ),
            // iOS-specific themes
            WidgetbookTheme(
              name: 'ChekMate Light (iOS)',
              data: AppTheme.lightTheme.copyWith(
                platform: TargetPlatform.iOS,
                pageTransitionsTheme: const PageTransitionsTheme(
                  builders: {
                    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                  },
                ),
              ),
            ),
            WidgetbookTheme(
              name: 'ChekMate Dark (iOS)',
              data: AppTheme.darkTheme.copyWith(
                platform: TargetPlatform.iOS,
                pageTransitionsTheme: const PageTransitionsTheme(
                  builders: {
                    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                  },
                ),
              ),
            ),
          ],
        ),
        
        // Viewport Addon for responsive breakpoints (replaces deprecated DeviceFrameAddon)
        ViewportAddon(
          [
            // Latest iPhones (2023-2024)
            const ViewportData(
              name: 'iPhone 15',
              width: 393,
              height: 852,
              platform: TargetPlatform.iOS,
              pixelRatio: 3.0,
            ),
            const ViewportData(
              name: 'iPhone 15 Plus',
              width: 430,
              height: 932,
              platform: TargetPlatform.iOS,
              pixelRatio: 3.0,
            ),
            const ViewportData(
              name: 'iPhone 15 Pro',
              width: 393,
              height: 852,
              platform: TargetPlatform.iOS,
              pixelRatio: 3.0,
            ),
            const ViewportData(
              name: 'iPhone 15 Pro Max',
              width: 430,
              height: 932,
              platform: TargetPlatform.iOS,
              pixelRatio: 3.0,
            ),
            
            // Previous Generation iPhones
            const ViewportData(
              name: 'iPhone 14',
              width: 390,
              height: 844,
              platform: TargetPlatform.iOS,
              pixelRatio: 3.0,
            ),
            const ViewportData(
              name: 'iPhone 14 Pro',
              width: 393,
              height: 852,
              platform: TargetPlatform.iOS,
              pixelRatio: 3.0,
            ),
            const ViewportData(
              name: 'iPhone 13',
              width: 390,
              height: 844,
              platform: TargetPlatform.iOS,
              pixelRatio: 3.0,
            ),
            const ViewportData(
              name: 'iPhone 13 Pro Max',
              width: 428,
              height: 926,
              platform: TargetPlatform.iOS,
              pixelRatio: 3.0,
            ),
            const ViewportData(
              name: 'iPhone SE',
              width: 375,
              height: 667,
              platform: TargetPlatform.iOS,
              pixelRatio: 2.0,
            ),
            
            // iPads
            const ViewportData(
              name: 'iPad',
              width: 810,
              height: 1080,
              platform: TargetPlatform.iOS,
              pixelRatio: 2.0,
            ),
            const ViewportData(
              name: 'iPad Pro 11"',
              width: 834,
              height: 1194,
              platform: TargetPlatform.iOS,
              pixelRatio: 2.0,
            ),
            const ViewportData(
              name: 'iPad Pro 12.9"',
              width: 1024,
              height: 1366,
              platform: TargetPlatform.iOS,
              pixelRatio: 2.0,
            ),
            const ViewportData(
              name: 'iPad Air',
              width: 820,
              height: 1180,
              platform: TargetPlatform.iOS,
              pixelRatio: 2.0,
            ),
            const ViewportData(
              name: 'iPad Mini',
              width: 744,
              height: 1133,
              platform: TargetPlatform.iOS,
              pixelRatio: 2.0,
            ),
            
            // Android Devices
            const ViewportData(
              name: 'Samsung Galaxy S20',
              width: 360,
              height: 800,
              platform: TargetPlatform.android,
              pixelRatio: 3.0,
            ),
            const ViewportData(
              name: 'Pixel 5',
              width: 393,
              height: 851,
              platform: TargetPlatform.android,
              pixelRatio: 2.75,
            ),
            const ViewportData(
              name: 'Samsung Galaxy Note20',
              width: 412,
              height: 915,
              platform: TargetPlatform.android,
              pixelRatio: 3.5,
            ),
            
            // Desktop
            const ViewportData(
              name: 'Desktop',
              width: 1440,
              height: 900,
              platform: TargetPlatform.macOS,
              pixelRatio: 1.0,
            ),
          ],
        ),
        
        // Text Scale Addon for accessibility
        TextScaleAddon(
          min: 0.8,
          max: 3.0,
        ),
        
        // Grid Addon for alignment
        GridAddon(),
      ],
      
      // App Builder for global configuration
      appBuilder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: child,
        );
      },
    );
  }
}

