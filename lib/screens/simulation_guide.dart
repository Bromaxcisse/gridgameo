import 'dart:math';

import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_text_styles.dart';

class SimulationGuide extends StatefulWidget {
  const SimulationGuide({super.key});

  @override
  State<SimulationGuide> createState() => _SimulationGuideState();
}

class _SimulationGuideState extends State<SimulationGuide> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepVoid,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            Text(
              'SIMULATION GUIDE',
              style: AppTextStyles.header,
            ),
            const SizedBox(height: 32),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: const [
                  _SwipePanel(),
                  _O2CostPanel(),
                  _ObjectivePanel(),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _PageIndicator(currentPage: _currentPage, totalPages: 3),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: _AcknowledgeButton(
                onTap: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({
    required this.currentPage,
    required this.totalPages,
  });

  final int currentPage;
  final int totalPages;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        final isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.cyanPlasma : AppColors.terminalDim,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _SwipePanel extends StatelessWidget {
  const _SwipePanel();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomPaint(
            size: const Size(200, 200),
            painter: _SwipeArrowsPainter(),
          ),
          const SizedBox(height: 32),
          Text(
            'SWIPE TO MOVE',
            style: AppTextStyles.header.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 16),
          Text(
            'Swipe in any direction to move the Drone one tile. '
            'Plan your route carefully.',
            style: AppTextStyles.body,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _O2CostPanel extends StatelessWidget {
  const _O2CostPanel();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomPaint(
            size: const Size(200, 200),
            painter: _O2DiagramPainter(),
          ),
          const SizedBox(height: 32),
          Text(
            'OXYGEN IS LIFE',
            style: AppTextStyles.header.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 16),
          Text(
            'Every move costs 1 O2. Standing still drains 1 O2 per second. '
            'Efficiency is survival.',
            style: AppTextStyles.body,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ObjectivePanel extends StatelessWidget {
  const _ObjectivePanel();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomPaint(
            size: const Size(200, 200),
            painter: _ObjectivePainter(),
          ),
          const SizedBox(height: 32),
          Text(
            'REACH THE EXIT',
            style: AppTextStyles.header.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 16),
          Text(
            'Avoid red anomalies. Reach the green Extraction Point '
            'before your oxygen runs out.',
            style: AppTextStyles.body,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SwipeArrowsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = AppColors.cyanPlasma
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const arrowLen = 50.0;
    const headLen = 12.0;

    // Up
    _drawArrow(canvas, paint, center, center + const Offset(0, -arrowLen),
        headLen);
    // Down
    _drawArrow(canvas, paint, center, center + const Offset(0, arrowLen),
        headLen);
    // Left
    _drawArrow(canvas, paint, center, center + const Offset(-arrowLen, 0),
        headLen);
    // Right
    _drawArrow(canvas, paint, center, center + const Offset(arrowLen, 0),
        headLen);

    final dronePaint = Paint()..color = AppColors.cyanPlasma;
    canvas.drawRect(
      Rect.fromCenter(center: center, width: 20, height: 20),
      dronePaint,
    );
  }

  void _drawArrow(
      Canvas canvas, Paint paint, Offset from, Offset to, double headLen) {
    canvas.drawLine(from, to, paint);
    final angle = atan2(to.dy - from.dy, to.dx - from.dx);
    canvas.drawLine(
      to,
      to + Offset(cos(angle + 2.5) * headLen, sin(angle + 2.5) * headLen),
      paint,
    );
    canvas.drawLine(
      to,
      to + Offset(cos(angle - 2.5) * headLen, sin(angle - 2.5) * headLen),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _O2DiagramPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final bgPaint = Paint()
      ..color = AppColors.terminalDim
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawCircle(center, 60, bgPaint);

    final arcPaint = Paint()
      ..color = AppColors.cyanPlasma
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: 60),
      -pi / 2,
      pi * 1.4,
      false,
      arcPaint,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: 'O2',
        style: AppTextStyles.hud.copyWith(fontSize: 28),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );

    final movePaint = Paint()
      ..color = AppColors.amberAlert
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.05, size.height - 30, 12, 12),
      movePaint,
    );

    final restPaint = Paint()
      ..color = AppColors.coreBreach
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.55, size.height - 30, 12, 12),
      restPaint,
    );

    final moveLabel = TextPainter(
      text: TextSpan(text: '-1 MOVE', style: AppTextStyles.secondary),
      textDirection: TextDirection.ltr,
    )..layout();
    moveLabel.paint(canvas, Offset(size.width * 0.05 + 18, size.height - 32));

    final restLabel = TextPainter(
      text: TextSpan(text: '-1/SEC', style: AppTextStyles.secondary),
      textDirection: TextDirection.ltr,
    )..layout();
    restLabel.paint(canvas, Offset(size.width * 0.55 + 18, size.height - 32));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ObjectivePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final tileSize = size.width / 5;

    final gridPaint = Paint()
      ..color = AppColors.terminalDim
      ..strokeWidth = 1;

    for (int i = 0; i <= 5; i++) {
      final pos = i * tileSize;
      canvas.drawLine(Offset(pos, 0), Offset(pos, size.height), gridPaint);
      canvas.drawLine(Offset(0, pos), Offset(size.width, pos), gridPaint);
    }

    // Drone (cyan square)
    final dronePaint = Paint()..color = AppColors.cyanPlasma;
    final droneRect = Rect.fromLTWH(
      tileSize * 1 + tileSize * 0.1,
      tileSize * 3 + tileSize * 0.1,
      tileSize * 0.8,
      tileSize * 0.8,
    );
    canvas.drawRect(droneRect, dronePaint);

    // Extraction point (green diamond)
    final extractPaint = Paint()
      ..color = AppColors.neonIsotope
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final cx = tileSize * 3 + tileSize / 2;
    final cy = tileSize * 1 + tileSize / 2;
    final half = tileSize * 0.3;
    final path = Path()
      ..moveTo(cx, cy - half)
      ..lineTo(cx + half, cy)
      ..lineTo(cx, cy + half)
      ..lineTo(cx - half, cy)
      ..close();
    canvas.drawPath(path, extractPaint);

    // Sentry node (red square)
    final sentryPaint = Paint()..color = AppColors.coreBreach;
    canvas.drawRect(
      Rect.fromLTWH(
        tileSize * 2 + tileSize * 0.1,
        tileSize * 2 + tileSize * 0.1,
        tileSize * 0.8,
        tileSize * 0.8,
      ),
      sentryPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
