import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

/// ShareService - Shared Service Layer
///
/// Handles all sharing functionality using share_plus package.
/// Supports sharing text, images, videos, and combinations.
///
/// Features:
/// - Share text content
/// - Share single/multiple images
/// - Share videos
/// - Share with custom subject
/// - Share position origin for iPad
/// - Share result tracking
class ShareService {
  /// Share text content
  ///
  /// Example:
  /// ```dart
  /// await ShareService.shareText(
  ///   text: 'Check out this post!',
  ///   subject: 'Amazing Post',
  /// );
  /// ```
  static Future<void> shareText({
    required String text,
    String? subject,
    Rect? sharePositionOrigin,
  }) async {
    await Share.share(
      text,
      subject: subject,
      sharePositionOrigin: sharePositionOrigin,
    );
  }

  /// Share single file (image or video)
  ///
  /// Example:
  /// ```dart
  /// await ShareService.shareFile(
  ///   filePath: '/path/to/image.jpg',
  ///   text: 'Check out this image!',
  /// );
  /// ```
  static Future<void> shareFile({
    required String filePath,
    String? text,
    String? subject,
    Rect? sharePositionOrigin,
  }) async {
    final xFile = XFile(filePath);
    await Share.shareXFiles(
      [xFile],
      text: text,
      subject: subject,
      sharePositionOrigin: sharePositionOrigin,
    );
  }

  /// Share multiple files (images)
  ///
  /// Example:
  /// ```dart
  /// await ShareService.shareFiles(
  ///   filePaths: ['/path/to/image1.jpg', '/path/to/image2.jpg'],
  ///   text: 'Check out these images!',
  /// );
  /// ```
  static Future<void> shareFiles({
    required List<String> filePaths,
    String? text,
    String? subject,
    Rect? sharePositionOrigin,
  }) async {
    final xFiles = filePaths.map((path) => XFile(path)).toList();
    await Share.shareXFiles(
      xFiles,
      text: text,
      subject: subject,
      sharePositionOrigin: sharePositionOrigin,
    );
  }

  /// Share URL
  ///
  /// Example:
  /// ```dart
  /// await ShareService.shareUrl(
  ///   url: 'https://chekmate.app/post/123',
  ///   text: 'Check out this post!',
  /// );
  /// ```
  static Future<void> shareUrl({
    required String url,
    String? text,
    String? subject,
    Rect? sharePositionOrigin,
  }) async {
    final shareText = text != null ? '$text\n$url' : url;
    await Share.share(
      shareText,
      subject: subject,
      sharePositionOrigin: sharePositionOrigin,
    );
  }
}
