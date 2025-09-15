class Governorate {
  final int id;
  final String nameEn;
  final String nameAr;
  final String createdAt;
  final String updatedAt;

  Governorate({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Governorate.fromJson(Map<String, dynamic> json) {
    return Governorate(
      id: json['id'] ?? 0,
      nameEn: json['name_en'] ?? '',
      nameAr: json['name_ar'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_en': nameEn,
      'name_ar': nameAr,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class City {
  final int id;
  final int governorateId;
  final String nameEn;
  final String nameAr;
  final String createdAt;
  final String updatedAt;

  City({
    required this.id,
    required this.governorateId,
    required this.nameEn,
    required this.nameAr,
    required this.createdAt,
    required this.updatedAt,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'] ?? 0,
      governorateId: json['governorate_id'] ?? 0,
      nameEn: json['name_en'] ?? '',
      nameAr: json['name_ar'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'governorate_id': governorateId,
      'name_en': nameEn,
      'name_ar': nameAr,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class GovernorateResponse {
  final bool success;
  final List<Governorate> data;

  GovernorateResponse({
    required this.success,
    required this.data,
  });

  factory GovernorateResponse.fromJson(Map<String, dynamic> json) {
    return GovernorateResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => Governorate.fromJson(item))
          .toList() ?? [],
    );
  }
}

class CityResponse {
  final bool success;
  final List<City> data;

  CityResponse({
    required this.success,
    required this.data,
  });

  factory CityResponse.fromJson(Map<String, dynamic> json) {
    return CityResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => City.fromJson(item))
          .toList() ?? [],
    );
  }
}