import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order_model.dart';
import '../api/api_endpoints.dart';

class OrdersService {
  static final OrdersService _instance = OrdersService._internal();
  factory OrdersService() => _instance;
  OrdersService._internal();

  // جلب طلبات المستخدم
  Future<List<OrderModel>> getMyOrders() async {
    try {
      // الحصول على الـ token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        throw Exception('User not logged in');
      }

      print('Fetching my orders...');
      
      final response = await http.get(
        Uri.parse(ApiEndpoints.myordersUrl),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Orders API response code: ${response.statusCode}');
      print('Orders API response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> ordersList = data['data'];
          final List<OrderModel> orders = ordersList
              .map((order) => OrderModel.fromJson(order))
              .toList();
          
          print('Successfully loaded ${orders.length} orders');
          return orders;
        } else {
          throw Exception('Failed to load orders: ${data['message'] ?? 'Unknown error'}');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - please login again');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to load orders: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } catch (e) {
      print('Error fetching orders: $e');
      throw Exception('Failed to load orders: $e');
    }
  }

  // جلب تفاصيل طلب محدد
  Future<OrderModel?> getOrderDetails(int orderId) async {
    try {
      // الحصول على الـ token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        throw Exception('User not logged in');
      }

      print('Fetching order details for ID: $orderId');
      
      final response = await http.get(
        Uri.parse('${ApiEndpoints.myordersUrl}/$orderId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Order details API response code: ${response.statusCode}');
      print('Order details API response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true && data['data'] != null) {
          final order = OrderModel.fromJson(data['data']);
          print('Successfully loaded order details');
          return order;
        } else {
          throw Exception('Failed to load order details: ${data['message'] ?? 'Unknown error'}');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - please login again');
      } else if (response.statusCode == 404) {
        throw Exception('Order not found');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to load order details: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } catch (e) {
      print('Error fetching order details: $e');
      throw Exception('Failed to load order details: $e');
    }
  }

  // إلغاء طلب
  Future<bool> cancelOrder(int orderId) async {
    try {
      // الحصول على الـ token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        throw Exception('User not logged in');
      }

      print('Cancelling order ID: $orderId');
      
      final response = await http.post(
        Uri.parse('${ApiEndpoints.myordersUrl}/$orderId/cancel'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Cancel order API response code: ${response.statusCode}');
      print('Cancel order API response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          print('Order cancelled successfully');
          return true;
        } else {
          throw Exception(data['message'] ?? 'Failed to cancel order');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - please login again');
      } else if (response.statusCode == 404) {
        throw Exception('Order not found');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to cancel order: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } catch (e) {
      print('Error cancelling order: $e');
      throw Exception('Failed to cancel order: $e');
    }
  }

  // تتبع حالة الطلب
  Future<String> trackOrder(int orderId) async {
    try {
      // الحصول على الـ token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        throw Exception('User not logged in');
      }

      print('Tracking order ID: $orderId');
      
      final response = await http.get(
        Uri.parse('${ApiEndpoints.myordersUrl}/$orderId/track'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Track order API response code: ${response.statusCode}');
      print('Track order API response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true && data['status'] != null) {
          return data['status'];
        } else {
          throw Exception(data['message'] ?? 'Failed to track order');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - please login again');
      } else if (response.statusCode == 404) {
        throw Exception('Order not found');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to track order: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } catch (e) {
      print('Error tracking order: $e');
      throw Exception('Failed to track order: $e');
    }
  }
}
