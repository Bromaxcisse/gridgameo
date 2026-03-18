import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../game/managers/audio_manager.dart';

class SystemConfig extends StatefulWidget {
  const SystemConfig({super.key});

  @override
  State<SystemConfig> createState() => _SystemConfigState();
}

class _SystemConfigState extends State<SystemConfig> {
  late bool _soundEnabled;

  @override
  void initState() {
    super.initState();
    _soundEnabled = AudioManager().enabled;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepVoid,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            Text('SYSTEM CONFIG', style: AppTextStyles.header),
            const SizedBox(height: 32),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    _ConfigToggle(
                      label: 'SOUND',
                      value: _soundEnabled,
                      onChanged: (value) {
                        setState(() => _soundEnabled = value);
                        AudioManager().enabled = value;
                      },
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: _BackButton(
                onTap: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfigToggle extends StatelessWidget {
  const _ConfigToggle({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.cyanPlasma.withValues(alpha: 0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.button),
          GestureDetector(
            onTap: () => onChanged(!value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56,
              height: 28,
              decoration: BoxDecoration(
                color: value
                    ? AppColors.cyanPlasma.withValues(alpha: 0.2)
                    : AppColors.terminalDim,
                border: Border.all(
                  color: value ? AppColors.cyanPlasma : AppColors.textSecondary,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment:
                    value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: value
                        ? AppColors.cyanPlasma
                        : AppColors.textSecondary,
                    shape: BoxShape.circle,
                    boxShadow: value
                        ? [
                            BoxShadow(
                              color:
                                  AppColors.cyanPlasma.withValues(alpha: 0.6),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatefulWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_BackButton> createState() => _BackButtonState();
}

class _BackButtonState extends State<_BackButton> {
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
          'RETURN',
          style: AppTextStyles.button,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
