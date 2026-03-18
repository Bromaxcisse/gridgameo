import 'package:flame/components.dart';

import '../../core/app_constants.dart';
import '../../the_oxygen_grid.dart';
import 'game_state_manager.dart';

class O2Manager extends Component with HasGameReference<TheOxygenGrid> {
  late int _currentO2;
  late int _startingO2;
  late Timer _tickTimer;

  int get currentO2 => _currentO2;

  double get o2Percentage => _startingO2 > 0 ? _currentO2 / _startingO2 : 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _startingO2 = game.sectorData.startingO2;
    _currentO2 = _startingO2;

    _tickTimer = Timer(
      Timing.o2TickInterval(game.sectorData.sector),
      onTick: () => deductO2(O2Costs.tick),
      repeat: true,
    );
    _tickTimer.start();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.gameStateManager.isPlaying) {
      _tickTimer.update(dt);
    }
  }

  void deductO2(int amount) {
    _currentO2 = (_currentO2 - amount).clamp(0, _startingO2);

    if (o2Percentage < O2Thresholds.criticalPercent && _currentO2 > 0) {
      game.audioManager.playO2Warning();
    }

    if (_currentO2 <= 0) {
      game.gameStateManager.transitionTo(GameState.signalLost);
    }
  }
}
