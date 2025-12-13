// lib/app_scaffold.dart

import 'package:flutter/material.dart';

import 'package:words_app/features/home/home_page.dart';
import 'package:words_app/features/explorer/explorer_page.dart';
import 'package:words_app/features/repetition/repetition_page.dart';
import 'package:words_app/features/quiz/quiz_page.dart';
import 'package:words_app/features/settings/settings_page.dart';

// Uygulamanın iskeleti ve navigasyonu
class AppScaffold extends StatefulWidget {
  // YENİ: Başlangıç sekmesini belirlemek için parametre
  final int initialIndex; 

  const AppScaffold({
    super.key,
    this.initialIndex = 0, // Varsayılan: Ana Sayfa (0. indeks)
  });

  @override
  State<AppScaffold> createState() => AppScaffoldState();
}

// State sınıfı adını dışarıya erişilebilir yaptık
class AppScaffoldState extends State<AppScaffold> {
  // _selectedIndex artık initState'te başlatılmalı.
  late int _selectedIndex; 

  final List<Widget> _pages = [
    const HomePage(),
    const ExplorerPage(),
    const RepetitionPage(),
    const QuizPage(),
    const SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    // Düzeltme: Widget'ın constructor'ından gelen initialIndex ile başlat
    _selectedIndex = widget.initialIndex; 
  }

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

  // Metot: Geri tuşuna basıldığında tetiklenir ve çıkış onayı ister veya ana sekmeye döner.
  Future<bool> _onWillPop() async {
    // Eğer Ana Sayfa'da değilsek (0. indeks):
    if (_selectedIndex != 0) { 
      setState(() {
        _selectedIndex = 0; // Doğrudan Ana Sayfa sekmesine dön
        // NOT: Eğer PageView yerine _pages[_selectedIndex] kullanıyorsanız, 
        // sadece _selectedIndex'i güncellemek yeterlidir.
      });
      return false; // Geri tuşu olayını tüket, uygulamadan çıkma.
    } else {
      // Eğer ana sayfadaysak (0. indeks): Çıkış Onayı Penceresini Göster
      final colorScheme = Theme.of(context).colorScheme;
      final shouldExit = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Uygulamadan Çıkılsın mı?'),
            content: const Text('Uygulamadan çıkmak istediğinizden emin misiniz?'),
            backgroundColor: Theme.of(context).cardColor, 
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false), 
                child: Text('Hayır', style: TextStyle(color: colorScheme.onSurface)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true), 
                child: const Text('Evet, Çık'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.error,
                    foregroundColor: colorScheme.onError,
                ),
              ),
            ],
          );
        },
      );
      
      return shouldExit ?? false; // Onaylanırsa (true) uygulamadan çık.
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope( // Geri tuşu olaylarını yakalamak için
      canPop: false, 
      onPopInvoked: (didPop) async {
        if (didPop) return;
        // Geri tuşu olayı _onWillPop metoduna gönderilir
        final bool shouldPop = await _onWillPop();
        if (shouldPop) {
          // Eğer _onWillPop true döndürürse (yani kullanıcı çıkışı onaylarsa)
          // Burada SystemNavigator.pop() veya eski Navigator.pop() kullanılabilir.
          // Uygulamayı tamamen kapatmak için
          Navigator.of(context).pop(); 
        }
      },
      child: Scaffold(
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
              icon: Icon(Icons.settings),
              label: 'Ayarlar'), 
          ],
          currentIndex: _selectedIndex,
          
          // DÜZELTME: Sabit renkler (blue, grey) yerine tema renkleri kullanıldı.
          selectedItemColor: colorScheme.primary, 
          unselectedItemColor: colorScheme.onSurface.withOpacity(0.6), 
          
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          // BottomNavigationBar arka planı theme.bottomNavigationBarTheme'den gelir.
        ),
      ),
    );
  }
}