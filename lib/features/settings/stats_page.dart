import 'package:flutter/material.dart';
import 'package:words_app/app_state.dart';
import 'package:words_app/core/models/word.dart';
import 'package:words_app/core/constants/constants.dart';
import 'package:provider/provider.dart';
class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  // İstatistik hesaplama metodu
  Map<String, dynamic> _calculateStats(
      List<Word> vocabulary, List<Word> learnedWords) {
    final levelCount = <String, int>{};
    final posCount = <String, int>{};
    final learnedLevelCount = <String, int>{};
    final learnedPosCount = <String, int>{};

    vocabulary.forEach((w) {
      levelCount[w.cefr] = (levelCount[w.cefr] ?? 0) + 1;
      posCount[w.pos] = (posCount[w.pos] ?? 0) + 1;
    });

    learnedWords.forEach((word) {
      // Kelimenin ana veri setindeki yerini bulup CEFR'e erişmek gerekir.
      // Basitlik için, doğrudan Word modelindeki CEFR ve POS'u kullanıyoruz.
      learnedLevelCount[word.cefr] = (learnedLevelCount[word.cefr] ?? 0) + 1;
      learnedPosCount[word.pos] = (learnedPosCount[word.pos] ?? 0) + 1;
    });

    return {
      'totalWords': vocabulary.length,
      'learnedCount': learnedWords.length,
      'levelCount': levelCount,
      'posCount': posCount,
      'learnedLevelCount': learnedLevelCount,
      'learnedPosCount': learnedPosCount,
    };
  }

  // İstatistik Kutucuğu Widget'ı
  Widget _buildStatBox(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(8.0), // <<< Padding 12'den 8'e düşürüldü
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding:
                  const EdgeInsets.all(5), // <<< İç padding 6'ya yaklaştırıldı
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon,
                  color: color,
                  size: 20), // <<< İkon boyutu 24'ten 20'ye düşürüldü
            ),
            const SizedBox(height: 5), // <<< Boşluk 8'den 5'e düşürüldü
            Text(value,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold)), // <<< Font 24'ten 20'ye düşürüldü
            const SizedBox(height: 2), // <<< Boşluk 4'ten 2'ye düşürüldü
            Text(title,
                style: const TextStyle(
                    fontSize: 12,
                    color:
                        Colors.grey)), // Font 13'ten 12'ye düşürüldü (minimum)
          ],
        ),
      ),
    );
  }

  // Seviye Dağılım Çubuğu Widget'ı
  Widget _buildLevelProgress(
      String level, int learned, int total, Map<String, Color> levelColors) {
    final percentage = total > 0 ? learned / total : 0.0;
    final color =
        LEVEL_COLORS[level] ?? Colors.grey.shade400; // CONSTANTS'ı kullanır

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(level,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              Text('$learned / $total (${(percentage * 100).round()}%)',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey.shade200,
            color: color,
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    final learnedWords = appState.allWords.where((w) => w.isLearned).toList();
    final stats = _calculateStats(appState.allWords, learnedWords);

    // User Progress verileri
    final totalPoints = appState.userProgress.totalPoints;
    final currentLevel = appState.userProgress.level;

    final levelCounts = stats['levelCount'] as Map<String, int>? ?? {};
    final learnedLevelCounts =
        stats['learnedLevelCount'] as Map<String, int>? ?? {};
    final posCounts = stats['posCount'] as Map<String, int>? ?? {};
    final learnedPosCounts =
        stats['learnedPosCount'] as Map<String, int>? ?? {};

    return Scaffold(
      appBar: AppBar(title: const Text('📊 İlerleme ve İstatistikler')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Genel Metrikler
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.30,
              children: [
                _buildStatBox('Öğrenilen', stats['learnedCount'].toString(),
                    Icons.check_circle, Colors.green),
                _buildStatBox('Toplam Puan', totalPoints.toString(),
                    Icons.emoji_events, Colors.orange),
                _buildStatBox('Toplam Kelime', stats['totalWords'].toString(),
                    Icons.library_books, Colors.blue),
                _buildStatBox('Kullanıcı Seviyesi', currentLevel.toString(),
                    Icons.star, Colors.purple),
              ],
            ),

            const SizedBox(height: 30),

            // Seviye Dağılımı
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Seviye Bazlı Öğrenme',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    // CEFR_LEVELS'ı kullanır
                    ...CEFR_LEVELS.map((level) {
                      final learned = learnedLevelCounts[level] ?? 0;
                      final total = levelCounts[level] ?? 0;
                      // LEVEL_COLORS'ı kullanır
                      return _buildLevelProgress(
                          level, learned, total, LEVEL_COLORS);
                    }).toList(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Kelime Türü Dağılımı
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Kelime Türü Başarısı',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    // POS_NAMES'i kullanır
                    ...POS_NAMES.entries.map((entry) {
                      final pos = entry.key;
                      final learned = learnedPosCounts[pos] ?? 0;
                      final total = posCounts[pos] ?? 0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(entry.value,
                                style: const TextStyle(fontSize: 16)),
                            Text('$learned / $total',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue)),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
