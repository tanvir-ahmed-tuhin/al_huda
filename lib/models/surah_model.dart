class SurahSummary {
  final int number;
  final String nameArabic;
  final String nameEnglish;
  final String nameBangla;
  final String meaningBangla;
  final String englishTranslation;
  final int numberOfAyahs;
  final String revelationType; // 'Meccan' or 'Medinan'
  final String revelationTypeBangla;

  const SurahSummary({
    required this.number,
    required this.nameArabic,
    required this.nameEnglish,
    required this.nameBangla,
    required this.meaningBangla,
    required this.englishTranslation,
    required this.numberOfAyahs,
    required this.revelationType,
    required this.revelationTypeBangla,
  });

  factory SurahSummary.fromJson(Map<String, dynamic> json) {
    return SurahSummary(
      number: json['number'] as int,
      nameArabic: json['nameArabic'] as String,
      nameEnglish: json['nameEnglish'] as String,
      nameBangla: json['nameBangla'] as String,
      meaningBangla: json['meaningBangla'] as String,
      englishTranslation: json['englishTranslation'] as String,
      numberOfAyahs: json['numberOfAyahs'] as int,
      revelationType: json['revelationType'] as String,
      revelationTypeBangla: json['revelationTypeBangla'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'nameArabic': nameArabic,
      'nameEnglish': nameEnglish,
      'nameBangla': nameBangla,
      'meaningBangla': meaningBangla,
      'englishTranslation': englishTranslation,
      'numberOfAyahs': numberOfAyahs,
      'revelationType': revelationType,
      'revelationTypeBangla': revelationTypeBangla,
    };
  }
}

class Ayah {
  final int numberInSurah;
  final int numberInQuran;
  final int surahNumber;
  final String textArabic;
  final String translationBangla;
  final String translationEnglish;
  final String? audioUrl;
  final bool sajda;

  const Ayah({
    required this.numberInSurah,
    required this.numberInQuran,
    required this.surahNumber,
    required this.textArabic,
    required this.translationBangla,
    required this.translationEnglish,
    this.audioUrl,
    this.sajda = false,
  });

  factory Ayah.fromJson(Map<String, dynamic> json) {
    return Ayah(
      numberInSurah: json['numberInSurah'] as int,
      numberInQuran: json['numberInQuran'] as int,
      surahNumber: json['surahNumber'] as int,
      textArabic: json['textArabic'] as String,
      translationBangla: json['translationBangla'] as String,
      translationEnglish: json['translationEnglish'] as String,
      audioUrl: json['audioUrl'] as String?,
      sajda: json['sajda'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numberInSurah': numberInSurah,
      'numberInQuran': numberInQuran,
      'surahNumber': surahNumber,
      'textArabic': textArabic,
      'translationBangla': translationBangla,
      'translationEnglish': translationEnglish,
      'audioUrl': audioUrl,
      'sajda': sajda,
    };
  }
}

class BookmarkItem {
  final int surahNumber;
  final String surahNameBangla;
  final String surahNameArabic;
  final int ayahNumber;
  final String ayahTextArabic;
  final String ayahTextBangla;
  final DateTime savedAt;

  const BookmarkItem({
    required this.surahNumber,
    required this.surahNameBangla,
    required this.surahNameArabic,
    required this.ayahNumber,
    required this.ayahTextArabic,
    required this.ayahTextBangla,
    required this.savedAt,
  });

  factory BookmarkItem.fromJson(Map<String, dynamic> json) {
    return BookmarkItem(
      surahNumber: json['surahNumber'] as int,
      surahNameBangla: json['surahNameBangla'] as String,
      surahNameArabic: json['surahNameArabic'] as String,
      ayahNumber: json['ayahNumber'] as int,
      ayahTextArabic: json['ayahTextArabic'] as String,
      ayahTextBangla: json['ayahTextBangla'] as String,
      savedAt: DateTime.parse(json['savedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'surahNumber': surahNumber,
      'surahNameBangla': surahNameBangla,
      'surahNameArabic': surahNameArabic,
      'ayahNumber': ayahNumber,
      'ayahTextArabic': ayahTextArabic,
      'ayahTextBangla': ayahTextBangla,
      'savedAt': savedAt.toIso8601String(),
    };
  }
}
