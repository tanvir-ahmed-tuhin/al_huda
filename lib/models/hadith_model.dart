class HadithBook {
  final String id;
  final String nameBangla;
  final String nameArabic;
  final int totalHadiths;

  const HadithBook({
    required this.id,
    required this.nameBangla,
    required this.nameArabic,
    required this.totalHadiths,
  });
}

class HadithSection {
  final int number;
  final String nameBangla;
  final String nameEnglish;

  const HadithSection({
    required this.number,
    required this.nameBangla,
    required this.nameEnglish,
  });
}

class HadithItem {
  final int hadithNumber;
  final String bookName;
  final String chapterName;
  final String text;
  final String reference;

  const HadithItem({
    required this.hadithNumber,
    required this.bookName,
    this.chapterName = '',
    required this.text,
    required this.reference,
  });

  factory HadithItem.fromJson(Map<String, dynamic> json, {String bookName = 'সহীহ বুখারী'}) {
    final hadiths = json['hadiths'] as List<dynamic>?;
    if (hadiths != null && hadiths.isNotEmpty) {
      final h = hadiths.first as Map<String, dynamic>;
      return HadithItem.fromSingleJson(h, bookName: bookName);
    }
    throw Exception('Invalid hadith json format');
  }

  factory HadithItem.fromSingleJson(Map<String, dynamic> h, {String bookName = 'সহীহ বুখারী'}) {
    final num = h['hadithnumber'] is int
        ? h['hadithnumber'] as int
        : int.tryParse(h['hadithnumber'].toString()) ?? 1;
    final rawText = (h['text'] ?? '').toString().trim();
    return HadithItem(
      hadithNumber: num,
      bookName: bookName,
      text: rawText,
      reference: '$bookName: $num',
    );
  }
}
