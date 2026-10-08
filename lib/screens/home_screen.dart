import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/azan_provider.dart';
import '../providers/prayer_provider.dart';
import '../providers/quran_provider.dart';
import '../providers/theme_provider.dart';
import '../models/prayer_time_model.dart';
import '../services/prayer_service.dart';
import '../services/quran_data_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/upcoming_islamic_event_card.dart';
import 'prayer_times/azan_settings_screen.dart';
import 'profile/profile_screen.dart';
import 'quran/surah_detail_screen.dart';

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
            // Trigger refresh
            await Future.delayed(const Duration(milliseconds: 500));
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

                // Ayah of the Day
                _buildAyahOfTheDay(context, isDark),
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

  Widget _buildHeader(BuildContext context, bool isDark) {
    final prayerProvider = Provider.of<PrayerProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final prayerTimes = prayerProvider.prayerTimes;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  color: AppColors.accentGold,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  prayerProvider.selectedCity.nameBangla,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
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
            ),
          ],
        ),

        // Dark/Light Mode Switcher & Profile Chip
        Row(
          children: [
            IconButton(
              icon: Icon(
                themeProvider.isDarkMode
                    ? Icons.wb_sunny_rounded
                    : Icons.nightlight_round,
                color: AppColors.accentGold,
              ),
              onPressed: () => themeProvider.toggleTheme(),
              tooltip: themeProvider.isDarkMode ? 'লাইট মোড' : 'ডার্ক মোড',
            ),
            const SizedBox(width: 4),
            InkWell(
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
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.accentGold.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.account_circle_rounded,
                      size: 16,
                      color: AppColors.accentGold,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accentGold,
                      ),
                    ),
                  ],
                ),
              ),
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
        final hours = duration.inHours;
        final minutes = duration.inMinutes % 60;
        final timeRemainingStr = hours > 0
            ? '${PrayerService.toBanglaDigits(hours.toString())} ঘণ্টা ${PrayerService.toBanglaDigits(minutes.toString())} মিনিট বাকি'
            : '${PrayerService.toBanglaDigits(minutes.toString())} মিনিট বাকি';

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
                      color: AppColors.accentGold.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.accentGold,
                        width: 0.8,
                      ),
                    ),
                    child: const Text(
                      'পরবর্তী নামাজ',
                      style: TextStyle(
                        color: AppColors.goldLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.mosque_rounded,
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
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
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Consumer<AzanProvider>(
                builder: (context, azanProvider, _) {
                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AzanSettingsScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.accentGold.withValues(alpha: 0.35),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.campaign_rounded,
                                size: 16,
                                color: AppColors.accentGold,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'আযান কণ্ঠ: ${azanProvider.selectedVoice.muadhin}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          const Row(
                            children: [
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 10,
                                color: AppColors.goldLight,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
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
        'subtitle': '১১৪টি সূরা',
        'icon': Icons.menu_book_rounded,
        'tabIndex': 1,
        'color': const Color(0xFF10B981),
      },
      {
        'title': 'ক্বিবলা কম্পাস',
        'subtitle': 'সঠিক দিক',
        'icon': Icons.explore_rounded,
        'tabIndex': 2,
        'color': AppColors.accentGold,
      },
      {
        'title': 'ডিজিটাল তসবিহ',
        'subtitle': 'যিকির গণনা',
        'icon': Icons.radio_button_checked_rounded,
        'tabIndex': 3,
        'color': const Color(0xFF6366F1),
      },
      {
        'title': 'নামাজের সময়',
        'subtitle': 'আজকের সূচি',
        'icon': Icons.access_time_filled_rounded,
        'tabIndex': 4,
        'color': const Color(0xFFF59E0B),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final item = actions[index];
        final iconColor = item['color'] as Color;

        return IslamicCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          onTap: () {
            final tab = item['tabIndex'] as int;
            onNavigateTab(tab);
          },
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item['icon'] as IconData,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item['title'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item['subtitle'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
                  Icons.bookmark_rounded,
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
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.accentGold,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAyahOfTheDay(BuildContext context, bool isDark) {
    final dailyAyah = QuranDataService.getDailyAyah();

    return IslamicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.accentGold,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'আজকের আয়াত (আয়াতুল কুরসী)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark
                          ? AppColors.goldLight
                          : AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(
                  Icons.copy_rounded,
                  size: 18,
                  color: AppColors.accentGold,
                ),
                tooltip: 'কপি করুন',
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(
                      text:
                          '${dailyAyah.textArabic}\n\n${dailyAyah.translationBangla}\n[সূরা বাকারা: ২৫৫]',
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('আয়াত ক্লিপবোর্ডে কপি করা হয়েছে'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Arabic Text
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              dailyAyah.textArabic,
              textAlign: TextAlign.right,
              style: AppTheme.arabicText(
                fontSize: 21,
                color: isDark ? Colors.white : AppColors.primaryDark,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Bengali Translation
          Text(
            dailyAyah.translationBangla,
            style: AppTheme.banglaText(
              fontSize: 14,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              '— সূরা আল-বাকারা, আয়াত ২৫৫',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.accentGold,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
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
                    Icons.arrow_forward_rounded,
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
