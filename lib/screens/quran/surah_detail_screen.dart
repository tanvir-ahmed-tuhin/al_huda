import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:provider/provider.dart';
import '../../models/surah_model.dart';
import '../../providers/quran_provider.dart';
import '../../services/prayer_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/audio_player_bar.dart';

class SurahDetailScreen extends StatefulWidget {
  final SurahSummary surah;
  final int? initialAyahNumber;

  const SurahDetailScreen({
    super.key,
    required this.surah,
    this.initialAyahNumber,
  });

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final quranProvider = Provider.of<QuranProvider>(context, listen: false);
      quranProvider.loadSurah(widget.surah);
      quranProvider.setLastRead(
        widget.surah.number,
        widget.initialAyahNumber ?? 1,
        widget.surah.nameBangla,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final quranProvider = Provider.of<QuranProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(widget.surah.nameBangla),
            Text(
              '${widget.surah.meaningBangla} • ${widget.surah.revelationTypeBangla}',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(IconlyLight.setting, color: AppColors.accentGold),
            tooltip: 'ফন্ট ও অনুবাদ সেটিং',
            onPressed: () => _showSettingsModal(context, quranProvider, isDark),
          ),
        ],
      ),
      bottomNavigationBar: const AudioPlayerBar(),
      body: quranProvider.isLoadingAyahs
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.accentGold,
              ),
            )
          : CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Surah Header Banner
                SliverToBoxAdapter(
                  child: _buildSurahBanner(context, isDark),
                ),

                // Bismillah Banner (Except Surah At-Tawbah #9)
                if (widget.surah.number != 9 && widget.surah.number != 1)
                  SliverToBoxAdapter(
                    child: _buildBismillahBanner(context, isDark),
                  ),

                // Ayahs List
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final ayah = quranProvider.currentAyahs[index];
                        final isPlaying = quranProvider.playingAyahIndex == index;
                        final isBookmarked = quranProvider.isAyahBookmarked(
                          widget.surah.number,
                          ayah.numberInSurah,
                        );

                        return _buildAyahCard(
                          context,
                          ayah,
                          index,
                          isPlaying,
                          isBookmarked,
                          quranProvider,
                          isDark,
                        );
                      },
                      childCount: quranProvider.currentAyahs.length,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSurahBanner(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F5132),
            Color(0xFF0A2B1C),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F5132).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppColors.accentGold.withValues(alpha: 0.5),
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          Text(
            widget.surah.nameArabic,
            style: AppTheme.arabicText(
              fontSize: 28,
              color: AppColors.goldLight,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'সূরা ${widget.surah.nameBangla}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            widget.surah.meaningBangla,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.goldLight,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 1,
            width: 160,
            color: AppColors.accentGold.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 10),
          Text(
            '${widget.surah.revelationTypeBangla} • ${PrayerService.toBanglaDigits(widget.surah.numberOfAyahs.toString())} আয়াত',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBismillahBanner(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
          style: AppTheme.arabicText(
            fontSize: 24,
            color: isDark ? AppColors.accentGold : AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAyahCard(
    BuildContext context,
    Ayah ayah,
    int index,
    bool isPlaying,
    bool isBookmarked,
    QuranProvider quranProvider,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPlaying
            ? (isDark
                ? AppColors.primary.withValues(alpha: 0.35)
                : const Color(0xFFE8F5EE))
            : (isDark ? AppColors.darkCard : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPlaying
              ? AppColors.accentGold
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: isPlaying ? 1.8 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Ayah Top Action Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Ayah Number Badge
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isPlaying ? AppColors.accentGold : AppColors.primary.withValues(alpha: 0.15),
                  border: Border.all(
                    color: AppColors.accentGold,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    PrayerService.toBanglaDigits(ayah.numberInSurah.toString()),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isPlaying ? Colors.black : AppColors.accentGold,
                    ),
                  ),
                ),
              ),

              // Action Buttons: Play Audio, Bookmark, Copy
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      isPlaying
                          ? (quranProvider.isPlaying
                              ? IconlyBold.video
                              : IconlyBold.play)
                          : IconlyLight.play,
                      color: isPlaying ? AppColors.accentGold : (isDark ? Colors.white70 : AppColors.primary),
                      size: 22,
                    ),
                    tooltip: 'তেলাওয়াত শুনুন',
                    onPressed: () => quranProvider.playAyah(index),
                  ),
                  IconButton(
                    icon: Icon(
                      isBookmarked ? IconlyBold.bookmark : IconlyLight.bookmark,
                      color: isBookmarked ? AppColors.accentGold : (isDark ? Colors.white70 : AppColors.primary),
                      size: 22,
                    ),
                    tooltip: 'বুকমার্ক করুন',
                    onPressed: () {
                      quranProvider.toggleBookmark(
                        ayah,
                        widget.surah.nameBangla,
                        widget.surah.nameArabic,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isBookmarked ? 'বুকমার্ক সরানো হয়েছে' : 'বুকমার্কে যোগ করা হয়েছে',
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      IconlyLight.document,
                      color: isDark ? Colors.white70 : AppColors.primary,
                      size: 20,
                    ),
                    tooltip: 'কপি করুন',
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(
                          text: '${ayah.textArabic}\n\n${ayah.translationBangla}\n[সূরা ${widget.surah.nameBangla}: ${ayah.numberInSurah}]',
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('আয়াত কপি করা হয়েছে'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Arabic Uthmani Text
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              ayah.textArabic,
              textAlign: TextAlign.right,
              style: AppTheme.arabicText(
                fontSize: quranProvider.arabicFontSize,
                color: isDark ? Colors.white : AppColors.primaryDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Bengali Translation
          if (quranProvider.showBangla && ayah.translationBangla.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                ayah.translationBangla,
                style: AppTheme.banglaText(
                  fontSize: 14.5,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
            ),

          // English Translation
          if (quranProvider.showEnglish && ayah.translationEnglish.isNotEmpty)
            Text(
              ayah.translationEnglish,
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
        ],
      ),
    );
  }

  void _showSettingsModal(BuildContext context, QuranProvider quranProvider, bool isDark) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'পড়ার সেটিংস',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Arabic Font Size Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('আরবি ফন্ট সাইজ'),
                      Text(
                        '${PrayerService.toBanglaDigits(quranProvider.arabicFontSize.round().toString())} পিটি',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentGold,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: quranProvider.arabicFontSize,
                    min: 18.0,
                    max: 36.0,
                    divisions: 9,
                    activeColor: AppColors.accentGold,
                    onChanged: (val) {
                      quranProvider.setArabicFontSize(val);
                      setModalState(() {});
                    },
                  ),
                  const Divider(),

                  // Bangla Translation Switch
                  SwitchListTile(
                    title: const Text('বাংলা অনুবাদ দেখান'),
                    value: quranProvider.showBangla,
                    activeTrackColor: AppColors.accentGold,
                    onChanged: (val) {
                      quranProvider.toggleBangla(val);
                      setModalState(() {});
                    },
                  ),

                  // English Translation Switch
                  SwitchListTile(
                    title: const Text('ইংরেজি অনুবাদ দেখান'),
                    value: quranProvider.showEnglish,
                    activeTrackColor: AppColors.accentGold,
                    onChanged: (val) {
                      quranProvider.toggleEnglish(val);
                      setModalState(() {});
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
