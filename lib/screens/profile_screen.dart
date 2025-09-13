import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import '../core/services/auth_service.dart';
import '../core/services/language_service.dart';
import '../core/models/user_model.dart';
import '../l10n/app_localizations.dart';
import 'auth/login_screen.dart';
import 'auth/change_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  
  UserModel? _user;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _selectedGender;
  File? _selectedImage;
  String? _currentImageUrl;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  Timer? _imageRefreshTimer;

  List<String> get _genderOptions => [
    AppLocalizations.of(context)!.male,
    AppLocalizations.of(context)!.female,
    AppLocalizations.of(context)!.other,
  ];

  // خريطة للتحويل من النصوص المترجمة إلى القيم الأصلية
  Map<String, String> get _genderValueMap => {
    AppLocalizations.of(context)!.male: 'male',
    AppLocalizations.of(context)!.female: 'female',
    AppLocalizations.of(context)!.other: 'other',
  };

  // خريطة للتحويل من القيم الأصلية إلى النصوص المترجمة
  Map<String, String> get _genderDisplayMap => {
    'male': AppLocalizations.of(context)!.male,
    'female': AppLocalizations.of(context)!.female,
    'other': AppLocalizations.of(context)!.other,
  };

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
      
      print('Profile Screen - User image URL: ${user.image}');
      
      if (mounted) {
        setState(() {
          _user = user;
          _nameController.text = user.name;
          _ageController.text = user.age?.toString() ?? '';
          _selectedGender = user.gender;
          _currentImageUrl = user.image;
          _isLoading = false;
        });
        print('Profile Screen - Current image URL set to: $_currentImageUrl');
        _animationController.forward();
        
        // إعادة تحميل الصورة كل 30 ثانية لتجنب التعليق
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

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showSnackBar('${AppLocalizations.of(context)!.failedToPickImage}: ${e.toString()}', Colors.red);
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final authService = AuthService();
      await authService.updateProfile(
        name: _nameController.text.trim(),
        age: int.tryParse(_ageController.text.trim()),
        gender: _selectedGender,
        image: _selectedImage,
      );

      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        _showSnackBar(AppLocalizations.of(context)!.profileUpdatedSuccessfully, Colors.green);
        
        // إعادة تحميل البيانات
        await _loadUserProfile();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
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
        Navigator.of(context).pop(); // إغلاق الـ dialog
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // إغلاق الـ dialog
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
          // إعادة تحميل الصورة
        });
      }
    });
  }

  @override
  void dispose() {
    _imageRefreshTimer?.cancel();
    _animationController.dispose();
    _nameController.dispose();
    _ageController.dispose();
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
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    
                    // Profile Card
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
                            // Profile Image
                            Center(
                              child: GestureDetector(
                                onTap: _pickImage,
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
                                    child: _selectedImage != null
                                        ? Image.file(
                                            _selectedImage!,
                                            width: 120,
                                            height: 120,
                                            fit: BoxFit.cover,
                                          )
                                        : _currentImageUrl != null && _currentImageUrl!.isNotEmpty
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
                                                  print('Profile Screen - Error loading image: $error');
                                                  return GestureDetector(
                                                    onTap: () {
                                                      // إعادة تحميل الصورة
                                                      setState(() {
                                                        // إعادة تحميل الصورة
                                                      });
                                                    },
                                                    child: Container(
                                                      width: 120,
                                                      height: 120,
                                                      decoration: const BoxDecoration(
                                                        color: Color(0xFFF7FAFC),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          const Icon(
                                                            Icons.refresh,
                                                            size: 30,
                                                            color: Color(0xFF667eea),
                                                          ),
                                                          const SizedBox(height: 4),
                                                          Text(
                                                            AppLocalizations.of(context)!.tapToRetry,
                                                            style: GoogleFonts.cairo(
                                                              fontSize: 10,
                                                              color: Color(0xFF667eea),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                                // إضافة cache و timeout
                                                cacheWidth: 120,
                                                cacheHeight: 120,
                                                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                                                  if (wasSynchronouslyLoaded) return child;
                                                  return AnimatedOpacity(
                                                    opacity: frame == null ? 0 : 1,
                                                    duration: const Duration(milliseconds: 300),
                                                    child: child,
                                                  );
                                                },
                                              )
                                            : _buildDefaultAvatar(),
                                  ),
                                ),
                              ),
                            ).animate().scale(
                              duration: 800.ms,
                              delay: 400.ms,
                              curve: Curves.elasticOut,
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Tap to change image text
                            Center(
                              child: Text(
                                AppLocalizations.of(context)!.tapToChangeImage,
                                style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  color: const Color(0xFF718096),
                                ),
                              ),
                            ).animate().fadeIn(
                              duration: 600.ms,
                              delay: 500.ms,
                            ),
                            
                            const SizedBox(height: 40),
                            
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
                              delay: 600.ms,
                              begin: 0.3,
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Email (Read-only)
                            _buildReadOnlyField(
                              label: AppLocalizations.of(context)!.email,
                              value: _user?.email ?? '',
                              icon: Icons.email_outlined,
                            ).animate().slideY(
                              duration: 600.ms,
                              delay: 700.ms,
                              begin: 0.3,
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Phone (Read-only)
                            _buildReadOnlyField(
                              label: AppLocalizations.of(context)!.phone,
                              value: _user?.phone ?? AppLocalizations.of(context)!.notProvided,
                              icon: Icons.phone_outlined,
                            ).animate().slideY(
                              duration: 600.ms,
                              delay: 800.ms,
                              begin: 0.3,
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Name (Editable)
                            _buildEditableField(
                              controller: _nameController,
                              label: AppLocalizations.of(context)!.name,
                              icon: Icons.person_outlined,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return AppLocalizations.of(context)!.nameIsRequired;
                                }
                                return null;
                              },
                            ).animate().slideY(
                              duration: 600.ms,
                              delay: 900.ms,
                              begin: 0.3,
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Age (Editable)
                            _buildEditableField(
                              controller: _ageController,
                              label: AppLocalizations.of(context)!.age,
                              icon: Icons.cake_outlined,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  final age = int.tryParse(value);
                                  if (age == null || age < 1 || age > 120) {
                                    return AppLocalizations.of(context)!.pleaseEnterValidAge;
                                  }
                                }
                                return null;
                              },
                            ).animate().slideY(
                              duration: 600.ms,
                              delay: 1000.ms,
                              begin: 0.3,
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Gender (Editable)
                            _buildGenderDropdown().animate().slideY(
                              duration: 600.ms,
                              delay: 1100.ms,
                              begin: 0.3,
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Language Switcher
                            _buildLanguageSwitcher().animate().slideY(
                              duration: 600.ms,
                              delay: 1200.ms,
                              begin: 0.3,
                            ),
                            
                            const SizedBox(height: 40),
                            
                            // Save Button
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
                                onPressed: _isSaving ? null : _updateProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: _isSaving
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        AppLocalizations.of(context)!.saveChanges,
                                        style: GoogleFonts.cairo(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ).animate().slideY(
                              duration: 600.ms,
                              delay: 1200.ms,
                              begin: 0.3,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
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
                      delay: 1300.ms,
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
                      delay: 1400.ms,
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
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF718096),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: const Color(0xFF718096),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    color: const Color(0xFF2d3748),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.cairo(
        fontSize: 16,
        color: const Color(0xFF2d3748),
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF667eea),
          size: 20,
        ),
        labelStyle: GoogleFonts.cairo(
          color: const Color(0xFF718096),
        ),
        filled: true,
        fillColor: const Color(0xFFF7FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF56565)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF56565), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedGender != null ? _genderDisplayMap[_selectedGender] : null,
          hint: Row(
            children: [
              const Icon(
                Icons.person_outline,
                color: Color(0xFF667eea),
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.selectGender,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  color: const Color(0xFF718096),
                ),
              ),
            ],
          ),
          isExpanded: true,
          items: _genderOptions.map((String gender) {
            return DropdownMenuItem<String>(
              value: gender,
              child: Text(
                gender,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  color: const Color(0xFF2d3748),
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedGender = _genderValueMap[newValue];
            });
          },
        ),
      ),
    );
  }

  Widget _buildLanguageSwitcher() {
    final languageService = LanguageService();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF667eea).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.language,
              color: Color(0xFF667eea),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)?.language ?? 'Language',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2d3748),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  languageService.currentLanguageName,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: const Color(0xFF718096),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: languageService.isEnglish,
            onChanged: (value) {
              languageService.toggleLanguage();
            },
            activeColor: const Color(0xFF667eea),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFE2E8F0),
          ),
        ],
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
