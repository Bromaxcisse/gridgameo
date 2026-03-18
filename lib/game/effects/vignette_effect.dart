import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../the_oxygen_grid.dart';

class VignetteEffect extends PositionComponent
    with HasGameReference<TheOxygenGrid> {
  VignetteEffect() : super(priority: 10);

  static const double _pulseCycleDuration = 0.8;

  double _elapsed = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    size = game.size;
    position = Vector2.zero();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.gameStateManager.isPlaying) {
      _elapsed += dt;
    }
  }

  @override
  void render(Canvas canvas) {
    final pct = game.o2Manager.o2Percentage;
    if (pct >= O2Thresholds.criticalPercent) return;

    final intensity = 1.0 - (pct / O2Thresholds.criticalPercent);

    final pulsePhase = (_elapsed % _pulseCycleDuration) / _pulseCycleDuration;
    final pulse = 0.5 + 0.5 * sin(pulsePhase * 2 * pi);

    final alpha = (intensity * 0.6 * (0.5 + 0.5 * pulse)).clamp(0.0, 1.0);

    final rect = size.toRect();
    final center = Offset(rect.width / 2, rect.height / 2);
    final radius = max(rect.width, rect.height) * 0.7;

    final gradient = RadialGradient(
      center: Alignment.center,
      radius: 0.8,
      colors: [
        const Color(0x00000000),
        AppColors.coreBreach.withValues(alpha: alpha),
      ],
      stops: const [0.3, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );

    canvas.drawRect(rect, paint);
  }
}
