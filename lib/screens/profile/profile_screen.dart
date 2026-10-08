import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/prayer_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final taskProvider = Provider.of<TaskProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('প্রোফাইল ও সেটিংস'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          children: [
            // User Avatar & Name Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF072B1A)],
                ),
                border: Border.all(
                  color: AppColors.accentGold.withValues(alpha: 0.5),
                  width: 1.2,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accentGold.withValues(alpha: 0.2),
                      border: Border.all(
                        color: AppColors.accentGold,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 44,
                      color: AppColors.accentGold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'সম্মানিত অতিথি',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'guest@islamic.app',
                    style: TextStyle(
                      color: AppColors.goldLight,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Amal Points & Streak Stats
            Row(
              children: [
                Expanded(
                  child: IslamicCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.local_fire_department_rounded,
                          color: AppColors.amber,
                          size: 28,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          PrayerService.toBanglaDigits('1') + ' দিন',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'আমলের ধারাবাহিকতা',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: IslamicCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.stars_rounded,
                          color: AppColors.accentGold,
                          size: 28,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          PrayerService.toBanglaDigits(
                            taskProvider.earnedPointsToday.toString(),
                          ),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'মোট অর্জিত পয়েন্ট',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Settings & Preferences
            IslamicCard(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: Icon(
                      themeProvider.isDarkMode
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      color: AppColors.accentGold,
                    ),
                    title: const Text('ডার্ক মোড (Dark Theme)'),
                    value: themeProvider.isDarkMode,
                    activeTrackColor: AppColors.accentGold,
                    onChanged: (_) => themeProvider.toggleTheme(),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.share_rounded,
                      color: AppColors.accentGold,
                    ),
                    title: const Text('অ্যাপ শেয়ার করুন'),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('শেয়ার লিঙ্ক কপি করা হয়েছে'),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.accentGold,
                    ),
                    title: const Text('অ্যাপ সম্পর্কিত তথ্য'),
                    subtitle: const Text(
                      'সংস্করণ ১.০.১ (সাদকায়ে জারিয়া)',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}