class UserModel {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final bool isGuest;
  final int streakDays;
  final int totalAmalPoints;
  final DateTime joinedAt;
  final DateTime? lastLoginAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.isGuest = false,
    this.streakDays = 1,
    this.totalAmalPoints = 0,
    required this.joinedAt,
    this.lastLoginAt,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    bool? isGuest,
    int? streakDays,
    int? totalAmalPoints,
    DateTime? joinedAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      isGuest: isGuest ?? this.isGuest,
      streakDays: streakDays ?? this.streakDays,
      totalAmalPoints: totalAmalPoints ?? this.totalAmalPoints,
      joinedAt: joinedAt ?? this.joinedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic val, {DateTime? fallback}) {
      if (val == null) return fallback ?? DateTime.now();
      if (val is String) {
        return DateTime.tryParse(val) ?? fallback ?? DateTime.now();
      }
      return fallback ?? DateTime.now();
    }

    return UserModel(
      id: (json['id'] ?? json['uid'] ?? '') as String,
      name: (json['name'] ?? json['displayName'] ?? 'ব্যবহারকারী') as String,
      email: (json['email'] ?? '') as String,
      photoUrl: json['photoUrl'] as String?,
      isGuest: json['isGuest'] as bool? ?? false,
      streakDays: json['streakDays'] as int? ?? 1,
      totalAmalPoints: json['totalAmalPoints'] as int? ?? 0,
      joinedAt: parseDate(json['joinedAt']),
      lastLoginAt: json['lastLoginAt'] != null ? parseDate(json['lastLoginAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'isGuest': isGuest,
      'streakDays': streakDays,
      'totalAmalPoints': totalAmalPoints,
      'joinedAt': joinedAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'isGuest': isGuest,
      'streakDays': streakDays,
      'totalAmalPoints': totalAmalPoints,
      'joinedAt': joinedAt.toIso8601String(),
      'lastLoginAt': (lastLoginAt ?? DateTime.now()).toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  factory UserModel.fromFirestore(Map<String, dynamic> data, String uid) {
    DateTime parseDate(dynamic val, {DateTime? fallback}) {
      if (val == null) return fallback ?? DateTime.now();
      if (val is String) {
        return DateTime.tryParse(val) ?? fallback ?? DateTime.now();
      }
      return fallback ?? DateTime.now();
    }

    return UserModel(
      id: uid,
      name: (data['name'] ?? data['displayName'] ?? 'ব্যবহারকারী') as String,
      email: (data['email'] ?? '') as String,
      photoUrl: data['photoUrl'] as String?,
      isGuest: data['isGuest'] as bool? ?? false,
      streakDays: data['streakDays'] as int? ?? 1,
      totalAmalPoints: data['totalAmalPoints'] as int? ?? 0,
      joinedAt: parseDate(data['joinedAt']),
      lastLoginAt: data['lastLoginAt'] != null ? parseDate(data['lastLoginAt']) : null,
    );
  }
}
