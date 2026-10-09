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
    CityLocation(nameBangla: 'ঢাকা', nameEnglish: 'Dhaka', latitude: 23.8103, longitude: 90.4125),
    CityLocation(nameBangla: 'চট্টগ্রাম', nameEnglish: 'Chittagong', latitude: 22.3569, longitude: 91.7832),
    CityLocation(nameBangla: 'সিলেট', nameEnglish: 'Sylhet', latitude: 24.8949, longitude: 91.8687),
    CityLocation(nameBangla: 'রাজশাহী', nameEnglish: 'Rajshahi', latitude: 24.3745, longitude: 88.6042),
    CityLocation(nameBangla: 'খুলনা', nameEnglish: 'Khulna', latitude: 22.8456, longitude: 89.5403),
    CityLocation(nameBangla: 'বরিশাল', nameEnglish: 'Barishal', latitude: 22.7010, longitude: 90.3535),
    CityLocation(nameBangla: 'রংপুর', nameEnglish: 'Rangpur', latitude: 25.7439, longitude: 89.2752),
    CityLocation(nameBangla: 'ময়মনসিংহ', nameEnglish: 'Mymensingh', latitude: 24.7471, longitude: 90.4203),
    CityLocation(nameBangla: 'কুমিল্লা', nameEnglish: 'Cumilla', latitude: 23.4607, longitude: 91.1809),
    CityLocation(nameBangla: 'কক্সবাজার', nameEnglish: 'Cox\'s Bazar', latitude: 21.4272, longitude: 92.0058),
    CityLocation(nameBangla: 'বগুড়া', nameEnglish: 'Bogura', latitude: 24.8465, longitude: 89.3770),
    CityLocation(nameBangla: 'যশোর', nameEnglish: 'Jashore', latitude: 23.1664, longitude: 89.2081),
    CityLocation(nameBangla: 'দিনাজপুর', nameEnglish: 'Dinajpur', latitude: 25.6279, longitude: 88.6332),
    CityLocation(nameBangla: 'গাজীপুর', nameEnglish: 'Gazipur', latitude: 23.9999, longitude: 90.4203),
    CityLocation(nameBangla: 'নারায়ণগঞ্জ', nameEnglish: 'Narayanganj', latitude: 23.6238, longitude: 90.5000),
    CityLocation(nameBangla: 'টাঙ্গাইল', nameEnglish: 'Tangail', latitude: 24.2513, longitude: 89.9167),
    CityLocation(nameBangla: 'ফরিদপুর', nameEnglish: 'Faridpur', latitude: 23.6071, longitude: 89.8426),
    CityLocation(nameBangla: 'পাবনা', nameEnglish: 'Pabna', latitude: 24.0064, longitude: 89.2372),
    CityLocation(nameBangla: 'কুষ্টিয়া', nameEnglish: 'Kushtia', latitude: 23.9013, longitude: 89.1205),
    CityLocation(nameBangla: 'নোয়াখালী', nameEnglish: 'Noakhali', latitude: 22.8696, longitude: 91.0994),
    CityLocation(nameBangla: 'ব্রাহ্মণবাড়িয়া', nameEnglish: 'Brahmanbaria', latitude: 23.9608, longitude: 91.1115),
    CityLocation(nameBangla: 'জামালপুর', nameEnglish: 'Jamalpur', latitude: 24.9375, longitude: 89.9378),
    CityLocation(nameBangla: 'সিরাজগঞ্জ', nameEnglish: 'Sirajganj', latitude: 24.4534, longitude: 89.7008),
    CityLocation(nameBangla: 'পটুয়াখালী', nameEnglish: 'Patuakhali', latitude: 22.3596, longitude: 90.3299),
    CityLocation(nameBangla: 'ফেনী', nameEnglish: 'Feni', latitude: 23.0159, longitude: 91.3976),
    CityLocation(nameBangla: 'মৌলভীবাজার', nameEnglish: 'Moulvibazar', latitude: 24.4829, longitude: 91.7774),
    CityLocation(nameBangla: 'হবিগঞ্জ', nameEnglish: 'Habiganj', latitude: 24.3750, longitude: 91.4167),
    CityLocation(nameBangla: 'চাঁদপুর', nameEnglish: 'Chandpur', latitude: 23.2333, longitude: 90.6667),
    CityLocation(nameBangla: 'চাঁপাইনবাবগঞ্জ', nameEnglish: 'Chapai Nawabganj', latitude: 24.5965, longitude: 88.2775),
    CityLocation(nameBangla: 'পঞ্চগড়', nameEnglish: 'Panchagarh', latitude: 26.3411, longitude: 88.5542),
    CityLocation(nameBangla: 'বান্দরবান', nameEnglish: 'Bandarban', latitude: 22.1953, longitude: 92.2184),
    CityLocation(nameBangla: 'রাঙ্গামাটি', nameEnglish: 'Rangamati', latitude: 22.6533, longitude: 92.1789),
    CityLocation(nameBangla: 'ভোলা', nameEnglish: 'Bhola', latitude: 22.6859, longitude: 90.6481),
    CityLocation(nameBangla: 'নেত্রকোণা', nameEnglish: 'Netrokona', latitude: 24.8837, longitude: 90.7279),
    CityLocation(nameBangla: 'ঝিনাইদহ', nameEnglish: 'Jhenaidah', latitude: 23.5450, longitude: 89.1726),
    CityLocation(nameBangla: 'সাতক্ষীরা', nameEnglish: 'Satkhira', latitude: 22.7185, longitude: 89.0705),
    CityLocation(nameBangla: 'নওগাঁ', nameEnglish: 'Naogaon', latitude: 24.7936, longitude: 88.9318),
    CityLocation(nameBangla: 'কিশোরগঞ্জ', nameEnglish: 'Kishoreganj', latitude: 24.4449, longitude: 90.7766),
    CityLocation(nameBangla: 'নরসিংদী', nameEnglish: 'Narsingdi', latitude: 23.9193, longitude: 90.7202),
    CityLocation(nameBangla: 'মানিকগঞ্জ', nameEnglish: 'Manikganj', latitude: 23.8617, longitude: 90.0003),
  ];

  /// Finds closest registered city by geodesic distance
  static CityLocation findNearestCity(double latitude, double longitude) {
    CityLocation closest = defaultCities.first;
    double minDistance = double.infinity;
    for (final city in defaultCities) {
      final double dLat = _degreesToRadians(city.latitude - latitude);
      final double dLon = _degreesToRadians(city.longitude - longitude);
      final double lat1 = _degreesToRadians(latitude);
      final double lat2 = _degreesToRadians(city.latitude);
      final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
          math.sin(dLon / 2) * math.sin(dLon / 2) * math.cos(lat1) * math.cos(lat2);
      final double dist = 6371.0 * (2 * math.atan2(math.sqrt(a), math.sqrt(1 - a)));
      if (dist < minDistance) {
        minDistance = dist;
        closest = city;
      }
    }
    return closest;
  }

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
    if (degree >= 337.5 || degree < 22.5) return "উত্তর দিক";
    if (degree >= 22.5 && degree < 67.5) return "উত্তর-পূর্ব দিক";
    if (degree >= 67.5 && degree < 112.5) return "পূর্ব দিক";
    if (degree >= 112.5 && degree < 157.5) return "দক্ষিণ-পূর্ব দিক";
    if (degree >= 157.5 && degree < 202.5) return "দক্ষিণ দিক";
    if (degree >= 202.5 && degree < 247.5) return "দক্ষিণ-পশ্চিম দিক";
    if (degree >= 247.5 && degree < 292.5) return "পশ্চিম দিক";
    return "উত্তর-পশ্চিম দিক";
  }
}
