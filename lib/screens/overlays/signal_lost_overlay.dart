import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../the_oxygen_grid.dart';
import '../active_grid.dart';

class SignalLostOverlay extends StatelessWidget {
  const SignalLostOverlay({super.key, required this.game});

  final TheOxygenGrid game;

  @override
  Widget build(BuildContext context) {
    final sector = game.sectorData.sector;

    return Container(
      color: AppColors.panelBackground,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.deepVoid,
            border: Border.all(color: AppColors.coreBreach, width: 2),
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: AppColors.coreBreach.withValues(alpha: 0.3),
                blurRadius: 24,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'SIGNAL LOST',
                style: AppTextStyles.header.copyWith(
                  color: AppColors.coreBreach,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'O2 DEPLETED',
                style: AppTextStyles.secondary.copyWith(
                  color: AppColors.coreBreach.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 32),
              _OverlayButton(
                label: 'REDEPLOY',
                color: AppColors.coreBreach,
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => ActiveGrid(sector: sector),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _OverlayButton(
                label: 'RETURN TO TERMINAL',
                color: AppColors.cyanPlasma,
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverlayButton extends StatefulWidget {
  const _OverlayButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_OverlayButton> createState() => _OverlayButtonState();
}

class _OverlayButtonState extends State<_OverlayButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: _pressed
              ? widget.color.withValues(alpha: 0.2)
              : Colors.transparent,
          border: Border.all(color: widget.color, width: 2),
          borderRadius: BorderRadius.circular(2),
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: 0.4),
              blurRadius: 15,
            ),
          ],
        ),
        transform: _pressed
            ? Matrix4.diagonal3Values(0.97, 0.97, 1.0)
            : Matrix4.identity(),
        transformAlignment: Alignment.center,
        child: Text(
          widget.label,
          style: AppTextStyles.button.copyWith(color: widget.color),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
