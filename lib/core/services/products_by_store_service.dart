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
        'store_id': storeId.toString(),
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
          // Clean the response body to handle malformed Unicode escapes
          String cleanedBody = response.body
              .replaceAll(RegExp(r'\\u[0-9a-fA-F]{1,3}(?![0-9a-fA-F])'), '') // Remove incomplete Unicode escapes
              .replaceAll(RegExp(r'\\[^u]'), ''); // Remove other malformed escapes
          
          final Map<String, dynamic> data = json.decode(cleanedBody);
          return ProductsByStoreResponse.fromJson(data);
        } catch (e) {
          // If cleaning doesn't work, try to parse the original response
          try {
            final Map<String, dynamic> data = json.decode(response.body);
            return ProductsByStoreResponse.fromJson(data);
          } catch (e2) {
            throw Exception('Invalid data format from server. Please try again.');
          }
        }
      } else {
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
    return ProductsByStoreResponse(
      products: (json['products'] as List)
          .map((productJson) => ProductModel.fromJson(productJson))
          .toList(),
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      total: json['total'] ?? 0,
      perPage: json['per_page'] ?? 10,
    );
  }
}
