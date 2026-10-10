import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:provider/provider.dart';
import '../models/azan_voice_model.dart';
import '../models/prayer_time_model.dart';
import '../providers/azan_provider.dart';
import '../services/azan_service.dart';
import '../theme/app_theme.dart';
import 'azan_dialog.dart';

class AzanFloatingBar extends StatelessWidget {
  const AzanFloatingBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AzanProvider>(
      builder: (context, azanProvider, child) {
        if (!azanProvider.isPlaying && !azanProvider.isLoading) {
          return const SizedBox.shrink();
        }

        final playingId = azanProvider.playingVoiceId;
        final AzanVoiceModel voice = (playingId != null && playingId.isNotEmpty)
            ? AzanService.getVoiceById(playingId)
            : azanProvider.selectedVoice;

        final prayerName = azanProvider.activePrayer != null
            ? PrayerTimeModel.getPrayerNameBangla(azanProvider.activePrayer!)
            : null;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => AzanDialog.show(context),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF0F5132),
                  Color(0xFF07291A),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.accentGold,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentGold.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Mosque Icon with Glow
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accentGold.withValues(alpha: 0.2),
                    border: Border.all(color: AppColors.accentGold, width: 1),
                  ),
                  child: const Icon(
                    IconlyBold.voice,
                    color: AppColors.accentGold,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),

                // Azan Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              prayerName != null ? '$prayerName নামাজের আযান' : 'আযান বাজছে',
                              style: const TextStyle(
                                color: AppColors.goldLight,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: azanProvider.isLoading ? Colors.orange.shade800 : Colors.red.shade700,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              azanProvider.isLoading ? 'লোড হচ্ছে' : 'চলছে',
                              style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'কণ্ঠ: ${voice.muadhin} (${voice.name})',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Dua / Details button
                IconButton(
                  icon: const Icon(IconlyBold.document, color: AppColors.goldLight, size: 20),
                  tooltip: 'আযানের দোয়া দেখুন',
                  onPressed: () => AzanDialog.show(context),
                ),

                // Stop Azan button
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => azanProvider.stopAzan(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red.shade800,
                    ),
                    child: const Icon(
                      IconlyBold.closeSquare,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
