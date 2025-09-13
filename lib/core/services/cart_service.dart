import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';
import '../api/api_endpoints.dart';
import '../../screens/home_screen.dart';

class CartItem {
  final ProductModel product;
  int quantity;
  bool isSynced; // هل تم مزامنة هذا العنصر مع الخادم؟

  CartItem({
    required this.product,
    this.quantity = 1,
    this.isSynced = false,
  });

  double get totalPrice => product.finalPrice * quantity;

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
      'is_synced': isSynced,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: ProductModel.fromJson(json['product']),
      quantity: json['quantity'] ?? 1,
      isSynced: json['is_synced'] ?? false,
    );
  }
}

const String _cartKey = 'cart_items';
const String _pendingSyncKey = 'pending_sync';

class CartService {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  List<CartItem> _cartItems = [];

  // تحميل السلة من التخزين المحلي
  Future<void> loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = prefs.getString(_cartKey);
      
      if (cartData != null) {
        final List<dynamic> cartList = json.decode(cartData);
        _cartItems = cartList.map((item) => CartItem.fromJson(item)).toList();
      }
    } catch (e) {
      print('Error loading cart: $e');
      _cartItems = [];
    }
  }

  // حفظ السلة في التخزين المحلي
  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = json.encode(_cartItems.map((item) => item.toJson()).toList());
      await prefs.setString(_cartKey, cartData);
    } catch (e) {
      print('Error saving cart: $e');
    }
  }

  // إضافة منتج إلى السلة (هجين: محلي + خادم)
  Future<bool> addToCart(ProductModel product, {int quantity = 1}) async {
    try {
      await loadCart();
      
      // التحقق من store_id
      if (_cartItems.isNotEmpty) {
        final existingStoreId = _cartItems.first.product.storeId;
        if (existingStoreId != product.storeId) {
          // رمي استثناء خاص لمعالجته في الواجهة
          throw Exception('DIFFERENT_STORE');
        }
      }
      
      // 1. إضافة محلياً فوراً (تجربة فورية)
      await _addToLocalCart(product, quantity);
      
      // 2. مزامنة مع الخادم في الخلفية
      _syncToServerInBackground(product.id, quantity);
      
      // 3. إشعار تحديث السلة
      CartUpdateNotifier.notifyCartUpdate();
      
      return true; // نجح فوراً
    } catch (e) {
      print('Error adding to cart: $e');
      // إعادة رمي الاستثناء إذا كان DIFFERENT_STORE
      if (e.toString().contains('DIFFERENT_STORE')) {
        rethrow;
      }
      return false;
    }
  }

  // إضافة منتج إلى السلة مع إمكانية تفريغ السلة
  Future<bool> addToCartWithClear(ProductModel product, {int quantity = 1}) async {
    try {
      await loadCart();
      
      // تفريغ السلة إذا كانت تحتوي على منتجات من متجر مختلف
      if (_cartItems.isNotEmpty) {
        final existingStoreId = _cartItems.first.product.storeId;
        if (existingStoreId != product.storeId) {
          await clearCart();
        }
      }
      
      // 1. إضافة محلياً فوراً (تجربة فورية)
      await _addToLocalCart(product, quantity);
      
      // 2. مزامنة مع الخادم في الخلفية
      _syncToServerInBackground(product.id, quantity);
      
      // 3. إشعار تحديث السلة
      CartUpdateNotifier.notifyCartUpdate();
      
      return true; // نجح فوراً
    } catch (e) {
      print('Error adding to cart with clear: $e');
      return false;
    }
  }

  // إضافة محلياً (فوري)
  Future<void> _addToLocalCart(ProductModel product, int quantity) async {
    await loadCart();
    
    // البحث عن المنتج في السلة
    final existingItemIndex = _cartItems.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingItemIndex != -1) {
      // تحديث الكمية إذا كان المنتج موجود
      _cartItems[existingItemIndex].quantity += quantity;
      _cartItems[existingItemIndex].isSynced = false; // يحتاج مزامنة
    } else {
      // إضافة منتج جديد
      _cartItems.add(CartItem(
        product: product, 
        quantity: quantity,
        isSynced: false, // يحتاج مزامنة
      ));
    }

    await _saveCart();
  }

  // مزامنة مع الخادم في الخلفية
  Future<void> _syncToServerInBackground(int productId, int quantity) async {
    try {
      await _addToCartAPI(productId, quantity);
      
      // تحديث حالة المزامنة
      await _markAsSynced(productId);
    } catch (e) {
      print('Background sync failed: $e');
      // حفظ في قائمة الانتظار للمزامنة لاحقاً
      await _addToPendingSync(productId, quantity);
    }
  }

  // إضافة منتج إلى السلة عبر API
  Future<bool> _addToCartAPI(int productId, int quantity) async {
    try {
      // الحصول على الـ token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        throw Exception('User not logged in');
      }

      print('Syncing to server...');
      print('Product ID: $productId, Quantity: $quantity');
      
      final response = await http.post(
        Uri.parse(ApiEndpoints.addtocartUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'product_id': productId,
          'quantity': quantity,
        }),
      );

      print('Sync response code: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Product synced successfully');
        return true;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - please login again');
      } else if (response.statusCode == 422) {
        final responseData = jsonDecode(response.body);
        final errors = responseData['errors'];
        if (errors != null) {
          if (errors['product_id'] != null) {
            throw Exception('Product ID is required');
          } else if (errors['quantity'] != null) {
            throw Exception('Quantity must be greater than 0');
          }
        }
        throw Exception('Validation error');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to sync with server');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } catch (e) {
      print('Error syncing to server: $e');
      throw Exception(e.toString());
    }
  }

  // تحديد العنصر كمزامن
  Future<void> _markAsSynced(int productId) async {
    await loadCart();
    final itemIndex = _cartItems.indexWhere(
      (item) => item.product.id == productId,
    );
    
    if (itemIndex != -1) {
      _cartItems[itemIndex].isSynced = true;
      await _saveCart();
    }
  }

  // إضافة إلى قائمة انتظار المزامنة
  Future<void> _addToPendingSync(int productId, int quantity) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingData = prefs.getString(_pendingSyncKey);
      
      List<Map<String, dynamic>> pendingList = [];
      if (pendingData != null) {
        pendingList = List<Map<String, dynamic>>.from(json.decode(pendingData));
      }
      
      pendingList.add({
        'product_id': productId,
        'quantity': quantity,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      
      await prefs.setString(_pendingSyncKey, json.encode(pendingList));
    } catch (e) {
      print('Error adding to pending sync: $e');
    }
  }

  // مزامنة العناصر المعلقة
  Future<void> syncPendingItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingData = prefs.getString(_pendingSyncKey);
      
      if (pendingData == null) return;
      
      final List<dynamic> pendingList = json.decode(pendingData);
      
      for (var item in pendingList) {
        try {
          await _addToCartAPI(item['product_id'], item['quantity']);
          print('Synced pending item: ${item['product_id']}');
        } catch (e) {
          print('Failed to sync pending item: $e');
        }
      }
      
      // مسح قائمة الانتظار بعد المزامنة
      await prefs.remove(_pendingSyncKey);
      
      // تحديث حالة المزامنة لجميع العناصر
      await loadCart();
      for (var item in _cartItems) {
        if (!item.isSynced) {
          await _markAsSynced(item.product.id);
        }
      }
    } catch (e) {
      print('Error syncing pending items: $e');
    }
  }

  // إزالة منتج من السلة
  Future<bool> removeFromCart(int productId) async {
    try {
      await loadCart();
      
      _cartItems.removeWhere((item) => item.product.id == productId);
      await _saveCart();
      
      // محاولة إزالة من الخادم أيضاً
      _removeFromServerInBackground(productId);
      
      // إشعار تحديث السلة
      CartUpdateNotifier.notifyCartUpdate();
      
      return true;
    } catch (e) {
      print('Error removing from cart: $e');
      return false;
    }
  }

  // إزالة من الخادم في الخلفية
  Future<void> _removeFromServerInBackground(int productId) async {
    try {
      // الحصول على الـ token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        throw Exception('User not logged in');
      }

      print('Removing from server: $productId');
      
      final response = await http.post(
        Uri.parse(ApiEndpoints.removefromcartUrl),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {
          'product_id': productId.toString(),
        },
      );

      print('Remove from cart response code: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Product removed from server successfully');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - please login again');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to remove from server');
      }
    } catch (e) {
      print('Error removing from server: $e');
    }
  }

  // إزالة منتج من السلة على الخادم (مباشر)
  Future<bool> removeFromServer(int productId) async {
    try {
      // الحصول على الـ token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        throw Exception('User not logged in');
      }

      print('Removing from server: $productId');
      print('API URL: ${ApiEndpoints.removefromcartUrl}');
      
      final response = await http.post(
        Uri.parse(ApiEndpoints.removefromcartUrl),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {
          'product_id': productId.toString(),
        },
      );

      print('Remove from cart response code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Product removed from server successfully');
        return true;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - please login again');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to remove from server');
      }
    } catch (e) {
      print('Error removing from server: $e');
      return false;
    }
  }

  // تحديث كمية منتج في السلة
  Future<bool> updateQuantity(int productId, int quantity) async {
    try {
      await loadCart();
      
      final itemIndex = _cartItems.indexWhere(
        (item) => item.product.id == productId,
      );

      if (itemIndex != -1) {
        if (quantity <= 0) {
          _cartItems.removeAt(itemIndex);
        } else {
          _cartItems[itemIndex].quantity = quantity;
          _cartItems[itemIndex].isSynced = false; // يحتاج مزامنة
        }
        await _saveCart();
        
        // مزامنة التغيير مع الخادم
        if (quantity > 0) {
          _updateQuantityAPI(productId, quantity);
        }
        
        // إشعار تحديث السلة
        CartUpdateNotifier.notifyCartUpdate();
        
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating quantity: $e');
      return false;
    }
  }

  // زيادة كمية منتج في السلة
  Future<bool> increaseQuantity(int productId) async {
    try {
      await loadCart();
      
      final itemIndex = _cartItems.indexWhere(
        (item) => item.product.id == productId,
      );

      if (itemIndex != -1) {
        _cartItems[itemIndex].quantity++;
        _cartItems[itemIndex].isSynced = false; // يحتاج مزامنة
        await _saveCart();
        
        // مزامنة التغيير مع الخادم
        _updateQuantityAPI(productId, _cartItems[itemIndex].quantity);
        
        // إشعار تحديث السلة
        CartUpdateNotifier.notifyCartUpdate();
        
        return true;
      }
      return false;
    } catch (e) {
      print('Error increasing quantity: $e');
      return false;
    }
  }

  // تقليل كمية منتج في السلة
  Future<bool> decreaseQuantity(int productId) async {
    try {
      await loadCart();
      
      final itemIndex = _cartItems.indexWhere(
        (item) => item.product.id == productId,
      );

      if (itemIndex != -1) {
        if (_cartItems[itemIndex].quantity > 1) {
          _cartItems[itemIndex].quantity--;
          _cartItems[itemIndex].isSynced = false; // يحتاج مزامنة
          await _saveCart();
          
          // مزامنة التغيير مع الخادم
          _updateQuantityAPI(productId, _cartItems[itemIndex].quantity);
        } else {
          // إذا كانت الكمية 1، احذف المنتج من السلة
          return await removeFromCart(productId);
        }
        
        // إشعار تحديث السلة
        CartUpdateNotifier.notifyCartUpdate();
        
        return true;
      }
      return false;
    } catch (e) {
      print('Error decreasing quantity: $e');
      return false;
    }
  }

  // الحصول على جميع عناصر السلة
  Future<List<CartItem>> getCartItems() async {
    await loadCart();
    return List.unmodifiable(_cartItems);
  }

  // الحصول على إجمالي الكمية في السلة (مجموع الكميات)
  Future<int> getCartItemsCount() async {
    await loadCart();
    final totalQuantity = _cartItems.fold<int>(0, (sum, item) => sum + item.quantity);
    print('Cart items count: ${_cartItems.length} unique products');
    print('Total quantity: $totalQuantity');
    print('Cart items: ${_cartItems.map((item) => '${item.product.nameEn} (qty: ${item.quantity})').toList()}');
    return totalQuantity; // إجمالي الكمية
  }

  // الحصول على عدد المنتجات المختلفة في السلة
  Future<int> getUniqueItemsCount() async {
    await loadCart();
    return _cartItems.length; // عدد المنتجات المختلفة
  }

  // الحصول على إجمالي الكمية (مجموع الكميات)
  Future<int> getTotalQuantity() async {
    await loadCart();
    return _cartItems.fold<int>(0, (sum, item) => sum + item.quantity);
  }

  // الحصول على إجمالي السعر
  Future<double> getTotalPrice() async {
    await loadCart();
    return _cartItems.fold<double>(0.0, (sum, item) => sum + item.totalPrice);
  }

  // مسح السلة بالكامل
  Future<bool> clearCart() async {
    try {
      _cartItems.clear();
      await _saveCart();
      
      // مسح من الخادم أيضاً
      _clearServerCartInBackground();
      
      // إشعار تحديث السلة
      CartUpdateNotifier.notifyCartUpdate();
      
      return true;
    } catch (e) {
      print('Error clearing cart: $e');
      return false;
    }
  }

  // مسح السلة من الخادم في الخلفية
  Future<void> _clearServerCartInBackground() async {
    try {
      // هنا يمكنك إضافة API لمسح السلة على الخادم
      print('Clearing server cart');
    } catch (e) {
      print('Error clearing server cart: $e');
    }
  }

  // فحص وجود منتج في السلة
  Future<bool> isInCart(int productId) async {
    await loadCart();
    return _cartItems.any((item) => item.product.id == productId);
  }

  // الحصول على كمية منتج في السلة
  Future<int> getProductQuantity(int productId) async {
    await loadCart();
    final item = _cartItems.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => CartItem(
        product: ProductModel(
          id: 0,
          storeId: 0,
          categoryId: 0,
          nameEn: '',
          nameAr: '',
          price: '0.00',
          discount: '0.00',
          stock: 0,
          descriptionEn: '',
          descriptionAr: '',
          active: 0,
          featured: 0,
          newProduct: 0,
          bestSeller: 0,
          topRated: 0,
          createdAt: '',
          updatedAt: '',
          productImages: [],
        ),
        quantity: 0,
      ),
    );
    return item.quantity;
  }

  // فحص حالة المزامنة
  Future<bool> isSynced(int productId) async {
    await loadCart();
    final item = _cartItems.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => CartItem(
        product: ProductModel(
          id: 0,
          storeId: 0,
          categoryId: 0,
          nameEn: '',
          nameAr: '',
          price: '0.00',
          discount: '0.00',
          stock: 0,
          descriptionEn: '',
          descriptionAr: '',
          active: 0,
          featured: 0,
          newProduct: 0,
          bestSeller: 0,
          topRated: 0,
          createdAt: '',
          updatedAt: '',
          productImages: [],
        ),
        quantity: 0,
        isSynced: false,
      ),
    );
    return item.isSynced;
  }

  // إعادة مزامنة عنصر معين
  Future<bool> resyncItem(int productId) async {
    try {
      await loadCart();
      final item = _cartItems.firstWhere(
        (item) => item.product.id == productId,
        orElse: () => throw Exception('Item not found'),
      );
      
      await _addToCartAPI(productId, item.quantity);
      await _markAsSynced(productId);
      
      return true;
    } catch (e) {
      print('Error resyncing item: $e');
      return false;
    }
  }

  // تحديث كمية منتج على الخادم
  Future<void> _updateQuantityAPI(int productId, int quantity) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        throw Exception('User not logged in');
      }

      print('Updating quantity on server: Product ID: $productId, Quantity: $quantity');
      
      final response = await http.post(
        Uri.parse(ApiEndpoints.updatequantityUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'product_id': productId,
          'quantity': quantity,
        }),
      );

      print('Update quantity response code: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Quantity updated successfully');
        await _markAsSynced(productId);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - please login again');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update quantity');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } catch (e) {
      print('Error updating quantity on server: $e');
      throw Exception(e.toString());
    }
  }

  // حذف السلة كاملة من الخادم
  Future<bool> clearCartFromServer() async {
    try {
      // الحصول على الـ token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        throw Exception('User not logged in');
      }

      print('Clearing cart from server...');
      
      final response = await http.post(
        Uri.parse(ApiEndpoints.removeallfromcartUrl),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Clear cart response code: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Cart cleared from server successfully');
        return true;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - please login again');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to clear cart from server');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } catch (e) {
      print('Error clearing cart from server: $e');
      return false;
    }
  }

}