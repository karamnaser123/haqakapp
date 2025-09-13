import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import '../home_screen.dart';
import 'login_screen.dart';
import '../../core/services/auth_service.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final String userId;

  const OtpVerificationScreen({
    super.key,
    required this.email,
    required this.userId,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen>
    with TickerProviderStateMixin {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );
  
  bool _isLoading = false;
  bool _isResending = false;
  int _resendCountdown = 0; // بدء من 0 بدلاً من 60
  late Timer _timer;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // طباعة معلومات التشخيص
    print('OTP Screen initialized with:');
    print('Email: ${widget.email}');
    print('User ID: ${widget.userId}');
    print('User ID type: ${widget.userId.runtimeType}');
    print('User ID isEmpty: ${widget.userId.isEmpty}');
    print('User ID == "0": ${widget.userId == "0"}');
    print('User ID == 0: ${widget.userId == 0}');
    
    // التحقق من معرف المستخدم
    if (widget.userId.isEmpty || widget.userId == '0' || widget.userId == 'null') {
      print('WARNING: User ID is missing or invalid!');
      print('Attempting to get user ID from AuthService...');
      
      // محاولة الحصول على معرف المستخدم من AuthService
      _getUserIdFromService();
    }
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
    // لا نبدأ العد التنازلي في البداية
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    _timer.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    // لا نبدأ العد التنازلي إلا إذا كان أكبر من 0
    if (_resendCountdown > 0) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_resendCountdown > 0) {
          setState(() {
            _resendCountdown--;
          });
        } else {
          timer.cancel();
        }
      });
    }
  }

  Future<void> _getUserIdFromService() async {
    try {
      final authService = AuthService();
      final user = await authService.getUserInfo();
      print('Retrieved user from service: ${user.id}');
      
      if (mounted) {
        // تحديث معرف المستخدم
        setState(() {
          // يمكننا استخدام معرف المستخدم الجديد هنا
        });
      }
    } catch (e) {
      print('Error getting user ID from service: $e');
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpControllers.map((controller) => controller.text).join();
    
    if (otp.length != 6) {
      _showSnackBar(AppLocalizations.of(context)!.pleaseEnterCompleteOtp, Colors.red);
      return;
    }

    // طباعة معلومات التشخيص
    print('Verifying OTP for user: ${widget.userId}');
    print('OTP: $otp');

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService();
      
      // محاولة الحصول على معرف المستخدم إذا كان مفقوداً
      String userId = widget.userId;
      if (userId.isEmpty || userId == '0' || userId == 'null') {
        print('User ID is missing, trying to get from service...');
        try {
          final user = await authService.getUserInfo();
          userId = user.id.toString();
          print('Retrieved user ID from service: $userId');
        } catch (e) {
          print('Error getting user ID from service: $e');
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            _showSnackBar(AppLocalizations.of(context)!.unableToVerifyUser, Colors.red);
          }
          return;
        }
      }

      final response = await authService.verifyOtp(
        userId: userId,
        otp: otp,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // تسجيل تشخيصي
        print('OTP Verification Response:');
        print('Success: ${response.success}');
        print('Message: ${response.message}');

        if (response.success) {
          _showSnackBar(AppLocalizations.of(context)!.emailVerifiedSuccessfully, Colors.green);
          
          // Navigate to home screen
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );
        } else {
          _showSnackBar(response.message, Colors.red);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showSnackBar(
          e.toString().replaceFirst('Exception: ', '').replaceFirst('Exception:', ''),
          Colors.red,
        );
      }
    }
  }

  Future<void> _resendOtp() async {
    setState(() {
      _isResending = true;
    });

    // طباعة معلومات التشخيص
    print('Resending OTP for user: ${widget.userId}');

    try {
      final authService = AuthService();
      
      // محاولة الحصول على معرف المستخدم إذا كان مفقوداً
      String userId = widget.userId;
      if (userId.isEmpty || userId == '0' || userId == 'null') {
        print('User ID is missing, trying to get from service...');
        try {
          final user = await authService.getUserInfo();
          userId = user.id.toString();
          print('Retrieved user ID from service: $userId');
        } catch (e) {
          print('Error getting user ID from service: $e');
          if (mounted) {
            setState(() {
              _isResending = false;
            });
            _showSnackBar(AppLocalizations.of(context)!.unableToResendOtp, Colors.red);
          }
          return;
        }
      }

      await authService.resendOtp(userId);

      if (mounted) {
        setState(() {
          _isResending = false;
          _resendCountdown = 60; // وضع 60 ثانية عند إرسال OTP
        });
        _startResendTimer(); // بدء العد التنازلي
        _showSnackBar(AppLocalizations.of(context)!.otpSentSuccessfully, Colors.green);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
        _showSnackBar(
          e.toString().replaceFirst('Exception: ', '').replaceFirst('Exception:', ''),
          Colors.red,
        );
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.cairo(),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            AppLocalizations.of(context)!.logout,
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            AppLocalizations.of(context)!.areYouSureLogout,
            style: GoogleFonts.cairo(
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: GoogleFonts.cairo(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.logout,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _logout() async {
    // مسح البيانات المحفوظة
    try {
      final authService = AuthService();
      await authService.logout();
    } catch (e) {
      print('Error during logout: $e');
    }
    
    // العودة إلى شاشة تسجيل الدخول
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  void _onOtpChanged(int index, String value) {
    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        _verifyOtp();
      }
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFFf093fb),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height - 
                               MediaQuery.of(context).padding.top - 
                               MediaQuery.of(context).padding.bottom - 48,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                    const SizedBox(height: 40),
                    
                    // Logout Button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => _showLogoutDialog(),
                        icon: const Icon(
                          Icons.logout,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ).animate().slideX(
                      duration: 600.ms,
                      delay: 200.ms,
                      begin: -0.3,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Logo and Title
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Colors.white, Color(0xFFf8f9ff)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.verified_user,
                              size: 60,
                              color: Color(0xFF667eea),
                            ),
                          ).animate().scale(
                            duration: 800.ms,
                            curve: Curves.elasticOut,
                          ),
                          
                          const SizedBox(height: 24),
                          
                          Text(
                            AppLocalizations.of(context)!.verifyYourEmail,
                            style: GoogleFonts.cairo(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ).animate().fadeIn(
                            duration: 1000.ms,
                            delay: 200.ms,
                          ),
                          
                          const SizedBox(height: 8),
                          
                          Text(
                            AppLocalizations.of(context)!.weSentVerificationCodeTo,
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ).animate().fadeIn(
                            duration: 1000.ms,
                            delay: 400.ms,
                          ),
                          
                          const SizedBox(height: 4),
                          
                          Text(
                            widget.email,
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ).animate().fadeIn(
                            duration: 1000.ms,
                            delay: 500.ms,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 60),
                    
                    // OTP Input Form
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.enterVerificationCode,
                            style: GoogleFonts.cairo(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2d3748),
                            ),
                            textAlign: TextAlign.center,
                          ).animate().slideY(
                            duration: 600.ms,
                            delay: 600.ms,
                            begin: -0.3,
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // OTP Input Fields
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(6, (index) {
                              return Container(
                                width: 50,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _focusNodes[index].hasFocus
                                        ? const Color(0xFF667eea)
                                        : const Color(0xFFE2E8F0),
                                    width: 2,
                                  ),
                                  boxShadow: _focusNodes[index].hasFocus
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFF667eea).withOpacity(0.2),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: TextFormField(
                                  controller: _otpControllers[index],
                                  focusNode: _focusNodes[index],
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(1),
                                  ],
                                  style: GoogleFonts.cairo(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF2d3748),
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    focusedErrorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                    fillColor: Colors.transparent,
                                    filled: false,
                                  ),
                                  onChanged: (value) => _onOtpChanged(index, value),
                                ),
                              ).animate().scale(
                                duration: 400.ms,
                                delay: (700 + index * 100).ms,
                                curve: Curves.elasticOut,
                              );
                            }),
                          ).animate().slideY(
                            duration: 600.ms,
                            delay: 700.ms,
                            begin: 0.3,
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Verify Button
                          Container(
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF667eea).withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _verifyOtp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      AppLocalizations.of(context)!.verifyCode,
                                      style: GoogleFonts.cairo(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ).animate().slideY(
                            duration: 600.ms,
                            delay: 800.ms,
                            begin: 0.3,
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Resend Code
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.didntReceiveCode,
                                style: GoogleFonts.cairo(
                                  color: const Color(0xFF718096),
                                ),
                              ),
                              if (_resendCountdown > 0)
                                Text(
                                  '${AppLocalizations.of(context)!.resendIn} ${_resendCountdown}s',
                                  style: GoogleFonts.cairo(
                                    color: const Color(0xFF718096),
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              else
                                TextButton(
                                  onPressed: _isResending ? null : _resendOtp,
                                  child: _isResending
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Color(0xFF667eea),
                                          ),
                                        )
                                      : Text(
                                          AppLocalizations.of(context)!.resendCode,
                                          style: GoogleFonts.cairo(
                                            color: const Color(0xFF667eea),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                            ],
                          ).animate().fadeIn(
                            duration: 600.ms,
                            delay: 900.ms,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
