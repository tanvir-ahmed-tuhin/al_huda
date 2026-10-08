class UserModel {
  final String id;
  final String name;
  final String email;
  final bool isGuest;
  final int streakDays;
  final int totalAmalPoints;
  final DateTime joinedAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.isGuest = false,
    this.streakDays = 1,
    this.totalAmalPoints = 0,
    required this.joinedAt,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    bool? isGuest,
    int? streakDays,
    int? totalAmalPoints,
    DateTime? joinedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      isGuest: isGuest ?? this.isGuest,
      streakDays: streakDays ?? this.streakDays,
      totalAmalPoints: totalAmalPoints ?? this.totalAmalPoints,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      isGuest: json['isGuest'] as bool? ?? false,
      streakDays: json['streakDays'] as int? ?? 1,
      totalAmalPoints: json['totalAmalPoints'] as int? ?? 0,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'isGuest': isGuest,
      'streakDays': streakDays,
      'totalAmalPoints': totalAmalPoints,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }

  static UserModel guestUser() {
    return UserModel(
      id: 'guest_user',
      name: 'সম্মানিত অতিথি',
      email: 'guest@islamic.app',
      isGuest: true,
      streakDays: 1,
      totalAmalPoints: 50,
      joinedAt: DateTime.now(),
    );
  }
}
