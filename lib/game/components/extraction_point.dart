import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../the_oxygen_grid.dart';

class ExtractionPoint extends PositionComponent
    with HasGameReference<TheOxygenGrid> {
  ExtractionPoint({required this.gridRow, required this.gridCol})
      : super(priority: 1, anchor: Anchor.center);

  final int gridRow;
  final int gridCol;

  static const double _rotationSpeed =
      Layout.extractionRotationSpeed * pi / 180;

  double _time = 0;

  final _paint = Paint()
    ..color = AppColors.neonIsotope
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  final _glowPaint = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 6);

  final _innerPaint = Paint()..style = PaintingStyle.stroke;

  final _corePaint = Paint()..style = PaintingStyle.fill;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    size = Vector2.all(game.tileSize * 0.6);
    position =
        game.gridToPixel(gridRow, gridCol) + Vector2.all(game.tileSize / 2);
  }

  @override
  void update(double dt) {
    super.update(dt);
    angle += _rotationSpeed * dt;
    _time += dt;
  }

  @override
  void render(Canvas canvas) {
    final hw = size.x / 2;
    final hh = size.y / 2;

    final pulse = 0.6 + 0.4 * sin(_time * 3);

    // Outer glow
    _glowPaint.color =
        AppColors.neonIsotope.withAlpha((40 * pulse).toInt());
    canvas.drawCircle(Offset(hw, hh), hw * 1.2, _glowPaint);

    // Outer diamond
    final path = Path()
      ..moveTo(hw, 0)
      ..lineTo(size.x, hh)
      ..lineTo(hw, size.y)
      ..lineTo(0, hh)
      ..close();
    _paint.color =
        AppColors.neonIsotope.withAlpha((220 * pulse).toInt());
    canvas.drawPath(path, _paint);

    // Inner diamond (counter-rotating effect via smaller scale)
    final innerScale = 0.55;
    final iw = hw * innerScale;
    final ih = hh * innerScale;
    final innerPath = Path()
      ..moveTo(hw, hh - ih)
      ..lineTo(hw + iw, hh)
      ..lineTo(hw, hh + ih)
      ..lineTo(hw - iw, hh)
      ..close();
    _innerPaint
      ..color = AppColors.neonIsotope.withAlpha((150 * pulse).toInt())
      ..strokeWidth = 1;
    canvas.drawPath(innerPath, _innerPaint);

    // Center core dot
    final coreRadius = hw * 0.12;
    _corePaint.color =
        AppColors.neonIsotope.withAlpha((255 * pulse).toInt());
    canvas.drawCircle(Offset(hw, hh), coreRadius, _corePaint);
  }
}
