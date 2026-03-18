import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../../core/app_colors.dart';
import '../../the_oxygen_grid.dart';

class CorrosiveTile extends PositionComponent
    with HasGameReference<TheOxygenGrid> {
  CorrosiveTile({required this.gridRow, required this.gridCol})
      : super(priority: 0, anchor: Anchor.topLeft);

  final int gridRow;
  final int gridCol;

  double _time = 0;

  final _fillPaint = Paint()..style = PaintingStyle.fill;
  final _borderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;
  final _glowPaint = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 4);
  final _hazardPaint = Paint()..style = PaintingStyle.fill;

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
    _time += dt;
  }

  @override
  void render(Canvas canvas) {
    final revealOpacity = game.obstacleRevealManager.revealOpacity;
    if (revealOpacity <= 0) return;

    final pulse = 0.6 + 0.4 * sin(_time * 3);
    final alpha = (revealOpacity * pulse).clamp(0.0, 1.0);
    final rect = size.toRect();

    _fillPaint.color =
        AppColors.amberAlert.withAlpha((50 * alpha).toInt());
    canvas.drawRect(rect, _fillPaint);

    _glowPaint.color =
        AppColors.amberAlert.withAlpha((25 * alpha).toInt());
    canvas.drawRect(rect.inflate(2), _glowPaint);

    _drawDashedRect(canvas, rect, alpha);

    // Hazard symbol — biohazard-like triangle
    _drawHazardIcon(canvas, rect, alpha);
  }

  void _drawHazardIcon(Canvas canvas, Rect rect, double alpha) {
    final cx = rect.center.dx;
    final cy = rect.center.dy;
    final s = rect.width * 0.2;

    final path = Path()
      ..moveTo(cx, cy - s)
      ..lineTo(cx + s * 0.87, cy + s * 0.5)
      ..lineTo(cx - s * 0.87, cy + s * 0.5)
      ..close();

    _hazardPaint.color =
        AppColors.amberAlert.withAlpha((160 * alpha).toInt());
    canvas.drawPath(path, _hazardPaint);

    final exclaim = Paint()
      ..color = AppColors.deepVoid.withAlpha((200 * alpha).toInt())
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx, cy - s * 0.4),
      Offset(cx, cy + s * 0.05),
      exclaim,
    );
    canvas.drawCircle(Offset(cx, cy + s * 0.25), 0.8, exclaim);
  }

  void _drawDashedRect(Canvas canvas, Rect rect, double alpha) {
    _borderPaint.color =
        AppColors.amberAlert.withAlpha((180 * alpha).toInt());

    _drawDashedLine(canvas, Offset(rect.left, rect.top),
        Offset(rect.right, rect.top));
    _drawDashedLine(canvas, Offset(rect.right, rect.top),
        Offset(rect.right, rect.bottom));
    _drawDashedLine(canvas, Offset(rect.right, rect.bottom),
        Offset(rect.left, rect.bottom));
    _drawDashedLine(canvas, Offset(rect.left, rect.bottom),
        Offset(rect.left, rect.top));
  }

  static const double _dashLength = 4.0;
  static const double _gapLength = 4.0;

  void _drawDashedLine(Canvas canvas, Offset start, Offset end) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final length = Offset(dx, dy).distance;
    if (length <= 0) return;
    final unitDx = dx / length;
    final unitDy = dy / length;

    double drawn = 0;
    bool drawing = true;

    while (drawn < length) {
      final segLen = drawing ? _dashLength : _gapLength;
      final remaining = length - drawn;
      final seg = segLen < remaining ? segLen : remaining;

      if (drawing) {
        canvas.drawLine(
          Offset(start.dx + unitDx * drawn, start.dy + unitDy * drawn),
          Offset(
            start.dx + unitDx * (drawn + seg),
            start.dy + unitDy * (drawn + seg),
          ),
          _borderPaint,
        );
      }

      drawn += seg;
      drawing = !drawing;
    }
  }
}
