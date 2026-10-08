import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import '../services/qibla_service.dart';
import '../services/storage_service.dart';

class QiblaProvider extends ChangeNotifier {
  StreamSubscription<CompassEvent>? _compassSubscription;

  double _deviceHeading = 0.0;
  double _qiblaAngle = 0.0;
  double _distanceToKaabaKm = 0.0;
  bool _hasCompassSensor = true;
  bool _isLoadingLocation = false;

  CityLocation _selectedCity = QiblaService.defaultCities[0];
  List<CityLocation> get cities => QiblaService.defaultCities;

  // Getters
  double get deviceHeading => _deviceHeading;
  double get qiblaAngle => _qiblaAngle;
  double get distanceToKaabaKm => _distanceToKaabaKm;
  bool get hasCompassSensor => _hasCompassSensor;
  bool get isLoadingLocation => _isLoadingLocation;
  CityLocation get selectedCity => _selectedCity;

  /// The angle between the top of phone and the Kaaba direction.
  /// (Qibla angle - Device heading)
  double get qiblaOffset {
    double offset = _qiblaAngle - _deviceHeading;
    while (offset < -180) {
      offset += 360;
    }
    while (offset > 180) {
      offset -= 360;
    }
    return offset;
  }

  /// Whether phone is pointed directly towards Kaaba within ±3 degrees
  bool get isFacingQibla => qiblaOffset.abs() <= 3.5;

  QiblaProvider() {
    _init();
  }

  Future<void> _init() async {
    final cityIndex = StorageService.getSelectedCityIndex();
    if (cityIndex >= 0 && cityIndex < QiblaService.defaultCities.length) {
      _selectedCity = QiblaService.defaultCities[cityIndex];
    }

    _calculateAngles();
    _startCompass();
  }

  void _startCompass() {
    try {
      final stream = QiblaService.compassStream;
      if (stream != null) {
        _compassSubscription = stream.listen(
          (CompassEvent event) {
            if (event.heading != null) {
              _deviceHeading = event.heading!;
              _hasCompassSensor = true;
              notifyListeners();
            }
          },
          onError: (e) {
            _hasCompassSensor = false;
            notifyListeners();
          },
        );
      } else {
        _hasCompassSensor = false;
        notifyListeners();
      }
    } catch (e) {
      _hasCompassSensor = false;
      notifyListeners();
    }
  }

  void _calculateAngles() {
    _qiblaAngle = QiblaService.calculateQiblaAngle(
      _selectedCity.latitude,
      _selectedCity.longitude,
    );
    _distanceToKaabaKm = QiblaService.calculateDistanceToKaaba(
      _selectedCity.latitude,
      _selectedCity.longitude,
    );
    notifyListeners();
  }

  Future<void> selectCity(CityLocation city) async {
    _selectedCity = city;
    final index = QiblaService.defaultCities.indexOf(city);
    if (index >= 0) {
      await StorageService.saveSelectedCityIndex(index);
    }
    _calculateAngles();
  }

  Future<void> fetchCurrentGpsLocation() async {
    _isLoadingLocation = true;
    notifyListeners();

    try {
      final position = await QiblaService.getCurrentPosition();
      if (position != null) {
        _selectedCity = CityLocation(
          nameBangla: 'আমার বর্তমান অবস্থান',
          nameEnglish: 'Current Location',
          latitude: position.latitude,
          longitude: position.longitude,
        );
        _calculateAngles();
      }
    } catch (e) {
      // Keep selected city on failure
    } finally {
      _isLoadingLocation = false;
      notifyListeners();
    }
  }

  /// For testing on desktop / web or devices without compass:
  void setManualHeading(double heading) {
    _deviceHeading = (heading + 360) % 360;
    notifyListeners();
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    super.dispose();
  }
}
