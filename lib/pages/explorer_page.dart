import 'package:flutter/material.dart';
import 'package:words_app/app_state.dart';
import 'package:words_app/models/word.dart';
import 'package:words_app/widgets/word_card_tile.dart';
import 'package:words_app/widgets/category_card.dart'; // LevelSelectionCard yerine CategoryCard kullanıldı
import 'package:words_app/constants.dart'; // <<< MERKEZİ SABİTLER BURADAN GELİYOR

// Keşif sayfasındaki farklı görünümleri yönetmek için bir Enum
enum ExplorerView { root, levelSelection, posSelection, wordList }


class ExplorerPage extends StatefulWidget {
  const ExplorerPage({super.key});

  // Statik sabitleri doğrudan constants.dart'tan çekiyoruz.
  static const List<String> levels = CEFR_LEVELS;
  static const Map<String, String> posNames = POS_NAMES;
  static const Map<String, Color> levelColors = LEVEL_COLORS;

  @override
  State<ExplorerPage> createState() => _ExplorerPageState();
}

class _ExplorerPageState extends State<ExplorerPage> {
  ExplorerView _currentView = ExplorerView.root;
  String? _selectedLevel;
  String? _selectedPos;
  String _searchTerm = '';

  void navigateToWords(String? level, String? pos) {
    setState(() {
      _selectedLevel = level;
      _selectedPos = pos;
      _currentView = ExplorerView.wordList;
    });
  }
  
  // Ana Keşfet Ekranı (Root)
  Widget _buildRootView() {
    // Arama Çubuğu İşlevi: Kullanıcı yazı yazıp Enter/Gönder tuşuna bastığında tetiklenir
    void startSearch(String term) {
      if (term.isNotEmpty) {
        setState(() {
          _searchTerm = term;
          _currentView = ExplorerView.wordList; 
          _selectedLevel = null;
          _selectedPos = null;
        });
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // GENEL ARAMA ÇUBUĞU
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: TextField(
              textInputAction: TextInputAction.search, 
              onSubmitted: startSearch, 
              decoration: InputDecoration(
                hintText: 'Tüm kelimeler ve anlamları arasında ara...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
          ),
          
          // Seviye Bazlı Öğrenme Kartı
          _buildFeatureCard(
            title: 'Seviye Bazlı Öğrenme',
            subtitle: 'CEFR seviyenize uygun kelimeleri keşfedin',
            icon: Icons.bar_chart,
            colors: [Colors.indigo.shade500, Colors.purple.shade600],
            tags: CEFR_LEVELS.map((l) => Chip(
              label: Text(l, style: const TextStyle(color: Colors.white, fontSize: 12)),
              backgroundColor: LEVEL_COLORS[l],
            )).toList(),
            onTap: () => setState(() => _currentView = ExplorerView.levelSelection),
          ),
          const SizedBox(height: 20),

          // Kelime Türü Bazlı Kart
          _buildFeatureCard(
            title: 'Kelime Türü Bazlı',
            subtitle: 'Fiil, isim, sıfat ve zarfları gruplar halinde öğrenin',
            icon: Icons.adjust, 
            colors: [Colors.purple.shade500, Colors.pink.shade600],
            tags: POS_NAMES.entries.map((e) => Chip(
              label: Text(e.value, style: TextStyle(color: Colors.purple.shade800, fontSize: 12)),
              backgroundColor: Colors.purple.shade100,
            )).toList(),
            onTap: () => setState(() => _currentView = ExplorerView.posSelection),
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
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF424242)),
            ),
          ),
          ...CEFR_LEVELS.where((l) => l != 'C1' && l != 'C2').map((level) => CategoryCard(
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
    
    // POS için ikonlar
    final Map<String, IconData> posIcons = {
      'verb': Icons.auto_stories, 'noun': Icons.widgets, 'adjective': Icons.brush, 
      'adverb': Icons.flash_on, 'determiner': Icons.tag, 'preposition': Icons.link, 
      'pronoun': Icons.person, 'conjunction': Icons.join_full, 
      'modal auxiliary': Icons.layers, 'interjection': Icons.campaign,
    };
    // POS için renkler (CategoryCard renkli gradient kullanır)
    final Map<String, Color> posColors = {
      'verb': Colors.red.shade600, 'noun': Colors.orange.shade600, 'adjective': Colors.green.shade600,
      'adverb': Colors.teal.shade600, 'determiner': Colors.purple.shade600, 'preposition': Colors.blue.shade600,
      'pronoun': Colors.pink.shade600, 'conjunction': Colors.brown.shade600, 
      'modal auxiliary': Colors.deepOrange.shade600, 'interjection': Colors.indigo.shade600,
    };


    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Kelime Türü Seçin', 
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF424242)),
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

    // Filtreleme mantığı
    final filteredWords = allWords.where((w) {
      if (_selectedLevel != null && w.cefr != _selectedLevel) return false;
      if (_selectedPos != null && w.pos != _selectedPos) return false;
      
      // Arama terimi filtresi
      if (_searchTerm.isNotEmpty) {
        final term = _searchTerm.toLowerCase();
        if (!w.headword.toLowerCase().contains(term) && !w.turkish.toLowerCase().contains(term)) return false;
      }
      return true;
    }).toList();
    
    // Görünüm başlığını belirleme
    String viewTitle = _searchTerm.isNotEmpty 
      ? 'Arama Sonuçları'
      : _selectedLevel != null ? '$_selectedLevel Kelimeleri'
      : _selectedPos != null ? '${POS_NAMES[_selectedPos]!} Kelimeleri'
      : 'Tüm Kelimeler';


    return Column(
      children: [
        // Başlık ve Filtre Bilgisi
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '$viewTitle (${filteredWords.length} kelime)',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
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
                onSpeak: () => appState.speak(word.headword), // Kelime okutma
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
                    width: 50, height: 50,
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
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.grey)),
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

    Widget currentWidget;
    String title = 'Kelime Gezgini';

    switch (_currentView) {
      case ExplorerView.root:
        currentWidget = _buildRootView();
        break;
      case ExplorerView.levelSelection:
        currentWidget = _buildLevelSelectionView(appState);
        title = 'Seviye Seçin';
        break;
      case ExplorerView.posSelection:
        currentWidget = _buildPosSelectionView(appState);
        title = 'Kelime Türü Seçin';
        break;
      case ExplorerView.wordList:
        currentWidget = _buildWordListView(appState);
        // Başlık, Kelime Listesi metodu içinde belirleniyor.
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
                    if (_currentView == ExplorerView.wordList) {
                      // Eğer arama yapıldıysa root'a, filtreleme yapıldıysa seçime dön
                      _currentView = _selectedLevel != null || _selectedPos != null ? 
                                     (_selectedLevel != null ? ExplorerView.levelSelection : ExplorerView.posSelection) 
                                     : ExplorerView.root;
                    } else {
                      _currentView = ExplorerView.root;
                    }
                    _selectedLevel = null;
                    _selectedPos = null;
                    _searchTerm = ''; // Arama terimini temizle
                  });
                },
              )
            : null,
      ),
      body: currentWidget,
    );
  }
}