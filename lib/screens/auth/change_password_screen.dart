import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../l10n/app_localizations.dart';
import '../../core/services/auth_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _oldPasswordVisible = false;
  bool _newPasswordVisible = false;
  bool _confirmPasswordVisible = false;
  
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
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        final authService = AuthService();
        await authService.changePassword(
          oldPassword: _oldPasswordController.text.trim(),
          newPassword: _newPasswordController.text.trim(),
          confirmPassword: _confirmPasswordController.text.trim(),
        );
        
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          
          // عرض رسالة نجاح
          _showSuccessDialog();
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFF48BB78),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.success,
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2d3748),
                ),
              ),
            ],
          ),
          content: Text(
            AppLocalizations.of(context)!.passwordChangedSuccessfully,
            style: GoogleFonts.cairo(
              fontSize: 16,
              color: const Color(0xFF718096),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // إغلاق الـ dialog
                Navigator.pop(context); // العودة لصفحة Profile
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF48BB78),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.ok,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 40,
                  ),
                  child: IntrinsicHeight(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Back Button
                            Align(
                              alignment: Directionality.of(context) == TextDirection.rtl 
                                  ? Alignment.centerRight 
                                  : Alignment.centerLeft,
                              child: IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Directionality.of(context) == TextDirection.rtl 
                                        ? Icons.arrow_forward_ios 
                                        : Icons.arrow_back_ios,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ).animate().fadeIn(
                              duration: 600.ms,
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Logo and Title
                            Center(
                              child: Column(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
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
                                      Icons.lock_reset,
                                      size: 50,
                                      color: Color(0xFF667eea),
                                    ),
                                  ).animate().scale(
                                    duration: 800.ms,
                                    curve: Curves.elasticOut,
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  Text(
                                    AppLocalizations.of(context)!.changePassword,
                                    style: GoogleFonts.cairo(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ).animate().fadeIn(
                                    duration: 1000.ms,
                                    delay: 200.ms,
                                  ),
                                  
                                  const SizedBox(height: 8),
                                  
                                  Text(
                                    AppLocalizations.of(context)!.enterCurrentAndNewPassword,
                                    style: GoogleFonts.cairo(
                                      fontSize: 16,
                                      color: Colors.white70,
                                    ),
                                  ).animate().fadeIn(
                                    duration: 1000.ms,
                                    delay: 400.ms,
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 40),
                            
                            // Form
                            Expanded(
                              child: Container(
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
                                child: _buildFormContent(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Old Password Field
          TextFormField(
            controller: _oldPasswordController,
            obscureText: !_oldPasswordVisible,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.currentPassword,
              labelStyle: GoogleFonts.cairo(
                color: const Color(0xFF718096),
              ),
              prefixIcon: const Icon(
                Icons.lock_outline,
                color: Color(0xFF667eea),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _oldPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: const Color(0xFF718096),
                ),
                onPressed: () {
                  setState(() {
                    _oldPasswordVisible = !_oldPasswordVisible;
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
                return AppLocalizations.of(context)!.pleaseEnterCurrentPassword;
              }
              return null;
            },
          ).animate().slideX(
            duration: 600.ms,
            delay: 500.ms,
            begin: -0.3,
          ),
          
          const SizedBox(height: 20),
          
          // New Password Field
          TextFormField(
            controller: _newPasswordController,
            obscureText: !_newPasswordVisible,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.newPassword,
              labelStyle: GoogleFonts.cairo(
                color: const Color(0xFF718096),
              ),
              prefixIcon: const Icon(
                Icons.lock_outline,
                color: Color(0xFF667eea),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _newPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: const Color(0xFF718096),
                ),
                onPressed: () {
                  setState(() {
                    _newPasswordVisible = !_newPasswordVisible;
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
                return AppLocalizations.of(context)!.pleaseEnterNewPassword;
              }
              if (value.length < 6) {
                return AppLocalizations.of(context)!.passwordMustBeAtLeast6;
              }
              return null;
            },
          ).animate().slideX(
            duration: 600.ms,
            delay: 600.ms,
            begin: -0.3,
          ),
          
          const SizedBox(height: 20),
          
          // Confirm Password Field
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: !_confirmPasswordVisible,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.confirmNewPassword,
              labelStyle: GoogleFonts.cairo(
                color: const Color(0xFF718096),
              ),
              prefixIcon: const Icon(
                Icons.lock_outline,
                color: Color(0xFF667eea),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _confirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: const Color(0xFF718096),
                ),
                onPressed: () {
                  setState(() {
                    _confirmPasswordVisible = !_confirmPasswordVisible;
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
                return AppLocalizations.of(context)!.pleaseConfirmNewPassword;
              }
              if (value != _newPasswordController.text) {
                return AppLocalizations.of(context)!.passwordsDoNotMatch;
              }
              return null;
            },
          ).animate().slideX(
            duration: 600.ms,
            delay: 700.ms,
            begin: -0.3,
          ),
          
          const SizedBox(height: 32),
          
          // Change Password Button
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
              onPressed: _isLoading ? null : _handleChangePassword,
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
                      AppLocalizations.of(context)!.changePassword,
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
        ],
      ),
    );
  }
}
