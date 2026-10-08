import 'package:flutter/material.dart';

import '../theme.dart';
import '../models/machine.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/ring.dart';

class MachPage extends StatelessWidget {
  const MachPage({super.key});

  void _showAddMachineSheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          22,
          20,
          22,
          24 + MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.precision_manufacturing_rounded, color: mint, size: 22),
                const SizedBox(width: 10),
                tx('Tambah Mesin Produksi Baru', 18, w: FontWeight.w700),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              decoration: dec('Nama / Kode Mesin (contoh: Mesin AOI 01)', prefix: const Icon(Icons.settings_suggest_rounded, color: Colors.white54, size: 18)),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: btn('Daftarkan Mesin', () {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) {
                  snack(context, 'Masukkan nama atau kode mesin terlebih dahulu', isError: true);
                  return;
                }
                st.addMachine(name);
                Navigator.pop(ctx);
                snack(context, '$name berhasil ditambahkan ke lini produksi!');
              }, icon: Icons.add_circle_outline_rounded),
            ),
          ],
        ),
      ),
    );
  }

  void _showRecordRepairSheet(BuildContext context, int index, Machine m) {
    final noteCtrl = TextEditingController(text: 'Servis berkala & kalibrasi');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          22,
          20,
          22,
          24 + MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.build_circle_rounded, color: mint, size: 22),
                const SizedBox(width: 10),
                tx('Catat Servis / Repair', 18, w: FontWeight.w700),
              ],
            ),
            const SizedBox(height: 8),
            tx(
              'Reset jam kerja sejak servis terakhir untuk "${m.name}". Jam operasional total (${numFmt(m.total.round())} jam) tetap dipertahankan.',
              13,
              c: Colors.white60,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: noteCtrl,
              decoration: dec('Catatan Teknisi / Tindakan Servis', prefix: const Icon(Icons.assignment_turned_in_rounded, color: Colors.white54, size: 18)),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: btn('Konfirmasi & Reset Siklus Servis', () {
                st.recordMachineMaintenance(index, note: noteCtrl.text.trim());
                Navigator.pop(ctx);
                snack(context, 'Servis ${m.name} dicatat! Siklus servis direset ke 0 jam.');
              }, icon: Icons.check_circle_rounded),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: st,
        builder: (context, _) => ListView(
          // Bottom padding 110 memberi ruang leluasa di atas bottom bar
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
          physics: const BouncingScrollPhysics(),
          children: [
            tx(
              'Kesehatan Alat Produksi',
              22,
              w: FontWeight.w700,
              al: TextAlign.center,
            ),
            const SizedBox(height: 4),
            tx(
              'Monitoring siklus servis 1.440 jam & batas aus 8.760 jam kerja',
              12,
              c: Colors.white54,
              al: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Factory Fleet Overview Box
            Box(
              Row(
                children: [
                  Ring(
                    [st.avgHealth],
                    [st.avgHealth >= 0.8 ? mint : (st.avgHealth >= 0.5 ? yel : org)],
                    size: 96,
                    child: tx('${(st.avgHealth * 100).round()}%', 18, w: FontWeight.w700),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        tx('Skor Rata-rata Pabrik', 13, c: Colors.white60),
                        const SizedBox(height: 4),
                        tx('${st.machines.length} Mesin Beroperasi', 16, w: FontWeight.w700),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: a(mint, 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: tx(
                            st.machines.any((m) => m.color == org)
                                ? '⚠️ Butuh tindakan servis segera'
                                : '✓ Kondisi keseluruhan terkontrol',
                            11,
                            c: st.machines.any((m) => m.color == org) ? org : mint,
                            w: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                tx('Daftar Unit Mesin', 15, w: FontWeight.w600),
                TextButton.icon(
                  onPressed: () => _showAddMachineSheet(context),
                  icon: const Icon(Icons.add, size: 16, color: mint),
                  label: tx('Mesin Baru', 13, c: mint, w: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),

            for (var i = 0; i < st.machines.length; i++) mCard(context, i, st.machines[i]),
          ],
        ),
      );

  Widget row(String l, String v, [Color c = Colors.white, IconData? icon]) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: Colors.white38),
              const SizedBox(width: 6),
            ],
            Expanded(child: tx(l, 13, c: Colors.white54)),
            tx(v, 13, c: c, w: FontWeight.w600),
          ],
        ),
      );

  Widget mCard(BuildContext context, int index, Machine m) => Box(
        Column(
          children: [
            Row(
              children: [
                Ring(
                  [m.repairPct, m.lifePct],
                  [m.color, lil],
                  size: 96,
                  child: tx('${(m.health * 100).round()}%', 18, w: FontWeight.w700),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: tx(m.name, 16, w: FontWeight.w700)),
                          PulseBadge(color: m.color),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: a(m.color, .15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: a(m.color, 0.3)),
                        ),
                        child: tx(m.status, 11, c: m.color, w: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardSurface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  row('Jam kerja sejak servis', '${numFmt(m.since.round())} / ${numFmt(1440)} jam', Colors.white, Icons.timelapse_rounded),
                  row(
                    'Jadwal servis berkala',
                    m.left < 0
                        ? (m.overdueDays > 0 ? 'Terlambat ${m.overdueDays} hari' : 'Lewat batas')
                        : m.left == 0
                            ? 'Hari ini'
                            : '±${m.remainingDays} hari lagi',
                    m.left <= 0 ? org : (m.remainingDays <= 14 ? yel : Colors.white),
                    Icons.calendar_month_rounded,
                  ),
                  row(
                    'Akumulasi usia mesin',
                    '${numFmt(m.total.round())} / ${numFmt(8760)} jam (${(m.lifePct * 100).round()}%)',
                    m.lifePct >= 0.85 ? org : Colors.white,
                    Icons.history_rounded,
                  ),
                  row('Servis terakhir dicatat', fd(m.last), Colors.white70, Icons.check_circle_outline_rounded),
                ],
              ),
            ),

            if (m.maintenanceNotes.isNotEmpty) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    const Icon(Icons.sticky_note_2_outlined, size: 14, color: Colors.white38),
                    const SizedBox(width: 5),
                    Expanded(
                      child: tx('Catatan: ${m.maintenanceNotes.first}', 11, c: Colors.white54, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: btn('+12 Jam Kerja', () {
                    st.addMachineHours(index, 12);
                    snack(context, '+12 jam kerja ditambahkan ke ${m.name}');
                  }, tonal: true, icon: Icons.schedule_rounded),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: btn('Catat Servis', () {
                    _showRecordRepairSheet(context, index, m);
                  }, icon: Icons.build_rounded),
                ),
              ],
            ),
          ],
        ),
      );
}

