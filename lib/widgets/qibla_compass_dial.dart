import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import '../theme/app_theme.dart';

class QiblaCompassDial extends StatelessWidget {
  final double deviceHeading;
  final double qiblaAngle;
  final bool isFacingQibla;
  final double size;

  const QiblaCompassDial({
    super.key,
    required this.deviceHeading,
    required this.qiblaAngle,
    required this.isFacingQibla,
    this.size = 290.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Angle of compass dial (rotates opposite to phone heading)
    final double compassRotationRad = -deviceHeading * (math.pi / 180.0);
    // Angle of Kaaba needle relative to phone top
    final double qiblaNeedleRad = (qiblaAngle - deviceHeading) * (math.pi / 180.0);

    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: isFacingQibla
                  ? AppColors.qiblaActive.withValues(alpha: 0.5)
                  : (isDark
                      ? AppColors.accentGold.withValues(alpha: 0.15)
                      : AppColors.primary.withValues(alpha: 0.12)),
              blurRadius: isFacingQibla ? 35 : 18,
              spreadRadius: isFacingQibla ? 8 : 2,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Rotating Compass Base Dial (with North, South, East, West)
            Transform.rotate(
              angle: compassRotationRad,
              child: CustomPaint(
                size: Size(size, size),
                painter: _CompassDialPainter(
                  isDark: isDark,
                  isFacingQibla: isFacingQibla,
                ),
              ),
            ),

            // Rotating Kaaba Indicator Needle
            Transform.rotate(
              angle: qiblaNeedleRad,
              child: SizedBox(
                width: size,
                height: size,
                child: CustomPaint(
                  painter: _KaabaNeedlePainter(
                    isFacingQibla: isFacingQibla,
                  ),
                ),
              ),
            ),

            // Center Brass/Emerald Hub
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: isFacingQibla
                      ? [AppColors.qiblaActive, const Color(0xFF065F46)]
                      : [AppColors.accentGold, AppColors.goldDark],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                IconlyBold.discovery,
                color: Colors.white,
                size: 26,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompassDialPainter extends CustomPainter {
  final bool isDark;
  final bool isFacingQibla;

  _CompassDialPainter({
    required this.isDark,
    required this.isFacingQibla,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    final bgPaint = Paint()
      ..shader = RadialGradient(
        colors: isDark
            ? [
                const Color(0xFF16271E),
                const Color(0xFF0C1711),
              ]
            : [
                const Color(0xFFFFFFFF),
                const Color(0xFFEAF3ED),
              ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, bgPaint);

    // Outer Brass/Gold Rim
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = isFacingQibla
          ? AppColors.qiblaActive
          : (isDark ? AppColors.accentGold : AppColors.primary);

    canvas.drawCircle(center, radius - 2, rimPaint);

    // Inner subtle circle
    final innerCirclePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.15);

    canvas.drawCircle(center, radius * 0.72, innerCirclePaint);

    // Draw Degree Ticks and Cardinal Directions
    for (int deg = 0; deg < 360; deg += 5) {
      final isMajor = deg % 30 == 0;
      final isCardinal = deg % 90 == 0;
      final angleRad = deg * (math.pi / 180.0);

      final double tickLength = isCardinal ? 14 : (isMajor ? 10 : 5);
      final double startR = radius - 8;
      final double endR = startR - tickLength;

      final startPos = Offset(
        center.dx + startR * math.sin(angleRad),
        center.dy - startR * math.cos(angleRad),
      );

      final endPos = Offset(
        center.dx + endR * math.sin(angleRad),
        center.dy - endR * math.cos(angleRad),
      );

      final tickPaint = Paint()
        ..color = isCardinal
            ? (deg == 0 ? AppColors.error : AppColors.accentGold)
            : (isDark
                ? Colors.white.withValues(alpha: isMajor ? 0.6 : 0.25)
                : Colors.black.withValues(alpha: isMajor ? 0.6 : 0.25))
        ..strokeWidth = isCardinal ? 2.5 : (isMajor ? 1.8 : 1.0)
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(startPos, endPos, tickPaint);

      // Draw Cardinal Labels (উ, পূ, দ, প)
      if (isCardinal) {
        String label = 'উ';
        Color labelColor = AppColors.error;
        if (deg == 90) {
          label = 'পূ';
          labelColor = isDark ? Colors.white70 : AppColors.primaryDark;
        } else if (deg == 180) {
          label = 'দ';
          labelColor = isDark ? Colors.white70 : AppColors.primaryDark;
        } else if (deg == 270) {
          label = 'প';
          labelColor = isDark ? Colors.white70 : AppColors.primaryDark;
        }

        final textPainter = TextPainter(
          text: TextSpan(
            text: label,
            style: TextStyle(
              color: labelColor,
              fontSize: deg == 0 ? 16 : 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        final double textR = radius - 30;
        final textPos = Offset(
          center.dx + textR * math.sin(angleRad) - (textPainter.width / 2),
          center.dy - textR * math.cos(angleRad) - (textPainter.height / 2),
        );

        textPainter.paint(canvas, textPos);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CompassDialPainter oldDelegate) =>
      oldDelegate.isDark != isDark || oldDelegate.isFacingQibla != isFacingQibla;
}

class _KaabaNeedlePainter extends CustomPainter {
  final bool isFacingQibla;

  _KaabaNeedlePainter({required this.isFacingQibla});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Golden Kaaba Arrow Pointer pointing upward (towards Makkah)
    final needlePath = Path();
    final double needleTipY = 16.0;
    final double needleWidth = 14.0;

    needlePath.moveTo(center.dx, needleTipY); // Tip
    needlePath.lineTo(center.dx + needleWidth, center.dy);
    needlePath.lineTo(center.dx, center.dy - 12);
    needlePath.lineTo(center.dx - needleWidth, center.dy);
    needlePath.close();

    final needlePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isFacingQibla
            ? [
                const Color(0xFF34D399),
                AppColors.qiblaActive,
              ]
            : [
                AppColors.goldLight,
                AppColors.accentGold,
              ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(needlePath, needlePaint);

    // Kaaba Icon Cube Representation on top of the needle tip
    final kaabaRect = Rect.fromCenter(
      center: Offset(center.dx, needleTipY - 6),
      width: 20,
      height: 20,
    );

    final kaabaPaint = Paint()
      ..color = const Color(0xFF1E1E1E)
      ..style = PaintingStyle.fill;
    final kaabaRRect = RRect.fromRectAndRadius(kaabaRect, const Radius.circular(3));
    canvas.drawRRect(kaabaRRect, kaabaPaint);

    // Gold band on Kaaba (Kiswa belt)
    final beltPaint = Paint()
      ..color = AppColors.accentGold
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(kaabaRect.left, kaabaRect.top + 4, kaabaRect.width, 3),
      beltPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _KaabaNeedlePainter oldDelegate) =>
      oldDelegate.isFacingQibla != isFacingQibla;
}
