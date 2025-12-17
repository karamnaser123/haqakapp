import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Phone Store - Cashback App'**
  String get appTitle;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success!'**
  String get success;

  /// No description provided for @passwordChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Your password has been changed successfully.'**
  String get passwordChangedSuccessfully;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @enterCurrentAndNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your current and new password'**
  String get enterCurrentAndNewPassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @pleaseEnterCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter current password'**
  String get pleaseEnterCurrentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @pleaseEnterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter new password'**
  String get pleaseEnterNewPassword;

  /// No description provided for @passwordMustBeAtLeast6.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMustBeAtLeast6;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @pleaseConfirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm new password'**
  String get pleaseConfirmNewPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @loginSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Login successful'**
  String get loginSuccessful;

  /// No description provided for @phoneStoreApp.
  ///
  /// In en, this message translates to:
  /// **'Phone Store App'**
  String get phoneStoreApp;

  /// No description provided for @emailOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Email or Phone'**
  String get emailOrPhone;

  /// No description provided for @pleaseEnterCredentials.
  ///
  /// In en, this message translates to:
  /// **'Please enter your credentials'**
  String get pleaseEnterCredentials;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @pleaseEnterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterYourEmail;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// No description provided for @otpSentSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'OTP sent successfully'**
  String get otpSentSuccessfully;

  /// No description provided for @linkSent.
  ///
  /// In en, this message translates to:
  /// **'Link Sent'**
  String get linkSent;

  /// No description provided for @checkYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Check your email for the verification code'**
  String get checkYourEmail;

  /// No description provided for @dontWorryWeWillHelp.
  ///
  /// In en, this message translates to:
  /// **'Don\'t worry, we\'ll help you reset your password'**
  String get dontWorryWeWillHelp;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @enterEmailAndWeWillSend.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send you a verification code'**
  String get enterEmailAndWeWillSend;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// No description provided for @otpCode.
  ///
  /// In en, this message translates to:
  /// **'OTP Code'**
  String get otpCode;

  /// No description provided for @pleaseEnterOtpCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter OTP code'**
  String get pleaseEnterOtpCode;

  /// No description provided for @otpMustBeAtLeast6.
  ///
  /// In en, this message translates to:
  /// **'OTP must be at least 6 digits'**
  String get otpMustBeAtLeast6;

  /// No description provided for @otpMustBeAtLeast6Digits.
  ///
  /// In en, this message translates to:
  /// **'OTP must be at least 6 digits'**
  String get otpMustBeAtLeast6Digits;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @pleaseConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm password'**
  String get pleaseConfirmPassword;

  /// No description provided for @passwordResetSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully'**
  String get passwordResetSuccessfully;

  /// No description provided for @goToLogin.
  ///
  /// In en, this message translates to:
  /// **'Go to Login'**
  String get goToLogin;

  /// No description provided for @rememberYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Remember your password?'**
  String get rememberYourPassword;

  /// No description provided for @enterOtpAndNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP and new password'**
  String get enterOtpAndNewPassword;

  /// No description provided for @verifyYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Email'**
  String get verifyYourEmail;

  /// No description provided for @weSentVerificationCodeTo.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification code to'**
  String get weSentVerificationCodeTo;

  /// No description provided for @enterVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Verification Code'**
  String get enterVerificationCode;

  /// No description provided for @pleaseEnterCompleteOtp.
  ///
  /// In en, this message translates to:
  /// **'Please enter complete OTP'**
  String get pleaseEnterCompleteOtp;

  /// No description provided for @emailVerifiedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Email verified successfully'**
  String get emailVerifiedSuccessfully;

  /// No description provided for @unableToVerifyUser.
  ///
  /// In en, this message translates to:
  /// **'Unable to verify user'**
  String get unableToVerifyUser;

  /// No description provided for @unableToResendOtp.
  ///
  /// In en, this message translates to:
  /// **'Unable to resend OTP'**
  String get unableToResendOtp;

  /// No description provided for @didntReceiveCode.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code?'**
  String get didntReceiveCode;

  /// No description provided for @resendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in'**
  String get resendIn;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get resendCode;

  /// No description provided for @verifyCode.
  ///
  /// In en, this message translates to:
  /// **'Verify Code'**
  String get verifyCode;

  /// No description provided for @areYouSureLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get areYouSureLogout;

  /// No description provided for @selectProfilePicture.
  ///
  /// In en, this message translates to:
  /// **'Select Profile Picture'**
  String get selectProfilePicture;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @errorPickingImage.
  ///
  /// In en, this message translates to:
  /// **'Error picking image'**
  String get errorPickingImage;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @pleaseEnterFullName.
  ///
  /// In en, this message translates to:
  /// **'Please enter full name'**
  String get pleaseEnterFullName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @pleaseEnterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter phone number'**
  String get pleaseEnterPhoneNumber;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get enterPhoneNumber;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter email'**
  String get pleaseEnterEmail;

  /// No description provided for @accountCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully'**
  String get accountCreatedSuccessfully;

  /// No description provided for @pleaseAgreeToTerms.
  ///
  /// In en, this message translates to:
  /// **'Please agree to terms and conditions'**
  String get pleaseAgreeToTerms;

  /// No description provided for @agreeToTerms.
  ///
  /// In en, this message translates to:
  /// **'I agree to'**
  String get agreeToTerms;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get termsAndConditions;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @joinUsAndEnjoy.
  ///
  /// In en, this message translates to:
  /// **'Join us and enjoy the best offers'**
  String get joinUsAndEnjoy;

  /// No description provided for @pricesUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Prices updated successfully'**
  String get pricesUpdatedSuccessfully;

  /// No description provided for @failedToUpdatePrices.
  ///
  /// In en, this message translates to:
  /// **'Failed to update prices'**
  String get failedToUpdatePrices;

  /// No description provided for @errorUpdatingPrices.
  ///
  /// In en, this message translates to:
  /// **'Error updating prices'**
  String get errorUpdatingPrices;

  /// No description provided for @removedFromCart.
  ///
  /// In en, this message translates to:
  /// **'Product removed from cart'**
  String get removedFromCart;

  /// No description provided for @quantityCannotExceed1000.
  ///
  /// In en, this message translates to:
  /// **'Quantity cannot exceed 1000'**
  String get quantityCannotExceed1000;

  /// No description provided for @quantityUpdated.
  ///
  /// In en, this message translates to:
  /// **'Quantity updated'**
  String get quantityUpdated;

  /// No description provided for @editQuantity.
  ///
  /// In en, this message translates to:
  /// **'Edit Quantity'**
  String get editQuantity;

  /// No description provided for @enterDesiredQuantity.
  ///
  /// In en, this message translates to:
  /// **'Enter desired quantity:'**
  String get enterDesiredQuantity;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @pleaseEnterValidQuantity.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid quantity'**
  String get pleaseEnterValidQuantity;

  /// No description provided for @clearCartCompletely.
  ///
  /// In en, this message translates to:
  /// **'Clear Cart Completely'**
  String get clearCartCompletely;

  /// No description provided for @areYouSureClearCart.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all products from cart?'**
  String get areYouSureClearCart;

  /// No description provided for @deleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete All'**
  String get deleteAll;

  /// No description provided for @cartClearedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Cart cleared successfully'**
  String get cartClearedSuccessfully;

  /// No description provided for @errorLoadingCart.
  ///
  /// In en, this message translates to:
  /// **'Error loading cart'**
  String get errorLoadingCart;

  /// No description provided for @cartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Cart is empty'**
  String get cartEmpty;

  /// No description provided for @cartEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Start shopping and add your favorite products'**
  String get cartEmptyDescription;

  /// No description provided for @startShopping.
  ///
  /// In en, this message translates to:
  /// **'Start Shopping'**
  String get startShopping;

  /// No description provided for @totalItems.
  ///
  /// In en, this message translates to:
  /// **'Total Items'**
  String get totalItems;

  /// No description provided for @totalPrice.
  ///
  /// In en, this message translates to:
  /// **'Total Price'**
  String get totalPrice;

  /// No description provided for @cashbackAmount.
  ///
  /// In en, this message translates to:
  /// **'Cashback Amount'**
  String get cashbackAmount;

  /// No description provided for @jd.
  ///
  /// In en, this message translates to:
  /// **'JOD'**
  String get jd;

  /// No description provided for @totalQuantity.
  ///
  /// In en, this message translates to:
  /// **'Total Quantity'**
  String get totalQuantity;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @checkoutOrder.
  ///
  /// In en, this message translates to:
  /// **'Checkout Order'**
  String get checkoutOrder;

  /// No description provided for @updatePrices.
  ///
  /// In en, this message translates to:
  /// **'Update Prices'**
  String get updatePrices;

  /// No description provided for @refreshCart.
  ///
  /// In en, this message translates to:
  /// **'Refresh Cart'**
  String get refreshCart;

  /// No description provided for @clearCart.
  ///
  /// In en, this message translates to:
  /// **'Clear Cart'**
  String get clearCart;

  /// No description provided for @subcategories.
  ///
  /// In en, this message translates to:
  /// **'Subcategories'**
  String get subcategories;

  /// No description provided for @product.
  ///
  /// In en, this message translates to:
  /// **'product'**
  String get product;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'products'**
  String get products;

  /// No description provided for @noSubcategoriesFound.
  ///
  /// In en, this message translates to:
  /// **'No subcategories found'**
  String get noSubcategoriesFound;

  /// No description provided for @noCategoriesFound.
  ///
  /// In en, this message translates to:
  /// **'No categories found'**
  String get noCategoriesFound;

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load More'**
  String get loadMore;

  /// No description provided for @orderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get orderSummary;

  /// No description provided for @pieces.
  ///
  /// In en, this message translates to:
  /// **'pieces'**
  String get pieces;

  /// No description provided for @originalTotal.
  ///
  /// In en, this message translates to:
  /// **'Original Total'**
  String get originalTotal;

  /// No description provided for @discountCode.
  ///
  /// In en, this message translates to:
  /// **'Discount Code'**
  String get discountCode;

  /// No description provided for @totalCashback.
  ///
  /// In en, this message translates to:
  /// **'Total Cashback'**
  String get totalCashback;

  /// No description provided for @youWillEarn.
  ///
  /// In en, this message translates to:
  /// **'You will earn'**
  String get youWillEarn;

  /// No description provided for @cashbackOnThisOrder.
  ///
  /// In en, this message translates to:
  /// **'cashback on this order'**
  String get cashbackOnThisOrder;

  /// No description provided for @finalTotal.
  ///
  /// In en, this message translates to:
  /// **'Final Total'**
  String get finalTotal;

  /// No description provided for @deliveryInformation.
  ///
  /// In en, this message translates to:
  /// **'Delivery Information'**
  String get deliveryInformation;

  /// No description provided for @governorate.
  ///
  /// In en, this message translates to:
  /// **'Governorate'**
  String get governorate;

  /// No description provided for @chooseGovernorate.
  ///
  /// In en, this message translates to:
  /// **'Choose Governorate'**
  String get chooseGovernorate;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @chooseGovernorateFirst.
  ///
  /// In en, this message translates to:
  /// **'Choose Governorate First'**
  String get chooseGovernorateFirst;

  /// No description provided for @chooseCity.
  ///
  /// In en, this message translates to:
  /// **'Choose City'**
  String get chooseCity;

  /// No description provided for @detailedAddress.
  ///
  /// In en, this message translates to:
  /// **'Detailed Address'**
  String get detailedAddress;

  /// No description provided for @enterDetailedAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter detailed address'**
  String get enterDetailedAddress;

  /// No description provided for @pleaseEnterDetailedAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter detailed address'**
  String get pleaseEnterDetailedAddress;

  /// No description provided for @phoneNumberMustBeAtLeast10.
  ///
  /// In en, this message translates to:
  /// **'Phone number must be at least 10 digits'**
  String get phoneNumberMustBeAtLeast10;

  /// No description provided for @discountCodeOptional.
  ///
  /// In en, this message translates to:
  /// **'Discount Code (Optional)'**
  String get discountCodeOptional;

  /// No description provided for @enterDiscountCode.
  ///
  /// In en, this message translates to:
  /// **'Enter discount code'**
  String get enterDiscountCode;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @discountCodeApplied.
  ///
  /// In en, this message translates to:
  /// **'Discount code applied'**
  String get discountCodeApplied;

  /// No description provided for @submitting.
  ///
  /// In en, this message translates to:
  /// **'Submitting...'**
  String get submitting;

  /// No description provided for @submitOrder.
  ///
  /// In en, this message translates to:
  /// **'Submit Order'**
  String get submitOrder;

  /// No description provided for @pleaseEnterDiscountCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter discount code'**
  String get pleaseEnterDiscountCode;

  /// No description provided for @discountCodeAppliedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Discount code applied successfully'**
  String get discountCodeAppliedSuccessfully;

  /// No description provided for @discountCodeIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Discount code is incorrect'**
  String get discountCodeIncorrect;

  /// No description provided for @errorApplyingDiscount.
  ///
  /// In en, this message translates to:
  /// **'Error applying discount'**
  String get errorApplyingDiscount;

  /// No description provided for @discountCodeRemoved.
  ///
  /// In en, this message translates to:
  /// **'Discount code removed'**
  String get discountCodeRemoved;

  /// No description provided for @pleaseSelectGovernorate.
  ///
  /// In en, this message translates to:
  /// **'Please select governorate'**
  String get pleaseSelectGovernorate;

  /// No description provided for @pleaseSelectCity.
  ///
  /// In en, this message translates to:
  /// **'Please select city'**
  String get pleaseSelectCity;

  /// No description provided for @orderSubmittedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Order submitted successfully'**
  String get orderSubmittedSuccessfully;

  /// No description provided for @errorSubmittingOrder.
  ///
  /// In en, this message translates to:
  /// **'Error submitting order'**
  String get errorSubmittingOrder;

  /// No description provided for @errorLoadingGovernorates.
  ///
  /// In en, this message translates to:
  /// **'Error loading governorates'**
  String get errorLoadingGovernorates;

  /// No description provided for @errorLoadingCities.
  ///
  /// In en, this message translates to:
  /// **'Error loading cities'**
  String get errorLoadingCities;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @tapToChangeImage.
  ///
  /// In en, this message translates to:
  /// **'Tap to change image'**
  String get tapToChangeImage;

  /// No description provided for @nameIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameIsRequired;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @pleaseEnterValidAge.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid age'**
  String get pleaseEnterValidAge;

  /// No description provided for @selectGender.
  ///
  /// In en, this message translates to:
  /// **'Select Gender'**
  String get selectGender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @failedToLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile'**
  String get failedToLoadProfile;

  /// No description provided for @failedToPickImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image'**
  String get failedToPickImage;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @discoverTheBestPhones.
  ///
  /// In en, this message translates to:
  /// **'Discover the best phones'**
  String get discoverTheBestPhones;

  /// No description provided for @searchForPhones.
  ///
  /// In en, this message translates to:
  /// **'Search for phones...'**
  String get searchForPhones;

  /// No description provided for @featuredPhones.
  ///
  /// In en, this message translates to:
  /// **'Featured Phones'**
  String get featuredPhones;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @specialOffers.
  ///
  /// In en, this message translates to:
  /// **'Special Offers'**
  String get specialOffers;

  /// No description provided for @getUpTo50OffOnAllPhones.
  ///
  /// In en, this message translates to:
  /// **'Get up to 50% off on all phones'**
  String get getUpTo50OffOnAllPhones;

  /// No description provided for @exploreOffers.
  ///
  /// In en, this message translates to:
  /// **'Explore Offers'**
  String get exploreOffers;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @stores.
  ///
  /// In en, this message translates to:
  /// **'stores'**
  String get stores;

  /// No description provided for @pleaseLoginFirst.
  ///
  /// In en, this message translates to:
  /// **'Please login first'**
  String get pleaseLoginFirst;

  /// No description provided for @errorRemovingDiscount.
  ///
  /// In en, this message translates to:
  /// **'Error removing discount'**
  String get errorRemovingDiscount;

  /// No description provided for @myOrders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get myOrders;

  /// No description provided for @orderCancelled.
  ///
  /// In en, this message translates to:
  /// **'Order cancelled'**
  String get orderCancelled;

  /// No description provided for @errorCancellingOrder.
  ///
  /// In en, this message translates to:
  /// **'Error cancelling order'**
  String get errorCancellingOrder;

  /// No description provided for @orderNumber.
  ///
  /// In en, this message translates to:
  /// **'Order Number'**
  String get orderNumber;

  /// No description provided for @orderDate.
  ///
  /// In en, this message translates to:
  /// **'Order Date'**
  String get orderDate;

  /// No description provided for @storeName.
  ///
  /// In en, this message translates to:
  /// **'Store Name'**
  String get storeName;

  /// No description provided for @orderItems.
  ///
  /// In en, this message translates to:
  /// **'Order Items'**
  String get orderItems;

  /// No description provided for @orderTotal.
  ///
  /// In en, this message translates to:
  /// **'Order Total'**
  String get orderTotal;

  /// No description provided for @cashbackEarned.
  ///
  /// In en, this message translates to:
  /// **'Cashback Earned'**
  String get cashbackEarned;

  /// No description provided for @orderDetails.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orderDetails;

  /// No description provided for @cancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Cancel Order'**
  String get cancelOrder;

  /// No description provided for @confirmCancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this order?'**
  String get confirmCancelOrder;

  /// No description provided for @noOrdersFound.
  ///
  /// In en, this message translates to:
  /// **'No orders found'**
  String get noOrdersFound;

  /// No description provided for @orderInformation.
  ///
  /// In en, this message translates to:
  /// **'Order Information'**
  String get orderInformation;

  /// No description provided for @item.
  ///
  /// In en, this message translates to:
  /// **'item'**
  String get item;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'items'**
  String get items;

  /// No description provided for @paymentAndDeliveryInfo.
  ///
  /// In en, this message translates to:
  /// **'Payment and Delivery Info'**
  String get paymentAndDeliveryInfo;

  /// No description provided for @deliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Delivery Address'**
  String get deliveryAddress;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @deliveryFee.
  ///
  /// In en, this message translates to:
  /// **'Delivery Fee'**
  String get deliveryFee;

  /// No description provided for @orderStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get orderStatusPending;

  /// No description provided for @orderStatusProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get orderStatusProcessing;

  /// No description provided for @orderStatusShipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get orderStatusShipped;

  /// No description provided for @orderStatusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get orderStatusDelivered;

  /// No description provided for @orderStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get orderStatusCompleted;

  /// No description provided for @orderStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get orderStatusCancelled;

  /// No description provided for @unknownStatus.
  ///
  /// In en, this message translates to:
  /// **'Unknown Status'**
  String get unknownStatus;

  /// No description provided for @productDetails.
  ///
  /// In en, this message translates to:
  /// **'Product Details'**
  String get productDetails;

  /// No description provided for @productNotFound.
  ///
  /// In en, this message translates to:
  /// **'Product not found'**
  String get productNotFound;

  /// No description provided for @noProductImages.
  ///
  /// In en, this message translates to:
  /// **'No product images'**
  String get noProductImages;

  /// No description provided for @imageNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Image not available'**
  String get imageNotAvailable;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @originalPrice.
  ///
  /// In en, this message translates to:
  /// **'Original Price'**
  String get originalPrice;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @features.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get features;

  /// No description provided for @newProduct.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newProduct;

  /// No description provided for @bestSeller.
  ///
  /// In en, this message translates to:
  /// **'Best Seller'**
  String get bestSeller;

  /// No description provided for @topRated.
  ///
  /// In en, this message translates to:
  /// **'Top Rated'**
  String get topRated;

  /// No description provided for @featured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get featured;

  /// No description provided for @stock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get stock;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get unavailable;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get addToCart;

  /// No description provided for @addingToCart.
  ///
  /// In en, this message translates to:
  /// **'Adding to Cart'**
  String get addingToCart;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get outOfStock;

  /// No description provided for @addedToCart.
  ///
  /// In en, this message translates to:
  /// **'Added to Cart'**
  String get addedToCart;

  /// No description provided for @viewCart.
  ///
  /// In en, this message translates to:
  /// **'View Cart'**
  String get viewCart;

  /// No description provided for @failedToAddToCart.
  ///
  /// In en, this message translates to:
  /// **'Failed to add to cart'**
  String get failedToAddToCart;

  /// No description provided for @store.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get store;

  /// No description provided for @differentStoreWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning: This product is from a different store. Do you want to clear the current cart and add this product?'**
  String get differentStoreWarning;

  /// No description provided for @clearCartAndAdd.
  ///
  /// In en, this message translates to:
  /// **'Clear Cart and Add'**
  String get clearCartAndAdd;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @creditCard.
  ///
  /// In en, this message translates to:
  /// **'Credit Card'**
  String get creditCard;

  /// No description provided for @bankTransfer.
  ///
  /// In en, this message translates to:
  /// **'Bank Transfer'**
  String get bankTransfer;

  /// No description provided for @productsCount.
  ///
  /// In en, this message translates to:
  /// **'Products Count'**
  String get productsCount;

  /// No description provided for @noProductsInThisCategory.
  ///
  /// In en, this message translates to:
  /// **'No products in this category'**
  String get noProductsInThisCategory;

  /// No description provided for @myBalance.
  ///
  /// In en, this message translates to:
  /// **'My Balance'**
  String get myBalance;

  /// No description provided for @phoneStore.
  ///
  /// In en, this message translates to:
  /// **'Phone Store'**
  String get phoneStore;

  /// No description provided for @cashbackApp.
  ///
  /// In en, this message translates to:
  /// **'Cashback App'**
  String get cashbackApp;

  /// No description provided for @pleaseLoginToViewStores.
  ///
  /// In en, this message translates to:
  /// **'Please login to view stores'**
  String get pleaseLoginToViewStores;

  /// No description provided for @searchStores.
  ///
  /// In en, this message translates to:
  /// **'Search stores'**
  String get searchStores;

  /// No description provided for @page.
  ///
  /// In en, this message translates to:
  /// **'Page'**
  String get page;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @cashbackRate.
  ///
  /// In en, this message translates to:
  /// **'Cashback Rate'**
  String get cashbackRate;

  /// No description provided for @storeDetails.
  ///
  /// In en, this message translates to:
  /// **'Store Details'**
  String get storeDetails;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @deliveryPrice.
  ///
  /// In en, this message translates to:
  /// **'Delivery Price'**
  String get deliveryPrice;

  /// No description provided for @whatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsapp;

  /// No description provided for @visitStore.
  ///
  /// In en, this message translates to:
  /// **'Visit Store'**
  String get visitStore;

  /// No description provided for @facebook.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get facebook;

  /// No description provided for @instagram.
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get instagram;

  /// No description provided for @contactFunctionalityComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Contact functionality coming soon'**
  String get contactFunctionalityComingSoon;

  /// No description provided for @contactStore.
  ///
  /// In en, this message translates to:
  /// **'Contact Store'**
  String get contactStore;

  /// No description provided for @visitStoreFunctionalityComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Visit store functionality coming soon'**
  String get visitStoreFunctionalityComingSoon;

  /// No description provided for @tryAdjustingSearch.
  ///
  /// In en, this message translates to:
  /// **'try Adjusting Search'**
  String get tryAdjustingSearch;

  /// No description provided for @noStoresFound.
  ///
  /// In en, this message translates to:
  /// **'no Stores Found'**
  String get noStoresFound;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get off;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @couldNotOpenGoogleMaps.
  ///
  /// In en, this message translates to:
  /// **'Could not open Google Maps'**
  String get couldNotOpenGoogleMaps;

  /// No description provided for @errorOpeningLocation.
  ///
  /// In en, this message translates to:
  /// **'Error opening location: {error}'**
  String errorOpeningLocation(Object error);

  /// No description provided for @viewProducts.
  ///
  /// In en, this message translates to:
  /// **'View Products'**
  String get viewProducts;

  /// No description provided for @pleaseLoginToViewProducts.
  ///
  /// In en, this message translates to:
  /// **'Please login to view products'**
  String get pleaseLoginToViewProducts;

  /// No description provided for @searchProducts.
  ///
  /// In en, this message translates to:
  /// **'Search Products'**
  String get searchProducts;

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get noProductsFound;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get sortBy;

  /// No description provided for @newest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get newest;

  /// No description provided for @priceLowToHigh.
  ///
  /// In en, this message translates to:
  /// **'Price: Low to High'**
  String get priceLowToHigh;

  /// No description provided for @priceHighToLow.
  ///
  /// In en, this message translates to:
  /// **'Price: High to Low'**
  String get priceHighToLow;

  /// No description provided for @nameAtoZ.
  ///
  /// In en, this message translates to:
  /// **'Name: A to Z'**
  String get nameAtoZ;

  /// No description provided for @nameZtoA.
  ///
  /// In en, this message translates to:
  /// **'Name: Z to A'**
  String get nameZtoA;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
