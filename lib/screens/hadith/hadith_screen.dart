import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/hadith_model.dart';
import '../../services/hadith_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';

class HadithScreen extends StatefulWidget {
  const HadithScreen({super.key});

  @override
  State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen> {
  String _selectedBookId = 'ben-bukhari';
  int _selectedSectionNumber = 1;
  final TextEditingController _searchController = TextEditingController();

  HadithItem? _searchedHadith;
  bool _isSearching = false;
  String? _searchError;

  List<HadithItem> _sectionHadiths = [];
  bool _isLoadingSection = false;

  @override
  void initState() {
    super.initState();
    _loadSectionHadiths(_selectedBookId, _selectedSectionNumber);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSectionHadiths(String bookId, int sectionNumber) async {
    setState(() {
      _selectedBookId = bookId;
      _selectedSectionNumber = sectionNumber;
      _isLoadingSection = true;
      _searchedHadith = null;
      _searchError = null;
    });

    final hadiths = await HadithService.getHadithsBySection(bookId, sectionNumber);
    if (mounted) {
      setState(() {
        _sectionHadiths = hadiths;
        _isLoadingSection = false;
      });
    }
  }

  void _onBookChanged(String newBookId) {
    if (newBookId == _selectedBookId) return;
    final sections = HadithService.bookSections[newBookId] ?? [];
    final firstSectionNum = sections.isNotEmpty ? sections.first.number : 1;
    _loadSectionHadiths(newBookId, firstSectionNum);
  }

  Future<void> _searchHadithByNumber() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    // Convert Bengali numerals to standard numbers
    final cleanQuery = query
        .replaceAll('০', '0')
        .replaceAll('১', '1')
        .replaceAll('২', '2')
        .replaceAll('৩', '3')
        .replaceAll('৪', '4')
        .replaceAll('৫', '5')
        .replaceAll('৬', '6')
        .replaceAll('৭', '7')
        .replaceAll('৮', '8')
        .replaceAll('৯', '9');

    final number = int.tryParse(cleanQuery);
    if (number == null || number <= 0) {
      setState(() {
        _searchError = 'অনুগ্রহ করে সঠিক হাদিস নম্বর লিখুন (যেমন: ১, ১৩, ১০০, ৮৭৬)';
        _searchedHadith = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchError = null;
    });

    FocusScope.of(context).unfocus();

    final item = await HadithService.getHadithByNumber(_selectedBookId, number);
    if (mounted) {
      setState(() {
        _isSearching = false;
        if (item != null) {
          _searchedHadith = item;
          _searchError = null;
        } else {
          _searchedHadith = null;
          _searchError = '${HadithService.getBookBanglaName(_selectedBookId)}-এ $number নং হাদিস পাওয়া যায়নি।';
        }
      });
    }
  }

  void _copyToClipboard(HadithItem hadith) {
    final text = '${hadith.text}\n\nরেফারেন্স: ${hadith.reference}';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.accentGold, size: 18),
            SizedBox(width: 8),
            Text('হাদিস কপি করা হয়েছে!'),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final availableSections = HadithService.bookSections[_selectedBookId] ?? [];
    final currentSection = availableSections.firstWhere(
      (s) => s.number == _selectedSectionNumber,
      orElse: () => availableSections.isNotEmpty
          ? availableSections.first
          : const HadithSection(number: 1, nameBangla: 'প্রথম অধ্যায়', nameEnglish: ''),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'হাদিস শরিফ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Filter & Search Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hadith Number Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : const Color(0xFFF1F5F2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.accentGold.withValues(alpha: 0.4),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Icon(
                          Icons.search_rounded,
                          color: AppColors.accentGold,
                          size: 20,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.search,
                          onSubmitted: (_) => _searchHadithByNumber(),
                          style: const TextStyle(fontSize: 13.5),
                          decoration: InputDecoration(
                            hintText: 'হাদিস নম্বর লিখে খুঁজুন (যেমন: ১, ১৩, ৮৭৬)...',
                            hintStyle: TextStyle(
                              fontSize: 12.5,
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchedHadith = null;
                              _searchError = null;
                            });
                          },
                        ),
                      Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.accentGold,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          icon: _isSearching
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                )
                              : const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 18,
                                  color: Colors.black,
                                ),
                          onPressed: _isSearching ? null : _searchHadithByNumber,
                          tooltip: 'অনুসন্ধান করুন',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Book Selector Horizontal Chips
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: HadithService.books.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final book = HadithService.books[index];
                      final isSelected = book.id == _selectedBookId;

                      return InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => _onBookChanged(book.id),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.accentGold
                                : (isDark ? AppColors.darkCard : Colors.grey.shade100),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.accentGold
                                  : (isDark ? AppColors.darkBorder : Colors.black12),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            book.nameBangla,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              color: isSelected
                                  ? Colors.black
                                  : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 10),

                // Section/Chapter Selector Horizontal Chips
                if (availableSections.isNotEmpty) ...[
                  SizedBox(
                    height: 34,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: availableSections.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final section = availableSections[index];
                        final isSelected = section.number == _selectedSectionNumber;

                        return InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            if (!isSelected) {
                              _loadSectionHadiths(_selectedBookId, section.number);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : (isDark
                                      ? AppColors.darkCardElevated
                                      : Colors.white),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.accentGold
                                    : (isDark
                                        ? AppColors.darkBorder
                                        : Colors.grey.shade300),
                                width: isSelected ? 1.2 : 0.7,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  section.nameBangla,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected
                                        ? Colors.white
                                        : (isDark ? Colors.white70 : Colors.black87),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Main Hadith List Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Search Error Alert
                if (_searchError != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, color: Colors.redAccent, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _searchError!,
                            style: const TextStyle(color: Colors.redAccent, fontSize: 12.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Searched Hadith Result
                if (_searchedHadith != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'অনুসন্ধানকৃত হাদিস',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.close_rounded, size: 16),
                        label: const Text('বন্ধ করুন'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.accentGold,
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () {
                          setState(() {
                            _searchedHadith = null;
                            _searchController.clear();
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildHadithCard(_searchedHadith!, isDark, isFeatured: true),
                  const SizedBox(height: 18),
                ],

                // Chapter Header with Hadith Count
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${currentSection.nameBangla} (${_sectionHadiths.length}টি হাদিস)',
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      HadithService.getBookBanglaName(_selectedBookId),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accentGold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Hadiths of this Chapter
                if (_isLoadingSection)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(50),
                      child: CircularProgressIndicator(color: AppColors.accentGold),
                    ),
                  )
                else if (_sectionHadiths.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Text(
                        'এই অধ্যায়ে কোনো হাদিস পাওয়া যায়নি।',
                        style: TextStyle(
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _sectionHadiths.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final hadith = _sectionHadiths[index];
                      return _buildHadithCard(hadith, isDark);
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHadithCard(HadithItem hadith, bool isDark, {bool isFeatured = false}) {
    return IslamicCard(
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      borderColor: isFeatured
          ? AppColors.accentGold
          : AppColors.accentGold.withValues(alpha: 0.35),
      gradient: LinearGradient(
        colors: isDark
            ? [const Color(0xFF1E3A2B), const Color(0xFF10281C)]
            : [const Color(0xFFF2FAF5), const Color(0xFFE2F3E9)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentGold,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  hadith.reference,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy_rounded, size: 18),
                color: AppColors.accentGold,
                onPressed: () => _copyToClipboard(hadith),
                tooltip: 'কপি করুন',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            hadith.text,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.6,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : AppColors.darkCard,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '— ${hadith.bookName}',
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: AppColors.accentGold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
