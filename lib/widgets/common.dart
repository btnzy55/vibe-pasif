import 'package:flutter/material.dart';
import '../theme.dart';

class Logo extends StatelessWidget {
  const Logo({super.key});
  @override
  Widget build(BuildContext c) => Container(
      width: 44, height: 44,
      decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [mint, yel])),
      child: Center(child: Container(width: 18, height: 18, decoration: const BoxDecoration(shape: BoxShape.circle, color: bg)))); // ganti dengan logo asli
}

class Box extends StatelessWidget {
  final Widget child; final VoidCallback? onTap;
  const Box(this.child, {super.key, this.onTap});
  @override
  Widget build(BuildContext c) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(color: card, borderRadius: BorderRadius.circular(22),
          child: InkWell(borderRadius: BorderRadius.circular(22), onTap: onTap, child: Padding(padding: const EdgeInsets.all(16), child: SizedBox(width: double.infinity, child: child)))));
}


class Seg extends StatelessWidget {
  final List<String> l; final int sel; final ValueChanged<int> on;
  const Seg(this.l, this.sel, this.on, {super.key});
  @override
  Widget build(BuildContext c) => Container(
      padding: const EdgeInsets.all(4), margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(30)),
      child: Row(children: [
        for (var i = 0; i < l.length; i++)
          Expanded(child: GestureDetector(onTap: () => on(i),
              child: AnimatedContainer(duration: const Duration(milliseconds: 250), padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(color: sel == i ? yel : Colors.transparent, borderRadius: BorderRadius.circular(26)),
                  child: tx(l[i], 14, c: sel == i ? bg : Colors.white60, al: TextAlign.center))))
      ]));
}
