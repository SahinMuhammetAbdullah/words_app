// lib/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:words_app/core/constants/constants.dart'; // AppThemeMode burada tanımlı olmalı

class ThemeProvider with ChangeNotifier {
  // Kayıt anahtarı
  static const String _themeModeKey = 'theme_mode';

  // Varsayılan tema modu 'system' olsun
  AppThemeMode _themeMode = AppThemeMode.system;
  AppThemeMode get themeMode => _themeMode;

  // Constructor: Temayı hemen yüklemeyi dener
  ThemeProvider() {
    _loadThemeMode();
  }

  // Tema modunu yerel depolamadan yükle
  void _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final savedModeString = prefs.getString(_themeModeKey);

    if (savedModeString != null) {
      try {
        _themeMode = AppThemeMode.values.firstWhere(
          (e) => e.toString() == 'AppThemeMode.$savedModeString',
          orElse: () => AppThemeMode.system,
        );
      } catch (e) {
        // Eğer kayıtlı string enum değerlerinden biri değilse varsayılanı kullan
        _themeMode = AppThemeMode.system;
      }
    }
    notifyListeners();
  }

  // Tema modunu ayarla ve yerel depolamaya kaydet
  void setThemeMode(AppThemeMode mode) async {
    if (mode == _themeMode) return;
    
    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    // Enum'u kaydederken sadece ismini (örneğin 'light' veya 'dark') kaydet
    await prefs.setString(_themeModeKey, mode.name); 
  }

  // MaterialApp için Brightness değerini döndürür
  ThemeMode get flutterThemeMode {
    switch (_themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}