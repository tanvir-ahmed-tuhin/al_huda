import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _keyCurrentUser = 'current_user_profile';
  static const String _keyIsLoggedIn = 'is_logged_in_state';
  static const String _keyRegisteredUsers = 'registered_users_database';

  static Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_keyCurrentUser);
    if (userJson != null) {
      return UserModel.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  static Future<UserModel> login({required String email, required String password}) async {
    final prefs = await SharedPreferences.getInstance();
    final usersRaw = prefs.getStringList(_keyRegisteredUsers) ?? [];

    for (final uStr in usersRaw) {
      final uMap = jsonDecode(uStr) as Map<String, dynamic>;
      if (uMap['email'] == email.trim().toLowerCase()) {
        if (uMap['password'] == password) {
          final user = UserModel(
            id: uMap['id'] as String,
            name: uMap['name'] as String,
            email: uMap['email'] as String,
            streakDays: uMap['streakDays'] as int? ?? 1,
            totalAmalPoints: uMap['totalAmalPoints'] as int? ?? 0,
            joinedAt: DateTime.parse(uMap['joinedAt'] as String),
          );
          await _saveSession(user);
          return user;
        } else {
          throw 'ভুল পাসওয়ার্ড। দয়া করে সঠিক পাসওয়ার্ড দিন।';
        }
      }
    }

    // If not registered yet, auto-create account for seamless user experience
    final newUser = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: email.split('@')[0],
      email: email.trim().toLowerCase(),
      streakDays: 1,
      totalAmalPoints: 50,
      joinedAt: DateTime.now(),
    );

    final newUserData = {
      ...newUser.toJson(),
      'password': password,
    };
    usersRaw.add(jsonEncode(newUserData));
    await prefs.setStringList(_keyRegisteredUsers, usersRaw);
    await _saveSession(newUser);
    return newUser;
  }

  static Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final usersRaw = prefs.getStringList(_keyRegisteredUsers) ?? [];

    for (final uStr in usersRaw) {
      final uMap = jsonDecode(uStr) as Map<String, dynamic>;
      if (uMap['email'] == email.trim().toLowerCase()) {
        throw 'এই ইমেইল দিয়ে ইতোমধ্যে একটি একাউন্ট খোলা আছে।';
      }
    }

    final newUser = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      email: email.trim().toLowerCase(),
      streakDays: 1,
      totalAmalPoints: 100, // Welcome bonus points
      joinedAt: DateTime.now(),
    );

    final newUserData = {
      ...newUser.toJson(),
      'password': password,
    };
    usersRaw.add(jsonEncode(newUserData));
    await prefs.setStringList(_keyRegisteredUsers, usersRaw);
    await _saveSession(newUser);
    return newUser;
  }

  static Future<UserModel> continueAsGuest() async {
    final guest = UserModel.guestUser();
    await _saveSession(guest);
    return guest;
  }

  static Future<void> updateUser(UserModel user) async {
    await _saveSession(user);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCurrentUser);
    await prefs.setBool(_keyIsLoggedIn, false);
  }

  static Future<void> _saveSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCurrentUser, jsonEncode(user.toJson()));
    await prefs.setBool(_keyIsLoggedIn, true);
  }
}
