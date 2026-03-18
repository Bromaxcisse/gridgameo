import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_text_styles.dart';
import '../../the_oxygen_grid.dart';

class HudOverlay extends StatefulWidget {
  const HudOverlay({super.key, required this.game});

  final TheOxygenGrid game;

  @override
  State<HudOverlay> createState() => _HudOverlayState();
}

class _HudOverlayState extends State<HudOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color _o2Color(double percentage) {
    if (percentage > O2Thresholds.warningPercent) return AppColors.cyanPlasma;
    if (percentage > O2Thresholds.criticalPercent) return AppColors.amberAlert;
    return AppColors.coreBreach;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(),
            Expanded(
              flex: 2,
              child: _O2Display(
                game: widget.game,
                pulseScale: _pulseScale,
                o2Color: _o2Color,
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.topRight,
                child: _PauseButton(game: widget.game),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _O2Display extends StatelessWidget {
  const _O2Display({
    required this.game,
    required this.pulseScale,
    required this.o2Color,
  });

  final TheOxygenGrid game;
  final Animation<double> pulseScale;
  final Color Function(double) o2Color;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseScale,
      builder: (context, _) {
        final o2 = game.o2Manager.currentO2;
        final pct = game.o2Manager.o2Percentage;
        final color = o2Color(pct);
        final isCritical = pct < O2Thresholds.criticalPercent;
        final scale = isCritical ? pulseScale.value : 1.0;

        return Transform.scale(
          scale: scale,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$o2',
                style: AppTextStyles.hud.copyWith(color: color),
              ),
              const SizedBox(height: 4),
              Container(
                height: 2,
                width: 64,
                color: color,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PauseButton extends StatelessWidget {
  const _PauseButton({required this.game});

  final TheOxygenGrid game;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        game.pauseGame();
      },
      child: Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        child: Icon(
          Icons.pause_rounded,
          color: AppColors.textSecondary,
          size: 28,
        ),
      ),
    );
  }
}
