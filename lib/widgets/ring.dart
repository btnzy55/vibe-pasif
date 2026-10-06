import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';

class Ring extends StatelessWidget {
  final List<double> v; final List<Color> c; final double size; final Widget? child;
  const Ring(this.v, this.c, {super.key, this.size = 200, this.child});
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
      key: ValueKey(v.map((e) => e.toStringAsFixed(2)).join()),
      tween: Tween(begin: 0, end: 1), duration: const Duration(milliseconds: 900), curve: Curves.easeOutCubic,
      builder: (_, t, __) => CustomPaint(size: Size.square(size), painter: RP(v, c, t),
          child: SizedBox.square(dimension: size, child: Center(child: child))));
}

class RP extends CustomPainter {
  final List<double> v; final List<Color> c; final double t;
  RP(this.v, this.c, this.t);
  @override
  void paint(Canvas cv, Size s) {
    final w = s.width / 14;
    for (var i = 0; i < v.length; i++) {
      final r = s.width / 2 - w / 2 - i * w * 1.5;
      final rect = Rect.fromCircle(center: s.center(Offset.zero), radius: r);
      final p = Paint()..style = PaintingStyle.stroke..strokeWidth = w..strokeCap = StrokeCap.round;
      cv.drawCircle(rect.center, r, p..color = a(Colors.white, .06));
      cv.drawArc(rect, -math.pi / 2, 2 * math.pi * v[i] * t, false, p..color = c[i]);
    }
  }
  @override
  bool shouldRepaint(RP o) => o.t != t || o.v != v;
}
