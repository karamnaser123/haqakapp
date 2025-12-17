import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../api/api_endpoints.dart';
import '../models/store_model.dart';
import 'auth_service.dart';

class StoresService {
  final AuthService _authService = AuthService();

  /// Get stores with pagination
  Future<PaginatedStoresResponse> getStores({int page = 1, String? search}) async {
    try {
      // تحميل الـ token أولاً
      await _authService.initialize();
      final token = _authService.token;
      if (token == null) {
        throw Exception('User not authenticated');
      }

      String url = '${ApiEndpoints.storesUrl}?page=$page';
      if (search != null && search.isNotEmpty) {
        url += '&search=${Uri.encodeComponent(search)}';
      }

      print('Fetching stores from: $url');
      print('Token: $token');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Stores response code: ${response.statusCode}');
      print('Stores response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // التحقق من وجود البيانات
        if (data['stores'] != null) {
          // البيانات موجودة في 'stores' مع pagination
          return PaginatedStoresResponse.fromJson(data['stores']);
        } else if (data['data'] != null) {
          // إذا كانت البيانات في 'data' مباشرة
          return PaginatedStoresResponse.fromJson(data);
        } else if (data['products'] != null) {
          // إذا كانت البيانات في 'products' (من productsbystore)
          // نحتاج لتحويل المنتجات إلى متاجر
          return _convertProductsToStores(data['products']);
        } else {
          throw Exception('Invalid response format: missing stores data');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - please login again');
      } else if (response.statusCode == 500) {
        throw Exception('Server error - please try again later');
      } else {
        final errorData = json.decode(response.body);
        final message = errorData['message'] ?? 'Failed to load stores: ${response.statusCode}';
        throw Exception(message);
      }
    } on FormatException {
      throw Exception('Invalid response format from server');
    } on SocketException {
      throw Exception('Check your internet connection');
    } catch (e) {
      print('Error fetching stores: $e');
      throw Exception('Error fetching stores: $e');
    }
  }

  /// Convert products response to stores response
  PaginatedStoresResponse _convertProductsToStores(Map<String, dynamic> productsData) {
    try {
      final List<dynamic> products = productsData['data'] ?? [];
      final List<Store> stores = [];
      
      // استخراج المتاجر الفريدة من المنتجات
      final Map<int, Store> uniqueStores = {};
      
      for (var product in products) {
        if (product['store'] != null) {
          final storeData = product['store'];
          final storeId = storeData['id'];
          
          if (!uniqueStores.containsKey(storeId)) {
            // إنشاء متجر جديد مع صورة من المنتج
            final store = Store.fromJson(storeData);
            
            // إضافة صورة من المنتج إذا لم تكن موجودة في المتجر
            if (store.image == null || store.image!.isEmpty) {
              final productImages = product['product_images'] as List<dynamic>?;
              if (productImages != null && productImages.isNotEmpty) {
                final firstImage = productImages.first['image'] as String?;
                if (firstImage != null && firstImage.isNotEmpty) {
                  // إنشاء متجر جديد مع الصورة
                  final storeWithImage = Store(
                    id: store.id,
                    name: store.name,
                    email: store.email,
                    phone: store.phone,
                    otp: store.otp,
                    emailVerifiedAt: store.emailVerifiedAt,
                    gender: store.gender,
                    age: store.age,
                    balance: store.balance,
                    code: store.code,
                    qrCode: store.qrCode,
                    cashbackRate: store.cashbackRate,
                    image: firstImage, // استخدام صورة المنتج
                    active: store.active,
                    createdAt: store.createdAt,
                    updatedAt: store.updatedAt,
                    storeDetails: store.storeDetails,
                  );
                  uniqueStores[storeId] = storeWithImage;
                } else {
                  uniqueStores[storeId] = store;
                }
              } else {
                uniqueStores[storeId] = store;
              }
            } else {
              uniqueStores[storeId] = store;
            }
          }
        }
      }
      
      stores.addAll(uniqueStores.values);
      
      print('Converted ${stores.length} unique stores from products');
      
      return PaginatedStoresResponse(
        data: stores,
        currentPage: productsData['current_page'] ?? 1,
        lastPage: productsData['last_page'] ?? 1,
        perPage: productsData['per_page'] ?? 10,
        total: productsData['total'] ?? stores.length,
        from: productsData['from'] ?? 1,
        to: productsData['to'] ?? stores.length,
        firstPageUrl: productsData['first_page_url'],
        lastPageUrl: productsData['last_page_url'],
        nextPageUrl: productsData['next_page_url'],
        prevPageUrl: productsData['prev_page_url'],
        path: productsData['path'],
        links: (productsData['links'] as List<dynamic>?)
            ?.map((link) => PaginationLink.fromJson(link))
            .toList() ?? [],
      );
    } catch (e) {
      print('Error converting products to stores: $e');
      throw Exception('Error converting products to stores: $e');
    }
  }

  /// Get all stores (backward compatibility)
  Future<List<Store>> getAllStores() async {
    try {
      final paginatedResponse = await getStores();
      return paginatedResponse.data;
    } catch (e) {
      print('Error fetching all stores: $e');
      throw Exception('Error fetching all stores: $e');
    }
  }

  /// Get store by ID
  Future<Store> getStoreById(int storeId) async {
    try {
      // تحميل الـ token أولاً
      await _authService.initialize();
      final token = _authService.token;
      if (token == null) {
        throw Exception('User not authenticated');
      }

      print('Fetching store by ID: $storeId');
      print('Token: $token');

      final response = await http.get(
        Uri.parse('${ApiEndpoints.storesUrl}/$storeId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Store by ID response code: ${response.statusCode}');
      print('Store by ID response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Store.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - please login again');
      } else if (response.statusCode == 404) {
        throw Exception('Store not found');
      } else if (response.statusCode == 500) {
        throw Exception('Server error - please try again later');
      } else {
        final errorData = json.decode(response.body);
        final message = errorData['message'] ?? 'Failed to load store: ${response.statusCode}';
        throw Exception(message);
      }
    } on FormatException {
      throw Exception('Invalid response format from server');
    } on SocketException {
      throw Exception('Check your internet connection');
    } catch (e) {
      print('Error fetching store by ID: $e');
      throw Exception('Error fetching store: $e');
    }
  }

  /// Search stores by name with pagination
  Future<PaginatedStoresResponse> searchStores(String query, {int page = 1}) async {
    try {
      print('Searching stores with query: $query, page: $page');
      return await getStores(page: page, search: query);
    } catch (e) {
      print('Error searching stores: $e');
      throw Exception('Error searching stores: $e');
    }
  }

  /// Get active stores only
  Future<List<Store>> getActiveStores() async {
    try {
      print('Fetching active stores only');
      final allStores = await getAllStores();
      final activeStores = allStores.where((store) => store.isActive).toList();
      print('Found ${activeStores.length} active stores out of ${allStores.length} total stores');
      return activeStores;
    } catch (e) {
      print('Error fetching active stores: $e');
      throw Exception('Error fetching active stores: $e');
    }
  }
}
