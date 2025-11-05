// lib/features/quiz/widgets/quiz_result.dart

import 'package:flutter/material.dart';
import 'package:words_app/features/quiz/quiz_page.dart'; // QuizMode/QuizQuestion için

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
    final percentage = (totalQuestions > 0) ? (quizScore / totalQuestions * 100).round() : 0;
    
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events, size: 80, color: Colors.orange),
                const SizedBox(height: 20),
                const Text('Test Bitti!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF424242))),
                const SizedBox(height: 10),
                Text('Puanınız: $quizScore / $totalQuestions', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.green)),
                Text('Başarı Oranı: $percentage%', style: const TextStyle(fontSize: 18, color: Colors.grey)),
                const SizedBox(height: 30),

                ElevatedButton.icon(
                  onPressed: () => onStartNewQuiz(quizMode),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tekrar Test Yap'),
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50), backgroundColor: Colors.purple.shade700!, foregroundColor: Colors.white),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pop(context), // Ana sayfaya dönmek için
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