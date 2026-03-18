import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/particles.dart';

import '../../core/app_colors.dart';
import '../../the_oxygen_grid.dart';

class ExtractionParticles extends PositionComponent
    with HasGameReference<TheOxygenGrid> {
  ExtractionParticles({required this.origin}) : super(priority: 11);

  final Vector2 origin;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final rng = Random();
    final particles = List.generate(12, (_) {
      final speed = Vector2(
        (rng.nextDouble() - 0.5) * 200,
        (rng.nextDouble() - 0.5) * 200,
      );
      final particleSize = 3.0 + rng.nextDouble() * 4;
      return AcceleratedParticle(
        position: origin.clone(),
        speed: speed,
        child: ComputedParticle(
          renderer: (canvas, particle) {
            final paint = Paint()
              ..color = AppColors.cyanPlasma
                  .withValues(alpha: 1.0 - particle.progress);
            canvas.drawRect(
              Rect.fromCenter(
                center: Offset.zero,
                width: particleSize * (1.0 - particle.progress),
                height: particleSize * (1.0 - particle.progress),
              ),
              paint,
            );
          },
        ),
      );
    });

    add(
      ParticleSystemComponent(
        particle: Particle.generate(
          count: particles.length,
          lifespan: 0.5,
          generator: (i) => particles[i],
        ),
      ),
    );
  }
}
