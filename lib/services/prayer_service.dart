import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/prayer_time_model.dart';

class PrayerService {
  /// Calculates prayer times for a given coordinate and date
  static PrayerTimeModel calculatePrayerTimes({
    required double latitude,
    required double longitude,
    required String locationName,
    DateTime? date,
  }) {
    final now = date ?? DateTime.now();
    final int dayOfYear = _getDayOfYear(now);

    // Approximate solar calculation
    final double b = 2 * math.pi * (dayOfYear - 81) / 365;
    final double eot = 9.87 * math.sin(2 * b) - 7.53 * math.cos(b) - 1.5 * math.sin(b); // Equation of time in mins
    final double solarDec = 23.45 * math.sin(_deg2rad(360 / 365 * (dayOfYear - 81))); // Solar declination

    // Solar noon (Dhuhr)
    final double timezoneOffsetHours = now.timeZoneOffset.inMinutes / 60.0;
    final double standardMeridian = timezoneOffsetHours * 15.0;
    final double solarNoonMinutes = 720 + (standardMeridian - longitude) * 4 - eot;

    // Zenith angle calculations
    final double latRad = _deg2rad(latitude);
    final double decRad = _deg2rad(solarDec);

    // Sunrise & Sunset (Zenith ~ 90.833°)
    final double sunAngle = _deg2rad(90.833);
    final double cosHaSun = (math.cos(sunAngle) - math.sin(latRad) * math.sin(decRad)) /
        (math.cos(latRad) * math.cos(decRad));
    final double haSunDeg = _rad2deg(math.acos(cosHaSun.clamp(-1.0, 1.0)));
    final double sunDurationMins = haSunDeg * 4;

    // Fajr (18° angle below horizon)
    final double fajrAngle = _deg2rad(108.0);
    final double cosHaFajr = (math.cos(fajrAngle) - math.sin(latRad) * math.sin(decRad)) /
        (math.cos(latRad) * math.cos(decRad));
    final double haFajrDeg = _rad2deg(math.acos(cosHaFajr.clamp(-1.0, 1.0)));
    final double fajrDurationMins = haFajrDeg * 4;

    // Isha (18° angle below horizon)
    final double ishaAngle = _deg2rad(108.0);
    final double cosHaIsha = (math.cos(ishaAngle) - math.sin(latRad) * math.sin(decRad)) /
        (math.cos(latRad) * math.cos(decRad));
    final double haIshaDeg = _rad2deg(math.acos(cosHaIsha.clamp(-1.0, 1.0)));
    final double ishaDurationMins = haIshaDeg * 4;

    // Asr (Hanafi shadow multiplier = 2)
    final double asrAltitude = _rad2deg(math.atan(1.0 / (2.0 + math.tan((latRad - decRad).abs()))));
    final double asrZenith = _deg2rad(90.0 - asrAltitude);
    final double cosHaAsr = (math.cos(asrZenith) - math.sin(latRad) * math.sin(decRad)) /
        (math.cos(latRad) * math.cos(decRad));
    final double haAsrDeg = _rad2deg(math.acos(cosHaAsr.clamp(-1.0, 1.0)));
    final double asrDurationMins = haAsrDeg * 4;

    final double dhuhrMins = solarNoonMinutes + 4; // slight safety offset
    final double sunriseMins = solarNoonMinutes - sunDurationMins;
    final double maghribMins = solarNoonMinutes + sunDurationMins + 3; // +3 min sunset safety
    final double fajrMins = solarNoonMinutes - fajrDurationMins;
    final double asrMins = solarNoonMinutes + asrDurationMins;
    final double ishaMins = solarNoonMinutes + ishaDurationMins;

    final fajrTod = _minutesToTimeOfDay(fajrMins);
    final sunriseTod = _minutesToTimeOfDay(sunriseMins);
    final dhuhrTod = _minutesToTimeOfDay(dhuhrMins);
    final asrTod = _minutesToTimeOfDay(asrMins);
    final maghribTod = _minutesToTimeOfDay(maghribMins);
    final ishaTod = _minutesToTimeOfDay(ishaMins);

    final hijriStr = getHijriDate(now);

    return PrayerTimeModel(
      fajr: fajrTod,
      sunrise: sunriseTod,
      dhuhr: dhuhrTod,
      asr: asrTod,
      maghrib: maghribTod,
      isha: ishaTod,
      date: now,
      hijriDate: hijriStr,
      locationName: locationName,
    );
  }

  static TimeOfDay _minutesToTimeOfDay(double totalMinutes) {
    int mins = totalMinutes.round() % 1440;
    if (mins < 0) mins += 1440;
    final hour = mins ~/ 60;
    final minute = mins % 60;
    return TimeOfDay(hour: hour, minute: minute);
  }

  static int _getDayOfYear(DateTime date) {
    return date.difference(DateTime(date.year, 1, 1)).inDays + 1;
  }

  static double _deg2rad(double deg) => deg * (math.pi / 180.0);
  static double _rad2deg(double rad) => rad * (180.0 / math.pi);

  /// Approximate Hijri Date Calculator
  static String getHijriDate(DateTime gregorian) {
    int y = gregorian.year;
    int m = gregorian.month;
    int d = gregorian.day;

    if (m < 3) {
      y -= 1;
      m += 12;
    }

    int a = y ~/ 100;
    int b = 2 - a + (a ~/ 4);
    int jd = (365.25 * (y + 4716)).floor() + (30.6001 * (m + 1)).floor() + d + b - 1524;

    int l = jd - 1948440 + 10632;
    int n = ((l - 1) ~/ 10631);
    l = l - 10631 * n + 354;
    int j = ((10985 - l) ~/ 5316) * ((50 * l) ~/ 17719) + (l ~/ 5670) * ((43 * l) ~/ 15238);
    l = l - ((30 - j) ~/ 15) * ((17719 * j) ~/ 50) - (j ~/ 16) * ((15238 * j) ~/ 43) + 29;
    int hijriMonth = (24 * l) ~/ 709;
    int hijriDay = l - (709 * hijriMonth) ~/ 24;
    int hijriYear = 30 * n + j - 30;

    final List<String> hijriMonthsBangla = [
      "মুহররম", "সফর", "রবিউল আউয়াল", "রবিউস সানি",
      "জমাদিউল আউয়াল", "জমাদিউস সানি", "রজব", "শাবান",
      "রমজান", "শাওয়াল", "জিলকদ", "জিলহজ্জ"
    ];

    final monthName = (hijriMonth >= 1 && hijriMonth <= 12) ? hijriMonthsBangla[hijriMonth - 1] : "রমজান";
    return "$hijriDay $monthName, $hijriYear হিজরি";
  }

  /// Formats TimeOfDay to Bengali string (e.g. "০৫:২০ AM")
  static String formatTimeOfDayBangla(TimeOfDay tod, {bool use12Hours = true}) {
    int hour = tod.hour;
    final int minute = tod.minute;
    String period = '';

    if (use12Hours) {
      period = hour >= 12 ? ' PM' : ' AM';
      hour = hour % 12;
      if (hour == 0) hour = 12;
    }

    final hourStr = hour.toString().padLeft(2, '0');
    final minStr = minute.toString().padLeft(2, '0');
    final formattedEnglish = '$hourStr:$minStr$period';

    return toBanglaDigits(formattedEnglish);
  }

  static String toBanglaDigits(String input) {
    const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const banglaDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];

    String output = input;
    for (int i = 0; i < 10; i++) {
      output = output.replaceAll(englishDigits[i], banglaDigits[i]);
    }
    return output;
  }
}
