import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../the_oxygen_grid.dart';

class DecayingWall extends PositionComponent
    with HasGameReference<TheOxygenGrid> {
  DecayingWall({required this.gridRow, required this.gridCol})
      : super(priority: 0, anchor: Anchor.topLeft);

  final int gridRow;
  final int gridCol;

  double _elapsed = 0;

  bool get isSolid {
    final phase = _elapsed % Timing.decayingWallCycle;
    return phase < Timing.decayingWallCycle / 2;
  }

  static final Color _wallBorderColor =
      Color.lerp(AppColors.terminalDim, AppColors.textPrimary, 0.15)!;

  final _wallFillPaint = Paint()
    ..color = AppColors.terminalDim
    ..style = PaintingStyle.fill;

  final _wallBorderPaint = Paint()
    ..color = _wallBorderColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  final _glitchPaint = Paint()..style = PaintingStyle.fill;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final ts = game.tileSize;
    size = Vector2.all(ts);
    position = game.gridToPixel(gridRow, gridCol);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!game.gameStateManager.isPlaying) return;
    _elapsed += dt;
  }

  @override
  void render(Canvas canvas) {
    final revealOpacity = game.obstacleRevealManager.revealOpacity;
    if (revealOpacity <= 0) return;

    final phase = _elapsed % Timing.decayingWallCycle;
    final halfCycle = Timing.decayingWallCycle / 2;

    double cycleOpacity;
    if (phase < halfCycle) {
      cycleOpacity = 1.0 - (phase / halfCycle) * 0.7;
    } else {
      cycleOpacity = 0.3 + ((phase - halfCycle) / halfCycle) * 0.7;
    }

    final alpha = (cycleOpacity * revealOpacity).clamp(0.0, 1.0);
    final rect = size.toRect();

    _wallFillPaint.color =
        AppColors.terminalDim.withAlpha((alpha * 255).toInt());
    _wallBorderPaint.color =
        _wallBorderColor.withAlpha((alpha * 255).toInt());

    canvas.drawRect(rect, _wallFillPaint);
    canvas.drawRect(rect, _wallBorderPaint);

    // Glitch stripes when transitioning
    if (phase > halfCycle * 0.7 && phase < halfCycle * 1.3) {
      final glitchAlpha = (alpha * 0.4).clamp(0.0, 1.0);
      _glitchPaint.color =
          AppColors.cyanPlasma.withAlpha((glitchAlpha * 100).toInt());
      final stripeH = size.y * 0.08;
      for (int i = 0; i < 3; i++) {
        final y = (sin(_elapsed * 12 + i * 2.1) * 0.5 + 0.5) * size.y;
        canvas.drawRect(
          Rect.fromLTWH(0, y.clamp(0, size.y - stripeH), size.x, stripeH),
          _glitchPaint,
        );
      }
    }
  }
}
