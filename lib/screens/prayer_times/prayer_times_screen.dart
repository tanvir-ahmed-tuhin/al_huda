import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
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
            icon: prayerProvider.isLoadingLocation
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentGold),
                  )
                : Icon(
                    prayerProvider.isLiveLocation ? IconlyBold.location : IconlyLight.location,
                    color: prayerProvider.isLiveLocation ? const Color(0xFF10B981) : AppColors.accentGold,
                  ),
            tooltip: 'GPS লোকেশন সনাক্ত করুন',
            onPressed: () async {
              final ok = await prayerProvider.fetchLiveLocation(requestPermission: true);
              if (!context.mounted) return;
              if (ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('লোকেশন আপডেট হয়েছে: ${prayerProvider.currentLocationName}'),
                    backgroundColor: AppColors.primary,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(IconlyBold.voice, color: AppColors.accentGold),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(IconlyBold.calendar, color: AppColors.accentGold, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    pt.hijriDate,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),

              // Live GPS Location Action Chip
              InkWell(
                onTap: provider.isLoadingLocation
                    ? null
                    : () async {
                        final ok = await provider.fetchLiveLocation(requestPermission: true);
                        if (!context.mounted) return;
                        if (!ok && provider.locationStatusMessage != null) {
                          if (provider.locationStatusMessage!.contains('GPS')) {
                            await provider.openLocationSettings();
                          } else if (provider.locationStatusMessage!.contains('সেটিংসে')) {
                            await provider.openAppSettings();
                          }
                        }
                      },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: provider.isLiveLocation
                        ? const Color(0xFF10B981).withValues(alpha: 0.2)
                        : AppColors.accentGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: provider.isLiveLocation ? const Color(0xFF10B981) : AppColors.accentGold,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (provider.isLoadingLocation)
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentGold),
                        )
                      else
                        Icon(
                          provider.isLiveLocation ? IconlyBold.location : IconlyLight.location,
                          size: 14,
                          color: provider.isLiveLocation ? const Color(0xFF10B981) : AppColors.accentGold,
                        ),
                      const SizedBox(width: 5),
                      const Text(
                        'GPS লোকেশন',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentGold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Location details & manual city dropdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.currentLocationName,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${PrayerService.toBanglaDigits(provider.currentLatitude.toStringAsFixed(2))}° N, ${PrayerService.toBanglaDigits(provider.currentLongitude.toStringAsFixed(2))}° E',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              DropdownButtonHideUnderline(
                child: DropdownButton<CityLocation>(
                  value: !provider.isLiveLocation && QiblaService.defaultCities.contains(provider.selectedCity)
                      ? provider.selectedCity
                      : null,
                  hint: const Text('জেলা পরিবর্তন', style: TextStyle(fontSize: 12, color: AppColors.accentGold)),
                  icon: const Icon(IconlyLight.arrowDown2, color: AppColors.accentGold, size: 16),
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

          if (provider.locationStatusMessage != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(IconlyBold.danger, color: Colors.orange, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      provider.locationStatusMessage!,
                      style: const TextStyle(fontSize: 11, color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNextPrayerCard(BuildContext context, PrayerTimeModel pt, bool isDark) {
    final nextPrayer = pt.currentOrNextPrayer;
    final nextName = PrayerTimeModel.getPrayerNameBangla(nextPrayer);
    final nextTime = PrayerService.formatTimeOfDayBangla(pt.getTimeForPrayer(nextPrayer));
    final duration = pt.timeUntilNextPrayer;
    final totalSeconds = duration.isNegative ? 0 : duration.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    final String timeRemainingStr;
    if (hours > 0) {
      timeRemainingStr =
          '${PrayerService.toBanglaDigits(hours.toString())} ঘণ্টা ${PrayerService.toBanglaDigits(minutes.toString())} মি. ${PrayerService.toBanglaDigits(seconds.toString().padLeft(2, '0'))} সে. বাকি';
    } else if (minutes > 0) {
      timeRemainingStr =
          '${PrayerService.toBanglaDigits(minutes.toString())} মিনিট ${PrayerService.toBanglaDigits(seconds.toString().padLeft(2, '0'))} সেকেন্ড বাকি';
    } else {
      timeRemainingStr =
          '${PrayerService.toBanglaDigits(seconds.toString())} সেকেন্ড বাকি';
    }

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
              IconlyBold.voice,
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
              azanProvider.isPlaying ? IconlyBold.video : IconlyBold.play,
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
          const Icon(IconlyLight.arrowRight2, size: 14, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildPrayerList(BuildContext context, PrayerTimeModel pt, bool isDark) {
    final prayers = [
      {'prayer': PrayerName.fajr, 'icon': IconlyBold.timeCircle},
      {'prayer': PrayerName.sunrise, 'icon': IconlyBold.star},
      {'prayer': PrayerName.dhuhr, 'icon': IconlyBold.star},
      {'prayer': PrayerName.asr, 'icon': IconlyLight.timeCircle},
      {'prayer': PrayerName.maghrib, 'icon': IconlyLight.star},
      {'prayer': PrayerName.isha, 'icon': IconlyBold.timeCircle},
    ];

    final currentPrayer = pt.currentOrNextPrayer;

    return Column(
      children: prayers.map((item) {
        final prayer = item['prayer'] as PrayerName;
        final icon = item['icon'] as IconData;
        final name = PrayerTimeModel.getPrayerNameBangla(prayer);
        final arabicName = PrayerTimeModel.getPrayerNameArabic(prayer);
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
                            arabicName,
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Amiri',
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
                const Icon(IconlyLight.star, color: AppColors.accentGold, size: 22),
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
                const Icon(IconlyBold.star, color: AppColors.accentGold, size: 22),
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
