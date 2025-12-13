// lib/widgets/explorer_level_selection.dart

import 'package:flutter/material.dart';
import 'package:words_app/app_state.dart';
import 'package:words_app/core/constants/constants.dart';
import 'package:words_app/core/widgets/category_card.dart'; // CategoryCard'ı kullanır

class ExplorerLevelSelection extends StatelessWidget {
  final AppState appState;
  final Map<String, dynamic> stats;
  final Function(String level) onLevelSelected;

  const ExplorerLevelSelection({
    super.key,
    required this.appState,
    required this.stats,
    required this.onLevelSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final levelCounts = stats['levelCount'] as Map<String, int>? ?? {};

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 2. Padding'de const anahtar kelimesi kaldırıldı
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Seviye Seçin',
              // 3. TextStyle const içermez
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface),
            ),
          ),
          ...CEFR_LEVELS
              .where((l) => l != 'C1' && l != 'C2')
              .map((level) => CategoryCard(
                    title: '$level Seviyesi',
                    subtitle: '${levelCounts[level] ?? 0} kelime',
                    icon: Icons.school,
                    color: LEVEL_COLORS[level]!,
                    onTap: () => onLevelSelected(level),
                  )),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
