// lib/widgets/explorer_root_view.dart

import 'package:flutter/material.dart';
import 'package:words_app/core/constants/constants.dart';
import 'package:words_app/features/explorer/explorer_page.dart';

class ExplorerRootView extends StatelessWidget {
  final Function(ExplorerView view) onViewChange;
  final Map<String, dynamic> stats;

  const ExplorerRootView({
    super.key,
    required this.onViewChange,
    required this.stats,
  });

  // Feature Kartı Oluşturucu (Aynı kaldı)
  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> colors,
    required List<Widget> tags,
    required VoidCallback onTap,
  }) {
    // ... (Önceki _buildFeatureCard kodu)
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
            tags: CEFR_LEVELS.map((l) => Chip(
              label: Text(l, style: const TextStyle(color: Colors.white, fontSize: 12)),
              backgroundColor: LEVEL_COLORS[l],
            )).toList(),
            onTap: () async {
                await Future.delayed(Duration.zero);
                onViewChange(ExplorerView.levelSelection);
            },
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
            onTap: () async {
                await Future.delayed(Duration.zero);
                onViewChange(ExplorerView.posSelection);
            },
          ),
        ],
      ),
    );
  }
}