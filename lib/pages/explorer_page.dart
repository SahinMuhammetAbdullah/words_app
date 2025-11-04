import 'package:flutter/material.dart';
import 'package:words_app/app_state.dart';
import 'package:words_app/models/word.dart';
import 'package:words_app/widgets/word_card_tile.dart';
import 'package:words_app/widgets/category_card.dart'; 
import 'package:words_app/constants.dart'; 

// Keşif sayfasındaki farklı görünümleri yönetmek için bir Enum
enum ExplorerView { root, levelSelection, posSelection, wordList }

class ExplorerPage extends StatefulWidget {
  const ExplorerPage({super.key});

  @override
  State<ExplorerPage> createState() => _ExplorerPageState();
}

class _ExplorerPageState extends State<ExplorerPage> {
  // Sadece ana görünüme geri dönmek için kullanılır.
  ExplorerView _currentView = ExplorerView.root;
  String? _selectedLevel;
  String? _selectedPos;
  final TextEditingController _searchController = TextEditingController();
  // Arama, bu sayfanın ana state'idir.
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    // Arama metni her değiştiğinde, anlık filtreleme yerine yalnızca state'i güncelleriz.
    _searchController.addListener(_onSearchTextChange);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchTextChange);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchTextChange() {
    setState(() {
      _searchTerm = _searchController.text.trim();

      // Arama temizlendiğinde Root'a dön
      if (_searchTerm.isEmpty && _currentView != ExplorerView.root) {
        _currentView = ExplorerView.root;
        _selectedLevel = null;
        _selectedPos = null;
      }
      // Arama yapılırken WordList'e geç
      else if (_searchTerm.isNotEmpty &&
          _currentView != ExplorerView.wordList) {
        _currentView = ExplorerView.wordList;
        _selectedLevel = null;
        _selectedPos = null;
      }
    });
  }

  void navigateToWords(String? level, String? pos) {
    setState(() {
      _selectedLevel = level;
      _selectedPos = pos;
      _currentView = ExplorerView.wordList; // Kelime listesi görünümüne geç
      _searchTerm = ''; // Yeni bir filtre uygulandığında aramayı temizle
    });
  }

  // Metot: Arama terimi değiştiğinde çağrılır (Canlı Filtreleme)
  void handleSearchChange(String term) {
    setState(() {
      _searchTerm = term.trim();
      // Arama yapılırken filtrelenen tüm içeriği göster (WordList görünümüne geç)
      _currentView =
          term.isNotEmpty ? ExplorerView.wordList : ExplorerView.root;
      _selectedLevel = null;
      _selectedPos = null;
    });
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        controller: _searchController, // <<< KONTROLCÜ KULLANILDI
        onSubmitted: (term) {
          // Enter tuşuna basıldığında kesin olarak WordList'e geç
          if (term.isNotEmpty) {
            setState(() {
              _currentView = ExplorerView.wordList;
              _selectedLevel = null;
              _selectedPos = null;
            });
          }
        },
        decoration: InputDecoration(
          hintText: 'Tüm kelimeler ve anlamları arasında ara...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.grey.shade100,
          // Arama metni varsa temizleme butonu
          suffixIcon: _searchTerm.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchTextChange();
                    setState(() =>
                        _currentView = ExplorerView.root); // Root'a geri dön
                  },
                )
              : null,
        ),
      ),
    );
  }

  // Ana Keşfet Ekranı (Root)
  Widget _buildRootView() {
    // ... (Aynı kalır, sadece arama çubuğu bu metoddan kaldırılmıştır.)
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Seviye Bazlı Öğrenme Kartı
          _buildFeatureCard(
            title: 'Seviye Bazlı Öğrenme',
            subtitle: 'CEFR seviyenize uygun kelimeleri keşfedin',
            icon: Icons.bar_chart,
            colors: [Colors.indigo.shade500, Colors.purple.shade600],
            tags: CEFR_LEVELS
                .map((l) => Chip(
                      label: Text(l,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12)),
                      backgroundColor: LEVEL_COLORS[l],
                    ))
                .toList(),
            onTap: () =>
                setState(() => _currentView = ExplorerView.levelSelection),
          ),
          const SizedBox(height: 20),

          // Kelime Türü Bazlı Kart
          _buildFeatureCard(
            title: 'Kelime Türü Bazlı',
            subtitle: 'Fiil, isim, sıfat ve zarfları gruplar halinde öğrenin',
            icon: Icons.adjust,
            colors: [Colors.purple.shade500, Colors.pink.shade600],
            tags: POS_NAMES.entries
                .map((e) => Chip(
                      label: Text(e.value,
                          style: TextStyle(
                              color: Colors.purple.shade800, fontSize: 12)),
                      backgroundColor: Colors.purple.shade100,
                    ))
                .toList(),
            onTap: () =>
                setState(() => _currentView = ExplorerView.posSelection),
          ),
        ],
      ),
    );
  }

  // Seviye Seçim Ekranı
  Widget _buildLevelSelectionView(AppState appState) {
    final stats = _calculateStats(appState.allWords);
    final levelCounts = stats['levelCount'] as Map<String, int>? ?? {};

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Seviye Seçin',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF424242)),
            ),
          ),
          ...CEFR_LEVELS
              .where((l) => l != 'C1' && l != 'C2')
              .map((level) => CategoryCard(
                    title: '$level Seviyesi',
                    subtitle: '${levelCounts[level] ?? 0} kelime',
                    icon: Icons.school,
                    color: LEVEL_COLORS[level]!,
                    onTap: () => navigateToWords(level, null),
                  )),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Kelime Türü Seçim Ekranı
  Widget _buildPosSelectionView(AppState appState) {
    final stats = _calculateStats(appState.allWords);
    final posCounts = stats['posCount'] as Map<String, int>? ?? {};

    final Map<String, IconData> posIcons = {
      'verb': Icons.auto_stories,
      'noun': Icons.widgets,
      'adjective': Icons.brush,
      'adverb': Icons.flash_on,
      'determiner': Icons.tag,
      'preposition': Icons.link,
      'pronoun': Icons.person,
      'conjunction': Icons.join_full,
      'modal auxiliary': Icons.layers,
      'interjection': Icons.campaign,
    };
    final Map<String, Color> posColors = {
      'verb': Colors.red.shade600,
      'noun': Colors.orange.shade600,
      'adjective': Colors.green.shade600,
      'adverb': Colors.teal.shade600,
      'determiner': Colors.purple.shade600,
      'preposition': Colors.blue.shade600,
      'pronoun': Colors.pink.shade600,
      'conjunction': Colors.brown.shade600,
      'modal auxiliary': Colors.deepOrange.shade600,
      'interjection': Colors.indigo.shade600,
    };

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Kelime Türü Seçin',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF424242)),
            ),
          ),
          ...POS_NAMES.entries.map((entry) {
            final posKey = entry.key;
            final posName = entry.value;
            final count = posCounts[posKey] ?? 0;

            return CategoryCard(
              title: posName,
              subtitle: '$count kelime',
              icon: posIcons[posKey] ?? Icons.category,
              color: posColors[posKey] ?? Colors.grey.shade600,
              onTap: () => navigateToWords(null, posKey),
            );
          }).toList(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Kelime Listesi Görünümü
  Widget _buildWordListView(AppState appState) {
    final allWords = appState.allWords;

    // Filtreleme mantığı: Hem arama terimi hem de seçilen filtreler uygulanır.
    final filteredWords = allWords.where((w) {
      if (_selectedLevel != null && w.cefr != _selectedLevel) return false;
      if (_selectedPos != null && w.pos != _selectedPos) return false;

      // Arama terimi filtresi (Her zaman aktiftir)
      if (_searchTerm.isNotEmpty) {
        final term = _searchTerm.toLowerCase();
        if (!w.headword.toLowerCase().contains(term) &&
            !w.turkish.toLowerCase().contains(term)) return false;
      }
      return true;
    }).toList();

    // Görünüm başlığını belirleme
    String viewTitle = _searchTerm.isNotEmpty
        ? 'Arama Sonuçları'
        : _selectedLevel != null
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

  // Geçici istatistik hesaplama (StatsPage için gerekli)
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

  // Feature Kartı Oluşturucu
  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> colors,
    required List<Widget> tags,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: colors),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: Colors.white, size: 30),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 15),
              Text(title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(subtitle,
                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 15),
              Wrap(spacing: 8, runSpacing: 8, children: tags),
            ],
          ),
        ),
      ),
    );
  }

@override
  Widget build(BuildContext context) {
    final appState = ListenableProvider.of<AppState>(context);

    Widget contentWidget;
    String title = 'Kelime Gezgini';

    // --- AKIŞ KONTROLÜ (Aynı Kalır) ---
    if (_searchTerm.isNotEmpty) {
        // Arama yapılırken WordList görünümüne geç
        _selectedLevel = null;
        _selectedPos = null;
        _currentView = ExplorerView.wordList;
    } else if (_selectedLevel == null && _selectedPos == null) {
        // Arama yoksa ve filtre de yoksa Root'a geri dön
        _currentView = ExplorerView.root;
    }


    // GÖRÜNÜM ATAMASI
    switch (_currentView) {
      case ExplorerView.root:
        contentWidget = _buildRootView(); // Root içeriği
        break;
      case ExplorerView.levelSelection:
        contentWidget = _buildLevelSelectionView(appState); // Seviye Seçim içeriği
        title = 'Seviye Seçin';
        break;
      case ExplorerView.posSelection:
        contentWidget = _buildPosSelectionView(appState); // POS Seçim içeriği
        title = 'Kelime Türü Seçin';
        break;
      case ExplorerView.wordList:
        // WordList içeriği (Filtrelenmiş sonuçlar)
        contentWidget = _buildWordListView(appState); 
        title = _searchTerm.isNotEmpty 
          ? 'Arama Sonuçları: "$_searchTerm"'
          : _selectedLevel != null ? '$_selectedLevel Kelimeleri' : 'Kelime Türü Kelimeleri';
        break;
    }


    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: _currentView != ExplorerView.root
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    // Geri dönüş mantığı
                    if (_currentView == ExplorerView.wordList) {
                      // Eğer arama yapıyorsak ve geri basıldıysa: Aramayı temizle ve Root'a dön
                      if (_searchTerm.isNotEmpty) {
                           _searchController.clear();
                           _searchTerm = '';
                           _currentView = ExplorerView.root;
                           _selectedLevel = null;
                           _selectedPos = null;
                           return; // State'i temizleyip hemen bitir
                      }
                      // Filtreleme varsa, bir önceki seçim ekranına dön
                      _currentView = _selectedLevel != null 
                                     ? ExplorerView.levelSelection 
                                     : ExplorerView.posSelection;
                    } else {
                      // Seçim ekranındaysak Root'a dön
                      _currentView = ExplorerView.root;
                    }
                    _selectedLevel = null;
                    _selectedPos = null;
                  });
                },
              )
            : null,
      ),
      body: Column(
          children: [
              _buildSearchBar(), 
              Expanded(child: contentWidget),
          ],
      ),
    );
  }
}
