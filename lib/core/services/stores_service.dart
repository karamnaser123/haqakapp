import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api/api_endpoints.dart';
import '../models/store_model.dart';
import 'auth_service.dart';

class StoresService {
  final AuthService _authService = AuthService();

  /// Get stores with pagination
  Future<PaginatedStoresResponse> getStores({int page = 1, String? search}) async {
    try {
      final token = _authService.token;
      if (token == null) {
        throw Exception('User not authenticated');
      }

      String url = '${ApiEndpoints.storesUrl}?page=$page';
      if (search != null && search.isNotEmpty) {
        url += '&search=$search';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return PaginatedStoresResponse.fromJson(data['stores']);
      } else {
        throw Exception('Failed to load stores: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching stores: $e');
    }
  }

  /// Get all stores (backward compatibility)
  Future<List<Store>> getAllStores() async {
    try {
      final paginatedResponse = await getStores();
      return paginatedResponse.data;
    } catch (e) {
      throw Exception('Error fetching all stores: $e');
    }
  }

  /// Get store by ID
  Future<Store> getStoreById(int storeId) async {
    try {
      final token = _authService.token;
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.get(
        Uri.parse('${ApiEndpoints.storesUrl}/$storeId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Store.fromJson(data);
      } else {
        throw Exception('Failed to load store: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching store: $e');
    }
  }

  /// Search stores by name with pagination
  Future<PaginatedStoresResponse> searchStores(String query, {int page = 1}) async {
    try {
      return await getStores(page: page, search: query);
    } catch (e) {
      throw Exception('Error searching stores: $e');
    }
  }

  /// Get active stores only
  Future<List<Store>> getActiveStores() async {
    try {
      final allStores = await getAllStores();
      return allStores.where((store) => store.isActive).toList();
    } catch (e) {
      throw Exception('Error fetching active stores: $e');
    }
  }
}
