import 'package:flutter/material.dart';

/// Responsive breakpoints for ChekMate
/// Follows industry standards (Bootstrap, Material Design)
class AppBreakpoints {
  // Breakpoint values (in logical pixels)
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
  static const double wide = 1800;

  // Check device type
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobile;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width < desktop;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktop;
  }

  static bool isWide(BuildContext context) {
    return MediaQuery.of(context).size.width >= wide;
  }

  // Get device type enum
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < mobile) {
      return DeviceType.mobile;
    } else if (width < desktop) {
      return DeviceType.tablet;
    } else if (width < wide) {
      return DeviceType.desktop;
    } else {
      return DeviceType.wide;
    }
  }

  // Get responsive value based on device type
  static T responsive<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
    T? wide,
  }) {
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.wide:
        return wide ?? desktop ?? tablet ?? mobile;
    }
  }

  // Get content max width based on device type
  static double getContentMaxWidth(BuildContext context) {
    return responsive(
      context: context,
      mobile: double.infinity,
      tablet: 800,
      desktop: 1000,
      wide: 1200,
    );
  }

  // Get number of columns for grid layouts
  static int getGridColumns(BuildContext context) {
    return responsive(
      context: context,
      mobile: 1,
      tablet: 2,
      desktop: 3,
      wide: 4,
    );
  }

  // Get horizontal padding based on device type
  static double getHorizontalPadding(BuildContext context) {
    return responsive(
      context: context,
      mobile: 16.0,
      tablet: 24.0,
      desktop: 32.0,
      wide: 48.0,
    );
  }
}

/// Device type enum
enum DeviceType {
  mobile,
  tablet,
  desktop,
  wide,
}

/// Responsive builder widget
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    required this.mobile,
    super.key,
    this.tablet,
    this.desktop,
    this.wide,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? wide;

  @override
  Widget build(BuildContext context) {
    return AppBreakpoints.responsive(
      context: context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      wide: wide,
    );
  }
}

/// Responsive layout wrapper
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    required this.child,
    super.key,
    this.maxWidth,
    this.centerContent = true,
  });

  final Widget child;
  final double? maxWidth;
  final bool centerContent;

  @override
  Widget build(BuildContext context) {
    final contentMaxWidth = maxWidth ?? AppBreakpoints.getContentMaxWidth(context);
    
    if (AppBreakpoints.isMobile(context)) {
      return child;
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: contentMaxWidth,
        ),
        child: child,
      ),
    );
  }
}

/// Responsive grid widget
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    required this.children,
    super.key,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.wideColumns = 4,
  });

  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final int wideColumns;

  @override
  Widget build(BuildContext context) {
    final columns = AppBreakpoints.responsive(
      context: context,
      mobile: mobileColumns,
      tablet: tabletColumns,
      desktop: desktopColumns,
      wide: wideColumns,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - (spacing * (columns - 1))) / columns;
        
        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: children.map((child) {
            return SizedBox(
              width: itemWidth,
              child: child,
            );
          }).toList(),
        );
      },
    );
  }
}

/// Responsive padding widget
class ResponsivePadding extends StatelessWidget {
  const ResponsivePadding({
    required this.child,
    super.key,
    this.horizontal = true,
    this.vertical = false,
  });

  final Widget child;
  final bool horizontal;
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final padding = AppBreakpoints.getHorizontalPadding(context);
    
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontal ? padding : 0,
        vertical: vertical ? padding : 0,
      ),
      child: child,
    );
  }
}

/// Responsive visibility widget
class ResponsiveVisibility extends StatelessWidget {
  const ResponsiveVisibility({
    required this.child,
    super.key,
    this.hiddenOn = const [],
    this.visibleOn = const [],
  });

  final Widget child;
  final List<DeviceType> hiddenOn;
  final List<DeviceType> visibleOn;

  @override
  Widget build(BuildContext context) {
    final deviceType = AppBreakpoints.getDeviceType(context);
    
    // If visibleOn is specified, only show on those devices
    if (visibleOn.isNotEmpty) {
      if (!visibleOn.contains(deviceType)) {
        return const SizedBox.shrink();
      }
    }
    
    // If hiddenOn is specified, hide on those devices
    if (hiddenOn.contains(deviceType)) {
      return const SizedBox.shrink();
    }
    
    return child;
  }
}

