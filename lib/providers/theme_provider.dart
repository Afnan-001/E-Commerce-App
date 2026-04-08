import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemePreference { device, light, dark }

class ThemeProvider extends ChangeNotifier {
  static const String _storageKey = 'app_theme_preference';

  ThemeMode _themeMode = ThemeMode.system;
  AppThemePreference _preference = AppThemePreference.device;
  bool _isLoaded = false;

  ThemeMode get themeMode => _themeMode;
  AppThemePreference get preference => _preference;
  bool get isLoaded => _isLoaded;

  Future<void> loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final rawValue = prefs.getString(_storageKey);
    _preference = _parsePreference(rawValue);
    _themeMode = _toThemeMode(_preference);
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setPreference(AppThemePreference preference) async {
    _preference = preference;
    _themeMode = _toThemeMode(preference);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, preference.name);
  }

  AppThemePreference _parsePreference(String? rawValue) {
    switch (rawValue) {
      case 'light':
        return AppThemePreference.light;
      case 'dark':
        return AppThemePreference.dark;
      case 'device':
      default:
        return AppThemePreference.device;
    }
  }

  ThemeMode _toThemeMode(AppThemePreference preference) {
    switch (preference) {
      case AppThemePreference.light:
        return ThemeMode.light;
      case AppThemePreference.dark:
        return ThemeMode.dark;
      case AppThemePreference.device:
        return ThemeMode.system;
    }
  }
}
