import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/services.dart';

import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../the_oxygen_grid.dart';

class SentryNode extends PositionComponent
    with HasGameReference<TheOxygenGrid> {
  SentryNode({
    required this.gridRow,
    required this.gridCol,
    this.patrolHorizontal = true,
    this.speedMultiplier = 1.0,
  }) : super(priority: 1, anchor: Anchor.center);

  int gridRow;
  int gridCol;

  final bool patrolHorizontal;
  final double speedMultiplier;

  int _direction = 1;
  double _elapsed = 0;
  double _pulseTime = 0;

  final _fillPaint = Paint()..style = PaintingStyle.fill;
  final _glowPaint = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 8);
  final _innerPaint = Paint()..style = PaintingStyle.fill;
  final _scanPaint = Paint()..style = PaintingStyle.fill;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    size = Vector2.all(game.tileSize * Layout.droneScaleFactor);
    position = _tileCenter(gridRow, gridCol);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!game.gameStateManager.isPlaying) return;

    _pulseTime += dt;

    final interval = Timing.sentryPatrolInterval / speedMultiplier;
    _elapsed += dt;

    if (_elapsed >= interval) {
      _elapsed -= interval;
      _advance();
    }
  }

  void _advance() {
    final nextRow = patrolHorizontal ? gridRow : gridRow + _direction;
    final nextCol = patrolHorizontal ? gridCol + _direction : gridCol;

    if (_isBlocked(nextRow, nextCol)) {
      _direction *= -1;
      return;
    }

    gridRow = nextRow;
    gridCol = nextCol;
    position = _tileCenter(gridRow, gridCol);

    _checkDroneCollision();
  }

  bool _isBlocked(int row, int col) {
    final data = game.sectorData;
    if (row < 0 || row >= data.rows || col < 0 || col >= data.columns) {
      return true;
    }
    return data.grid[row][col] == GridEntity.wall;
  }

  void _checkDroneCollision() {
    if (gridRow == game.drone.gridRow && gridCol == game.drone.gridCol) {
      final cost = O2Costs.sentryHit +
          O2Costs.obstaclePenalty(game.sectorData.sector);
      game.o2Manager.deductO2(cost);
      HapticFeedback.heavyImpact();
      game.triggerCameraShake();
      game.audioManager.playSentryHit();
    }
  }

  @override
  void render(Canvas canvas) {
    final revealOpacity = game.obstacleRevealManager.revealOpacity;
    if (revealOpacity <= 0) return;

    final pulse = 0.7 + 0.3 * sin(_pulseTime * 4);
    final alpha = (revealOpacity * pulse).clamp(0.0, 1.0);

    final baseColor = AppColors.coreBreach;

    _glowPaint.color = baseColor.withAlpha((60 * alpha).toInt());
    canvas.drawRect(size.toRect().inflate(4), _glowPaint);

    _fillPaint.color = baseColor.withAlpha((200 * alpha).toInt());
    canvas.drawRect(size.toRect(), _fillPaint);

    // Inner "eye" — a diamond shape
    final cx = size.x / 2;
    final cy = size.y / 2;
    final r = size.x * 0.25;
    final eyePath = Path()
      ..moveTo(cx, cy - r)
      ..lineTo(cx + r, cy)
      ..lineTo(cx, cy + r)
      ..lineTo(cx - r, cy)
      ..close();

    _innerPaint.color = AppColors.deepVoid.withAlpha((220 * alpha).toInt());
    canvas.drawPath(eyePath, _innerPaint);

    // Scanning line that sweeps across
    final scanY = cy + sin(_pulseTime * 6) * r * 0.8;
    _scanPaint.color = baseColor.withAlpha((180 * alpha).toInt());
    canvas.drawRect(
      Rect.fromLTWH(cx - r * 0.6, scanY - 1, r * 1.2, 2),
      _scanPaint,
    );
  }

  Vector2 _tileCenter(int row, int col) {
    return game.gridToPixel(row, col) + Vector2.all(game.tileSize / 2);
  }
}
