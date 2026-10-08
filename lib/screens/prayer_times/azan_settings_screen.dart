import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/azan_voice_model.dart';
import '../../models/prayer_time_model.dart';
import '../../providers/azan_provider.dart';
import '../../providers/prayer_provider.dart';
import '../../services/azan_service.dart';
import '../../services/prayer_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/azan_dialog.dart';
import '../../widgets/glass_card.dart';

class AzanSettingsScreen extends StatelessWidget {
  const AzanSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final azanProvider = Provider.of<AzanProvider>(context);
    final prayerProvider = Provider.of<PrayerProvider>(context);
    final pt = prayerProvider.prayerTimes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('আযানের কণ্ঠ ও সেটিংস'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: AppColors.accentGold),
            tooltip: 'আযানের ফজিলত',
            onPressed: () => _showHadithDialog(context, isDark),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        children: [
          // Master Auto Azan Switch Card
          _buildMasterSwitchCard(context, azanProvider, isDark),
          const SizedBox(height: 16),

          // Test Play Azan Hero Card
          _buildTestPlayCard(context, azanProvider, isDark),
          const SizedBox(height: 20),

          // Per-Prayer Azan Toggle Card
          _buildPrayerTogglesCard(context, azanProvider, pt, isDark),
          const SizedBox(height: 20),

          // Fajr Special Azan Card
          _buildFajrSpecialCard(context, azanProvider, isDark),
          const SizedBox(height: 20),

          // Voice Selection Header
          Row(
            children: [
              const Icon(Icons.record_voice_over_rounded, color: AppColors.accentGold, size: 22),
              const SizedBox(width: 8),
              const Text(
                'আযানের সুললিত কণ্ঠ নির্বাচন',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'বিশ্ববিখ্যাত প্রধান মুয়াজ্জিন ও ক্বারীদের হৃদয়স্পর্শী কণ্ঠ থেকে আপনার পছন্দের সুর বেছে নিন',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 12),

          // Azan Voice Cards List
          ...AzanService.azanVoices.map((voice) {
            return _buildVoiceCard(context, voice, azanProvider, isDark);
          }),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMasterSwitchCard(
    BuildContext context,
    AzanProvider azanProvider,
    bool isDark,
  ) {
    return IslamicCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      borderColor: azanProvider.isMasterEnabled ? AppColors.accentGold : null,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: azanProvider.isMasterEnabled
                      ? AppColors.accentGold.withValues(alpha: 0.2)
                      : (isDark ? AppColors.darkCardElevated : Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  azanProvider.isMasterEnabled
                      ? Icons.notifications_active_rounded
                      : Icons.notifications_off_rounded,
                  color: azanProvider.isMasterEnabled
                      ? AppColors.accentGold
                      : (isDark ? Colors.white54 : Colors.grey),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'নামাজের সময় আযান দিন',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      azanProvider.isMasterEnabled
                          ? 'প্রতিটি ওয়াক্তের সময় স্বয়ংক্রিয়ভাবে আযান বাজবে'
                          : 'স্বয়ংক্রিয় আযান বন্ধ আছে',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: azanProvider.isMasterEnabled,
                activeThumbColor: AppColors.accentGold,
                onChanged: (val) => azanProvider.setMasterEnabled(val),
              ),
            ],
          ),
          if (azanProvider.isMasterEnabled) ...[
            const SizedBox(height: 14),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.volume_up_rounded, size: 20, color: AppColors.accentGold),
                const SizedBox(width: 10),
                const Text('আযানের ভলিউম', style: TextStyle(fontSize: 13)),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbColor: AppColors.accentGold,
                      activeTrackColor: AppColors.accentGold,
                      inactiveTrackColor: AppColors.accentGold.withValues(alpha: 0.2),
                      trackHeight: 3,
                    ),
                    child: Slider(
                      value: azanProvider.volume,
                      min: 0.1,
                      max: 1.0,
                      onChanged: (val) => azanProvider.setVolume(val),
                    ),
                  ),
                ),
                Text(
                  '${(azanProvider.volume * 100).toInt()}%',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTestPlayCard(
    BuildContext context,
    AzanProvider azanProvider,
    bool isDark,
  ) {
    final isPlayingActiveVoice =
        azanProvider.isPlaying && azanProvider.playingVoiceId == azanProvider.selectedVoice.id;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F5132),
            Color(0xFF082E1C),
          ],
        ),
        border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.6), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F5132).withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.accentGold, width: 1),
                ),
                child: const Icon(
                  Icons.mosque_rounded,
                  color: AppColors.accentGold,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'বর্তমান নির্বাচিত কণ্ঠ',
                      style: TextStyle(color: AppColors.goldLight, fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      azanProvider.selectedVoice.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'মুয়াজ্জিন: ${azanProvider.selectedVoice.muadhin}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (isPlayingActiveVoice) {
                      azanProvider.stopAzan();
                    } else {
                      azanProvider.triggerAzanForPrayer(
                        PrayerName.dhuhr,
                        isManualTest: true,
                      );
                      AzanDialog.show(context);
                    }
                  },
                  icon: Icon(
                    isPlayingActiveVoice ? Icons.stop_rounded : Icons.play_circle_filled_rounded,
                    color: Colors.black87,
                    size: 22,
                  ),
                  label: Text(
                    isPlayingActiveVoice ? 'আযান বন্ধ করুন' : 'টেস্ট আযান শুনুন',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGold,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              if (azanProvider.isPlaying) ...[
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () => AzanDialog.show(context),
                  icon: const Icon(Icons.open_in_full_rounded, color: AppColors.goldLight),
                  tooltip: 'আযান স্ক্রিন খুলুন',
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTogglesCard(
    BuildContext context,
    AzanProvider azanProvider,
    PrayerTimeModel? pt,
    bool isDark,
  ) {
    final prayers = [
      {'key': 'fajr', 'name': 'ফজর', 'icon': Icons.nights_stay_rounded, 'tod': pt?.fajr},
      {'key': 'dhuhr', 'name': 'যোহর', 'icon': Icons.wb_sunny_outlined, 'tod': pt?.dhuhr},
      {'key': 'asr', 'name': 'আসর', 'icon': Icons.wb_cloudy_rounded, 'tod': pt?.asr},
      {'key': 'maghrib', 'name': 'মাগরিব', 'icon': Icons.wb_twilight_rounded, 'tod': pt?.maghrib},
      {'key': 'isha', 'name': 'ইশা', 'icon': Icons.bedtime_rounded, 'tod': pt?.isha},
    ];

    return IslamicCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.alarm_on_rounded, color: AppColors.accentGold, size: 20),
              const SizedBox(width: 8),
              const Text(
                'ওয়াক্ত অনুযায়ী আযান অন/অফ',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...prayers.map((item) {
            final key = item['key'] as String;
            final name = item['name'] as String;
            final icon = item['icon'] as IconData;
            final tod = item['tod'] as TimeOfDay?;
            final isEnabled = azanProvider.prayerAzanEnabled[key] ?? true;
            final timeStr = tod != null ? PrayerService.formatTimeOfDayBangla(tod) : '--:--';

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(icon, size: 18, color: isEnabled ? AppColors.accentGold : Colors.grey),
                  const SizedBox(width: 10),
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: isEnabled ? FontWeight.bold : FontWeight.normal,
                      color: isEnabled ? null : Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    timeStr,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Transform.scale(
                    scale: 0.85,
                    child: Switch(
                      value: isEnabled && azanProvider.isMasterEnabled,
                      activeThumbColor: AppColors.accentGold,
                      onChanged: azanProvider.isMasterEnabled
                          ? (val) => azanProvider.setPrayerAzanEnabled(key, val)
                          : null,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFajrSpecialCard(
    BuildContext context,
    AzanProvider azanProvider,
    bool isDark,
  ) {
    return IslamicCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accentGold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.nightlight_rounded, color: AppColors.accentGold, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ফজরে বিশেষ আযান বাজান',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'الصلاة خير من النوم (ঘুম হতে নামাজ উত্তম) সংবলিত সুর',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: azanProvider.useFajrSpecial,
            activeThumbColor: AppColors.accentGold,
            onChanged: (val) => azanProvider.setUseFajrSpecial(val),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceCard(
    BuildContext context,
    AzanVoiceModel voice,
    AzanProvider azanProvider,
    bool isDark,
  ) {
    final isSelected = azanProvider.selectedVoice.id == voice.id;
    final isThisPlaying = azanProvider.isPlaying && azanProvider.playingVoiceId == voice.id;
    final isLoadingThis = azanProvider.isLoading && azanProvider.playingVoiceId == voice.id;

    return IslamicCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      borderColor: isSelected ? AppColors.accentGold : null,
      gradient: isSelected
          ? LinearGradient(
              colors: isDark
                  ? [
                      const Color(0xFF1B3828),
                      const Color(0xFF12281C),
                    ]
                  : [
                      const Color(0xFFEAF5EE),
                      const Color(0xFFD8EFE2),
                    ],
            )
          : null,
      onTap: () {
        azanProvider.selectVoice(voice);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selection Radio
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.accentGold : Colors.grey.shade400,
                    width: 2,
                  ),
                  color: isSelected ? AppColors.accentGold : Colors.transparent,
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 18, color: Colors.black)
                    : null,
              ),
              const SizedBox(width: 12),

              // Voice details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            voice.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: isSelected ? AppColors.accentGold : null,
                            ),
                          ),
                        ),
                        if (voice.isFajr)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accentGold.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'ফজর',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.accentGold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'কণ্ঠ: ${voice.muadhin}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'স্থান: ${voice.location} • আনুমানিক ${voice.durationText}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      voice.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Preview button
              Column(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      azanProvider.toggleVoicePreview(voice);
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isThisPlaying
                            ? AppColors.accentGold
                            : (isDark ? AppColors.darkCardElevated : Colors.white),
                        border: Border.all(
                          color: AppColors.accentGold.withValues(alpha: 0.6),
                          width: 1.2,
                        ),
                        boxShadow: [
                          if (isThisPlaying)
                            BoxShadow(
                              color: AppColors.accentGold.withValues(alpha: 0.4),
                              blurRadius: 10,
                            ),
                        ],
                      ),
                      child: isLoadingThis
                          ? const Padding(
                              padding: EdgeInsets.all(10),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.accentGold,
                              ),
                            )
                          : Icon(
                              isThisPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
                              color: isThisPlaying ? Colors.black87 : AppColors.accentGold,
                              size: 24,
                            ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isThisPlaying ? 'চলছে' : 'শুনুন',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isThisPlaying ? AppColors.accentGold : Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showHadithDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF14241C) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.stars_rounded, color: AppColors.accentGold),
            SizedBox(width: 8),
            Text('আযানের ফজিলত', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'রাসূলুল্লাহ (সা.) ইরশাদ করেছেন:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              SizedBox(height: 6),
              Text(
                '১. "মুয়াজ্জিনের কণ্ঠস্বর যতদূর পৌঁছায় এবং যা কিছু তা শোনে (জ্বিন, ইনসান বা কোনো বস্তু), কিয়ামতের দিন তারা সকলেই তার পক্ষে সাক্ষ্য দেবে।"\n(সহীহ বুখারী: ৬০৯)',
                style: TextStyle(fontSize: 13, height: 1.4),
              ),
              SizedBox(height: 8),
              Text(
                '২. "যখন আযান দেওয়া হয়, তখন শয়তান আযানের শব্দ শুনে পিছন ফিরে পলায়ন করে।"\n(সহীহ বুখারী: ৬০৮)',
                style: TextStyle(fontSize: 13, height: 1.4),
              ),
              SizedBox(height: 8),
              Text(
                '৩. "যে ব্যক্তি আযান শুনে আযানের দোয়া পাঠ করে, তার জন্য কিয়ামতের দিন আমার সুপারিশ ওয়াজিব হয়ে যায়।"\n(সহীহ বুখারী: ৬১৪)',
                style: TextStyle(fontSize: 13, height: 1.4),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('মাশাআল্লাহ', style: TextStyle(color: AppColors.accentGold)),
          ),
        ],
      ),
    );
  }
}
