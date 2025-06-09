import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

class LanguageService {
  // Available languages
  static const Map<String, String> availableLanguages = {
    'ko': '한국어',
    'en': 'English',
    'zh': '中文',
  };
  
  // Get current language code from shared preferences
  static Future<String> getCurrentLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.prefLanguageCode) ?? AppConstants.defaultLanguage;
  }
  
  // Set language code to shared preferences
  static Future<void> setLanguageCode(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefLanguageCode, languageCode);
  }
  
  // Get locale from language code
  static Locale getLocaleFromLanguageCode(String languageCode) {
    switch (languageCode) {
      case 'ko':
        return const Locale('ko', 'KR');
      case 'en':
        return const Locale('en', 'US');
      case 'zh':
        return const Locale('zh', 'CN');
      default:
        return const Locale('ko', 'KR'); // Default to Korean
    }
  }
  
  // Get language name from code
  static String getLanguageName(String languageCode) {
    return availableLanguages[languageCode] ?? availableLanguages[AppConstants.defaultLanguage]!;
  }
}
