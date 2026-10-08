import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/surah_model.dart';
import '../../providers/quran_provider.dart';
import '../../services/prayer_service.dart';
import '../../services/quran_data_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import 'surah_detail_screen.dart';

class SurahListScreen extends StatefulWidget {
  const SurahListScreen({super.key});

  @override
  State<SurahListScreen> createState() => _SurahListScreenState();
}

class _SurahListScreenState extends State<SurahListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final quranProvider = Provider.of<QuranProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('পবিত্র আল-কুরআন'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accentGold,
          labelColor: AppColors.accentGold,
          unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          tabs: const [
            Tab(text: 'সূরা সমূহ (১১৪)'),
            Tab(text: 'প্যারা / জুয (৩০)'),
            Tab(text: 'বুকমার্ক'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => quranProvider.searchSurahs(val),
              decoration: InputDecoration(
                hintText: 'সূরার নাম বা নম্বর দিয়ে খুঁজুন...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.accentGold),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          quranProvider.searchSurahs('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.accentGold,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Surah List
                _buildSurahListView(context, quranProvider.filteredSurahs, isDark),

                // Tab 2: Juz List
                _buildJuzListView(context, isDark),

                // Tab 3: Bookmarks List
                _buildBookmarksView(context, quranProvider, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurahListView(BuildContext context, List<SurahSummary> surahs, bool isDark) {
    if (surahs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded, size: 56, color: AppColors.accentGold),
            const SizedBox(height: 12),
            Text(
              'কোনো সূরা পাওয়া যায়নি',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: surahs.length,
      itemBuilder: (context, index) {
        final surah = surahs[index];
        return IslamicCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SurahDetailScreen(surah: surah),
              ),
            );
          },
          child: Row(
            children: [
              // Surah Number in Islamic Star/Circle
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? AppColors.darkCardElevated : AppColors.lightCard,
                  border: Border.all(
                    color: AppColors.accentGold.withValues(alpha: 0.6),
                    width: 1.2,
                  ),
                ),
                child: Center(
                  child: Text(
                    PrayerService.toBanglaDigits(surah.number.toString()),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.accentGold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Surah Names & Meta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      surah.nameBangla,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${surah.meaningBangla} • ${surah.revelationTypeBangla} • ${PrayerService.toBanglaDigits(surah.numberOfAyahs.toString())} আয়াত',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Arabic Name
              Text(
                surah.nameArabic,
                style: AppTheme.arabicText(
                  fontSize: 20,
                  color: isDark ? AppColors.goldLight : AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildJuzListView(BuildContext context, bool isDark) {
    // 30 Juz List
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: 30,
      itemBuilder: (context, index) {
        final juzNumber = index + 1;
        // Approximate first surah for each juz
        final surahForJuz = _getSurahForJuz(juzNumber);

        return IslamicCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SurahDetailScreen(surah: surahForJuz),
              ),
            );
          },
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.primary.withValues(alpha: 0.15),
                  border: Border.all(color: AppColors.accentGold, width: 1),
                ),
                child: Center(
                  child: Text(
                    PrayerService.toBanglaDigits(juzNumber.toString()),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.accentGold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'প্যারা / পারা ${PrayerService.toBanglaDigits(juzNumber.toString())}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'শুরু: সূরা ${surahForJuz.nameBangla}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.accentGold,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBookmarksView(BuildContext context, QuranProvider quranProvider, bool isDark) {
    final bookmarks = quranProvider.bookmarks;

    if (bookmarks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bookmark_border_rounded, size: 64, color: AppColors.accentGold),
            const SizedBox(height: 12),
            const Text(
              'কোনো বুকমার্ক সংরক্ষিত নেই',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'কুরআন পড়ার সময় যেকোনো আয়াত বুকমার্কে সংরক্ষণ করুন',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: bookmarks.length,
      itemBuilder: (context, index) {
        final b = bookmarks[index];
        final surah = QuranDataService.surahList.firstWhere(
          (s) => s.number == b.surahNumber,
          orElse: () => QuranDataService.surahList[0],
        );

        return IslamicCard(
          padding: const EdgeInsets.all(14),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SurahDetailScreen(
                  surah: surah,
                  initialAyahNumber: b.ayahNumber,
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
                  Text(
                    'সূরা ${b.surahNameBangla} • আয়াত ${PrayerService.toBanglaDigits(b.ayahNumber.toString())}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.accentGold,
                    ),
                  ),
                  Text(
                    b.surahNameArabic,
                    style: AppTheme.arabicText(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  b.ayahTextArabic,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.arabicText(fontSize: 18),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                b.ayahTextBangla,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  SurahSummary _getSurahForJuz(int juzNumber) {
    const juzStartSurahs = [
      1, 2, 2, 3, 4, 4, 5, 6, 7, 8,
      9, 11, 12, 15, 17, 18, 21, 23, 25, 27,
      29, 33, 36, 39, 41, 46, 51, 58, 67, 78
    ];
    final surahNum = (juzNumber >= 1 && juzNumber <= 30) ? juzStartSurahs[juzNumber - 1] : 1;
    return QuranDataService.surahList.firstWhere(
      (s) => s.number == surahNum,
      orElse: () => QuranDataService.surahList[0],
    );
  }
}
