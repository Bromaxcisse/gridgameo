import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';

import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../the_oxygen_grid.dart';

class DroneComponent extends PositionComponent
    with HasGameReference<TheOxygenGrid> {
  DroneComponent({required this.gridRow, required this.gridCol})
      : super(priority: 2, anchor: Anchor.center);

  int gridRow;
  int gridCol;

  double _opacity = 1.0;
  bool _isGray = false;
  double _time = 0;
  bool get isMoving => children.whereType<MoveToEffect>().isNotEmpty;

  final _fillPaint = Paint()..style = PaintingStyle.fill;
  final _glowPaint = Paint();
  final _innerPaint = Paint()..style = PaintingStyle.fill;
  final _ringPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    size = Vector2.all(game.tileSize * Layout.droneScaleFactor);
    position = _tileCenter(gridRow, gridCol);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
  }

  @override
  void render(Canvas canvas) {
    final color = _isGray ? const Color(0xFF666666) : AppColors.cyanPlasma;
    final alpha = _opacity;

    // Outer glow
    if (!_isGray) {
      _glowPaint
        ..color = color.withAlpha((60 * alpha).toInt())
        ..maskFilter =
            const MaskFilter.blur(BlurStyle.outer, Layout.droneGlowSigma);
      canvas.drawRect(size.toRect().inflate(2), _glowPaint);
    }

    // Main body — rounded rect
    final bodyRect = RRect.fromRectAndRadius(
      size.toRect(),
      const Radius.circular(4),
    );
    _fillPaint.color = color.withAlpha((220 * alpha).toInt());
    canvas.drawRRect(bodyRect, _fillPaint);

    // Inner circuit pattern
    final cx = size.x / 2;
    final cy = size.y / 2;
    final r = size.x * 0.22;

    // Rotating ring
    final ringPulse = 0.8 + 0.2 * sin(_time * 5);
    _ringPaint.color = AppColors.deepVoid.withAlpha((200 * alpha * ringPulse).toInt());
    canvas.drawCircle(Offset(cx, cy), r, _ringPaint);

    // Center dot — "core"
    final coreSize = r * 0.45;
    final corePulse = 0.6 + 0.4 * sin(_time * 8);
    _innerPaint.color = _isGray
        ? const Color(0xFF444444).withAlpha((alpha * 255).toInt())
        : AppColors.deepVoid.withAlpha((220 * alpha * corePulse).toInt());
    canvas.drawCircle(Offset(cx, cy), coreSize, _innerPaint);

    // Corner accents
    if (!_isGray) {
      final accentPaint = Paint()
        ..color = AppColors.deepVoid.withAlpha((150 * alpha).toInt())
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round;
      final a = 3.0;
      final l = 6.0;
      // Top-left
      canvas.drawLine(Offset(a, a), Offset(a + l, a), accentPaint);
      canvas.drawLine(Offset(a, a), Offset(a, a + l), accentPaint);
      // Top-right
      canvas.drawLine(Offset(size.x - a, a), Offset(size.x - a - l, a), accentPaint);
      canvas.drawLine(Offset(size.x - a, a), Offset(size.x - a, a + l), accentPaint);
      // Bottom-left
      canvas.drawLine(Offset(a, size.y - a), Offset(a + l, size.y - a), accentPaint);
      canvas.drawLine(Offset(a, size.y - a), Offset(a, size.y - a - l), accentPaint);
      // Bottom-right
      canvas.drawLine(Offset(size.x - a, size.y - a), Offset(size.x - a - l, size.y - a), accentPaint);
      canvas.drawLine(Offset(size.x - a, size.y - a), Offset(size.x - a, size.y - a - l), accentPaint);
    }
  }

  void moveTo(int row, int col) {
    gridRow = row;
    gridCol = col;
    add(
      MoveToEffect(
        _tileCenter(row, col),
        EffectController(
          duration: Timing.movementDuration,
          curve: Curves.easeOutExpo,
        ),
      ),
    );
  }

  void playWarpOut({required VoidCallback onComplete}) {
    add(
      ScaleEffect.to(
        Vector2.zero(),
        EffectController(duration: 0.5, curve: Curves.easeInExpo),
        onComplete: onComplete,
      ),
    );
    _animateOpacity(0.0, 0.5);
  }

  void turnGray() {
    _isGray = true;
  }

  void _animateOpacity(double target, double duration) {
    final start = _opacity;
    final diff = target - start;
    double elapsed = 0;
    add(
      TimerComponent(
        period: 0.016,
        repeat: true,
        removeOnFinish: true,
        onTick: () {
          elapsed += 0.016;
          final t = (elapsed / duration).clamp(0.0, 1.0);
          _opacity = start + diff * t;
          if (t >= 1.0) {
            removeWhere((c) => c is TimerComponent);
          }
        },
      ),
    );
  }

  Vector2 _tileCenter(int row, int col) {
    return game.gridToPixel(row, col) + Vector2.all(game.tileSize / 2);
  }
}
