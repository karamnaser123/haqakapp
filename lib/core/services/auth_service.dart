import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_endpoints.dart';
import '../models/user_model.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/cart_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  String? _token;

  // الحصول على الـ token
  String? get token => _token;

  // تحميل الـ token من التخزين المحلي
  Future<void> _loadToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');
    } catch (e) {
      print('Error loading token: $e');
    }
  }

  // حفظ الـ token في التخزين المحلي
  Future<void> _saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      _token = token;
    } catch (e) {
      print('Error saving token: $e');
    }
  }

  // حذف الـ token من التخزين المحلي
  Future<void> _clearToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      _token = null;
    } catch (e) {
      print('Error clearing token: $e');
    }
  }


  // تحديث الملف الشخصي
  Future<void> updateProfile({
    required String name,
    int? age,
    String? gender,
    File? image,
  }) async {
    try {
      // التأكد من تحميل الـ token
      if (_token == null) {
        await _loadToken();
      }
      
      if (_token == null) {
        throw Exception('User not logged in');
      }

      print('Updating profile...');
      print('Name: $name');
      print('Age: $age');
      print('Gender: $gender');
      print('Has image: ${image != null}');

      // إنشاء multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.updateProfile}'),
      );

      // إضافة headers
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $_token',
      });

      // إضافة البيانات
      request.fields['name'] = name;
      if (age != null) {
        request.fields['age'] = age.toString();
      }
      if (gender != null) {
        request.fields['gender'] = gender;
      }

      // إضافة الصورة إذا كانت موجودة
      if (image != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            image.path,
            filename: 'profile_image.jpg',
          ),
        );
      }

      print('Sending request...');
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('Response code: ${response.statusCode}');
      print('Response: ${response.body}');

      if (response.statusCode == 200) {
        print('Profile updated successfully');
        return;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - please login again');
      } else if (response.statusCode == 422) {
        final responseData = jsonDecode(response.body);
        final errors = responseData['errors'];
        if (errors != null) {
          if (errors['name'] != null) {
            throw Exception('Name is required');
          } else if (errors['age'] != null) {
            throw Exception('Please enter a valid age');
          } else if (errors['gender'] != null) {
            throw Exception('Please select a valid gender');
          } else if (errors['image'] != null) {
            throw Exception('Please select a valid image');
          }
        }
        throw Exception('Validation error');
      } else {
        throw Exception('Failed to update profile - error code: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Check your internet connection');
    } catch (e) {
      print('Error updating profile: $e');
      throw Exception(e.toString());
    }
  }

  // تسجيل الدخول
  Future<AuthResponse> login(LoginRequest loginRequest) async {
    try {
      print('login attempt...');
      print('data: ${loginRequest.toJson()}');
      
      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.login}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(loginRequest.toJson()),
      );

      print('response code: ${response.statusCode}');
      print('response: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(responseData);
        
        // save the token
        await _saveToken(authResponse.token);
        
        return authResponse;
      } else if (response.statusCode == 401) {
        final responseData = jsonDecode(response.body);
        final message = responseData['message'] ?? 'the credentials are incorrect';
        throw Exception(message);
      } else if (response.statusCode == 404) {
        final responseData = jsonDecode(response.body);
        final message = responseData['message'] ?? 'the user is not found';
        throw Exception(message); 
      } else if (response.statusCode == 403) {
        final responseData = jsonDecode(response.body);
        final message = responseData['message'] ?? 'the user is not active';
        throw Exception(message);
      }
      else if (response.statusCode == 422) {
        final responseData = jsonDecode(response.body);
        final errors = responseData['errors'];
        if (errors != null) {
          if (errors['credentials'] != null) {
            throw Exception('the data is required');
          } else if (errors['password'] != null) {
            throw Exception('the password must be at least 8 characters');
          }
        }
        throw Exception('the data is incorrect');
      } else {
        throw Exception('failed to login - error code: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('check your internet connection');
    } catch (e) {
      print('error in login: $e');
      throw Exception(e.toString());
    }
  }

  // إنشاء حساب جديد
  Future<AuthResponse> register(RegisterRequest registerRequest) async {
    try {
      print('attempt to create an account...');
      print('data: ${registerRequest.toJson()}');
      
      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.register}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(registerRequest.toJson()),
      );

      print('response code: ${response.statusCode}');
      print('response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(responseData);
        
        // save the token
        await _saveToken(authResponse.token);
        
        return authResponse;
      } else if (response.statusCode == 422) {
        final responseData = jsonDecode(response.body);
        final errors = responseData['errors'];
        if (errors != null) {
          if (errors['email'] != null) {
            throw Exception('the email is already used');
          } else if (errors['name'] != null) {
            throw Exception('the name is required');
          } else if (errors['phone'] != null) {
            throw Exception('the phone is incorrect');
          } else if (errors['password'] != null) {
              throw Exception('the password must be at least 8 characters');
          } else if (errors['password_confirmation'] != null) {
            throw Exception('the password confirmation is incorrect');
          }
        }
        throw Exception('the data is incorrect');
      } else {
        throw Exception('failed to create account - error code: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('check your internet connection');
    } catch (e) {
      print('error in create account: $e');
      throw Exception(e.toString());
    }
  }

  // إنشاء حساب جديد مع صورة
  Future<AuthResponse> registerWithImage(RegisterRequest registerRequest, String imagePath) async {
    try {
      print('attempt to create an account with an image...');
      print('data: ${registerRequest.toJson()}');
      print('image path: $imagePath');
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.register}'),
      );
      
      // add the image
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      
      // add the data
      request.fields['name'] = registerRequest.name;
      request.fields['email'] = registerRequest.email;
      request.fields['phone'] = registerRequest.phone;
      request.fields['password'] = registerRequest.password;
      request.fields['password_confirmation'] = registerRequest.passwordConfirmation;
      
      // add the headers
      request.headers.addAll({
        'Accept': 'application/json',
      });
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('response code: ${response.statusCode}');
      print('response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(responseData);
        
        // save the token
        await _saveToken(authResponse.token);
        
        return authResponse;
      } else if (response.statusCode == 422) {
        final responseData = jsonDecode(response.body);
        final errors = responseData['errors'];
        if (errors != null) {
          if (errors['email'] != null) {
            throw Exception('the email is already used');
          } else if (errors['name'] != null) {
            throw Exception('the name is required');
          } else if (errors['phone'] != null) {
            throw Exception('the phone is incorrect');
          } else if (errors['password'] != null) {
            throw Exception('the password must be at least 8 characters');
          } else if (errors['password_confirmation'] != null) {
            throw Exception('the password confirmation is incorrect');
          } else if (errors['image'] != null) {
            throw Exception('the image is incorrect');
          }
        }
        throw Exception('the data is incorrect');
      } else {
        throw Exception('failed to create account - error code: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('check your internet connection');
    } catch (e) {
      print('error in create account with image: $e');
      throw Exception(e.toString());
    }
  }

  // تسجيل الخروج
  Future<void> logout() async {
    await _clearToken();
  }

  // تحميل الـ token عند بدء التطبيق
  Future<void> initialize() async {
    await _loadToken();
  }

  // التحقق من حالة تسجيل الدخول
  bool isLoggedIn() {
    return _token != null && _token!.isNotEmpty;
  }

  // التحقق من OTP
  Future<OtpVerificationResponse> verifyOtp({
    required String userId,
    required String otp,
  }) async {
    try {
      // التأكد من تحميل الـ token
      if (_token == null) {
        await _loadToken();
      }
      
      if (_token == null) {
        throw Exception('User not logged in');
      }
      
      print('verifying OTP...');
      print('user_id: $userId, otp: $otp');
      print('API URL: ${ApiEndpoints.baseUrl}${ApiEndpoints.verifyOtp}');
      print('Token: $_token');
      
      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.verifyOtp}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'user_id': userId,
          'otp': otp,
        }),
      );

      print('response code: ${response.statusCode}');
      print('response: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('OTP verification response: $responseData');
        
        final otpResponse = OtpVerificationResponse.fromJson(responseData);
        print('Parsed OTP response - Success: ${otpResponse.success}, Message: ${otpResponse.message}');
        
        return otpResponse;
      } else if (response.statusCode == 400) {
        final responseData = jsonDecode(response.body);
        final message = responseData['message'] ?? 'Invalid OTP code';
        throw Exception(message);
      } else if (response.statusCode == 404) {
        final responseData = jsonDecode(response.body);
        final message = responseData['message'] ?? 'User not found';
        throw Exception(message);
      }  else if (response.statusCode == 401) {
        final responseData = jsonDecode(response.body);
        final message = responseData['message'] ?? 'Invalid OTP code';
        throw Exception(message);
      }
      else {
        throw Exception('Failed to verify OTP - error code: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Check your internet connection');
    } catch (e) {
      print('error in verify OTP: $e');
      throw Exception(e.toString());
    }
  }

  // إعادة إرسال OTP
  Future<void> resendOtp(String userId) async {
    try {
      // التأكد من تحميل الـ token
      if (_token == null) {
        await _loadToken();
      }
      
      if (_token == null) {
        throw Exception('User not logged in');
      }
      
      print('resending OTP...');
      print('user_id: $userId');
      print('API URL: ${ApiEndpoints.baseUrl}${ApiEndpoints.resendOtp}');
      print('Token: $_token');
      
      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.resendOtp}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'user_id': userId,
        }),
      );

      print('response code: ${response.statusCode}');
      print('response: ${response.body}');

      if (response.statusCode == 200) {
        print('OTP resent successfully');
        return;
      } else if (response.statusCode == 404) {
        final responseData = jsonDecode(response.body);
        final message = responseData['message'] ?? 'User not found';
        throw Exception(message);
      } else {
        throw Exception('Failed to resend OTP - error code: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Check your internet connection');
    } catch (e) {
      print('error in resend OTP: $e');
      throw Exception(e.toString());
    }
  }

  // الحصول على معلومات المستخدم
  Future<UserModel> getUserInfo() async {
    try {
      if (_token == null) {
        throw Exception('User not logged in');
      }

      print('getting user info...');
      print('API URL: ${ApiEndpoints.baseUrl}${ApiEndpoints.userInfo}');
      print('Token: $_token');
      
      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.userInfo}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      print('response code: ${response.statusCode}');
      print('response: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('User data: $responseData');
        
        // التحقق من أن البيانات تحتوي على user
        if (responseData['user'] != null) {
          return UserModel.fromJson(responseData['user']);
        } else {
          throw Exception('User data not found in response');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - please login again');
      } else {
        throw Exception('Failed to get user info - error code: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Check your internet connection');
    } catch (e) {
      print('error in get user info: $e');
      throw Exception(e.toString());
    }
  }

  // Forget Password - إرسال OTP للبريد الإلكتروني
  Future<void> forgetPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.forgetPasswordUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
        }),
      );

      print('Forget password response code: ${response.statusCode}');
      print('Forget password response: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('OTP sent successfully: ${responseData['message']}');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      print('error in forget password: $e');
      throw Exception(e.toString());
    }
  }

  // Reset Password - تغيير كلمة المرور باستخدام OTP
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.resetPasswordUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      print('Reset password response code: ${response.statusCode}');
      print('Reset password response: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Password reset successfully: ${responseData['message']}');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to reset password');
      }
    } catch (e) {
      print('error in reset password: $e');
      throw Exception(e.toString());
    }
  }

  // Change Password - تغيير كلمة المرور (يتطلب كلمة المرور القديمة)
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      if (_token == null) {
        await _loadToken();
        if (_token == null) {
          throw Exception('User not logged in');
        }
      }

      final response = await http.post(
        Uri.parse(ApiEndpoints.changePasswordUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'current_password': oldPassword,
          'password': newPassword,
          'password_confirmation': confirmPassword,
        }),
      );

      print('Change password response code: ${response.statusCode}');
      print('Change password response: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Password changed successfully: ${responseData['message']}');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to change password');
      }
    } catch (e) {
      print('error in change password: $e');
      throw Exception(e.toString());
    }
  }

  // Get Categories - الحصول على الفئات الرئيسية
  Future<CategoriesResponse> getCategories({int page = 1}) async {
    try {
      final url = '${ApiEndpoints.categoriesUrl}?page=$page';
      print('API URL: $url');
      print('Token: $_token');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      print('Categories response code: ${response.statusCode}');
      print('Categories response: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Parsed response data: $responseData');
        return CategoriesResponse.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to get categories');
      }
    } catch (e) {
      print('error in get categories: $e');
      throw Exception(e.toString());
    }
  }

  // Get Subcategories - الحصول على الفئات الفرعية
  Future<CategoriesResponse> getSubcategories({required int parentId, int page = 1}) async {
    try {
      final url = '${ApiEndpoints.subcategoriesUrl}$parentId?page=$page';
      print('Subcategories API URL: $url');
      print('Token: $_token');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      print('Subcategories response code: ${response.statusCode}');
      print('Subcategories response: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Parsed subcategories response data: $responseData');
        return CategoriesResponse.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to get subcategories');
      }
    } catch (e) {
      print('error in get subcategories: $e');
      throw Exception(e.toString());
    }
  }

  // Get Products by Category - الحصول على المنتجات حسب الفئة
  Future<ProductsResponse> getProductsByCategory({
    required int categoryId,
    int page = 1,
  }) async {
    try {
      await _loadToken();
      
      if (_token == null) {
        throw Exception('User not authenticated');
      }

      final url = '${ApiEndpoints.productbycategoryUrl}$categoryId?page=$page';
      print('Products API URL: $url');
      print('Token: $_token');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      print('Products response code: ${response.statusCode}');
      print('Products response: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Parsed products response data: $responseData');
        return ProductsResponse.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to get products');
      }
    } catch (e) {
      print('error in get products by category: $e');
      throw Exception(e.toString());
    }
  }

  // Get Products Count by Category - الحصول على عدد المنتجات حسب الفئة
  Future<int> getProductsCountByCategory(int categoryId) async {
    try {
      await _loadToken();
      
      if (_token == null) {
        throw Exception('User not authenticated');
      }

      final url = '${ApiEndpoints.productbycategoryUrl}$categoryId?page=1';
      print('Products count API URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      print('Products count response code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final productsCount = responseData['products_count'] ?? 0;
        print('Products count for category $categoryId: $productsCount');
        return productsCount;
      } else {
        print('Failed to get products count, returning 0');
        return 0;
      }
    } catch (e) {
      print('error in get products count: $e');
      return 0;
    }
  }

  // Get Product Details - الحصول على تفاصيل المنتج
  Future<ProductDetails> getProductDetails(int productId) async {
    try {
      await _loadToken();
      
      if (_token == null) {
        throw Exception('User not authenticated');
      }

      final url = '${ApiEndpoints.productdetailsUrl}$productId';
      print('Product details API URL: $url');
      print('Token: $_token');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      print('Product details response code: ${response.statusCode}');
      print('Product details response: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Parsed product details response data: $responseData');
        return ProductDetails.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to get product details');
      }
    } catch (e) {
      print('error in get product details: $e');
      throw Exception(e.toString());
    }
  }

  // Get Cart - الحصول على السلة
  Future<CartResponse> getCart() async {
    try {
      await _loadToken();
      
      if (_token == null) {
        throw Exception('User not authenticated');
      }

      print('Getting cart...');
      print('API URL: ${ApiEndpoints.cartUrl}');
      print('Token: $_token');
      
      final response = await http.get(
        Uri.parse(ApiEndpoints.cartUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      print('Cart response code: ${response.statusCode}');
      print('Cart response: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Parsed cart response data: $responseData');
        return CartResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - please login again');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to get cart');
      }
    } catch (e) {
      print('error in get cart: $e');
      throw Exception(e.toString());
    }
  }
}
