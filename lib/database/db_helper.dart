// lib/database/db_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:words_app/models/word.dart';
import 'package:flutter/services.dart' show rootBundle; // Assets okumak için
import 'dart:convert'; // JSON çözmek için

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final databasePath = await getDatabasesPath();
    // Veritabanı yolunu birleştirir
    final path = join(databasePath, 'vocabulary_db.db');

    // Veritabanını açar veya oluşturur
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE words(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        headword TEXT, 
        pos TEXT,
        cefr TEXT,
        sentence TEXT,
        sentence_tr TEXT,
        turkish TEXT,
        repetition_count INTEGER,
        next_review TEXT,
        is_learned INTEGER,
        is_favorite INTEGER,
        -- YENİ SM-2 ALANLARI
        easiness_factor REAL NOT NULL DEFAULT 2.5,
        interval INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Veritabanını JSON verileriyle doldur
    await _seedDatabase(db);
  }

  // JSON'dan verileri okuyup DB'ye ekleyen metot
  Future<void> _seedDatabase(Database db) async {
    try {
      print('JSON verisi yükleniyor...');

      // JSON okuma ve çözümleme
      final String response =
          await rootBundle.loadString('assets/data/word_list.json');
      final List<dynamic> data = json.decode(response);

      if (data.isEmpty) {
        print('JSON dosyası boş.');
        return;
      }

      var batch = db.batch(); // Tek seferlik Batch başlat
      int counter = 0;
      int errorCount = 0;

      print(
          'Toplam ${data.length} kelime bulundu. Ekleme işlemi başlıyor (TEK BATCH)...');

      for (var item in data) {
        try {
          final Word word =
              Word.fromJson(item as Map<String, dynamic>).copyWith(id: null);

          // Batch'e ekleme komutunu yolla (Commit yok)
          batch.insert('words', word.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace);

          counter++;
        } catch (e) {
          errorCount++;
          print('--- HATA ALINDI ---');
          print(
              'Sıra: ${counter + 1} | Kelime: ${item['headword'] ?? 'Bilinmeyen'}');
          print('Hata: $e');
          // Hata olsa bile döngü devam eder.
          print('--- HATA SONU ---');
        }
      }

      // TEK BİR TOPLU İŞLEM YAP: Kalan tüm işlemleri commit et
      await batch.commit(noResult: true);

      print(
          'Veritabanı DOLDURMA BAŞARILI. Toplam ${data.length} kelimeden, $counter kelime ekleme komutuna eklendi. ($errorCount hata)');

      // *** KRİTİK KONTROL: Veritabanında gerçekten kaç kelime var? ***
      final count = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM words'));
      print(
          'DB Kontrolü: Veritabanında şu an $count kelime var. Beklenen: 7799.');
    } catch (e) {
      print('KRİTİK HATA: JSON Okuma/Çözümleme Başarısız: $e');
    }
  }

  // Tüm kelimeleri getir
  Future<List<Word>> getWords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('words');
    return List.generate(maps.length, (i) {
      return Word.fromMap(maps[i]);
    });
  }

  // Kelimeyi güncelle
  Future<void> updateWord(Word word) async {
    final db = await database;
    // ID'ye göre güncelleme yap
    await db.update(
      'words',
      word.toMap(),
      where: 'id = ?',
      whereArgs: [word.id],
    );
  }
}
