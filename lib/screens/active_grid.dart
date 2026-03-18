import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../models/sector_factory.dart';
import '../the_oxygen_grid.dart';
import 'overlays/extraction_success_overlay.dart';
import 'overlays/hud_overlay.dart';
import 'overlays/signal_lost_overlay.dart';
import 'overlays/suspended_state_overlay.dart';

class ActiveGrid extends StatefulWidget {
  const ActiveGrid({super.key, required this.sector});

  final int sector;

  @override
  State<ActiveGrid> createState() => _ActiveGridState();
}

class _ActiveGridState extends State<ActiveGrid> {
  late TheOxygenGrid _game;

  @override
  void initState() {
    super.initState();
    _game = TheOxygenGrid(
      sectorData: SectorFactory.getSector(widget.sector),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: GameWidget<TheOxygenGrid>(
          game: _game,
          overlayBuilderMap: {
            'hud': (context, game) => HudOverlay(game: game),
            'suspended': (context, game) => SuspendedStateOverlay(game: game),
            'extractionSuccess': (context, game) =>
                ExtractionSuccessOverlay(game: game),
            'signalLost': (context, game) => SignalLostOverlay(game: game),
          },
          initialActiveOverlays: const ['hud'],
        ),
      ),
    );
  }
}
