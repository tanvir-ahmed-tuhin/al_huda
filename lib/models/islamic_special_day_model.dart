class IslamicAmalModel {
  final String id;
  final String title;
  final String category; // সালাত, কুরআন, জিকির ও দোয়া, রোজা, সদকা, সাধারণ
  final String description;
  final String benefit;
  final String? recommendedCount;
  final String? arabicDua;
  final String? banglaPronunciation;
  final String? banglaMeaning;
  final String? reference;
  final int? surahNumber; // Optional linked Surah
  final String? tasbihText; // Optional linked Tasbih text

  const IslamicAmalModel({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.benefit,
    this.recommendedCount,
    this.arabicDua,
    this.banglaPronunciation,
    this.banglaMeaning,
    this.reference,
    this.surahNumber,
    this.tasbihText,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'description': description,
      'benefit': benefit,
      'recommendedCount': recommendedCount,
      'arabicDua': arabicDua,
      'banglaPronunciation': banglaPronunciation,
      'banglaMeaning': banglaMeaning,
      'reference': reference,
      'surahNumber': surahNumber,
      'tasbihText': tasbihText,
    };
  }
}

class IslamicSpecialDayModel {
  final String id;
  final String title;
  final String arabicTitle;
  final String hijriDateString;
  final int hijriMonth; // 1 to 12, 0 for weekly
  final int hijriDay;   // 1 to 30, 0 for weekly
  final bool isWeekly;  // true for Friday
  final String category; // 'প্রধান উৎসব', 'বরকতময় রজনী', 'নফল সিয়াম ও ইবাদত', 'সাপ্তাহিক শ্রেষ্ঠ দিন'
  final String tagline;
  final String description;
  final String? quranReference;
  final String? hadithReference;
  final List<IslamicAmalModel> amals;
  final List<String> prohibitions; // বর্জনীয় ও কুসংস্কার
  final int advanceNotificationDays;

  const IslamicSpecialDayModel({
    required this.id,
    required this.title,
    required this.arabicTitle,
    required this.hijriDateString,
    required this.hijriMonth,
    required this.hijriDay,
    this.isWeekly = false,
    required this.category,
    required this.tagline,
    required this.description,
    this.quranReference,
    this.hadithReference,
    required this.amals,
    this.prohibitions = const [],
    this.advanceNotificationDays = 3,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'arabicTitle': arabicTitle,
      'hijriDateString': hijriDateString,
      'hijriMonth': hijriMonth,
      'hijriDay': hijriDay,
      'isWeekly': isWeekly,
      'category': category,
      'tagline': tagline,
      'description': description,
      'quranReference': quranReference,
      'hadithReference': hadithReference,
      'amals': amals.map((a) => a.toMap()).toList(),
      'prohibitions': prohibitions,
      'advanceNotificationDays': advanceNotificationDays,
    };
  }
}
