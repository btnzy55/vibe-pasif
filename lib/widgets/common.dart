import 'package:flutter/material.dart';
import '../theme.dart';

class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                colors: [mint, yel],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: mint.withAlpha(50),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: mint,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              tx('ProdTrack', 17, w: FontWeight.w700),
              tx('SMART FACTORY', 9, c: mint, w: FontWeight.w600),
            ],
          ),
        ],
      );
}

class Box extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? borderColor;
  final EdgeInsetsGeometry padding;

  const Box(
    this.child, {
    super.key,
    this.onTap,
    this.borderColor,
    this.padding = const EdgeInsets.all(18),
  });

  @override
  State<Box> createState() => _BoxState();
}

class _BoxState extends State<Box> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final borderCol = widget.borderColor ?? cardBorder;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: AnimatedScale(
        scale: _pressed && widget.onTap != null ? 0.985 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: Container(
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderCol, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(60),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              splashColor: mint.withAlpha(25),
              highlightColor: mint.withAlpha(15),
              onHighlightChanged: (val) {
                if (widget.onTap != null && mounted) {
                  setState(() => _pressed = val);
                }
              },
              onTap: widget.onTap,
              child: Padding(
                padding: widget.padding,
                child: SizedBox(
                  width: double.infinity,
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Seg extends StatelessWidget {
  final List<String> l;
  final int sel;
  final ValueChanged<int> on;

  const Seg(this.l, this.sel, this.on, {super.key});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(5),
        margin: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: cardSurface,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: a(mint, 0.12)),
        ),
        child: Row(
          children: [
            for (var i = 0; i < l.length; i++)
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => on(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: sel == i ? yel : Colors.transparent,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: sel == i
                          ? [
                              BoxShadow(
                                color: yel.withAlpha(50),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: tx(
                      l[i],
                      14,
                      c: sel == i ? bg : Colors.white60,
                      w: sel == i ? FontWeight.w700 : FontWeight.w500,
                      al: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
}

class AnimatedCount extends StatelessWidget {
  final int value;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;

  const AnimatedCount({
    super.key,
    required this.value,
    this.fontSize = 28,
    this.fontWeight = FontWeight.w700,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: value.toDouble(), end: value.toDouble()),
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeOutCubic,
        builder: (context, val, _) => Text(
          numFmt(val.round()),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: color,
            letterSpacing: -0.5,
          ),
        ),
      );
}

class PulseBadge extends StatefulWidget {
  final Color color;
  const PulseBadge({super.key, required this.color});

  @override
  State<PulseBadge> createState() => _PulseBadgeState();
}

class _PulseBadgeState extends State<PulseBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _anim,
        builder: (context, _) => Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color,
            boxShadow: [
              BoxShadow(
                color: widget.color.withAlpha((_anim.value * 200).round()),
                blurRadius: 8 * _anim.value,
                spreadRadius: 2 * _anim.value,
              ),
            ],
          ),
        ),
      );
}

