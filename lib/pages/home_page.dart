import 'package:flutter/material.dart';
import 'package:words_app/app_state.dart';
import 'package:words_app/models/word.dart';
import 'package:intl/intl.dart'; // <<< EKLENDİ (DateFormat hatası için)
import 'package:words_app/app_scaffold.dart'; // <<< BU SATIRIN VAR OLDUĞUNDAN EMİN OLUN!

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Basit istatistik hesaplama (StatsPage'deki mantığın sadeleştirilmiş hali)
  Map<String, dynamic> _calculateHomeStats(List<Word> vocabulary) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    int totalWords = vocabulary.length;
    int learned = 0;
    int dueForReview = 0;

    for (var word in vocabulary) {
      if (word.isLearned) learned++;
      
      final nextReview = word.nextReview;
      if (nextReview.compareTo(today) <= 0 && !word.isLearned) {
        dueForReview++;
      }
    }
    
    final learnedPercentage = totalWords == 0 ? 0 : (learned / totalWords * 100).round();

    return {
      'totalWords': totalWords,
      'learned': learned,
      'dueForReview': dueForReview,
      'learnedPercentage': learnedPercentage,
    };
  }

  // Hızlı Erişim Kartı Oluşturucu (Tekrardan kaçınmak için fonksiyonel widget)
  Widget _buildQuickAccessCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required int targetIndex,
    required BuildContext context,
  }) {
    // AppScaffold'daki BottomNavigationBar index'ine geçişi simüle eder
    final AppScaffoldState? scaffoldState = 
        context.findAncestorStateOfType<AppScaffoldState>();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          // BottomNavigationBar'da ilgili sekmeye geçiş (AppScaffold'un setState'ini çağırır)
          scaffoldState?.setSelectedIndex(targetIndex);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  // İstatistik Kutucuğu
  Widget _buildStatBox(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    // AppState'i dinleyerek veri değişiminde sayfayı yeniler
    final appState = ListenableProvider.of<AppState>(context);
    final stats = _calculateHomeStats(appState.allWords);

    return Scaffold(
      appBar: AppBar(title: const Text('Kelime Öğrenme Paneli')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Özet İstatistikler
            const Text('Özet İlerleme', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), // Kaydırmayı engelle
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.5, // Kutucuk boyutunu ayarlar
              children: [
                _buildStatBox('Toplam Kelime', stats['totalWords'].toString(), Icons.link, Colors.blue),
                _buildStatBox('Öğrenilen (%)', '${stats['learned']} (${stats['learnedPercentage']}%)', Icons.check_circle, Colors.green),
                _buildStatBox('Bugün Tekrar', stats['dueForReview'].toString(), Icons.schedule, Colors.red),
                _buildStatBox('Başarı Hızı', '95%', Icons.trending_up, Colors.purple),
              ],
            ),

            const SizedBox(height: 30),
            const Text('Hızlı Erişim', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // 2. Hızlı Erişim Kartları
            _buildQuickAccessCard(
              title: 'Hemen Tekrar Et',
              subtitle: '${stats['dueForReview']} kelime tekrar bekliyor',
              icon: Icons.refresh,
              color: Colors.red.shade400,
              targetIndex: 2, // Kart Tekrarı sekmesi (0'dan başlar)
              context: context,
            ),
            _buildQuickAccessCard(
              title: 'Yeni Kelimeler Keşfet',
              subtitle: 'Kategori veya seviye bazlı listeleri gör',
              icon: Icons.search,
              color: Colors.orange.shade400,
              targetIndex: 1, // Keşfet sekmesi
              context: context,
            ),
            _buildQuickAccessCard(
              title: 'Bilgimi Sına',
              subtitle: 'Öğrendiğin kelimelerle hızlı test yap',
              icon: Icons.flash_on,
              color: Colors.purple.shade400,
              targetIndex: 3, // Hızlı Test sekmesi
              context: context,
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}