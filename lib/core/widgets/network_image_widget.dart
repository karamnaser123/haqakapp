import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/image_helper.dart';

/// Widget موحد لعرض الصور من الإنترنت
/// 
/// يدعم:
/// - Caching للصور
/// - Placeholder أثناء التحميل
/// - Error handling
/// - Customization للـ fit والـ size
class NetworkImageWidget extends StatelessWidget {
  final String? imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget Function(BuildContext, String)? placeholder;
  final Widget Function(BuildContext, String, dynamic)? errorWidget;
  final Duration? fadeInDuration;
  final Duration? fadeOutDuration;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final int? maxWidthDiskCache;
  final int? maxHeightDiskCache;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;

  const NetworkImageWidget({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
    this.fadeInDuration,
    this.fadeOutDuration,
    this.memCacheWidth,
    this.memCacheHeight,
    this.maxWidthDiskCache,
    this.maxHeightDiskCache,
    this.borderRadius,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    // معالجة URL
    final processedUrl = ImageHelper.getImageUrl(imageUrl);
    
    // إذا لم يكن هناك URL صالح، نعرض error widget
    if (!ImageHelper.isValidImageUrl(processedUrl)) {
      return _buildErrorWidget(context);
    }

    Widget imageWidget = CachedNetworkImage(
      imageUrl: processedUrl,
      fit: fit,
      width: width,
      height: height,
      placeholder: placeholder != null 
          ? placeholder 
          : (context, url) => _buildDefaultPlaceholder(),
      errorWidget: errorWidget != null
          ? errorWidget
          : (context, url, error) => _buildErrorWidget(context),
      fadeInDuration: fadeInDuration ?? const Duration(milliseconds: 300),
      fadeOutDuration: fadeOutDuration ?? const Duration(milliseconds: 100),
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      maxWidthDiskCache: maxWidthDiskCache,
      maxHeightDiskCache: maxHeightDiskCache,
      httpHeaders: const {
        'Cache-Control': 'max-age=3600',
      },
    );

    // إضافة BorderRadius إذا كان موجود
    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    // إضافة Container مع backgroundColor فقط إذا لزم (width و height موجودان في CachedNetworkImage)
    if (backgroundColor != null) {
      imageWidget = Container(
        color: backgroundColor,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: Center(
        child: SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              const Color(0xFF667eea),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.image_not_supported,
          size: (width != null && height != null)
              ? (width! < height! ? width! * 0.4 : height! * 0.4)
              : 40,
          color: Colors.grey[400],
        ),
      ),
    );
  }
}

/// Widget خاص لعرض صور المنتجات
class ProductImageWidget extends StatelessWidget {
  final String? imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final int? maxWidthDiskCache;
  final int? maxHeightDiskCache;

  const ProductImageWidget({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.memCacheWidth,
    this.memCacheHeight,
    this.maxWidthDiskCache,
    this.maxHeightDiskCache,
  });

  @override
  Widget build(BuildContext context) {
    return NetworkImageWidget(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      borderRadius: borderRadius,
      memCacheWidth: memCacheWidth ?? 200,
      memCacheHeight: memCacheHeight ?? 200,
      maxWidthDiskCache: maxWidthDiskCache ?? 300,
      maxHeightDiskCache: maxHeightDiskCache ?? 300,
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        color: Colors.grey[100],
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: borderRadius,
        ),
        child: const Icon(
          Icons.shopping_bag,
          size: 40,
          color: Colors.grey,
        ),
      ),
    );
  }
}

/// Widget خاص لعرض صور الفئات
class CategoryImageWidget extends StatelessWidget {
  final String? imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final IconData defaultIcon;
  final Color? iconColor;

  const CategoryImageWidget({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.defaultIcon = Icons.category,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return NetworkImageWidget(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      borderRadius: borderRadius,
      memCacheWidth: 200,
      memCacheHeight: 200,
      maxWidthDiskCache: 300,
      maxHeightDiskCache: 300,
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        color: Colors.grey[100],
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: borderRadius,
        ),
        child: Icon(
          defaultIcon,
          size: 40,
          color: iconColor ?? Colors.grey[400],
        ),
      ),
    );
  }
}

/// Widget خاص لعرض صور المتاجر
class StoreImageWidget extends StatelessWidget {
  final String? imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const StoreImageWidget({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return NetworkImageWidget(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      memCacheWidth: 150,
      memCacheHeight: 150,
      maxWidthDiskCache: 200,
      maxHeightDiskCache: 200,
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFF667eea).withOpacity(0.1),
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFF667eea).withOpacity(0.1),
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.store,
          size: 30,
          color: Color(0xFF667eea),
        ),
      ),
    );
  }
}
