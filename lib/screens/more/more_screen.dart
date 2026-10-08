import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../allah_names/allah_names_screen.dart';
import '../duas/duas_screen.dart';
import '../islamic_events/islamic_events_screen.dart';
import '../prayer_times/azan_settings_screen.dart';
import '../prayer_times/prayer_times_screen.dart';
import '../profile/profile_screen.dart';
import '../tasbih/tasbih_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final menuItems = [
      {
        'title': 'ইসলামিক বিশেষ দিন ও আমল',
        'subtitle': 'অগ্রিম নোটিফিকেশন, ফজিলত ও করণীয় আমলসমূহ',
        'icon': Icons.event_available_rounded,
        'color': AppColors.accentGold,
        'screen': const IslamicEventsScreen(),
      },
      {
        'title': 'নামাজের পূর্ণাঙ্গ সময়সূচি',
        'subtitle': 'সকল ওয়াক্ত ও তাহাজ্জুদ সময়',
        'icon': Icons.access_time_filled_rounded,
        'color': const Color(0xFF10B981),
        'screen': const PrayerTimesScreen(),
      },
      {
        'title': 'আযানের কণ্ঠ ও সেটিংস',
        'subtitle': '৮টি বিখ্যাত কণ্ঠ ও ওয়াক্ত অনুযায়ী আযান',
        'icon': Icons.campaign_rounded,
        'color': AppColors.accentGold,
        'screen': const AzanSettingsScreen(),
      },
      {
        'title': 'ডিজিটাল তসবিহ কাউন্টার',
        'subtitle': 'যিকির গণনা ও রুটিন',
        'icon': Icons.fingerprint_rounded,
        'color': AppColors.accentGold,
        'screen': const TasbihScreen(),
      },
      {
        'title': 'আল্লাহর ৯৯টি গুণবাচক নাম',
        'subtitle': 'আসমাউল হুসনা, অর্থ ও ফজিলত',
        'icon': Icons.stars_rounded,
        'color': const Color(0xFFF59E0B),
        'screen': const AllahNamesScreen(),
      },
      {
        'title': 'দৈনন্দিন প্রয়োজনীয় দোয়া',
        'subtitle': 'হিসনুল মুসলিম দোয়া সমূহ',
        'icon': Icons.menu_book_rounded,
        'color': const Color(0xFF6366F1),
        'screen': const DuasScreen(),
      },
      {
        'title': 'প্রোফাইল ও সেটিংস',
        'subtitle': 'একাউন্ট, স্ট্রিক ও থিম পরিবর্তন',
        'icon': Icons.person_rounded,
        'color': const Color(0xFF3B82F6),
        'screen': const ProfileScreen(),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('ইসলামিক সেবা সমূহ'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        children: [
          ...menuItems.map((item) {
            final color = item['color'] as Color;
            final targetScreen = item['screen'] as Widget;

            return IslamicCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => targetScreen),
                );
              },
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      color: color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item['subtitle'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
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
          }),

          const SizedBox(height: 20),

          // App Info Banner
          Center(
            child: Column(
              children: [
                const Icon(
                  Icons.auto_stories_rounded,
                  color: AppColors.accentGold,
                  size: 32,
                ),
                const SizedBox(height: 8),
                const Text(
                  'পবিত্র আল-কুরআন ও ক্বিবলা কম্পাস',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  'সংস্করণ ১.০.১ • সাদকায়ে জারিয়া',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
