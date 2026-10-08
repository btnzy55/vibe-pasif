import 'package:flutter/material.dart';

import '../theme.dart';
import '../models/machine.dart';
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
  int sel = 6; // Indeks hari ini (6 dari 7 hari)

  void _showNotificationSheet(BuildContext context) {
    final alerts = st.criticalAlerts;
    showModalBottomSheet(
      context: context,
      backgroundColor: card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                const Icon(Icons.notifications_active_rounded, color: mint, size: 24),
                const SizedBox(width: 10),
                tx('Pusat Notifikasi & Alarm', 18, w: FontWeight.w700),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: a(mint, 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: tx('${alerts.length} aktif', 12, c: mint, w: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (alerts.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, color: mint, size: 48),
                      const SizedBox(height: 10),
                      tx('Semua sistem beroperasi normal', 14, c: Colors.white70),
                      tx('Tidak ada peringatan kritis saat ini.', 12, c: Colors.white38),
                    ],
                  ),
                ),
              )
            else
              for (final alert in alerts)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cardSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: alert.contains('melewati') || alert.contains('Kekurangan')
                            ? a(org, 0.3)
                            : a(mint, 0.2),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          alert.contains('melewati')
                              ? Icons.warning_amber_rounded
                              : alert.contains('Kekurangan')
                                  ? Icons.inventory_2_outlined
                                  : Icons.info_outline_rounded,
                          color: alert.contains('melewati') || alert.contains('Kekurangan')
                              ? org
                              : mint,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: tx(alert, 13, c: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: btn('Tutup', () => Navigator.pop(ctx), tonal: true),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: st,
        builder: (context, _) {
          final now = DateTime.now();
          final week = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
          final selectedDate = week[sel];
          final isTodaySelected = same(selectedDate, now);

          final q = st.made(selectedDate);
          final rejQ = st.rejected(selectedDate);
          final yieldQ = st.yieldRate(selectedDate);

          final Machine? worst = st.worstMachine;
          final health = st.avgHealth;
          final cover = st.demand == 0 ? 1.0 : cl(st.stock / st.demand);
          final tp = cl(q / st.target);
          final hasCritical = st.criticalAlerts.isNotEmpty;

          return ListView(
            // Memberikan padding bawah yang cukup luas agar tidak tertutup floating bottom bar
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 105),
            physics: const BouncingScrollPhysics(),
            children: [
              // Header Bar
              Row(
                children: [
                  const Logo(),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _showNotificationSheet(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: a(mint, 0.15)),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(Icons.notifications_outlined, size: 22, color: Colors.white70),
                          if (hasCritical)
                            Positioned(
                              right: 10,
                              top: 10,
                              child: PulseBadge(color: st.machines.any((m) => m.color == org) ? org : yel),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Greeting
              tx('Halo, Tim Produksi', 14, c: Colors.white54, al: TextAlign.center),
              const SizedBox(height: 4),
              tx(
                'Bagaimana Produksi\nHari Ini?',
                25,
                w: FontWeight.w700,
                al: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // 7-Day Week Selector
              Row(
                children: [
                  for (var k = 0; k < 7; k++) ...[
                    if (k > 0) const SizedBox(width: 6),
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => setState(() => sel = k),
                        child: Column(
                          children: [
                            tx(
                              dn[week[k].weekday - 1],
                              11,
                              c: sel == k ? yel : Colors.white54,
                              w: sel == k ? FontWeight.w700 : FontWeight.w500,
                            ),
                            const SizedBox(height: 6),
                            AspectRatio(
                              aspectRatio: 1,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOutCubic,
                                decoration: BoxDecoration(
                                  color: sel == k ? yel : card,
                                  borderRadius: BorderRadius.circular(sel == k ? 16 : 12),
                                  border: Border.all(
                                    color: sel == k ? yel : a(mint, 0.1),
                                    width: 1.2,
                                  ),
                                  boxShadow: sel == k
                                      ? [
                                          BoxShadow(
                                            color: yel.withAlpha(50),
                                            blurRadius: 10,
                                            offset: const Offset(0, 3),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Center(
                                  child: tx(
                                    '${week[k].day}',
                                    15,
                                    c: sel == k ? bg : Colors.white,
                                    w: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 7),
                            Icon(
                              st.made(week[k]) >= st.target
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              size: 18,
                              color: st.made(week[k]) >= st.target ? mint : Colors.white24,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 18),

              // Production Day Summary Card
              Box(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        tx(
                          isTodaySelected
                              ? 'Produksi Hari Ini'
                              : 'Produksi ${dn[selectedDate.weekday - 1]}, ${fd(selectedDate)}',
                          13,
                          c: Colors.white70,
                          w: FontWeight.w600,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: a(mint, 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: tx(
                            'QC Yield ${(yieldQ * 100).round()}%',
                            11,
                            c: mint,
                            w: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        AnimatedCount(
                          value: q,
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        tx('unit', 16, c: mint, w: FontWeight.w600),
                        const SizedBox(width: 6),
                        tx('/ target ${numFmt(st.target)} unit', 13, c: Colors.white54),
                        const Spacer(),
                        if (rejQ > 0)
                          tx('$rejQ reject', 12, c: org, w: FontWeight.w600),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _SmoothProdBar(value: tp),
                  ],
                ),
                onTap: () => widget.go(1),
              ),

              // Concentric Health & KPI Rings
              Box(
                Column(
                  children: [
                    Ring(
                      [tp, cover, health],
                      [mint, yel, lil],
                      size: 200,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          tx('${(tp * 100).round()}%', 32, w: FontWeight.w800),
                          tx('Capaian Target', 11, c: Colors.white54),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                      decoration: BoxDecoration(
                        color: cardSurface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _MetricLegendItem(
                            value: '${(tp * 100).round()}%',
                            label: 'Target',
                            color: mint,
                          ),
                          _MetricLegendItem(
                            value: '${(cover * 100).round()}%',
                            label: 'Stok/Order',
                            color: yel,
                          ),
                          _MetricLegendItem(
                            value: '${(health * 100).round()}%',
                            label: 'Kesehatan Alat',
                            color: lil,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Stock & Orders Quick Grid
              Row(
                children: [
                  Expanded(
                    child: Box(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              tx('Stok siap jual', 13, c: Colors.white60),
                              const Icon(Icons.inventory_2_rounded, size: 16, color: mint),
                            ],
                          ),
                          const SizedBox(height: 8),
                          AnimatedCount(
                            value: st.stock,
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                          ),
                          const SizedBox(height: 4),
                          tx('Unit di gudang', 11, c: Colors.white38),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              tx('Total pesanan', 13, c: Colors.white60),
                              const Icon(Icons.people_alt_rounded, size: 16, color: yel),
                            ],
                          ),
                          const SizedBox(height: 8),
                          AnimatedCount(
                            value: st.demand,
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                          ),
                          const SizedBox(height: 4),
                          tx('${st.clients.length} klien aktif', 11, c: Colors.white38),
                        ],
                      ),
                      onTap: () => widget.go(2),
                    ),
                  ),
                ],
              ),

              // Machine Health Card
              if (worst != null)
                Box(
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: a(worst.color, 0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: a(worst.color, 0.3)),
                        ),
                        child: Icon(
                          Icons.precision_manufacturing_rounded,
                          color: worst.color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(child: tx(worst.name, 15, w: FontWeight.w600)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: a(worst.color, 0.14),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: tx('${(worst.health * 100).round()}%', 11, c: worst.color, w: FontWeight.w700),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            tx(
                              worst.left <= 0
                                  ? (worst.overdueDays > 0 ? 'Terlambat repair ${worst.overdueDays} hari' : 'Jadwal servis hari ini')
                                  : 'Servis berikutnya ±${worst.remainingDays} hari lagi',
                              12,
                              c: worst.color,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right_rounded, color: Colors.white38),
                    ],
                  ),
                  onTap: () => widget.go(3),
                ),
            ],
          );
        },
      );
}

class _MetricLegendItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _MetricLegendItem({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Column(
        children: [
          tx(value, 18, w: FontWeight.w700),
          const SizedBox(height: 3),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
              ),
              const SizedBox(width: 5),
              tx(label, 11, c: Colors.white60),
            ],
          ),
        ],
      );
}

class _SmoothProdBar extends StatelessWidget {
  final double value;

  const _SmoothProdBar({required this.value});

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: cl(value)),
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeOutCubic,
        builder: (context, val, _) {
          final barColor = val < 0.5
              ? Color.lerp(org, yel, val * 2)!
              : Color.lerp(yel, mint, (val - 0.5) * 2)!;

          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                color: a(Colors.white, 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: val,
                  child: Container(
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: barColor.withAlpha(90),
                          blurRadius: 6,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
}

