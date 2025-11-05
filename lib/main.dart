import 'package:flutter/material.dart';
import 'package:words_app/data/database/db_helper.dart';
import 'package:words_app/app_state.dart';
import 'package:words_app/app_scaffold.dart';
import 'package:words_app/core/constants/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Veritabanı başlatma
  await DatabaseHelper().database;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. AppState'i oluşturuyoruz ve widget ağacına yayıyoruz.
    return ListenableProvider(
      create: (context) => AppState(),
      // 2. Provider'ın yaydığı değeri dinlemek için bir Builder kullanıyoruz.
      child: Builder(// Bu Builder, provider'ı dinleyen context'i sağlar
          builder: (providerContext) {
        // AppState'i dinleyerek (listen: true), tema değiştiğinde bu Builder'ı yeniden çalıştırır.
        final appState =
            ListenableProvider.of<AppState>(providerContext, listen: true);

        // Tema modunu AppState'ten al
        ThemeMode mode;
        switch (appState.currentThemeMode) {
          case AppThemeMode.light:
            mode = ThemeMode.light;
            break;
          case AppThemeMode.dark:
            mode = ThemeMode.dark;
            break;
          case AppThemeMode.system:
            mode = ThemeMode.system;
            break;
          default:
            mode = ThemeMode.system; // Varsayılan değer atanmasını garantiler
        }

        return MaterialApp(
          title: 'Kelime Gezgini',
          debugShowCheckedModeBanner: false,
          // Tema Ayarları
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: mode, // Dinlenen tema modu

          home: const AppScaffold(),
        );
      }),
    );
  }
}
