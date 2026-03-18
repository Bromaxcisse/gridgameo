import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../../the_oxygen_grid.dart';

class GlitchEffect extends Component with HasGameReference<TheOxygenGrid> {
  static const double _duration = 0.3;
  static const int _frameCount = 4;
  static const double _maxOffset = 12.0;

  double _elapsed = 0;
  int _currentFrame = 0;
  final _rng = Random();

  final VoidCallback onComplete;

  GlitchEffect({required this.onComplete});

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;

    final frame = ((_elapsed / _duration) * _frameCount).floor();
    if (frame > _currentFrame && frame < _frameCount) {
      _currentFrame = frame;
      final offset = (_rng.nextDouble() - 0.5) * _maxOffset * 2;
      game.camera.viewfinder.position = Vector2(offset, 0);
    }

    if (_elapsed >= _duration) {
      game.camera.viewfinder.position = Vector2.zero();
      onComplete();
      removeFromParent();
    }
  }
}
