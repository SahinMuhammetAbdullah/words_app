import 'package:flutter/material.dart';
import 'package:words_app/models/word.dart';
import 'package:intl/intl.dart';
import 'package:words_app/app_state.dart'; // AppState ve Provider için

class FlashcardPage extends StatefulWidget {
  const FlashcardPage({super.key});

  @override
  State<FlashcardPage> createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage> {
  int _currentIndex = 0;

  List<Word> _reviewWords = [];
  int _lastKnownAllWordsLength = 0;

  // Seviye Seçim State'i
  String? _selectedLevel;
  final List<String> _levels = ['A1', 'A2', 'B1', 'B2'];

  // 1. Yardımcı metot: Kelimeleri filtrelenir (karıştırma yapmaz).
  List<Word> _filterReviewWords(List<Word> allWords) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final filterLevel = _selectedLevel;

    if (filterLevel == null) return []; // Seviye seçilmediyse boş liste dön.

    final reviewWords = allWords.where((word) {
      // 1. Tekrar Günü Kontrolü (Bugün veya geçmiş)
      final isDue = word.nextReview.compareTo(today) <= 0 && !word.isLearned;

      // 2. Seviye Kontrolü
      final isLevelMatch = word.cefr == filterLevel;

      return isDue && isLevelMatch;
    }).toList();

    return reviewWords;
  }

  // 2. Kelime listesini yükler ve karıştırır (Yalnızca başlangıçta/değişimde çağrılır)
  void _loadAndShuffleWords(List<Word> allWords) {
    _reviewWords = _filterReviewWords(allWords);
    _reviewWords.shuffle(); // YALNIZCA BURADA KARIŞTIRILIYOR
    _currentIndex = 0;
    _lastKnownAllWordsLength = allWords.length;
  }

  // 3. Cevap işleyici: İlerlemeyi günceller ve sonraki kelimeye geçer.
  void _handleResponse(Word currentWord, bool known) async {
    final appState = ListenableProvider.of<AppState>(context, listen: false);

    // SRS güncellemesi (DB'ye kaydetme)
    final updatedWord = appState.calculateNextReview(currentWord, known);
    await appState.updateWordProgress(updatedWord);

    // Sonraki indekse geçiş
    setState(() {
      // Not: Bir sonraki build döngüsünde _reviewWords güncellenecektir.
      if (_reviewWords.isNotEmpty) {
        // İndeksi bir ileri al, liste boyutunu geçiyorsa başa dön
        _currentIndex = (_currentIndex + 1) % _reviewWords.length;
      } else {
        _currentIndex = 0;
      }
    });
  }

  // Seviye Seçim Ekranı
  Widget _buildLevelSelection(List<Word> allWords) {
    // Burada AppState'i dinlemiyoruz, sadece bir kerelik hesaplama yapıyoruz
    int totalDue = 0;
    for (var level in _levels) {
      totalDue +=
          _filterReviewWords(allWords.where((w) => w.cefr == level).toList())
              .length;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.autorenew,
                size: 60,
                color: Colors.blue), // Icons.refresh_cw yerine autorenew
            const SizedBox(height: 20),
            const Text(
              'Tekrar İçin Seviye Seçin',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Bugün ${_levels.length} seviyede toplam $totalDue kelime tekrar bekliyor.',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _levels.map((level) {
                final count = _filterReviewWords(
                        allWords.where((w) => w.cefr == level).toList())
                    .length;
                return ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedLevel = level;
                      _loadAndShuffleWords(
                          allWords); // Seçim yapıldı, listeyi yükle ve karıştır
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade50,
                    foregroundColor: Colors.blue.shade800,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('$level ($count)',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // Kart Tekrarı Ekranı (İçerik)
  Widget _buildReviewCards(Word currentWord, int totalCount) {
    return Stack(
      // Stack kullanıyoruz
      children: [
        // 1. Ana İçerik (Esnek Kart ve Sayaç)
        Positioned.fill(
          bottom: 120, // Butonların yüksekliği kadar boşluk bırakıyoruz
          child: SingleChildScrollView(
            // Tüm içeriğin kaydırılabilmesini sağlar
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Text(
                    '${_currentIndex + 1} / $totalCount',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),

                // Flashcard Bölümü - Sabit yükseklik KALDIRILDI
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Flashcard(
                    // Artık SizedBox içinde değil, kendisi boyutlanacak
                    word: currentWord,
                  ),
                ),
              ],
            ),
          ),
        ),

        // 2. Butonları En Alta Sabitleme
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            decoration: BoxDecoration(
                color: Theme.of(context)
                    .scaffoldBackgroundColor, // Arka plan rengi (Butonların altı şeffaf olmasın)
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  )
                ]),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _handleResponse(currentWord, false),
                    icon: const Icon(Icons.close),
                    label: const Text('Bilmiyorum',
                        style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15)),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _handleResponse(currentWord, true),
                    icon: const Icon(Icons.check),
                    label:
                        const Text('Biliyorum', style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = ListenableProvider.of<AppState>(context, listen: true);

    // Veri değişimi kontrolü (Sadece DB boyutu değiştiyse yeniden yükle)
    if (_reviewWords.isEmpty ||
        appState.allWords.length != _lastKnownAllWordsLength) {
      _loadAndShuffleWords(appState.allWords);
    }

    // Uygulama akışı kontrolü: Seviye seçildi mi?
    if (_selectedLevel == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Kart Tekrarı')),
        body: _buildLevelSelection(appState.allWords),
      );
    }

    // İndeks kontrolü
    if (_reviewWords.isNotEmpty && _currentIndex >= _reviewWords.length) {
      _currentIndex = 0;
    }

    final hasWordsToReview = _reviewWords.isNotEmpty;
    final currentWord = hasWordsToReview ? _reviewWords[_currentIndex] : null;

    if (!hasWordsToReview) {
      // Tekrar edilecek kelime kalmadıysa
      return Scaffold(
        appBar: AppBar(
            title: Text('Kart Tekrarı (${_selectedLevel} Seviyesi)'),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () => setState(
                    () => _selectedLevel = null), // Seviye seçim ekranına dön
              )
            ]),
        body: Center(
            child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.thumb_up, size: 80, color: Colors.green),
              SizedBox(height: 20),
              Text('Seçili seviyede tekrar bekleyen kelime kalmadı. 🎉',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => setState(() => _selectedLevel = null),
                child: Text('Seviye Değiştir'),
              )
            ],
          ),
        )),
      );
    }

    // Kart gösterme durumu
    return Scaffold(
      appBar: AppBar(
          title: Text('Kart Tekrarı (${_selectedLevel} Seviyesi)'),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => setState(
                  () => _selectedLevel = null), // Seviye seçim ekranına dön
            )
          ]),
      body: _buildReviewCards(currentWord!, _reviewWords.length),
    );
  }
}

// =======================================================
// FLASHCARD ARTIK KENDİ ÇEVİRME DURUMUNU YÖNETEN STATEFUL WIDGET'TIR
// (Bu kod, _FlashcardPageState sınıfının devamına eklenmelidir)
// =======================================================

class Flashcard extends StatefulWidget {
  final Word word;

  const Flashcard({
    super.key,
    required this.word,
  });

  @override
  State<Flashcard> createState() => _FlashcardState();
}

class _FlashcardState extends State<Flashcard> {
  bool _isFlipped = false;

  // Kelime değiştiğinde (yeni kart geldiğinde), kartın çevrilme durumunu sıfırla.
  @override
  void didUpdateWidget(covariant Flashcard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.word.headword != oldWidget.word.headword) {
      setState(() {
        _isFlipped = false; // Yeni kelime gelince kartı ön yüze çevir
      });
    }
  }

  void _flipCard() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Kartı çevirmek için dokunma olayını yakalar
      onTap: _flipCard,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        transitionBuilder: (Widget child, Animation<double> animation) {
          final rotationAnimation =
              Tween(begin: 0.0, end: 1.0).animate(animation);

          return AnimatedBuilder(
            animation: rotationAnimation,
            child: child,
            builder: (context, child) {
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001) // Perspektif efekti
                  ..rotateY(_isFlipped
                      ? rotationAnimation.value * 3.14159
                      : (1.0 - rotationAnimation.value) * 3.14159),
                child: child,
              );
            },
          );
        },
        // Yerel _isFlipped durumuna göre ön veya arka yüzü göster
        child: _isFlipped ? _buildCardBack(context) : _buildCardFront(context),
      ),
    );
  }

  // Kartın Ön Yüzü (İngilizce Kelime + Cümle)
  Widget _buildCardFront(BuildContext context) {
    return Card(
      // Card, Container yerine daha iyi bir gölge ve sınır sağlar
      key: const ValueKey(true),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.blue.shade700, width: 3),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: IntrinsicHeight(
          // İçeriğe göre yüksekliği ayarlar
          child: Column(
            mainAxisSize: MainAxisSize.min, // İçeriğe göre küçül
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.word.headword,
                style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              Text(
                widget.word.pos,
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              Divider(color: Colors.grey.shade300),
              const SizedBox(height: 10),
              // Cümle sarılmasını sağlamak için esnek olmayan widget'ları kullanıyoruz
              Text(
                widget.word.sentence,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Colors.blue.shade700),
              ),
              const SizedBox(height: 20),
              // Seslendirme Butonları
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.volume_up, color: Colors.blue),
                    tooltip: 'Kelimeyi oku',
                    onPressed: () =>
                        ListenableProvider.of<AppState>(context, listen: false)
                            .speak(widget.word.headword),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.hearing, color: Colors.blue),
                    tooltip: 'Cümleyi oku',
                    onPressed: () =>
                        ListenableProvider.of<AppState>(context, listen: false)
                            .speak(widget.word.sentence),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Kartın Arka Yüzü (Türkçe Anlamı + İngilizce ve Türkçe Cümleler)
  Widget _buildCardBack(BuildContext context) {
    return Card(
      key: const ValueKey(false),
      elevation: 8,
      color: Colors.blue,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationY(3.14159), // Metni geri çevirir
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: IntrinsicHeight(
            // İçeriğe göre yüksekliği ayarlar
            child: Column(
              mainAxisSize: MainAxisSize.min, // İçeriğe göre küçül
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.word.turkish,
                  style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                Divider(color: Colors.white70),
                Text(
                  widget.word.sentence,
                  style: const TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                Text(
                  widget.word.sentenceTr,
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
