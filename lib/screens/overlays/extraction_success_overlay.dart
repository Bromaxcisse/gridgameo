import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../models/sector_factory.dart';
import '../../the_oxygen_grid.dart';
import '../active_grid.dart';

class ExtractionSuccessOverlay extends StatelessWidget {
  const ExtractionSuccessOverlay({super.key, required this.game});

  final TheOxygenGrid game;

  @override
  Widget build(BuildContext context) {
    final sector = game.sectorData.sector;
    final remainingO2 = game.o2Manager.currentO2;
    final rating = game.gameStateManager.lastEfficiencyRating ?? 0;
    final hasNextSector = sector < SectorFactory.totalSectors;

    return Container(
      color: AppColors.panelBackground,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.deepVoid,
            border: Border.all(color: AppColors.neonIsotope, width: 2),
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: AppColors.neonIsotope.withValues(alpha: 0.3),
                blurRadius: 24,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                hasNextSector
                    ? 'EXTRACTION SUCCESSFUL'
                    : 'ALL SECTORS CLEARED',
                style: AppTextStyles.header.copyWith(
                  color: AppColors.neonIsotope,
                ),
              ),
              if (!hasNextSector) ...[
                const SizedBox(height: 8),
                Text(
                  'MISSION COMPLETE',
                  style: AppTextStyles.secondary.copyWith(
                    color: AppColors.neonIsotope.withValues(alpha: 0.7),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              _StatRow(label: 'SECTOR', value: '$sector'),
              const SizedBox(height: 8),
              _StatRow(label: 'O2 REMAINING', value: '$remainingO2'),
              const SizedBox(height: 8),
              _StatRow(label: 'EFFICIENCY RATING', value: '$rating'),
              const SizedBox(height: 32),
              if (hasNextSector) ...[
                _OverlayButton(
                  label: 'NEXT SECTOR',
                  color: AppColors.neonIsotope,
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => ActiveGrid(sector: sector + 1),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
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

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.secondary),
        Text(
          value,
          style: AppTextStyles.body.copyWith(color: AppColors.neonIsotope),
        ),
      ],
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
