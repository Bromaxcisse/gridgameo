import 'dart:ui';

import 'package:flame/components.dart';

import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../the_oxygen_grid.dart';

class GridComponent extends PositionComponent
    with HasGameReference<TheOxygenGrid> {
  GridComponent() : super(priority: 0);

  static final Color _wallBorderColor =
      Color.lerp(AppColors.terminalDim, AppColors.textPrimary, 0.15)!;

  final _linePaint = Paint()
    ..color = AppColors.terminalDim
    ..strokeWidth = 1;

  final _wallFillPaint = Paint()
    ..color = AppColors.terminalDim
    ..style = PaintingStyle.fill;

  final _wallBorderPaint = Paint()
    ..color = _wallBorderColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  final _wallGlowPaint = Paint()
    ..color = AppColors.cyanPlasma.withAlpha(20)
    ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 6);

  double _scanLineOffset = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    position = game.gridOffset;
    size = Vector2(
      game.sectorData.columns * game.tileSize,
      game.sectorData.rows * game.tileSize,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _scanLineOffset = (_scanLineOffset + dt * 30) % size.y;
  }

  @override
  void render(Canvas canvas) {
    final ts = game.tileSize;
    final data = game.sectorData;
    final revealOpacity = game.obstacleRevealManager.revealOpacity;

    for (int col = 0; col <= data.columns; col++) {
      final x = col * ts;
      canvas.drawLine(Offset(x, 0), Offset(x, size.y), _linePaint);
    }

    for (int row = 0; row <= data.rows; row++) {
      final y = row * ts;
      canvas.drawLine(Offset(0, y), Offset(size.x, y), _linePaint);
    }

    for (int row = 0; row < data.rows; row++) {
      for (int col = 0; col < data.columns; col++) {
        if (data.grid[row][col] == GridEntity.wall) {
          final rect = Rect.fromLTWH(col * ts, row * ts, ts, ts);
          final alpha = revealOpacity.clamp(0.0, 1.0);

          _wallFillPaint.color =
              AppColors.terminalDim.withAlpha((alpha * 255).toInt());
          _wallBorderPaint.color =
              _wallBorderColor.withAlpha((alpha * 255).toInt());

          canvas.drawRect(rect, _wallFillPaint);
          canvas.drawRect(rect, _wallBorderPaint);

          if (alpha > 0.3) {
            _wallGlowPaint.color = AppColors.cyanPlasma
                .withAlpha((20 * alpha).toInt());
            canvas.drawRect(rect.inflate(2), _wallGlowPaint);
          }

          if (alpha > 0 && alpha < 1.0) {
            _drawScanLines(canvas, rect, alpha);
          }
        }
      }
    }
  }

  void _drawScanLines(Canvas canvas, Rect rect, double alpha) {
    final scanPaint = Paint()
      ..color = AppColors.cyanPlasma.withAlpha((30 * alpha).toInt())
      ..strokeWidth = 0.5;

    final spacing = 4.0;
    for (double y = (rect.top + _scanLineOffset) % spacing;
        y < rect.bottom;
        y += spacing) {
      if (y >= rect.top) {
        canvas.drawLine(
          Offset(rect.left, y),
          Offset(rect.right, y),
          scanPaint,
        );
      }
    }
  }
}
