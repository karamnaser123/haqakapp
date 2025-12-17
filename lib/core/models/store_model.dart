class StoreDetails {
  final int id;
  final int storeId;
  final String? location;
  final String? image;
  final String? phone;
  final String? email;
  final String? website;
  final String? facebook;
  final String? instagram;
  final String? whatsapp;
  final String deliveryPrice;
  final String? createdAt;
  final String? updatedAt;

  StoreDetails({
    required this.id,
    required this.storeId,
    this.location,
    this.image,
    this.phone,
    this.email,
    this.website,
    this.facebook,
    this.instagram,
    this.whatsapp,
    required this.deliveryPrice,
    this.createdAt,
    this.updatedAt,
  });

  factory StoreDetails.fromJson(Map<String, dynamic> json) {
    return StoreDetails(
      id: json['id'] ?? 0,
      storeId: json['store_id'] ?? 0,
      location: json['location'],
      image: json['image'],
      phone: json['phone'],
      email: json['email'],
      website: json['website'],
      facebook: json['facebook'],
      instagram: json['instagram'],
      whatsapp: json['whatsapp'],
      deliveryPrice: json['delivery_price'] ?? '0.00',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'location': location,
      'image': image,
      'phone': phone,
      'email': email,
      'website': website,
      'facebook': facebook,
      'instagram': instagram,
      'whatsapp': whatsapp,
      'delivery_price': deliveryPrice,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class PaginationLink {
  final String? url;
  final String label;
  final int? page;
  final bool active;

  PaginationLink({
    this.url,
    required this.label,
    this.page,
    required this.active,
  });

  factory PaginationLink.fromJson(Map<String, dynamic> json) {
    return PaginationLink(
      url: json['url'],
      label: json['label'] ?? '',
      page: int.tryParse(json['page']?.toString() ?? '0'),
      active: json['active'] ?? false,
    );
  }
}

class PaginatedStoresResponse {
  final int currentPage;
  final List<Store> data;
  final String firstPageUrl;
  final int from;
  final int lastPage;
  final String lastPageUrl;
  final List<PaginationLink> links;
  final String? nextPageUrl;
  final String path;
  final int perPage;
  final String? prevPageUrl;
  final int to;
  final int total;

  PaginatedStoresResponse({
    required this.currentPage,
    required this.data,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
    required this.links,
    this.nextPageUrl,
    required this.path,
    required this.perPage,
    this.prevPageUrl,
    required this.to,
    required this.total,
  });

  factory PaginatedStoresResponse.fromJson(Map<String, dynamic> json) {
    final storesData = json['data'] as List<dynamic>? ?? [];
    
    return PaginatedStoresResponse(
      currentPage: int.tryParse(json['current_page']?.toString() ?? '1') ?? 1,
      data: storesData.map((storeJson) => Store.fromJson(storeJson)).toList(),
      firstPageUrl: json['first_page_url'] ?? '',
      from: int.tryParse(json['from']?.toString() ?? '0') ?? 0,
      lastPage: int.tryParse(json['last_page']?.toString() ?? '1') ?? 1,
      lastPageUrl: json['last_page_url'] ?? '',
      links: (json['links'] as List<dynamic>? ?? [])
          .map((linkJson) => PaginationLink.fromJson(linkJson))
          .toList(),
      nextPageUrl: json['next_page_url'],
      path: json['path'] ?? '',
      perPage: int.tryParse(json['per_page']?.toString() ?? '10') ?? 10,
      prevPageUrl: json['prev_page_url'],
      to: int.tryParse(json['to']?.toString() ?? '0') ?? 0,
      total: int.tryParse(json['total']?.toString() ?? '0') ?? 0,
    );
  }

  bool get hasNextPage => nextPageUrl != null;
  bool get hasPrevPage => prevPageUrl != null;
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
  final String balance;
  final String code;
  final String? qrCode;
  final int cashbackRate;
  final String? image;
  final int active;
  final String createdAt;
  final String updatedAt;
  final StoreDetails? storeDetails;

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
    this.storeDetails,
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
      age: int.tryParse(json['age']?.toString() ?? '0') ?? 0,
      balance: json['balance'] ?? '0.00',
      code: json['code'] ?? '',
      qrCode: json['qr_code'],
      cashbackRate: int.tryParse(json['cashback_rate']?.toString() ?? '0') ?? 0,
      image: json['image'],
      active: int.tryParse(json['active']?.toString() ?? '0') ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      storeDetails: json['store'] != null ? StoreDetails.fromJson(json['store']) : null,
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

  bool get isActive => active == 1;
  bool get isEmailVerified => emailVerifiedAt != null && emailVerifiedAt!.isNotEmpty;
  
  String get formattedBalance {
    try {
      final balanceValue = double.parse(balance);
      return balanceValue.toStringAsFixed(2);
    } catch (e) {
      return '0.00';
    }
  }

  // Get display email (prefer store details email if available)
  String get displayEmail => storeDetails?.email ?? email;
  
  // Get display phone (prefer store details phone if available)
  String get displayPhone => storeDetails?.phone ?? phone;
}
