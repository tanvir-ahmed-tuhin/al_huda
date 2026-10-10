import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/mosque_model.dart';
import '../../providers/prayer_provider.dart';
import '../../services/mosque_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import 'mosque_map_screen.dart';

class NearbyMosquesScreen extends StatefulWidget {
  const NearbyMosquesScreen({super.key});

  @override
  State<NearbyMosquesScreen> createState() => _NearbyMosquesScreenState();
}

class _NearbyMosquesScreenState extends State<NearbyMosquesScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<MosqueModel> _allMosques = [];
  List<MosqueModel> _filteredMosques = [];
  bool _isLoading = true;
  String _selectedFilter = 'all'; // 'all', 'near', 'mid', 'historic'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMosques();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMosques() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final prayerProvider = Provider.of<PrayerProvider>(context, listen: false);
    final lat = prayerProvider.currentLatitude;
    final lon = prayerProvider.currentLongitude;

    try {
      final mosques = await MosqueService.getNearbyMosques(
        latitude: lat,
        longitude: lon,
      );
      if (mounted) {
        setState(() {
          _allMosques = mosques;
          _isLoading = false;
        });
        _applyFilters();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _allMosques = MosqueService.curatedMosques;
          _isLoading = false;
        });
        _applyFilters();
      }
    }
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredMosques = _allMosques.where((mosque) {
        // Search query filter
        final matchesSearch = query.isEmpty ||
            mosque.name.toLowerCase().contains(query) ||
            mosque.address.toLowerCase().contains(query);

        if (!matchesSearch) return false;

        // Category filter
        switch (_selectedFilter) {
          case 'near':
            return mosque.distanceMeters <= 1000;
          case 'mid':
            return mosque.distanceMeters > 1000 && mosque.distanceMeters <= 5000;
          case 'historic':
            return mosque.isHistorical;
          default:
            return true;
        }
      }).toList();
    });
  }

  void _showMosqueDetails(MosqueModel mosque, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Title Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: const Icon(
                      FlutterIslamicIcons.locationMosque,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mosque.name,
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.lightTextPrimary,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                mosque.type,
                                style: GoogleFonts.hindSiliguri(
                                  fontSize: 12,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              'দূরত্ব: ${mosque.formattedDistance}',
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 13,
                                color: isDark ? Colors.white70 : Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Travel Time & Direction Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildTimePill(Icons.directions_walk, mosque.formattedWalkTime, isDark),
                    Container(height: 24, width: 1, color: isDark ? Colors.white12 : Colors.black12),
                    _buildTimePill(Icons.directions_car, mosque.formattedDriveTime, isDark),
                    Container(height: 24, width: 1, color: isDark ? Colors.white12 : Colors.black12),
                    _buildTimePill(Icons.explore, '${mosque.direction} দিকে', isDark),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Address
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on_outlined, size: 20, color: AppColors.accentGold),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      mosque.address,
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Description if historical
              if (mosque.description != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accentGold.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    mosque.description!,
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 13,
                      color: isDark ? Colors.white70 : Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Facility Badges
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildFacilityChip(Icons.water_drop_outlined, 'ওযুখনা সুবিধা', mosque.hasWudu, isDark),
                  _buildFacilityChip(Icons.people_outline, 'পাঁচ ওয়াক্ত জামাত', mosque.isJamahAvailable, isDark),
                  if (mosque.hasFemalePrayerSpace)
                    _buildFacilityChip(Icons.female, 'মহিলাদের নামাজের স্থান', true, isDark),
                ],
              ),
              const SizedBox(height: 18),

              // Hadith reminder
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(FlutterIslamicIcons.solidMohammad, color: AppColors.primary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'রাসূলুল্লাহ (ﷺ) বলেছেন: "যে ব্যক্তি মসজিদে গমনাগমন করে, আল্লাহ তা‘আলা তার প্রতিটি গমনাগমনের জন্য জান্নাতে মেহমানদারির সামগ্রী প্রস্তুত রাখেন।" (বুখারী ও মুসলিম)',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : Colors.black87,
                          fontStyle: FontStyle.italic,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(
                          text: '${mosque.name}\n${mosque.address}\nঅবস্থান: ${mosque.latitude}, ${mosque.longitude}',
                        ));
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'মসজিদের তথ্য ক্লিপবোর্ডে কপি করা হয়েছে!',
                              style: GoogleFonts.hindSiliguri(),
                            ),
                            backgroundColor: AppColors.primary,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 18),
                      label: Text(
                        'তথ্য কপি',
                        style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        final prayerProvider = Provider.of<PrayerProvider>(context, listen: false);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MosqueMapScreen(
                              mosque: mosque,
                              userLat: prayerProvider.currentLatitude,
                              userLon: prayerProvider.currentLongitude,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.navigation_outlined, size: 18),
                      label: Text(
                        'দিকনির্দেশনা (ম্যাপ)',
                        style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimePill(IconData icon, String text, bool isDark) {
    return Flexible(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              text,
              style: GoogleFonts.hindSiliguri(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFacilityChip(IconData icon, String label, bool available, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: available ? AppColors.primary.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: available ? AppColors.primary.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: available ? AppColors.primary : Colors.grey),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.hindSiliguri(
              fontSize: 12,
              color: available ? (isDark ? Colors.white70 : AppColors.primary) : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final prayerProvider = Provider.of<PrayerProvider>(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'কাছের মসজিদ',
          style: GoogleFonts.hindSiliguri(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.lightTextPrimary,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDark ? Colors.white : AppColors.lightTextPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            tooltip: 'রিফ্রেশ',
            icon: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  )
                : const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: _isLoading ? null : _loadMosques,
          ),
        ],
      ),
      body: Column(
        children: [
          // Current Location Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCardElevated : AppColors.lightCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.my_location, size: 16, color: AppColors.primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'আপনার বর্তমান অবস্থান',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 11,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ),
                        Text(
                          prayerProvider.currentLocationName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.lightTextPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${MosqueModel.toBnDigits(_filteredMosques.length.toString())}টি মসজিদ',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _applyFilters(),
              style: GoogleFonts.hindSiliguri(
                color: isDark ? Colors.white : AppColors.lightTextPrimary,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'মসজিদের নাম বা এলাকা খুঁজুন...',
                hintStyle: GoogleFonts.hindSiliguri(
                  color: isDark ? Colors.white38 : Colors.black38,
                  fontSize: 14,
                ),
                prefixIcon: const Icon(Icons.search, color: AppColors.primary, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _applyFilters();
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDark ? AppColors.darkCard : Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                _buildFilterChip('all', 'সব মসজিদ', isDark),
                const SizedBox(width: 8),
                _buildFilterChip('near', 'কাছের (< ১ কি.মি.)', isDark),
                const SizedBox(width: 8),
                _buildFilterChip('mid', '১-৫ কি.মি.', isDark),
                const SizedBox(width: 8),
                _buildFilterChip('historic', 'ঐতিহাসিক ও কেন্দ্রীয়', isDark),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // Mosque List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: AppColors.primary),
                        SizedBox(height: 12),
                        Text('আশেপাশের মসজিদ খোঁজা হচ্ছে...', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : _filteredMosques.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              FlutterIslamicIcons.locationMosque,
                              size: 56,
                              color: isDark ? Colors.white24 : Colors.black26,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'কোনো মসজিদ পাওয়া যায়নি',
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'অন্য কোনো নাম বা এলাকা লিখে অনুসন্ধান করুন',
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 13,
                                color: isDark ? Colors.white38 : Colors.black38,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: _loadMosques,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20, top: 4),
                          itemCount: _filteredMosques.length,
                          itemBuilder: (context, index) {
                            final mosque = _filteredMosques[index];
                            return _buildMosqueCard(mosque, isDark);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, String label, bool isDark) {
    final isSelected = _selectedFilter == key;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        setState(() => _selectedFilter = key);
        _applyFilters();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark ? AppColors.darkCard : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.hindSiliguri(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white70 : Colors.black87),
          ),
        ),
      ),
    );
  }

  Widget _buildMosqueCard(MosqueModel mosque, bool isDark) {
    final isVeryClose = mosque.distanceMeters <= 800;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: IslamicCard(
        onTap: () => _showMosqueDetails(mosque, isDark),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mosque Avatar Icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isVeryClose
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : (isDark ? AppColors.darkCardElevated : AppColors.lightCard),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isVeryClose
                          ? AppColors.primary.withValues(alpha: 0.3)
                          : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    ),
                  ),
                  child: Icon(
                    FlutterIslamicIcons.locationMosque,
                    color: isVeryClose ? AppColors.primary : (isDark ? Colors.white70 : AppColors.primary),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),

                // Name & Type
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mosque.name,
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.lightTextPrimary,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Wrap(
                        spacing: 6,
                        runSpacing: 2,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            mosque.type,
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 11,
                              color: AppColors.accentGold,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text('•', style: TextStyle(color: isDark ? Colors.white30 : Colors.black26)),
                          Text(
                            '🧭 ${mosque.direction}',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 11,
                              color: isDark ? Colors.white54 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Distance Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isVeryClose
                        ? AppColors.primary
                        : (isDark ? AppColors.darkCardElevated : AppColors.lightCard),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isVeryClose ? AppColors.primary : AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    mosque.formattedDistance,
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isVeryClose ? Colors.white : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Address snippet
            Text(
              mosque.address,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.hindSiliguri(
                fontSize: 12,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),

            const SizedBox(height: 10),
            Divider(height: 1, color: isDark ? Colors.white10 : Colors.black12),
            const SizedBox(height: 10),

            // Bottom Info: Walk/Drive time & Details action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.directions_walk, size: 14, color: isDark ? Colors.white54 : Colors.black54),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          mosque.formattedWalkTime,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 11,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('•', style: TextStyle(color: isDark ? Colors.white30 : Colors.black26)),
                      const SizedBox(width: 6),
                      Icon(Icons.directions_car, size: 14, color: isDark ? Colors.white54 : Colors.black54),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          mosque.formattedDriveTime,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 11,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () {
                        final prayerProvider = Provider.of<PrayerProvider>(context, listen: false);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MosqueMapScreen(
                              mosque: mosque,
                              userLat: prayerProvider.currentLatitude,
                              userLon: prayerProvider.currentLongitude,
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.navigation_outlined, size: 13, color: AppColors.primary),
                            const SizedBox(width: 3),
                            Text(
                              'দিকনির্দেশনা',
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () => _showMosqueDetails(mosque, isDark),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'বিস্তারিত',
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(Icons.arrow_forward_ios, size: 9, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
