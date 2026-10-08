import 'dart:async';
import 'package:flutter/material.dart';
import '../models/prayer_time_model.dart';
import '../services/prayer_service.dart';
import '../services/qibla_service.dart';
import '../services/storage_service.dart';

class PrayerProvider extends ChangeNotifier {
  Timer? _timer;
  PrayerTimeModel? _prayerTimes;
  CityLocation _selectedCity = QiblaService.defaultCities[0];

  PrayerTimeModel? get prayerTimes => _prayerTimes;
  CityLocation get selectedCity => _selectedCity;

  PrayerProvider() {
    _init();
  }

  Future<void> _init() async {
    final cityIndex = StorageService.getSelectedCityIndex();
    if (cityIndex >= 0 && cityIndex < QiblaService.defaultCities.length) {
      _selectedCity = QiblaService.defaultCities[cityIndex];
    }
    _recalculate();

    // Refresh every minute to update countdown & active prayer highlight
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      _recalculate();
    });
  }

  void _recalculate() {
    _prayerTimes = PrayerService.calculatePrayerTimes(
      latitude: _selectedCity.latitude,
      longitude: _selectedCity.longitude,
      locationName: _selectedCity.nameBangla,
    );
    notifyListeners();
  }

  void setCity(CityLocation city) {
    _selectedCity = city;
    _recalculate();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
