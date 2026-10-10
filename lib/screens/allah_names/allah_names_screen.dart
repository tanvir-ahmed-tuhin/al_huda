import 'package:flutter/material.dart';
import '../../services/allah_names_data.dart';
import '../../services/prayer_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';

class AllahNamesScreen extends StatelessWidget {
  const AllahNamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final names = AllahNamesData.names;

    return Scaffold(
      appBar: AppBar(
        title: const Text('আল্লাহর ৯৯টি গুণবাচক নাম'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: names.length,
        itemBuilder: (context, index) {
          final item = names[index];
          return IslamicCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Number badge
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.15),
                    border: Border.all(color: AppColors.accentGold, width: 1),
                  ),
                  child: Center(
                    child: Text(
                      PrayerService.toBanglaDigits(item.id.toString()),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.accentGold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Name Bangla & Meaning
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.banglaName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.banglaMeaning,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.benefit,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.accentGold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Arabic Calligraphy Text
                Text(
                  item.arabic,
                  style: AppTheme.arabicText(
                    fontSize: 22,
                    color: isDark ? AppColors.goldLight : AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
