import 'package:flame/components.dart';

import '../../core/app_constants.dart';
import '../../the_oxygen_grid.dart';

class ObstacleRevealManager extends Component
    with HasGameReference<TheOxygenGrid> {
  late double _revealDuration;
  double _elapsed = 0;
  bool _revealed = true;
  bool _fadeStarted = false;
  bool _fadeSoundPlayed = false;

  bool get isRevealed => _revealed;

  /// 0.0 = fully hidden, 1.0 = fully visible. Used for fade-out animation.
  double get revealOpacity {
    if (_revealed && !_fadeStarted) return 1.0;
    if (!_revealed) return 0.0;

    final fadeStart = _revealDuration * 0.6;
    final fadeDuration = _revealDuration * 0.4;
    final fadeProgress = ((_elapsed - fadeStart) / fadeDuration).clamp(0.0, 1.0);
    return 1.0 - fadeProgress;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _revealDuration =
        Timing.obstacleRevealDuration(game.sectorData.sector);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!game.gameStateManager.isPlaying) return;
    if (!_revealed) return;

    _elapsed += dt;

    if (!_fadeStarted && _elapsed >= _revealDuration * 0.6) {
      _fadeStarted = true;
      if (!_fadeSoundPlayed) {
        _fadeSoundPlayed = true;
        game.audioManager.playRevealFade();
      }
    }

    if (_elapsed >= _revealDuration) {
      _revealed = false;
    }
  }
}
