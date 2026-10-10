import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/hadith_model.dart';

class HadithService {
  static final Random _random = Random();
  static final Map<String, List<HadithItem>> _sectionCache = {};

  static const List<HadithBook> books = [
    HadithBook(
      id: 'ben-bukhari',
      nameBangla: 'সহীহ বুখারী',
      nameArabic: 'صحيح البخاري',
      totalHadiths: 7563,
    ),
    HadithBook(
      id: 'ben-muslim',
      nameBangla: 'সহীহ মুসলিম',
      nameArabic: 'صحيح مسلم',
      totalHadiths: 7453,
    ),
    HadithBook(
      id: 'ben-tirmidhi',
      nameBangla: 'জামে আত-তিরমিযী',
      nameArabic: 'جامع الترمذي',
      totalHadiths: 3956,
    ),
    HadithBook(
      id: 'ben-abudawud',
      nameBangla: 'সুনানে আবু দাউদ',
      nameArabic: 'سنن أبي داود',
      totalHadiths: 5274,
    ),
    HadithBook(
      id: 'ben-nasai',
      nameBangla: 'সুনানে আন-নাসায়ী',
      nameArabic: 'سنن النسائي',
      totalHadiths: 5758,
    ),
    HadithBook(
      id: 'ben-ibnmajah',
      nameBangla: 'সুনানে ইবনে মাজাহ',
      nameArabic: 'سنن ابن ماجه',
      totalHadiths: 4341,
    ),
  ];

  static const Map<String, List<HadithSection>> bookSections = {
    'ben-bukhari': [
      HadithSection(number: 1, nameBangla: 'ওহীর সূচনা', nameEnglish: 'Revelation'),
      HadithSection(number: 2, nameBangla: 'ঈমান ও বিশ্বাস', nameEnglish: 'Belief'),
      HadithSection(number: 3, nameBangla: 'ইলম বা জ্ঞান', nameEnglish: 'Knowledge'),
      HadithSection(number: 4, nameBangla: 'ওযু ও তাহারাত', nameEnglish: 'Ablution'),
      HadithSection(number: 5, nameBangla: 'গোসলের বিধান', nameEnglish: 'Bathing'),
      HadithSection(number: 8, nameBangla: 'সালাত / নামাজ', nameEnglish: 'Prayers'),
      HadithSection(number: 9, nameBangla: 'সালাতের ওয়াক্ত', nameEnglish: 'Prayer Times'),
      HadithSection(number: 10, nameBangla: 'আযান ও ইকামত', nameEnglish: 'Adhan'),
      HadithSection(number: 11, nameBangla: 'পবিত্র জুমুআ', nameEnglish: 'Friday Prayer'),
      HadithSection(number: 24, nameBangla: 'যাকাত ও সদকা', nameEnglish: 'Zakat'),
      HadithSection(number: 30, nameBangla: 'সাওম বা সিয়াম', nameEnglish: 'Fasting'),
      HadithSection(number: 66, nameBangla: 'কুরআনের ফজিলত', nameEnglish: 'Virtues of Quran'),
      HadithSection(number: 78, nameBangla: 'সদ্ব্যবহার ও শিষ্টাচার', nameEnglish: 'Good Manners'),
      HadithSection(number: 80, nameBangla: 'দোয়া ও মোনাজাত', nameEnglish: 'Invocations'),
      HadithSection(number: 81, nameBangla: 'চিত্তশুদ্ধি ও খোদাভীতি', nameEnglish: 'Heart Softeners'),
    ],
    'ben-muslim': [
      HadithSection(number: 1, nameBangla: 'ঈমান ও তাওহীদ', nameEnglish: 'Faith'),
      HadithSection(number: 2, nameBangla: 'পবিত্রতা ও তাহারাত', nameEnglish: 'Purification'),
      HadithSection(number: 4, nameBangla: 'সালাত / নামাজ', nameEnglish: 'Prayers'),
      HadithSection(number: 5, nameBangla: 'মসজিদ ও নামাজের স্থান', nameEnglish: 'Masjids'),
      HadithSection(number: 12, nameBangla: 'যাকাত', nameEnglish: 'Zakat'),
      HadithSection(number: 13, nameBangla: 'সিয়াম বা রোজা', nameEnglish: 'Fasting'),
      HadithSection(number: 35, nameBangla: 'জিকির, দোয়া ও তাওবা', nameEnglish: 'Remembrance & Dua'),
      HadithSection(number: 45, nameBangla: 'সদ্ব্যবহার ও আত্মীয়তা', nameEnglish: 'Good Manners & Kinship'),
    ],
    'ben-tirmidhi': [
      HadithSection(number: 1, nameBangla: 'পবিত্রতা ও ওযু', nameEnglish: 'Purification'),
      HadithSection(number: 2, nameBangla: 'সালাত / নামাজ', nameEnglish: 'Prayers'),
      HadithSection(number: 3, nameBangla: 'বিতর সালাত', nameEnglish: 'Witr Prayer'),
      HadithSection(number: 4, nameBangla: 'পবিত্র জুমুআ', nameEnglish: 'Friday Prayer'),
      HadithSection(number: 5, nameBangla: 'যাকাত ও সদকা', nameEnglish: 'Zakat'),
      HadithSection(number: 6, nameBangla: 'সাওম বা রোজা', nameEnglish: 'Fasting'),
      HadithSection(number: 25, nameBangla: 'সদ্ব্যবহার ও সদাচার', nameEnglish: 'Righteousness'),
      HadithSection(number: 45, nameBangla: 'দোয়া ও প্রার্থনা', nameEnglish: 'Supplications'),
    ],
    'ben-abudawud': [
      HadithSection(number: 1, nameBangla: 'পবিত্রতা ও তাহারাত', nameEnglish: 'Purification'),
      HadithSection(number: 2, nameBangla: 'সালাত / নামাজ', nameEnglish: 'Prayers'),
      HadithSection(number: 9, nameBangla: 'যাকাত', nameEnglish: 'Zakat'),
      HadithSection(number: 14, nameBangla: 'সাওম বা রোজা', nameEnglish: 'Fasting'),
      HadithSection(number: 26, nameBangla: 'ইলম ও জ্ঞান', nameEnglish: 'Knowledge'),
      HadithSection(number: 36, nameBangla: 'সাধারণ শিষ্টাচার', nameEnglish: 'General Behavior'),
    ],
    'ben-nasai': [
      HadithSection(number: 1, nameBangla: 'তাহারাত ও পবিত্রতা', nameEnglish: 'Purification'),
      HadithSection(number: 5, nameBangla: 'সালাত ও কিবলা', nameEnglish: 'Salah'),
      HadithSection(number: 6, nameBangla: 'সালাতের ওয়াক্ত', nameEnglish: 'Times of Prayer'),
      HadithSection(number: 8, nameBangla: 'আযান ও আহ্বান', nameEnglish: 'The Adhan'),
      HadithSection(number: 22, nameBangla: 'সিয়াম বা রোজা', nameEnglish: 'Fasting'),
      HadithSection(number: 23, nameBangla: 'যাকাত', nameEnglish: 'Zakah'),
    ],
    'ben-ibnmajah': [
      HadithSection(number: 1, nameBangla: 'তাহারাত ও পবিত্রতা', nameEnglish: 'Purification'),
      HadithSection(number: 5, nameBangla: 'সালাত কায়েম করা', nameEnglish: 'Establishing Prayer'),
      HadithSection(number: 6, nameBangla: 'সালাতের ওয়াক্ত', nameEnglish: 'Prayer Times'),
      HadithSection(number: 7, nameBangla: 'সাওম বা রোজা', nameEnglish: 'Fasting'),
      HadithSection(number: 8, nameBangla: 'যাকাত', nameEnglish: 'Zakat'),
      HadithSection(number: 31, nameBangla: 'দোয়া ও মোনাজাত', nameEnglish: 'Supplications'),
    ],
  };

  // Reliable offline fallbacks in case of network unavailability
  static final List<HadithItem> _offlineFallbacks = [
    const HadithItem(
      hadithNumber: 1,
      bookName: 'সহীহ বুখারী',
      text: '‘উমর ইবনুল খাত্তাব (রা.) হতে বর্ণিত। রাসূলুল্লাহ (সা.) ইরশাদ করেন: "কাজের ফলাফল নিয়্যাতের ওপর নির্ভরশীল। আর প্রত্যেক ব্যক্তি তার নিয়্যাত অনুযায়ী প্রতিদান পাবে।"',
      reference: 'সহীহ বুখারী: ১',
    ),
    const HadithItem(
      hadithNumber: 13,
      bookName: 'সহীহ বুখারী',
      text: 'আনাস (রা.) হতে বর্ণিত। নবীজি (সা.) বলেন: "তোমাদের কেউ ততক্ষণ পর্যন্ত প্রকৃত মুমিন হতে পারবে না, যতক্ষণ না সে তার ভাইয়ের জন্য তা-ই পছন্দ করবে যা সে নিজের জন্য পছন্দ করে।"',
      reference: 'সহীহ বুখারী: ১৩',
    ),
    const HadithItem(
      hadithNumber: 5027,
      bookName: 'সহীহ বুখারী',
      text: '‘উসমান (রা.) সূত্রে নবীজি (সা.) হতে বর্ণিত। তিনি বলেন: "তোমাদের মধ্যে সর্বোত্তম ব্যক্তি সে, যে নিজে কুরআন শিখে এবং অন্যকে তা শিক্ষা দেয়।"',
      reference: 'সহীহ বুখারী: ৫০২৭',
    ),
    const HadithItem(
      hadithNumber: 6464,
      bookName: 'সহীহ বুখারী',
      text: 'আয়েশা (রা.) হতে বর্ণিত। রাসূলুল্লাহ (সা.) বলেছেন: "আল্লাহর কাছে সর্বাধিক প্রিয় আমল তা-ই, যা নিয়মিত করা হয়—যদিও তা পরিমাণে অল্প হয়।"',
      reference: 'সহীহ বুখারী: ৬৪৬৪',
    ),
    const HadithItem(
      hadithNumber: 1,
      bookName: 'জামে আত-তিরমিযী',
      text: 'ইবনে উমর (রা.) হতে বর্ণিত। রাসূলুল্লাহ (সা.) বলেন: "পবিত্রতা ছাড়া সালাত কবুল হয় না, আর হারাম উপায়ে উপার্জিত মালের সদকা কবুল হয় না।"',
      reference: 'জামে আত-তিরমিযী: ১',
    ),
  ];

  static String getBookBanglaName(String bookId) {
    final book = books.firstWhere(
      (b) => b.id == bookId,
      orElse: () => books.first,
    );
    return book.nameBangla;
  }

  /// Fetches all Hadiths in a particular section/chapter of a book
  static Future<List<HadithItem>> getHadithsBySection(String bookId, int sectionNumber) async {
    final cacheKey = '$bookId-$sectionNumber';
    if (_sectionCache.containsKey(cacheKey) && _sectionCache[cacheKey]!.isNotEmpty) {
      return _sectionCache[cacheKey]!;
    }

    final url = Uri.parse(
      'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions/$bookId/sections/$sectionNumber.json',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 7));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final rawHadiths = data['hadiths'] as List<dynamic>?;
        if (rawHadiths != null && rawHadiths.isNotEmpty) {
          final bookName = getBookBanglaName(bookId);
          final List<HadithItem> items = [];
          for (final h in rawHadiths) {
            final map = h as Map<String, dynamic>;
            final text = (map['text'] ?? '').toString().trim();
            if (text.isNotEmpty) {
              items.add(HadithItem.fromSingleJson(map, bookName: bookName));
            }
          }
          if (items.isNotEmpty) {
            _sectionCache[cacheKey] = items;
            return items;
          }
        }
      }
    } catch (_) {}

    return _offlineFallbacks
        .where((h) => h.bookName == getBookBanglaName(bookId))
        .toList();
  }

  /// Fetches a specific Hadith by book and number from API
  static Future<HadithItem?> getHadithByNumber(String bookId, int hadithNumber) async {
    final url = Uri.parse(
      'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions/$bookId/$hadithNumber.json',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final bookName = getBookBanglaName(bookId);
        final item = HadithItem.fromJson(data, bookName: bookName);
        if (item.text.isNotEmpty) {
          return item;
        }
      }
    } catch (_) {}

    return null;
  }

  /// Fetches a random Hadith from Bukhari or the selected book
  static Future<HadithItem> getRandomHadith([String bookId = 'ben-bukhari']) async {
    final popular = [1, 13, 5027, 6464, 10, 11, 12, 15, 16, 21, 41, 6023, 6491];
    final hadithNum = popular[_random.nextInt(popular.length)];
    final item = await getHadithByNumber(bookId, hadithNum);
    if (item != null) return item;

    return _offlineFallbacks[_random.nextInt(_offlineFallbacks.length)];
  }
}
