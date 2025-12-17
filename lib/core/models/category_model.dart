import '../utils/image_helper.dart';

class CategoryModel {
  final int id;
  final int? parentId;
  final String nameEn;
  final String nameAr;
  final String? image;
  final String? createdAt;
  final String? updatedAt;
  final int productsCount;
  final int childrenCount;

  CategoryModel({
    required this.id,
    this.parentId,
    required this.nameEn,
    required this.nameAr,
    this.image,
    this.createdAt,
    this.updatedAt,
    this.productsCount = 0,
    this.childrenCount = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final rawImageUrl = json['image'];
    
    return CategoryModel(
      id: json['id'] ?? 0,
      parentId: json['parent_id'] != null ? int.tryParse(json['parent_id'].toString()) : null,
      nameEn: json['name_en'] ?? '',
      nameAr: json['name_ar'] ?? '',
      image: rawImageUrl != null ? ImageHelper.getImageUrl(rawImageUrl) : null,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      productsCount: int.tryParse(json['products_count']?.toString() ?? '0') ?? 0,
      childrenCount: int.tryParse(json['children_count']?.toString() ?? '0') ?? 0,
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
      'products_count': productsCount,
      'children_count': childrenCount,
    };
  }

  // دالة للتحقق من أن الفئة هي فئة رئيسية
  bool get isParent {
    return parentId == null;
  }

  // دالة للتحقق من أن الفئة هي فئة فرعية
  bool get isSubCategory {
    return parentId != null;
  }
}

class CategoriesResponse {
  final List<CategoryModel> categories;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final String? nextPageUrl;
  final String? prevPageUrl;

  CategoriesResponse({
    required this.categories,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  factory CategoriesResponse.fromJson(Map<String, dynamic> json) {
    final categoriesData = json['categories'];
    print('Categories data structure: $categoriesData');
    
    // التحقق من وجود 'data' key
    List<dynamic> categoriesList;
    if (categoriesData.containsKey('data')) {
      // إذا كان pagination موجود
      categoriesList = categoriesData['data'] as List<dynamic>? ?? [];
      print('Using pagination data, categories count: ${categoriesList.length}');
    } else {
      // إذا كان array مباشر
      categoriesList = categoriesData as List<dynamic>? ?? [];
      print('Using direct array, categories count: ${categoriesList.length}');
    }
    
    final response = CategoriesResponse(
      categories: categoriesList
          .map((category) => CategoryModel.fromJson(category))
          .toList(),
      currentPage: int.tryParse(categoriesData['current_page']?.toString() ?? '1') ?? 1,
      lastPage: int.tryParse(categoriesData['last_page']?.toString() ?? '1') ?? 1,
      perPage: int.tryParse(categoriesData['per_page']?.toString() ?? '20') ?? 10,
      total: int.tryParse(categoriesData['total']?.toString() ?? '0') ?? 0,
      nextPageUrl: categoriesData['next_page_url'],
      prevPageUrl: categoriesData['prev_page_url'],
    );
    
    print('Parsed response - Categories: ${response.categories.length}, Current page: ${response.currentPage}, Last page: ${response.lastPage}, Has next: ${response.hasNextPage}');
    
    return response;
  }

  Map<String, dynamic> toJson() {
    return {
      'categories': {
        'data': categories.map((category) => category.toJson()).toList(),
        'current_page': currentPage,
        'last_page': lastPage,
        'per_page': perPage,
        'total': total,
        'next_page_url': nextPageUrl,
        'prev_page_url': prevPageUrl,
      },
    };
  }

  bool get hasNextPage => nextPageUrl != null;
  bool get hasPrevPage => prevPageUrl != null;

  // دالة للحصول على الفئات الرئيسية فقط
  List<CategoryModel> get parentCategories {
    return categories.where((category) => category.isParent).toList();
  }

  // دالة للحصول على الفئات الفرعية لفئة معينة
  List<CategoryModel> getSubCategories(int parentId) {
    return categories.where((category) => category.parentId == parentId).toList();
  }
}
