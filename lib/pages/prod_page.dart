import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';
import '../models/log.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/ring.dart';

class ProdPage extends StatefulWidget {
  const ProdPage({super.key});

  @override
  State<ProdPage> createState() => _ProdS();
}

class _ProdS extends State<ProdPage> {
  int mode = 0; // 0 = Hari ini, 1 = Semua riwayat
  final g = TextEditingController();
  final r = TextEditingController();
  final noteCtrl = TextEditingController();

  void _addQuick(TextEditingController ctrl, int delta) {
    final current = int.tryParse(ctrl.text) ?? 0;
    final next = math.max(0, current + delta);
    ctrl.text = next.toString();
  }

  void _confirmDeleteLog(BuildContext context, Log log) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: tx('Hapus Catatan Produksi?', 18, w: FontWeight.w700),
        content: tx(
          'Catatan ${log.good} OK & ${log.rej} Reject pada ${fdt(log.d)} akan dihapus dan stok akan dikurangi ${log.good} unit.',
          14,
          c: Colors.white70,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: tx('Batal', 14, c: Colors.white60),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: org),
            onPressed: () {
              Navigator.pop(ctx);
              st.deleteLog(log);
              snack(context, 'Catatan produksi telah dihapus');
            },
            child: tx('Hapus', 14, c: bg, w: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    g.dispose();
    r.dispose();
    noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: st,
        builder: (context, _) {
          final now = DateTime.now();
          final list = st.logs.reversed
              .where((l) => mode == 1 || same(l.d, now))
              .toList();

          final todayGood = st.today;
          final todayRej = st.todayRej;
          final todayYield = st.todayYield;
          final progress = cl(todayGood / st.target);

          return ListView(
            // Bottom padding besar (110) mengantisipasi bottom navigation bar
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
            physics: const BouncingScrollPhysics(),
            children: [
              tx('Pusat Produksi & QC', 22, w: FontWeight.w700, al: TextAlign.center),
              const SizedBox(height: 4),
              tx('Pemantauan output perakitan dan kualitas produk', 12, c: Colors.white54, al: TextAlign.center),
              
              Seg(
                const ['Hari Ini', 'Semua Riwayat'],
                mode,
                (v) => setState(() => mode = v),
              ),

              // Hero Ring Capaian
              Center(
                child: Ring(
                  [progress],
                  [progress >= 1.0 ? mint : (progress >= 0.5 ? yel : org)],
                  size: 195,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedCount(
                        value: todayGood,
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                      ),
                      const SizedBox(height: 2),
                      tx('dari target ${numFmt(st.target)} unit', 12, c: Colors.white54),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: a(mint, 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: tx('${(progress * 100).round()}% tercapai', 11, c: mint, w: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Target Setter Card
              Box(
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        tx('Target Harian Pabrik', 14, w: FontWeight.w600),
                        const SizedBox(height: 2),
                        tx('Beban produksi hari berjalan', 11, c: Colors.white54),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton.filledTonal(
                          style: IconButton.styleFrom(
                            backgroundColor: cardSurface,
                            foregroundColor: mint,
                          ),
                          onPressed: () {
                            st.target = math.max(50, st.target - 25);
                            st.change();
                          },
                          icon: const Icon(Icons.remove_rounded, size: 20),
                        ),
                        SizedBox(
                          width: 64,
                          child: tx('${st.target}', 18, w: FontWeight.w700, al: TextAlign.center),
                        ),
                        IconButton.filledTonal(
                          style: IconButton.styleFrom(
                            backgroundColor: cardSurface,
                            foregroundColor: mint,
                          ),
                          onPressed: () {
                            st.target += 25;
                            st.change();
                          },
                          icon: const Icon(Icons.add_rounded, size: 20),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Production & Defect Metrics Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          tx('First Pass Yield', 11, c: Colors.white54),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              tx('${(todayYield * 100).toStringAsFixed(1)}%', 20, w: FontWeight.w700, c: mint),
                              const Spacer(),
                              const Icon(Icons.verified_rounded, size: 18, color: mint),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          tx('Total Reject Hari Ini', 11, c: Colors.white54),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              tx('$todayRej unit', 20, w: FontWeight.w700, c: todayRej > 0 ? org : Colors.white70),
                              const Spacer(),
                              Icon(Icons.warning_amber_rounded, size: 18, color: todayRej > 0 ? org : Colors.white38),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Production Input Box
              Box(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.add_circle_outline_rounded, color: mint, size: 20),
                        const SizedBox(width: 8),
                        tx('Catat Hasil Produksi Baru', 16, w: FontWeight.w600),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: g,
                                keyboardType: TextInputType.number,
                                decoration: dec('Produk OK (Lolos)', prefix: const Icon(Icons.check, color: mint, size: 18)),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  for (final inc in [50, 100])
                                    Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: ActionChip(
                                        label: tx('+$inc', 11, c: mint, w: FontWeight.w600),
                                        backgroundColor: a(mint, 0.1),
                                        side: BorderSide(color: a(mint, 0.2)),
                                        padding: EdgeInsets.zero,
                                        onPressed: () => _addQuick(g, inc),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: r,
                                keyboardType: TextInputType.number,
                                decoration: dec('Reject (Cacat)', prefix: const Icon(Icons.close, color: org, size: 18)),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  for (final inc in [1, 5])
                                    Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: ActionChip(
                                        label: tx('+$inc', 11, c: org, w: FontWeight.w600),
                                        backgroundColor: a(org, 0.1),
                                        side: BorderSide(color: a(org, 0.2)),
                                        padding: EdgeInsets.zero,
                                        onPressed: () => _addQuick(r, inc),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: noteCtrl,
                      decoration: dec('Catatan batch / shift (opsional)', prefix: const Icon(Icons.edit_note_rounded, color: Colors.white54, size: 18)),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: btn('Simpan ke Stok Siap Jual', () {
                        final gv = int.tryParse(g.text) ?? 0;
                        final rv = int.tryParse(r.text) ?? 0;
                        if (gv <= 0 && rv <= 0) {
                          snack(context, 'Masukkan jumlah produk OK atau Reject terlebih dahulu', isError: true);
                          return;
                        }
                        st.produce(gv, rv, note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim());
                        g.clear();
                        r.clear();
                        noteCtrl.clear();
                        FocusScope.of(context).unfocus();
                        snack(context, '+$gv unit OK berhasil ditambahkan ke stok siap jual!');
                      }, icon: Icons.save_rounded),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 6),
              Row(
                children: [
                  tx(mode == 0 ? 'Catatan Produksi Hari Ini' : 'Seluruh Riwayat Batch', 15, w: FontWeight.w600),
                  const Spacer(),
                  tx('${list.length} entri', 12, c: Colors.white38),
                ],
              ),
              const SizedBox(height: 10),

              // Production Entries List
              for (final l in list)
                Box(
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: a(mint, 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.inventory_2_rounded, color: mint, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                tx(
                                  same(l.d, now) ? 'Hari ini, ${ft(l.d)}' : fdt(l.d),
                                  13,
                                  w: FontWeight.w600,
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: a(mint, 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: tx('${(l.yieldPct * 100).round()}% OK', 10, c: mint, w: FontWeight.w600),
                                ),
                              ],
                            ),
                            if (l.note != null && l.note!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: tx(l.note!, 11, c: Colors.white54),
                              ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          tx('+${numFmt(l.good)} OK', 13, c: mint, w: FontWeight.w700),
                          if (l.rej > 0)
                            tx('${l.rej} reject', 11, c: org, w: FontWeight.w600)
                          else
                            tx('0 reject', 11, c: Colors.white24),
                        ],
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.white38),
                        onPressed: () => _confirmDeleteLog(context, l),
                        tooltip: 'Hapus entri',
                      ),
                    ],
                  ),
                ),

              if (list.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      const Icon(Icons.inbox_outlined, size: 40, color: Colors.white24),
                      const SizedBox(height: 10),
                      tx('Belum ada data produksi pada filter ini', 13, c: Colors.white38, al: TextAlign.center),
                    ],
                  ),
                ),
            ],
          );
        },
      );
}

