import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:al_quran_app/services/auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AuthService Tests', () {
    test('Can register a new user successfully', () async {
      final user = await AuthService.register(
        name: 'আব্দুল্লাহ',
        email: 'abdullah@test.com',
        password: 'password123',
      );

      expect(user.name, 'আব্দুল্লাহ');
      expect(user.email, 'abdullah@test.com');
      expect(user.totalAmalPoints, 100); // bonus points
      expect(user.isGuest, false);

      final current = await AuthService.getCurrentUser();
      expect(current?.email, 'abdullah@test.com');
    });

    test('Prevents duplicate email registration', () async {
      await AuthService.register(
        name: 'আব্দুল্লাহ',
        email: 'duplicate@test.com',
        password: 'password123',
      );

      expect(
        () => AuthService.register(
          name: 'আরেকজন',
          email: 'duplicate@test.com',
          password: 'newpassword',
        ),
        throwsA(contains('ইতোমধ্যে একটি একাউন্ট')),
      );
    });

    test('Can continue as guest', () async {
      final guest = await AuthService.continueAsGuest();
      expect(guest.isGuest, true);
      expect(guest.name, 'সম্মানিত অতিথি');

      final isLoggedIn = await AuthService.isLoggedIn();
      expect(isLoggedIn, true);
    });

    test('Can logout', () async {
      await AuthService.continueAsGuest();
      await AuthService.logout();

      final current = await AuthService.getCurrentUser();
      expect(current, isNull);
      final isLoggedIn = await AuthService.isLoggedIn();
      expect(isLoggedIn, false);
    });
  });
}
