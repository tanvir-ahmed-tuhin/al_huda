import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/mosque_model.dart';
import '../../theme/app_theme.dart';

class MosqueMapScreen extends StatefulWidget {
  final MosqueModel mosque;
  final double userLat;
  final double userLon;

  const MosqueMapScreen({
    super.key,
    required this.mosque,
    required this.userLat,
    required this.userLon,
  });

  @override
  State<MosqueMapScreen> createState() => _MosqueMapScreenState();
}

class _MosqueMapScreenState extends State<MosqueMapScreen> with SingleTickerProviderStateMixin {
  late double _centerLat;
  late double _centerLon;
  int _zoom = 15;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    // Default center on mosque
    _centerLat = widget.mosque.latitude;
    _centerLon = widget.mosque.longitude;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _centerOnMosque() {
    setState(() {
      _centerLat = widget.mosque.latitude;
      _centerLon = widget.mosque.longitude;
      _zoom = 16;
    });
  }

  void _centerOnUser() {
    if (widget.userLat != 0 && widget.userLon != 0) {
      setState(() {
        _centerLat = widget.userLat;
        _centerLon = widget.userLon;
        _zoom = 16;
      });
    }
  }

  void _zoomIn() {
    if (_zoom < 18) {
      setState(() => _zoom++);
    }
  }

  void _zoomOut() {
    if (_zoom > 12) {
      setState(() => _zoom--);
    }
  }

  // --- Tile Calculation Helpers ---
  static double lonToTileXExact(double lon, int zoom) {
    return (lon + 180.0) / 360.0 * (1 << zoom);
  }

  static double latToTileYExact(double lat, int zoom) {
    final latRad = lat * pi / 180.0;
    final n = log(tan(latRad) + 1.0 / cos(latRad));
    return (1.0 - n / pi) / 2.0 * (1 << zoom);
  }

  static double tileXToLon(double x, int zoom) {
    return x / (1 << zoom) * 360.0 - 180.0;
  }

  static double tileYToLat(double y, int zoom) {
    final n = pi - 2.0 * pi * y / (1 << zoom);
    return 180.0 / pi * atan(0.5 * (exp(n) - exp(-n)));
  }

  void _onPanUpdate(DragUpdateDetails details, double viewportWidth, double viewportHeight) {
    final centerXExact = lonToTileXExact(_centerLon, _zoom);
    final centerYExact = latToTileYExact(_centerLat, _zoom);

    // 256 pixels per tile
    final newCenterXExact = centerXExact - details.delta.dx / 256.0;
    final newCenterYExact = centerYExact - details.delta.dy / 256.0;

    final newLon = tileXToLon(newCenterXExact, _zoom);
    final newLat = tileYToLat(newCenterYExact, _zoom);

    setState(() {
      _centerLon = newLon;
      _centerLat = newLat;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          final centerXExact = lonToTileXExact(_centerLon, _zoom);
          final centerYExact = latToTileYExact(_centerLat, _zoom);

          // Calculate visible tiles range
          const tileSize = 256.0;
          final tilesAcross = (width / tileSize).ceil() + 2;
          final tilesDown = (height / tileSize).ceil() + 2;

          final centerTileX = centerXExact.floor();
          final centerTileY = centerYExact.floor();

          final minTileX = centerTileX - (tilesAcross ~/ 2) - 1;
          final maxTileX = centerTileX + (tilesAcross ~/ 2) + 1;
          final minTileY = centerTileY - (tilesDown ~/ 2) - 1;
          final maxTileY = centerTileY + (tilesDown ~/ 2) + 1;

          // Mosque Screen Position
          final mosqueTileX = lonToTileXExact(widget.mosque.longitude, _zoom);
          final mosqueTileY = latToTileYExact(widget.mosque.latitude, _zoom);
          final mosqueScreenX = (mosqueTileX - centerXExact) * tileSize + width / 2;
          final mosqueScreenY = (mosqueTileY - centerYExact) * tileSize + height / 2;

          // User Screen Position
          final hasUserLocation = widget.userLat != 0 && widget.userLon != 0;
          double userScreenX = 0;
          double userScreenY = 0;
          if (hasUserLocation) {
            final userTileX = lonToTileXExact(widget.userLon, _zoom);
            final userTileY = latToTileYExact(widget.userLat, _zoom);
            userScreenX = (userTileX - centerXExact) * tileSize + width / 2;
            userScreenY = (userTileY - centerYExact) * tileSize + height / 2;
          }

          final maxTileIndex = 1 << _zoom;

          return Stack(
            children: [
              // 1. Interactive Slippy Map Layer
              GestureDetector(
                onPanUpdate: (details) => _onPanUpdate(details, width, height),
                child: Container(
                  width: width,
                  height: height,
                  color: isDark ? const Color(0xFF1B2420) : const Color(0xFFE8ECE9),
                  child: Stack(
                    children: [
                      // Render Map Tiles
                      for (int tx = minTileX; tx <= maxTileX; tx++)
                        for (int ty = minTileY; ty <= maxTileY; ty++)
                          if (tx >= 0 && tx < maxTileIndex && ty >= 0 && ty < maxTileIndex)
                            Positioned(
                              left: (tx - centerXExact) * tileSize + width / 2,
                              top: (ty - centerYExact) * tileSize + height / 2,
                              width: tileSize,
                              height: tileSize,
                              child: Image.network(
                                'https://tile.openstreetmap.org/$_zoom/$tx/$ty.png',
                                headers: const {'User-Agent': 'AlHudaIslamicApp/1.0 (Islamic Navigator)'},
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1E2822) : const Color(0xFFF0F4F1),
                                    border: Border.all(
                                      color: isDark ? Colors.white10 : Colors.black12,
                                      width: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                      // Connecting Route Line between User & Mosque
                      if (hasUserLocation)
                        CustomPaint(
                          size: Size(width, height),
                          painter: _RouteLinePainter(
                            startX: userScreenX,
                            startY: userScreenY,
                            endX: mosqueScreenX,
                            endY: mosqueScreenY,
                            color: AppColors.primary,
                          ),
                        ),

                      // User Location Marker
                      if (hasUserLocation)
                        Positioned(
                          left: userScreenX - 20,
                          top: userScreenY - 20,
                          child: _buildUserMarker(),
                        ),

                      // Mosque Location Marker
                      Positioned(
                        left: mosqueScreenX - 32,
                        top: mosqueScreenY - 60,
                        child: _buildMosqueMarker(widget.mosque),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Top Navigation Bar
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back Button
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: (isDark ? AppColors.darkSurface : Colors.white).withValues(alpha: 0.94),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            size: 20,
                            color: isDark ? Colors.white : AppColors.lightTextPrimary,
                          ),
                        ),
                      ),

                      // Title Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: (isDark ? AppColors.darkSurface : Colors.white).withValues(alpha: 0.94),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              FlutterIslamicIcons.locationMosque,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'মসজিদ দিকনির্দেশনা',
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppColors.lightTextPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Zoom Level Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: (isDark ? AppColors.darkSurface : Colors.white).withValues(alpha: 0.94),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          '${MosqueModel.toBnDigits(_zoom.toString())}x',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Floating Action Controls (Right side)
              Positioned(
                right: 16,
                bottom: 235,
                child: Column(
                  children: [
                    // Zoom In Button
                    _buildCircleActionButton(
                      icon: Icons.add,
                      onTap: _zoomIn,
                      isDark: isDark,
                      tooltip: 'জুম ইন',
                    ),
                    const SizedBox(height: 8),
                    // Zoom Out Button
                    _buildCircleActionButton(
                      icon: Icons.remove,
                      onTap: _zoomOut,
                      isDark: isDark,
                      tooltip: 'জুম আউট',
                    ),
                    const SizedBox(height: 12),
                    // Mosque Focus Button
                    FloatingActionButton.small(
                      heroTag: 'fab_mosque_target',
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      onPressed: _centerOnMosque,
                      tooltip: 'মসজিদে ফোকাস করুন',
                      child: const Icon(FlutterIslamicIcons.locationMosque, size: 20),
                    ),
                    if (hasUserLocation) ...[
                      const SizedBox(height: 8),
                      // User Focus Button
                      FloatingActionButton.small(
                        heroTag: 'fab_user_target',
                        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
                        foregroundColor: AppColors.primary,
                        onPressed: _centerOnUser,
                        tooltip: 'আমার অবস্থান',
                        child: const Icon(Icons.my_location, size: 20),
                      ),
                    ],
                  ],
                ),
              ),

              // 4. Bottom Direction Summary Card
              Positioned(
                left: 16,
                right: 16,
                bottom: 20,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mosque Title & Distance Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.mosque.name,
                                  style: GoogleFonts.hindSiliguri(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : AppColors.lightTextPrimary,
                                    height: 1.25,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.mosque.address,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.hindSiliguri(
                                    fontSize: 12,
                                    color: isDark ? Colors.white60 : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              widget.mosque.formattedDistance,
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Walk, Drive & Direction Pills
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : AppColors.lightCard,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildInfoItem(Icons.directions_walk, widget.mosque.formattedWalkTime, isDark),
                            Container(height: 18, width: 1, color: isDark ? Colors.white12 : Colors.black12),
                            _buildInfoItem(Icons.directions_car, widget.mosque.formattedDriveTime, isDark),
                            Container(height: 18, width: 1, color: isDark ? Colors.white12 : Colors.black12),
                            _buildInfoItem(Icons.explore, '${widget.mosque.direction} দিকে', isDark),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(color: AppColors.primary),
                                padding: const EdgeInsets.symmetric(vertical: 11),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(
                                  text: '${widget.mosque.name}\n${widget.mosque.address}\nম্যাপ স্থানাঙ্ক: ${widget.mosque.latitude}, ${widget.mosque.longitude}',
                                ));
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
                              icon: const Icon(Icons.copy, size: 16),
                              label: Text(
                                'ঠিকানা কপি',
                                style: GoogleFonts.hindSiliguri(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 11),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: _centerOnMosque,
                              icon: const Icon(Icons.my_location, size: 16),
                              label: Text(
                                'মসজিদ ফোকাস',
                                style: GoogleFonts.hindSiliguri(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCircleActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
    required String tooltip,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: (isDark ? AppColors.darkSurface : Colors.white).withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: isDark ? Colors.white70 : Colors.black87),
      ),
    );
  }

  Widget _buildMosqueMarker(MosqueModel mosque) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Name pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.primaryDark,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2))],
          ),
          child: Text(
            mosque.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.hindSiliguri(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 2),
        // Dome Pin Icon
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 6, offset: Offset(0, 3))],
          ),
          child: const Icon(
            FlutterIslamicIcons.locationMosque,
            color: Colors.white,
            size: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildUserMarker() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = 1.0 + (_pulseController.value * 0.35);
        final opacity = (1.0 - _pulseController.value).clamp(0.0, 1.0);

        return Stack(
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scale: scale,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.withValues(alpha: opacity * 0.4),
                ),
              ),
            ),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.shade600,
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2))],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoItem(IconData icon, String text, bool isDark) {
    return Flexible(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              text,
              style: GoogleFonts.hindSiliguri(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for dashed connection route line between user and mosque
class _RouteLinePainter extends CustomPainter {
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final Color color;

  const _RouteLinePainter({
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dx = endX - startX;
    final dy = endY - startY;
    final totalDist = sqrt(dx * dx + dy * dy);

    if (totalDist == 0) return;

    const dashWidth = 10.0;
    const dashSpace = 6.0;
    double distance = 0;

    final unitX = dx / totalDist;
    final unitY = dy / totalDist;

    while (distance < totalDist) {
      final currentDash = min(dashWidth, totalDist - distance);
      final p1 = Offset(startX + unitX * distance, startY + unitY * distance);
      final p2 = Offset(startX + unitX * (distance + currentDash), startY + unitY * (distance + currentDash));
      canvas.drawLine(p1, p2, paint);
      distance += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _RouteLinePainter oldDelegate) {
    return oldDelegate.startX != startX ||
        oldDelegate.startY != startY ||
        oldDelegate.endX != endX ||
        oldDelegate.endY != endY ||
        oldDelegate.color != color;
  }
}
