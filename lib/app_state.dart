// lib/app_state.dart

import 'package:flutter/material.dart';
import 'package:words_app/database/db_helper.dart';
import 'package:words_app/models/word.dart';
import 'package:words_app/services/tts_service.dart';
import 'package:intl/intl.dart'; // <<< EKLENDİ (DateFormat hatası için)

// ======================================================
// Kullanıcı İlerleme Modeli (UserProgress)
// ======================================================

class UserProgress {
  final int totalPoints;
  final int level;
  final int streak;
  final int dailyGoal;
  final int studiedToday;

  const UserProgress({
    this.totalPoints = 0,
    this.level = 1,
    this.streak = 3,
    this.dailyGoal = 10,
    this.studiedToday = 0,
  });

  UserProgress copyWith({
    int? totalPoints,
    int? level,
    int? streak,
    int? dailyGoal,
    int? studiedToday,
  }) {
    return UserProgress(
      totalPoints: totalPoints ?? this.totalPoints,
      level: level ?? this.level,
      streak: streak ?? this.streak,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      studiedToday: studiedToday ?? this.studiedToday,
    );
  }
}

// ======================================================
// Global Durum Yönetimi (AppState)
// ======================================================

class AppState extends ChangeNotifier {
  List<Word> _allWords = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TTSService ttsService = TTSService();

  // Kullanıcı İlerlemesi State'i
  UserProgress _userProgress = const UserProgress();

  List<Word> get allWords => _allWords;
  UserProgress get userProgress => _userProgress; // Getter hatası çözüldü.

  AppState() {
    loadWords();
  }

  Future<void> loadWords() async {
    _allWords = await _dbHelper.getWords();
    notifyListeners();
  }

  Future<void> updateWordProgress(Word updatedWord) async {
    await _dbHelper.updateWord(updatedWord);
    await loadWords();
  }

  // TTS yardımcı fonksiyonu
  void speak(String text) {
    ttsService.speak(text);
  }

  // Puan ve ilerleme güncelleyen metot (Quiz gibi yerlerde kullanılacak)
  void updatePoints(int points) {
    _userProgress = _userProgress.copyWith(
      totalPoints: _userProgress.totalPoints + points,
      // Seviye her 100 puanda bir artar
      level: (_userProgress.totalPoints + points) ~/ 100 + 1,
      studiedToday: _userProgress.studiedToday + 1,
    );
    notifyListeners();
  }

  void setDailyGoal(int newGoal) {
    if (newGoal > 0) {
      _userProgress = _userProgress.copyWith(dailyGoal: newGoal);
      notifyListeners();
    }
  }

  // Basit SRS Algoritması
  Word calculateNextReview(Word word, bool known) {
    // 0 = Bilmiyorum (Zor); 5 = Biliyorum (Kolay)
    final int quality = known ? 5 : 0;

    int newRepetitions = word.repetitionCount;
    int newInterval = word.interval;
    double newEasinessFactor = word.easinessFactor;

    final int maxIntervalDays = 120; // Tekrar aralığı limiti

    // --- SM-2 Algoritması Uygulaması ---

    if (quality >= 3) {
      // Başarılı Hatırlama (Biliyorum, 3-5 puan arası)
      newRepetitions++;

      // EF Güncelleme
      newEasinessFactor = newEasinessFactor +
          (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
      if (newEasinessFactor < 1.3) newEasinessFactor = 1.3; // Min EF sınırı

      // Interval Hesaplama
      if (newRepetitions == 1) {
        newInterval = 1;
      } else if (newRepetitions == 2) {
        newInterval = 6;
      } else {
        newInterval = (newInterval * newEasinessFactor).round();
      }
    } else {
      // Başarısız Hatırlama (Bilmiyorum, 0-2 puan arası)
      newRepetitions = 0;
      newInterval = 1; // Başlangıç intervali

      // EF Güncelleme (Başarısız hatırlama sonrası EF düşer)
      newEasinessFactor = newEasinessFactor - 0.2;
      if (newEasinessFactor < 1.3) newEasinessFactor = 1.3;
    }

    // Max interval sınırı uygulama
    newInterval = newInterval.clamp(1, maxIntervalDays);

    // Sonraki Tekrar Tarihini Hesaplama
    final DateTime now = DateTime.now();
    final DateTime nextReviewDate = now.add(Duration(days: newInterval));
    final String nextReview = DateFormat('yyyy-MM-dd').format(nextReviewDate);

    final bool isLearned = newRepetitions >= 5 &&
        quality >= 4; // 5 Başarılı tekrar ve yüksek kalite

    return word.copyWith(
      repetitionCount: newRepetitions,
      nextReview: nextReview,
      isLearned: isLearned,
      easinessFactor: newEasinessFactor,
      interval: newInterval,
    );
  }

  Future<void> toggleFavorite(Word word) async {
    final updatedWord = word.copyWith(isFavorite: !word.isFavorite);
    await updateWordProgress(updatedWord);
  }

  Future<void> toggleLearned(Word word) async {
    final updatedWord = word.copyWith(
      isLearned: !word.isLearned,
      repetitionCount: !word.isLearned ? 3 : 0,
      nextReview: !word.isLearned
          ? DateTime.now()
              .add(const Duration(days: 999))
              .toString()
              .split(' ')[0]
          : DateTime.now().toString().split(' ')[0],
    );
    await updateWordProgress(updatedWord);
  }
}

// ======================================================
// ListenableProvider (Durum Yönetimi Helper'ı)
// ======================================================

class ListenableProvider<T extends ChangeNotifier> extends StatefulWidget {
  final T Function(BuildContext context) create;
  final Widget child;

  const ListenableProvider(
      {super.key, required this.create, required this.child});

  @override
  State<ListenableProvider<T>> createState() => _ListenableProviderState<T>();

  static T of<T extends ChangeNotifier>(BuildContext context,
      {bool listen = true}) {
    final inherited = listen
        ? context.dependOnInheritedWidgetOfExactType<_InheritedProvider<T>>()
        : context.findAncestorWidgetOfExactType<_InheritedProvider<T>>();

    if (inherited == null) {
      throw FlutterError('Provider not found');
    }
    return inherited.notifier!;
  }
}

class _ListenableProviderState<T extends ChangeNotifier>
    extends State<ListenableProvider<T>> {
  late T notifier;

  @override
  void initState() {
    super.initState();
    notifier = widget.create(context);
    notifier.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    notifier.removeListener(_rebuild);
    notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedProvider<T>(
      notifier: notifier,
      child: widget.child,
    );
  }
}

class _InheritedProvider<T extends ChangeNotifier>
    extends InheritedNotifier<T> {
  const _InheritedProvider({
    required T notifier,
    required Widget child,
  }) : super(notifier: notifier, child: child);

  @override
  bool updateShouldNotify(covariant InheritedNotifier<T> oldWidget) => true;
}
