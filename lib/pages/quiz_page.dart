import 'package:flutter/material.dart';
import 'package:words_app/app_state.dart';
import 'package:words_app/models/word.dart';

enum QuizState { intro, question, result }

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  QuizState _quizState = QuizState.intro;
  List<Word> _quizWords = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  List<String> _currentOptions = [];
  bool _showAnswer = false;
  String? _selectedOption;

  void _startQuiz(List<Word> allWords) {
    final pool = allWords.where((w) => w.repetitionCount < 3 || !w.isLearned).toList();
    
    // Basit rastgele seçim
    pool.shuffle();
    _quizWords = pool.take(5).toList();

    setState(() {
      _quizState = QuizState.question;
      _currentQuestionIndex = 0;
      _score = 0;
      _showAnswer = false;
      _loadQuestion(_quizWords.first);
    });
  }

  void _loadQuestion(Word word) {
    final appState = ListenableProvider.of<AppState>(context, listen: false);
    final correctTurkish = word.turkish;
    final otherWords = appState.allWords.where((w) => w.headword != word.headword).toList();
    otherWords.shuffle();
    
    // Rastgele 3 yanlış şık
    final randomOptions = otherWords.take(3).map((w) => w.turkish).toList();
    
    _currentOptions = [...randomOptions, correctTurkish];
    _currentOptions.shuffle();
    _selectedOption = null;
    _showAnswer = false;
  }

  void _handleAnswer(String selectedOption) async {
    if (_showAnswer) return;

    final appState = ListenableProvider.of<AppState>(context, listen: false);
    final currentWord = _quizWords[_currentQuestionIndex];
    final isCorrect = selectedOption == currentWord.turkish;

    setState(() {
      _showAnswer = true;
      _selectedOption = selectedOption;
      if (isCorrect) {
        _score++;
      }
    });

    // SRS güncellemesi
    final updatedWord = appState.calculateNextReview(currentWord, isCorrect);
    await appState.updateWordProgress(updatedWord);
  }

  void _nextQuestion() {
    setState(() {
      _currentQuestionIndex++;
      if (_currentQuestionIndex >= _quizWords.length) {
        _quizState = QuizState.result;
      } else {
        _loadQuestion(_quizWords[_currentQuestionIndex]);
      }
    });
  }

  Widget _buildIntro(List<Word> allWords) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.flash_on, size: 80, color: Colors.orange),
          const SizedBox(height: 20),
          const Text(
            'Hızlı Test Modu',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Test, tekrara ihtiyacı olan veya yeni kelimelerinizden 5 soru olarak oluşturulur.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => _startQuiz(allWords),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Testi Başlat'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              textStyle: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion() {
    final currentWord = _quizWords[_currentQuestionIndex];
    final isCorrect = _selectedOption == currentWord.turkish;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'Soru ${_currentQuestionIndex + 1} / ${_quizWords.length}',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Text(
            '"${currentWord.headword}" kelimesinin Türkçe karşılığı nedir?',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () => ListenableProvider.of<AppState>(context, listen: false),
            icon: const Icon(Icons.volume_up, color: Colors.white),
            label: const Text('Oku', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          ),
          const SizedBox(height: 30),

          // Şıklar
          ..._currentOptions.map((option) {
            Color color = Colors.grey.shade200;
            Color textColor = Colors.black;

            if (_showAnswer) {
              if (option == currentWord.turkish) {
                color = Colors.green.shade100;
                textColor = Colors.green.shade800;
              } else if (option == _selectedOption) {
                color = Colors.red.shade100;
                textColor = Colors.red.shade800;
              }
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                tileColor: color,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: color == Colors.grey.shade200 ? Colors.grey.shade300 : Colors.transparent)),
                title: Text(option, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                onTap: _showAnswer ? null : () => _handleAnswer(option),
                trailing: _showAnswer ? Icon(option == currentWord.turkish ? Icons.check_circle : (option == _selectedOption ? Icons.cancel : null), color: option == currentWord.turkish ? Colors.green : Colors.red) : null,
              ),
            );
          }).toList(),

          if (_showAnswer)
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Column(
                children: [
                  const Divider(),
                  Text(isCorrect ? 'Doğru!' : 'Yanlış. Doğru cevap: ${currentWord.turkish}'),
                  Text('Örnek Cümle: "${currentWord.sentenceTr}"', style: const TextStyle(fontStyle: FontStyle.italic)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _nextQuestion,
                    child: Text(_currentQuestionIndex + 1 < _quizWords.length ? 'Sonraki Soru' : 'Testi Bitir'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResult() {
    final percentage = _quizWords.isEmpty ? 0 : (_score / _quizWords.length * 100).round();
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
          const SizedBox(height: 20),
          const Text(
            'Test Bitti!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'Puanınız: $_score / ${_quizWords.length}',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          Text(
            'Başarı Oranı: %$percentage',
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => _startQuiz(ListenableProvider.of<AppState>(context, listen: false).allWords),
            child: const Text('Tekrar Test Yap'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allWords = ListenableProvider.of<AppState>(context).allWords;

    return Scaffold(
      appBar: AppBar(title: const Text('Hızlı Test Modu')),
      body: Center(
        child: switch (_quizState) {
          QuizState.intro => _buildIntro(allWords),
          QuizState.question => _buildQuestion(),
          QuizState.result => _buildResult(),
        },
      ),
    );
  }
}