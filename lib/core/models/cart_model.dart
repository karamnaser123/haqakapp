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

class CartProduct {
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

  CartProduct({
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
    required this.productImages,
  });

  factory CartProduct.fromJson(Map<String, dynamic> json) {
    return CartProduct(
      id: json['id'] ?? 0,
      storeId: json['store_id'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      nameEn: json['name_en'] ?? '',
      nameAr: json['name_ar'] ?? '',
      price: json['price'] ?? '0.00',
      discount: json['discount'] ?? '0.00',
      stock: json['stock'] ?? 0,
      descriptionEn: json['description_en'] ?? '',
      descriptionAr: json['description_ar'] ?? '',
      active: json['active'] ?? 0,
      featured: json['featured'] ?? 0,
      newProduct: json['new'] ?? 0,
      bestSeller: json['best_seller'] ?? 0,
      topRated: json['top_rated'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      productImages: (json['product_images'] as List<dynamic>?)
          ?.map((image) => ProductImage.fromJson(image))
          .toList() ?? [],
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
    };
  }

  // Helper methods
  double get finalPrice => double.parse(price) - double.parse(discount);
  bool get isAvailable => active == 1 && stock > 0;
  String get firstImage => productImages.isNotEmpty ? productImages.first.image : '';
}

class Store {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? otp;
  final String? emailVerifiedAt;
  final String? gender;
  final int? age;
  final String balance;
  final String code;
  final String? qrCode;
  final int cashbackRate;
  final String? image;
  final int active;
  final String createdAt;
  final String updatedAt;

  Store({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.otp,
    this.emailVerifiedAt,
    this.gender,
    this.age,
    required this.balance,
    required this.code,
    this.qrCode,
    required this.cashbackRate,
    this.image,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      otp: json['otp'],
      emailVerifiedAt: json['email_verified_at'],
      gender: json['gender'],
      age: json['age'],
      balance: json['balance'] ?? '0.00',
      code: json['code'] ?? '',
      qrCode: json['qr_code'],
      cashbackRate: json['cashback_rate'] ?? 0,
      image: json['image'],
      active: json['active'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'otp': otp,
      'email_verified_at': emailVerifiedAt,
      'gender': gender,
      'age': age,
      'balance': balance,
      'code': code,
      'qr_code': qrCode,
      'cashback_rate': cashbackRate,
      'image': image,
      'active': active,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class OrderItem {
  final int id;
  final int orderId;
  final int productId;
  final int quantity;
  final String price;
  final String totalPrice;
  final String createdAt;
  final String updatedAt;
  final CartProduct product;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.price,
    required this.totalPrice,
    required this.createdAt,
    required this.updatedAt,
    required this.product,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? 0,
      orderId: json['order_id'] ?? 0,
      productId: json['product_id'] ?? 0,
      quantity: json['quantity'] ?? 0,
      price: json['price'] ?? '0.00',
      totalPrice: json['total_price'] ?? '0.00',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      product: CartProduct.fromJson(json['product'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'quantity': quantity,
      'price': price,
      'total_price': totalPrice,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'product': product.toJson(),
    };
  }
}

class CartItem {
  final int id;
  final int userId;
  final int storeId;
  final int? discountId;
  final int quantity;
  final String totalPrice;
  final String cashbackAmount;
  final String createdAt;
  final String updatedAt;
  final List<OrderItem> orderItems;
  final Store store;

  CartItem({
    required this.id,
    required this.userId,
    required this.storeId,
    this.discountId,
    required this.quantity,
    required this.totalPrice,
    required this.cashbackAmount,
    required this.createdAt,
    required this.updatedAt,
    required this.orderItems,
    required this.store,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      storeId: json['store_id'] ?? 0,
      discountId: json['discount_id'],
      quantity: json['quantity'] ?? 0,
      totalPrice: json['total_price'] ?? '0.00',
      cashbackAmount: json['cashback_amount'] ?? '0.00',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      orderItems: (json['order_items'] as List<dynamic>?)
          ?.map((item) => OrderItem.fromJson(item))
          .toList() ?? [],
      store: Store.fromJson(json['store'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'store_id': storeId,
      'discount_id': discountId,
      'quantity': quantity,
      'total_price': totalPrice,
      'cashback_amount': cashbackAmount,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'order_items': orderItems.map((item) => item.toJson()).toList(),
      'store': store.toJson(),
    };
  }
}

class CartResponse {
  final List<CartItem> cart;

  CartResponse({
    required this.cart,
  });

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    return CartResponse(
      cart: (json['cart'] as List<dynamic>?)
          ?.map((item) => CartItem.fromJson(item))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cart': cart.map((item) => item.toJson()).toList(),
    };
  }

  // Helper methods
  int get totalItems => cart.fold(0, (sum, item) => sum + item.quantity);
  
  double get totalPrice => cart.fold(0.0, (sum, item) => sum + double.parse(item.totalPrice));
  
  double get totalCashback => cart.fold(0.0, (sum, item) => sum + double.parse(item.cashbackAmount));
}
