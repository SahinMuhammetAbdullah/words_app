// lib/widgets/word_card_tile.dart (TAMAMI)

import 'package:flutter/material.dart';
import 'package:words_app/core/models/word.dart';
import 'package:words_app/app_state.dart';

class WordCardTile extends StatelessWidget {
  final Word word;
  final VoidCallback onToggleFavorite;
  final VoidCallback onToggleLearned;
  final VoidCallback onSpeak; // Kelimeyi okutmak için

  const WordCardTile({
    super.key,
    required this.word,
    required this.onToggleFavorite,
    required this.onToggleLearned,
    required this.onSpeak,
  });

  Color _getLevelColor(String cefr) {
    // ... (Aynı kalır)
    switch (cefr) {
      case 'A1':
        return Colors.green;
      case 'A2':
        return Colors.lightGreen;
      case 'B1':
        return Colors.blue;
      case 'B2':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  String _getPosName(String pos) {
    return {
          'verb': 'Fiil',
          'noun': 'İsim',
          'adjective': 'Sıfat',
          'determiner': 'Belirteç'
        }[pos] ??
        pos;
  }

  @override
  Widget build(BuildContext context) {
    final appState =
        ListenableProvider.of<AppState>(context, listen: false); // TTS için
    final levelColor = _getLevelColor(word.cefr);
    final posName = _getPosName(word.pos);
    final isFavorite = word.isFavorite;
    final isLearned = word.isLearned;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
            color: isLearned ? Colors.green.shade700 : levelColor, width: 3),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kelime Başlığı ve Çeviri
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        word.headword,
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        word.turkish,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade700),
                      ),
                    ],
                  ),
                ),

                // Aksiyon Butonları
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. Kelimeyi Oku Butonu (onSpeak)
                    IconButton(
                      icon: const Icon(Icons.volume_up, color: Colors.blue),
                      onPressed: onSpeak, // Kelime okutulur
                    ),
                    // 2. Cümleyi Oku Butonu (YENİ EKLENDİ)
                    IconButton(
                      icon: const Icon(Icons.hearing, color: Colors.blue),
                      onPressed: () =>
                          appState.speak(word.sentence), // Cümle okutulur
                    ),
                    // 3. Favori Butonu
                    IconButton(
                      icon: Icon(isFavorite ? Icons.star : Icons.star_border,
                          color: isFavorite ? Colors.amber : Colors.grey),
                      onPressed: onToggleFavorite,
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 20),

            // Etiketler (Seviye ve POS)
            Row(
              children: [
                Chip(
                  label: Text(word.cefr,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  backgroundColor: levelColor,
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(posName,
                      style: const TextStyle(color: Colors.black87)),
                  backgroundColor: Colors.grey.shade200,
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Cümleler
            Text(
              '🗣️ İngilizce: ${word.sentence}',
              style: const TextStyle(
                  fontStyle: FontStyle.italic, color: Colors.black54),
            ),
            const SizedBox(height: 5),
            Text(
              'Çeviri: ${word.sentenceTr}',
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 10),

            // Öğrenildi İşaretleme
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onToggleLearned,
                icon: Icon(isLearned ? Icons.cancel : Icons.check_circle,
                    color: isLearned ? Colors.red : Colors.green),
                label: Text(isLearned
                    ? 'Öğrenildi İşaretini Kaldır'
                    : 'Öğrenildi Olarak İşaretle'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
