import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_text_styles.dart';

class DataIntegrity extends StatelessWidget {
  const DataIntegrity({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepVoid,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            Text('DATA INTEGRITY', style: AppTextStyles.header),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'The Oxygen Grid operates entirely offline. '
                  'No user telemetry, personal data, or location metrics '
                  'are tracked, stored, or transmitted by this application.',
                  style: AppTextStyles.body,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: _AcknowledgeButton(
                onTap: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AcknowledgeButton extends StatefulWidget {
  const _AcknowledgeButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_AcknowledgeButton> createState() => _AcknowledgeButtonState();
}

class _AcknowledgeButtonState extends State<_AcknowledgeButton> {
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
          'ACKNOWLEDGE',
          style: AppTextStyles.button,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
