import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:provider/provider.dart';
import '../../models/islamic_special_day_model.dart';
import '../../providers/islamic_events_provider.dart';
import '../../providers/tasbih_provider.dart';
import '../../services/islamic_events_service.dart';
import '../../services/prayer_service.dart';
import '../../services/quran_data_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../quran/surah_detail_screen.dart';
import '../tasbih/tasbih_screen.dart';
import 'notification_settings_sheet.dart';

class IslamicEventDetailScreen extends StatelessWidget {
  final IslamicSpecialDayModel event;
  final UpcomingEventResult? upcomingResult;

  const IslamicEventDetailScreen({
    super.key,
    required this.event,
    this.upcomingResult,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = Provider.of<IslamicEventsProvider>(context);
    final stats = provider.getCompletionStats(event);
    final isNotifEnabled = provider.isEventNotificationEnabled(event.id);

    final result = upcomingResult ?? IslamicEventsService.calculateNextOccurrence(event);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Gradient
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              title: Text(
                event.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(color: Colors.black54, blurRadius: 4),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF0F5132),
                          Color(0xFF062817),
                          Color(0xFF1B3B2B),
                        ],
                      ),
                    ),
                  ),
                  // Decorative Crescent & Star Icon
                  Positioned(
                    right: -20,
                    top: 20,
                    child: Icon(
                      IconlyBold.star,
                      size: 150,
                      color: AppColors.accentGold.withValues(alpha: 0.12),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    bottom: 60,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.accentGold.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.accentGold, width: 0.8),
                              ),
                              child: Text(
                                event.hijriDateString,
                                style: const TextStyle(
                                  color: AppColors.goldLight,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: result.isToday
                                    ? Colors.redAccent.withValues(alpha: 0.8)
                                    : Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                result.dateDisplay,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          event.arabicTitle,
                          style: const TextStyle(
                            fontFamily: 'ScheherazadeNew',
                            fontSize: 22,
                            color: AppColors.accentGold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isNotifEnabled ? IconlyBold.notification : IconlyLight.notification,
                  color: isNotifEnabled ? AppColors.accentGold : Colors.grey,
                ),
                tooltip: 'নোটিফিকেশন সেটিংস',
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => IslamicNotificationSettingsSheet(targetEvent: event),
                  );
                },
              ),
            ],
          ),

          // Content List
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tagline & Description Card
                  IslamicCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(IconlyBold.star, color: AppColors.accentGold, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                event.tagline,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: AppColors.accentGold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          event.description,
                          style: TextStyle(
                            fontSize: 13.5,
                            height: 1.55,
                            color: isDark ? AppColors.darkText : AppColors.lightText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Quran Reference Card (if present)
                  if (event.quranReference != null) ...[
                    IslamicCard(
                      borderColor: AppColors.accentGold.withValues(alpha: 0.4),
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF1E3A2B), const Color(0xFF12281D)]
                            : [const Color(0xFFEFF8F2), const Color(0xFFE2F3E7)],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(IconlyBold.document, color: AppColors.accentGold, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'পবিত্র কুরআনের বাণী',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.5,
                                  color: AppColors.accentGold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            event.quranReference!,
                            style: const TextStyle(
                              fontSize: 13.5,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Hadith Reference Card (if present)
                  if (event.hadithReference != null) ...[
                    IslamicCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(IconlyBold.paper, color: Color(0xFF10B981), size: 20),
                              SizedBox(width: 8),
                              Text(
                                'সহিহ হাদিসের ফজিলত',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.5,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            event.hadithReference!,
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.6,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],

                  // Amals Progress Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(IconlyBold.tickSquare, color: AppColors.accentGold, size: 22),
                          const SizedBox(width: 8),
                          const Text(
                            'বিশেষ আমলসমূহ ও আমলনামা',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.primary, width: 0.8),
                        ),
                        child: Text(
                          '${PrayerService.toBanglaDigits(stats['completed'].toString())} / ${PrayerService.toBanglaDigits(stats['total'].toString())} সম্পন্ন',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: stats['total']! > 0 ? (stats['completed']! / stats['total']!) : 0,
                      backgroundColor: Colors.grey.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentGold),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // List of Amals
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: event.amals.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final amal = event.amals[index];
                      final isCompleted = provider.isAmalCompleted(event.id, amal.id);

                      return _buildAmalCard(context, amal, isCompleted, provider, isDark);
                    },
                  ),
                  const SizedBox(height: 20),

                  // Prohibitions & Warnings (বিদআত ও বর্জনীয় বিষয়)
                  if (event.prohibitions.isNotEmpty) ...[
                    IslamicCard(
                      borderColor: Colors.redAccent.withValues(alpha: 0.4),
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF381414), const Color(0xFF220909)]
                            : [const Color(0xFFFFECEC), const Color(0xFFFFDFDF)],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(IconlyBold.danger, color: Colors.redAccent, size: 22),
                              SizedBox(width: 8),
                              Text(
                                'বর্জনীয় বিষয় ও বিদআত সতর্কতা',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ...event.prohibitions.map(
                            (p) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• ', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                                  Expanded(
                                    child: Text(
                                      p,
                                      style: TextStyle(
                                        fontSize: 13,
                                        height: 1.45,
                                        color: isDark ? AppColors.darkText : AppColors.lightText,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmalCard(
    BuildContext context,
    IslamicAmalModel amal,
    bool isCompleted,
    IslamicEventsProvider provider,
    bool isDark,
  ) {
    return IslamicCard(
      borderColor: isCompleted
          ? AppColors.primary
          : AppColors.accentGold.withValues(alpha: 0.25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with checkbox & title
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  provider.toggleAmalCompletion(event.id, amal.id);
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted ? AppColors.primary : Colors.transparent,
                    border: Border.all(
                      color: isCompleted ? AppColors.primary : AppColors.accentGold,
                      width: 2,
                    ),
                  ),
                  child: isCompleted
                      ? const Icon(IconlyBold.tickSquare, color: Colors.white, size: 18)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(amal.category).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            amal.category,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _getCategoryColor(amal.category),
                            ),
                          ),
                        ),
                        if (amal.recommendedCount != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '(${amal.recommendedCount})',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.accentGold,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      amal.title,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                        color: isCompleted
                            ? (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)
                            : (isDark ? AppColors.darkText : AppColors.lightText),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Description
          Text(
            amal.description,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 8),

          // Benefit
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(IconlyBold.shieldDone, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    amal.benefit,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Optional Arabic Dua block
          if (amal.arabicDua != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.black26 : const Color(0xFFF9F9F4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.accentGold.withValues(alpha: 0.3),
                  width: 0.8,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    amal.arabicDua!,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 18,
                      fontFamily: 'ScheherazadeNew',
                      height: 1.8,
                      color: AppColors.accentGold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (amal.banglaPronunciation != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      'উচ্চারণ: ${amal.banglaPronunciation}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  if (amal.banglaMeaning != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'অর্থ: ${amal.banglaMeaning}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  if (amal.reference != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'সূত্র: ${amal.reference}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        visualDensity: VisualDensity.compact,
                      ),
                      icon: const Icon(IconlyLight.document, size: 16, color: AppColors.accentGold),
                      label: const Text(
                        'দোয়া কপি করুন',
                        style: TextStyle(fontSize: 12, color: AppColors.accentGold),
                      ),
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(
                            text: '${amal.arabicDua}\n\nউচ্চারণ: ${amal.banglaPronunciation}\n\nঅর্থ: ${amal.banglaMeaning}',
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('দোয়া ক্লিপবোর্ডে কপি করা হয়েছে!'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Quick Action buttons (Surah reading or Tasbih counting)
          if (amal.surahNumber != null || amal.tasbihText != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                if (amal.surahNumber != null) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(IconlyBold.document, size: 16),
                      label: const Text(
                        'সূরা পাঠ করুন',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        final surah = QuranDataService.surahList.firstWhere(
                          (s) => s.number == amal.surahNumber,
                          orElse: () => QuranDataService.surahList[0],
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SurahDetailScreen(surah: surah),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                if (amal.surahNumber != null && amal.tasbihText != null)
                  const SizedBox(width: 10),
                if (amal.tasbihText != null) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentGold,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(IconlyBold.activity, size: 16),
                      label: const Text(
                        'তসবিহ পড়ুন',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        final tasbihProvider = Provider.of<TasbihProvider>(context, listen: false);
                        // Add or set this phrase
                        tasbihProvider.addCustomDhikr(amal.title, amal.tasbihText!);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const TasbihScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'সালাত':
        return const Color(0xFF10B981);
      case 'কুরআন':
        return AppColors.accentGold;
      case 'জিকির ও দোয়া':
        return const Color(0xFF6366F1);
      case 'রোজা':
        return const Color(0xFFEC4899);
      case 'সদকা':
        return const Color(0xFFF59E0B);
      default:
        return AppColors.primary;
    }
  }
}
