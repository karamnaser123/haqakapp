import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../l10n/app_localizations.dart';
import '../core/models/location_model.dart';
import '../core/models/product_model.dart';
import '../core/services/location_service.dart';
import '../core/services/cart_service.dart' as cart_service;
import '../core/services/auth_service.dart';
import '../core/api/api_endpoints.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _discountCodeController = TextEditingController();
  
  final LocationService _locationService = LocationService();
  final cart_service.CartService _cartService = cart_service.CartService();
  
  List<Governorate> _governorates = [];
  List<City> _cities = [];
  Governorate? _selectedGovernorate;
  City? _selectedCity;
  
  bool _isLoadingGovernorates = true;
  bool _isLoadingCities = false;
  bool _isSubmitting = false;
  
  List<cart_service.CartItem> _cartItems = [];
  double _totalPrice = 0.0;
  bool _isLoadingCart = true;
  Map<int, double> _itemPrices = {}; // To store correct prices from API
  double _cashbackAmount = 0.0; // Cashback amount from API
  
  // Additional discount from discount code
  double _discountAmount = 0.0;
  String? _discountCode;
  bool _isApplyingDiscount = false;
  
  // Discount details from API
  double _subtotal = 0.0; // Subtotal before discount
  double _totalPriceAfterDiscount = 0.0; // Final total after discount
  
  // Use cashback amount from API
  double get _totalCashback => _cashbackAmount;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }


  Future<void> _loadInitialData() async {
    await _loadGovernorates();
    await _loadCartFromServer();
  }

  Future<void> _loadGovernorates() async {
    try {
      setState(() {
        _isLoadingGovernorates = true;
      });
      
      final response = await _locationService.getGovernorates();
      setState(() {
        _governorates = response.data;
        _isLoadingGovernorates = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingGovernorates = false;
      });
      _showErrorSnackBar('${AppLocalizations.of(context)!.errorLoadingGovernorates}: $e');
    }
  }

  Future<void> _loadCities(int governorateId) async {
    try {
      setState(() {
        _isLoadingCities = true;
        _cities = [];
        _selectedCity = null;
      });
      
      final response = await _locationService.getCitiesByGovernorate(governorateId);
      setState(() {
        _cities = response.data;
        _isLoadingCities = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCities = false;
      });
      _showErrorSnackBar('${AppLocalizations.of(context)!.errorLoadingCities}: $e');
    }
  }

  Future<void> _loadCartFromServer() async {
    try {
      setState(() {
        _isLoadingCart = true;
      });
      
      // Use AuthService to get cart data properly
      final authService = AuthService();
      await authService.initialize(); // التأكد من تحميل الـ token
      final cartResponse = await authService.getCart();
      
      if (cartResponse.cart.isNotEmpty) {
        // Convert CartResponse to cart_service.CartItem list
        final List<cart_service.CartItem> items = [];
        double total = 0.0;
        
        print('Cart response items: ${cartResponse.cart.length}');
        
        for (var cartItem in cartResponse.cart) {
          for (var orderItem in cartItem.orderItems) {
            try {
              print('Processing item: ${orderItem.product.nameEn}');
              
              // Create cart_service.CartItem from orderItem
              // Convert CartProduct to ProductModel
              final productModel = ProductModel(
                id: orderItem.product.id,
                storeId: orderItem.product.storeId,
                categoryId: orderItem.product.categoryId,
                nameEn: orderItem.product.nameEn,
                nameAr: orderItem.product.nameAr,
                price: orderItem.product.price,
                discount: orderItem.product.discount,
                stock: orderItem.product.stock,
                descriptionEn: orderItem.product.descriptionEn,
                descriptionAr: orderItem.product.descriptionAr,
                active: orderItem.product.active,
                featured: orderItem.product.featured,
                newProduct: orderItem.product.newProduct,
                bestSeller: orderItem.product.bestSeller,
                topRated: orderItem.product.topRated,
                createdAt: orderItem.product.createdAt,
                updatedAt: orderItem.product.updatedAt,
                productImages: orderItem.product.productImages.map((img) => ProductImage(
                  id: img.id,
                  productId: img.productId,
                  image: img.image,
                  createdAt: img.createdAt,
                  updatedAt: img.updatedAt,
                )).toList(),
              );
              
              final cartItemObj = cart_service.CartItem(
                product: productModel,
                quantity: orderItem.quantity,
                isSynced: true,
              );
              
              items.add(cartItemObj);
              _itemPrices[orderItem.product.id] = orderItem.correctTotalPrice;
              total += orderItem.correctTotalPrice;
              
              print('Added item: ${orderItem.product.nameEn}, quantity: ${orderItem.quantity}, API price: ${orderItem.correctTotalPrice}');
            } catch (e) {
              print('Error parsing cart item: $e');
            }
          }
        }
        
        // Extract cashback amount from API
        double cashbackAmount = cartResponse.totalCashback;
        double subtotal = 0.0;
        double discountAmount = 0.0;
        double totalPriceAfterDiscount = cartResponse.totalPrice;
        String? discountCode;
        
        // Extract data from first cart item if available
        if (cartResponse.cart.isNotEmpty) {
          final cartItem = cartResponse.cart.first;
          
          // Extract details from cart item
          subtotal = double.tryParse(cartItem.totalPrice) ?? 0.0;
          discountAmount = 0.0; // Will be updated when discount is applied
          totalPriceAfterDiscount = double.tryParse(cartItem.totalPrice) ?? 0.0;
          cashbackAmount = double.tryParse(cartItem.cashbackAmount) ?? 0.0;
          
          print('Cart item details:');
          print('Subtotal: $subtotal');
          print('Discount Amount: $discountAmount');
          print('Total Price: $totalPriceAfterDiscount');
          print('Cashback Amount: $cashbackAmount');
        }
        
        print('Total items parsed: ${items.length}');
        print('Total price: $total');
        print('Cashback amount from API: $cashbackAmount');
        
        setState(() {
          _cartItems = items;
          _totalPrice = total;
          _cashbackAmount = cashbackAmount;
          
          // Update discount details from API
          _subtotal = subtotal;
          _discountAmount = discountAmount;
          _totalPriceAfterDiscount = totalPriceAfterDiscount;
          _discountCode = discountCode;
          
          _isLoadingCart = false;
        });
      } else {
        setState(() {
          _isLoadingCart = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingCart = false;
      });
      _showErrorSnackBar('${AppLocalizations.of(context)!.errorLoadingCart}: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Apply discount code
  Future<void> _applyDiscountCode() async {
    final code = _discountCodeController.text.trim();
    
    if (code.isEmpty) {
      _showErrorSnackBar(AppLocalizations.of(context)!.pleaseEnterDiscountCode);
      return;
    }

    setState(() {
      _isApplyingDiscount = true;
    });

    try {
      // Get Bearer token from AuthService
      final authService = AuthService();
      final token = authService.token;
      
      if (token == null) {
        _showErrorSnackBar(AppLocalizations.of(context)!.pleaseLoginFirst);
        setState(() {
          _isApplyingDiscount = false;
        });
        return;
      }

      // Send API request to apply discount code
      final response = await http.post(
        Uri.parse(ApiEndpoints.applydiscountUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'discount_code': code,
        }),
      );

      print('Apply discount response status: ${response.statusCode}');
      print('Apply discount response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData['success'] == true) {
          // Extract complete details from response
          final subtotal = double.tryParse(responseData['subtotal']?.toString() ?? '0') ?? 0.0;
          final discountAmount = double.tryParse(responseData['discount_amount']?.toString() ?? '0') ?? 0.0;
          final totalPriceAfterDiscount = double.tryParse(responseData['total_price']?.toString() ?? '0') ?? 0.0;
          final cashbackAmount = double.tryParse(responseData['cashback_amount']?.toString() ?? '0') ?? 0.0;
          
          print('Discount API Response:');
          print('Subtotal: $subtotal');
          print('Discount Amount: $discountAmount');
          print('Total Price After Discount: $totalPriceAfterDiscount');
          print('Cashback Amount: $cashbackAmount');
          
          setState(() {
            _discountCode = code;
            _discountAmount = discountAmount;
            _subtotal = subtotal;
            _totalPriceAfterDiscount = totalPriceAfterDiscount;
            _cashbackAmount = cashbackAmount;
            _isApplyingDiscount = false;
          });

          _showSuccessSnackBar(AppLocalizations.of(context)!.discountCodeAppliedSuccessfully);
          
          // Reload cart to get updated data
          await _loadCartFromServer();
        } else {
          _showErrorSnackBar(responseData['message'] ?? AppLocalizations.of(context)!.discountCodeIncorrect);
          setState(() {
            _isApplyingDiscount = false;
          });
        }
      } else {
        final errorData = json.decode(response.body);
        _showErrorSnackBar(errorData['message'] ?? AppLocalizations.of(context)!.errorApplyingDiscount);
        setState(() {
          _isApplyingDiscount = false;
        });
      }
    } catch (e) {
      print('Error applying discount: $e');
      setState(() {
        _isApplyingDiscount = false;
      });
      _showErrorSnackBar('${AppLocalizations.of(context)!.errorApplyingDiscount}: $e');
    }
  }

  // Remove discount code
  Future<void> _removeDiscountCode() async {
    if (_discountCode == null) return;

    setState(() {
      _isApplyingDiscount = true;
    });

    try {
      // Get Bearer token from AuthService
      final authService = AuthService();
      final token = authService.token;
      
      if (token == null) {
        _showErrorSnackBar(AppLocalizations.of(context)!.pleaseLoginFirst);
        setState(() {
          _isApplyingDiscount = false;
        });
        return;
      }

      // Send API request to remove discount code
      final response = await http.post(
        Uri.parse(ApiEndpoints.removediscountUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Remove discount response status: ${response.statusCode}');
      print('Remove discount response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData['success'] == true) {
          // Extract complete details from response بعد إزالة الخصم
          final subtotal = double.tryParse(responseData['subtotal']?.toString() ?? '0') ?? 0.0;
          final totalPriceAfterDiscount = double.tryParse(responseData['total_price']?.toString() ?? '0') ?? 0.0;
          final cashbackAmount = double.tryParse(responseData['cashback_amount']?.toString() ?? '0') ?? 0.0;
          
          print('Remove Discount API Response:');
          print('Subtotal: $subtotal');
          print('Total Price After Discount: $totalPriceAfterDiscount');
          print('Cashback Amount: $cashbackAmount');
          
          setState(() {
            _discountCode = null;
            _discountAmount = 0.0;
            _subtotal = subtotal;
            _totalPriceAfterDiscount = totalPriceAfterDiscount;
            _cashbackAmount = cashbackAmount;
            _discountCodeController.clear();
            _isApplyingDiscount = false;
          });

          _showSuccessSnackBar(AppLocalizations.of(context)!.discountCodeRemoved);
          
          // Reload cart to get updated data
          await _loadCartFromServer();
        } else {
          _showErrorSnackBar(responseData['message'] ?? AppLocalizations.of(context)!.errorRemovingDiscount);
          setState(() {
            _isApplyingDiscount = false;
          });
        }
      } else {
        final errorData = json.decode(response.body);
        _showErrorSnackBar(errorData['message'] ?? AppLocalizations.of(context)!.errorRemovingDiscount);
        setState(() {
          _isApplyingDiscount = false;
        });
      }
    } catch (e) {
      print('Error removing discount: $e');
      setState(() {
        _isApplyingDiscount = false;
      });
      _showErrorSnackBar('${AppLocalizations.of(context)!.errorRemovingDiscount}: $e');
    }
  }

  // Calculate final price after discount
  double get _finalTotalPrice {
    // If discount code is applied, use data from API
    if (_discountCode != null && _totalPriceAfterDiscount > 0) {
      return _totalPriceAfterDiscount;
    }
    // Otherwise use local calculation
    return _totalPrice - _discountAmount;
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedGovernorate == null) {
      _showErrorSnackBar(AppLocalizations.of(context)!.pleaseSelectGovernorate);
      return;
    }

    if (_selectedCity == null) {
      _showErrorSnackBar(AppLocalizations.of(context)!.pleaseSelectCity);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Get Bearer token from AuthService
      final authService = AuthService();
      final token = authService.token;
      
      if (token == null) {
        _showErrorSnackBar(AppLocalizations.of(context)!.pleaseLoginFirst);
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      // Send API request for order
      final response = await http.post(
        Uri.parse(ApiEndpoints.checkoutUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'city_id': _selectedCity!.id,
          'address': _addressController.text.trim(),
          'phone': _phoneController.text.trim(),
        }),
      );

      print('Checkout response status: ${response.statusCode}');
      print('Checkout response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData['success'] == true) {
          _showSuccessSnackBar(AppLocalizations.of(context)!.orderSubmittedSuccessfully);
          
          // Clear cart after submitting order
          await _cartService.clearCart();
          
          // Return to home page
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else {
          _showErrorSnackBar(responseData['message'] ?? AppLocalizations.of(context)!.errorSubmittingOrder);
        }
      } else {
        final errorData = json.decode(response.body);
        _showErrorSnackBar(errorData['message'] ?? AppLocalizations.of(context)!.errorSubmittingOrder);
      }
      
    } catch (e) {
      print('Error submitting order: $e');
      _showErrorSnackBar('${AppLocalizations.of(context)!.errorSubmittingOrder}: $e');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.checkoutOrder,
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue[800],
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            isRTL ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue[800]!,
              Colors.blue[100]!,
            ],
          ),
        ),
        child: Column(
          children: [
            // Order information
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.orderSummary,
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  if (_isLoadingCart) ...[
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ] else if (_cartItems.isEmpty) ...[
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          AppLocalizations.of(context)!.cartEmpty,
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Display total quantity
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.totalQuantity,
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[800],
                            ),
                          ),
                          Text(
                            '${_cartItems.fold(0, (sum, item) => sum + item.quantity)} ${AppLocalizations.of(context)!.pieces}',
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  
                  // Calculate total discount
                  Builder(
                    builder: (context) {
                      // If discount code is applied, use data from API
                      if (_discountCode != null && _subtotal > 0) {
                        return Column(
                          children: [
                            // Subtotal from API
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.originalTotal,
                                  style: GoogleFonts.cairo(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  '${_subtotal.toStringAsFixed(2)} ${AppLocalizations.of(context)!.jd}',
                                  style: GoogleFonts.cairo(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            
                            // خصم كود الخصم من API
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${AppLocalizations.of(context)!.discountCode} (${_discountCode})',
                                  style: GoogleFonts.cairo(
                                    fontSize: 14,
                                    color: Colors.red[600],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '-${_discountAmount.toStringAsFixed(2)} ${AppLocalizations.of(context)!.jd}',
                                  style: GoogleFonts.cairo(
                                    fontSize: 14,
                                    color: Colors.red[600],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                          ],
                        );
                      }
                      
                      // إذا لم يكن هناك كود خصم، لا تعرض أي خصم
                      return const SizedBox.shrink();
                    },
                  ),
                  
                  // عرض مبلغ الكاش باك
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.totalCashback,
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: _totalCashback > 0 ? Colors.green[600] : Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _totalCashback > 0 
                          ? '+${_totalCashback.toStringAsFixed(2)} ${AppLocalizations.of(context)!.jd}'
                          : '0.00 ${AppLocalizations.of(context)!.jd}',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: _totalCashback > 0 ? Colors.green[600] : Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (_totalCashback > 0) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.monetization_on,
                            color: Colors.green[600],
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${AppLocalizations.of(context)!.youWillEarn} ${_totalCashback.toStringAsFixed(2)} ${AppLocalizations.of(context)!.jd} ${AppLocalizations.of(context)!.cashbackOnThisOrder}',
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                color: Colors.green[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  
                  // المجموع النهائي
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.finalTotal,
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                        Text(
                          '${_finalTotalPrice.toStringAsFixed(2)} ${AppLocalizations.of(context)!.jd}',
                          style: GoogleFonts.cairo(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                  ],
                ],
              ),
            ),
            
            // نموذج البيانات
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.deliveryInformation,
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // اختيار المحافظة
                        Text(
                          '${AppLocalizations.of(context)!.governorate} *',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<Governorate>(
                              value: _selectedGovernorate,
                              hint: _isLoadingGovernorates
                                  ? Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(AppLocalizations.of(context)!.loading),
                                        ],
                                      ),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(AppLocalizations.of(context)!.chooseGovernorate),
                                    ),
                              isExpanded: true,
                              items: _governorates.map((governorate) {
                                return DropdownMenuItem<Governorate>(
                                  value: governorate,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Text(
                                      isRTL ? governorate.nameAr : governorate.nameEn,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: _isLoadingGovernorates
                                  ? null
                                  : (Governorate? newValue) {
                                      setState(() {
                                        _selectedGovernorate = newValue;
                                        _selectedCity = null;
                                        _cities = [];
                                      });
                                      if (newValue != null) {
                                        _loadCities(newValue.id);
                                      }
                                    },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // اختيار المدينة
                        Text(
                          '${AppLocalizations.of(context)!.city} *',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<City>(
                              value: _selectedCity,
                              hint: _isLoadingCities
                                  ? Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(AppLocalizations.of(context)!.loading),
                                        ],
                                      ),
                                    )
                                  : _selectedGovernorate == null
                                      ? Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Text(AppLocalizations.of(context)!.chooseGovernorateFirst),
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Text(AppLocalizations.of(context)!.chooseCity),
                                        ),
                              isExpanded: true,
                              items: _cities.map((city) {
                                return DropdownMenuItem<City>(
                                  value: city,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Text(
                                      isRTL ? city.nameAr : city.nameEn,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: _isLoadingCities || _selectedGovernorate == null
                                  ? null
                                  : (City? newValue) {
                                      setState(() {
                                        _selectedCity = newValue;
                                      });
                                    },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // حقل العنوان
                        Text(
                          '${AppLocalizations.of(context)!.detailedAddress} *',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _addressController,
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.enterDetailedAddress,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.all(12),
                          ),
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return AppLocalizations.of(context)!.pleaseEnterDetailedAddress;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        
                        // حقل رقم الهاتف
                        Text(
                          '${AppLocalizations.of(context)!.phoneNumber} *',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.enterPhoneNumber,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.all(12),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return AppLocalizations.of(context)!.pleaseEnterPhoneNumber;
                            }
                            if (value.length < 10) {
                              return AppLocalizations.of(context)!.phoneNumberMustBeAtLeast10;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        
                        // حقل كود الخصم
                        Text(
                          AppLocalizations.of(context)!.discountCodeOptional,
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _discountCodeController,
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(context)!.enterDiscountCode,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.all(12),
                                  suffixIcon: _discountCode != null
                                      ? IconButton(
                                          icon: const Icon(Icons.close),
                                          onPressed: _removeDiscountCode,
                                        )
                                      : null,
                                ),
                                enabled: _discountCode == null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _discountCode == null
                                    ? (_isApplyingDiscount ? null : _applyDiscountCode)
                                    : _removeDiscountCode,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _discountCode == null
                                      ? Colors.orange[600]
                                      : Colors.red[600],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: _isApplyingDiscount
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        _discountCode == null ? AppLocalizations.of(context)!.apply : AppLocalizations.of(context)!.remove,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                        
                        // عرض كود الخصم المطبق
                        if (_discountCode != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green[600],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${AppLocalizations.of(context)!.discountCodeApplied}: $_discountCode',
                                  style: TextStyle(
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 30),
                        
                        // زر إرسال الطلب
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submitOrder,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[800],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _isSubmitting
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        AppLocalizations.of(context)!.submitting,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(
                                    AppLocalizations.of(context)!.submitOrder,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _discountCodeController.dispose();
    super.dispose();
  }
}
