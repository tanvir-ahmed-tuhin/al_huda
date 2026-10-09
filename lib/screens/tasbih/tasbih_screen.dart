import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:provider/provider.dart';
import '../../providers/tasbih_provider.dart';
import '../../services/prayer_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';

class TasbihScreen extends StatelessWidget {
  const TasbihScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tasbih = Provider.of<TasbihProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    final countStr = PrayerService.toBanglaDigits(tasbih.count.toString());
    final targetStr = PrayerService.toBanglaDigits(tasbih.target.toString());
    final totalCountStr = PrayerService.toBanglaDigits(tasbih.totalCount.toString());

    // Responsive circle size to prevent any pixel overflow on smaller phones
    final double counterSize = (screenWidth * 0.62).clamp(190.0, 250.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ডিজিটাল তসবিহ'),
        actions: [
          IconButton(
            icon: Icon(
              tasbih.vibrationEnabled ? IconlyBold.activity : IconlyLight.activity,
              color: AppColors.accentGold,
            ),
            tooltip: tasbih.vibrationEnabled ? 'ভাইব্রেশন চালু' : 'ভাইব্রেশন বন্ধ',
            onPressed: () => tasbih.toggleVibration(),
          ),
          IconButton(
            icon: const Icon(IconlyLight.swap, color: AppColors.accentGold),
            tooltip: 'রিসেট করুন',
            onPressed: () => _confirmReset(context, tasbih),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Column(
            children: [
              // Active Dhikr Selector Card
              _buildDhikrSelector(context, tasbih, isDark),
              const SizedBox(height: 16),

              // Large Circular Glowing Tap Counter
              _buildCircularCounter(context, tasbih, countStr, targetStr, counterSize, isDark),
              const SizedBox(height: 14),

              // Reset & Quick Control Buttons near the Tap Counter
              _buildCounterActionButtons(context, tasbih, isDark),
              const SizedBox(height: 18),

              // Target Selectors (33, 100, 1000, অসীম) - Uses Wrap to prevent pixel overflow
              _buildTargetSelector(context, tasbih, isDark),
              const SizedBox(height: 16),

              // Total Count Stats Card
              IslamicCard(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(IconlyBold.timeCircle, color: AppColors.accentGold, size: 20),
                        SizedBox(width: 8),
                        Text('মোট পঠিত তাসবিহ', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Text(
                      totalCountStr,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accentGold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDhikrSelector(BuildContext context, TasbihProvider tasbih, bool isDark) {
    final current = tasbih.currentPreset;

    return IslamicCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'নির্বাচিত যিকির',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.accentGold,
                  fontWeight: FontWeight.w600,
                ),
              ),
              DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: tasbih.selectedPresetIndex,
                  icon: const Icon(IconlyLight.arrowDown2, color: AppColors.accentGold, size: 18),
                  dropdownColor: isDark ? AppColors.darkCardElevated : Colors.white,
                  items: List.generate(TasbihProvider.presets.length, (index) {
                    final p = TasbihProvider.presets[index];
                    return DropdownMenuItem<int>(
                      value: index,
                      child: Text(
                        p.banglaPronunciation,
                        style: const TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }),
                  onChanged: (int? newIndex) {
                    if (newIndex != null) {
                      tasbih.selectPreset(newIndex);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            current.arabic,
            style: AppTheme.arabicText(
              fontSize: 22,
              color: isDark ? Colors.white : AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            current.banglaPronunciation,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            current.banglaMeaning,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCircularCounter(
    BuildContext context,
    TasbihProvider tasbih,
    String countStr,
    String targetStr,
    double size,
    bool isDark,
  ) {
    return Center(
      child: GestureDetector(
        onTap: () => tasbih.increment(),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: isDark
                  ? [
                      const Color(0xFF1B3D2B),
                      const Color(0xFF0D1E15),
                    ]
                  : [
                      Colors.white,
                      const Color(0xFFE5F3EB),
                    ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: isDark ? 0.4 : 0.15),
                blurRadius: 24,
                spreadRadius: 4,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: AppColors.accentGold.withValues(alpha: 0.6),
              width: 3,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Progress Ring
              SizedBox(
                width: size - 20,
                height: size - 20,
                child: CircularProgressIndicator(
                  value: tasbih.progress,
                  strokeWidth: 5,
                  backgroundColor: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentGold),
                ),
              ),

              // Tap Text and Numbers
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'লক্ষ্য: $targetStr',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.accentGold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        countStr,
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.4), width: 0.8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(IconlyBold.activity, size: 14, color: AppColors.accentGold),
                          SizedBox(width: 4),
                          Text(
                            'ট্যাপ করুন',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accentGold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCounterActionButtons(BuildContext context, TasbihProvider tasbih, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Reset Button directly near tap counter
        ElevatedButton.icon(
          onPressed: () => _confirmReset(context, tasbih),
          icon: const Icon(IconlyLight.swap, size: 18, color: Colors.white),
          label: const Text('রিসেট'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFC0392B),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 2,
          ),
        ),
        const SizedBox(width: 12),

        // Count +1 Direct Button
        ElevatedButton.icon(
          onPressed: () => tasbih.increment(),
          icon: const Icon(IconlyBold.plus, size: 18, color: Colors.black),
          label: const Text('গণনা (+১)'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentGold,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 2,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildTargetSelector(BuildContext context, TasbihProvider tasbih, bool isDark) {
    final targets = [33, 100, 1000, 0];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'টার্গেট বা লক্ষ্যমাত্রা নির্বাচন করুন:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accentGold),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: targets.map((t) {
            final isSelected = tasbih.target == t;
            final label = t == 0 ? 'আনলিমিটেড' : '${PrayerService.toBanglaDigits(t.toString())} বার';

            return ChoiceChip(
              label: Text(label),
              selected: isSelected,
              selectedColor: AppColors.accentGold,
              backgroundColor: isDark ? AppColors.darkCardElevated : AppColors.lightCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? AppColors.accentGold : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
              ),
              labelStyle: TextStyle(
                color: isSelected ? Colors.black : (isDark ? Colors.white70 : AppColors.primaryDark),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              onSelected: (_) => tasbih.setTarget(t),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _confirmReset(BuildContext context, TasbihProvider tasbih) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(IconlyBold.swap, color: AppColors.accentGold),
              SizedBox(width: 8),
              Text('তসবিহ রিসেট'),
            ],
          ),
          content: const Text('আপনি কি গণনা পুনরায় শূন্য থেকে শুরু করতে চান?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('না'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC0392B),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                tasbih.reset();
                Navigator.pop(context);
              },
              child: const Text('হ্যাঁ, রিসেট করুন'),
            ),
          ],
        );
      },
    );
  }
}
