// lib/features/quiz/widgets/quiz_intro.dart

import 'package:flutter/material.dart';
import 'package:words_app/core/models/word.dart';
import 'package:words_app/features/quiz/quiz_page.dart'; // QuizMode/QuizState için

class QuizIntro extends StatelessWidget {
  final List<Word> allWords;
  final int questionCount;
  final List<String> cefrLevels;
  final String selectedCefrLevel;
  final Function(QuizMode mode) onStartQuiz;
  final Function(String? level) onLevelChange;
  final Function(List<Word> allWords) getQuizPool;

  const QuizIntro({
    super.key,
    required this.allWords,
    required this.questionCount,
    required this.cefrLevels,
    required this.selectedCefrLevel,
    required this.onStartQuiz,
    required this.onLevelChange,
    required this.getQuizPool,
  });

  @override
  Widget build(BuildContext context) {
    final poolCount = getQuizPool(allWords).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Test Modu Seçimi',
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87), // <<< Metin rengi
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),

          // Seviye Seçimi Dropdown'u
          Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Test Seviyesini Seçin:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedCefrLevel,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                    ),
                    items: cefrLevels.map((String level) {
                      return DropdownMenuItem<String>(
                        value: level,
                        child: Text(level),
                      );
                    }).toList(),
                    onChanged: onLevelChange,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),

          Text(
            'Seçili ${selectedCefrLevel} seviyesinde tekrar havuzunda ${poolCount} kelime mevcut. Her test ${questionCount} soru içerir.',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          // Çoktan Seçmeli Kart
          _buildQuizModeCard(
            title: 'Çoktan Seçmeli (TR -> EN)',
            subtitle: 'Türkçe anlamını gör, İngilizce kelimeyi seç.',
            icon: Icons.check_circle_outline,
            color: Colors.purple.shade600,
            onTap: poolCount >= questionCount
                ? () => onStartQuiz(QuizMode.multiple)
                : null,
          ),
          const SizedBox(height: 20),

          // Boşluk Doldurma Kartı
          _buildQuizModeCard(
            title: 'Boşluk Doldurma',
            subtitle: 'Cümleyi oku ve boşluğu uygun kelimeyle tamamla.',
            icon: Icons.edit_note,
            color: Colors.green.shade600,
            onTap: poolCount >= questionCount
                ? () => onStartQuiz(QuizMode.fill)
                : null,
          ),
          const SizedBox(height: 20),

          // Rastgele Mod Kartı
          _buildQuizModeCard(
            title: 'Rastgele Karışık Test',
            subtitle:
                'Çoktan Seçmeli ve Boşluk Doldurma soruları karışık gelir.',
            icon: Icons.shuffle, // Düzeltildi
            color: Colors.orange.shade600,
            onTap: poolCount >= questionCount
                ? () => onStartQuiz(QuizMode.random)
                : null,
          ),

          if (poolCount < questionCount)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                'Teste başlamak için en az ${questionCount} kelimeye ihtiyacınız var. Lütfen daha fazla kelime çalışın.',
                style: const TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            )
        ],
      ),
    );
  }

  Widget _buildQuizModeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    Color baseColor = color;
    Color darkerColor = color;

    if (color == Colors.purple.shade600) {
      baseColor = Colors.purple.shade600;
      darkerColor = Colors.purple.shade700;
    } else if (color == Colors.green.shade600) {
      baseColor = Colors.green.shade600;
      darkerColor = Colors.green.shade700;
    } else if (color == Colors.orange.shade600) {
      baseColor = Colors.orange.shade600;
      darkerColor = Colors.orange.shade700;
    }

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: onTap == null ? Colors.grey.shade200 : baseColor,
            gradient: onTap != null
                ? LinearGradient(colors: [baseColor, darkerColor])
                : null,
          ),
          child: Row(
            children: [
              Icon(icon,
                  size: 36, color: onTap == null ? Colors.grey : Colors.white),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color:
                                onTap == null ? Colors.black87 : Colors.white)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 14,
                            color: onTap == null
                                ? Colors.grey
                                : Colors.white.withOpacity(0.8))),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 20, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }
}
