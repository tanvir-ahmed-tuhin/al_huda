import 'package:flutter/material.dart';

enum PrayerName {
  fajr,
  sunrise,
  dhuhr,
  asr,
  maghrib,
  isha,
}

class PrayerTimeModel {
  final TimeOfDay fajr;
  final TimeOfDay sunrise;
  final TimeOfDay dhuhr;
  final TimeOfDay asr;
  final TimeOfDay maghrib;
  final TimeOfDay isha;
  final DateTime date;
  final String hijriDate;
  final String locationName;

  const PrayerTimeModel({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.date,
    required this.hijriDate,
    required this.locationName,
  });

  PrayerName get currentOrNextPrayer {
    final now = DateTime.now();
    final nowMinutes = now.hour * 60 + now.minute;

    if (nowMinutes < _toMinutes(fajr)) return PrayerName.fajr;
    if (nowMinutes < _toMinutes(sunrise)) return PrayerName.sunrise;
    if (nowMinutes < _toMinutes(dhuhr)) return PrayerName.dhuhr;
    if (nowMinutes < _toMinutes(asr)) return PrayerName.asr;
    if (nowMinutes < _toMinutes(maghrib)) return PrayerName.maghrib;
    if (nowMinutes < _toMinutes(isha)) return PrayerName.isha;
    return PrayerName.fajr;
  }

  Duration get timeUntilNextPrayer {
    final now = DateTime.now();
    final nextPrayer = currentOrNextPrayer;
    final targetTime = _timeOfDayToDateTime(getTimeForPrayer(nextPrayer), now, nextPrayer == PrayerName.fajr && now.hour >= 20);
    return targetTime.difference(now);
  }

  TimeOfDay getTimeForPrayer(PrayerName prayer) {
    switch (prayer) {
      case PrayerName.fajr:
        return fajr;
      case PrayerName.sunrise:
        return sunrise;
      case PrayerName.dhuhr:
        return dhuhr;
      case PrayerName.asr:
        return asr;
      case PrayerName.maghrib:
        return maghrib;
      case PrayerName.isha:
        return isha;
    }
  }

  static String getPrayerNameBangla(PrayerName prayer) {
    switch (prayer) {
      case PrayerName.fajr:
        return 'ফজর';
      case PrayerName.sunrise:
        return 'সূর্যোদয়';
      case PrayerName.dhuhr:
        return 'যোহর';
      case PrayerName.asr:
        return 'আসর';
      case PrayerName.maghrib:
        return 'মাগরিব';
      case PrayerName.isha:
        return 'ইশা';
    }
  }

  static String getPrayerNameEnglish(PrayerName prayer) {
    switch (prayer) {
      case PrayerName.fajr:
        return 'Fajr';
      case PrayerName.sunrise:
        return 'Sunrise';
      case PrayerName.dhuhr:
        return 'Dhuhr';
      case PrayerName.asr:
        return 'Asr';
      case PrayerName.maghrib:
        return 'Maghrib';
      case PrayerName.isha:
        return 'Isha';
    }
  }

  static int _toMinutes(TimeOfDay tod) => tod.hour * 60 + tod.minute;

  static DateTime _timeOfDayToDateTime(TimeOfDay tod, DateTime baseDate, bool isTomorrow) {
    final day = isTomorrow ? baseDate.add(const Duration(days: 1)) : baseDate;
    return DateTime(day.year, day.month, day.day, tod.hour, tod.minute);
  }
}
