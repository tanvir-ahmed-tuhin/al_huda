import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/azan_provider.dart';
import 'providers/islamic_events_provider.dart';
import 'providers/prayer_provider.dart';
import 'providers/qibla_provider.dart';
import 'providers/quran_provider.dart';
import 'providers/tasbih_provider.dart';
import 'providers/task_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'services/islamic_notification_service.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('DEBUG: main() started');

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  await StorageService.init();
  debugPrint('DEBUG: StorageService.init finished');

  // Launch UI immediately so the first frame renders without blocking
  runApp(const AlQuranApp());
  debugPrint('DEBUG: runApp executed');

  // Initialize notifications asynchronously in the background
  IslamicNotificationService.init().catchError((e) {
    debugPrint('Error in IslamicNotificationService.init: $e');
  });
}

class AlQuranApp extends StatelessWidget {
  const AlQuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => QuranProvider()),
        ChangeNotifierProvider(create: (_) => QiblaProvider()),
        ChangeNotifierProvider(create: (_) => PrayerProvider()),
        ChangeNotifierProvider(create: (_) => AzanProvider()),
        ChangeNotifierProvider(create: (_) => TasbihProvider()),
        ChangeNotifierProvider(create: (_) => IslamicEventsProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          final isDark = themeProvider.isDarkMode;

          // Dynamically synchronize status bar and navigation bar with current theme
          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
              statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
              systemNavigationBarColor: isDark ? AppColors.darkBg : AppColors.lightBg,
              systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            ),
          );

          return MaterialApp(
            navigatorKey: AzanProvider.navigatorKey,
            title: 'Al-Huda',
            debugShowCheckedModeBanner: false,

// Hind Siliguri Font
            theme: AppTheme.lightTheme.copyWith(
              textTheme: GoogleFonts.hindSiliguriTextTheme(
                AppTheme.lightTheme.textTheme,
              ),
            ),

            darkTheme: AppTheme.darkTheme.copyWith(
              textTheme: GoogleFonts.hindSiliguriTextTheme(
                AppTheme.darkTheme.textTheme,
              ),
            ),

            themeMode: themeProvider.themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
