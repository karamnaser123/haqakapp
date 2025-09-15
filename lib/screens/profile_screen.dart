import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/services/auth_service.dart';
import '../core/services/language_service.dart';
import '../core/models/user_model.dart';
import '../l10n/app_localizations.dart';
import 'auth/login_screen.dart';
import 'auth/change_password_screen.dart';
import 'my_orders_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  UserModel? _user;
  bool _isLoading = true;
  String? _currentImageUrl;
  final LanguageService _languageService = LanguageService();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  Timer? _imageRefreshTimer;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserProfile();
  }

  void _initializeAnimations() {
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
  }

  Future<void> _loadUserProfile() async {
    try {
      final authService = AuthService();
      final user = await authService.getUserInfo();
      
      if (mounted) {
        setState(() {
          _user = user;
          _currentImageUrl = user.image;
          _isLoading = false;
        });
        _animationController.forward();
        _startImageRefreshTimer();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showSnackBar('${AppLocalizations.of(context)!.failedToLoadProfile}: ${e.toString()}', Colors.red);
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
              color: const Color(0xFF2d3748),
            ),
          ),
          content: Text(
            AppLocalizations.of(context)!.areYouSureLogout,
            style: GoogleFonts.cairo(
              fontSize: 16,
              color: const Color(0xFF718096),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  color: const Color(0xFF718096),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.logout,
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

  Future<void> _logout() async {
    try {
      final authService = AuthService();
      await authService.logout();
      
      if (mounted) {
        Navigator.of(context).pop(); // Close the dialog
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close the dialog
        _showSnackBar(
          e.toString().replaceFirst('Exception: ', '').replaceFirst('Exception:', ''),
          Colors.red,
        );
      }
    }
  }

  void _startImageRefreshTimer() {
    _imageRefreshTimer?.cancel();
    _imageRefreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted && _currentImageUrl != null && _currentImageUrl!.isNotEmpty) {
        setState(() {
          // Reload image
        });
      }
    });
  }

  @override
  void dispose() {
    _imageRefreshTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          ),
        ),
      );
    }

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
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height - 
                               MediaQuery.of(context).padding.top,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                    const SizedBox(height: 40),
                    
                    // Profile Header Card
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
                        children: [
                          // Profile Image
                          Center(
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF667eea),
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF667eea).withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: _currentImageUrl != null && _currentImageUrl!.isNotEmpty
                                    ? Image.network(
                                        _currentImageUrl!,
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return const Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
                                            ),
                                          );
                                        },
                                        errorBuilder: (context, error, stackTrace) {
                                          return _buildDefaultAvatar();
                                        },
                                      )
                                    : _buildDefaultAvatar(),
                              ),
                            ),
                          ).animate().scale(
                            duration: 800.ms,
                            delay: 400.ms,
                            curve: Curves.elasticOut,
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // User Name
                          Text(
                            _user?.name ?? AppLocalizations.of(context)!.name,
                            style: GoogleFonts.cairo(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2d3748),
                            ),
                          ).animate().fadeIn(
                            duration: 600.ms,
                            delay: 500.ms,
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // User Email
                          Text(
                            _user?.email ?? '',
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              color: const Color(0xFF718096),
                            ),
                          ).animate().fadeIn(
                            duration: 600.ms,
                            delay: 600.ms,
                          ),
                          
                          const SizedBox(height: 30),
                          
                          // Balance Card
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
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
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.account_balance_wallet,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!.myBalance,
                                        style: GoogleFonts.cairo(
                                          fontSize: 14,
                                          color: Colors.white70,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _user?.balance != null && _user!.balance!.isNotEmpty
                                            ? '${_user!.balance} ${AppLocalizations.of(context)!.jd}'
                                            : '0.00 ${AppLocalizations.of(context)!.jd}',
                                        style: GoogleFonts.cairo(
                                          fontSize: 24,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    AppLocalizations.of(context)!.jd,
                                    style: GoogleFonts.cairo(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ).animate().slideY(
                            duration: 600.ms,
                            delay: 700.ms,
                            begin: 0.3,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Edit Profile Button
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
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditProfileScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.edit_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              AppLocalizations.of(context)!.editProfile,
                              style: GoogleFonts.cairo(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().slideY(
                      duration: 600.ms,
                      delay: 800.ms,
                      begin: 0.3,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Change Password Button
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ChangePasswordScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.lock_outline,
                              color: Color(0xFF667eea),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              AppLocalizations.of(context)!.changePassword,
                              style: GoogleFonts.cairo(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF667eea),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().slideY(
                      duration: 600.ms,
                      delay: 900.ms,
                      begin: 0.3,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // My Orders Button
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyOrdersScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.shopping_bag_outlined,
                              color: Color(0xFF667eea),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              AppLocalizations.of(context)!.myOrders,
                              style: GoogleFonts.cairo(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF667eea),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().slideY(
                      duration: 600.ms,
                      delay: 1000.ms,
                      begin: 0.3,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Language Selection Buttons
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Arabic Button
                          Expanded(
                            child: Container(
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: _languageService.isArabic
                                    ? const LinearGradient(
                                        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      )
                                    : null,
                                color: _languageService.isArabic
                                    ? null
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (!_languageService.isArabic) {
                                    await _languageService.changeLanguage('ar');
                                    if (mounted) {
                                      setState(() {});
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.language,
                                      color: _languageService.isArabic 
                                          ? Colors.white 
                                          : const Color(0xFF667eea),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'العربية',
                                      style: GoogleFonts.cairo(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: _languageService.isArabic 
                                            ? Colors.white 
                                            : const Color(0xFF667eea),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // English Button
                          Expanded(
                            child: Container(
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: _languageService.isEnglish
                                    ? const LinearGradient(
                                        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      )
                                    : null,
                                color: _languageService.isEnglish
                                    ? null
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (!_languageService.isEnglish) {
                                    await _languageService.changeLanguage('en');
                                    if (mounted) {
                                      setState(() {});
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.language,
                                      color: _languageService.isEnglish 
                                          ? Colors.white 
                                          : const Color(0xFF667eea),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'English',
                                      style: GoogleFonts.cairo(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: _languageService.isEnglish 
                                            ? Colors.white 
                                            : const Color(0xFF667eea),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().slideY(
                      duration: 600.ms,
                      delay: 1100.ms,
                      begin: 0.3,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Logout Button
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE53E3E), Color(0xFFC53030)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE53E3E).withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _showLogoutDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.logout,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              AppLocalizations.of(context)!.logout,
                              style: GoogleFonts.cairo(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().slideY(
                      duration: 600.ms,
                      delay: 1100.ms,
                      begin: 0.3,
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
        ),
      ),
    );
  }



  Widget _buildDefaultAvatar() {
    return Container(
      width: 120,
      height: 120,
      decoration: const BoxDecoration(
        color: Color(0xFFF7FAFC),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.person,
        size: 60,
        color: Color(0xFF667eea),
      ),
    );
  }
}
