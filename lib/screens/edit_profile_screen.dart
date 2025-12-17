import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../core/services/auth_service.dart';
import '../core/services/language_service.dart';
import '../core/models/user_model.dart';
import '../l10n/app_localizations.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  
  UserModel? _user;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _selectedGender;
  File? _selectedImage;
  String? _currentImageUrl;
  final LanguageService _languageService = LanguageService();

  List<String> get _genderOptions => [
    AppLocalizations.of(context)!.male,
    AppLocalizations.of(context)!.female,
  ];

  // خريطة للتحويل من النصوص المترجمة إلى القيم الأصلية
  Map<String, String> get _genderValueMap => {
    AppLocalizations.of(context)!.male: 'male',
    AppLocalizations.of(context)!.female: 'female',
  };

  // خريطة للتحويل من القيم الأصلية إلى النصوص المترجمة
  Map<String, String> get _genderDisplayMap => {
    'male': AppLocalizations.of(context)!.male,
    'female': AppLocalizations.of(context)!.female,
  };

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final authService = AuthService();
      final user = await authService.getUserInfo();
      
      if (mounted) {
        setState(() {
          _user = user;
          _nameController.text = user.name;
          _ageController.text = user.age?.toString() ?? '';
          _selectedGender = user.gender;
          _currentImageUrl = user.image;
          _isLoading = false;
        });
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
        
        // العودة للصفحة السابقة
        Navigator.of(context).pop();
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

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

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
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.editProfile,
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF667eea),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            isRTL ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.language,
              color: Colors.white,
            ),
            onPressed: () async {
              await _languageService.toggleLanguage();
              if (mounted) {
                setState(() {});
              }
            },
            tooltip: AppLocalizations.of(context)!.language,
          ),
        ],
      ),
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
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 
                           MediaQuery.of(context).padding.top - 
                           kToolbarHeight,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                      
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
                                color: Colors.white,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
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
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Tap to change image text
                      Center(
                        child: Text(
                          AppLocalizations.of(context)!.tapToChangeImage,
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Name Field
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
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Age Field
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
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Gender Dropdown
                      _buildGenderDropdown(),
                      
                      const SizedBox(height: 40),
                      
                      // Spacer to fill remaining space
                      const Spacer(),
                      
                      // Save Button
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.white, Colors.white70],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
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
                                    color: Color(0xFF667eea),
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  AppLocalizations.of(context)!.saveChanges,
                                  style: GoogleFonts.cairo(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF667eea),
                                  ),
                                ),
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
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: Colors.white70,
          size: 20,
        ),
        labelStyle: GoogleFonts.cairo(
          color: Colors.white70,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white30),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white30),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white30,
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
                color: Colors.white70,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.selectGender,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          isExpanded: true,
          dropdownColor: const Color(0xFF667eea),
          items: _genderOptions.map((String gender) {
            return DropdownMenuItem<String>(
              value: gender,
              child: Text(
                gender,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  color: Colors.white,
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

  Widget _buildDefaultAvatar() {
    return Container(
      width: 120,
      height: 120,
      decoration: const BoxDecoration(
        color: Colors.white30,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.person,
        size: 60,
        color: Colors.white,
      ),
    );
  }
}
