import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';

class Ring extends StatelessWidget {
  final List<double> v;
  final List<Color> c;
  final double size;
  final Widget? child;

  const Ring(this.v, this.c, {super.key, this.size = 200, this.child});

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        key: ValueKey(v.map((e) => e.toStringAsFixed(2)).join()),
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 850),
        curve: Curves.easeOutCubic,
        builder: (context, t, _) => CustomPaint(
          size: Size.square(size),
          painter: RP(v, c, t),
          child: SizedBox.square(
            dimension: size,
            child: Center(child: child),
          ),
        ),
      );
}

class RP extends CustomPainter {
  final List<double> v;
  final List<Color> c;
  final double t;

  RP(this.v, this.c, this.t);

  @override
  void paint(Canvas cv, Size s) {
    final w = (s.width / 14).clamp(6.0, 14.0);
    final center = s.center(Offset.zero);

    for (var i = 0; i < v.length; i++) {
      final r = s.width / 2 - w / 2 - i * (w * 1.45);
      if (r <= w) break;

      final rect = Rect.fromCircle(center: center, radius: r);

      // Background track
      final trackPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w
        ..color = a(Colors.white, 0.07);
      cv.drawCircle(center, r, trackPaint);

      // Active Arc
      final val = cl(v[i]);
      final sweepAngle = 2 * math.pi * val * t;

      if (sweepAngle > 0.01) {
        final arcPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = w
          ..strokeCap = StrokeCap.round
          ..color = c[i % c.length];

        cv.drawArc(rect, -math.pi / 2, sweepAngle, false, arcPaint);
      }
    }
  }

  @override
  bool shouldRepaint(RP oldDelegate) =>
      oldDelegate.t != t || oldDelegate.v != v || oldDelegate.c != c;
}

