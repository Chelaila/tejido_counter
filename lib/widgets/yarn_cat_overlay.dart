import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

enum _State { chasing, playing, dropping }

const int _kFrameCount = 33;
const double _kAnimDuration = 0.66; // seconds for one full cycle

class YarnCatOverlay extends StatefulWidget {
  final Widget child;
  const YarnCatOverlay({super.key, required this.child});

  @override
  State<YarnCatOverlay> createState() => _YarnCatOverlayState();
}

class _YarnCatOverlayState extends State<YarnCatOverlay>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final _rng = Random();

  _State _state = _State.chasing;
  double _playTimer = 0;

  // All positions = CENTER of sprite
  double _yarnX = 0;
  double _yarnY = 0;
  double _yarnVX = 0;
  double _yarnVY = 0;
  double _yarnAngle = 0;
  double _yarnBobPhase = 0;

  double _catX = 0;
  double _catY = 0;
  double _animTime = 0; // accumulated time for sprite cycling
  bool _facingRight = true;

  bool _initialized = false;
  Size _screenSize = Size.zero;
  Duration _prevElapsed = Duration.zero;

  static const double _yarnSize = 34;
  static const double _catSize = 72;
  static const double _bottomPad = 20;
  static const double _catSpeed = 230;
  static const double _playDuration = 1.6;
  static const double _catchDist = 10;
  static const double _gravity = 1400;
  static const double _yarnMinSpeed = 80;
  static const double _yarnMaxSpeed = 150;

  double get _yarnFloorY => _screenSize.height - _bottomPad - _yarnSize / 2;
  double get _catFloorY => _screenSize.height - _bottomPad - _catSize / 2;
  double get _yarnMinX => _yarnSize / 2;
  double get _yarnMaxX => _screenSize.width - _yarnSize / 2;

  double _randomYarnSpeed() =>
      (_yarnMinSpeed + _rng.nextDouble() * (_yarnMaxSpeed - _yarnMinSpeed)) *
      (_rng.nextBool() ? 1 : -1);

  int get _currentFrame {
    final t = _animTime % _kAnimDuration;
    final fwd = (t * _kFrameCount / _kAnimDuration).toInt().clamp(0, _kFrameCount - 1);
    // When mirrored (going right), reverse frame order so the roll direction matches movement
    return _facingRight ? (_kFrameCount - 1 - fwd) : fwd;
  }

  String _framePath(int frame) =>
      'assets/cat_frames/cat_${frame.toString().padLeft(2, '0')}.webp';

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precache all frames so first render is instant
    for (var i = 0; i < _kFrameCount; i++) {
      precacheImage(AssetImage(_framePath(i)), context);
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _init() {
    if (_initialized || _screenSize == Size.zero) return;
    _catX = _screenSize.width * 0.2;
    _catY = _catFloorY;
    _yarnX = _screenSize.width * 0.72;
    _yarnY = _yarnFloorY;
    _yarnVX = _randomYarnSpeed();
    _initialized = true;
  }

  void _onTick(Duration elapsed) {
    if (_screenSize == Size.zero) return;
    _init();

    final dt = ((elapsed - _prevElapsed).inMicroseconds / 1e6).clamp(0.0, 0.05);
    _prevElapsed = elapsed;

    switch (_state) {
      case _State.chasing:
        _tickChasing(dt);
      case _State.playing:
        _tickPlaying(dt);
      case _State.dropping:
        _tickDropping(dt);
    }

    setState(() {});
  }

  void _moveYarnLinear(double dt, {double spinScale = 1.0}) {
    _yarnX += _yarnVX * dt;
    _yarnBobPhase += dt * 2.2;
    _yarnY = _yarnFloorY - sin(_yarnBobPhase).abs() * 12;

    if (_yarnX <= _yarnMinX) {
      _yarnX = _yarnMinX;
      _yarnVX = _yarnVX.abs();
    }
    if (_yarnX >= _yarnMaxX) {
      _yarnX = _yarnMaxX;
      _yarnVX = -_yarnVX.abs();
    }

    _yarnAngle += (_yarnVX > 0 ? 1.0 : -1.0) * dt * 4 * spinScale;
  }

  void _tickChasing(double dt) {
    _moveYarnLinear(dt);
    _moveCatToward(_yarnX, _yarnY, dt);
    _animTime += dt;

    if (_distXY(_catX, _catY, _yarnX, _yarnY) < _catchDist) {
      _state = _State.playing;
      _playTimer = _playDuration;
    }
  }

  void _tickPlaying(double dt) {
    _moveYarnLinear(dt, spinScale: 0.4);
    _catX = _yarnX;
    _catY = _yarnY;
    _animTime += dt;

    _playTimer -= dt;
    if (_playTimer <= 0) _spawnNewYarn();
  }

  void _spawnNewYarn() {
    final w = _screenSize.width;
    final double spawnX;
    if (_catX / w < 0.5) {
      spawnX =
          (w * (0.55 + _rng.nextDouble() * 0.38)).clamp(_yarnMinX, _yarnMaxX);
    } else {
      spawnX = (w * (_rng.nextDouble() * 0.38) + _yarnMinX)
          .clamp(_yarnMinX, _yarnMaxX);
    }
    _yarnX = spawnX;
    _yarnY = -_yarnSize;
    _yarnVY = 0;
    _state = _State.dropping;
  }

  void _tickDropping(double dt) {
    _yarnVY += _gravity * dt;
    _yarnY += _yarnVY * dt;
    _yarnAngle += dt * 7;

    if (_yarnY >= _yarnFloorY) {
      _yarnY = _yarnFloorY;
      _yarnVY *= -0.28;
      if (_yarnVY.abs() < 55) {
        _yarnVY = 0;
        _yarnVX = _randomYarnSpeed();
        _yarnBobPhase = _rng.nextDouble() * pi * 2;
        _state = _State.chasing;
      }
    }

    _catY += (_catFloorY - _catY) * dt * 10;
    final dx = _yarnX - _catX;
    if (dx.abs() > 4) {
      final step = (_catSpeed * dt).clamp(0.0, dx.abs());
      _catX += dx.sign * step;
      _facingRight = dx > 0;
      _animTime += dt;
    }
  }

  void _moveCatToward(double tx, double ty, double dt) {
    final dx = tx - _catX;
    final dy = ty - _catY;
    final dist = sqrt(dx * dx + dy * dy);
    if (dist > 2) {
      final speed =
          (_catSpeed * (1 + dist * 0.012)).clamp(0.0, _catSpeed * 2.4);
      final step = (speed * dt).clamp(0.0, dist);
      _catX += dx / dist * step;
      _catY += dy / dist * step;
      if (dx.abs() > 1) _facingRight = dx > 0;
    }
  }

  double _distXY(double ax, double ay, double bx, double by) {
    final dx = ax - bx;
    final dy = ay - by;
    return sqrt(dx * dx + dy * dy);
  }

  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.sizeOf(context);

    return Stack(
      children: [
        widget.child,

        // Yarn ball
        Positioned(
          left: _yarnX - _yarnSize / 2,
          top: _yarnY - _yarnSize / 2,
          child: IgnorePointer(
            child: Transform.rotate(
              angle: _yarnAngle,
              child: Text(
                '🧶',
                style: TextStyle(
                  fontSize: _yarnSize,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
        ),

        // Cat sprite
        Positioned(
          left: _catX - _catSize / 2,
          top: _catY - _catSize / 2,
          child: IgnorePointer(
            child: Transform.scale(
              scaleX: _facingRight ? -1.0 : 1.0,
              child: Image.asset(
                _framePath(_currentFrame),
                width: _catSize,
                height: _catSize,
                fit: BoxFit.contain,
                gaplessPlayback: true,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
