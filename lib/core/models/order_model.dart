class OrderModel {
  final int id;
  final int userId;
  final int storeId;
  final int? discountId;
  final int quantity;
  final double subtotal;
  final double discountAmount;
  final double totalPrice;
  final double cashbackAmount;
  final double deliveryFee;
  final String phone;
  final String address;
  final int cityId;
  final String paymentMethod;
  final String status;
  final String createdAt;
  final String updatedAt;
  final List<OrderItem> orderItems;
  final Store store;
  final Discount? discount;

  OrderModel({
    required this.id,
    required this.userId,
    required this.storeId,
    this.discountId,
    required this.quantity,
    required this.subtotal,
    required this.discountAmount,
    required this.totalPrice,
    required this.cashbackAmount,
    required this.deliveryFee,
    required this.phone,
    required this.address,
    required this.cityId,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.orderItems,
    required this.store,
    this.discount,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      storeId: json['store_id'] ?? 0,
      discountId: json['discount_id'],
      quantity: json['quantity'] ?? 0,
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0.0,
      discountAmount: double.tryParse(json['discount_amount']?.toString() ?? '0') ?? 0.0,
      totalPrice: double.tryParse(json['total_price']?.toString() ?? '0') ?? 0.0,
      cashbackAmount: double.tryParse(json['cashback_amount']?.toString() ?? '0') ?? 0.0,
      deliveryFee: double.tryParse(json['delivery_fee']?.toString() ?? '0') ?? 0.0,
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      cityId: json['city_id'] ?? 0,
      paymentMethod: json['payment_method'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      orderItems: (json['order_items'] as List<dynamic>?)
          ?.map((item) => OrderItem.fromJson(item))
          .toList() ?? [],
      store: Store.fromJson(json['store'] ?? {}),
      discount: json['discount'] != null ? Discount.fromJson(json['discount']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'store_id': storeId,
      'discount_id': discountId,
      'quantity': quantity,
      'subtotal': subtotal,
      'discount_amount': discountAmount,
      'total_price': totalPrice,
      'cashback_amount': cashbackAmount,
      'delivery_fee': deliveryFee,
      'phone': phone,
      'address': address,
      'city_id': cityId,
      'payment_method': paymentMethod,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'order_items': orderItems.map((item) => item.toJson()).toList(),
      'store': store.toJson(),
      'discount': discount?.toJson(),
    };
  }

  // Getter للحصول على حالة الطلب بالعربية
  String get statusInArabic {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'في الانتظار';
      case 'processing':
        return 'قيد المعالجة';
      case 'shipped':
        return 'تم الشحن';
      case 'delivered':
        return 'تم التسليم';
      case 'cancelled':
        return 'ملغي';
      case 'completed':
        return 'مكتمل';
      default:
        return status;
    }
  }

  // Getter للحصول على طريقة الدفع بالعربية
  String get paymentMethodInArabic {
    switch (paymentMethod.toLowerCase()) {
      case 'cash':
        return 'نقداً';
      case 'card':
        return 'بطاقة ائتمان';
      case 'bank_transfer':
        return 'تحويل بنكي';
      default:
        return paymentMethod;
    }
  }
}

class OrderItem {
  final int id;
  final int orderId;
  final int productId;
  final int quantity;
  final double price;
  final double totalPrice;
  final String createdAt;
  final String updatedAt;
  final Product product;

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
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      totalPrice: double.tryParse(json['total_price']?.toString() ?? '0') ?? 0.0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      product: Product.fromJson(json['product'] ?? {}),
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

class Product {
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

  Product({
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
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
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
    };
  }
}

class Store {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? otp;
  final String? emailVerifiedAt;
  final String gender;
  final int age;
  final double balance;
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
    required this.gender,
    required this.age,
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
      gender: json['gender'] ?? '',
      age: json['age'] ?? 0,
      balance: double.tryParse(json['balance']?.toString() ?? '0') ?? 0.0,
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

class Discount {
  final int id;
  final String code;
  final String type;
  final double value;
  final double minimumAmount;
  final DateTime? startDate;
  final DateTime? endDate;
  final int usageLimit;
  final int usedCount;
  final int active;
  final String createdAt;
  final String updatedAt;

  Discount({
    required this.id,
    required this.code,
    required this.type,
    required this.value,
    required this.minimumAmount,
    this.startDate,
    this.endDate,
    required this.usageLimit,
    required this.usedCount,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Discount.fromJson(Map<String, dynamic> json) {
    return Discount(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      type: json['type'] ?? '',
      value: double.tryParse(json['value']?.toString() ?? '0') ?? 0.0,
      minimumAmount: double.tryParse(json['minimum_amount']?.toString() ?? '0') ?? 0.0,
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date']) : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      usageLimit: json['usage_limit'] ?? 0,
      usedCount: json['used_count'] ?? 0,
      active: json['active'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'type': type,
      'value': value,
      'minimum_amount': minimumAmount,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'usage_limit': usageLimit,
      'used_count': usedCount,
      'active': active,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
