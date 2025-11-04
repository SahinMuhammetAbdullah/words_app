// lib/models/word.dart

class Word {
  final int? id;
  final String headword;
  final String pos;
  final String cefr;
  final String sentence;
  final String sentenceTr;
  final String turkish;

  // SRS (Spaced Repetition System) verileri
  final int repetitionCount;
  final String nextReview; // ISO 8601 string: YYYY-MM-DD
  final bool isLearned;
  final bool isFavorite;

  Word({
    this.id,
    required this.headword,
    required this.pos,
    required this.cefr,
    required this.sentence,
    required this.sentenceTr,
    required this.turkish,
    this.repetitionCount = 0,
    this.nextReview = '2000-01-01', // Geçmiş bir tarih, hemen tekrar için
    this.isLearned = false,
    this.isFavorite = false,
  });

  // =======================================================
  // Veri Kaynağına Özel Metotlar
  // =======================================================

  // Veritabanından objeye çevirme (SRS ve DB ID'yi okur)
  factory Word.fromMap(Map<String, dynamic> map) {
    return Word(
      id: map['id'],
      headword: map['headword'],
      pos: map['pos'],
      cefr: map['cefr'],
      sentence: map['sentence'],
      sentenceTr: map['sentence_tr'],
      turkish: map['turkish'],
      repetitionCount: map['repetition_count'],
      nextReview: map['next_review'],
      isLearned: map['is_learned'] == 1,
      isFavorite: map['is_favorite'] == 1,
    );
  }

  // JSON'dan yeni kelime oluşturma (Sadece temel kelime verilerini okur)
  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      headword: json['headword']?.toString() ?? '',
        pos: json['pos']?.toString() ?? '',
        cefr: json['CEFR']?.toString() ?? '',
        sentence: json['sentence']?.toString() ?? '',
        sentenceTr: json['sentence_tr']?.toString() ?? '',
        turkish: json['turkish']?.toString() ?? '',
      // SRS alanları burada varsayılan (initial) değerleri alır:
      repetitionCount: 0,
      nextReview: '2000-01-01', 
      isLearned: false,
      isFavorite: false,
    );
  }

  // Objeyi veritabanına çevirme
  Map<String, dynamic> toMap() {
    return {
      'headword': headword,
      'pos': pos,
      'cefr': cefr,
      'sentence': sentence,
      'sentence_tr': sentenceTr,
      'turkish': turkish,
      'repetition_count': repetitionCount,
      'next_review': nextReview,
      'is_learned': isLearned ? 1 : 0,
      'is_favorite': isFavorite ? 1 : 0,
    };
  }

  // Bir kelime verisini güncellenmiş değerlerle kopyalama
  Word copyWith({
    int? id,
    String? headword,
    String? pos,
    String? cefr,
    String? sentence,
    String? sentenceTr,
    String? turkish,
    int? repetitionCount,
    String? nextReview,
    bool? isLearned,
    bool? isFavorite,
  }) {
    return Word(
      id: id ?? this.id,
      headword: headword ?? this.headword,
      pos: pos ?? this.pos,
      cefr: cefr ?? this.cefr,
      sentence: sentence ?? this.sentence,
      sentenceTr: sentenceTr ?? this.sentenceTr,
      turkish: turkish ?? this.turkish,
      repetitionCount: repetitionCount ?? this.repetitionCount,
      nextReview: nextReview ?? this.nextReview,
      isLearned: isLearned ?? this.isLearned,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}