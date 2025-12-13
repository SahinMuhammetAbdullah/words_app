// lib/features/quiz/widgets/quiz_result.dart

import 'package:flutter/material.dart';
import 'package:words_app/features/quiz/quiz_page.dart';
import 'package:words_app/app_scaffold.dart';

class QuizResult extends StatelessWidget {
  final List<QuizQuestion> currentQuiz;
  final int quizScore;
  final QuizMode quizMode;
  final Function(QuizMode mode) onStartNewQuiz;

  const QuizResult({
    super.key,
    required this.currentQuiz,
    required this.quizScore,
    required this.quizMode,
    required this.onStartNewQuiz,
  });

  @override
  Widget build(BuildContext context) {
    final totalQuestions = currentQuiz.length;
    final percentage =
        (totalQuestions > 0) ? (quizScore / totalQuestions * 100).round() : 0;
    final colorScheme = Theme.of(context).colorScheme;
    Color scoreColor =
        (percentage >= 70) ? Colors.green.shade600 : colorScheme.error;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Card(
          elevation: 8,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.emoji_events,
                    size: 80, color: colorScheme.secondary),
                const SizedBox(height: 20),
                Text('Test Bitti!',
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface)),
                const SizedBox(height: 10),
                Text('Puanınız: $quizScore / $totalQuestions',
                    style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: scoreColor)),
                Text('Başarı Oranı: $percentage%',
                    style: TextStyle(
                        fontSize: 18,
                        color: colorScheme.onSurface.withOpacity(0.7))),
                const SizedBox(height: 30),

                // Tekrar Test Yap Butonu
                ElevatedButton.icon(
                  onPressed: () => onStartNewQuiz(quizMode),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tekrar Test Yap'),
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: colorScheme.secondary,
                      foregroundColor: colorScheme.onSecondary),
                ),
                const SizedBox(height: 10),

                // Mod Seçimine Dön Butonu (Ana sayfaya kesin dönüş)
                TextButton(
                  onPressed: () {
                    // KESİN DÖNÜŞ: Yığındaki her şeyi sil ve yerine AppScaffold'u koy.
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => const AppScaffold()),
                      (Route<dynamic> route) => false, // Tüm rotaları sil
                    );
                  },
                  child: const Text('Mod Seçimine Dön'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
