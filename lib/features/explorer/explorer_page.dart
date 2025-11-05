import 'package:flutter/material.dart';

import 'package:words_app/app_state.dart';

import 'package:words_app/core/models/word.dart';
import 'package:words_app/core/constants/constants.dart';

import 'package:words_app/features/explorer/widgets/word_card_tile.dart';
import 'package:words_app/features/explorer/widgets/explorer_root_view.dart';
import 'package:words_app/features/explorer/widgets/explorer_level_selection.dart';
import 'package:words_app/features/explorer/widgets/explorer_pos_selection.dart';
import 'package:words_app/features/explorer/widgets/search_overlay.dart';

// Keşif sayfasındaki farklı görünümleri yönetmek için bir Enum
enum ExplorerView { root, levelSelection, posSelection, wordList }

class ExplorerPage extends StatefulWidget {
  const ExplorerPage({super.key});

  @override
  State<ExplorerPage> createState() => _ExplorerPageState();
}

class _ExplorerPageState extends State<ExplorerPage> {
  ExplorerView _currentView = ExplorerView.root;
  String? _selectedLevel;
  String? _selectedPos;

  // Arama işlemini SearchOverlay'e taşıdığımız için bu alanlar basitleşti.
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = "";
  
  @override
  void initState() {
    super.initState();
    // Arama artık SearchOverlay içinde yapıldığı için listener kaldırıldı.
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Metot: Arama butonu tıklandığında tam ekran arama modalını açar.
  Widget _buildSearchBar(BuildContext context, AppState appState) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 8.0, vertical: 8.0), // <<< DÜZELTİLDİ
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // Tam ekran arama modalını açar
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchOverlay(appState: appState),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.grey),
                const SizedBox(width: 10),
                Text(
                  'Tüm kelimeler ve anlamları arasında ara...',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Metot: Seçimler yapıldığında WordList görünümüne geçişi sağlar.
  void navigateToWords(String? level, String? pos) {
    setState(() {
      _selectedLevel = level;
      _selectedPos = pos;
      _currentView = ExplorerView.wordList;
      _searchTerm = ''; // Filtreye geçerken arama terimini temizle
    });
  }

  // Kelime Listesi Görünümü
  Widget _buildWordListView(AppState appState) {
    final allWords = appState.allWords;

    // Filtreleme mantığı: Sadece Level ve POS filtreleri uygulanır (Arama, SearchOverlay'de yapılır)
    final filteredWords = allWords.where((w) {
      // Not: Arama (searchTerm) filtresi bu metodda KALDIRILDI, artık SearchOverlay'de yönetiliyor.
      if (_selectedLevel != null && w.cefr != _selectedLevel) return false;
      if (_selectedPos != null && w.pos != _selectedPos) return false;
      return true;
    }).toList();

    // Görünüm başlığını belirleme
    String viewTitle = _selectedLevel != null
        ? '$_selectedLevel Kelimeleri'
        : _selectedPos != null
            ? '${POS_NAMES[_selectedPos]!} Kelimeleri'
            : 'Tüm Kelimeler';

    return Column(
      children: [
        // Başlık ve Filtre Bilgisi
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '$viewTitle (${filteredWords.length} kelime)',
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
            textAlign: TextAlign.center,
          ),
        ),

        // Kelime Listesi
        Expanded(
          child: ListView.builder(
            itemCount: filteredWords.length,
            itemBuilder: (context, index) {
              final word = filteredWords[index];
              return WordCardTile(
                word: word,
                onToggleFavorite: () => appState.toggleFavorite(word),
                onToggleLearned: () => appState.toggleLearned(word),
                onSpeak: () => appState.speak(word.headword),
              );
            },
          ),
        ),
      ],
    );
  }

  // Geçici istatistik hesaplama (Helper metotlar aynı kalır)
  Map<String, dynamic> _calculateStats(List<Word> vocabulary) {
    final levelCount = <String, int>{};
    final posCount = <String, int>{};

    vocabulary.forEach((w) {
      levelCount[w.cefr] = (levelCount[w.cefr] ?? 0) + 1;
      posCount[w.pos] = (posCount[w.pos] ?? 0) + 1;
    });

    return {
      'levelCount': levelCount,
      'posCount': posCount,
    };
  }

  // Root View'daki Feature Kartları için bir Helper Fonksiyonu
  void _onViewChange(ExplorerView view) {
    setState(() {
      _currentView = view;
      // Yeni bir seçim başladığında eski filtreleri temizle (Seçim ekranlarında arama yapılmayacak)
      _selectedLevel = null;
      _selectedPos = null;
      _searchTerm = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = ListenableProvider.of<AppState>(context);
    final stats = _calculateStats(appState.allWords);

    Widget contentWidget;
    String title = 'Kelime Gezgini';

    // GÖRÜNÜM ATAMASI
    switch (_currentView) {
      case ExplorerView.root:
        contentWidget = ExplorerRootView(
          onViewChange: _onViewChange,
          stats: stats,
        );
        break;
      case ExplorerView.levelSelection:
        contentWidget = ExplorerLevelSelection(
          appState: appState,
          stats: stats,
          onLevelSelected: (level) => navigateToWords(level, null),
        );
        title = 'Seviye Seçin';
        break;
      case ExplorerView.posSelection:
        contentWidget = ExplorerPosSelection(
          appState: appState,
          stats: stats,
          onPosSelected: (pos) => navigateToWords(null, pos),
        );
        title = 'Kelime Türü Seçin';
        break;
      case ExplorerView.wordList:
        contentWidget = _buildWordListView(appState);
        title = _selectedLevel != null
            ? '$_selectedLevel Kelimeleri'
            : 'Kelime Türü Kelimeleri';
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        // Geri butonu mantığı: Root dışındaki her görünümde butonu göster.
        leading: _currentView != ExplorerView.root
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    if (_currentView == ExplorerView.wordList) {
                      // WordList'ten (filtreli sonuçtan) bir önceki seçim ekranına dön
                      _currentView = _selectedLevel != null
                          ? ExplorerView.levelSelection
                          : ExplorerView.posSelection;
                    } else {
                      // Seçim ekranından Root'a dön
                      _currentView = ExplorerView.root;
                    }
                    _selectedLevel = null;
                    _selectedPos = null;
                    _searchTerm = ''; // Geri döndüğünde aramayı temizle
                  });
                },
              )
            : null,
      ),
      body: Column(
        children: [
          _buildSearchBar(context, appState), // 1. Sabit Arama Çubuğu butonu
          Expanded(child: contentWidget), // 2. Kalan İçerik (Dinamik View)
        ],
      ),
    );
  }
}
