import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/islamic_events_provider.dart';
import '../screens/islamic_events/event_detail_screen.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

class _InspirationalItem {
  final String category;
  final String arabic;
  final String bangla;
  final String reference;
  final IconData icon;

  const _InspirationalItem({
    required this.category,
    required this.arabic,
    required this.bangla,
    required this.reference,
    required this.icon,
  });
}

class UpcomingIslamicEventCard extends StatefulWidget {
  const UpcomingIslamicEventCard({super.key});

  @override
  State<UpcomingIslamicEventCard> createState() => _UpcomingIslamicEventCardState();
}

class _UpcomingIslamicEventCardState extends State<UpcomingIslamicEventCard> {
  static const List<_InspirationalItem> _items = [
    _InspirationalItem(
      category: 'হাদিস শরিফ',
      arabic: 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ',
      bangla: 'কাজের ফলাফল নিয়্যাতের ওপর নির্ভরশীল। আর প্রত্যেক ব্যক্তি তার নিয়্যাত অনুযায়ী প্রতিদান পাবে।',
      reference: 'সহীহ বুখারী: ১',
      icon: FlutterIslamicIcons.prayer,
    ),
    _InspirationalItem(
      category: 'কুরআনের বাণী',
      arabic: 'فَمَن كَانَ يَرْجُو لِقَاءَ رَبِّهِ فَلْيَعْمَلْ عَمَلًا صَالِحًا',
      bangla: 'যে ব্যক্তি তার রবের সাক্ষাৎ কামনা করে, সে যেন সৎকাজ করে এবং তার রবের ইবাদতে কাউকে শরিক না করে।',
      reference: 'সূরা আল-কাহাফ: ১১০',
      icon: FlutterIslamicIcons.quran,
    ),
    _InspirationalItem(
      category: 'জুমার হাদিস',
      arabic: 'خَيْرُ يَوْمٍ طَلَعَتْ عَلَيْهِ الشَّمْسُ يَوْمُ الْجُمُعَةِ',
      bangla: 'সূর্য উদিত হওয়া দিনগুলোর মধ্যে শ্রেষ্ঠ দিন হলো জুমার দিন; এ দিনেই আদম (আ.)-কে সৃষ্টি করা হয়েছিল।',
      reference: 'সহীহ মুসলিম: ৮৫৪',
      icon: FlutterIslamicIcons.crescentMoon,
    ),
    _InspirationalItem(
      category: 'দরুদ ও আমল',
      arabic: 'أَكْثِرُوا عَلَيَّ مِنَ الصَّلَاةِ فِي كُلِّ يَوْمِ جُمُعَةٍ',
      bangla: 'জুমার দিনে তোমরা আমার ওপর বেশি বেশি দরুদ পাঠ করো, কেননা তোমাদের দরুদ আমার কাছে পৌঁছানো হয়।',
      reference: 'সুনানে বায়হাকী: ২৪৪৪',
      icon: FlutterIslamicIcons.prayingPerson,
    ),
    _InspirationalItem(
      category: 'হাদিস শরিফ',
      arabic: 'خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ',
      bangla: 'তোমাদের মধ্যে ঐ ব্যক্তি সবচেয়ে উত্তম যে নিজে কুরআন শিখে এবং অন্যকে শেখায়।',
      reference: 'সহীহ বুখারী: ৫০২৭',
      icon: FlutterIslamicIcons.quran2,
    ),
    _InspirationalItem(
      category: 'কুরআনের আয়াত',
      arabic: 'فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ',
      bangla: 'অতএব তোমরা আমাকে স্মরণ করো, আমিও তোমাদের স্মরণ করব। আর আমার প্রতি কৃতজ্ঞতা প্রকাশ করো, অকৃতজ্ঞ হয়ো না।',
      reference: 'সূরা আল-বাকারা: ১৫২',
      icon: FlutterIslamicIcons.quran2,
    ),
    _InspirationalItem(
      category: 'দোয়া ইউনুস',
      arabic: 'لَّا إِلَٰهَ إِلَّا أَنتَ سُبْحَانَكَ إِنِّي كُنتُ مِنَ الظَّالِمِينَ',
      bangla: 'আপনি ছাড়া কোনো সত্য উপাস্য নেই, আপনি অতি পবিত্র! নিশ্চয়ই আমি সীমালঙ্ঘনকারীদের অন্তর্ভুক্ত ছিলাম।',
      reference: 'সূরা আল-আম্বিয়া: ৮৭',
      icon: FlutterIslamicIcons.tasbih,
    ),
    _InspirationalItem(
      category: 'হাদিস শরিফ',
      arabic: 'أَحَبُّ الأَعْمَالِ إِلَى اللَّهِ أَدْوَمُهَا وَإِنْ قَلَّ',
      bangla: 'আল্লাহর কাছে সর্বাধিক প্রিয় আমল তা-ই, যা নিয়মিত করা হয়—যদিও তা পরিমাণে অল্প হয়।',
      reference: 'সহীহ বুখারী: ৬৪৬৪',
      icon: FlutterIslamicIcons.prayer,
    ),
    _InspirationalItem(
      category: 'কুরআনের আয়াত',
      arabic: 'إِنَّ مَعَ الْعُسْرِ يُسْرًا',
      bangla: 'নিশ্চয়ই কষ্টের সাথেই স্বস্তি রয়েছে, নিশ্চয়ই কষ্টের সাথেই রয়েছে স্বস্তি।',
      reference: 'সূরা আল-ইনশিরাহ: ৬',
      icon: FlutterIslamicIcons.quran,
    ),
    _InspirationalItem(
      category: 'হিদায়াতের দোয়া',
      arabic: 'يَا مُقَلِّبَ الْقُلُوبِ ثَبِّتْ قَلْبِي عَلَىٰ دِينِكَ',
      bangla: 'হে অন্তরের পরিবর্তনকারী! আমার অন্তরকে আপনার দ্বীনের ওপর অবিচল রাখুন।',
      reference: 'সুনানে তিরমিযী: ২১৪০',
      icon: FlutterIslamicIcons.prayingPerson,
    ),
    _InspirationalItem(
      category: 'কুরআনের আয়াত',
      arabic: 'وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ',
      bangla: 'আর যে ব্যক্তি আল্লাহর ওপর ভরসা করে, তার জন্য তিনিই যথেষ্ট।',
      reference: 'সূরা আত-তালাক: ৩',
      icon: FlutterIslamicIcons.quran2,
    ),
  ];

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = Random().nextInt(_items.length);
  }

  void _nextQuote() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _items.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<IslamicEventsProvider>(
      builder: (context, provider, child) {
        final next = provider.nextMajorEvent;
        if (next == null) return const SizedBox.shrink();

        final event = next.event;
        final currentItem = _items[_currentIndex];

        return IslamicCard(
          borderRadius: 18,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          borderColor: AppColors.accentGold.withValues(alpha: 0.45),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF1E3A2B), const Color(0xFF0F261B)]
                : [const Color(0xFFF0F9F4), const Color(0xFFDDF1E6)],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => IslamicEventDetailScreen(
                  event: event,
                  upcomingResult: next,
                ),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Event badge & "আরো জানুন" button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.accentGold.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.accentGold,
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 13,
                          color: AppColors.accentGold,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          next.dateDisplay,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accentGold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => IslamicEventDetailScreen(
                            event: event,
                            upcomingResult: next,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.accentGold,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentGold.withValues(alpha: 0.35),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'আরো জানুন',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 3),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 13,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              Divider(
                height: 1,
                thickness: 0.8,
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
              ),
              const SizedBox(height: 10),

              // Random Ayah / Hadith / Dua Inspiration Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.22)
                      : Colors.white.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.accentGold.withValues(alpha: 0.25),
                    width: 0.7,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category & Shuffle Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              currentItem.icon,
                              size: 15,
                              color: AppColors.accentGold,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              currentItem.category,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.accentGold,
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: _nextQuote,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            child: Row(
                              children: [
                                Text(
                                  'অন্যটি দেখুন',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: (isDark ? Colors.white70 : Colors.black54),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.shuffle_rounded,
                                  size: 13,
                                  color: AppColors.accentGold,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),

                    // Arabic Text (Noto Naskh Arabic with bold, prominent size)
                    if (currentItem.arabic.isNotEmpty) ...[
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          currentItem.arabic,
                          style: GoogleFonts.notoNaskhArabic(
                            fontSize: 20,
                            height: 1.6,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.goldLight : const Color(0xFF1B5E20),
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],

                    // Bangla Text
                    Text(
                      currentItem.bangla,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: isDark ? Colors.white.withValues(alpha: 0.92) : const Color(0xFF2C3E50),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 5),

                    // Reference
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '— ${currentItem.reference}',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
