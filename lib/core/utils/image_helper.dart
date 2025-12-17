class ImageHelper {
  // Base URL من API
  static const String baseUrl = 'http://192.168.1.89:8000';
  
  /// معالجة URL الصورة وإرجاع URL كامل وصحيح
  /// 
  /// [imageUrl] - URL الصورة (قد يكون نسبي أو مطلق)
  /// 
  /// Returns: URL كامل وصحيح للصورة
  static String getImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return '';
    }
    
    // إزالة المسافات الزائدة والأحرف غير المرئية
    imageUrl = imageUrl.trim().replaceAll(RegExp(r'\s+'), '');
    
    // إذا كان URL مطلق (يبدأ بـ http:// أو https://)
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      // إصلاح URL المكسور - إضافة الشرطة المائلة المفقودة
      if (imageUrl.contains('https:') && !imageUrl.contains('://')) {
        imageUrl = imageUrl.replaceFirst('https:', 'https://');
      }
      if (imageUrl.contains('http:') && !imageUrl.contains('://')) {
        imageUrl = imageUrl.replaceFirst('http:', 'http://');
      }
      // إزالة المسافات الزائدة في نهاية URL
      return imageUrl.trim();
    }
    
    // إذا كان URL نسبي (يبدأ بـ /)
    if (imageUrl.startsWith('/')) {
      return '$baseUrl$imageUrl';
    }
    
    // إذا كان URL نسبي بدون /
    return '$baseUrl/$imageUrl';
  }
  
  /// التحقق من صحة URL الصورة
  static bool isValidImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return false;
    }
    
    final url = getImageUrl(imageUrl);
    return url.isNotEmpty && 
           (url.startsWith('http://') || url.startsWith('https://'));
  }
  
  /// الحصول على قائمة من URLs معالجة
  static List<String> getImageUrls(List<String>? imageUrls) {
    if (imageUrls == null || imageUrls.isEmpty) {
      return [];
    }
    
    return imageUrls
        .map((url) => getImageUrl(url))
        .where((url) => url.isNotEmpty)
        .toList();
  }
}
