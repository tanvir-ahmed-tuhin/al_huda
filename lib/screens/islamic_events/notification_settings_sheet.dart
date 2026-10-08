import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/islamic_special_day_model.dart';
import '../../providers/islamic_events_provider.dart';
import '../../services/islamic_events_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';

class IslamicNotificationSettingsSheet extends StatelessWidget {
  final IslamicSpecialDayModel? targetEvent;

  const IslamicNotificationSettingsSheet({super.key, this.targetEvent});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = Provider.of<IslamicEventsProvider>(context);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: AppColors.accentGold,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'বিশেষ দিন ও আমলের নোটিফিকেশন',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'আসন্ন দিনগুলোর আগেভাগেই অ্যালার্ট পান',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Master Switch
          IslamicCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.power_settings_new_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'সকল নোটিফিকেশন চালু রাখুন',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'আসন্ন বরকতময় দিনগুলোর নোটিফিকেশন পাবেন',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: provider.notificationsEnabled,
                  activeThumbColor: AppColors.accentGold,
                  activeTrackColor: AppColors.primary,
                  onChanged: (val) {
                    provider.setNotificationsEnabled(val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Timing options
          if (provider.notificationsEnabled) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Text(
                'কখন নোটিফিকেশন পেতে চান?',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accentGold,
                ),
              ),
            ),
            IslamicCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Column(
                children: [
                  _buildToggleTile(
                    icon: Icons.calendar_month_rounded,
                    title: '৩ দিন আগে অগ্রিম নোটিফিকেশন',
                    subtitle: 'যাতে মানসিক ও আমলি প্রস্তুতি নিতে পারেন',
                    value: provider.notify3DaysBefore,
                    onChanged: (val) => provider.setNotify3DaysBefore(val),
                  ),
                  const Divider(height: 1),
                  _buildToggleTile(
                    icon: Icons.timer_outlined,
                    title: '১ দিন আগে (সন্ধ্যায়) নোটিফিকেশন',
                    subtitle: 'মাগরিবের পর বরকতময় রাত শুরু হওয়ার পূর্বে অ্যালার্ট',
                    value: provider.notify1DayBefore,
                    onChanged: (val) => provider.setNotify1DayBefore(val),
                  ),
                  const Divider(height: 1),
                  _buildToggleTile(
                    icon: Icons.wb_sunny_rounded,
                    title: 'বিশেষ দিনের সকালে রিমাইন্ডার',
                    subtitle: 'সকালে ফজরের পর আজকের বিশেষ আমলসমূহ স্মরণ করিয়ে দিবে',
                    value: provider.notifyOnDayMorning,
                    onChanged: (val) => provider.setNotifyOnDayMorning(val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Instant Test Notification Button
            IslamicCard(
              padding: const EdgeInsets.all(14),
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.15),
                  AppColors.accentGold.withValues(alpha: 0.15),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.cell_tower_rounded,
                    color: AppColors.accentGold,
                    size: 26,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'নোটিফিকেশন পরীক্ষা করুন',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'ফোনে নোটিফিকেশন টেস্ট করতে এখনই ট্যাপ করুন',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentGold,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      await provider.sendTestNotification(targetEvent);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              '🔔 সফলভাবে টেস্ট নোটিফিকেশন পাঠানো হয়েছে!',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            backgroundColor: AppColors.primary,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'টেস্ট করুন',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Per Event Notification Toggles
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Text(
                'বিশেষ দিনসমূহ কাস্টমাইজ করুন',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accentGold,
                ),
              ),
            ),
            IslamicCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: IslamicEventsService.specialDays.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final event = IslamicEventsService.specialDays[index];
                  final enabled = provider.isEventNotificationEnabled(event.id);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.title,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                event.hijriDateString,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: enabled,
                          activeThumbColor: AppColors.accentGold,
                          activeTrackColor: AppColors.primary,
                          onChanged: (val) {
                            provider.toggleEventNotification(event.id);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accentGold, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: AppColors.accentGold,
            activeTrackColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
