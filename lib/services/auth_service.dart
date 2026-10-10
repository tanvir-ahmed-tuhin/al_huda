import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _keyCurrentUser = 'current_user_profile';
  static const String _keyIsLoggedIn = 'is_logged_in_state';
  static const String _keyRegisteredUsers = 'registered_users_database';

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Track if Firestore permission-denied occurred during last sync
  static bool hadFirestorePermissionDenied = false;

  /// Collection reference for users in Firestore
  static CollectionReference get _usersCollection => _firestore.collection('users');

  /// Get currently active user (from Firebase Auth / Firestore or local session)
  static Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      try {
        final doc = await _usersCollection.doc(firebaseUser.uid).get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data() as Map<String, dynamic>;
          final user = UserModel.fromFirestore(data, firebaseUser.uid);
          await _saveSession(user);
          hadFirestorePermissionDenied = false;
          return user;
        } else {
          // Document does not exist in Firestore yet (e.g. earlier permission issue)
          // Automatically save user to Firestore now
          final prefs = await SharedPreferences.getInstance();
          final userJson = prefs.getString(_keyCurrentUser);
          UserModel user;
          if (userJson != null) {
            try {
              user = UserModel.fromJson(jsonDecode(userJson));
            } catch (_) {
              user = _buildDefaultUserModel(firebaseUser);
            }
          } else {
            user = _buildDefaultUserModel(firebaseUser);
          }
          await _usersCollection.doc(firebaseUser.uid).set(user.toFirestore(), SetOptions(merge: true));
          hadFirestorePermissionDenied = false;
          await _saveSession(user);
          debugPrint('✅ User profile successfully written to Firestore for uid: ${firebaseUser.uid}');
          return user;
        }
      } on FirebaseException catch (e) {
        debugPrint('⚠️ Firestore read/write warning: ${e.code} - ${e.message}');
        if (e.code == 'permission-denied') {
          hadFirestorePermissionDenied = true;
        }
      } catch (e) {
        debugPrint('⚠️ Firestore sync warning: $e');
      }

      // Check local cached session
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_keyCurrentUser);
      if (userJson != null) {
        try {
          return UserModel.fromJson(jsonDecode(userJson));
        } catch (_) {}
      }

      // Fallback from Firebase Auth user directly
      final fallbackUser = _buildDefaultUserModel(firebaseUser);
      await _saveSession(fallbackUser);
      return fallbackUser;
    }

    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_keyCurrentUser);
    if (userJson != null) {
      try {
        return UserModel.fromJson(jsonDecode(userJson));
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Force upload/sync current active user data to Firestore
  static Future<bool> syncCurrentUserToFirestore() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return false;
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_keyCurrentUser);
      UserModel user;
      if (userJson != null) {
        try {
          user = UserModel.fromJson(jsonDecode(userJson));
        } catch (_) {
          user = _buildDefaultUserModel(firebaseUser);
        }
      } else {
        user = _buildDefaultUserModel(firebaseUser);
      }

      await _usersCollection.doc(firebaseUser.uid).set(user.toFirestore(), SetOptions(merge: true));
      hadFirestorePermissionDenied = false;
      await _saveSession(user);
      debugPrint('✅ Explicit sync to Firestore succeeded for uid: ${firebaseUser.uid}');
      return true;
    } on FirebaseException catch (e) {
      debugPrint('⚠️ Explicit sync FirebaseException: ${e.code} - ${e.message}');
      if (e.code == 'permission-denied') {
        hadFirestorePermissionDenied = true;
      }
      return false;
    } catch (e) {
      debugPrint('⚠️ Explicit sync error: $e');
      return false;
    }
  }

  static UserModel _buildDefaultUserModel(User firebaseUser) {
    return UserModel(
      id: firebaseUser.uid,
      name: firebaseUser.displayName ?? 'ব্যবহারকারী',
      email: firebaseUser.email ?? '',
      photoUrl: firebaseUser.photoURL,
      streakDays: 1,
      totalAmalPoints: 100,
      joinedAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
  }

  static Future<bool> isLoggedIn() async {
    if (_auth.currentUser != null) return true;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  /// Sign In with Google and save user data to Firestore
  static Future<UserModel> signInWithGoogle() async {
    try {
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw 'গুগল সাইন-ইন বাতিল করা হয়েছে';
      }

      // Obtain auth details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create Firebase credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase Auth
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw 'গুগল একাউন্টে প্রবেশ করা সম্ভব হয়নি';
      }

      // Base user model from verified Firebase User
      UserModel userModel = UserModel(
        id: firebaseUser.uid,
        name: firebaseUser.displayName ?? googleUser.displayName ?? 'ব্যবহারকারী',
        email: firebaseUser.email ?? googleUser.email,
        photoUrl: firebaseUser.photoURL ?? googleUser.photoUrl,
        streakDays: 1,
        totalAmalPoints: 100, // Welcome bonus points
        joinedAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      // Attempt Firestore sync in try-catch so permission-denied does not abort user login
      hadFirestorePermissionDenied = false;
      try {
        final userDocRef = _usersCollection.doc(firebaseUser.uid);
        final docSnapshot = await userDocRef.get();

        if (docSnapshot.exists && docSnapshot.data() != null) {
          final existingData = docSnapshot.data() as Map<String, dynamic>;
          userModel = UserModel(
            id: firebaseUser.uid,
            name: firebaseUser.displayName ?? existingData['name'] ?? userModel.name,
            email: firebaseUser.email ?? existingData['email'] ?? userModel.email,
            photoUrl: firebaseUser.photoURL ?? existingData['photoUrl'] ?? userModel.photoUrl,
            streakDays: existingData['streakDays'] as int? ?? userModel.streakDays,
            totalAmalPoints: existingData['totalAmalPoints'] as int? ?? userModel.totalAmalPoints,
            joinedAt: existingData['joinedAt'] != null
                ? (DateTime.tryParse(existingData['joinedAt'].toString()) ?? DateTime.now())
                : DateTime.now(),
            lastLoginAt: DateTime.now(),
          );

          // Update Firestore with recent login time and fresh profile info
          await userDocRef.set(userModel.toFirestore(), SetOptions(merge: true));
        } else {
          // New user: Create profile in Firestore
          await userDocRef.set(userModel.toFirestore());
        }
      } on FirebaseException catch (e) {
        debugPrint('⚠️ Cloud Firestore sync error: ${e.code} - ${e.message}');
        if (e.code == 'permission-denied') {
          hadFirestorePermissionDenied = true;
        }
      } catch (e) {
        debugPrint('⚠️ Firestore sync warning: $e');
      }

      // Save local session so user is logged in
      await _saveSession(userModel);
      return userModel;
    } on FirebaseAuthException catch (e) {
      String message = 'গুগল সাইন-ইন ব্যর্থ হয়েছে।';
      if (e.code == 'account-exists-with-different-credential') {
        message = 'এই ইমেইল দিয়ে অন্য মাধ্যমে পূর্বে একাউন্ট তৈরি করা আছে।';
      } else if (e.code == 'network-request-failed') {
        message = 'ইন্টারনেট সংযোগ চেক করুন।';
      } else if (e.message != null && e.message!.isNotEmpty) {
        message = e.message!;
      }
      throw message;
    } catch (e) {
      if (e is String) rethrow;
      throw 'সাইন-ইন করার সময় সমস্যা হয়েছে: ${e.toString()}';
    }
  }

  /// Update user streak or points in Firestore
  static Future<void> syncAmalStats({
    required String uid,
    int? streakDays,
    int? totalAmalPoints,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': DateTime.now().toIso8601String(),
      };
      if (streakDays != null) updates['streakDays'] = streakDays;
      if (totalAmalPoints != null) updates['totalAmalPoints'] = totalAmalPoints;

      await _usersCollection.doc(uid).set(updates, SetOptions(merge: true));

      final currentUser = await getCurrentUser();
      if (currentUser != null && currentUser.id == uid) {
        final updatedUser = currentUser.copyWith(
          streakDays: streakDays ?? currentUser.streakDays,
          totalAmalPoints: totalAmalPoints ?? currentUser.totalAmalPoints,
        );
        await _saveSession(updatedUser);
      }
    } catch (_) {
      // Silently ignore or queue sync
    }
  }

  static Future<UserModel> login({required String email, required String password}) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      final fUser = userCredential.user;
      if (fUser != null) {
        final doc = await _usersCollection.doc(fUser.uid).get();
        UserModel user;
        if (doc.exists && doc.data() != null) {
          user = UserModel.fromFirestore(doc.data() as Map<String, dynamic>, fUser.uid);
        } else {
          user = UserModel(
            id: fUser.uid,
            name: fUser.displayName ?? email.split('@')[0],
            email: fUser.email ?? email,
            streakDays: 1,
            totalAmalPoints: 50,
            joinedAt: DateTime.now(),
            lastLoginAt: DateTime.now(),
          );
          await _usersCollection.doc(fUser.uid).set(user.toFirestore());
        }
        await _saveSession(user);
        return user;
      }
    } catch (_) {
      // Fallback to local storage if offline or Firebase Auth fails
    }

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
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      final fUser = userCredential.user;
      if (fUser != null) {
        await fUser.updateDisplayName(name.trim());
        final newUser = UserModel(
          id: fUser.uid,
          name: name.trim(),
          email: fUser.email ?? email,
          streakDays: 1,
          totalAmalPoints: 100,
          joinedAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
        await _usersCollection.doc(fUser.uid).set(newUser.toFirestore());
        await _saveSession(newUser);
        return newUser;
      }
    } catch (_) {
      // Fallback to local storage if offline
    }

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
      totalAmalPoints: 100,
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

  static Future<void> updateUser(UserModel user) async {
    await _saveSession(user);
    try {
      await _usersCollection.doc(user.id).set(user.toFirestore(), SetOptions(merge: true));
    } catch (_) {}
  }

  static Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (_) {}
    try {
      await _googleSignIn.signOut();
    } catch (_) {}

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
