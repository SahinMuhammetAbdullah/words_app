import 'package:flutter/material.dart';
import 'package:words_app/core/models/word.dart';
import 'package:intl/intl.dart';
import 'package:words_app/app_state.dart'; 
import 'package:words_app/core/constants/constants.dart';
import 'package:words_app/features/repetition/widgets/repetition_dashboard.dart'; // Yeni Dashboard widget'ı
import 'package:words_app/features/repetition/widgets/repetition_view.dart';     // Yeni Kart Görünümü widget'ı

class RepetitionPage extends StatefulWidget {
  const RepetitionPage({super.key});

  @override
  State<RepetitionPage> createState() => _RepetitionPageState();
}

class _RepetitionPageState extends State<RepetitionPage> {
  int _currentIndex = 0;
  
  List<Word> _reviewWords = [];
  int _lastKnownAllWordsLength = 0; 
  
  String? _selectedLevel;
  final List<String> _levels = CEFR_LEVELS.where((l) => l != 'C1' && l != 'C2').toList(); 

  // 1. Kelimeleri filtreler (Hala burada kalır, çünkü mantık State'e bağlıdır)
  List<Word> _filterReviewWords(List<Word> allWords) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final filterLevel = _selectedLevel; 

    if (filterLevel == null) return []; 

    final reviewWords = allWords.where((word) {
      final isDue = word.nextReview.compareTo(today) <= 0 && !word.isLearned;
      final isLevelMatch = filterLevel == 'RANDOM' ? true : word.cefr == filterLevel;
      
      return isDue && isLevelMatch;
    }).toList();
    
    return reviewWords;
  }

  // 2. Kelime listesini yükler ve karıştırır
  void _loadAndShuffleWords(List<Word> allWords) {
    _reviewWords = _filterReviewWords(allWords); 
    _reviewWords.shuffle(); 
    _currentIndex = 0;
    _lastKnownAllWordsLength = allWords.length;
  }

  // 3. Cevap işleyici: İlerlemeyi günceller ve sonraki kelimeye geçer.
  void _handleResponse(Word currentWord, bool known) async {
    final appState = ListenableProvider.of<AppState>(context, listen: false);

    final updatedWord = appState.calculateNextReview(currentWord, known);
    await appState.updateWordProgress(updatedWord);

    if (known) {
      appState.updatePoints(10);
    }

    setState(() {
      // Bir sonraki build döngüsünde _reviewWords yeniden filtrelenecektir.
      if (_reviewWords.isNotEmpty) {
        _currentIndex = (_currentIndex + 1) % _reviewWords.length;
      } else {
        _currentIndex = 0;
      }
    });
  }

  // Seviye Seçildiğinde Çağrılır
  void _onLevelSelected(String level) {
      setState(() {
          _selectedLevel = level;
          _loadAndShuffleWords(ListenableProvider.of<AppState>(context, listen: false).allWords); 
      });
  }
  
  // Rastgele Seçildiğinde Çağrılır
  void _onRandomSelected(List<Word> preparedList) {
      setState(() {
          _selectedLevel = 'RANDOM';
          _reviewWords = preparedList; // Dashboard'dan hazırlanan listeyi alır
          _currentIndex = 0;
      });
  }


  @override
  Widget build(BuildContext context) {
    final appState = ListenableProvider.of<AppState>(context, listen: true);
    final allWords = appState.allWords;

    // A. Veri Senkronizasyonu Kontrolü
    if (_reviewWords.isEmpty || allWords.length != _lastKnownAllWordsLength) {
         _loadAndShuffleWords(allWords);
    }
    
    // B. Ana Akış Kontrolü: Seviye seçili mi?
    if (_selectedLevel == null) {
      // DASHBOARD GÖRÜNÜMÜ
      
      // Dashboard için gereken hazırlık (Random listeyi burada yapıyoruz)
      List<Word> randomPool = allWords.where((w) {
          final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
          return w.nextReview.compareTo(today) <= 0 && !w.isLearned;
      }).toList()..shuffle();

      return Scaffold(
        appBar: AppBar(title: const Text('Kart Tekrarı')),
        body: RepetitionDashboard(
            allWords: allWords,
            levels: _levels,
            randomPool: randomPool,
            totalDue: randomPool.length, // Total tekrar sayısını kullan
            onLevelSelected: _onLevelSelected,
            onRandomSelected: () => _onRandomSelected(randomPool),
        ),
      );
    }

    // C. KART TEKRARI GÖRÜNÜMÜ
    
    // İndeks ve Kelime Kontrolü
    if (_reviewWords.isNotEmpty && _currentIndex >= _reviewWords.length) {
      _currentIndex = 0;
    }

    final hasWordsToReview = _reviewWords.isNotEmpty;
    final currentWord = hasWordsToReview ? _reviewWords[_currentIndex] : null;

    if (!hasWordsToReview) {
      // Eğer liste boşsa (Tüm kelimeler bitti)
      return Scaffold(
        appBar: AppBar(
            title: Text('Kart Tekrarı (${_selectedLevel == 'RANDOM' ? 'Rastgele' : _selectedLevel} Seviyesi)'),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () => setState(() => _selectedLevel = null), 
              )
            ]
        ),
        body: Center(
            child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.thumb_up, size: 80, color: Colors.green),
              const SizedBox(height: 20),
              const Text('Seçili seviyede tekrar bekleyen kelime kalmadı. 🎉', textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => setState(() => _selectedLevel = null),
                child: const Text('Seviye Değiştir'),
              )
            ],
          ),
        )),
      );
    }
    
    // Kart Görünümü (FLASHCARD VIEW)
    return Scaffold(
      appBar: AppBar(
          title: Text(
              'Kart Tekrarı (${_selectedLevel == 'RANDOM' ? 'Rastgele' : _selectedLevel} Seviyesi)'),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => setState(
                  () => _selectedLevel = null), 
            )
          ]),
      body: RepetitionView(
          currentWord: currentWord!,
          totalCount: _reviewWords.length,
          currentIndex: _currentIndex,
          onAnswer: _handleResponse,
      ),
    );
  }
}