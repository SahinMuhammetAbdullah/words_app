import 'package:flutter/material.dart';
import 'package:words_app/database/db_helper.dart'; 
import 'package:words_app/app_state.dart';
import 'package:words_app/app_scaffold.dart';

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
    return ListenableProvider( 
      create: (context) => AppState(),
      child: MaterialApp(
        title: 'Kelime Gezgini',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          )
        ),
        home: const AppScaffold(),
      ),
    );
  }
}