import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';

import 'core/app_colors.dart';
import 'core/app_constants.dart';
import 'game/components/corrosive_tile.dart';
import 'game/components/decaying_wall.dart';
import 'game/components/drone_component.dart';
import 'game/components/extraction_point.dart';
import 'game/components/grid_component.dart';
import 'game/components/sentry_node.dart';
import 'game/effects/extraction_particles.dart';
import 'game/effects/glitch_effect.dart';
import 'game/effects/vignette_effect.dart';
import 'game/managers/audio_manager.dart';
import 'game/managers/game_state_manager.dart';
import 'game/managers/input_manager.dart';
import 'game/managers/o2_manager.dart';
import 'game/managers/obstacle_reveal_manager.dart';
import 'models/sector_data.dart';

class TheOxygenGrid extends FlameGame with PanDetector {
  TheOxygenGrid({required this.sectorData});

  final SectorData sectorData;

  late double tileSize;
  late Vector2 gridOffset;
  late DroneComponent drone;
  late InputManager inputManager;
  late GameStateManager gameStateManager;
  late O2Manager o2Manager;
  late ObstacleRevealManager obstacleRevealManager;
  final AudioManager audioManager = AudioManager();

  final List<SentryNode> sentryNodes = [];
  final List<DecayingWall> decayingWalls = [];

  @override
  Color backgroundColor() => AppColors.deepVoid;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    camera.viewfinder.anchor = Anchor.topLeft;

    _calculateLayout();
    _spawnComponents();
  }

  void _calculateLayout() {
    final tileByWidth =
        (size.x - Layout.gridPadding * 2) / sectorData.columns;
    final tileByHeight =
        (size.y - Layout.gridPadding * 2) / sectorData.rows;
    tileSize = tileByWidth < tileByHeight ? tileByWidth : tileByHeight;

    final gridWidth = sectorData.columns * tileSize;
    final gridHeight = sectorData.rows * tileSize;
    gridOffset = Vector2(
      (size.x - gridWidth) / 2,
      (size.y - gridHeight) / 2,
    );
  }

  void _spawnComponents() {
    int droneRow = 0, droneCol = 0;
    int extractRow = 0, extractCol = 0;

    sentryNodes.clear();
    decayingWalls.clear();

    final isHunterWake = sectorData.sector >= 41;
    final speedMultiplier = isHunterWake ? 1.2 : 1.0;

    gameStateManager = GameStateManager();
    world.add(gameStateManager);

    o2Manager = O2Manager();
    world.add(o2Manager);

    obstacleRevealManager = ObstacleRevealManager();
    world.add(obstacleRevealManager);

    world.add(GridComponent());

    for (int row = 0; row < sectorData.rows; row++) {
      for (int col = 0; col < sectorData.columns; col++) {
        final cell = sectorData.grid[row][col];
        switch (cell) {
          case GridEntity.droneStart:
            droneRow = row;
            droneCol = col;
          case GridEntity.extractionPoint:
            extractRow = row;
            extractCol = col;
          case GridEntity.sentryNode:
            final sentry = SentryNode(
              gridRow: row,
              gridCol: col,
              patrolHorizontal: row.isEven,
              speedMultiplier: speedMultiplier,
            );
            sentryNodes.add(sentry);
            world.add(sentry);
          case GridEntity.corrosiveTile:
            world.add(CorrosiveTile(gridRow: row, gridCol: col));
          case GridEntity.decayingWall:
            final wall = DecayingWall(gridRow: row, gridCol: col);
            decayingWalls.add(wall);
            world.add(wall);
        }
      }
    }

    world.add(ExtractionPoint(gridRow: extractRow, gridCol: extractCol));

    drone = DroneComponent(gridRow: droneRow, gridCol: droneCol);
    world.add(drone);

    inputManager = InputManager();
    world.add(inputManager);

    world.add(VignetteEffect());
  }

  Vector2 gridToPixel(int row, int col) {
    return Vector2(
      gridOffset.x + col * tileSize,
      gridOffset.y + row * tileSize,
    );
  }

  void pauseGame() {
    gameStateManager.transitionTo(GameState.suspended);
    overlays.add('suspended');
    pauseEngine();
  }

  void resumeGame() {
    overlays.remove('suspended');
    resumeEngine();
    gameStateManager.transitionTo(GameState.playing);
  }

  void showExtractionSuccess() {
    world.add(ExtractionParticles(origin: drone.position.clone()));
    drone.playWarpOut(
      onComplete: () => overlays.add('extractionSuccess'),
    );
  }

  void showSignalLost() {
    drone.turnGray();
    world.add(
      GlitchEffect(
        onComplete: () => overlays.add('signalLost'),
      ),
    );
  }

  void triggerCameraShake() {
    final rng = Random();
    final offsetX = (rng.nextDouble() - 0.5) * 8;
    final offsetY = (rng.nextDouble() - 0.5) * 8;
    camera.viewfinder.add(
      MoveByEffect(
        Vector2(offsetX, offsetY),
        EffectController(
          duration: 0.1,
          reverseDuration: 0.1,
        ),
      ),
    );
  }

  // — Swipe tracking —

  Vector2 _panDelta = Vector2.zero();

  @override
  void onPanStart(DragStartInfo info) {
    _panDelta = Vector2.zero();
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    _panDelta += info.delta.global;
  }

  @override
  void onPanEnd(DragEndInfo info) {
    inputManager.handleSwipe(_panDelta);
  }
}
