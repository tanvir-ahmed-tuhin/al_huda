import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/surah_model.dart';

class StorageService {
  static const String _keyBookmarks = 'quran_bookmarks';
  static const String _keyLastReadSurah = 'last_read_surah';
  static const String _keyLastReadAyah = 'last_read_ayah';
  static const String _keyLastReadSurahName = 'last_read_surah_name';
  static const String _keyTasbihCount = 'tasbih_count';
  static const String _keyTasbihTarget = 'tasbih_target';
  static const String _keyArabicFontSize = 'arabic_font_size';
  static const String _keySelectedCityIndex = 'selected_city_index';
  static const String _keyIsDarkMode = 'is_dark_mode';
  static const String _keyUseLiveLocation = 'use_live_location';
  static const String _keyLiveLatitude = 'live_latitude';
  static const String _keyLiveLongitude = 'live_longitude';
  static const String _keyLiveLocationName = 'live_location_name';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Bookmarks
  static Future<List<BookmarkItem>> getBookmarks() async {
    await init();
    final listJson = _prefs?.getStringList(_keyBookmarks) ?? [];
    return listJson.map((item) => BookmarkItem.fromJson(jsonDecode(item))).toList();
  }

  static Future<void> toggleBookmark(BookmarkItem item) async {
    await init();
    final current = await getBookmarks();
    final index = current.indexWhere(
      (b) => b.surahNumber == item.surahNumber && b.ayahNumber == item.ayahNumber,
    );

    if (index >= 0) {
      current.removeAt(index);
    } else {
      current.insert(0, item);
    }

    final updatedJson = current.map((b) => jsonEncode(b.toJson())).toList();
    await _prefs?.setStringList(_keyBookmarks, updatedJson);
  }

  static Future<bool> isBookmarked(int surahNumber, int ayahNumber) async {
    final current = await getBookmarks();
    return current.any((b) => b.surahNumber == surahNumber && b.ayahNumber == ayahNumber);
  }

  // Last Read
  static Future<void> saveLastRead({
    required int surahNumber,
    required int ayahNumber,
    required String surahNameBangla,
  }) async {
    await init();
    await _prefs?.setInt(_keyLastReadSurah, surahNumber);
    await _prefs?.setInt(_keyLastReadAyah, ayahNumber);
    await _prefs?.setString(_keyLastReadSurahName, surahNameBangla);
  }

  static Map<String, dynamic> getLastRead() {
    return {
      'surahNumber': _prefs?.getInt(_keyLastReadSurah) ?? 1,
      'ayahNumber': _prefs?.getInt(_keyLastReadAyah) ?? 1,
      'surahNameBangla': _prefs?.getString(_keyLastReadSurahName) ?? 'আল-ফাতিহা',
    };
  }

  // Tasbih
  static Future<void> saveTasbihState(int count, int target) async {
    await init();
    await _prefs?.setInt(_keyTasbihCount, count);
    await _prefs?.setInt(_keyTasbihTarget, target);
  }

  static int getTasbihCount() => _prefs?.getInt(_keyTasbihCount) ?? 0;
  static int getTasbihTarget() => _prefs?.getInt(_keyTasbihTarget) ?? 33;

  // Arabic Font Size
  static Future<void> saveArabicFontSize(double size) async {
    await init();
    await _prefs?.setDouble(_keyArabicFontSize, size);
  }

  static double getArabicFontSize() => _prefs?.getDouble(_keyArabicFontSize) ?? 24.0;

  // Selected City Index
  static Future<void> saveSelectedCityIndex(int index) async {
    await init();
    await _prefs?.setInt(_keySelectedCityIndex, index);
  }

  static int getSelectedCityIndex() => _prefs?.getInt(_keySelectedCityIndex) ?? 0;

  // Live Location Settings
  static Future<void> saveLiveLocationState({
    required bool isLive,
    double? latitude,
    double? longitude,
    String? locationName,
  }) async {
    await init();
    await _prefs?.setBool(_keyUseLiveLocation, isLive);
    if (latitude != null) await _prefs?.setDouble(_keyLiveLatitude, latitude);
    if (longitude != null) await _prefs?.setDouble(_keyLiveLongitude, longitude);
    if (locationName != null) await _prefs?.setString(_keyLiveLocationName, locationName);
  }

  static bool getUseLiveLocation() => _prefs?.getBool(_keyUseLiveLocation) ?? false;
  static double? getLiveLatitude() => _prefs?.getDouble(_keyLiveLatitude);
  static double? getLiveLongitude() => _prefs?.getDouble(_keyLiveLongitude);
  static String? getLiveLocationName() => _prefs?.getString(_keyLiveLocationName);

  // Dark Mode
  static Future<void> saveDarkMode(bool isDark) async {
    await init();
    await _prefs?.setBool(_keyIsDarkMode, isDark);
  }

  static bool isDarkMode() => _prefs?.getBool(_keyIsDarkMode) ?? true;

  // Azan Settings
  static const String _keyAzanEnabled = 'azan_enabled';
  static const String _keySelectedAzanVoice = 'selected_azan_voice';
  static const String _keyUseFajrSpecial = 'azan_use_fajr_special';
  static const String _keyAzanPrayerPrefix = 'azan_enabled_prayer_';
  static const String _keyAzanVolume = 'azan_volume';

  static Future<void> saveAzanMasterEnabled(bool enabled) async {
    await init();
    await _prefs?.setBool(_keyAzanEnabled, enabled);
  }

  static bool isAzanMasterEnabled() => _prefs?.getBool(_keyAzanEnabled) ?? true;

  static Future<void> saveSelectedAzanVoiceId(String id) async {
    await init();
    await _prefs?.setString(_keySelectedAzanVoice, id);
  }

  static String getSelectedAzanVoiceId() => _prefs?.getString(_keySelectedAzanVoice) ?? 'makkah_ali_mulla';

  static Future<void> saveUseFajrSpecial(bool enabled) async {
    await init();
    await _prefs?.setBool(_keyUseFajrSpecial, enabled);
  }

  static bool getUseFajrSpecial() => _prefs?.getBool(_keyUseFajrSpecial) ?? true;

  static Future<void> savePrayerAzanEnabled(String prayerName, bool enabled) async {
    await init();
    await _prefs?.setBool('$_keyAzanPrayerPrefix$prayerName', enabled);
  }

  static bool isPrayerAzanEnabled(String prayerName) =>
      _prefs?.getBool('$_keyAzanPrayerPrefix$prayerName') ?? true;

  static Future<void> saveAzanVolume(double volume) async {
    await init();
    await _prefs?.setDouble(_keyAzanVolume, volume);
  }

  static double getAzanVolume() => _prefs?.getDouble(_keyAzanVolume) ?? 1.0;

  // Generic Storage Helpers
  static bool? getBool(String key) => _prefs?.getBool(key);

  static Future<void> setBool(String key, bool value) async {
    await init();
    await _prefs?.setBool(key, value);
  }

  static String? getString(String key) => _prefs?.getString(key);

  static Future<void> setString(String key, String value) async {
    await init();
    await _prefs?.setString(key, value);
  }
}
