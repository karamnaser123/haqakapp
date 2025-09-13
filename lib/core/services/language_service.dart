import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  LanguageService._internal();

  static const String _languageKey = 'selected_language';
  
  Locale _currentLocale = const Locale('ar', '');
  
  Locale get currentLocale => _currentLocale;
  
  bool get isArabic => _currentLocale.languageCode == 'ar';
  bool get isEnglish => _currentLocale.languageCode == 'en';

  // قائمة اللغات المدعومة
  static const List<Locale> supportedLocales = [
    Locale('ar', ''), // العربية
    Locale('en', ''), // الإنجليزية
  ];

  // تهيئة الخدمة
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString(_languageKey);
      
      if (savedLanguage != null) {
        _currentLocale = Locale(savedLanguage);
      } else {
        // اللغة الافتراضية هي العربية
        _currentLocale = const Locale('ar');
        await _saveLanguage('ar');
      }
      
      notifyListeners();
    } catch (e) {
      print('Error initializing language service: $e');
      _currentLocale = const Locale('ar');
    }
  }

  // تغيير اللغة
  Future<void> changeLanguage(String languageCode) async {
    if (languageCode == _currentLocale.languageCode) return;
    
    _currentLocale = Locale(languageCode);
    await _saveLanguage(languageCode);
    notifyListeners();
  }

  // حفظ اللغة المختارة
  Future<void> _saveLanguage(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
    } catch (e) {
      print('Error saving language: $e');
    }
  }

  // الحصول على اسم اللغة الحالية
  String get currentLanguageName {
    switch (_currentLocale.languageCode) {
      case 'ar':
        return 'العربية';
      case 'en':
        return 'English';
      default:
        return 'العربية';
    }
  }

  // الحصول على اتجاه النص
  TextDirection get textDirection {
    return isArabic ? TextDirection.rtl : TextDirection.ltr;
  }

  // الحصول على محاذاة النص
  TextAlign get textAlign {
    return isArabic ? TextAlign.right : TextAlign.left;
  }

  // تبديل اللغة
  Future<void> toggleLanguage() async {
    final newLanguage = isArabic ? 'en' : 'ar';
    await changeLanguage(newLanguage);
  }

  // إعادة تعيين اللغة إلى الافتراضية
  Future<void> resetToDefault() async {
    await changeLanguage('ar');
  }
}
