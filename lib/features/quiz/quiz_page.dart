// lib/features/quiz/quiz_page.dart

import 'package:flutter/material.dart';
import 'package:words_app/app_state.dart';
import 'package:words_app/core/models/word.dart';
import 'package:words_app/features/quiz/widgets/quiz_intro.dart'; // YENİ
import 'package:words_app/features/quiz/widgets/quiz_question_view.dart'; // YENİ
import 'package:words_app/features/quiz/widgets/quiz_result.dart'; // YENİ
import 'dart:math';
import 'package:provider/provider.dart';
// ENUM'LAR VE MODELLER TEKRAR BURADA TANIMLI OLMALIDIR (veya core/models'e taşınmalıdır)
enum QuizState { intro, question, result }
enum QuizMode { multiple, fill, random }

class QuizQuestion {
  final Word word;
  final String questionText;
  final List<String>? options;
  final String correctAnswer;
  final QuizMode mode;
  bool? isAnsweredCorrectly;
  String? submittedAnswer;

  QuizQuestion({
    required this.word, required this.questionText, this.options, 
    required this.correctAnswer, required this.mode,
  });
}

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  QuizState _quizState = QuizState.intro;
  QuizMode? _quizMode;
  List<QuizQuestion> _currentQuiz = [];
  int _questionIndex = 0;
  int _score = 0;
  bool _showAnswer = false;

  final int questionCount = 10;
  String _selectedCefrLevel = 'Tüm Seviyeler';
  final List<String> _cefrLevels = ['Tüm Seviyeler', 'A1', 'A2', 'B1', 'B2'];


  List<Word> _getQuizPool(List<Word> allWords) {
    return allWords
        .where((w) {
          final isNotLearned = w.repetitionCount < 3 && !w.isLearned;
          final isLevelMatch = _selectedCefrLevel == 'Tüm Seviyeler' || w.cefr == _selectedCefrLevel;
          return isNotLearned && isLevelMatch;
        })
        .toList()..shuffle();
  }

  void _startQuiz(List<Word> allWords, QuizMode mode) {
    final pool = _getQuizPool(allWords);
    final quizWords = pool.take(questionCount).toList();

    if (quizWords.isEmpty) {
      setState(() => _quizState = QuizState.intro);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Seçili ${_selectedCefrLevel} seviyesinde test için yeterli kelime bulunamadı.')),
      );
      return;
    }

    // ... (QuizQuestion oluşturma mantığı aynı kalır, sadece metodları kullanırız)
    final List<QuizQuestion> questions = [];
    final Random random = Random();
    final effectiveMode = mode == QuizMode.random ? null : mode;

    for (var word in quizWords) {
      final modeForQuestion = effectiveMode ?? (random.nextBool() ? QuizMode.multiple : QuizMode.fill);

      if (modeForQuestion == QuizMode.multiple) {
          final correctTurkish = word.turkish;
          // Şık havuzu ve oluşturma mantığı... (Çok uzun olduğu için atlandı, ancak eski kodunuzdaki mantık burada çalışır)
          final incorrectOptionsPool = allWords.where((w) => w.turkish != correctTurkish && (_selectedCefrLevel == 'Tüm Seviyeler' || w.cefr == _selectedCefrLevel)).toList()..shuffle();
          final incorrectOptions = incorrectOptionsPool.take(3).map((w) => w.turkish).toList();
          
          while (incorrectOptions.length < 3 && incorrectOptions.length < allWords.length - 1) {
              final randomWord = allWords.firstWhere((w) => !incorrectOptions.contains(w.turkish) && w.turkish != correctTurkish, orElse: () => allWords.first);
              if (randomWord.turkish != correctTurkish) {
                  incorrectOptions.add(randomWord.turkish);
              }
          }
          final options = [correctTurkish, ...incorrectOptions]..shuffle();
          if (options.length > 4) options.removeRange(4, options.length);

          questions.add(QuizQuestion(word: word, questionText: '"${word.headword}" kelimesinin Türkçe karşılığı nedir?', options: options.cast<String>(), correctAnswer: correctTurkish, mode: QuizMode.multiple));
      } else {
          final sentenceWithGap = word.sentence.toLowerCase().replaceAll(word.headword.toLowerCase(), '_____');
          questions.add(QuizQuestion(word: word, questionText: 'Aşağıdaki cümleyi tamamlayınız: \n"$sentenceWithGap"', correctAnswer: word.headword.toLowerCase(), mode: QuizMode.fill));
      }
    }
    // ... (setState ve başlatma aynı kalır)
    setState(() {
      _quizMode = mode;
      _currentQuiz = questions;
      _questionIndex = 0;
      _score = 0;
      _quizState = QuizState.question;
      _showAnswer = false;
    });
  }

  void _checkAnswer(String submittedAnswer) async {
    if (_showAnswer) return;
    final appState = Provider.of<AppState>(context, listen: false);
    final currentQuestion = _currentQuiz[_questionIndex];
    final normalizedAnswer = submittedAnswer.trim().toLowerCase();
    final isCorrect = normalizedAnswer == currentQuestion.correctAnswer.toLowerCase();

    final updatedWord = appState.calculateNextReview(currentQuestion.word, isCorrect);
    await appState.updateWordProgress(updatedWord);
    
    setState(() {
      currentQuestion.submittedAnswer = submittedAnswer;
      currentQuestion.isAnsweredCorrectly = isCorrect;
      _showAnswer = true;
      if (isCorrect) {
        _score++;
        appState.updatePoints(5);
      }
    });
  }

  void _goToNextQuestion() {
    if (_questionIndex < _currentQuiz.length - 1) {
      setState(() {
        _questionIndex++;
        _showAnswer = false;
      });
    } else {
      setState(() {
        _quizState = QuizState.result;
      });
    }
  }
  
  // Seviye seçimi state'ini güncelleyen helper
  void _setCefrLevel(String? level) {
      if (level != null) {
          setState(() => _selectedCefrLevel = level);
      }
  }
  
  // Ana Build Metodu
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    
    switch (_quizState) {
      case QuizState.intro:
        return QuizIntro(
          allWords: appState.allWords,
          questionCount: questionCount,
          cefrLevels: _cefrLevels,
          selectedCefrLevel: _selectedCefrLevel,
          onStartQuiz: (mode) => _startQuiz(appState.allWords, mode),
          onLevelChange: _setCefrLevel,
          getQuizPool: _getQuizPool, // Havuz hesaplama metodu
        );
      case QuizState.question:
        return QuizQuestionView(
          question: _currentQuiz[_questionIndex],
          questionIndex: _questionIndex,
          totalQuestions: _currentQuiz.length,
          showAnswer: _showAnswer,
          onCheckAnswer: _checkAnswer,
          onNextQuestion: _goToNextQuestion,
        );
      case QuizState.result:
        return QuizResult(
          currentQuiz: _currentQuiz,
          quizScore: _score,
          onStartNewQuiz: (mode) => _startQuiz(appState.allWords, mode),
          quizMode: _quizMode!,
        );
    }
  }
}