import 'package:flutter/material.dart';

import '../theme.dart';
import '../models/machine.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/ring.dart';

class MachPage extends StatelessWidget {
  const MachPage({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: st,
    builder: (_, __) => ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        tx(
          'Kesehatan Alat Produksi',
          22,
          w: FontWeight.w600,
          al: TextAlign.center,
        ),
        const SizedBox(height: 8),
        tx(
          'Repair tiap 4 bulan × 12 jam kerja = 1.440 jam\nRisiko rusak setelah 2 tahun × 12 jam kerja = 8.760 jam',
          12,
          c: Colors.white54,
          al: TextAlign.center,
        ),
        const SizedBox(height: 16),
        for (final m in st.machines) mCard(context, m),
      ],
    ),
  );

  Widget row(String l, String v, [Color c = Colors.white]) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Expanded(child: tx(l, 13, c: Colors.white54)),
        tx(v, 13, c: c),
      ],
    ),
  );

  Widget mCard(BuildContext context, Machine m) => Box(
    Column(
      children: [
        Row(
          children: [
            Ring(
              [m.repairPct, m.lifePct],
              [m.color, lil],
              size: 96,
              child: tx('${(m.health * 100).round()}%', 18),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  tx(m.name, 17),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: a(m.color, .15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: tx(m.status, 12, c: m.color),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        row('Jam kerja sejak repair', '${m.since.round()} / 1440 jam'),
        row(
          'Repair berikutnya',
          m.left <= 0
              ? 'Terlambat ${-m.repairDays} hari'
              : '±${m.repairDays} hari lagi',
          m.left <= 0 ? org : Colors.white,
        ),
        row(
          'Estimasi risiko rusak',
          m.lifeDays <= 0
              ? 'Sudah melewati batas'
              : '±${m.lifeDays} hari (${(m.lifePct * 100).round()}% terpakai)',
          m.lifePct >= .85 ? org : Colors.white,
        ),
        row('Repair terakhir', fd(m.last)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: btn('+12 jam kerja', () {
                m.since += 12;
                m.total += 12;
                st.change();
              }, tonal: true),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: btn('Catat repair', () {
                m.since = 0;
                m.last = DateTime.now();
                st.change();
                snack(context, '${m.name}: repair dicatat');
              }),
            ),
          ],
        ),
      ],
    ),
  );
}
