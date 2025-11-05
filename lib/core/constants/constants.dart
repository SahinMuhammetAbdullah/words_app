// lib/core/constants.dart

import 'package:flutter/material.dart';

// ======================================================
// VERİ SABİTLERİ (Tema Dışı)
// ======================================================

// CEFR Seviyeleri Listesi
const List<String> CEFR_LEVELS = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

const Color PRIMARY_COLOR_LOGO = Color(0xFF00bcd4); // Turkuaz/Mavi-Yeşil
const Color ACCENT_COLOR_LOGO = Color(0xFFe57373); // Hafif Kırmızı (Vurgu)

// Seviyelere Özel Renkler
const Map<String, Color> LEVEL_COLORS = {
  'A1': Colors.green,
  'A2': Colors.lightGreen,
  'B1': Colors.blue,
  'B2': Colors.indigo,
  'C1': Colors.purple,
  'C2': Colors.pink,
};

// Kelime Türleri ve Türkçe Karşılıkları
const Map<String, String> POS_NAMES = {
  'verb': 'Fiil',
  'noun': 'İsim',
  'adjective': 'Sıfat',
  'adverb': 'Zarf',
  'determiner': 'Belirteç',
  'preposition': 'Edat',
  'pronoun': 'Zamir',
  'conjunction': 'Bağlaç',
  'modal auxiliary': 'Modal Yardımcı Fiil',
  'interjection': 'Ünlem',
};

enum AppThemeMode { light, dark, system }

// ======================================================
// TEMA TANIMLAMALARI
// ======================================================

// Aydınlık Tema Renk Şeması
final ColorScheme lightColorScheme = ColorScheme.fromSeed(
  seedColor: PRIMARY_COLOR_LOGO, // <<< seedColor ZORUNLU PARAMETRESİ EKLENDİ
  brightness: Brightness.light,
  primary: PRIMARY_COLOR_LOGO,
  onPrimary: Colors.white,
  surface: Colors.white,
  onSurface: Colors.grey.shade900,
  error: Colors.red.shade700,
  secondary: Colors.purple.shade600,
  onSecondary: Colors.white,
);

// Karanlık Tema Renk Şeması
final ColorScheme darkColorScheme = ColorScheme.fromSeed(
  seedColor: PRIMARY_COLOR_LOGO, // <<< seedColor ZORUNLU PARAMETRESİ EKLENDİ
  brightness: Brightness.dark,
  primary: PRIMARY_COLOR_LOGO,
  onPrimary: Colors.white,
  surface: Colors.grey.shade800,
  onSurface: Colors.white,
  error: Colors.red.shade400,
  secondary: Colors.purple.shade400,
  onSecondary: Colors.white,
);

// Temel Aydınlık Tema (Light Theme)
final ThemeData lightTheme = ThemeData(
  colorScheme: lightColorScheme,
  scaffoldBackgroundColor: Colors.white,
  cardColor: Colors.white,

  // HATA DÜZELTİLDİ: apply() metodu doğru kullanıldı, metin rengini onSurface'e bağlar.
  textTheme: Typography.material2018().black.apply(
        bodyColor: lightColorScheme.onSurface,
        displayColor: lightColorScheme.onSurface,
      ),

  appBarTheme: AppBarTheme(
    color: lightColorScheme.primary,
    titleTextStyle: TextStyle(
        color: lightColorScheme.onPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w500),
    iconTheme: IconThemeData(color: lightColorScheme.onPrimary),
    elevation: 0,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: lightColorScheme.primary,
      foregroundColor: lightColorScheme.onPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  ),
  useMaterial3: true,
);

// Temel Karanlık Tema (Dark Theme)
final ThemeData darkTheme = ThemeData(
  colorScheme: darkColorScheme,
  brightness: Brightness.dark,
  cardColor: darkColorScheme.surface,
  scaffoldBackgroundColor: Colors.grey.shade900,

  // HATA DÜZELTİLDİ: apply() metodu doğru kullanıldı, metin rengini onSurface'e bağlar.
  textTheme: Typography.material2018().white.apply(
        bodyColor: darkColorScheme.onSurface,
        displayColor: darkColorScheme.onSurface,
      ),

  appBarTheme: AppBarTheme(
    color: darkColorScheme.surface,
    titleTextStyle: TextStyle(
        color: darkColorScheme.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w500),
    iconTheme: IconThemeData(color: darkColorScheme.onSurface),
    elevation: 0,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: darkColorScheme.primary,
      foregroundColor: darkColorScheme.onPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  ),
  useMaterial3: true,
);
