import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/prayer_time_model.dart';
import '../services/prayer_service.dart';
import '../services/qibla_service.dart';
import '../services/storage_service.dart';

class PrayerProvider extends ChangeNotifier {
  Timer? _timer;
  PrayerTimeModel? _prayerTimes;

  CityLocation _selectedCity = QiblaService.defaultCities[0];
  bool _isLiveLocation = false;
  bool _isLoadingLocation = false;
  double _currentLatitude = 23.8103;
  double _currentLongitude = 90.4125;
  String _currentLocationName = 'ঢাকা (Dhaka)';
  String? _locationStatusMessage;

  // Getters
  PrayerTimeModel? get prayerTimes => _prayerTimes;
  CityLocation get selectedCity => _selectedCity;
  bool get isLiveLocation => _isLiveLocation;
  bool get isLoadingLocation => _isLoadingLocation;
  double get currentLatitude => _currentLatitude;
  double get currentLongitude => _currentLongitude;
  String get currentLocationName => _currentLocationName;
  String get locationShortName => _currentLocationName.split(' (')[0].trim();
  String? get locationStatusMessage => _locationStatusMessage;

  PrayerProvider() {
    _init();
  }

  Future<void> _init() async {
    final useLive = StorageService.getUseLiveLocation();
    final savedLat = StorageService.getLiveLatitude();
    final savedLon = StorageService.getLiveLongitude();
    final savedName = StorageService.getLiveLocationName();

    if (useLive && savedLat != null && savedLon != null) {
      _isLiveLocation = true;
      _currentLatitude = savedLat;
      _currentLongitude = savedLon;
      _currentLocationName = savedName != null
          ? savedName.replaceAll(' (লাইভ)', '').replaceAll('(লাইভ)', '').trim()
          : 'ঢাকা (Dhaka)';
      _selectedCity = CityLocation(
        nameBangla: _currentLocationName,
        nameEnglish: 'Location',
        latitude: savedLat,
        longitude: savedLon,
      );
    } else {
      final cityIndex = StorageService.getSelectedCityIndex();
      if (cityIndex >= 0 && cityIndex < QiblaService.defaultCities.length) {
        _selectedCity = QiblaService.defaultCities[cityIndex];
        _currentLatitude = _selectedCity.latitude;
        _currentLongitude = _selectedCity.longitude;
        _currentLocationName = _selectedCity.nameBangla;
      }
    }

    _recalculate();

    // Auto-detect live location from GPS on startup
    _autoDetectLocationIfPermitted();

    // Refresh every second to update live countdown with seconds
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _recalculate();
    });
  }

  Future<void> _autoDetectLocationIfPermitted() async {
    try {
      final isEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        // Automatically request permission on startup
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        await fetchLiveLocation(requestPermission: false);
      }
    } catch (_) {}
  }

  void _recalculate() {
    _prayerTimes = PrayerService.calculatePrayerTimes(
      latitude: _currentLatitude,
      longitude: _currentLongitude,
      locationName: _currentLocationName,
    );
    notifyListeners();
  }

  /// Request live GPS location and update prayer times
  Future<bool> fetchLiveLocation({bool requestPermission = true}) async {
    _isLoadingLocation = true;
    _locationStatusMessage = null;
    notifyListeners();

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _locationStatusMessage = 'ডিভাইসের GPS লোকেশন সার্ভিস বন্ধ রয়েছে।';
        _isLoadingLocation = false;
        notifyListeners();
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied && requestPermission) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        _locationStatusMessage = 'লোকেশন পারমিশন দেওয়া হয়নি।';
        _isLoadingLocation = false;
        notifyListeners();
        return false;
      }

      if (permission == LocationPermission.deniedForever) {
        _locationStatusMessage = 'লোকেশন পারমিশন স্থায়ীভাবে বন্ধ রয়েছে। অ্যাপ সেটিংসে অনুমতি দিন।';
        _isLoadingLocation = false;
        notifyListeners();
        return false;
      }

      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 8),
          ),
        );
      } catch (_) {
        position = await Geolocator.getLastKnownPosition();
      }

      if (position != null) {
        final nearest = QiblaService.findNearestCity(position.latitude, position.longitude);
        _currentLatitude = position.latitude;
        _currentLongitude = position.longitude;
        _currentLocationName = nearest.nameBangla;
        _isLiveLocation = true;

        _selectedCity = CityLocation(
          nameBangla: _currentLocationName,
          nameEnglish: nearest.nameEnglish,
          latitude: position.latitude,
          longitude: position.longitude,
        );

        await StorageService.saveLiveLocationState(
          isLive: true,
          latitude: position.latitude,
          longitude: position.longitude,
          locationName: _currentLocationName,
        );

        _recalculate();
        _locationStatusMessage = 'লোকেশন সফলভাবে আপডেট হয়েছে!';
        _isLoadingLocation = false;
        notifyListeners();
        return true;
      } else {
        _locationStatusMessage = 'জিপিএস সংকেত পাওয়া যায়নি। পুনরায় চেষ্টা করুন।';
        _isLoadingLocation = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _locationStatusMessage = 'লোকেশন পেতে সমস্যা হয়েছে: ${e.toString()}';
      _isLoadingLocation = false;
      notifyListeners();
      return false;
    }
  }

  /// Manually select a predefined city
  void setCity(CityLocation city) {
    _selectedCity = city;
    _currentLatitude = city.latitude;
    _currentLongitude = city.longitude;
    _currentLocationName = city.nameBangla;
    _isLiveLocation = false;
    _locationStatusMessage = null;

    StorageService.saveLiveLocationState(isLive: false);
    final index = QiblaService.defaultCities.indexOf(city);
    if (index >= 0) {
      StorageService.saveSelectedCityIndex(index);
    }

    _recalculate();
  }

  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
