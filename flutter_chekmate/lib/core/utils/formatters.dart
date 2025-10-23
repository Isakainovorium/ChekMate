import 'package:intl/intl.dart';

/// Utility class for formatting numbers, dates, and strings
class Formatters {
  /// Format large numbers (e.g., 1000 -> 1k, 1500000 -> 1.5M)
  static String formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }
  
  /// Format date to relative time (e.g., "2h ago", "3 days ago")
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    }
  }
  
  /// Format date to readable string
  static String formatDate(DateTime dateTime) {
    return DateFormat('MMM d, yyyy').format(dateTime);
  }
  
  /// Format date and time
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM d, yyyy • h:mm a').format(dateTime);
  }
  
  /// Format time only
  static String formatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }
  
  /// Truncate text with ellipsis
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}
