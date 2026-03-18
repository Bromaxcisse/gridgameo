import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../models/save_data.dart';
import '../models/sector_factory.dart';

class MissionLogs extends StatefulWidget {
  const MissionLogs({super.key});

  @override
  State<MissionLogs> createState() => _MissionLogsState();
}

class _MissionLogsState extends State<MissionLogs> {
  int _highestUnlocked = 1;
  Map<int, int> _ratings = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final unlocked = await SaveData.getHighestUnlockedSector();
    final ratings = await SaveData.getAllEfficiencyRatings();
    if (!mounted) return;
    setState(() {
      _highestUnlocked = unlocked;
      _ratings = ratings;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepVoid,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            Text('MISSION LOGS', style: AppTextStyles.header),
            const SizedBox(height: 24),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.cyanPlasma,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: SectorFactory.totalSectors,
                      itemBuilder: (context, index) {
                        final sector = index + 1;
                        final rating = _ratings[sector];
                        final isUnlocked = sector <= _highestUnlocked;
                        final isCompleted = rating != null && rating > 0;

                        return _SectorRow(
                          sector: sector,
                          rating: rating,
                          isUnlocked: isUnlocked,
                          isCompleted: isCompleted,
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: _ReturnButton(
                onTap: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectorRow extends StatelessWidget {
  const _SectorRow({
    required this.sector,
    required this.rating,
    required this.isUnlocked,
    required this.isCompleted,
  });

  final int sector;
  final int? rating;
  final bool isUnlocked;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final textColor = isCompleted
        ? AppColors.neonIsotope
        : isUnlocked
            ? AppColors.textPrimary
            : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: isCompleted
              ? AppColors.neonIsotope.withValues(alpha: 0.3)
              : AppColors.terminalDim,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              'SECTOR ${sector.toString().padLeft(2, '0')}',
              style: AppTextStyles.secondary.copyWith(color: textColor),
            ),
          ),
          const Spacer(),
          if (isCompleted)
            Text(
              '$rating',
              style: AppTextStyles.body.copyWith(color: AppColors.neonIsotope),
            )
          else if (isUnlocked)
            Text(
              '---',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          else
            Icon(
              Icons.lock_outline,
              color: AppColors.textSecondary,
              size: 18,
            ),
        ],
      ),
    );
  }
}

class _ReturnButton extends StatefulWidget {
  const _ReturnButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_ReturnButton> createState() => _ReturnButtonState();
}

class _ReturnButtonState extends State<_ReturnButton> {
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
              ? AppColors.cyanPlasma.withValues(alpha: 0.2)
              : Colors.transparent,
          border: Border.all(color: AppColors.cyanPlasma, width: 2),
          borderRadius: BorderRadius.circular(2),
          boxShadow: [
            BoxShadow(
              color: AppColors.cyanPlasma.withValues(alpha: 0.4),
              blurRadius: 15,
            ),
          ],
        ),
        transform: _pressed
            ? Matrix4.diagonal3Values(0.97, 0.97, 1.0)
            : Matrix4.identity(),
        transformAlignment: Alignment.center,
        child: Text(
          'RETURN TO TERMINAL',
          style: AppTextStyles.button,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
