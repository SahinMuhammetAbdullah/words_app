import 'package:flutter/material.dart';
import 'package:words_app/app_state.dart';
import 'package:words_app/constants.dart';
import 'package:words_app/models/word.dart';
import 'package:intl/intl.dart';

class FlashcardDashboard extends StatelessWidget {
  final List<Word> allWords;
  final List<String> levels;
  final List<Word> randomPool;
  final int totalDue;
  final Function(String level) onLevelSelected;
  final Function() onRandomSelected;

  const FlashcardDashboard({
    super.key,
    required this.allWords,
    required this.levels,
    required this.randomPool,
    required this.totalDue,
    required this.onLevelSelected,
    required this.onRandomSelected,
  });

  @override
  Widget build(BuildContext context) {
    final appState = ListenableProvider.of<AppState>(context);
    final userProgress = appState.userProgress;

    final neededToCompleteGoal = userProgress.dailyGoal - userProgress.studiedToday;
    final randomCount = randomPool.length;

    final TextEditingController goalController = TextEditingController(
      text: userProgress.dailyGoal.toString(),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          // 1. Günlük Hedef Alanı ve İlerleme
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Günlük Hedef', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  
                  // Hedef Input Alanı
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: goalController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Hedef Kelime Sayısı',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            suffixText: 'kelime',
                          ),
                          onSubmitted: (value) {
                            final goal = int.tryParse(value) ?? userProgress.dailyGoal;
                            appState.setDailyGoal(goal);
                            FocusScope.of(context).unfocus(); 
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      TextButton(
                        onPressed: () {
                          final goal = int.tryParse(goalController.text) ?? userProgress.dailyGoal;
                          appState.setDailyGoal(goal);
                          FocusScope.of(context).unfocus();
                        },
                        child: const Text('Kaydet'),
                      )
                    ],
                  ),
                  const SizedBox(height: 15),
                  
                  // Hedef Çubuğu
                  Text(
                    'Bugün Çalışıldı: ${userProgress.studiedToday} / ${userProgress.dailyGoal}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 5),
                  LinearProgressIndicator(
                    value: userProgress.studiedToday / userProgress.dailyGoal.clamp(1, userProgress.dailyGoal + 1),
                    minHeight: 10,
                    backgroundColor: Colors.grey.shade300,
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),
          
          // 2. Rastgele Tekrar Kartı
          _buildQuickAccessCard(
            title: 'Rastgele Tekrar (${randomCount} Kelime)',
            subtitle: neededToCompleteGoal > 0 
                ? 'Hedefe $neededToCompleteGoal kelime kaldı.' 
                : 'Günlük hedef tamamlandı! Ekstra çalışma.',
            icon: Icons.shuffle_rounded,
            color: Colors.purple.shade600,
            onTap: randomCount > 0 ? onRandomSelected : null,
          ),

          const SizedBox(height: 30),
          
          // 3. Seviyeye Göre Tekrar Kartları Başlığı
          const Text(
            'Seviyeye Göre Tekrar Listesi',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF424242)),
          ),
          const SizedBox(height: 10),
          
          // 4. Seviye Kartları
          ...levels.map((level) {
            final count = allWords.where((w) => w.cefr == level && w.nextReview.compareTo(DateFormat('yyyy-MM-dd').format(DateTime.now())) <= 0 && !w.isLearned).length;
            final Color color = LEVEL_COLORS[level] ?? Colors.grey;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0), 
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  onTap: count > 0 ? () => onLevelSelected(level) : null, 
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      border: Border.all(color: color.withOpacity(0.5), width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                      color: count > 0 ? color.withOpacity(0.1) : Colors.grey.shade100, 
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 35, height: 35,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
                              child: Text(level, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 15),
                            Text(
                              '$level Seviyesi', 
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF424242)),
                            ),
                          ],
                        ),
                        Text(
                          count > 0 ? '$count kelime' : 'Hepsi Tamamlandı!',
                          style: TextStyle(
                            fontSize: 16, 
                            fontWeight: FontWeight.bold, 
                            color: count > 0 ? Colors.red.shade700 : Colors.green.shade700
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // Yeni Hızlı Erişim Kartı Widget'ı (Tekrar Dashboard'u için)
  Widget _buildQuickAccessCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    // Aynı kodlar (Görünüm kartı)
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.9), color.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 36, color: Colors.white),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 20, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }
}