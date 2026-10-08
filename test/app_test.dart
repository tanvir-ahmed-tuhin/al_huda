import 'package:flutter_test/flutter_test.dart';
import 'package:al_quran_app/services/qibla_service.dart';
import 'package:al_quran_app/services/prayer_service.dart';
import 'package:al_quran_app/services/quran_data_service.dart';

void main() {
  group('Islamic App Core Tests', () {
    test('114 Surahs directory is populated', () {
      expect(QuranDataService.surahList.length, 114);
      expect(QuranDataService.surahList[0].nameBangla, 'আল-ফাতিহা');
      expect(QuranDataService.surahList[113].nameBangla, 'আন-নাস');
    });

    test('Qibla angle calculation for Dhaka is accurate', () {
      // Dhaka coordinates: ~23.81, 90.41
      final angle = QiblaService.calculateQiblaAngle(23.8103, 90.4125);
      // Qibla from Dhaka is ~277.5 degrees
      expect(angle, greaterThan(270.0));
      expect(angle, lessThan(285.0));

      final distance = QiblaService.calculateDistanceToKaaba(23.8103, 90.4125);
      // Distance is ~4800 to 5200 km
      expect(distance, greaterThan(4500.0));
      expect(distance, lessThan(5500.0));
    });

    test('Prayer calculation outputs valid times', () {
      final times = PrayerService.calculatePrayerTimes(
        latitude: 23.8103,
        longitude: 90.4125,
        locationName: 'Dhaka',
      );

      expect(times.fajr.hour, inInclusiveRange(3, 6));
      expect(times.dhuhr.hour, inInclusiveRange(11, 13));
      expect(times.maghrib.hour, inInclusiveRange(17, 19));
      expect(times.hijriDate.isNotEmpty, true);
    });

    test('Built-in Surah Al-Fatihah has 7 verses', () async {
      final ayahs = await QuranDataService.getSurahAyahs(1);
      expect(ayahs.length, 7);
      expect(ayahs[0].translationBangla.contains('আল্লাহর নামে'), true);
    });
  });
}
