import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../services/prayer_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';

class DailyTasksScreen extends StatelessWidget {
  const DailyTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('দৈনিক আমল ট্র্যাকার'),
        actions: [
          IconButton(
            icon: const Icon(IconlyLight.plus, color: AppColors.accentGold),
            tooltip: 'নতুন আমল যোগ করুন',
            onPressed: () => _showAddTaskModal(context, taskProvider, isDark),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accentGold,
        foregroundColor: Colors.black,
        icon: const Icon(IconlyBold.plus),
        label: const Text('আমল যোগ করুন', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => _showAddTaskModal(context, taskProvider, isDark),
      ),
      body: RefreshIndicator(
        onRefresh: () => taskProvider.loadTasks(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Daily Progress Hero Card
              _buildProgressHero(context, taskProvider, isDark),
              const SizedBox(height: 16),

              // Category Selector Tabs
              _buildCategorySelector(taskProvider, isDark),
              const SizedBox(height: 16),

              // Task List Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'আজকের আমল তালিকা (${PrayerService.toBanglaDigits(taskProvider.filteredTasks.length.toString())})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'পয়েন্ট: ${PrayerService.toBanglaDigits(taskProvider.earnedPointsToday.toString())}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentGold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Task Items List
              if (taskProvider.filteredTasks.isEmpty)
                _buildEmptyState(isDark)
              else
                ...taskProvider.filteredTasks.map((task) {
                  return _buildTaskTile(context, task, taskProvider, isDark);
                }),

              const SizedBox(height: 80), // Padding for FAB
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressHero(BuildContext context, TaskProvider provider, bool isDark) {
    final progress = provider.progressPercentage;
    final completed = provider.completedCount;
    final total = provider.totalCount;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F5132),
            Color(0xFF072C1B),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F5132).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: AppColors.accentGold.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Circular Progress Indicator
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentGold),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),

          // Progress Details & Streak
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accentGold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.accentGold, width: 0.8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(IconlyBold.activity, size: 14, color: AppColors.accentGold),
                      SizedBox(width: 4),
                      Text(
                        'দৈনিক আমল রুটিন',
                        style: TextStyle(
                          color: AppColors.goldLight,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${PrayerService.toBanglaDigits(completed.toString())}/${PrayerService.toBanglaDigits(total.toString())} টি আমল সম্পন্ন',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  progress == 1.0
                      ? 'মাশাআল্লাহ! আজকের সব আমল সম্পন্ন!'
                      : 'ধারাবাহিকতা বজায় রাখতে সব আমল করুন',
                  style: TextStyle(
                    color: AppColors.goldLight.withValues(alpha: 0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector(TaskProvider provider, bool isDark) {
    final categories = ['সব', 'নামাজ', 'কুরআন', 'যিকির', 'নেক আমল'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          final isSelected = provider.selectedCategory == cat;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(cat),
              selected: isSelected,
              selectedColor: AppColors.accentGold,
              backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: isSelected ? AppColors.accentGold : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
              ),
              labelStyle: TextStyle(
                color: isSelected ? Colors.black : (isDark ? Colors.white70 : AppColors.primaryDark),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              onSelected: (_) => provider.setCategory(cat),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTaskTile(BuildContext context, dynamic task, TaskProvider provider, bool isDark) {
    final bool isDone = task.isCompleted;

    return IslamicCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      gradient: isDone
          ? LinearGradient(
              colors: isDark
                  ? [
                      const Color(0xFF133522),
                      const Color(0xFF0C2417),
                    ]
                  : [
                      const Color(0xFFE5F5EC),
                      const Color(0xFFD4ECE0),
                    ],
            )
          : null,
      borderColor: isDone ? AppColors.qiblaActive.withValues(alpha: 0.6) : null,
      onTap: () {
        HapticFeedback.selectionClick();
        provider.toggleTask(task.id);
      },
      child: Row(
        children: [
          // Animated Checkbox
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDone ? AppColors.qiblaActive : Colors.transparent,
              border: Border.all(
                color: isDone ? AppColors.qiblaActive : (isDark ? Colors.white38 : Colors.grey),
                width: 2,
              ),
            ),
            child: isDone
                ? const Icon(IconlyBold.tickSquare, size: 18, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 14),

          // Title and Category Tag
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                    color: isDone
                        ? (isDark ? Colors.white54 : Colors.grey.shade600)
                        : (isDark ? Colors.white : AppColors.lightTextPrimary),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        task.category,
                        style: const TextStyle(fontSize: 10.5, color: AppColors.accentGold, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '+${PrayerService.toBanglaDigits(task.points.toString())} পয়েন্ট',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Delete custom task option
          if (task.id.length > 10)
            IconButton(
              icon: const Icon(IconlyLight.delete, size: 18, color: AppColors.error),
              tooltip: 'মুছে ফেলুন',
              onPressed: () => provider.deleteTask(task.id),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Icon(IconlyBold.paper, size: 54, color: AppColors.accentGold),
            const SizedBox(height: 12),
            const Text(
              'এই ক্যাটাগরিতে কোনো আমল নেই',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'নতুন আমল যোগ করতে নিচের বাটনে চাপ দিন',
              style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTaskModal(BuildContext context, TaskProvider provider, bool isDark) {
    final titleController = TextEditingController();
    String selectedCat = 'নেক আমল';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'নতুন আমল যোগ করুন',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: titleController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'যেমন: তাহাজ্জুদ নামাজ, সূরা কাহাফ তিলাওয়াত...',
                      labelText: 'আমলের নাম',
                      filled: true,
                      fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.accentGold, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category Selector
                  DropdownButtonFormField<String>(
                    initialValue: selectedCat,
                    decoration: InputDecoration(
                      labelText: 'ক্যাটাগরি',
                      filled: true,
                      fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    items: ['নামাজ', 'কুরআন', 'যিকির', 'নেক আমল'].map((cat) {
                      return DropdownMenuItem(value: cat, child: Text(cat));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => selectedCat = val);
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      if (titleController.text.trim().isNotEmpty) {
                        provider.addTask(
                          title: titleController.text,
                          category: selectedCat,
                          points: 15,
                        );
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('সংরক্ষণ করুন', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
