import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

import '../../theme/app_theme.dart';
import '../main_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _pulseController;
  late AnimationController _progressController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  Timer? _statusTimer;
  int _statusIndex = 0;

  final List<String> _loadingStatuses = [
    'লোড হচ্ছে...',
    'অনুগ্রহ করে অপেক্ষা করুন...',
    'স্বাগতম...',
  ];

  @override
  void initState() {
    super.initState();

    // 1. Entrance animation (fade + scale + slide)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOutBack,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOutCubic,
      ),
    );

    // 2. Gentle breathing pulse for the glow & rotating geometric ring
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    // 3. Progress bar animation over 2.6 seconds
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    _entranceController.forward();
    _progressController.forward();

    // Cycle through loading status text
    _statusTimer = Timer.periodic(const Duration(milliseconds: 850), (timer) {
      if (mounted) {
        setState(() {
          if (_statusIndex < _loadingStatuses.length - 1) {
            _statusIndex++;
          }
        });
      }
    });

    // Navigate to MainNavigationScreen after loading completes
    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToNextScreen();
      }
    });
  }

  void _navigateToNextScreen() {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (context, anim, secAnim) => const MainNavigationScreen(),
        transitionsBuilder: (context, animation, secAnim, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _entranceController.dispose();
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFF03160D),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF03160D),
              Color(0xFF07291A),
              Color(0xFF0A3E26),
              Color(0xFF03140C),
            ],
            stops: [0.0, 0.35, 0.7, 1.0],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Ambient Geometric Islamic Background
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return CustomPaint(
                  size: size,
                  painter: _IslamicGeometricBackgroundPainter(
                    progress: _pulseController.value,
                  ),
                );
              },
            ),

            // Soft Central Gold Bloom Aura
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final scale = 1.0 + (_pulseController.value * 0.15);
                final opacity = 0.18 + (_pulseController.value * 0.12);

                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.accentGold.withValues(alpha: opacity),
                          Colors.transparent,
                        ],
                        stops: const [0.1, 0.8],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Foreground Content
            SafeArea(
              child: AnimatedBuilder(
                animation: _entranceController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Spacer(flex: 3),

                              // Central Glowing Emblem
                              _buildHeroLogo(),

                              const SizedBox(height: 28),

                              // App Name in Bangla with Luxury Gold Styling
                              const Text(
                                'আল-হুদা',
                                style: TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 3.0,
                                ),
                              ),

                              const SizedBox(height: 6),

                              const Text(
                                'পবিত্র জীবন ও ইবাদতের সঙ্গী',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.accentGold,
                                  letterSpacing: 1.2,
                                ),
                              ),

                              const Spacer(flex: 3),

                              // Animated Smooth Progress Bar
                              _buildProgressBar(),

                              const SizedBox(height: 12),

                              // Dynamic Status Text
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 350),
                                child: Text(
                                  _loadingStatuses[_statusIndex],
                                  key: ValueKey<int>(_statusIndex),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.goldLight.withValues(alpha: 0.8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                              const Spacer(flex: 1),

                              // Footer Version
                              Text(
                                'সংস্করণ ১.০.১',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withValues(alpha: 0.45),
                                  letterSpacing: 0.5,
                                ),
                              ),

                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildHeroLogo() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final rotation = _pulseController.value * 0.08;
        final glowScale = 1.0 + (_pulseController.value * 0.06);

        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer Rotating Islamic Decorative Ring
            Transform.rotate(
              angle: rotation,
              child: Container(
                width: 142,
                height: 142,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.accentGold.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                ),
              ),
            ),

            // Middle Glowing Halo Ring
            Transform.scale(
              scale: glowScale,
              child: Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accentGold.withValues(alpha: 0.4),
                      Colors.transparent,
                    ],
                    stops: const [0.7, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentGold.withValues(alpha: 0.5),
                      blurRadius: 32,
                      spreadRadius: 6,
                    ),
                  ],
                ),
              ),
            ),

            // Center Logo Card with App Icon or Islamic Emblem
            Container(
              width: 116,
              height: 116,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [
                    Color(0xFF0A442A),
                    Color(0xFF042013),
                  ],
                ),
                border: Border.all(
                  color: AppColors.accentGold,
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipOval(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Image.asset(
                    'assets/icon/app_logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        IconlyBold.document,
                        color: AppColors.accentGold,
                        size: 58,
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProgressBar() {
    return AnimatedBuilder(
      animation: _progressController,
      builder: (context, child) {
        final progress = _progressController.value;

        return Container(
          width: 200,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.accentGold.withValues(alpha: 0.3),
              width: 0.8,
            ),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 200 * progress,
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  colors: [
                    AppColors.goldLight,
                    AppColors.accentGold,
                    AppColors.goldDark,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentGold.withValues(alpha: 0.6),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Custom Painter to draw a sacred geometric Islamic 8-point star pattern
class _IslamicGeometricBackgroundPainter extends CustomPainter {
  final double progress;

  _IslamicGeometricBackgroundPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.42);
    final paint = Paint()
      ..color = AppColors.accentGold.withValues(alpha: 0.05 + (progress * 0.03))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw concentric sacred rings
    canvas.drawCircle(center, 90 + (progress * 10), paint);
    canvas.drawCircle(center, 150 + (progress * 15), paint);
    canvas.drawCircle(center, 210 + (progress * 20), paint);

    // Draw rotating 8-pointed star (Rub el Hizb)
    final starPaint = Paint()
      ..color = AppColors.accentGold.withValues(alpha: 0.04 + (progress * 0.02))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final angleOffset = progress * math.pi * 0.05;

    _drawSquare(canvas, center, 110, angleOffset, starPaint);
    _drawSquare(canvas, center, 110, angleOffset + (math.pi / 4), starPaint);

    _drawSquare(canvas, center, 170, -angleOffset, starPaint);
    _drawSquare(canvas, center, 170, -angleOffset + (math.pi / 4), starPaint);
  }

  void _drawSquare(Canvas canvas, Offset center, double radius, double rotation, Paint paint) {
    final path = Path();
    for (int i = 0; i < 4; i++) {
      final angle = rotation + (i * math.pi / 2);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _IslamicGeometricBackgroundPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
