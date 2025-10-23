import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/domain/entities/location_entity.dart';

/// LocationTagWidget - Shared UI Component
///
/// A compact widget for displaying location tags on posts, stories, and profiles.
/// Shows location name with icon in a chip-like format.
///
/// Features:
/// - Compact location display
/// - Customizable icon and colors
/// - Optional tap action
/// - Distance display (optional)
///
/// Usage:
/// ```dart
/// LocationTagWidget(
///   location: location,
///   onTap: () {
///     // Navigate to location details
///   },
/// )
/// ```
class LocationTagWidget extends StatelessWidget {
  const LocationTagWidget({
    required this.location,
    super.key,
    this.onTap,
    this.icon = Icons.location_on,
    this.iconSize = 16,
    this.fontSize = 14,
    this.color,
    this.backgroundColor,
    this.showFullAddress = false,
    this.maxLines = 1,
    this.currentLocation,
  });

  final LocationEntity location;
  final VoidCallback? onTap;
  final IconData icon;
  final double iconSize;
  final double fontSize;
  final Color? color;
  final Color? backgroundColor;
  final bool showFullAddress;
  final int maxLines;
  final LocationEntity? currentLocation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayColor = color ?? theme.primaryColor;
    final bgColor = backgroundColor ?? displayColor.withValues(alpha: 0.1);

    var displayText =
        showFullAddress ? location.fullAddress : location.shortDisplayName;

    // Add distance if current location is provided
    if (currentLocation != null) {
      final distance = location.getDistanceString(currentLocation!);
      displayText = '$displayText • $distance';
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: displayColor,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                displayText,
                style: TextStyle(
                  fontSize: fontSize,
                  color: displayColor,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// LocationHeaderWidget - Widget for displaying location in post headers
///
/// Displays location with icon and optional subtitle.
/// Used in post headers, story headers, etc.
class LocationHeaderWidget extends StatelessWidget {
  const LocationHeaderWidget({
    required this.location,
    super.key,
    this.onTap,
    this.icon = Icons.location_on,
    this.iconSize = 20,
    this.showFullAddress = false,
    this.currentLocation,
  });

  final LocationEntity location;
  final VoidCallback? onTap;
  final IconData icon;
  final double iconSize;
  final bool showFullAddress;
  final LocationEntity? currentLocation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final title = location.displayName;
    String? subtitle;

    if (showFullAddress && location.address != null) {
      subtitle = location.address;
    } else if (currentLocation != null) {
      subtitle = location.getDistanceString(currentLocation!);
    }

    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: iconSize,
            color: theme.iconTheme.color,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// LocationListTile - Full-width location display for lists
///
/// Displays location with icon, title, subtitle, and optional trailing widget.
/// Used in location search results, location lists, etc.
class LocationListTile extends StatelessWidget {
  const LocationListTile({
    required this.location,
    super.key,
    this.onTap,
    this.icon = Icons.location_on,
    this.trailing,
    this.currentLocation,
    this.showDistance = true,
  });

  final LocationEntity location;
  final VoidCallback? onTap;
  final IconData icon;
  final Widget? trailing;
  final LocationEntity? currentLocation;
  final bool showDistance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    var subtitle = location.address;
    if (showDistance && currentLocation != null) {
      final distance = location.getDistanceString(currentLocation!);
      subtitle = subtitle != null ? '$subtitle • $distance' : distance;
    }

    return ListTile(
      leading: Icon(icon, color: theme.primaryColor),
      title: Text(
        location.displayName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}

/// LocationDistanceWidget - Widget for displaying distance to a location
///
/// Shows distance with icon in a compact format.
class LocationDistanceWidget extends StatelessWidget {
  const LocationDistanceWidget({
    required this.location,
    required this.currentLocation,
    super.key,
    this.icon = Icons.near_me,
    this.iconSize = 16,
    this.fontSize = 14,
    this.color,
    this.useMetric = true,
  });

  final LocationEntity location;
  final LocationEntity currentLocation;
  final IconData icon;
  final double iconSize;
  final double fontSize;
  final Color? color;
  final bool useMetric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayColor = color ?? theme.textTheme.bodySmall?.color;

    final distance = location.getDistanceString(
      currentLocation,
      useMetric: useMetric,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: iconSize,
          color: displayColor,
        ),
        const SizedBox(width: 4),
        Text(
          distance,
          style: TextStyle(
            fontSize: fontSize,
            color: displayColor,
          ),
        ),
      ],
    );
  }
}
