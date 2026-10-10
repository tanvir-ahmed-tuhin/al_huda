import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/prayer_provider.dart';
import '../providers/quran_provider.dart';
import '../providers/theme_provider.dart';
import '../models/prayer_time_model.dart';
import '../services/prayer_service.dart';
import '../services/qibla_service.dart';
import '../services/quran_data_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/upcoming_islamic_event_card.dart';
import 'allah_names/allah_names_screen.dart';
import 'duas/duas_screen.dart';
import 'hadith/hadith_screen.dart';
import 'islamic_events/islamic_events_screen.dart';
import 'mosque/nearby_mosques_screen.dart';
import 'prayer_times/azan_settings_screen.dart';
import 'prayer_times/prayer_times_screen.dart';
import 'profile/profile_screen.dart';
import 'quran/surah_detail_screen.dart';
import 'tasks/daily_tasks_screen.dart';
import 'tasbih/tasbih_screen.dart';
import 'zakat/zakat_calculator_screen.dart';

class HomeScreen extends StatelessWidget {
  final Function(int) onNavigateTab;

  const HomeScreen({super.key, required this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            final prayerProvider = Provider.of<PrayerProvider>(context, listen: false);
            if (prayerProvider.isLiveLocation) {
              await prayerProvider.fetchLiveLocation(requestPermission: false);
            } else {
              await Future.delayed(const Duration(milliseconds: 400));
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top App Bar / Header
                _buildHeader(context, isDark),
                const SizedBox(height: 16),

                // Next Prayer Countdown Hero Card
                _buildPrayerHeroCard(context, isDark),
                const SizedBox(height: 16),

                // Upcoming Islamic Special Day & Amals Advance Alert Card
                const UpcomingIslamicEventCard(),
                const SizedBox(height: 16),

                // Quick Navigation Grid
                _buildQuickActionGrid(context, isDark),
                const SizedBox(height: 18),

                // Last Read Resume Card
                _buildLastReadCard(context, isDark),
                const SizedBox(height: 18),

                // Popular Surahs Quick Access
                _buildPopularSurahs(context, isDark),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLocationSettingsDialog(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Consumer<PrayerProvider>(
          builder: (context, prayerProvider, _) {
            final isLive = prayerProvider.isLiveLocation;
            final isLoading = prayerProvider.isLoadingLocation;
            final statusMsg = prayerProvider.locationStatusMessage;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, -4)),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'লোকেশন ও নামাজের সময়',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Current Status Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isLive
                            ? const Color(0xFF10B981).withValues(alpha: 0.12)
                            : AppColors.accentGold.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isLive ? const Color(0xFF10B981) : AppColors.accentGold,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isLive ? IconlyBold.location : IconlyLight.location,
                            color: isLive ? const Color(0xFF10B981) : AppColors.accentGold,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  prayerProvider.currentLocationName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'অক্ষাংশ: ${PrayerService.toBanglaDigits(prayerProvider.currentLatitude.toStringAsFixed(4))}° | দ্রাঘিমাংশ: ${PrayerService.toBanglaDigits(prayerProvider.currentLongitude.toStringAsFixed(4))}°',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (statusMsg != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          statusMsg,
                          style: const TextStyle(fontSize: 12, color: Colors.orange),
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    // Live Location Action Button
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: isLoading
                          ? null
                          : () async {
                              final success = await prayerProvider.fetchLiveLocation(requestPermission: true);
                              if (!context.mounted) return;
                              if (!success && prayerProvider.locationStatusMessage != null) {
                                if (prayerProvider.locationStatusMessage!.contains('GPS')) {
                                  await prayerProvider.openLocationSettings();
                                } else if (prayerProvider.locationStatusMessage!.contains('সেটিংসে')) {
                                  await prayerProvider.openAppSettings();
                                }
                              }
                            },
                      icon: isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(IconlyBold.location, size: 20),
                      label: Text(
                        isLoading
                            ? 'GPS লোকেশন সনাক্ত করা হচ্ছে...'
                            : 'GPS লোকেশন সনাক্ত করুন',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text(
                      'অথবা বাংলাদেশের যেকোনো জেলা বেছে নিন:',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    const SizedBox(height: 10),
                    // Quick City Grid / Wrap
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 180),
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: QiblaService.defaultCities.map((city) {
                            final isSelected = !isLive && prayerProvider.selectedCity.nameEnglish == city.nameEnglish;
                            return ChoiceChip(
                              label: Text(city.nameBangla, style: const TextStyle(fontSize: 12)),
                              selected: isSelected,
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              onSelected: (_) {
                                prayerProvider.setCity(city);
                                Navigator.pop(ctx);
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    final prayerProvider = Provider.of<PrayerProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final prayerTimes = prayerProvider.prayerTimes;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _showLocationSettingsDialog(context, isDark),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        prayerProvider.isLiveLocation
                            ? IconlyBold.location
                            : IconlyLight.location,
                        color: prayerProvider.isLiveLocation
                            ? const Color(0xFF10B981)
                            : AppColors.accentGold,
                        size: 18,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          prayerProvider.locationShortName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        IconlyLight.arrowDown2,
                        size: 12,
                        color: AppColors.accentGold,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    prayerTimes?.hijriDate ?? 'পবিত্র কুরআন ও নামাজ',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ),
        ),

        // Dark/Light Mode Switcher & Profile Chip
        Row(
          children: [
            IconButton(
              icon: Icon(
                themeProvider.isDarkMode
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                color: AppColors.accentGold,
              ),
              onPressed: () => themeProvider.toggleTheme(),
              tooltip: themeProvider.isDarkMode ? 'লাইট মোড' : 'ডার্ক মোড',
            ),
            const SizedBox(width: 4),
            Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                final user = authProvider.currentUser;
                final isAuth = authProvider.isAuthenticated;
                return InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isAuth && user?.photoUrl != null && user!.photoUrl!.isNotEmpty)
                          ClipOval(
                            child: Image.network(
                              user.photoUrl!,
                              width: 18,
                              height: 18,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                IconlyBold.profile,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          )
                        else
                          const Icon(
                            IconlyBold.profile,
                            size: 18,
                            color: Colors.white,
                          ),
                        const SizedBox(width: 5),
                        Text(
                          isAuth
                              ? (user?.name.split(' ').first ?? 'প্রোফাইল')
                              : 'প্রোফাইল',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPrayerHeroCard(BuildContext context, bool isDark) {
    return Consumer<PrayerProvider>(
      builder: (context, prayerProvider, child) {
        final pt = prayerProvider.prayerTimes;
        if (pt == null) return const SizedBox.shrink();

        final nextPrayer = pt.currentOrNextPrayer;
        final nextPrayerName = PrayerTimeModel.getPrayerNameBangla(nextPrayer);
        final nextPrayerTime = PrayerService.formatTimeOfDayBangla(
          pt.getTimeForPrayer(nextPrayer),
        );
        final duration = pt.timeUntilNextPrayer;
        final totalSeconds = duration.isNegative ? 0 : duration.inSeconds;
        final hours = totalSeconds ~/ 3600;
        final minutes = (totalSeconds % 3600) ~/ 60;
        final seconds = totalSeconds % 60;

        final String timeRemainingStr;
        if (hours > 0) {
          timeRemainingStr =
              '${PrayerService.toBanglaDigits(hours.toString())} ঘণ্টা ${PrayerService.toBanglaDigits(minutes.toString())} মি. ${PrayerService.toBanglaDigits(seconds.toString().padLeft(2, '0'))} সে. বাকি';
        } else if (minutes > 0) {
          timeRemainingStr =
              '${PrayerService.toBanglaDigits(minutes.toString())} মিনিট ${PrayerService.toBanglaDigits(seconds.toString().padLeft(2, '0'))} সেকেন্ড বাকি';
        } else {
          timeRemainingStr =
              '${PrayerService.toBanglaDigits(seconds.toString())} সেকেন্ড বাকি';
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0F5132), Color(0xFF082F1D)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F5132).withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(
              color: AppColors.accentGold.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5),
                        width: 0.8,
                      ),
                    ),
                    child: const Text(
                      'পরবর্তী নামাজ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Icon(
                    IconlyBold.timeCircle,
                    color: AppColors.accentGold,
                    size: 26,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nextPrayerName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        nextPrayerTime,
                        style: const TextStyle(
                          color: AppColors.goldLight,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        timeRemainingStr,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActionGrid(BuildContext context, bool isDark) {
    final actions = [
      {
        'title': 'আল-কুরআন',
        'icon': FlutterIslamicIcons.quran2,
        'tabIndex': 1,
        'isComingSoon': false,
      },
      {
        'title': 'ক্বিবলা',
        'icon': FlutterIslamicIcons.qibla2,
        'tabIndex': 2,
        'isComingSoon': false,
      },
      {
        'title': 'তসবিহ',
        'icon': FlutterIslamicIcons.tasbih2,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TasbihScreen())),
        'isComingSoon': false,
      },
      {
        'title': 'নামাজ সূচি',
        'icon': FlutterIslamicIcons.prayer,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrayerTimesScreen())),
        'isComingSoon': false,
      },
      {
        'title': 'দোয়া সমূহ',
        'icon': FlutterIslamicIcons.prayingPerson,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DuasScreen())),
        'isComingSoon': false,
      },
      {
        'title': 'আল্লাহর নাম',
        'icon': FlutterIslamicIcons.allah99,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AllahNamesScreen())),
        'isComingSoon': false,
      },
      {
        'title': 'বিশেষ দিন',
        'icon': FlutterIslamicIcons.calendar,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const IslamicEventsScreen())),
        'isComingSoon': false,
      },
      {
        'title': 'আযান সুর',
        'icon': FlutterIslamicIcons.solidMinaret,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AzanSettingsScreen())),
        'isComingSoon': false,
      },
      // Coming Soon New Services
      {
        'title': 'হাদিস শরিফ',
        'icon': FlutterIslamicIcons.solidMohammad,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HadithScreen())),
        'isComingSoon': false,
      },
      {
        'title': 'যাকাত হিসাব',
        'icon': FlutterIslamicIcons.zakat,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ZakatCalculatorScreen())),
        'isComingSoon': false,
      },
      {
        'title': 'কাছের মসজিদ',
        'icon': FlutterIslamicIcons.locationMosque,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NearbyMosquesScreen())),
        'isComingSoon': false,
      },
      {
        'title': 'মাকবুল আমল',
        'icon': FlutterIslamicIcons.sajadah,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DailyTasksScreen())),
        'isComingSoon': false,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'দ্রুত সেবা সমূহ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.accentGold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'সব অপশন',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentGold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 12,
            childAspectRatio: 0.82,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final item = actions[index];
            final isComingSoon = item['isComingSoon'] as bool? ?? false;
            final title = item['title'] as String;

            // Consistent minimal styling matching profile theme:
            // Dark mode: AppColors.accentGold / primary tint
            // Light mode: AppColors.primary / emerald with gold border
            final iconColor = isComingSoon
                ? (isDark ? Colors.white38 : Colors.black38)
                : (isDark ? AppColors.accentGold : AppColors.primary);

            final containerBg = isComingSoon
                ? (isDark ? AppColors.darkCard : const Color(0xFFF1F5F2))
                : (isDark ? AppColors.darkCardElevated : AppColors.lightCard);

            final borderColor = isComingSoon
                ? (isDark ? AppColors.darkBorder : Colors.black12)
                : (isDark ? AppColors.accentGold.withValues(alpha: 0.3) : AppColors.primary.withValues(alpha: 0.2));

            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                if (isComingSoon) {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(IconlyBold.timeCircle, color: AppColors.accentGold, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '$title ফিচারটি শীঘ্রই আসছে (Coming Soon)!',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                } else if (item['tabIndex'] != null) {
                  onNavigateTab(item['tabIndex'] as int);
                } else if (item['onTap'] != null) {
                  (item['onTap'] as VoidCallback)();
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: containerBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: borderColor,
                            width: 1,
                          ),
                          boxShadow: isComingSoon
                              ? null
                              : [
                                  BoxShadow(
                                    color: isDark
                                        ? Colors.black.withValues(alpha: 0.25)
                                        : AppColors.primary.withValues(alpha: 0.08),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                        ),
                        child: Icon(
                          item['icon'] as IconData,
                          color: iconColor,
                          size: 25,
                        ),
                      ),
                      if (isComingSoon)
                        Positioned(
                          top: -6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF374151) : const Color(0xFF64748B),
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 3,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: const Text(
                              'শীঘ্রই আসছে',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: isComingSoon ? FontWeight.normal : FontWeight.w600,
                      color: isComingSoon
                          ? (isDark ? Colors.white38 : Colors.black45)
                          : (isDark ? Colors.white : AppColors.lightTextPrimary),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLastReadCard(BuildContext context, bool isDark) {
    return Consumer<QuranProvider>(
      builder: (context, quranProvider, child) {
        final lastRead = quranProvider.lastRead;
        final surahNumber = lastRead['surahNumber'] as int;
        final ayahNumber = lastRead['ayahNumber'] as int;
        final surahName = lastRead['surahNameBangla'] as String;

        return IslamicCard(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF1E3A2B), const Color(0xFF132A1E)]
                : [const Color(0xFFE8F5EE), const Color(0xFFD7ECE0)],
          ),
          borderColor: AppColors.accentGold.withValues(alpha: 0.5),
          onTap: () {
            final surah = QuranDataService.surahList.firstWhere(
              (s) => s.number == surahNumber,
              orElse: () => QuranDataService.surahList[0],
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SurahDetailScreen(surah: surah),
              ),
            );
          },
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
                child: const Icon(
                  IconlyBold.bookmark,
                  color: AppColors.accentGold,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'সর্বশেষ পঠিত আয়াত',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.accentGold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'সূরা $surahName • আয়াত ${PrayerService.toBanglaDigits(ayahNumber.toString())}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                IconlyLight.arrowRight2,
                size: 16,
                color: AppColors.accentGold,
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _buildPopularSurahs(BuildContext context, bool isDark) {
    final popularSurahNumbers = [36, 55, 67, 18, 56, 112];
    final popularSurahs = QuranDataService.surahList
        .where((s) => popularSurahNumbers.contains(s.number))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'জনপ্রিয় সূরাসমূহ',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => onNavigateTab(1),
              child: const Row(
                children: [
                  Text(
                    'সব সূরা',
                    style: TextStyle(color: AppColors.accentGold),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    IconlyLight.arrowRight,
                    size: 16,
                    color: AppColors.accentGold,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: popularSurahs.length,
            itemBuilder: (context, index) {
              final surah = popularSurahs[index];

              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 12),
                child: IslamicCard(
                  padding: const EdgeInsets.all(12),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SurahDetailScreen(surah: surah),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accentGold.withValues(
                                alpha: 0.2,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              PrayerService.toBanglaDigits(
                                surah.number.toString(),
                              ),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.accentGold,
                              ),
                            ),
                          ),
                          Flexible(
                            child: Text(
                              surah.nameArabic,
                              style: AppTheme.arabicText(fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            surah.nameBangla,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${PrayerService.toBanglaDigits(surah.numberOfAyahs.toString())} আয়াত',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
