import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import 'command_terminal.dart';

class BootSequence extends StatefulWidget {
  const BootSequence({super.key});

  @override
  State<BootSequence> createState() => _BootSequenceState();
}

class _BootSequenceState extends State<BootSequence>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final Animation<double> _logoOpacity;

  late final AnimationController _barController;
  late final Animation<double> _barProgress;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _logoOpacity = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutExpo,
    );

    _barController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _barProgress = CurvedAnimation(
      parent: _barController,
      curve: Curves.easeOutExpo,
    );

    _logoController.forward();

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _barController.forward();
    });

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, a, b) => const CommandTerminal(),
          transitionsBuilder: (_, animation, a2, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _barController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepVoid,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FadeTransition(
              opacity: _logoOpacity,
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cyanPlasma.withValues(alpha: 0.4),
                      blurRadius: 40,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 160,
                  height: 160,
                ),
              ),
            ),
            const SizedBox(height: 48),
            Text(
              'INITIALIZING LIFE SUPPORT...',
              style: AppTextStyles.secondary,
            ),
            const SizedBox(height: 16),
            AnimatedBuilder(
              animation: _barProgress,
              builder: (context, _) {
                return SizedBox(
                  width: 200,
                  height: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: _barProgress.value,
                      backgroundColor: AppColors.terminalDim,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.cyanPlasma,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
