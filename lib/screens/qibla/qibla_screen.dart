import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:provider/provider.dart';

import '../../providers/qibla_provider.dart';
import '../../services/prayer_service.dart';
import '../../services/qibla_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/qibla_compass_dial.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  bool _hasVibratedForAlignment = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final qiblaProvider = Provider.of<QiblaProvider>(context);

    // Haptic feedback when facing Qibla
    if (qiblaProvider.isFacingQibla) {
      if (!_hasVibratedForAlignment) {
        HapticFeedback.mediumImpact();
        _hasVibratedForAlignment = true;
      }
    } else {
      _hasVibratedForAlignment = false;
    }

    final qiblaDegStr = PrayerService.toBanglaDigits(
      qiblaProvider.qiblaAngle.toStringAsFixed(1),
    );

    final distanceStr = PrayerService.toBanglaDigits(
      qiblaProvider.distanceToKaabaKm.toStringAsFixed(0),
    );

    final directionName = QiblaService.getDirectionNameBangla(
      qiblaProvider.qiblaAngle,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('ক্বিবলা কম্পাস'),
        actions: [
          IconButton(
            icon: const Icon(
              IconlyBold.location,
              color: AppColors.accentGold,
            ),
            tooltip: 'জিপিএস লোকেশন সনাক্ত করুন',
            onPressed: () async {
              await qiblaProvider.fetchCurrentGpsLocation();

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'লোকেশন: ${qiblaProvider.selectedCity.nameBangla}',
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          children: [
            // ==============================
            // LOCATION SELECTOR
            // ==============================
            _buildLocationSelector(context, qiblaProvider, isDark),

            const SizedBox(height: 16),

            // ==============================
            // QIBLA STATUS
            // ==============================
            _buildAlignmentStatusBanner(qiblaProvider, isDark),

            const SizedBox(height: 24),

            // ==============================
            // COMPASS
            // ==============================
            QiblaCompassDial(
              deviceHeading: qiblaProvider.deviceHeading,
              qiblaAngle: qiblaProvider.qiblaAngle,
              isFacingQibla: qiblaProvider.isFacingQibla,
              size: 290,
            ),

            const SizedBox(height: 28),

            // ==============================
            // DEGREE & DISTANCE CARDS
            // ==============================
            Row(
              children: [
                Expanded(
                  child: IslamicCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        const Text(
                          'ক্বিবলার কোণ',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.accentGold,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          '$qiblaDegStr°',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Text(
                          directionName,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                        const Text(
                          'মক্কার দূরত্ব',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.accentGold,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 4),

                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '$distanceStr কি.মি.',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        Text(
                          'মক্কা মুকাররমা',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ==============================
            // SENSOR INFORMATION
            // ==============================
            IslamicCard(
              padding: const EdgeInsets.all(14),
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF15261C), const Color(0xFF0D1812)]
                    : [const Color(0xFFF3FAF6), const Color(0xFFE5F2EB)],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    IconlyLight.infoSquare,
                    color: AppColors.accentGold,
                    size: 22,
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      'সঠিক দিক নির্দেশনার জন্য ফোনটিকে সমতলে রাখুন এবং কাবার পয়েন্টার ও কম্পাসের কাঁটা মেলান।',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ==============================
            // MANUAL COMPASS TESTING
            // ==============================
            ExpansionTile(
              title: const Text(
                'ম্যানুয়াল কম্পাস রোটেশন (টেস্টিং)',
                style: TextStyle(fontSize: 13, color: AppColors.accentGold),
              ),

              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Column(
                    children: [
                      Text(
                        'ডিভাইস হেডিং: ${qiblaProvider.deviceHeading.round()}°',
                        style: const TextStyle(fontSize: 12),
                      ),

                      Slider(
                        value: qiblaProvider.deviceHeading.clamp(0.0, 360.0),
                        min: 0,
                        max: 360,
                        activeColor: AppColors.accentGold,
                        onChanged: (val) {
                          qiblaProvider.setManualHeading(val);
                        },
                      ),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            qiblaProvider.setManualHeading(
                              qiblaProvider.qiblaAngle,
                            );
                          },
                          icon: const Icon(
                            IconlyBold.tickSquare,
                            size: 18,
                          ),
                          label: const Text('ক্বিবলার দিকে সেট করুন'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // LOCATION SELECTOR
  // ============================================================

  Widget _buildLocationSelector(
    BuildContext context,
    QiblaProvider provider,
    bool isDark,
  ) {
    return IslamicCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // --------------------------------
          // LOCATION NAME
          // --------------------------------
          Expanded(
            flex: 5,
            child: Row(
              children: [
                const Icon(
                  IconlyBold.discovery,
                  color: AppColors.accentGold,
                  size: 20,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'নির্বাচিত জেলা',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.accentGold,
                        ),
                      ),

                      Text(
                        provider.selectedCity.nameBangla,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
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

          // --------------------------------
          // DISTRICT DROPDOWN
          // --------------------------------
          Expanded(
            flex: 4,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<CityLocation>(
                // IMPORTANT:
                // This forces dropdown to stay inside available width.
                isExpanded: true,
                isDense: true,

                value: provider.cities.contains(provider.selectedCity)
                    ? provider.selectedCity
                    : null,

                hint: const Text(
                  'জেলা পরিবর্তন',
                  style: TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                icon: const Icon(
                  IconlyLight.arrowDown2,
                  color: AppColors.accentGold,
                  size: 22,
                ),

                dropdownColor: isDark
                    ? AppColors.darkCardElevated
                    : Colors.white,

                items: provider.cities.map((city) {
                  return DropdownMenuItem<CityLocation>(
                    value: city,

                    child: Text(
                      city.nameBangla,
                      style: const TextStyle(fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),

                onChanged: (CityLocation? newCity) {
                  if (newCity != null) {
                    provider.selectCity(newCity);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QIBLA ALIGNMENT STATUS
  // ============================================================

  Widget _buildAlignmentStatusBanner(QiblaProvider provider, bool isDark) {
    final isFacing = provider.isFacingQibla;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),

      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),

      decoration: BoxDecoration(
        color: isFacing
            ? AppColors.qiblaActive.withValues(alpha: 0.2)
            : (isDark ? AppColors.darkCard : AppColors.lightCard),

        borderRadius: BorderRadius.circular(16),

        border: Border.all(
          color: isFacing ? AppColors.qiblaActive : Colors.transparent,
          width: 1.5,
        ),
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isFacing ? IconlyBold.tickSquare : IconlyBold.discovery,

            color: isFacing ? AppColors.qiblaActive : AppColors.accentGold,

            size: 22,
          ),

          const SizedBox(width: 8),

          // Flexible prevents text overflow
          Flexible(
            child: Text(
              isFacing
                  ? 'মাশাআল্লাহ! আপনি ক্বিবলার মুখোমুখি আছেন'
                  : 'তীর চিহ্ন বরাবর ফোন ঘোরান',

              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13.5,
                color: isFacing
                    ? AppColors.qiblaActive
                    : (isDark ? Colors.white70 : AppColors.primaryDark),
              ),

              textAlign: TextAlign.center,

              maxLines: 2,

              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
