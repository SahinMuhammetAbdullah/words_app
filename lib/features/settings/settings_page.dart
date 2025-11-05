// lib/features/settings/settings_page.dart

import 'package:flutter/material.dart';
import 'package:words_app/app_state.dart';
import 'package:words_app/core/constants/constants.dart';
import 'package:words_app/features/settings/stats_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  // İstatistik sayfasına navigasyon metodu
  void _navigateToStats(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StatsPage()),
    );
  }

  // Yardımcı Başlık Widget'ı
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  // Genel Ayar Kutucuğu
  Widget _buildSettingsTile(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // AppState'ten tema durumunu dinliyoruz
    final appState = ListenableProvider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Hesap Ayarları ---
            _buildSectionHeader(context, 'Hesap'),
            _buildSettingsTile(
              context, 
              title: 'Giriş Bilgileri',
              subtitle: 'Kullanıcı adı: Öğrenci (Yer Tutucu)',
              icon: Icons.person,
              onTap: () {},
            ),
            const SizedBox(height: 20),

            // --- 2. Görünüm Ayarları (Tema Seçimi) ---
            _buildSectionHeader(context, 'Görünüm'),
            
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Column(
                children: AppThemeMode.values.map((mode) {
                  String title;
                  switch (mode) {
                    case AppThemeMode.light: title = 'Aydınlık Tema'; break;
                    case AppThemeMode.dark: title = 'Karanlık Tema'; break;
                    case AppThemeMode.system: title = 'Sistem Varsayılanı'; break;
                  }
                  
                  return RadioListTile<AppThemeMode>(
                    title: Text(title),
                    value: mode,
                    groupValue: appState.currentThemeMode,
                    onChanged: (AppThemeMode? newMode) {
                      if (newMode != null) {
                        appState.setThemeMode(newMode); 
                      }
                    },
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // --- 3. İlerleme ve Veri ---
            _buildSectionHeader(context, 'İlerleme ve Veri'),
            
            // İstatistik Sayfasına Yönlendirme
            _buildSettingsTile(
              context, 
              title: 'Detaylı İstatistikler',
              subtitle: 'Öğrenme seviyenizi ve puan dağılımınızı görün',
              icon: Icons.bar_chart,
              onTap: () => _navigateToStats(context),
            ),
            
            // Veri Sıfırlama
            _buildSettingsTile(
              context, 
              title: 'Verileri Sıfırla (Geliştirici)',
              subtitle: 'Tüm öğrenme ilerlemesini ve istatistikleri sıfırlar.',
              icon: Icons.delete_forever,
              onTap: () {
                 // **ÖNEMLİ:** Veri sıfırlama diyalogu burada açılmalıdır.
              },
            ),
          ],
        ),
      ),
    );
  }
}