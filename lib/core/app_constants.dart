abstract final class GridEntity {
  static const int empty = 0;
  static const int wall = 1;
  static const int droneStart = 2;
  static const int extractionPoint = 3;
  static const int sentryNode = 4;
  static const int corrosiveTile = 5;
  static const int decayingWall = 6;
}

abstract final class Timing {
  static const double movementDuration = 0.12;
  static const double sentryPatrolInterval = 2.0;
  static const double decayingWallCycle = 3.0;

  /// O2 drain interval — decreases as sectors progress, making the
  /// timer feel faster at higher levels.
  static double o2TickInterval(int sector) {
    if (sector <= 5) return 1.0;
    if (sector <= 15) return 0.9;
    if (sector <= 25) return 0.85;
    if (sector <= 40) return 0.8;
    return 0.7;
  }

  /// How long obstacles remain visible at the start of a sector.
  /// Scales down as the player progresses through sectors.
  static double obstacleRevealDuration(int sector) {
    if (sector <= 5) return 3.0;
    if (sector <= 15) return 2.0;
    if (sector <= 25) return 1.5;
    if (sector <= 40) return 1.2;
    return 0.8;
  }
}

abstract final class O2Thresholds {
  static const double warningPercent = 0.50;
  static const double criticalPercent = 0.20;
}

abstract final class O2Costs {
  static const int move = 1;
  static const int tick = 1;
  static const int sentryHit = 10;
  static const int corrosiveTile = 2; // additional cost on top of move
  static const int wallCollision = 2;

  /// Extra O2 penalty that scales with sector progression.
  static int obstaclePenalty(int sector) {
    if (sector <= 5) return 0;
    if (sector <= 15) return 1;
    if (sector <= 25) return 2;
    if (sector <= 40) return 3;
    return 4;
  }
}

abstract final class Scoring {
  static const int baseScore = 100;
  static const int o2Multiplier = 10;
}

abstract final class Layout {
  static const double gridPadding = 16.0;
  static const double droneScaleFactor = 0.80;
  static const double droneGlowSigma = 10.0;
  static const double extractionRotationSpeed = 15.0; // degrees per second
}
