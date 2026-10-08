import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';

class CityLocation {
  final String nameBangla;
  final String nameEnglish;
  final double latitude;
  final double longitude;

  const CityLocation({
    required this.nameBangla,
    required this.nameEnglish,
    required this.latitude,
    required this.longitude,
  });
}

class QiblaService {
  // Kaaba Coordinates (Makkah, Saudi Arabia)
  static const double kaabaLatitude = 21.422487;
  static const double kaabaLongitude = 39.826206;

  // List of pre-set popular cities
  static const List<CityLocation> defaultCities = [
    CityLocation(nameBangla: 'ঢাকা (Dhaka)', nameEnglish: 'Dhaka', latitude: 23.8103, longitude: 90.4125),
    CityLocation(nameBangla: 'চট্টগ্রাম (Chittagong)', nameEnglish: 'Chittagong', latitude: 22.3569, longitude: 91.7832),
    CityLocation(nameBangla: 'সিলেট (Sylhet)', nameEnglish: 'Sylhet', latitude: 24.8949, longitude: 91.8687),
    CityLocation(nameBangla: 'রাজশাহী (Rajshahi)', nameEnglish: 'Rajshahi', latitude: 24.3745, longitude: 88.6042),
    CityLocation(nameBangla: 'খুলনা (Khulna)', nameEnglish: 'Khulna', latitude: 22.8456, longitude: 89.5403),
    CityLocation(nameBangla: 'বরিশাল (Barishal)', nameEnglish: 'Barishal', latitude: 22.7010, longitude: 90.3535),
    CityLocation(nameBangla: 'রংপুর (Rangpur)', nameEnglish: 'Rangpur', latitude: 25.7439, longitude: 89.2752),
    CityLocation(nameBangla: 'ময়মনসিংহ (Mymensingh)', nameEnglish: 'Mymensingh', latitude: 24.7471, longitude: 90.4203),
    CityLocation(nameBangla: 'মদিনা (Madinah)', nameEnglish: 'Madinah', latitude: 24.5247, longitude: 39.5692),
    CityLocation(nameBangla: 'দুবাই (Dubai)', nameEnglish: 'Dubai', latitude: 25.2048, longitude: 55.2708),
    CityLocation(nameBangla: 'লন্ডন (London)', nameEnglish: 'London', latitude: 51.5074, longitude: -0.1278),
    CityLocation(nameBangla: 'নিউইয়র্ক (New York)', nameEnglish: 'New York', latitude: 40.7128, longitude: -74.0060),
    CityLocation(nameBangla: 'কুয়ালালামপুর (Kuala Lumpur)', nameEnglish: 'Kuala Lumpur', latitude: 3.1390, longitude: 101.6869),
  ];

  /// Calculates the Qibla bearing (direction from True North in degrees 0-360)
  static double calculateQiblaAngle(double latitude, double longitude) {
    final double lat1 = _degreesToRadians(latitude);
    final double lon1 = _degreesToRadians(longitude);
    final double lat2 = _degreesToRadians(kaabaLatitude);
    final double lon2 = _degreesToRadians(kaabaLongitude);

    final double dLon = lon2 - lon1;

    final double y = math.sin(dLon) * math.cos(lat2);
    final double x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    double initialBearing = math.atan2(y, x);
    initialBearing = _radiansToDegrees(initialBearing);
    final double compassBearing = (initialBearing + 360.0) % 360.0;

    return compassBearing;
  }

  /// Calculates distance to Kaaba in kilometers
  static double calculateDistanceToKaaba(double latitude, double longitude) {
    const double earthRadiusKm = 6371.0;

    final double dLat = _degreesToRadians(kaabaLatitude - latitude);
    final double dLon = _degreesToRadians(kaabaLongitude - longitude);

    final double lat1 = _degreesToRadians(latitude);
    final double lat2 = _degreesToRadians(kaabaLatitude);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.sin(dLon / 2) * math.sin(dLon / 2) * math.cos(lat1) * math.cos(lat2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadiusKm * c;
  }

  /// Stream of compass events (safely guarded for mobile platforms only)
  static Stream<CompassEvent>? get compassStream {
    if (kIsWeb) return null;
    final isMobile = defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
    if (!isMobile) return null;

    try {
      return FlutterCompass.events?.handleError((error) {
        debugPrint('Compass stream error handled safely: $error');
      });
    } catch (e) {
      return null;
    }
  }

  /// Tries to get current GPS location, falls back to default Dhaka
  static Future<Position?> getCurrentPosition() async {
    if (kIsWeb) return null;

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 5),
        ),
      );
    } catch (e) {
      debugPrint('Geolocator safe error: $e');
      return null;
    }
  }

  static double _degreesToRadians(double degrees) => degrees * (math.pi / 180.0);
  static double _radiansToDegrees(double radians) => radians * (180.0 / math.pi);

  /// Human-friendly cardinal direction label in Bengali
  static String getDirectionNameBangla(double degree) {
    if (degree >= 337.5 || degree < 22.5) return "উত্তর (North)";
    if (degree >= 22.5 && degree < 67.5) return "উত্তর-পূর্ব (NE)";
    if (degree >= 67.5 && degree < 112.5) return "পূর্ব (East)";
    if (degree >= 112.5 && degree < 157.5) return "দক্ষিণ-পূর্ব (SE)";
    if (degree >= 157.5 && degree < 202.5) return "দক্ষিণ (South)";
    if (degree >= 202.5 && degree < 247.5) return "দক্ষিণ-পশ্চিম (SW)";
    if (degree >= 247.5 && degree < 292.5) return "পশ্চিম (West)";
    return "উত্তর-পশ্চিম (NW)";
  }
}
