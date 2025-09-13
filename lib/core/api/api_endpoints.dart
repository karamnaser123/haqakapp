class ApiEndpoints {
  // Base URL
  static const String baseUrl = 'http://192.168.56.1:8000/api';
  
  // Authentication endpoints
  static const String login = '/login';
  static const String register = '/register';
  static const String updateProfile = '/update-profile';
  static const String changePassword = '/update-password';
  static const String logout = '/logout';
  static const String verifyOtp = '/verify-otp';
  static const String resendOtp = '/resend-otp';
  static const String userInfo = '/user';
  static const String forgetPassword = '/forget-password';
  static const String resetPassword = '/reset-password';
  static const String categories = '/categories';
  static const String productbycategory = '/productbycategory/';
  static const String productdetails = '/productdetails/';
  static const String addtocart = '/addtocart';
  static const String cart = '/cart';
  static const String removefromcart = '/removefromcart';
  static const String updatequantity = '/updatequantity';
  static const String removeallfromcart = '/removeallfromcart';

  // Complete URLs (Base + Endpoint)
  static const String loginUrl = baseUrl + login;
  static const String registerUrl = baseUrl + register;
  static const String updateProfileUrl = baseUrl + updateProfile;
  static const String changePasswordUrl = baseUrl + changePassword;
  static const String logoutUrl = baseUrl + logout;
  static const String verifyOtpUrl = baseUrl + verifyOtp;
  static const String resendOtpUrl = baseUrl + resendOtp;
  static const String userInfoUrl = baseUrl + userInfo;
  static const String forgetPasswordUrl = baseUrl + forgetPassword;
  static const String resetPasswordUrl = baseUrl + resetPassword;
  static const String categoriesUrl = baseUrl + categories;
  static const String productbycategoryUrl = baseUrl + productbycategory;
  static const String productdetailsUrl = baseUrl + productdetails;
  static const String addtocartUrl = baseUrl + addtocart;
  static const String cartUrl = baseUrl + cart;
  static const String removefromcartUrl = baseUrl + removefromcart;
  static const String updatequantityUrl = baseUrl + updatequantity;
  static const String removeallfromcartUrl = baseUrl + removeallfromcart;

}
