import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// A fun animated car loading widget to replace the plain CircularProgressIndicator.
class CarLoadingWidget extends StatefulWidget {
  final String message;
  const CarLoadingWidget({this.message = 'Loading…', super.key});

  @override
  State<CarLoadingWidget> createState() => _CarLoadingWidgetState();
}

class _CarLoadingWidgetState extends State<CarLoadingWidget>
    with TickerProviderStateMixin {
  late final AnimationController _driveController;
  late final AnimationController _bounceController;
  late final AnimationController _dotController;

  late final Animation<double> _carPosition;
  late final Animation<double> _carBounce;
  late final Animation<double> _dotOpacity;

  @override
  void initState() {
    super.initState();

    // Car drives left → right and repeats
    _driveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    _carPosition = Tween<double>(begin: -0.6, end: 0.6).animate(
      CurvedAnimation(parent: _driveController, curve: Curves.easeInOut),
    );

    // Subtle vertical bounce for the car
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..repeat(reverse: true);

    _carBounce = Tween<double>(begin: 0.0, end: -4.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    // Blinking dots for "Loading…"
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _dotOpacity = Tween<double>(begin: 0.3, end: 1.0).animate(_dotController);
  }

  @override
  void dispose() {
    _driveController.dispose();
    _bounceController.dispose();
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Road + Car ──────────────────────────────────────────
          SizedBox(
            width: 220,
            height: 70,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Road track
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                // Dashed center line
                Positioned(
                  bottom: 12,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      6,
                      (_) => Container(
                        width: 14,
                        height: 2,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
                // Animated car
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _driveController,
                    _bounceController,
                  ]),
                  builder: (ctx, _) {
                    return Positioned(
                      bottom: 14 + _carBounce.value,
                      left: (220 / 2) + (_carPosition.value * 90),
                      child: _buildCar(),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ── Loading text with animated dots ─────────────────────
          AnimatedBuilder(
            animation: _dotOpacity,
            builder: (ctx, _) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.message,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                  Opacity(
                    opacity: _dotOpacity.value,
                    child: Text(
                      '●●●',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 8,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCar() {
    return SizedBox(
      width: 48,
      height: 28,
      child: CustomPaint(painter: _CarPainter()),
    );
  }
}

/// Custom car painter — draws a side-view car shape
class _CarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final darkPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    final windowPaint = Paint()
      ..color = Colors.lightBlue.shade100
      ..style = PaintingStyle.fill;

    final wheelPaint = Paint()
      ..color = const Color(0xFF333333)
      ..style = PaintingStyle.fill;

    final hubPaint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // ── Car body ────────────────────────────────────────────────
    final bodyPath = Path()
      ..moveTo(w * 0.05, h * 0.65) // bottom-left
      ..lineTo(w * 0.05, h * 0.45) // left side
      ..lineTo(w * 0.20, h * 0.20) // windscreen start
      ..lineTo(w * 0.55, h * 0.10) // roof left
      ..lineTo(w * 0.78, h * 0.10) // roof right
      ..lineTo(w * 0.96, h * 0.38) // rear windscreen
      ..lineTo(w * 0.96, h * 0.65) // bottom-right
      ..close();
    canvas.drawPath(bodyPath, bodyPaint);

    // ── Hood (darker) ────────────────────────────────────────────
    final hoodPath = Path()
      ..moveTo(w * 0.05, h * 0.45)
      ..lineTo(w * 0.05, h * 0.55)
      ..lineTo(w * 0.23, h * 0.40)
      ..lineTo(w * 0.20, h * 0.20)
      ..close();
    canvas.drawPath(hoodPath, darkPaint);

    // ── Windscreen ───────────────────────────────────────────────
    final windPath = Path()
      ..moveTo(w * 0.22, h * 0.22)
      ..lineTo(w * 0.25, h * 0.43)
      ..lineTo(w * 0.52, h * 0.43)
      ..lineTo(w * 0.55, h * 0.13)
      ..close();
    canvas.drawPath(windPath, windowPaint);

    // ── Rear window ──────────────────────────────────────────────
    final rearPath = Path()
      ..moveTo(w * 0.57, h * 0.12)
      ..lineTo(w * 0.76, h * 0.12)
      ..lineTo(w * 0.94, h * 0.38)
      ..lineTo(w * 0.56, h * 0.43)
      ..close();
    canvas.drawPath(rearPath, windowPaint);

    // ── Wheels ───────────────────────────────────────────────────
    canvas.drawCircle(Offset(w * 0.22, h * 0.72), h * 0.18, wheelPaint);
    canvas.drawCircle(Offset(w * 0.78, h * 0.72), h * 0.18, wheelPaint);

    // ── Wheel hubs ───────────────────────────────────────────────
    canvas.drawCircle(Offset(w * 0.22, h * 0.72), h * 0.08, hubPaint);
    canvas.drawCircle(Offset(w * 0.78, h * 0.72), h * 0.08, hubPaint);

    // ── Headlight ────────────────────────────────────────────────
    final headlightPaint = Paint()
      ..color = Colors.yellow.shade200
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromLTRBR(
        w * 0.04,
        h * 0.40,
        w * 0.10,
        h * 0.50,
        const Radius.circular(2),
      ),
      headlightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
