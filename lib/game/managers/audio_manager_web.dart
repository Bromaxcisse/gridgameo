import 'package:web/web.dart' as web;

/// Synthesizes and plays short sound effects using the Web Audio API.
/// All sounds are generated procedurally — no audio files needed.
class AudioManager {
  static final AudioManager _instance = AudioManager._();
  factory AudioManager() => _instance;
  AudioManager._();

  web.AudioContext? _ctx;
  bool enabled = true;

  web.AudioContext get _context {
    _ctx ??= web.AudioContext();
    return _ctx!;
  }

  void _resumeIfNeeded() {
    if (_context.state == 'suspended') {
      _context.resume();
    }
  }

  void playMove() {
    if (!enabled) return;
    _resumeIfNeeded();
    _playTone(frequency: 520, duration: 0.05, type: 'sine', volume: 0.12);
  }

  void playBlocked() {
    if (!enabled) return;
    _resumeIfNeeded();
    _playTone(frequency: 150, duration: 0.1, type: 'square', volume: 0.15);
  }

  void playSentryHit() {
    if (!enabled) return;
    _resumeIfNeeded();
    final now = _context.currentTime;
    _playTone(
      frequency: 120,
      duration: 0.3,
      type: 'sawtooth',
      volume: 0.2,
      startTime: now,
    );
    _playTone(
      frequency: 80,
      duration: 0.2,
      type: 'square',
      volume: 0.15,
      startTime: now + 0.05,
    );
  }

  void playCorrosive() {
    if (!enabled) return;
    _resumeIfNeeded();
    _playTone(
      frequency: 2400,
      duration: 0.12,
      type: 'sine',
      volume: 0.06,
      endFrequency: 1200,
    );
  }

  void playExtraction() {
    if (!enabled) return;
    _resumeIfNeeded();
    final now = _context.currentTime;
    const notes = [523.25, 659.25, 783.99, 1046.50];
    for (int i = 0; i < notes.length; i++) {
      _playTone(
        frequency: notes[i],
        duration: 0.18,
        type: 'sine',
        volume: 0.15,
        startTime: now + i * 0.1,
      );
    }
  }

  void playSignalLost() {
    if (!enabled) return;
    _resumeIfNeeded();
    _playTone(
      frequency: 200,
      duration: 0.6,
      type: 'sawtooth',
      volume: 0.18,
      endFrequency: 40,
    );
  }

  void playRevealFade() {
    if (!enabled) return;
    _resumeIfNeeded();
    _playTone(
      frequency: 600,
      duration: 0.5,
      type: 'sine',
      volume: 0.05,
      endFrequency: 150,
    );
  }

  void playO2Warning() {
    if (!enabled) return;
    _resumeIfNeeded();
    _playTone(frequency: 880, duration: 0.04, type: 'square', volume: 0.06);
  }

  void _playTone({
    required double frequency,
    required double duration,
    required String type,
    required double volume,
    double? startTime,
    double? endFrequency,
  }) {
    final ctx = _context;
    final now = startTime ?? ctx.currentTime;

    final osc = ctx.createOscillator();
    osc.type = type;
    osc.frequency.setValueAtTime(frequency, now);
    if (endFrequency != null) {
      osc.frequency.exponentialRampToValueAtTime(endFrequency, now + duration);
    }

    final gain = ctx.createGain();
    gain.gain.setValueAtTime(volume, now);
    gain.gain.exponentialRampToValueAtTime(0.001, now + duration);

    osc.connect(gain);
    gain.connect(ctx.destination);

    osc.start(now);
    osc.stop(now + duration + 0.01);
  }
}
