import 'package:flame/components.dart';
import 'package:flutter/services.dart';

import '../../core/app_constants.dart';
import '../../the_oxygen_grid.dart';

class InputManager extends Component with HasGameReference<TheOxygenGrid> {
  static const double _minSwipeDistance = 20.0;

  void handleSwipe(Vector2 delta) {
    if (!game.gameStateManager.isPlaying) return;
    if (delta.length < _minSwipeDistance) return;
    if (game.drone.isMoving) return;

    int dRow = 0;
    int dCol = 0;

    if (delta.x.abs() > delta.y.abs()) {
      dCol = delta.x > 0 ? 1 : -1;
    } else {
      dRow = delta.y > 0 ? 1 : -1;
    }

    final targetRow = game.drone.gridRow + dRow;
    final targetCol = game.drone.gridCol + dCol;

    if (_isBlocked(targetRow, targetCol)) {
      HapticFeedback.heavyImpact();
      game.audioManager.playBlocked();
      game.o2Manager.deductO2(O2Costs.wallCollision);
      return;
    }

    game.drone.moveTo(targetRow, targetCol);
    HapticFeedback.lightImpact();
    game.audioManager.playMove();

    game.o2Manager.deductO2(O2Costs.move);

    _evaluateCollision(targetRow, targetCol);
  }

  void _evaluateCollision(int row, int col) {
    if (!game.gameStateManager.isPlaying) return;

    final cell = game.sectorData.grid[row][col];

    switch (cell) {
      case GridEntity.extractionPoint:
        game.audioManager.playExtraction();
        game.gameStateManager.completeExtraction(
          game.o2Manager.currentO2,
          game.sectorData.sector,
        );
      case GridEntity.corrosiveTile:
        game.audioManager.playCorrosive();
        final corrosiveCost = O2Costs.corrosiveTile +
            O2Costs.obstaclePenalty(game.sectorData.sector);
        game.o2Manager.deductO2(corrosiveCost);
    }

    if (!game.gameStateManager.isPlaying) return;

    final hitSentry = game.sentryNodes
        .any((s) => s.gridRow == row && s.gridCol == col);
    if (hitSentry) {
      final sentryCost = O2Costs.sentryHit +
          O2Costs.obstaclePenalty(game.sectorData.sector);
      game.o2Manager.deductO2(sentryCost);
      HapticFeedback.heavyImpact();
      game.triggerCameraShake();
      game.audioManager.playSentryHit();
    }
  }

  bool _isBlocked(int row, int col) {
    final data = game.sectorData;
    if (row < 0 || row >= data.rows || col < 0 || col >= data.columns) {
      return true;
    }
    final cell = data.grid[row][col];
    if (cell == GridEntity.wall) return true;
    if (cell == GridEntity.decayingWall) {
      return game.decayingWalls
          .any((w) => w.gridRow == row && w.gridCol == col && w.isSolid);
    }
    return false;
  }
}
