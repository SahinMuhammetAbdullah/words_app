// lib/widgets/search_overlay.dart

import 'package:flutter/material.dart';
import 'package:words_app/app_state.dart';
import 'package:words_app/core/models/word.dart';
import 'package:words_app/features/explorer/widgets/word_card_tile.dart';
import 'package:words_app/core/constants/constants.dart'; // <<< YOL DÜZELTİLDİ

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
    // 1. Arama Terimi ve Filtre Kontrolü
    if (_searchTerm.isEmpty && _filterLevel == null && _filterPos == null) {
        return [];
    }

    final allWords = widget.appState.allWords;
    final lowerTerm = _searchTerm.toLowerCase().trim();
    
    // 2. TÜM FİLTRELERİ UYGULAYARAK İLK LİSTEYİ OLUŞTUR
    final List<Word> filteredResults = allWords.where((w) {
        // Arama Terimi Kontrolü (içerir/başlar)
        final searchMatches = lowerTerm.isEmpty || 
                              w.headword.toLowerCase().contains(lowerTerm) || 
                              w.turkish.toLowerCase().contains(lowerTerm);

        if (!searchMatches) return false;
        
        // Seviye Filtresi
        if (_filterLevel != null && w.cefr != _filterLevel) return false;

        // POS Filtresi
        if (_filterPos != null && w.pos != _filterPos) return false;

        return true;
    }).toList();
    
    // 3. SIRALAMA VE ÖNCELİKLENDİRME AŞAMASI
    if (lowerTerm.isNotEmpty) {
        // Tam eşleşen kelimeyi/kelimeleri bul
        final exactMatches = filteredResults.where((w) => 
            w.headword.toLowerCase() == lowerTerm
        ).toList();
        
        // Geri kalan (kısmi) eşleşmeleri bul. 
        // Burada, tam eşleşenleri hariç tutmak için set kullanıyoruz.
        final Set<Word> exactSet = exactMatches.toSet();
        
        final partialMatches = filteredResults.where((w) => 
            !exactSet.contains(w)
        ).toList();

        // Tam eşleşmeleri en başta, kısmi eşleşmeleri arkada listeleyerek sonucu döndür.
        return [...exactMatches, ...partialMatches];
    }

    // Arama terimi yoksa (sadece filtre varsa) normal sonucu döndür
    return filteredResults;
}

  // Ayarlar Paneli (ModalBottomSheet olarak açılır)
  void _openFilterSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final colorScheme =
            Theme.of(context).colorScheme; // Renk şeması modal içinde
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(20),
              // DÜZELTME 3: Modal Arka Plan Rengi Tema Uyumlu
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // DÜZELTME 4: Başlık Metin Rengi Tema Uyumlu
                  Text('Filtre Ayarları',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface)),
                  const Divider(),

                  // Seviye Filtresi Başlığı
                  Text('CEFR Seviyesi',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: [
                      // Tümünü Temizle Butonu
                      ChoiceChip(
                        // DÜZELTME 5: Chip stilini tema uyumlu yap
                        selectedColor: colorScheme.primary,
                        labelStyle: TextStyle(
                            color: _filterLevel == null
                                ? colorScheme.onPrimary
                                : colorScheme.onSurface),
                        label: const Text('Hepsi'),
                        selected: _filterLevel == null,
                        onSelected: (selected) {
                          modalSetState(() =>
                              _filterLevel = selected ? null : _filterLevel);
                          setState(() {});
                        },
                      ),
                      ...CEFR_LEVELS
                          .map((level) => ChoiceChip(
                                selectedColor: colorScheme.primary,
                                labelStyle: TextStyle(
                                    color: _filterLevel == level
                                        ? colorScheme.onPrimary
                                        : colorScheme.onSurface),
                                label: Text(level),
                                selected: _filterLevel == level,
                                onSelected: (selected) {
                                  modalSetState(() =>
                                      _filterLevel = selected ? level : null);
                                  setState(() {});
                                },
                              ))
                          .toList(),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Tür Filtresi Başlığı
                  Text('Kelime Türü',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface)),
                  const SizedBox(height: 10),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 3,
                      childAspectRatio: 2.5,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      children: [
                        // Tümünü Temizle Butonu
                        ChoiceChip(
                          selectedColor: colorScheme.primary,
                          labelStyle: TextStyle(
                              color: _filterPos == null
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurface),
                          label: const Text('Hepsi'),
                          selected: _filterPos == null,
                          onSelected: (selected) {
                            modalSetState(() =>
                                _filterPos = selected ? null : _filterPos);
                            setState(() {});
                          },
                        ),
                        ...POS_NAMES.entries
                            .map((entry) => ChoiceChip(
                                  selectedColor: colorScheme.primary,
                                  labelStyle: TextStyle(
                                      color: _filterPos == entry.key
                                          ? colorScheme.onPrimary
                                          : colorScheme.onSurface),
                                  label: Text(entry.value),
                                  selected: _filterPos == entry.key,
                                  onSelected: (selected) {
                                    modalSetState(() => _filterPos =
                                        selected ? entry.key : null);
                                    setState(() {});
                                  },
                                ))
                            .toList(),
                      ],
                    ),
                  ),

                  // Alt Kısım
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        // DÜZELTME 6: Kapat metni rengi tema uyumlu
                        child: Text('Kapat',
                            style: TextStyle(
                                fontSize: 18, color: colorScheme.primary)),
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
    final colorScheme = Theme.of(context).colorScheme; // Tema renklerini al

    return Scaffold(
      // DÜZELTME 7: Scaffold arka planı temadan alınır
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        // AppBar rengi temadan gelir (darkColorScheme.surface)
        title: TextField(
          controller: _searchController,
          autofocus: true,
          onChanged: (value) => setState(() => _searchTerm = value),
          // DÜZELTME 8: TextField Metin rengi tema uyumlu yapıldı
          style: TextStyle(color: colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: 'Arama yapın...',
            border: InputBorder.none,
            // DÜZELTME 9: Hint metni rengi tema uyumlu yapıldı
            hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings,
                color: colorScheme.onSurface), // DÜZELTME 10
            onPressed: _openFilterSettings,
          ),
          IconButton(
            icon:
                Icon(Icons.close, color: colorScheme.onSurface), // DÜZELTME 11
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _searchTerm.isNotEmpty ||
                      _filterLevel != null ||
                      _filterPos != null
                  ? 'Toplam ${filteredWords.length} sonuç bulundu'
                  : 'Aramaya başlamak için yazın veya filtre uygulayın.',
              // DÜZELTME 12: Metin rengi tema uyumlu yapıldı
              style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.7), fontSize: 16),
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
