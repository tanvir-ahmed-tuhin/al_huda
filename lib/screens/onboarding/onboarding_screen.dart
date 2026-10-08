import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../main_navigation_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'আল-কুরআনুল কারীম',
      'subtitle':
          '১১৪টি সূরা, আরবি উসমানী স্ক্রিপ্ট, বাংলা অনুবাদ এবং বিশ্বখ্যাত ক্বারীর মধুর অডিও তিলাওয়াত।',
      'icon': Icons.menu_book_rounded,
      'color': const Color(0xFF10B981),
    },
    {
      'title': 'সঠিক ক্বিবলা কম্পাস',
      'subtitle':
          'লাইভ সেন্সর ও জিপিএস নির্দেশনায় যেকোনো স্থান থেকে কাবার সঠিক দিক মুহূর্তেই জানুন।',
      'icon': Icons.explore_rounded,
      'color': AppColors.accentGold,
    },
    {
      'title': 'প্রতিদিনের আমল ট্র্যাকার',
      'subtitle':
          '৫ ওয়াক্ত নামাজ, কুরআন ও যিকিরের রুটিন ট্র্যাকিং এবং ধারাবাহিকতার স্ট্রিক সংরক্ষণ।',
      'icon': Icons.task_alt_rounded,
      'color': const Color(0xFF6366F1),
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF072718), Color(0xFF0D3722), Color(0xFF081A11)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _navigateToMain,
                  child: const Text(
                    'স্কিপ',
                    style: TextStyle(color: AppColors.accentGold, fontSize: 14),
                  ),
                ),
              ),

              // PageView
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (idx) {
                    setState(() => _currentPage = idx);
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final p = _pages[index];
                    final icon = p['icon'] as IconData;
                    final color = p['color'] as Color;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color.withValues(alpha: 0.15),
                              border: Border.all(color: color, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.3),
                                  blurRadius: 30,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: Icon(icon, size: 64, color: color),
                          ),
                          const SizedBox(height: 36),
                          Text(
                            p['title'] as String,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            p['subtitle'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.75),
                              height: 1.6,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Indicators & Button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 24,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Indicators
                    Row(
                      children: List.generate(_pages.length, (idx) {
                        final isSel = idx == _currentPage;

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(right: 6),
                          width: isSel ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isSel
                                ? AppColors.accentGold
                                : Colors.white24,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),

                    // Next / Get Started Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentGold,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      onPressed: () {
                        if (_currentPage < _pages.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _navigateToMain();
                        }
                      },
                      child: Row(
                        children: [
                          Text(
                            _currentPage == _pages.length - 1
                                ? 'শুরু করুন'
                                : 'পরবর্তী',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward_rounded, size: 16),
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

  void _navigateToMain() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
    );
  }
}
