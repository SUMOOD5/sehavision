import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'language_code';

  Locale _locale = const Locale('en', 'US');

  Locale get locale => _locale;

  bool get isArabic => _locale.languageCode == 'ar';
  bool get isEnglish => _locale.languageCode == 'en';

  LanguageProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey) ?? 'en';
      _locale = Locale(languageCode, languageCode == 'ar' ? 'SA' : 'US');
      notifyListeners();
    } catch (e) {
      // Use English as default
      _locale = const Locale('en', 'US');
    }
  }

  Future<void> setLanguage(Locale locale) async {
    if (_locale == locale) return;

    _locale = locale;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, locale.languageCode);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> toggleLanguage() async {
    if (isEnglish) {
      await setLanguage(const Locale('ar', 'SA'));
    } else {
      await setLanguage(const Locale('en', 'US'));
    }
  }

  String getLanguageName() {
    switch (_locale.languageCode) {
      case 'ar':
        return 'العربية';
      case 'en':
      default:
        return 'English';
    }
  }

  TextDirection get textDirection {
    return isArabic ? TextDirection.rtl : TextDirection.ltr;
  }
}
