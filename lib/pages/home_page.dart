import 'package:flutter/material.dart';

import '../theme.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/ring.dart';

class Home extends StatefulWidget {
  final void Function(int) go;
  const Home({super.key, required this.go});
  @override
  State<Home> createState() => _HomeS();
}

class _HomeS extends State<Home> {
  int sel = 6;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: st,
    builder: (_, __) {
      final now = DateTime.now(),
          week = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
      final q = st.made(week[sel]);
      final worst = st.machines.reduce((x, y) => x.left < y.left ? x : y);
      final health =
          st.machines.fold(0.0, (s, m) => s + m.health) / st.machines.length;
      final cover = st.demand == 0 ? 1.0 : cl(st.stock / st.demand);
      final tp = cl(st.today / st.target);
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Row(
            children: [
              const Logo(),
              const Spacer(),
              Stack(
                children: [
                  const Icon(Icons.notifications_rounded, size: 28),
                  if (st.machines.any((m) => m.color == org))
                    const Positioned(
                      right: 0,
                      top: 0,
                      child: CircleAvatar(radius: 5, backgroundColor: org),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          tx('Haloo...', 15, c: Colors.white54, al: TextAlign.center),
          const SizedBox(height: 4),
          tx(
            'Bagaimana Produksi\nHari Ini?',
            26,
            w: FontWeight.w600,
            al: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              for (var k = 0; k < 7; k++)
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => sel = k),
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: sel == k ? yel : card,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              tx(
                                dn[week[k].weekday - 1],
                                11,
                                c: sel == k ? bg : Colors.white54,
                              ),
                              tx(
                                '${week[k].day}',
                                16,
                                c: sel == k ? bg : Colors.white,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Icon(
                          st.made(week[k]) >= st.target
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          size: 22,
                          color: st.made(week[k]) >= st.target
                              ? mint
                              : Colors.white24,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Box(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                tx(
                  same(week[sel], now)
                      ? 'Produksi hari ini'
                      : 'Produksi ${dn[week[sel].weekday - 1]}, ${fd(week[sel])}',
                  14,
                  c: Colors.white60,
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    tx('$q', 34, w: FontWeight.w600),
                    const SizedBox(width: 6),
                    tx('unit / target ${st.target}', 14, c: Colors.white54),
                  ],
                ),
                const SizedBox(height: 10),
                TweenAnimationBuilder<double>(
                  tween: Tween(end: cl(q / st.target)),
                  duration: const Duration(milliseconds: 600),
                  builder: (_, v, __) => ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: v,
                      minHeight: 10,
                      color: yel,
                      backgroundColor: a(Colors.white, .08),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Box(
            Column(
              children: [
                Ring(
                  [tp, cover, health],
                  [mint, yel, lil],
                  size: 210,
                  child: tx('${(tp * 100).round()}%', 30, w: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    for (final e in [
                      ['${(tp * 100).round()}%', 'Target', mint],
                      ['${(cover * 100).round()}%', 'Stok/Pesanan', yel],
                      ['${(health * 100).round()}%', 'Kesehatan alat', lil],
                    ])
                      Column(
                        children: [
                          tx(e[0] as String, 20),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 4,
                                backgroundColor: e[2] as Color,
                              ),
                              const SizedBox(width: 5),
                              tx(e[1] as String, 12, c: Colors.white60),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Box(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      tx('Stok siap jual', 13, c: Colors.white60),
                      const SizedBox(height: 6),
                      tx('${st.stock}', 28, w: FontWeight.w600),
                    ],
                  ),
                  onTap: () => widget.go(1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Box(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      tx('Total pesanan', 13, c: Colors.white60),
                      const SizedBox(height: 6),
                      tx('${st.demand}', 28, w: FontWeight.w600),
                    ],
                  ),
                  onTap: () => widget.go(2),
                ),
              ),
            ],
          ),
          Box(
            Row(
              children: [
                Icon(Icons.build_circle_rounded, color: worst.color, size: 34),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      tx(worst.name, 16),
                      tx(
                        worst.left <= 0
                            ? 'Repair terlambat ${-worst.repairDays} hari'
                            : 'Repair berikutnya ±${worst.repairDays} hari lagi',
                        13,
                        c: worst.color,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () => widget.go(3),
          ),
        ],
      );
    },
  );
}
