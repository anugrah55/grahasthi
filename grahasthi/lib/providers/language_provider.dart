import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';
import '../l10n/app_localizations.dart';

class LanguageProvider extends ChangeNotifier {
  String _language = 'en';
  bool _initialized = false;

  String get language => _language;
  bool get isHindi => _language == 'hi';
  bool get initialized => _initialized;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _language = prefs.getString(AppConstants.keyLanguage) ?? 'en';
    AppLocalizations.setLanguage(_language);
    _initialized = true;
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    _language = lang;
    AppLocalizations.setLanguage(lang);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyLanguage, lang);
    notifyListeners();
  }

  /// Check if user has picked a language before (first launch)
  Future<bool> hasSelectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(AppConstants.keyLanguage);
  }

  String t(String key) => AppLocalizations.translate(key);
}
