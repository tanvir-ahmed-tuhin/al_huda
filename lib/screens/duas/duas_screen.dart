import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import '../../services/duas_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';

class DuasScreen extends StatelessWidget {
  const DuasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final duas = DuasData.dailyDuas;

    return Scaffold(
      appBar: AppBar(
        title: const Text('দৈনন্দিন প্রয়োজনীয় দোয়া'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: duas.length,
        itemBuilder: (context, index) {
          final dua = duas[index];

          return IslamicCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Title & Copy button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accentGold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.accentGold, width: 0.8),
                      ),
                      child: Text(
                        dua.titleBangla,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.accentGold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(IconlyLight.document, size: 18, color: AppColors.accentGold),
                      tooltip: 'দোয়া কপি করুন',
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(
                            text: '${dua.titleBangla}\n\n${dua.arabic}\n\nউচ্চারণ: ${dua.transliterationBangla}\n\nঅর্থ: ${dua.translationBangla}\n[সূত্র: ${dua.reference}]',
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('দোয়া কপি করা হয়েছে'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Arabic Text
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      dua.arabic,
                      style: AppTheme.arabicText(
                        fontSize: 22,
                        color: isDark ? Colors.white : AppColors.primaryDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Transliteration
                Text(
                  'উচ্চারণ: ${dua.transliterationBangla}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: AppColors.accentGold,
                  ),
                ),
                const SizedBox(height: 6),

                // Bangla Meaning
                Text(
                  'অর্থ: ${dua.translationBangla}',
                  style: AppTheme.banglaText(
                    fontSize: 14,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 6),

                // Reference
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    dua.reference,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
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
