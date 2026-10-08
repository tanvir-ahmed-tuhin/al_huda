import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quran_provider.dart';
import '../theme/app_theme.dart';

class AudioPlayerBar extends StatelessWidget {
  const AudioPlayerBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QuranProvider>(
      builder: (context, quranProvider, child) {
        if (quranProvider.playingAyahIndex == null) {
          return const SizedBox.shrink();
        }

        final currentIndex = quranProvider.playingAyahIndex!;
        final ayah = (currentIndex >= 0 && currentIndex < quranProvider.currentAyahs.length)
            ? quranProvider.currentAyahs[currentIndex]
            : null;

        if (ayah == null) return const SizedBox.shrink();

        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCardElevated : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.accentGold.withValues(alpha: 0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Rotating / Animated Disc / Icon
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.primaryLight, AppColors.primary],
                  ),
                ),
                child: const Icon(
                  Icons.audiotrack_rounded,
                  color: AppColors.accentGold,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),

              // Ayah Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'আয়াত ${ayah.numberInSurah} • ${quranProvider.currentSurah?.nameBangla ?? ""}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Text(
                      'তিলাওয়াত: মিশারী রাশিদ আলাফাসী',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.accentGold,
                      ),
                    ),
                  ],
                ),
              ),

              // Player Controls: Previous
              IconButton(
                icon: const Icon(Icons.skip_previous_rounded, size: 24),
                onPressed: currentIndex > 0 ? () => quranProvider.playPreviousAyah() : null,
                tooltip: 'পূর্ববর্তী আয়াত',
              ),

              // Play / Pause
              if (quranProvider.isAudioLoading)
                const SizedBox(
                  width: 32,
                  height: 32,
                  child: Padding(
                    padding: EdgeInsets.all(6),
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.accentGold,
                    ),
                  ),
                )
              else
                IconButton(
                  icon: Icon(
                    quranProvider.isPlaying
                        ? Icons.pause_circle_filled_rounded
                        : Icons.play_circle_fill_rounded,
                    size: 36,
                    color: AppColors.accentGold,
                  ),
                  onPressed: () => quranProvider.playAyah(currentIndex),
                  tooltip: quranProvider.isPlaying ? 'বিরতি' : 'চালান',
                ),

              // Next
              IconButton(
                icon: const Icon(Icons.skip_next_rounded, size: 24),
                onPressed: currentIndex + 1 < quranProvider.currentAyahs.length
                    ? () => quranProvider.playNextAyahManual()
                    : null,
                tooltip: 'পরবর্তী আয়াত',
              ),

              // Close / Stop
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: () => quranProvider.stopAudio(),
                tooltip: 'বন্ধ করুন',
              ),
            ],
          ),
        );
      },
    );
  }
}
