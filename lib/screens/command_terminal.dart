import 'dart:math';

import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../models/save_data.dart';
import '../models/sector_factory.dart';
import 'active_grid.dart';
import 'data_integrity.dart';
import 'mission_logs.dart';
import 'simulation_guide.dart';
import 'system_config.dart';

class CommandTerminal extends StatelessWidget {
  const CommandTerminal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepVoid,
      body: Stack(
        children: [
          const _NeonGridBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 64),
                    Text(
                      'THE OXYGEN GRID',
                      style: AppTextStyles.mainTitle,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    _TerminalButton(
                      label: 'DEPLOY DRONE',
                      onTap: () => _deployDrone(context),
                    ),
                    const SizedBox(height: 16),
                    _TerminalButton(
                      label: 'SIMULATION GUIDE',
                      onTap: () => _navigateTo(
                        context,
                        const SimulationGuide(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _TerminalButton(
                      label: 'MISSION LOGS',
                      onTap: () => _navigateTo(
                        context,
                        const MissionLogs(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _TerminalButton(
                      label: 'SYSTEM CONFIG',
                      onTap: () => _navigateTo(
                        context,
                        const SystemConfig(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _TerminalButton(
                      label: 'DATA INTEGRITY',
                      onTap: () => _navigateTo(
                        context,
                        const DataIntegrity(),
                      ),
                    ),
                    const SizedBox(height: 64),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deployDrone(BuildContext context) async {
    final unlocked = await SaveData.getHighestUnlockedSector();
    final sector = unlocked.clamp(1, SectorFactory.totalSectors);
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ActiveGrid(sector: sector)),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}

class _TerminalButton extends StatefulWidget {
  const _TerminalButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_TerminalButton> createState() => _TerminalButtonState();
}

class _TerminalButtonState extends State<_TerminalButton> {
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
          widget.label,
          style: AppTextStyles.button,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _NeonGridBackground extends StatefulWidget {
  const _NeonGridBackground();

  @override
  State<_NeonGridBackground> createState() => _NeonGridBackgroundState();
}

class _NeonGridBackgroundState extends State<_NeonGridBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: _GridPainter(offset: _controller.value),
        );
      },
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter({required this.offset});

  final double offset;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.terminalDim.withValues(alpha: 0.5)
      ..strokeWidth = 1;

    const spacing = 40.0;
    final scrollOffset = offset * spacing;

    for (double x = -spacing + (scrollOffset % spacing);
        x < size.width + spacing;
        x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = -spacing + (scrollOffset % spacing);
        y < size.height + spacing;
        y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.cyanPlasma.withValues(alpha: 0.05),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width / 2, size.height * 0.3),
          radius: min(size.width, size.height) * 0.6,
        ),
      );
    canvas.drawRect(Offset.zero & size, glowPaint);
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) => oldDelegate.offset != offset;
}
