class ProductImage {
  final int id;
  final int productId;
  final String image;
  final String createdAt;
  final String updatedAt;

  ProductImage({
    required this.id,
    required this.productId,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      image: json['image'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'image': image,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class Store {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? image;
  final String? qrCode;
  final double cashbackRate;
  final int active;

  Store({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.image,
    this.qrCode,
    required this.cashbackRate,
    required this.active,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      image: json['image'],
      qrCode: json['qr_code'],
      cashbackRate: double.tryParse(json['cashback_rate']?.toString() ?? '0') ?? 0.0,
      active: json['active'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'image': image,
      'qr_code': qrCode,
      'cashback_rate': cashbackRate,
      'active': active,
    };
  }
}

class ProductModel {
  final int id;
  final int storeId;
  final int categoryId;
  final String nameEn;
  final String nameAr;
  final String price;
  final String discount;
  final int stock;
  final String descriptionEn;
  final String descriptionAr;
  final int active;
  final int featured;
  final int newProduct;
  final int bestSeller;
  final int topRated;
  final String createdAt;
  final String updatedAt;
  final List<ProductImage> productImages;
  final Store? store;

  ProductModel({
    required this.id,
    required this.storeId,
    required this.categoryId,
    required this.nameEn,
    required this.nameAr,
    required this.price,
    required this.discount,
    required this.stock,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.active,
    required this.featured,
    required this.newProduct,
    required this.bestSeller,
    required this.topRated,
    required this.createdAt,
    required this.updatedAt,
    this.productImages = const [],
    this.store,
  });

  // دالة لتنظيف النصوص من الأحرف غير الصحيحة
  static String _cleanText(dynamic value) {
    if (value == null) return '';
    String text = value.toString();
    // إزالة الأحرف غير الصحيحة والرموز الغريبة
    text = text.replaceAll(RegExp(r'[^\x00-\x7F\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]'), '');
    return text.trim();
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // استخراج الصور
    final imagesData = json['product_images'] as List<dynamic>? ?? [];
    final productImages = imagesData
        .map((imageData) => ProductImage.fromJson(imageData))
        .toList();

    // استخراج معلومات المتجر
    final storeData = json['store'];
    final store = storeData != null ? Store.fromJson(storeData) : null;

    return ProductModel(
      id: json['id'] ?? 0,
      storeId: json['store_id'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      nameEn: _cleanText(json['name_en']),
      nameAr: _cleanText(json['name_ar']),
      price: _cleanText(json['price']) != '' ? _cleanText(json['price']) : '0.00',
      discount: _cleanText(json['discount']) != '' ? _cleanText(json['discount']) : '0.00',
      stock: json['stock'] ?? 0,
      descriptionEn: _cleanText(json['description_en']),
      descriptionAr: _cleanText(json['description_ar']),
      active: json['active'] ?? 0,
      featured: json['featured'] ?? 0,
      newProduct: json['new'] ?? 0,
      bestSeller: json['best_seller'] ?? 0,
      topRated: json['top_rated'] ?? 0,
      createdAt: _cleanText(json['created_at']),
      updatedAt: _cleanText(json['updated_at']),
      productImages: productImages,
      store: store,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'category_id': categoryId,
      'name_en': nameEn,
      'name_ar': nameAr,
      'price': price,
      'discount': discount,
      'stock': stock,
      'description_en': descriptionEn,
      'description_ar': descriptionAr,
      'active': active,
      'featured': featured,
      'new': newProduct,
      'best_seller': bestSeller,
      'top_rated': topRated,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'product_images': productImages.map((image) => image.toJson()).toList(),
      'store': store?.toJson(),
    };
  }

  // حساب السعر بعد الخصم
  double get finalPrice {
    final originalPrice = double.tryParse(price) ?? 0.0;
    final discountValue = double.tryParse(discount) ?? 0.0;
    
    // إذا كان الخصم أكبر من 1، فهو نسبة مئوية
    if (discountValue > 1) {
      return originalPrice * (1 - discountValue / 100);
    } else {
      // إذا كان الخصم أقل من أو يساوي 1، فهو مبلغ خصم مباشر
      return originalPrice - discountValue;
    }
  }

  // التحقق من وجود خصم
  bool get hasDiscount => double.tryParse(discount) != null && double.parse(discount) > 0;

  // التحقق من توفر المنتج
  bool get isAvailable => stock > 0 && active == 1;

  // التحقق من المنتج الجديد
  bool get isNew => newProduct == 1;

  // التحقق من الأكثر مبيعاً
  bool get isBestSeller => bestSeller == 1;

  // التحقق من الأعلى تقييماً
  bool get isTopRated => topRated == 1;

  // التحقق من المميز
  bool get isFeatured => featured == 1;

  // الحصول على أول صورة للمنتج
  String? get firstImage {
    if (productImages.isNotEmpty) {
      return productImages.first.image;
    }
    return null;
  }

  // التحقق من وجود صور للمنتج
  bool get hasImages => productImages.isNotEmpty;

  // الحصول على جميع صور المنتج
  List<String> get allImages => productImages.map((img) => img.image).toList();
}

class Category {
  final int id;
  final int? parentId;
  final String nameEn;
  final String nameAr;
  final String? image;
  final String? createdAt;
  final String? updatedAt;

  Category({
    required this.id,
    this.parentId,
    required this.nameEn,
    required this.nameAr,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      parentId: json['parent_id'],
      nameEn: json['name_en'] ?? '',
      nameAr: json['name_ar'] ?? '',
      image: json['image'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parent_id': parentId,
      'name_en': nameEn,
      'name_ar': nameAr,
      'image': image,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class ProductDetails {
  final ProductModel product;
  final Category? category;
  final dynamic store; // يمكن أن يكون null

  ProductDetails({
    required this.product,
    this.category,
    this.store,
  });

  factory ProductDetails.fromJson(Map<String, dynamic> json) {
    return ProductDetails(
      product: ProductModel.fromJson(json['product'] ?? {}),
      category: json['category'] != null ? Category.fromJson(json['category']) : null,
      store: json['store'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'category': category?.toJson(),
      'store': store,
    };
  }
}

class ProductsResponse {
  final List<ProductModel> products;
  final int currentPage;
  final int lastPage;
  final bool hasNextPage;
  final bool hasPrevPage;
  final int total;
  final int perPage;
  final int productsCount;

  ProductsResponse({
    required this.products,
    required this.currentPage,
    required this.lastPage,
    required this.hasNextPage,
    required this.hasPrevPage,
    required this.total,
    required this.perPage,
    required this.productsCount,
  });

  factory ProductsResponse.fromJson(Map<String, dynamic> json) {
    final productsData = json['products'] ?? {};
    final data = productsData['data'] as List<dynamic>? ?? [];
    
    return ProductsResponse(
      products: data.map((item) => ProductModel.fromJson(item)).toList(),
      currentPage: productsData['current_page'] ?? 1,
      lastPage: productsData['last_page'] ?? 1,
      hasNextPage: productsData['next_page_url'] != null,
      hasPrevPage: productsData['prev_page_url'] != null,
      total: productsData['total'] ?? 0,
      perPage: productsData['per_page'] ?? 10,
      productsCount: json['products_count'] ?? 0,
    );
  }
}
