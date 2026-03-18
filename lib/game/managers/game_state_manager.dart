import 'package:flame/components.dart';
import 'package:flutter/services.dart';

import '../../core/app_constants.dart';
import '../../models/save_data.dart';
import '../../the_oxygen_grid.dart';

enum GameState {
  booting,
  menu,
  playing,
  suspended,
  extractionSuccessful,
  signalLost,
}

class GameStateManager extends Component
    with HasGameReference<TheOxygenGrid> {
  GameState _currentState = GameState.playing;

  GameState get currentState => _currentState;

  bool get isPlaying => _currentState == GameState.playing;

  int? lastEfficiencyRating;

  void transitionTo(GameState newState) {
    _currentState = newState;

    if (newState == GameState.extractionSuccessful) {
      game.showExtractionSuccess();
    } else if (newState == GameState.signalLost) {
      HapticFeedback.heavyImpact();
      game.triggerCameraShake();
      game.audioManager.playSignalLost();
      game.showSignalLost();
    }
  }

  void completeExtraction(int remainingO2, int sector) {
    lastEfficiencyRating =
        Scoring.baseScore + (remainingO2 * Scoring.o2Multiplier);
    SaveData.saveEfficiencyRating(sector, lastEfficiencyRating!);
    transitionTo(GameState.extractionSuccessful);
  }
}
