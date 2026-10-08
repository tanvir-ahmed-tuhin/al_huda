import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/audio_player_bar.dart';
import '../widgets/azan_floating_bar.dart';
import 'home_screen.dart';
import 'quran/surah_list_screen.dart';
import 'qibla/qibla_screen.dart';
import 'tasks/daily_tasks_screen.dart';
import 'more/more_screen.dart';
import 'package:hugeicons/hugeicons.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Widget> screens = [
      HomeScreen(onNavigateTab: (index) {
        setState(() {
          _currentIndex = index;
        });
      }),
      const SurahListScreen(),
      const QiblaScreen(),
      const DailyTasksScreen(),
      const MoreScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Floating Azan Bar when azan is active
          const AzanFloatingBar(),

          // Floating audio bar if audio recitation is active
          const AudioPlayerBar(),

          // Navigation Bar
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              backgroundColor: Colors.transparent,
              indicatorColor: AppColors.primary.withValues(alpha: 0.2),
              elevation: 0,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded, color: AppColors.accentGold),
                  label: 'হোম',
                ),
                NavigationDestination(
                  icon: Icon(Icons.menu_book_outlined),
                  selectedIcon: Icon(Icons.menu_book_rounded, color: AppColors.accentGold),
                  label: 'কুরআন',
                ),
                NavigationDestination(
                  icon: Icon(Icons.explore_outlined),
                  selectedIcon: Icon(Icons.explore_rounded, color: AppColors.accentGold),
                  label: 'ক্বিবলা',
                ),
                NavigationDestination(
                  icon: Icon(Icons.task_alt_outlined),
                  selectedIcon: Icon(Icons.task_alt_rounded, color: AppColors.accentGold),
                  label: 'আমল',
                ),
                NavigationDestination(
                  icon: Icon(Icons.widgets_outlined),
                  selectedIcon: Icon(Icons.widgets_rounded, color: AppColors.accentGold),
                  label: 'অন্যান্য',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
