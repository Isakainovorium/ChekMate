import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/shared/widgets/loading_indicator.dart';

class CachedImage extends StatelessWidget {
  const CachedImage({
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    super.key,
  });
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  @override
  Widget build(BuildContext context) {
    Widget image = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) =>
          placeholder ??
          Center(
            child: LoadingIndicator(
              size: width != null && width! < 50 ? 16 : 24,
            ),
          ),
      errorWidget: (context, url, error) =>
          errorWidget ??
          Container(
            color: AppColors.surfaceVariant,
            child: const Icon(
              Icons.broken_image_outlined,
              color: AppColors.textTertiary,
            ),
          ),
    );

    if (borderRadius != null) {
      image = ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    return image;
  }
}

class CircularCachedImage extends StatelessWidget {
  const CircularCachedImage({
    required this.imageUrl,
    this.size = 40,
    this.placeholder,
    this.errorWidget,
    super.key,
  });
  final String imageUrl;
  final double size;
  final Widget? placeholder;
  final Widget? errorWidget;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: CachedImage(
        imageUrl: imageUrl,
        width: size,
        height: size,
        placeholder: placeholder,
        errorWidget: errorWidget ??
            Container(
              width: size,
              height: size,
              color: AppColors.surfaceVariant,
              child: Icon(
                Icons.person,
                size: size * 0.6,
                color: AppColors.textTertiary,
              ),
            ),
      ),
    );
  }
}
