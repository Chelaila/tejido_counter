import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Para agregar más SVGs: copia el archivo a assets/bg_svgs/ y agrega la ruta.
// ─────────────────────────────────────────────────────────────────────────────
const List<String> _kSvgAssets = [
  'assets/bg_svgs/pinkBall.svg',
  'assets/bg_svgs/purpleBall.svg',
  'assets/bg_svgs/greenBall.svg',
  'assets/bg_svgs/yellowBall.svg',
  'assets/bg_svgs/redBall.svg',
  'assets/bg_svgs/blackBall.svg',
];

class _Blob {
  double x, y;
  double vx, vy;
  double angle;
  double av;
  double size;
  String svgPath;

  _Blob({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.angle,
    required this.av,
    required this.size,
    required this.svgPath,
  });
}

class AnimatedYarnBackground extends StatefulWidget {
  const AnimatedYarnBackground({super.key});

  @override
  State<AnimatedYarnBackground> createState() =>
      _AnimatedYarnBackgroundState();
}

class _AnimatedYarnBackgroundState extends State<AnimatedYarnBackground>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  late final List<_Blob> _blobs;
  Duration _prev = Duration.zero;

  @override
  void initState() {
    super.initState();
    _blobs = _buildBlobs();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  List<_Blob> _buildBlobs() {
    if (_kSvgAssets.isEmpty) return [];
    final rng = Random();

    return List.generate(_kSvgAssets.length, (i) {
      final speed = 0.05 + rng.nextDouble() * 0.1;
      final dir = rng.nextDouble() * pi * 4;
      return _Blob(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        vx: cos(dir) * speed,
        vy: sin(dir) * speed,
        angle: rng.nextDouble() * pi * 2,
        av: (rng.nextDouble() - 0.5) * 0.3,
        size: 120 + rng.nextDouble() * 110,
        svgPath: _kSvgAssets[i],
      );
    });
  }

  void _onTick(Duration elapsed) {
    if (_blobs.isEmpty) return;
    final dt = ((elapsed - _prev).inMicroseconds / 1e6).clamp(0.0, 0.05);
    _prev = elapsed;

    for (final b in _blobs) {
      b.x += b.vx * dt;
      b.y += b.vy * dt;
      b.angle += b.av * dt;

      if (b.x <= 0) { b.x = 0; b.vx = b.vx.abs(); }
      if (b.x >= 1) { b.x = 1; b.vx = -b.vx.abs(); }
      if (b.y <= 0) { b.y = 0; b.vy = b.vy.abs(); }
      if (b.y >= 1) { b.y = 1; b.vy = -b.vy.abs(); }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_blobs.isEmpty) return const SizedBox.shrink();

    final screenSize = MediaQuery.sizeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RepaintBoundary(
      child: Stack(
        children: _blobs.map((b) {
          final cx = b.x * screenSize.width;
          final cy = b.y * screenSize.height;
          final half = b.size / 2;

          return Positioned(
            left: cx - half,
            top: cy - half,
            child: Transform.rotate(
              angle: b.angle,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Opacity(
                  opacity: isDark ? 0.55 : 0.60,
                  child: SvgPicture.asset(
                    b.svgPath,
                    width: b.size,
                    height: b.size,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
