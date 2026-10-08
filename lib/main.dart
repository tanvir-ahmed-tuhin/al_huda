import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
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
  await StorageService.init();
  await IslamicNotificationService.init();

// Set preferred system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const AlQuranApp());
}

class AlQuranApp extends StatelessWidget {
  const AlQuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
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
