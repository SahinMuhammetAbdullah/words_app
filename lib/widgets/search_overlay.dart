// lib/widgets/search_overlay.dart

import 'package:flutter/material.dart';
import 'package:words_app/app_state.dart';
import 'package:words_app/models/word.dart';
import 'package:words_app/widgets/word_card_tile.dart';
import 'package:words_app/constants.dart';

class SearchOverlay extends StatefulWidget {
  final AppState appState;

  const SearchOverlay({super.key, required this.appState});

  @override
  State<SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends State<SearchOverlay> {
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';
  
  // Filtre State'leri
  String? _filterLevel;
  String? _filterPos;

  // Arama sonuçlarını hesaplar
  List<Word> _getFilteredWords() {
    if (_searchTerm.isEmpty && _filterLevel == null && _filterPos == null) {
      return [];
    }

    return widget.appState.allWords.where((w) {
      final term = _searchTerm.toLowerCase();
      
      // 1. Arama Filtresi
      final searchMatches = _searchTerm.isEmpty || w.headword.toLowerCase().contains(term) || w.turkish.toLowerCase().contains(term);
      if (!searchMatches) return false;
      
      // 2. Seviye Filtresi
      if (_filterLevel != null && w.cefr != _filterLevel) return false;

      // 3. POS Filtresi
      if (_filterPos != null && w.pos != _filterPos) return false;

      return true;
    }).toList();
  }

  // Ayarlar Paneli (ModalBottomSheet olarak açılır)
  void _openFilterSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Filtre Ayarları', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const Divider(),
                  
                  // Seviye Filtresi
                  const Text('CEFR Seviyesi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: [
                      // Tümünü Temizle Butonu
                      ChoiceChip(
                        label: const Text('Hepsi'),
                        selected: _filterLevel == null,
                        onSelected: (selected) {
                          modalSetState(() => _filterLevel = selected ? null : _filterLevel);
                          setState(() {}); // Ana ekranı güncelle
                        },
                      ),
                      ...CEFR_LEVELS.map((level) => ChoiceChip(
                        label: Text(level),
                        selected: _filterLevel == level,
                        onSelected: (selected) {
                          modalSetState(() => _filterLevel = selected ? level : null);
                          setState(() {}); // Ana ekranı güncelle
                        },
                      )).toList(),
                    ],
                  ),

                  const SizedBox(height: 20),
                  
                  // Tür Filtresi
                  const Text('Kelime Türü', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 3,
                      childAspectRatio: 2.5,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('Hepsi'),
                          selected: _filterPos == null,
                          onSelected: (selected) {
                            modalSetState(() => _filterPos = selected ? null : _filterPos);
                            setState(() {}); // Ana ekranı güncelle
                          },
                        ),
                        ...POS_NAMES.entries.map((entry) => ChoiceChip(
                          label: Text(entry.value),
                          selected: _filterPos == entry.key,
                          onSelected: (selected) {
                            modalSetState(() => _filterPos = selected ? entry.key : null);
                            setState(() {}); // Ana ekranı güncelle
                          },
                        )).toList(),
                      ],
                    ),
                  ),

                  // Alt Kısım
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Kapat', style: TextStyle(fontSize: 18)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredWords = _getFilteredWords();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false, // Varsayılan geri butonunu gizle
        title: TextField(
          controller: _searchController,
          autofocus: true, // Otomatik odaklanma
          onChanged: (value) => setState(() => _searchTerm = value), // Canlı arama
          decoration: const InputDecoration(
            hintText: 'Arama yapın...',
            border: InputBorder.none,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openFilterSettings, // Ayar paneline aç
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context), // Sayfayı kapat
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _searchTerm.isNotEmpty || _filterLevel != null || _filterPos != null
                  ? 'Toplam ${filteredWords.length} sonuç bulundu'
                  : 'Aramaya başlamak için yazın veya filtre uygulayın.',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredWords.length,
              itemBuilder: (context, index) {
                final word = filteredWords[index];
                return WordCardTile(
                  word: word,
                  onToggleFavorite: () => widget.appState.toggleFavorite(word),
                  onToggleLearned: () => widget.appState.toggleLearned(word),
                  onSpeak: () => widget.appState.speak(word.headword),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}