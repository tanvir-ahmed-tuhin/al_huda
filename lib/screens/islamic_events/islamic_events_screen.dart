import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:provider/provider.dart';
import '../../providers/islamic_events_provider.dart';
import '../../services/prayer_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import 'event_detail_screen.dart';
import 'notification_settings_sheet.dart';

class IslamicEventsScreen extends StatelessWidget {
  const IslamicEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = Provider.of<IslamicEventsProvider>(context);
    final events = provider.filteredEvents;
    final nextEvent = provider.nextMajorEvent;

    final categories = ['সকল', 'বরকতময় রজনী', 'প্রধান উৎসব', 'নফল সিয়াম ও ইবাদত', 'সাপ্তাহিক শ্রেষ্ঠ দিন'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('ইসলামিক বিশেষ দিন ও আমল'),
        actions: [
          IconButton(
            icon: const Icon(IconlyBold.notification, color: AppColors.accentGold),
            tooltip: 'নোটিফিকেশন ও অ্যালার্ট সেটিংস',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const IslamicNotificationSettingsSheet(),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          provider.refreshEvents();
        },
        color: AppColors.accentGold,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          children: [
            // Hero Upcoming Event Banner
            if (nextEvent != null) ...[
              _buildHeroCountdownCard(context, nextEvent, isDark),
              const SizedBox(height: 18),
            ],

            // Advance Notification Info Strip
            IslamicCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1E3A2B), const Color(0xFF10281B)]
                    : [const Color(0xFFE8F5EE), const Color(0xFFD6EDE0)],
              ),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const IslamicNotificationSettingsSheet(),
                );
              },
              child: Row(
                children: [
                  const Icon(
                    IconlyBold.notification,
                    color: AppColors.accentGold,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          provider.notificationsEnabled
                              ? 'অ্যালার্ট চালু: ৩ দিন ও ১ দিন আগে নোটিফিকেশন'
                              : 'নোটিফিকেশন বর্তমানে বন্ধ আছে',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'ট্যাপ করে সময়সূচি ও অ্যালার্ট কাস্টমাইজ করুন',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    IconlyLight.setting,
                    size: 18,
                    color: AppColors.accentGold,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Category Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((cat) {
                  final isSelected = provider.selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (_) => provider.setCategory(cat),
                      selectedColor: AppColors.primary,
                      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isDark ? AppColors.darkText : AppColors.lightText),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12.5,
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.accentGold.withValues(alpha: 0.3),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Events List
            ...events.map((result) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildEventCard(context, result, provider, isDark),
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCountdownCard(
    BuildContext context,
    dynamic nextEvent,
    bool isDark,
  ) {
    final event = nextEvent.event;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F5132),
            Color(0xFF082F1D),
          ],
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.accentGold, width: 0.8),
                ),
                child: Row(
                  children: [
                    const Icon(IconlyBold.star, size: 14, color: AppColors.goldLight),
                    const SizedBox(width: 4),
                    Text(
                      nextEvent.isToday ? 'আজকের বিশেষ দিন' : 'আসন্ন প্রধান দিন',
                      style: const TextStyle(
                        color: AppColors.goldLight,
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: nextEvent.isToday ? Colors.redAccent : AppColors.accentGold,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  nextEvent.dateDisplay,
                  style: TextStyle(
                    color: nextEvent.isToday ? Colors.white : Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            event.title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            event.arabicTitle,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.accentGold,
              fontFamily: 'ScheherazadeNew',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            event.tagline,
            style: const TextStyle(
              fontSize: 12.5,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(IconlyLight.arrowRight, size: 18),
              label: const Text(
                'বিশেষ আমল ও করণীয় দেখুন',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => IslamicEventDetailScreen(
                      event: event,
                      upcomingResult: nextEvent,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(
    BuildContext context,
    dynamic result,
    IslamicEventsProvider provider,
    bool isDark,
  ) {
    final event = result.event;
    final stats = provider.getCompletionStats(event);
    final isNotifOn = provider.isEventNotificationEnabled(event.id);

    return IslamicCard(
      padding: const EdgeInsets.all(14),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => IslamicEventDetailScreen(
              event: event,
              upcomingResult: result,
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      event.category,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    event.hijriDateString,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: result.isToday
                      ? Colors.redAccent.withValues(alpha: 0.15)
                      : AppColors.accentGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: result.isToday ? Colors.redAccent : AppColors.accentGold,
                    width: 0.8,
                  ),
                ),
                child: Text(
                  result.dateDisplay,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: result.isToday ? Colors.redAccent : AppColors.accentGold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      event.tagline,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(
                IconlyLight.arrowRight2,
                size: 15,
                color: AppColors.accentGold,
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Footer with Amals count, progress & notification icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(IconlyBold.tickSquare, size: 16, color: AppColors.accentGold),
                  const SizedBox(width: 4),
                  Text(
                    '${PrayerService.toBanglaDigits(event.amals.length.toString())}টি বিশেষ আমল ও দোয়া',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                  ),
                  if (stats['completed']! > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${PrayerService.toBanglaDigits(stats['completed'].toString())} সম্পন্ন',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Icon(
                isNotifOn ? IconlyBold.notification : IconlyLight.notification,
                size: 16,
                color: isNotifOn ? AppColors.accentGold : Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
