import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api/api_endpoints.dart';
import '../models/product_model.dart';
import 'auth_service.dart';

class ProductsByStoreService {
  final AuthService _authService = AuthService();
  Future<ProductsByStoreResponse> getProductsByStore({
    required int storeId,
    int page = 1,
    String? search,
    String? categoryId,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final token = _authService.token;
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final Map<String, String> queryParams = {
        'page': page.toString(),
        'per_page': '20', // طلب 20 منتج في كل صفحة
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      if (categoryId != null && categoryId.isNotEmpty) {
        queryParams['category_id'] = categoryId;
      }

      if (sortBy != null && sortBy.isNotEmpty) {
        queryParams['sort_by'] = sortBy;
      }

      if (sortOrder != null && sortOrder.isNotEmpty) {
        queryParams['sort_order'] = sortOrder;
      }

      final uri = Uri.parse('${ApiEndpoints.productsbystoreUrl}$storeId').replace(
        queryParameters: queryParams,
      );

      // طباعة URL للتشخيص
      print('ProductsByStore API URL: $uri');
      print('Query params: $queryParams');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        try {
          // استخدام JSON decode مباشرة بدون cleaning لأن الـ cleaning كان يفسد URLs
          final Map<String, dynamic> data = json.decode(response.body);
          final responseObj = ProductsByStoreResponse.fromJson(data);
          
          // طباعة للتشخيص
          print('Products loaded: ${responseObj.products.length} products');
          print('Current page: ${responseObj.currentPage}, Last page: ${responseObj.lastPage}');
          print('Per page: ${responseObj.perPage}, Total: ${responseObj.total}');
          
          return responseObj;
        } catch (e) {
          print('Error parsing response: $e');
          print('Response body: ${response.body}');
          throw Exception('Invalid data format from server. Please try again.');
        }
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading products: $e');
    }
  }
}

class ProductsByStoreResponse {
  final List<ProductModel> products;
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;

  ProductsByStoreResponse({
    required this.products,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.perPage,
  });

  factory ProductsByStoreResponse.fromJson(Map<String, dynamic> json) {
    // الـ API يرجع البيانات في هيكل مختلف
    final productsData = json['products'] ?? {};
    final data = productsData['data'] as List<dynamic>? ?? [];
    
    // طباعة للتشخيص
    print('Parsing products response:');
    print('  - productsData keys: ${productsData.keys}');
    print('  - data length: ${data.length}');
    print('  - per_page from API: ${productsData['per_page']}');
    
    // طباعة معلومات الصور للمنتج الأول
    if (data.isNotEmpty) {
      final firstProduct = data[0] as Map<String, dynamic>;
      final productImages = firstProduct['product_images'] as List<dynamic>? ?? [];
      print('  - First product ID: ${firstProduct['id']}');
      print('  - First product images count: ${productImages.length}');
      if (productImages.isNotEmpty) {
        print('  - First product first image: ${productImages[0]['image']}');
      }
    }
    
    final products = data.map((productJson) {
      final product = ProductModel.fromJson(productJson);
      // طباعة للتشخيص
      print('  - Product ID: ${product.id}, Images count: ${product.productImages.length}');
      if (product.productImages.isNotEmpty) {
        print('    - First image URL: ${product.productImages.first.image}');
        print('    - allImages: ${product.allImages}');
      }
      return product;
    }).toList();
    
    return ProductsByStoreResponse(
      products: products,
      currentPage: int.tryParse(productsData['current_page']?.toString() ?? '1') ?? 1,
      lastPage: int.tryParse(productsData['last_page']?.toString() ?? '1') ?? 1,
      total: int.tryParse(productsData['total']?.toString() ?? '0') ?? 0,
      perPage: int.tryParse(productsData['per_page']?.toString() ?? '20') ?? 20,
    );
  }
}
