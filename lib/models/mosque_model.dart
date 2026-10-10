import 'dart:math';

class MosqueModel {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double distanceMeters;
  final String direction;
  final String type;
  final bool hasWudu;
  final bool hasFemalePrayerSpace;
  final bool isJamahAvailable;
  final bool isHistorical;
  final String? description;

  const MosqueModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.distanceMeters,
    required this.direction,
    this.type = 'জামে মসজিদ',
    this.hasWudu = true,
    this.hasFemalePrayerSpace = false,
    this.isJamahAvailable = true,
    this.isHistorical = false,
    this.description,
  });

  MosqueModel copyWith({
    double? distanceMeters,
    String? direction,
  }) {
    return MosqueModel(
      id: id,
      name: name,
      address: address,
      latitude: latitude,
      longitude: longitude,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      direction: direction ?? this.direction,
      type: type,
      hasWudu: hasWudu,
      hasFemalePrayerSpace: hasFemalePrayerSpace,
      isJamahAvailable: isJamahAvailable,
      isHistorical: isHistorical,
      description: description,
    );
  }

  static String toBnDigits(String input) {
    const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const bn = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    var result = input;
    for (int i = 0; i < en.length; i++) {
      result = result.replaceAll(en[i], bn[i]);
    }
    return result;
  }

  String get formattedDistance {
    if (distanceMeters < 1000) {
      return '${toBnDigits(distanceMeters.round().toString())} মিটার';
    } else {
      final km = (distanceMeters / 1000).toStringAsFixed(1);
      return '${toBnDigits(km)} কি.মি.';
    }
  }

  String get formattedWalkTime {
    // Average walking speed ~ 4.8 km/h (~80m/min)
    final minutes = max(1, (distanceMeters / 80).round());
    if (minutes > 60) {
      final hours = (minutes / 60).toStringAsFixed(1);
      return '${toBnDigits(hours)} ঘণ্টা হাঁটা';
    }
    return '${toBnDigits(minutes.toString())} মিনিট হাঁটা';
  }

  String get formattedDriveTime {
    // City drive speed ~ 24 km/h (~400m/min)
    final minutes = max(1, (distanceMeters / 400).round());
    if (minutes > 60) {
      final hours = (minutes / 60).toStringAsFixed(1);
      return '${toBnDigits(hours)} ঘণ্টা ড্রাইভ';
    }
    return '${toBnDigits(minutes.toString())} মিনিট ড্রাইভ';
  }

  factory MosqueModel.fromOsmJson(Map<String, dynamic> json, {double userLat = 0, double userLon = 0}) {
    final lat = double.tryParse(json['lat']?.toString() ?? '0') ?? 0;
    final lon = double.tryParse(json['lon']?.toString() ?? '0') ?? 0;

    String rawName = json['name']?.toString() ?? '';
    final displayName = json['display_name']?.toString() ?? '';

    if (rawName.isEmpty || rawName.toLowerCase() == 'mosque' || rawName.toLowerCase() == 'masjid') {
      final parts = displayName.split(',');
      if (parts.isNotEmpty && parts.first.trim().isNotEmpty && parts.first.trim().toLowerCase() != 'mosque') {
        rawName = parts.first.trim();
      } else if (parts.length > 1) {
        rawName = '${parts[1].trim()} জামে মসজিদ';
      } else {
        rawName = 'কাছের জামে মসজিদ';
      }
    }

    // Clean address
    final addressParts = displayName.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    final address = addressParts.length > 1 ? addressParts.take(3).join(', ') : displayName;

    return MosqueModel(
      id: json['place_id']?.toString() ?? '${lat}_$lon',
      name: rawName,
      address: address.isNotEmpty ? address : 'নিকটবর্তী এলাকা',
      latitude: lat,
      longitude: lon,
      distanceMeters: 0,
      direction: 'উত্তর',
      type: 'জামে মসজিদ',
      hasWudu: true,
      hasFemalePrayerSpace: false,
      isJamahAvailable: true,
      isHistorical: false,
    );
  }
}
