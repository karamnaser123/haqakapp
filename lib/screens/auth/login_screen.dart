import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../../l10n/app_localizations.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'otp_verification_screen.dart';
import '../home_screen.dart';
import '../../core/services/auth_service.dart';
import '../../core/models/user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // التحقق من صحة البيانات أولاً
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final authService = AuthService();
      final loginRequest = LoginRequest(
        credentials: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      // استدعاء API
      await authService.login(loginRequest);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // الحصول على معلومات المستخدم للتحقق من حالة البريد الإلكتروني
        try {
          final user = await authService.getUserInfo();
          
          // طباعة معلومات التشخيص
          print('User email verification status:');
          print('emailVerifiedAt: ${user.emailVerifiedAt}');
          print('isEmailVerified: ${user.isEmailVerified}');
          
          // التحقق من أن البريد الإلكتروني غير مفعل
          if (!user.isEmailVerified) {
            print('Email is not verified, redirecting to OTP screen');
            // البريد الإلكتروني غير مؤكد - الانتقال لصفحة OTP
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => OtpVerificationScreen(
                  email: user.email,
                  userId: user.id.toString(),
                ),
              ),
            );
            return;
          } else {
            print('Email is already verified, proceeding to home screen');
          }
        } catch (e) {
          // في حالة الخطأ، نتابع للصفحة الرئيسية
          print('Error getting user info: $e');
        }
        
        // الانتقال للصفحة الرئيسية
        // لا نعرض رسالة نجاح هنا لأن الشاشة ستنتهي بعد الانتقال
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // رسالة خطأ - التحقق من mounted مرة أخرى قبل عرض snackbar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                e.toString().replaceFirst('Exception: ', '').replaceFirst('Exception:', ''),
                style: GoogleFonts.cairo(),
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    
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
                              Icons.phone_android,
                              size: 60,
                              color: Color(0xFF667eea),
                            ),
                          ).animate().scale(
                            duration: 800.ms,
                            curve: Curves.elasticOut,
                          ),
                          
                          const SizedBox(height: 24),
                          
                          Text(
                            AppLocalizations.of(context)!.welcome,
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
                          
                          AnimatedTextKit(
                            animatedTexts: [
                              TypewriterAnimatedText(
                                AppLocalizations.of(context)!.phoneStoreApp,
                                textStyle: GoogleFonts.cairo(
                                  fontSize: 18,
                                  color: Colors.white70,
                                ),
                                speed: const Duration(milliseconds: 100),
                              ),
                            ],
                            totalRepeatCount: 1,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 60),
                    
                    // Login Form
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
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.login,
                              style: GoogleFonts.cairo(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2d3748),
                              ),
                              textAlign: TextAlign.center,
                            ).animate().slideY(
                              duration: 600.ms,
                              delay: 400.ms,
                              begin: -0.3,
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // Email Field
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textDirection: TextDirection.ltr,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!.emailOrPhone,
                                labelStyle: GoogleFonts.cairo(
                                  color: const Color(0xFF718096),
                                ),
                                prefixIcon: const Icon(
                                  Icons.email_outlined,
                                  color: Color(0xFF667eea),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF7FAFC),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppLocalizations.of(context)!.pleaseEnterCredentials;
                                }
                              
                                return null;
                              },
                            ).animate().slideX(
                              duration: 600.ms,
                              delay: 500.ms,
                              begin: -0.3,
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Password Field
                            TextFormField(
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              textDirection: TextDirection.ltr,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!.password,
                                labelStyle: GoogleFonts.cairo(
                                  color: const Color(0xFF718096),
                                ),
                                prefixIcon: const Icon(
                                  Icons.lock_outline,
                                  color: Color(0xFF667eea),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                    color: const Color(0xFF718096),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF7FAFC),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppLocalizations.of(context)!.pleaseEnterPassword;
                                }
                                return null;
                              },
                            ).animate().slideX(
                              duration: 600.ms,
                              delay: 600.ms,
                              begin: -0.3,
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Forgot Password
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation, secondaryAnimation) => const ForgotPasswordScreen(),
                                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                        return SlideTransition(
                                          position: Tween<Offset>(
                                            begin: const Offset(1.0, 0.0),
                                            end: Offset.zero,
                                          ).animate(CurvedAnimation(
                                            parent: animation,
                                            curve: Curves.easeInOut,
                                          )),
                                          child: child,
                                        );
                                      },
                                      transitionDuration: const Duration(milliseconds: 300),
                                    ),
                                  );
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.forgotPassword,
                                  style: GoogleFonts.cairo(
                                    color: const Color(0xFF667eea),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ).animate().fadeIn(
                              duration: 600.ms,
                              delay: 700.ms,
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Login Button
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
                                onPressed: _isLoading ? null : _handleLogin,
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
                                        AppLocalizations.of(context)!.login,
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
                            
                            // Register Link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.dontHaveAccount,
                                  style: GoogleFonts.cairo(
                                    color: const Color(0xFF718096),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation, secondaryAnimation) => const RegisterScreen(),
                                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                          return SlideTransition(
                                            position: Tween<Offset>(
                                              begin: const Offset(1.0, 0.0),
                                              end: Offset.zero,
                                            ).animate(CurvedAnimation(
                                              parent: animation,
                                              curve: Curves.easeInOut,
                                            )),
                                            child: child,
                                          );
                                        },
                                        transitionDuration: const Duration(milliseconds: 300),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    AppLocalizations.of(context)!.createAccount,
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
                    ),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
