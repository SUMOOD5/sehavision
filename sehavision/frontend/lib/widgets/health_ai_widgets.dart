import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utils/app_theme.dart';

class HealthAIIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const HealthAIIcon({
    super.key,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: HealthAIPainter(color ?? AppTheme.primaryColor),
    );
  }
}

class HealthAIPainter extends CustomPainter {
  final Color color;

  HealthAIPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;

    // Draw medical cross
    final crossSize = radius * 0.6;
    canvas.drawRect(
      Rect.fromCenter(
        center: center,
        width: crossSize * 0.2,
        height: crossSize,
      ),
      paint,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: center,
        width: crossSize,
        height: crossSize * 0.2,
      ),
      paint,
    );

    // Draw AI circuit pattern around the cross
    final circuitRadius = radius * 0.8;
    final circuitPoints = <Offset>[];

    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * (3.14159 / 180);
      final x = center.dx + circuitRadius * cos(angle);
      final y = center.dy + circuitRadius * sin(angle);
      circuitPoints.add(Offset(x, y));
    }

    // Draw circuit lines
    for (int i = 0; i < circuitPoints.length; i++) {
      final nextIndex = (i + 1) % circuitPoints.length;
      canvas.drawLine(circuitPoints[i], circuitPoints[nextIndex], strokePaint);
    }

    // Draw circuit nodes
    for (final point in circuitPoints) {
      canvas.drawCircle(point, 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GradientCard extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;

  const GradientCard({
    super.key,
    required this.child,
    this.colors,
    this.padding,
    this.margin,
    this.borderRadius,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors ??
              [
                AppTheme.cardColor,
                AppTheme.cardColor.withOpacity(0.8),
              ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.textTertiaryColor.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: boxShadow ?? AppTheme.cardShadow,
      ),
      child: child,
    );
  }
}

class AnimatedHealthIndicator extends StatefulWidget {
  final double value;
  final String label;
  final Color color;
  final IconData icon;

  const AnimatedHealthIndicator({
    super.key,
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  State<AnimatedHealthIndicator> createState() =>
      _AnimatedHealthIndicatorState();
}

class _AnimatedHealthIndicatorState extends State<AnimatedHealthIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    widget.color.withOpacity(0.2),
                    widget.color.withOpacity(0.1),
                  ],
                ),
                border: Border.all(
                  color: widget.color.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Stack(
                children: [
                  // Background circle
                  Center(
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        value: _animation.value,
                        strokeWidth: 6,
                        backgroundColor: widget.color.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(widget.color),
                      ),
                    ),
                  ),
                  // Icon
                  Center(
                    child: Icon(
                      widget.icon,
                      color: widget.color,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.label,
              style: AppTheme.caption.copyWith(
                color: widget.color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }
}

class PulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double scale;

  const PulseAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1000),
    this.scale = 1.1,
  });

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 1.0, end: widget.scale).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: widget.child,
        );
      },
    );
  }
}

class HealthAIBadge extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;

  const HealthAIBadge({
    super.key,
    required this.text,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppTheme.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Helper functions for trigonometry
double cos(double radians) {
  return math.cos(radians);
}

double sin(double radians) {
  return math.sin(radians);
}
