// lib/app_scaffold.dart

import 'package:flutter/material.dart';
import 'package:words_app/pages/home_page.dart';
import 'package:words_app/pages/explorer_page.dart';
import 'package:words_app/pages/flashcard_page.dart';
import 'package:words_app/pages/quiz_page.dart';
import 'package:words_app/pages/stats_page.dart';

// Uygulamanın iskeleti ve navigasyonu
class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key});

  @override
  State<AppScaffold> createState() => AppScaffoldState();
}

// State sınıfı adını dışarıya erişilebilir yaptık (HomePage bu ismi kullanır)
class AppScaffoldState extends State<AppScaffold> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const ExplorerPage(),
    const FlashcardPage(),
    const QuizPage(),
    const StatsPage(),
  ];

  // 1. Dışarıdan çağrılabilen, BottomBar'ı değiştiren ana metot
  void setSelectedIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // 2. BottomNavigationBar'ın kendi onTap event'i için kullanılan metot
  void _onItemTapped(int index) {
    setSelectedIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Ana Sayfa'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Keşfet'),
          BottomNavigationBarItem(
              icon: Icon(Icons.refresh), label: 'Kart Tekrarı'),
          BottomNavigationBarItem(
              icon: Icon(Icons.flash_on), label: 'Hızlı Test'),
          BottomNavigationBarItem(
              icon: Icon(Icons.trending_up), label: 'İstatistik'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped, // Sadece tek bir _onItemTapped çağrılır.
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
