import 'dart:convert';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../models/mosque_model.dart';

class MosqueService {
  static const String _osmSearchUrl = 'https://nominatim.openstreetmap.org/search';

  // Curated database of well-known mosques across divisions & historic landmarks of Bangladesh
  static final List<MosqueModel> curatedMosques = [
    const MosqueModel(
      id: 'curated_1',
      name: 'বায়তুল মোকাররম জাতীয় মসজিদ',
      address: 'পল্টন, ঢাকা-১০০০',
      latitude: 23.7259,
      longitude: 90.4125,
      distanceMeters: 0,
      direction: 'উত্তর',
      type: 'জাতীয় মসজিদ',
      hasWudu: true,
      hasFemalePrayerSpace: true,
      isJamahAvailable: true,
      isHistorical: true,
      description: 'বাংলাদেশের জাতীয় মসজিদ, যা ১৯৬০ সালে প্রতিষ্ঠিত হয় এবং ইসলামিক স্থাপত্যকলার এক অনন্য নিদর্শন।',
    ),
    const MosqueModel(
      id: 'curated_2',
      name: 'তারা মসজিদ (সিতারা মসজিদ)',
      address: 'আরমানিটোলা, পুরান ঢাকা',
      latitude: 23.7147,
      longitude: 90.4022,
      distanceMeters: 0,
      direction: 'উত্তর',
      type: 'ঐতিহাসিক মসজিদ',
      hasWudu: true,
      hasFemalePrayerSpace: false,
      isJamahAvailable: true,
      isHistorical: true,
      description: '১৯ শতকের শুরুতে নির্মিত চমৎকার চিনির টুকরা কারুকাজ ও নীল তারার মোজাইকে সাজানো ঐতিহ্যবাহী মসজিদ।',
    ),
    const MosqueModel(
      id: 'curated_3',
      name: 'চকবাজার শাহী জামে মসজিদ',
      address: 'চকবাজার, পুরান ঢাকা',
      latitude: 23.7169,
      longitude: 90.3953,
      distanceMeters: 0,
      direction: 'উত্তর',
      type: 'ঐতিহাসিক জামে মসজিদ',
      hasWudu: true,
      hasFemalePrayerSpace: false,
      isJamahAvailable: true,
      isHistorical: true,
      description: '১৬৭৬ সালে সুবাদার শায়েস্তা খাঁ কর্তৃক নির্মিত ঢাকা শহরের অন্যতম প্রাচীন ঐতিহাসিক জামে মসজিদ।',
    ),
    const MosqueModel(
      id: 'curated_4',
      name: 'সাত গম্বুজ মসজিদ',
      address: 'জাফরাবাদ, মোহাম্মদপুর, ঢাকা',
      latitude: 23.7548,
      longitude: 90.3582,
      distanceMeters: 0,
      direction: 'উত্তর',
      type: 'ঐতিহাসিক মসজিদ',
      hasWudu: true,
      hasFemalePrayerSpace: false,
      isJamahAvailable: true,
      isHistorical: true,
      description: '১৭ শতকের মুঘল স্থাপত্যের অনবদ্য নিদর্শন, তিনটি বড় এবং চারটি কোণায় ছোট গম্বুজ সমন্বিত।',
    ),
    const MosqueModel(
      id: 'curated_5',
      name: 'গুলশান সেন্ট্রাল জামে মসজিদ (সোসাইটি মসজিদ)',
      address: 'রোড ৬৩, গুলশান-২, ঢাকা-১২১২',
      latitude: 23.7915,
      longitude: 90.4184,
      distanceMeters: 0,
      direction: 'উত্তর',
      type: 'কেন্দ্রীয় জামে মসজিদ',
      hasWudu: true,
      hasFemalePrayerSpace: true,
      isJamahAvailable: true,
      isHistorical: false,
      description: 'সুবিশাল ও আধুনিক সুযোগ-সুবিধাসম্পন্ন দৃষ্টিনন্দন জামে মসজিদ।',
    ),
    const MosqueModel(
      id: 'curated_6',
      name: 'ধানমন্ডি ঈদগাহ ও তাকওয়া জামে মসজিদ',
      address: 'রোড ১২/এ, ধানমন্ডি, ঢাকা',
      latitude: 23.7461,
      longitude: 90.3742,
      distanceMeters: 0,
      direction: 'উত্তর',
      type: 'জামে মসজিদ',
      hasWudu: true,
      hasFemalePrayerSpace: true,
      isJamahAvailable: true,
      isHistorical: false,
      description: 'ধানমন্ডি লেক সংলগ্ন শান্তিময় ও মনোরম পরিবেশে অবস্থিত বৃহদাকার জামে মসজিদ।',
    ),
    const MosqueModel(
      id: 'curated_7',
      name: 'বনানী কেন্দ্রীয় জামে মসজিদ',
      address: 'রোড ১১, বনানী, ঢাকা-১২১৩',
      latitude: 23.7937,
      longitude: 90.4048,
      distanceMeters: 0,
      direction: 'উত্তর',
      type: 'কেন্দ্রীয় জামে মসজিদ',
      hasWudu: true,
      hasFemalePrayerSpace: true,
      isJamahAvailable: true,
      isHistorical: false,
      description: 'আধুনিক অ্যারোবিক আর্কিটেকচার ও মনোরম সুবিশাল জামাত প্রাঙ্গণ।',
    ),
    const MosqueModel(
      id: 'curated_8',
      name: 'মহাখালী ডিওএইচএস জামে মসজিদ',
      address: 'ডিওএইচএস, মহাখালী, ঢাকা',
      latitude: 23.7820,
      longitude: 90.3930,
      distanceMeters: 0,
      direction: 'উত্তর',
      type: 'জামে মসজিদ',
      hasWudu: true,
      hasFemalePrayerSpace: true,
      isJamahAvailable: true,
      isHistorical: false,
      description: 'প্রশস্ত ও সুশৃঙ্খল পরিবেশের আবাসিক জামে মসজিদ।',
    ),
    const MosqueModel(
      id: 'curated_9',
      name: 'উত্তরা সেক্টর ৩ কেন্দ্রীয় জামে মসজিদ',
      address: 'সেক্টর ৩, উত্তরা, ঢাকা-১২৩০',
      latitude: 23.8710,
      longitude: 90.3970,
      distanceMeters: 0,
      direction: 'উত্তর',
      type: 'কেন্দ্রীয় জামে মসজিদ',
      hasWudu: true,
      hasFemalePrayerSpace: true,
      isJamahAvailable: true,
      isHistorical: false,
      description: 'উত্তরা মডেল টাউনের প্রধান কেন্দ্রীয় মসজিদ ও ইসলামিক কেন্দ্র।',
    ),
    const MosqueModel(
      id: 'curated_10',
      name: 'আন্দরকিল্লা শাহী জামে মসজিদ',
      address: 'আন্দরকিল্লা, চট্টগ্রাম',
      latitude: 22.3364,
      longitude: 91.8365,
      distanceMeters: 0,
      direction: 'উত্তর',
      type: 'ঐতিহাসিক জামে মসজিদ',
      hasWudu: true,
      hasFemalePrayerSpace: true,
      isJamahAvailable: true,
      isHistorical: true,
      description: '১৬৬৭ সালে মুঘল সেনাপতি উমেদ খাঁ কর্তৃক চট্টগ্রামের টিলার শীর্ষে প্রতিষ্ঠিত অন্যতম প্রাচীন মসজিদ।',
    ),
    const MosqueModel(
      id: 'curated_11',
      name: 'জমিয়াতুল ফালাহ জাতীয় মসজিদ',
      address: 'দামপাড়া, ওয়াসার মোড়, চট্টগ্রাম',
      latitude: 22.3551,
      longitude: 91.8219,
      distanceMeters: 0,
      direction: 'উত্তর',
      type: 'বিভাগীয় প্রধান মসজিদ',
      hasWudu: true,
      hasFemalePrayerSpace: true,
      isJamahAvailable: true,
      isHistorical: false,
      description: 'চট্টগ্রামের সর্ববৃহৎ ইসলামিক কমপ্লেক্স ও প্রধান জামাত প্রাঙ্গণ।',
    ),
    const MosqueModel(
      id: 'curated_12',
      name: 'হযরত শাহজালাল (রহ.) মাজার জামে মসজিদ',
      address: 'দরগাহ মহল্লা, সিলেট',
      latitude: 24.8998,
      longitude: 91.8679,
      distanceMeters: 0,
      direction: 'উত্তর',
      type: 'ঐতিহাসিক জামে মসজিদ',
      hasWudu: true,
      hasFemalePrayerSpace: true,
      isJamahAvailable: true,
      isHistorical: true,
      description: 'সিলেটের বিশ্ববিখ্যাত ওলিয়ে কামেল হযরত শাহজালাল (রহ.) মাজার প্রাঙ্গণের সুপ্রাচীন মসজিদ।',
    ),
    const MosqueModel(
      id: 'curated_13',
      name: 'ষাট গম্বুজ মসজিদ',
      address: 'সুন্দরঘোনা, বাগেরহাট সদর',
      latitude: 22.6744,
      longitude: 89.7417,
      distanceMeters: 0,
      direction: 'উত্তর',
      type: 'ইউনেস্কো বিশ্ব ঐতিহ্যবাহী মসজিদ',
      hasWudu: true,
      hasFemalePrayerSpace: false,
      isJamahAvailable: true,
      isHistorical: true,
      description: '১৫ শতকে খান জাহান আলী (রহ.) কর্তৃক নির্মিত ইউনেস্কো স্বীকৃত ঐতিহাসিক ৭৭ গম্বুজবিশিষ্ট বিশ্ব ঐতিহ্য।',
    ),
    const MosqueModel(
      id: 'curated_14',
      name: 'বায়তুল আমান জামে মসজিদ (গুঠিয়া মসজিদ)',
      address: 'উজিরপুর, বরিশাল',
      latitude: 22.8122,
      longitude: 90.2520,
      distanceMeters: 0,
      direction: 'উত্তর',
      type: 'দৃষ্টিনন্দন জামে মসজিদ',
      hasWudu: true,
      hasFemalePrayerSpace: true,
      isJamahAvailable: true,
      isHistorical: false,
      description: 'দক্ষিণাঞ্চলের অন্যতম বৃহৎ ও দৃষ্টিনন্দন মসজিদ কমপ্লেক্স, যা এর স্থাপত্য সৌন্দর্যের জন্য দেশব্যাপী খ্যাত।',
    ),
    const MosqueModel(
      id: 'curated_15',
      name: 'ছোট সোনা মসজিদ',
      address: 'শিবগঞ্জ, চাঁপাইনবাবগঞ্জ',
      latitude: 24.8019,
      longitude: 88.1542,
      distanceMeters: 0,
      direction: 'উত্তর',
      type: 'ঐতিহাসিক সুলতানি মসজিদ',
      hasWudu: true,
      hasFemalePrayerSpace: false,
      isJamahAvailable: true,
      isHistorical: true,
      description: 'সুলতানি আমলের অনিন্দ্যসুন্দর স্থাপত্যকীর্তি যা বাংলার রত্ন হিসেবে অভিহিত।',
    ),
    const MosqueModel(
      id: 'curated_16',
      name: 'বাঘা শাহী জামে মসজিদ',
      address: 'বাঘা, রাজশাহী',
      latitude: 24.1925,
      longitude: 88.8351,
      distanceMeters: 0,
      direction: 'উত্তর',
      type: 'ঐতিহাসিক পোড়ামাটির মসজিদ',
      hasWudu: true,
      hasFemalePrayerSpace: false,
      isJamahAvailable: true,
      isHistorical: true,
      description: '১৫২৩ সালে নির্মিত পোড়ামাটির অপূর্ব কারুকার্যে খচিত ঐতিহাসিক ঐতিহ্যবাহী জামে মসজিদ।',
    ),
    const MosqueModel(
      id: 'curated_17',
      name: 'ময়মনসিংহ বড় মসজিদ',
      address: 'চকবাজার, ময়মনসিংহ সদর',
      latitude: 24.7577,
      longitude: 90.4073,
      distanceMeters: 0,
      direction: 'উত্তর',
      type: 'কেন্দ্রীয় জামে মসজিদ',
      hasWudu: true,
      hasFemalePrayerSpace: true,
      isJamahAvailable: true,
      isHistorical: true,
      description: 'ময়মনসিংহের সবচেয়ে সুপরিচিত ও প্রাচীন কেন্দ্রীয় জামে মসজিদ।',
    ),
    const MosqueModel(
      id: 'curated_18',
      name: 'খুলনা টাউন জামে মসজিদ',
      address: 'পিকচার প্যালেস মোড়, খুলনা',
      latitude: 22.8157,
      longitude: 89.5644,
      distanceMeters: 0,
      direction: 'উত্তর',
      type: 'প্রধান জামে মসজিদ',
      hasWudu: true,
      hasFemalePrayerSpace: true,
      isJamahAvailable: true,
      isHistorical: false,
      description: 'খুলনা মহানগরীর কেন্দ্রস্থলে অবস্থিত বৃহত্তম প্রধান জামে মসজিদ।',
    ),
  ];

  /// Calculate compass bearing direction in Bangla
  static String calculateDirection(double startLat, double startLon, double endLat, double endLon) {
    final startLatRad = startLat * pi / 180;
    final startLonRad = startLon * pi / 180;
    final endLatRad = endLat * pi / 180;
    final endLonRad = endLon * pi / 180;

    final dLon = endLonRad - startLonRad;
    final y = sin(dLon) * cos(endLatRad);
    final x = cos(startLatRad) * sin(endLatRad) - sin(startLatRad) * cos(endLatRad) * cos(dLon);
    final bearingRad = atan2(y, x);
    final bearingDeg = (bearingRad * 180 / pi + 360) % 360;

    if (bearingDeg >= 337.5 || bearingDeg < 22.5) return 'উত্তর';
    if (bearingDeg >= 22.5 && bearingDeg < 67.5) return 'উত্তর-পূর্ব';
    if (bearingDeg >= 67.5 && bearingDeg < 112.5) return 'পূর্ব';
    if (bearingDeg >= 112.5 && bearingDeg < 157.5) return 'দক্ষিণ-পূর্ব';
    if (bearingDeg >= 157.5 && bearingDeg < 202.5) return 'দক্ষিণ';
    if (bearingDeg >= 202.5 && bearingDeg < 247.5) return 'দক্ষিণ-পশ্চিম';
    if (bearingDeg >= 247.5 && bearingDeg < 292.5) return 'পশ্চিম';
    return 'উত্তর-পশ্চিম';
  }

  /// Fetch nearby mosques given current user latitude and longitude
  static Future<List<MosqueModel>> getNearbyMosques({
    required double latitude,
    required double longitude,
    double radiusKm = 6.0,
  }) async {
    final List<MosqueModel> results = [];
    final Set<String> seenNames = {};

    // 1. Try to fetch live OpenStreetMap mosques around user location
    try {
      final deltaLat = radiusKm / 111.0;
      final deltaLon = radiusKm / (111.0 * cos(latitude * pi / 180));
      final minLat = latitude - deltaLat;
      final maxLat = latitude + deltaLat;
      final minLon = longitude - deltaLon;
      final maxLon = longitude + deltaLon;

      final url = Uri.parse(
        '$_osmSearchUrl?format=json&q=mosque&viewbox=$minLon,$maxLat,$maxLon,$minLat&bounded=1&limit=30',
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'AlHudaIslamicApp/1.0 (Islamic Mosque Finder)',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        for (var item in jsonList) {
          if (item is Map<String, dynamic>) {
            final mosque = MosqueModel.fromOsmJson(item, userLat: latitude, userLon: longitude);
            final dist = Geolocator.distanceBetween(latitude, longitude, mosque.latitude, mosque.longitude);
            final dir = calculateDirection(latitude, longitude, mosque.latitude, mosque.longitude);

            final cleanName = mosque.name.trim();
            if (cleanName.isNotEmpty && !seenNames.contains(cleanName)) {
              seenNames.add(cleanName);
              results.add(mosque.copyWith(
                distanceMeters: dist,
                direction: dir,
              ));
            }
          }
        }
      }
    } catch (_) {
      // In case of timeout or offline, we fallback to curated mosques
    }

    // 2. Incorporate curated mosques with calculated distances
    for (var mosque in curatedMosques) {
      final dist = Geolocator.distanceBetween(latitude, longitude, mosque.latitude, mosque.longitude);
      final dir = calculateDirection(latitude, longitude, mosque.latitude, mosque.longitude);

      if (!seenNames.contains(mosque.name.trim())) {
        seenNames.add(mosque.name.trim());
        results.add(mosque.copyWith(
          distanceMeters: dist,
          direction: dir,
        ));
      }
    }

    // 3. Sort ascending by distance (closest first)
    results.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));

    return results;
  }
}
