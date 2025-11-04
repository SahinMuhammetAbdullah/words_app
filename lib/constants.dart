// lib/constants.dart

import 'package:flutter/material.dart';

// CEFR Seviyeleri Listesi
const List<String> CEFR_LEVELS = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2']; 

// Seviyelere Özel Renkler (Explorer/Stats için)
const Map<String, Color> LEVEL_COLORS = {
  'A1': Colors.green,
  'A2': Colors.lightGreen,
  'B1': Colors.blue,
  'B2': Colors.indigo,
  'C1': Colors.purple,
  'C2': Colors.pink,
};

// Kelime Türleri ve Türkçe Karşılıkları
const Map<String, String> POS_NAMES = {
  'verb': 'Fiil', 
  'noun': 'İsim', 
  'adjective': 'Sıfat', 
  'adverb': 'Zarf', 
  'determiner': 'Belirteç',
  'preposition': 'Edat',
  'pronoun': 'Zamir',
  'conjunction': 'Bağlaç',
  'modal auxiliary': 'Modal Yardımcı Fiil',
  'interjection': 'Ünlem',
};