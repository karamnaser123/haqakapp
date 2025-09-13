import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../l10n/app_localizations.dart';
import 'auth/login_screen.dart';
import 'auth/otp_verification_screen.dart';
import 'home_screen.dart';
import '../core/services/auth_service.dart';
import '../core/models/user_model.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
    _checkAuthStatus();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthStatus() async {
    // انتظار قليل لعرض الشاشة
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    try {
      final authService = AuthService();
      
      if (authService.isLoggedIn()) {
        // المستخدم مسجل الدخول - التحقق من حالة البريد الإلكتروني
        final user = await authService.getUserInfo();
        
        if (mounted) {
          if (user.emailVerifiedAt == null || user.emailVerifiedAt!.isEmpty) {
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
          } else {
            // البريد الإلكتروني مؤكد - الانتقال للصفحة الرئيسية
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        }
      } else {
        // المستخدم غير مسجل الدخول - الانتقال لصفحة تسجيل الدخول
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      }
    } catch (e) {
      // في حالة الخطأ، نوجه لصفحة تسجيل الدخول
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
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
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Colors.white, Color(0xFFf8f9ff)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.phone_android,
                          size: 80,
                          color: Color(0xFF667eea),
                        ),
                      ).animate().scale(
                        duration: 800.ms,
                        curve: Curves.elasticOut,
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // App Name
                      Text(
                        AppLocalizations.of(context)!.phoneStore,
                        style: GoogleFonts.cairo(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ).animate().fadeIn(
                        duration: 1000.ms,
                        delay: 200.ms,
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Text(
                        AppLocalizations.of(context)!.cashbackApp,
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                      ).animate().fadeIn(
                        duration: 1000.ms,
                        delay: 400.ms,
                      ),
                      
                      const SizedBox(height: 60),
                      
                      // Loading Indicator
                      const SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      ).animate().fadeIn(
                        duration: 600.ms,
                        delay: 600.ms,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
