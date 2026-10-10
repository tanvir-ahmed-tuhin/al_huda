import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
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
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final isAuthenticated = authProvider.isAuthenticated;

    final menuItems = [
      {
        'title': 'ইসলামিক বিশেষ দিন ও আমল',
        'subtitle': 'অগ্রিম নোটিফিকেশন, ফজিলত ও করণীয় আমলসমূহ',
        'icon': FlutterIslamicIcons.calendar,
        'color': AppColors.accentGold,
        'screen': const IslamicEventsScreen(),
      },
      {
        'title': 'নামাজের পূর্ণাঙ্গ সময়সূচি',
        'subtitle': 'সকল ওয়াক্ত ও তাহাজ্জুদ সময়',
        'icon': FlutterIslamicIcons.prayer,
        'color': const Color(0xFF10B981),
        'screen': const PrayerTimesScreen(),
      },
      {
        'title': 'আযানের কণ্ঠ ও সেটিংস',
        'subtitle': '৮টি বিখ্যাত কণ্ঠ ও ওয়াক্ত অনুযায়ী আযান',
        'icon': FlutterIslamicIcons.solidMinaret,
        'color': AppColors.accentGold,
        'screen': const AzanSettingsScreen(),
      },
      {
        'title': 'ডিজিটাল তসবিহ কাউন্টার',
        'subtitle': 'যিকির গণনা ও রুটিন',
        'icon': FlutterIslamicIcons.solidTasbih2,
        'color': AppColors.accentGold,
        'screen': const TasbihScreen(),
      },
      {
        'title': 'আল্লাহর ৯৯টি গুণবাচক নাম',
        'subtitle': 'আসমাউল হুসনা, অর্থ ও ফজিলত',
        'icon': FlutterIslamicIcons.allah99,
        'color': const Color(0xFFF59E0B),
        'screen': const AllahNamesScreen(),
      },
      {
        'title': 'দৈনন্দিন প্রয়োজনীয় দোয়া',
        'subtitle': 'হিসনুল মুসলিম দোয়া সমূহ',
        'icon': FlutterIslamicIcons.solidPrayer,
        'color': const Color(0xFF6366F1),
        'screen': const DuasScreen(),
      },
      {
        'title': 'প্রোফাইল ও সেটিংস',
        'subtitle': isAuthenticated
            ? '${user?.name} (ক্লাউড সিঙ্ক সক্রিয়)'
            : 'একাউন্ট, গুগল সাইন-ইন ও ক্লাউড ব্যাকআপ',
        'icon': IconlyBold.profile,
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
            final targetScreen = item['screen'] as Widget;
            final iconColor = isDark ? AppColors.accentGold : AppColors.primary;
            final containerBg = isDark
                ? AppColors.accentGold.withValues(alpha: 0.15)
                : AppColors.primary.withValues(alpha: 0.12);

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
                      color: containerBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? AppColors.accentGold.withValues(alpha: 0.25)
                            : AppColors.primary.withValues(alpha: 0.18),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      color: iconColor,
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
                    IconlyLight.arrowRight2,
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
                  IconlyBold.document,
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
