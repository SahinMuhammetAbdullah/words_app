// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:words_app/data/database/db_helper.dart';
import 'package:words_app/app_state.dart';
import 'package:words_app/app_scaffold.dart';
import 'package:words_app/core/constants/constants.dart';
import 'package:words_app/theme_provider.dart'; // Tema kalıcılığı

void main() async {
  // Widget ağacının SharedPreferences/Veritabanı işlemlerinden önce hazır olduğundan emin ol
  WidgetsFlutterBinding.ensureInitialized();

  // Veritabanını başlatma
  await DatabaseHelper().database;

  runApp(
    MultiProvider(
      providers: [
        // 1. Tema Sağlayıcısı: Tema kalıcılığını yönetir.
        ChangeNotifierProvider(create: (context) => ThemeProvider()),

        // 2. Uygulama Durum Sağlayıcısı: Genel uygulama mantığını yönetir.
        ChangeNotifierProvider(create: (context) => AppState()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ThemeProvider'ı dinle: Tema değiştiğinde MaterialApp yeniden çizilir.
    // Provider.of, özel ListenableProvider yerine standart paketi kullanır.
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Kelime Gezgini',
      debugShowCheckedModeBanner: false,

      // Tema Ayarları
      theme: lightTheme,
      darkTheme: darkTheme,

      // themeMode, ThemeProvider'dan gelen kaydedilmiş tercihi kullanır.
      themeMode: themeProvider.flutterThemeMode,

      home: const AppScaffold(),
    );
  }
}
