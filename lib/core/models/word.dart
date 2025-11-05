class Word {
  final int? id;
  final String headword;
  final String pos;
  final String cefr;
  final String sentence;
  final String sentenceTr;
  final String turkish;

  // SRS (Spaced Repetition System) verileri - MEVCUT ALANLAR
  final int repetitionCount;
  final String nextReview; // ISO 8601 string: YYYY-MM-DD
  final bool isLearned;
  final bool isFavorite;

  // YENİ SM-2 ALANLARI
  final double easinessFactor; // Kolaylık Faktörü (EF). Varsayılan: 2.5
  final int interval; // Tekrar aralığı (Gün)

  Word({
    this.id,
    required this.headword,
    required this.pos,
    required this.cefr,
    required this.sentence,
    required this.sentenceTr,
    required this.turkish,
    // SRS Default/Mevcut
    this.repetitionCount = 0,
    this.nextReview = '2000-01-01',
    this.isLearned = false,
    this.isFavorite = false,
    // SM-2 Default/Yeni
    this.easinessFactor = 2.5,
    this.interval = 0,
  });

  // ... (Word.fromMap metodu)
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
      // YENİ ALANLAR OKUNUYOR
      easinessFactor: map['easiness_factor'] is double
          ? map['easiness_factor']
          : (map['easiness_factor'] as int).toDouble(),
      interval: map['interval'],
    );
  }

  // ... (Word.fromJson metodu - Sadece SRS default alanları güncellendi)
  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      headword: json['headword']?.toString() ?? '',
      pos: json['pos']?.toString() ?? '',
      cefr: json['CEFR']?.toString() ?? '',
      sentence: json['sentence']?.toString() ?? '',
      sentenceTr: json['sentence_tr']?.toString() ?? '',
      turkish: json['turkish']?.toString() ?? '',
      // SRS Default/Mevcut
      repetitionCount: 0,
      nextReview: '2000-01-01',
      isLearned: false,
      isFavorite: false,
      // SM-2 Default/Yeni
      easinessFactor: 2.5,
      interval: 0,
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
      // YENİ ALANLAR DB'ye yazılıyor
      'easiness_factor': easinessFactor,
      'interval': interval,
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
    double? easinessFactor,
    int? interval,
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
      easinessFactor: easinessFactor ?? this.easinessFactor,
      interval: interval ?? this.interval,
    );
  }
}
