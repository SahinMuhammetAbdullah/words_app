// lib/widgets/explorer_pos_selection.dart

import 'package:flutter/material.dart';
import 'package:words_app/app_state.dart';
import 'package:words_app/core/constants/constants.dart';
import 'package:words_app/core/widgets/category_card.dart';

class ExplorerPosSelection extends StatelessWidget {
  final AppState appState;
  final Map<String, dynamic> stats;
  final Function(String pos) onPosSelected;

  const ExplorerPosSelection({
    super.key,
    required this.appState,
    required this.stats,
    required this.onPosSelected,
  });

  @override
  Widget build(BuildContext context) {
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
              onTap: () => onPosSelected(posKey),
            );
          }).toList(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}