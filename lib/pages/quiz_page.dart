import 'package:flutter/material.dart';
import 'package:words_app/app_state.dart';
import 'package:words_app/models/word.dart';
import 'dart:math';

// =======================================================
// QUIZ MODELLERİ VE ENUM'LAR
// =======================================================

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
    required this.word,
    required this.questionText,
    this.options,
    required this.correctAnswer,
    required this.mode,
  });
}

// =======================================================
// QUIZ PAGE STATE
// =======================================================

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

  final int questionCount = 10; // Her testte 10 soru

  // YENİ: Seviye seçimi değişkeni ve seçenekler
  String _selectedCefrLevel = 'Tüm Seviyeler';
  final List<String> _cefrLevels = ['Tüm Seviyeler', 'A1', 'A2', 'B1', 'B2'];


  // Kelime havuzunu seçer (Öğrenilmemiş, tekrara ihtiyacı olan VE SEÇİLİ SEVİYEDE OLAN kelimeler)
  List<Word> _getQuizPool(List<Word> allWords) {
    return allWords
        .where((w) {
          final isNotLearned = w.repetitionCount < 3 && !w.isLearned;
          // YENİ FİLTRE: Seviye kontrolü
          final isLevelMatch = _selectedCefrLevel == 'Tüm Seviyeler' || w.cefr == _selectedCefrLevel;
          
          return isNotLearned && isLevelMatch;
        })
        .toList()
        ..shuffle();
  }

  // Quiz'i Başlatma ve Soruları Oluşturma
  void _startQuiz(List<Word> allWords, QuizMode mode) {
    final pool = _getQuizPool(allWords);
    final quizWords = pool.take(questionCount).toList();

    if (quizWords.isEmpty) {
      // Yeterli kelime yoksa geri dön
      setState(() => _quizState = QuizState.intro);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Seçili ${_selectedCefrLevel} seviyesinde test için yeterli kelime bulunamadı.')),
      );
      return;
    }

    final List<QuizQuestion> questions = [];
    final Random random = Random();
    
    final effectiveMode = mode == QuizMode.random ? null : mode;

    for (var word in quizWords) {
      final modeForQuestion = effectiveMode ?? (random.nextBool() ? QuizMode.multiple : QuizMode.fill);

      if (modeForQuestion == QuizMode.multiple) {
        // Çoktan Seçmeli Soru Oluşturma
        final correctTurkish = word.turkish;
        
        // Yanlış şıkları, SADECE mevcut testin SEÇİLİ SEVİYESİNDEKİ diğer kelimelerden alalım
        final incorrectOptionsPool = allWords
            .where((w) => w.turkish != correctTurkish && (_selectedCefrLevel == 'Tüm Seviyeler' || w.cefr == _selectedCefrLevel))
            .toList();
            
        incorrectOptionsPool.shuffle();
        final incorrectOptions = incorrectOptionsPool.take(3).map((w) => w.turkish).toList();
        
        // Eğer 3 yanlış şık bulamazsak (örneğin A1'de sadece 4 kelime varsa), eksik olanları genel havuzdan tamamlayabiliriz
        while (incorrectOptions.length < 3 && incorrectOptions.length < allWords.length - 1) {
            final randomWord = allWords.firstWhere((w) => 
                !incorrectOptions.contains(w.turkish) && w.turkish != correctTurkish, 
                orElse: () => allWords.first);
            if (randomWord.turkish != correctTurkish) {
                incorrectOptions.add(randomWord.turkish);
            }
        }
        
        final options = [correctTurkish, ...incorrectOptions]..shuffle();
        
        // Şık sayısını 4'e sabitlemek için kontrol
        if (options.length > 4) options.removeRange(4, options.length);


        questions.add(QuizQuestion(
          word: word,
          questionText: '"${word.headword}" kelimesinin Türkçe karşılığı nedir?',
          options: options.cast<String>(),
          correctAnswer: correctTurkish,
          mode: QuizMode.multiple,
        ));

      } else {
        // Boşluk Doldurma Soru Oluşturma
        final sentenceWithGap = word.sentence.toLowerCase().replaceAll(word.headword.toLowerCase(), '_____');

        questions.add(QuizQuestion(
          word: word,
          questionText: 'Aşağıdaki cümleyi tamamlayınız: \n"$sentenceWithGap"',
          correctAnswer: word.headword.toLowerCase(),
          mode: QuizMode.fill,
        ));
      }
    }

    setState(() {
      _quizMode = mode;
      _currentQuiz = questions;
      _questionIndex = 0;
      _score = 0;
      _quizState = QuizState.question;
      _showAnswer = false;
    });
  }

  // Cevabı Kontrol Etme ve İlerlemeyi Kaydetme
  void _checkAnswer(String submittedAnswer) async {
    if (_showAnswer) return;

    final appState = ListenableProvider.of<AppState>(context, listen: false);
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
        appState.updatePoints(5); // Quiz için 5 puan
      }
    });
  }

  // Sonraki Soruya Geçme
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

  // =======================================================
  // UI - GÖRÜNÜM METOTLARI
  // =======================================================

  Widget _buildIntroView(List<Word> allWords) {
    final poolCount = _getQuizPool(allWords).length;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Test Modu Seçimi',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF424242)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),

          // YENİ: Seviye Seçimi Dropdown'u
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Test Seviyesini Seçin:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _selectedCefrLevel,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    ),
                    items: _cefrLevels.map((String level) {
                      return DropdownMenuItem<String>(
                        value: level,
                        child: Text(level),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedCefrLevel = newValue;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          
          // Güncellenmiş metin: Seviyeye göre kelime sayısını gösterir
          Text(
            'Seçili ${_selectedCefrLevel} seviyesinde tekrar havuzunda ${poolCount} kelime mevcut. Her test ${questionCount} soru içerir.',
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
            onTap: poolCount >= questionCount ? () => _startQuiz(allWords, QuizMode.multiple) : null,
          ),
          const SizedBox(height: 20),

          // Boşluk Doldurma Kartı
          _buildQuizModeCard(
            title: 'Boşluk Doldurma',
            subtitle: 'Cümleyi oku ve boşluğu uygun kelimeyle tamamla.',
            icon: Icons.edit_note,
            color: Colors.green.shade600,
            onTap: poolCount >= questionCount ? () => _startQuiz(allWords, QuizMode.fill) : null,
          ),
          const SizedBox(height: 20),

          // Rastgele Mod Kartı
          _buildQuizModeCard(
            title: 'Rastgele Karışık Test',
            subtitle: 'Çoktan Seçmeli ve Boşluk Doldurma soruları karışık gelir.',
            icon: Icons.shuffle_on,
            color: Colors.orange.shade600,
            onTap: poolCount >= questionCount ? () => _startQuiz(allWords, QuizMode.random) : null,
          ),
          
          if (poolCount < questionCount)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                'Teste başlamak için en az ${questionCount} kelimeye ihtiyacınız var. Lütfen daha fazla kelime çalışın.',
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
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
    // shade700 hatasını çözmek için renkleri MaterialColor'dan alıyoruz
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
              Icon(icon, size: 36, color: onTap == null ? Colors.grey : Colors.white),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: onTap == null ? Colors.black87 : Colors.white)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: TextStyle(fontSize: 14, color: onTap == null ? Colors.grey : Colors.white.withOpacity(0.8))),
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

  // Çoktan Seçmeli (Multiple Choice) Görünümü
  Widget _buildMultipleChoice(QuizQuestion question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Türkçe Anlamı:', style: TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 5),
        Text(question.questionText, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF424242))),
        const SizedBox(height: 20),
        
        ...question.options!.map((option) {
          final isSubmitted = _showAnswer;
          final isCorrectOption = option == question.correctAnswer;
          final isSelected = isSubmitted && option == question.submittedAnswer;

          Color cardColor = Colors.white;
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: InkWell(
                onTap: isSubmitted ? null : () => _checkAnswer(option),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(option, style: const TextStyle(fontSize: 18))),
                      if (isSubmitted)
                        Icon(
                          isCorrectOption ? Icons.check_circle : (isSelected ? Icons.cancel : null),
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
  Widget _buildFillInTheBlank(QuizQuestion question) {
    final String sentence = question.questionText;
    final String correctWord = question.correctAnswer;
    TextEditingController controller = TextEditingController(text: question.submittedAnswer);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Türkçe Anlamı (ipucu olarak)
        const Text('Türkçe İpucu:', style: TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 5),
        Text(question.word.turkish, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),

        // Cümle
        const Text('Cümleyi Tamamlayın:', style: TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 5),
        Text(sentence, style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic)),
        const SizedBox(height: 30),

        // Cevap Alanı
        TextField(
          controller: controller,
          enabled: !_showAnswer,
          textInputAction: TextInputAction.done,
          onSubmitted: _showAnswer ? null : (value) => _checkAnswer(value),
          decoration: InputDecoration(
            labelText: 'Kelimeyi buraya yazın',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            suffixIcon: _showAnswer 
                ? Icon(question.isAnsweredCorrectly! ? Icons.check : Icons.close, color: question.isAnsweredCorrectly! ? Colors.green : Colors.red)
                : null,
          ),
        ),
        const SizedBox(height: 20),

        if (_showAnswer && !question.isAnsweredCorrectly!)
          Text('Doğru Cevap: ${correctWord}', style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold)),

        const SizedBox(height: 20),

        // Cevapla Butonu (Sadece cevaplanmadıysa göster)
        if (!_showAnswer)
          ElevatedButton(
            onPressed: () => _checkAnswer(controller.text),
            child: const Text('Cevapla'),
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50), backgroundColor: Colors.purple.shade600, foregroundColor: Colors.white),
          ),
      ],
    );
  }

  // Soru Görünümü
  Widget _buildQuestionView() {
    final currentQuestion = _currentQuiz[_questionIndex];
    final progress = (_questionIndex + 1) / _currentQuiz.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // İlerleme Çubuğu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Soru ${_questionIndex + 1}/${_currentQuiz.length}', style: const TextStyle(color: Colors.grey)),
              Text('Skor: $_score', style: TextStyle(color: Colors.purple.shade600, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: Colors.grey.shade300,
            color: Colors.purple.shade600,
            borderRadius: BorderRadius.circular(5),
          ),
          const SizedBox(height: 30),

          // Soru Kartı
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: currentQuestion.mode == QuizMode.multiple
                  ? _buildMultipleChoice(currentQuestion)
                  : _buildFillInTheBlank(currentQuestion),
            ),
          ),
          const SizedBox(height: 20),

          // Sonraki Soru Butonu (Cevaplandıysa göster)
          if (_showAnswer)
            ElevatedButton(
              onPressed: _goToNextQuestion,
              child: Text(_questionIndex < _currentQuiz.length - 1 ? 'Sonraki Soru' : 'Testi Bitir'),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50), backgroundColor: Colors.blue.shade600, foregroundColor: Colors.white),
            )
        ],
      ),
    );
  }

  // Sonuç Görünümü
  Widget _buildResultView(AppState appState) {
    final totalQuestions = _currentQuiz.length;
    final percentage = (totalQuestions > 0) ? (_score / totalQuestions * 100).round() : 0;
    
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
                Text('Puanınız: $_score / $totalQuestions', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.green)),
                Text('Başarı Oranı: $percentage%', style: const TextStyle(fontSize: 18, color: Colors.grey)),
                const SizedBox(height: 30),

                ElevatedButton.icon(
                  onPressed: () => _startQuiz(appState.allWords, _quizMode!),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tekrar Test Yap'),
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50), backgroundColor: Colors.purple.shade700, foregroundColor: Colors.white),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => setState(() => _quizState = QuizState.intro),
                  child: const Text('Mod Seçimine Dön'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = ListenableProvider.of<AppState>(context);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Hızlı Test')),
      body: Builder(
        builder: (context) {
          switch (_quizState) {
            case QuizState.intro:
              return _buildIntroView(appState.allWords);
            case QuizState.question:
              return _buildQuestionView();
            case QuizState.result:
              return _buildResultView(appState);
          }
        },
      ),
    );
  }
}