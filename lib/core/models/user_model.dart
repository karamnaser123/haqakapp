class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? image;
  final String? emailVerifiedAt;
  final int? age;
  final String? gender;
  final String? balance;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.image,
    this.emailVerifiedAt,
    this.age,
    this.gender,
    this.balance,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      image: json['image'],
      emailVerifiedAt: json['email_verified_at'],
      age: json['age'] != null ? int.tryParse(json['age'].toString()) : null,
      gender: json['gender'],
      balance: json['balance'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'image': image,
      'email_verified_at': emailVerifiedAt,
      'age': age,
      'gender': gender,
      'balance': balance,
    };
  }

  // دالة للتحقق من حالة تفعيل البريد الإلكتروني
  bool get isEmailVerified {
    return emailVerifiedAt != null && 
           emailVerifiedAt!.isNotEmpty && 
           emailVerifiedAt != 'null';
  }
}

class LoginRequest {
  final String credentials;
  final String password;

  LoginRequest({
    required this.credentials,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'credentials': credentials,
      'password': password,
    };
  }
}

class RegisterRequest {
  final String name;
  final String email;
  final String phone;
  final String password;
  final String passwordConfirmation;
  final String image;
  RegisterRequest({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.passwordConfirmation,
    required this.image,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'image': image,
    };
  }
}

class AuthResponse {
  final String token;
  final String message;
  final UserModel? user;

  AuthResponse({
    required this.token,
    required this.message,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? '',
      message: json['message'] ?? '',
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'message': message,
      if (user != null) 'user': user!.toJson(),
    };
  }
}

class OtpVerificationRequest {
  final String userId;
  final String otp;

  OtpVerificationRequest({
    required this.userId,
    required this.otp,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'otp': otp,
    };
  }
}

class OtpVerificationResponse {
  final bool success;
  final String message;

  OtpVerificationResponse({
    required this.success,
    required this.message,
  });

  factory OtpVerificationResponse.fromJson(Map<String, dynamic> json) {
    // إذا لم يكن هناك حقل success، نعتبر أن الرسالة الإيجابية تعني النجاح
    bool success = json['success'] ?? false;
    String message = json['message'] ?? '';
    
    // إذا لم يكن هناك success ولكن الرسالة تحتوي على كلمات إيجابية، نعتبرها نجاح
    if (!success && message.isNotEmpty) {
      success = message.toLowerCase().contains('success') || 
                message.toLowerCase().contains('verified') ||
                message.toLowerCase().contains('تم');
    }
    
    return OtpVerificationResponse(
      success: success,
      message: message,
    );
  }
}
