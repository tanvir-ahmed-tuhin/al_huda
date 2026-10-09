import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/auth_service.dart';
import '../../services/prayer_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/google_logo.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _handleManualSync(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ফায়ারস্টোরে তথ্য সিঙ্ক করা হচ্ছে...'),
        duration: Duration(milliseconds: 900),
      ),
    );
    final ok = await authProvider.syncWithFirestore();
    if (!context.mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(IconlyBold.tickSquare, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(child: Text('ফায়ারস্টোর ডাটাবেসে তথ্য সফলভাবে যুক্ত হয়েছে!')),
            ],
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(IconlyBold.danger, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(child: Text('সিঙ্ক ব্যর্থ হয়েছে। ইন্টারনেট সংযোগ চেক করুন।')),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signInWithGoogle();

    if (!context.mounted) return;

    if (success) {
      final name = authProvider.currentUser?.name ?? 'ব্যবহারকারী';
      final isFirestoreDenied = AuthService.hadFirestorePermissionDenied;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isFirestoreDenied ? IconlyBold.danger : IconlyBold.tickSquare,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isFirestoreDenied
                      ? 'স্বাগতম $name! গুগল লগইন সফল হয়েছে (ফায়ারস্টোরে ডাটা সেভ করা হচ্ছে)।'
                      : 'স্বাগতম $name! তথ্য ফায়ারস্টোরে সফলভাবে যুক্ত হয়েছে।',
                ),
              ),
            ],
          ),
          backgroundColor: isFirestoreDenied ? Colors.orange.shade800 : AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 4),
        ),
      );
    } else if (authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage!),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(IconlyLight.logout, color: Colors.redAccent),
            SizedBox(width: 10),
            Text('লগআউট নিশ্চিতকরণ'),
          ],
        ),
        content: const Text('আপনি কি নিশ্চিত যে আপনার একাউন্ট থেকে লগআউট করতে চান?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('বাতিল'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('লগআউট'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await Provider.of<AuthProvider>(context, listen: false).logout();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('সফলভাবে লগআউট করা হয়েছে।'),
            backgroundColor: Colors.grey.shade800,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final taskProvider = Provider.of<TaskProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final isAuthenticated = authProvider.isAuthenticated;

    final displayName = user?.name.isNotEmpty == true ? user!.name : 'লগইন করা নেই';
    final displayEmail = user?.email.isNotEmpty == true ? user!.email : 'গুগল দিয়ে সাইন-ইন করে ক্লাউড সিঙ্ক চালু করুন';
    final photoUrl = user?.photoUrl;
    final streakDays = user?.streakDays ?? 1;
    final baseAmalPoints = user?.totalAmalPoints ?? 0;
    final totalPoints = baseAmalPoints + taskProvider.earnedPointsToday;

    return Scaffold(
      appBar: AppBar(
        title: const Text('প্রোফাইল ও সেটিংস'),
        actions: [
          if (isAuthenticated) ...[
            IconButton(
              icon: const Icon(IconlyLight.swap, color: AppColors.accentGold),
              tooltip: 'ফায়ারস্টোরে ডাটা সিঙ্ক করুন',
              onPressed: () => _handleManualSync(context),
            ),
            IconButton(
              icon: const Icon(IconlyLight.logout, color: Colors.redAccent),
              tooltip: 'লগআউট',
              onPressed: () => _handleLogout(context),
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          children: [
            // User Avatar & Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF072B1A)],
                ),
                border: Border.all(
                  color: AppColors.accentGold.withValues(alpha: 0.5),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Avatar with Google photo or fallback icon
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accentGold.withValues(alpha: 0.2),
                          border: Border.all(
                            color: AppColors.accentGold,
                            width: 2.2,
                          ),
                        ),
                        child: ClipOval(
                          child: photoUrl != null && photoUrl.isNotEmpty
                              ? Image.network(
                                  photoUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                    IconlyBold.profile,
                                    size: 46,
                                    color: AppColors.accentGold,
                                  ),
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) return child;
                                    return const Center(
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            AppColors.accentGold,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : const Icon(
                                  IconlyBold.profile,
                                  size: 46,
                                  color: AppColors.accentGold,
                                ),
                        ),
                      ),
                      if (isAuthenticated)
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const GoogleLogo(size: 16),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    displayEmail,
                    style: const TextStyle(
                      color: AppColors.goldLight,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  // Connection Badge & Sync Action
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: isAuthenticated ? () => _handleManualSync(context) : null,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isAuthenticated
                              ? const Color(0xFF10B981).withValues(alpha: 0.22)
                              : Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isAuthenticated
                                ? const Color(0xFF10B981)
                                : Colors.white24,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isAuthenticated
                                  ? IconlyBold.shieldDone
                                  : IconlyLight.lock,
                              size: 14,
                              color: isAuthenticated
                                  ? const Color(0xFF10B981)
                                  : Colors.white70,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isAuthenticated
                                  ? 'ফায়ারস্টোরে সিঙ্ক করুন'
                                  : 'লগইন করা প্রয়োজন',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isAuthenticated
                                    ? const Color(0xFF10B981)
                                    : Colors.white70,
                              ),
                            ),
                            if (isAuthenticated) ...[
                              const SizedBox(width: 6),
                              const Icon(
                                IconlyLight.swap,
                                size: 12,
                                color: Color(0xFF10B981),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Sign In with Google Card (Shown when not authenticated)
            if (!isAuthenticated) ...[
              IslamicCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.accentGold.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            IconlyLight.swap,
                            color: AppColors.accentGold,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'গুগল দিয়ে সাইন-ইন করুন',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'আমল, স্ট্রিক ও পয়েন্ট ফায়ারবেসে সুরক্ষিত রাখুন',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Google Sign-In Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? const Color(0xFF242C26) : Colors.white,
                        foregroundColor: isDark ? Colors.white : Colors.black87,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: isDark ? Colors.white24 : Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                      ),
                      onPressed: authProvider.isLoading
                          ? null
                          : () => _handleGoogleSignIn(context),
                      child: authProvider.isLoading
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.accentGold,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'ফায়ারবেসে সাইন-ইন হচ্ছে...',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GoogleLogo(size: 22),
                                SizedBox(width: 12),
                                Text(
                                  'গুগল একাউন্ট দিয়ে যুক্ত হোন',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Amal Points & Streak Stats
            Row(
              children: [
                Expanded(
                  child: IslamicCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        const Icon(
                          IconlyBold.activity,
                          color: AppColors.amber,
                          size: 28,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${PrayerService.toBanglaDigits(streakDays.toString())} দিন',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'আমলের ধারাবাহিকতা',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: IslamicCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        const Icon(
                          IconlyBold.star,
                          color: AppColors.accentGold,
                          size: 28,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          PrayerService.toBanglaDigits(totalPoints.toString()),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'মোট অর্জিত পয়েন্ট',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Settings & Preferences
            IslamicCard(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: Icon(
                      themeProvider.isDarkMode
                          ? IconlyBold.show
                          : IconlyLight.show,
                      color: AppColors.accentGold,
                    ),
                    title: const Text('ডার্ক মোড'),
                    value: themeProvider.isDarkMode,
                    activeTrackColor: AppColors.accentGold,
                    onChanged: (_) => themeProvider.toggleTheme(),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      IconlyLight.send,
                      color: AppColors.accentGold,
                    ),
                    title: const Text('অ্যাপ শেয়ার করুন'),
                    trailing: const Icon(
                      IconlyLight.arrowRight2,
                      size: 14,
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('শেয়ার লিঙ্ক কপি করা হয়েছে'),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      IconlyLight.infoSquare,
                      color: AppColors.accentGold,
                    ),
                    title: const Text('অ্যাপ সম্পর্কিত তথ্য'),
                    subtitle: const Text(
                      'সংস্করণ ১.০.১ (সাদকায়ে জারিয়া)',
                    ),
                  ),
                  if (isAuthenticated) ...[
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(
                        IconlyLight.logout,
                        color: Colors.redAccent,
                      ),
                      title: const Text(
                        'লগআউট',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: const Text('আপনার একাউন্ট থেকে সাইন-আউট করুন'),
                      onTap: () => _handleLogout(context),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}