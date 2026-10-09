import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:provider/provider.dart';
import '../models/prayer_time_model.dart';
import '../providers/azan_provider.dart';
import '../services/azan_service.dart';
import '../services/prayer_service.dart';
import '../theme/app_theme.dart';

class AzanDialog extends StatelessWidget {
  const AzanDialog({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AzanDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final azanProvider = Provider.of<AzanProvider>(context);
    final voice = azanProvider.playingVoiceId != null
        ? AzanService.getVoiceById(azanProvider.playingVoiceId!)
        : azanProvider.selectedVoice;

    final activePrayerName = azanProvider.activePrayer != null
        ? PrayerTimeModel.getPrayerNameBangla(azanProvider.activePrayer!)
        : null;

    final title = activePrayerName != null
        ? '$activePrayerName নামাজের আযানের সময় হয়েছে'
        : 'আযান চলছে';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF13231B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),

            // Mosque Glowing Icon
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [
                    AppColors.accentGold,
                    Color(0xFF8A6D1C),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentGold.withValues(alpha: 0.4),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                IconlyBold.voice,
                color: Colors.black87,
                size: 40,
              ),
            ),
            const SizedBox(height: 14),

            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.goldLight : AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),

            // Voice info
            Text(
              voice.name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              'মুয়াজ্জিন: ${voice.muadhin} • ${voice.location}',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Progress Slider
            if (azanProvider.totalDuration > Duration.zero) ...[
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  thumbColor: AppColors.accentGold,
                  activeTrackColor: AppColors.accentGold,
                  inactiveTrackColor: AppColors.accentGold.withValues(alpha: 0.2),
                  trackHeight: 3,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                ),
                child: Slider(
                  value: azanProvider.currentPosition.inMilliseconds
                      .clamp(0, azanProvider.totalDuration.inMilliseconds)
                      .toDouble(),
                  max: azanProvider.totalDuration.inMilliseconds.toDouble(),
                  onChanged: (val) {},
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(azanProvider.currentPosition),
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    Text(
                      _formatDuration(azanProvider.totalDuration),
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 14),

            // Audio Controls: Stop and Play/Pause
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Stop Azan button
                ElevatedButton.icon(
                  onPressed: () {
                    azanProvider.stopAzan();
                    Navigator.pop(context);
                  },
                  icon: const Icon(IconlyBold.closeSquare, size: 20),
                  label: const Text('আযান বন্ধ করুন'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Play / Pause Preview
                OutlinedButton.icon(
                  onPressed: () {
                    if (azanProvider.isPlaying) {
                      azanProvider.stopAzan();
                    } else {
                      azanProvider.toggleVoicePreview(voice);
                    }
                  },
                  icon: Icon(
                    azanProvider.isPlaying ? IconlyBold.video : IconlyBold.play,
                    color: AppColors.accentGold,
                  ),
                  label: Text(
                    azanProvider.isPlaying ? 'বিরতি' : 'চালান',
                    style: const TextStyle(color: AppColors.accentGold),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.accentGold),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),

            // Azan Dua Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCardElevated : const Color(0xFFF9FBF9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.accentGold.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(IconlyBold.star, color: AppColors.accentGold, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'আযানের পরের দোয়া',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.goldLight : AppColors.primary,
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'সহীহ বুখারী: ৬১৪',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Arabic
                  const Text(
                    'اللَّهُمَّ رَبَّ هَذِهِ الدَّعْوَةِ التَّامَّةِ ، وَالصَّلاَةِ الْقَائِمَةِ ، آتِ مُحَمَّدًا الْوَسِيلَةَ وَالْفَضِيلَةَ ، وَابْعَثْهُ مَقَامًا مَحْمُودًا الَّذِي وَعَدْتَهُ',
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 17,
                      height: 1.8,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 8),
                  // Pronunciation
                  Text(
                    'উচ্চারণ: "আল্লাহুম্মা রব্বা হাযিহিদ দাওয়াতিত তাম্মাহ, ওয়াস সালাতিল কায়িমাহ, আতি মুহাম্মাদানিল ওয়াসীলাতা ওয়াল ফাদীলাহ, ওয়াব\'আসহু মাক্বামাম মাহমূদানিল্লাযী ওয়া\'আদতাহ।"',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: isDark ? Colors.white70 : Colors.black87,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Meaning
                  Text(
                    'অর্থ: হে আল্লাহ! এই পরিপূর্ণ আহ্বান এবং প্রতিষ্ঠিত নামাজের মালিক! হযরত মুহাম্মদ (সা.)-কে ওসীলা (সর্বোচ্চ জান্নাত) ও মর্যাদা দান করুন এবং তাঁকে সেই প্রশংসিত স্থানে পৌঁছিয়ে দিন যার প্রতিশ্রুতি আপনি দিয়েছেন।',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    final minStr = minutes.toString().padLeft(2, '0');
    final secStr = seconds.toString().padLeft(2, '0');
    return PrayerService.toBanglaDigits('$minStr:$secStr');
  }
}
