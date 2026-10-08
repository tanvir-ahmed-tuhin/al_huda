import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/prayer_time_model.dart';
import '../../providers/azan_provider.dart';
import '../../providers/prayer_provider.dart';
import '../../services/prayer_service.dart';
import '../../services/qibla_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/azan_dialog.dart';
import '../../widgets/glass_card.dart';
import 'azan_settings_screen.dart';

class PrayerTimesScreen extends StatelessWidget {
  const PrayerTimesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final prayerProvider = Provider.of<PrayerProvider>(context);
    final pt = prayerProvider.prayerTimes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('নামাজের সময়সূচি'),
        actions: [
          IconButton(
            icon: const Icon(Icons.campaign_rounded, color: AppColors.accentGold),
            tooltip: 'আযানের কণ্ঠ ও সেটিংস',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AzanSettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: pt == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.accentGold))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Column(
                children: [
                  // Location and Date Card
                  _buildDateLocationCard(context, pt, prayerProvider, isDark),
                  const SizedBox(height: 16),

                  // Active Prayer Card
                  _buildNextPrayerCard(context, pt, isDark),
                  const SizedBox(height: 14),

                  // Azan Voice & Settings Banner
                  _buildAzanBanner(context, isDark),
                  const SizedBox(height: 16),

                  // Full Prayer Timetable List
                  _buildPrayerList(context, pt, isDark),
                  const SizedBox(height: 16),

                  // Sehri & Iftar / Tahajjud Times
                  _buildExtraTimesCard(context, pt, isDark),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildDateLocationCard(
    BuildContext context,
    PrayerTimeModel pt,
    PrayerProvider provider,
    bool isDark,
  ) {
    return IslamicCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_month_rounded, color: AppColors.accentGold, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    pt.hijriDate,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              DropdownButtonHideUnderline(
                child: DropdownButton<CityLocation>(
                  value: QiblaService.defaultCities.contains(provider.selectedCity)
                      ? provider.selectedCity
                      : null,
                  hint: Text(provider.selectedCity.nameBangla, style: const TextStyle(fontSize: 12)),
                  icon: const Icon(Icons.arrow_drop_down, color: AppColors.accentGold),
                  dropdownColor: isDark ? AppColors.darkCardElevated : Colors.white,
                  items: QiblaService.defaultCities.map((city) {
                    return DropdownMenuItem<CityLocation>(
                      value: city,
                      child: Text(city.nameBangla, style: const TextStyle(fontSize: 12)),
                    );
                  }).toList(),
                  onChanged: (CityLocation? city) {
                    if (city != null) {
                      provider.setCity(city);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNextPrayerCard(BuildContext context, PrayerTimeModel pt, bool isDark) {
    final nextPrayer = pt.currentOrNextPrayer;
    final nextName = PrayerTimeModel.getPrayerNameBangla(nextPrayer);
    final nextTime = PrayerService.formatTimeOfDayBangla(pt.getTimeForPrayer(nextPrayer));
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
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF072B19)],
        ),
        border: Border.all(color: AppColors.accentGold, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'পরবর্তী ওয়াক্ত',
                style: TextStyle(color: AppColors.goldLight, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                nextName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                timeRemainingStr,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          Text(
            nextTime,
            style: const TextStyle(
              color: AppColors.goldLight,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAzanBanner(BuildContext context, bool isDark) {
    final azanProvider = Provider.of<AzanProvider>(context);
    final voice = azanProvider.selectedVoice;

    return IslamicCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderColor: azanProvider.isMasterEnabled ? AppColors.accentGold.withValues(alpha: 0.5) : null,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AzanSettingsScreen()),
        );
      },
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: azanProvider.isMasterEnabled
                  ? AppColors.accentGold.withValues(alpha: 0.15)
                  : (isDark ? AppColors.darkCardElevated : Colors.grey.shade200),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.campaign_rounded,
              color: azanProvider.isMasterEnabled ? AppColors.accentGold : Colors.grey,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'আযানের কণ্ঠ',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: azanProvider.isMasterEnabled
                            ? const Color(0xFF10B981).withValues(alpha: 0.2)
                            : Colors.grey.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        azanProvider.isMasterEnabled ? 'চালু' : 'বন্ধ',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: azanProvider.isMasterEnabled
                              ? const Color(0xFF10B981)
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${voice.muadhin} (${voice.name})',
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
          const SizedBox(width: 6),
          IconButton(
            icon: Icon(
              azanProvider.isPlaying ? Icons.stop_circle_rounded : Icons.play_circle_fill_rounded,
              color: AppColors.accentGold,
              size: 30,
            ),
            tooltip: azanProvider.isPlaying ? 'আযান বন্ধ করুন' : 'আযান শুনুন',
            onPressed: () {
              if (azanProvider.isPlaying) {
                azanProvider.stopAzan();
              } else {
                azanProvider.triggerAzanForPrayer(PrayerName.dhuhr, isManualTest: true);
                AzanDialog.show(context);
              }
            },
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildPrayerList(BuildContext context, PrayerTimeModel pt, bool isDark) {
    final prayers = [
      {'prayer': PrayerName.fajr, 'icon': Icons.nights_stay_rounded},
      {'prayer': PrayerName.sunrise, 'icon': Icons.wb_sunny_rounded},
      {'prayer': PrayerName.dhuhr, 'icon': Icons.wb_sunny_outlined},
      {'prayer': PrayerName.asr, 'icon': Icons.wb_cloudy_rounded},
      {'prayer': PrayerName.maghrib, 'icon': Icons.wb_twilight_rounded},
      {'prayer': PrayerName.isha, 'icon': Icons.bedtime_rounded},
    ];

    final currentPrayer = pt.currentOrNextPrayer;

    return Column(
      children: prayers.map((item) {
        final prayer = item['prayer'] as PrayerName;
        final icon = item['icon'] as IconData;
        final name = PrayerTimeModel.getPrayerNameBangla(prayer);
        final englishName = PrayerTimeModel.getPrayerNameEnglish(prayer);
        final timeStr = PrayerService.formatTimeOfDayBangla(pt.getTimeForPrayer(prayer));
        final isCurrent = prayer == currentPrayer;

        return IslamicCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          borderColor: isCurrent ? AppColors.accentGold : null,
          gradient: isCurrent
              ? LinearGradient(
                  colors: isDark
                      ? [
                          const Color(0xFF1E3D2C),
                          const Color(0xFF142B1F),
                        ]
                      : [
                          const Color(0xFFE5F5EC),
                          const Color(0xFFD3EDE0),
                        ],
                )
              : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? AppColors.accentGold.withValues(alpha: 0.2)
                            : (isDark ? AppColors.darkCardElevated : AppColors.lightCard),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        icon,
                        color: isCurrent ? AppColors.accentGold : (isDark ? Colors.white70 : AppColors.primary),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: isCurrent ? AppColors.accentGold : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            englishName,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isCurrent)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accentGold,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'চলমান',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  Text(
                    timeStr,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isCurrent ? AppColors.accentGold : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExtraTimesCard(BuildContext context, PrayerTimeModel pt, bool isDark) {
    // Sehri ends 5 mins before Fajr
    final fajrMins = pt.fajr.hour * 60 + pt.fajr.minute - 5;
    final sehriHour = (fajrMins ~/ 60) % 24;
    final sehriMin = fajrMins % 60;
    final sehriTod = TimeOfDay(hour: sehriHour, minute: sehriMin);
    final sehriStr = PrayerService.formatTimeOfDayBangla(sehriTod);
    final iftarStr = PrayerService.formatTimeOfDayBangla(pt.maghrib);

    return Row(
      children: [
        Expanded(
          child: IslamicCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                const Icon(Icons.nightlight_outlined, color: AppColors.accentGold, size: 22),
                const SizedBox(height: 4),
                const Text('সাহরীর শেষ সময়', style: TextStyle(fontSize: 12)),
                const SizedBox(height: 2),
                Text(
                  sehriStr,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                const Icon(Icons.wb_twilight_rounded, color: AppColors.accentGold, size: 22),
                const SizedBox(height: 4),
                const Text('ইফতারের সময়', style: TextStyle(fontSize: 12)),
                const SizedBox(height: 2),
                Text(
                  iftarStr,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
