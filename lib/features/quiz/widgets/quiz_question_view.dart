// lib/features/quiz/widgets/quiz_question_view.dart

import 'package:flutter/material.dart';
import 'package:words_app/features/quiz/quiz_page.dart';

class QuizQuestionView extends StatelessWidget {
  final QuizQuestion question;
  final int questionIndex;
  final int totalQuestions;
  final bool showAnswer;
  final Function(String submittedAnswer) onCheckAnswer;
  final VoidCallback onNextQuestion;

  const QuizQuestionView({
    super.key,
    required this.question,
    required this.questionIndex,
    required this.totalQuestions,
    required this.showAnswer,
    required this.onCheckAnswer,
    required this.onNextQuestion,
  });

  // Soru modunu ekranda gösterilecek başlığa çeviren metod
  String _getQuestionModeTitle(QuizMode mode) {
    switch (mode) {
      case QuizMode.multiple:
        return 'Çoktan Seçmeli Soru';
      case QuizMode.fill:
        return 'Boşluk Doldurma Soru';
      case QuizMode.random:
        // Rastgele modda, alttaki soru tipini gösteririz (question.mode'u kullanır)
        return (question.mode == QuizMode.multiple)
            ? 'Rastgele - Çoktan Seçmeli'
            : 'Rastgele - Boşluk Doldurma';
    }
  }

  // Çoktan Seçmeli (Multiple Choice) Görünümü
  Widget _buildMultipleChoice(BuildContext context, QuizQuestion question) {
    // ... (Çoktan Seçmeli kodları aynı kalır, colorScheme kullanılır)
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Türkçe Anlamı:',
            style: TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 5),
        Text(question.questionText,
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface)),
        const SizedBox(height: 20),
        ...question.options!.map((option) {
          final isSubmitted = showAnswer;
          final isCorrectOption = option == question.correctAnswer;
          final isSelected = isSubmitted && option == question.submittedAnswer;

          Color cardColor = Theme.of(context).cardColor;
          if (isSubmitted) {
            if (isCorrectOption) {
              cardColor = Colors.green.shade100;
            } else if (isSelected) {
              cardColor = Colors.red.shade100;
            }
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Card(
              color: cardColor,
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: InkWell(
                onTap: isSubmitted ? null : () => onCheckAnswer(option),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Text(option,
                              style: const TextStyle(fontSize: 18))),
                      if (isSubmitted)
                        Icon(
                          isCorrectOption
                              ? Icons.check_circle
                              : (isSelected ? Icons.cancel : null),
                          color: isCorrectOption ? Colors.green : Colors.red,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  // Boşluk Doldurma (Fill in the Blank) Görünümü
  Widget _buildFillInTheBlank(BuildContext context, QuizQuestion question) {
    // ... (Boşluk doldurma kodları aynı kalır, colorScheme kullanılır)
    final colorScheme = Theme.of(context).colorScheme;
    final String sentence = question.questionText;
    final String correctWord = question.correctAnswer;
    TextEditingController controller =
        TextEditingController(text: question.submittedAnswer);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Türkçe İpucu:',
            style: TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 5),
        Text(question.word.turkish,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface)),
        const SizedBox(height: 20),

        const Text('Cümleyi Tamamlayın:',
            style: TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 5),
        Text(sentence,
            style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic)),
        const SizedBox(height: 30),

        // Cevap Alanı
        TextField(
          controller: controller,
          enabled: !showAnswer,
          textInputAction: TextInputAction.done,
          onSubmitted: showAnswer ? null : (value) => onCheckAnswer(value),
          decoration: InputDecoration(
            labelText: 'Kelimeyi buraya yazın',
            labelStyle:
                TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            suffixIcon: showAnswer
                ? Icon(
                    question.isAnsweredCorrectly! ? Icons.check : Icons.close,
                    color: question.isAnsweredCorrectly!
                        ? Colors.green
                        : Colors.red)
                : null,
          ),
          style: TextStyle(color: colorScheme.onSurface, fontSize: 18),
        ),
        const SizedBox(height: 20),

        if (showAnswer && !question.isAnsweredCorrectly!)
          Text('Doğru Cevap: ${correctWord}',
              style: TextStyle(
                  color: Colors.green.shade700, fontWeight: FontWeight.bold)),

        const SizedBox(height: 20),

        // Cevapla Butonu
        if (!showAnswer)
          ElevatedButton(
            onPressed: () => onCheckAnswer(controller.text),
            child: const Text('Cevapla'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: colorScheme.secondary,
              foregroundColor: colorScheme.onSecondary,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (questionIndex + 1) / totalQuestions;
    final colorScheme = Theme.of(context).colorScheme;

    // TÜM İÇERİĞİ SAFEAREA İLE SAR
    return SafeArea(
      // <<< GÜVENLİ ALAN SAĞLANDI
      child: SingleChildScrollView(
        // İçeriği dikeyde ortalamak için Center ve AlwaysScrollableScrollPhysics
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),

        child: Center(
          child: Column(
            children: [
              // Ekstra üst boşluk ekleyerek içeriği aşağı çek
              const SizedBox(height: 30), // <<< DİKEY İTME BAŞLANGICI

              // İlerleme Çubuğu ve Skor
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Soru ${questionIndex + 1}/${totalQuestions}',
                      style: const TextStyle(color: Colors.grey)),
                  // Skor: AppState'ten çekilmesi gerekir. Şimdilik yer tutucu.
                  Text('Skor: 0',
                      style: TextStyle(
                          color: colorScheme.secondary,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: colorScheme.surfaceVariant,
                color: colorScheme.secondary,
                borderRadius: BorderRadius.circular(5),
              ),
              const SizedBox(height: 30),

              // Soru Tipi Başlığı
              Container(
                alignment: Alignment.center,
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                decoration: BoxDecoration(
                  color: colorScheme.secondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getQuestionModeTitle(question.mode),
                  style: TextStyle(
                    color: colorScheme.onSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Soru Kartı
              ConstrainedBox(
                // Kartın çok küçük kalmasını önler
                constraints:
                    const BoxConstraints(minHeight: 250, maxWidth: 600),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: question.mode == QuizMode.multiple
                        ? _buildMultipleChoice(context, question)
                        : _buildFillInTheBlank(context, question),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Sonraki Soru Butonu (Cevaplandıysa göster)
              if (showAnswer)
                ElevatedButton(
                  onPressed: onNextQuestion,
                  child: Text(questionIndex < totalQuestions - 1
                      ? 'Sonraki Soru'
                      : 'Testi Bitir'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
