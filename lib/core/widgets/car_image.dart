import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// A drop-in image widget for car images that:
/// - Uses [CachedNetworkImage] on mobile for performance
/// - Falls back gracefully on CORS errors (common on web with 3rd-party CDNs)
/// - Shows a branded car-icon placeholder while loading / on error
class CarImage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const CarImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
  });

  Widget _placeholder(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: AppColors.background,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.directions_car_rounded,
              size: 36,
              color: AppColors.textLight,
            ),
            const SizedBox(height: 4),
            Text(
              'No image',
              style: TextStyle(fontSize: 10, color: AppColors.textLight),
            ),
          ],
        ),
      ),
    );
  }

  Widget _wrap(Widget child) {
    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: child);
    }
    return child;
  }

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return _wrap(_placeholder(context));

    if (kIsWeb) {
      // On web we use Image.network with an error builder — CachedNetworkImage
      // can swallow CORS errors silently.
      return _wrap(
        Image.network(
          url,
          fit: fit,
          width: width,
          height: height,
          loadingBuilder: (_, child, progress) {
            if (progress == null) return child;
            return Container(
              width: width,
              height: height,
              color: AppColors.background,
              child: Center(
                child: CircularProgressIndicator(
                  value: progress.expectedTotalBytes != null
                      ? progress.cumulativeBytesLoaded /
                            progress.expectedTotalBytes!
                      : null,
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            );
          },
          errorBuilder: (_, error, __) {
            // CORS or 404 — show branded fallback
            return _placeholder(context);
          },
        ),
      );
    }

    // Mobile: use CachedNetworkImage for disk caching
    return _wrap(
      CachedNetworkImage(
        imageUrl: url,
        fit: fit,
        width: width,
        height: height,
        placeholder: (_, __) => Container(
          width: width,
          height: height,
          color: AppColors.background,
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        ),
        errorWidget: (_, __, ___) => _placeholder(context),
      ),
    );
  }
}
