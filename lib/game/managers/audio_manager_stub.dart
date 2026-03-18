/// No-op AudioManager for native platforms (Android, iOS, desktop).
/// Web Audio API is unavailable outside the browser.
class AudioManager {
  static final AudioManager _instance = AudioManager._();
  factory AudioManager() => _instance;
  AudioManager._();

  bool enabled = true;

  void playMove() {}
  void playBlocked() {}
  void playSentryHit() {}
  void playCorrosive() {}
  void playExtraction() {}
  void playSignalLost() {}
  void playRevealFade() {}
  void playO2Warning() {}
}
