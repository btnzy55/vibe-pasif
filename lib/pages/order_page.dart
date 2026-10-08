import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';
import '../models/client.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/ring.dart';

// Form tambah pemesan (bottom sheet)
void addClient(BuildContext c) {
  final n = TextEditingController();
  final q = TextEditingController();

  void addPreset(int amount) {
    final current = int.tryParse(q.text) ?? 0;
    q.text = (current + amount).toString();
  }

  showModalBottomSheet(
    context: c,
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
              const Icon(Icons.person_add_alt_1_rounded, color: mint, size: 22),
              const SizedBox(width: 10),
              tx('Tambah Pemesan Baru', 18, w: FontWeight.w700),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: n,
            decoration: dec('Nama Klien / Perusahaan', prefix: const Icon(Icons.business_rounded, color: Colors.white54, size: 18)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: q,
            keyboardType: TextInputType.number,
            decoration: dec('Jumlah Permintaan (Unit)', prefix: const Icon(Icons.numbers_rounded, color: Colors.white54, size: 18)),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final val in [250, 500, 1000])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: tx('+$val', 11, c: yel, w: FontWeight.w600),
                    backgroundColor: a(yel, 0.1),
                    side: BorderSide(color: a(yel, 0.2)),
                    padding: EdgeInsets.zero,
                    onPressed: () => addPreset(val),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: btn('Simpan ke Daftar Pesanan', () {
              final v = int.tryParse(q.text) ?? 0;
              final name = n.text.trim();
              if (name.isEmpty) {
                snack(c, 'Masukkan nama pemesan / klien terlebih dahulu', isError: true);
                return;
              }
              if (v <= 0) {
                snack(c, 'Jumlah pesanan harus lebih besar dari 0 unit', isError: true);
                return;
              }
              st.addClient(name, v);
              Navigator.pop(ctx);
              snack(c, 'Pesanan $name sebanyak ${numFmt(v)} unit berhasil didaftarkan');
            }, icon: Icons.check_circle_outline_rounded),
          ),
        ],
      ),
    ),
  );
}

class OrderPage extends StatelessWidget {
  const OrderPage({super.key});

  void _confirmDeleteClient(BuildContext context, int index, Client client) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: tx('Batalkan Pesanan?', 18, w: FontWeight.w700),
        content: tx(
          'Pesanan "${client.name}" sebanyak ${numFmt(client.qty)} unit akan dihapus dari sistem antrean.',
          14,
          c: Colors.white70,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: tx('Kembali', 14, c: Colors.white60),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: org),
            onPressed: () {
              Navigator.pop(ctx);
              st.removeClient(index);
              snack(context, 'Pesanan ${client.name} dibatalkan');
            },
            child: tx('Hapus Pesanan', 14, c: bg, w: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: st,
        builder: (context, _) {
          final short = math.max(0, st.demand - st.stock);
          final cover = st.demand == 0 ? 1.0 : cl(st.stock / st.demand);

          return ListView(
            // Bottom padding 115 memastikan tidak terhalang floating action button dan navigation bar
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 115),
            physics: const BouncingScrollPhysics(),
            children: [
              tx('Permintaan Pasar', 22, w: FontWeight.w700, al: TextAlign.center),
              const SizedBox(height: 4),
              tx('Alokasi stok FIFO & jadwal pengiriman pemesan', 12, c: Colors.white54, al: TextAlign.center),
              const SizedBox(height: 16),

              // Overview Ring & Stats Box
              Box(
                Row(
                  children: [
                    Ring(
                      [cover],
                      [cover >= 1.0 ? mint : (cover >= 0.5 ? yel : org)],
                      size: 96,
                      child: tx('${(cover * 100).round()}%', 18, w: FontWeight.w700),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              tx('Stok Siap: ', 13, c: Colors.white70),
                              tx('${numFmt(st.stock)} unit', 14, w: FontWeight.w700, c: mint),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              tx('Total Pesanan: ', 13, c: Colors.white70),
                              tx('${numFmt(st.demand)} unit', 14, w: FontWeight.w700, c: yel),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: a(short == 0 ? mint : yel, 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: tx(
                              short == 0
                                  ? '✓ Stok mencukupi seluruh pesanan'
                                  : 'Defisit ${numFmt(short)} unit (±${(short / st.target).ceil()} hari kerja)',
                              11,
                              c: short == 0 ? mint : yel,
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
                  tx('Daftar Antrean Pemesan', 15, w: FontWeight.w600),
                  TextButton.icon(
                    onPressed: () => addClient(context),
                    icon: const Icon(Icons.add, size: 16, color: mint),
                    label: tx('Tambah', 13, c: mint, w: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              for (var i = 0; i < st.clients.length; i++) clientCard(context, i),

              if (st.clients.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(36),
                  child: Column(
                    children: [
                      const Icon(Icons.assignment_turned_in_outlined, size: 44, color: Colors.white24),
                      const SizedBox(height: 12),
                      tx('Semua pesanan telah terpenuhi atau kosong.', 14, c: Colors.white54, al: TextAlign.center),
                      const SizedBox(height: 12),
                      btn('+ Tambah Pemesan Baru', () => addClient(context), tonal: true),
                    ],
                  ),
                ),
            ],
          );
        },
      );

  Widget clientCard(BuildContext context, int i) {
    final c = st.clients[i];
    final al = st.alloc(i);
    final p = cl(al / c.qty);
    final col = p >= 1.0 ? mint : (p > 0 ? yel : org);

    final statusText = p >= 1.0
        ? 'Siap Kirim Penuh'
        : p > 0
            ? 'Teralokasi Sebagian'
            : 'Menunggu Antrean Stok';

    return Box(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: cardSurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: tx('${i + 1}', 13, w: FontWeight.w700, c: mint),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    tx(c.name, 16, w: FontWeight.w600),
                    tx('Target: ${numFmt(c.qty)} unit', 12, c: Colors.white54),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: a(col, 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: tx(statusText, 11, c: col, w: FontWeight.w600),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: () => _confirmDeleteClient(context, i, c),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: Colors.white38,
                ),
                tooltip: 'Batalkan pesanan',
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress indicator with smooth animation
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: p),
            duration: const Duration(milliseconds: 650),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: a(Colors.white, 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: v,
                    child: Container(
                      decoration: BoxDecoration(
                        color: col,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: col.withAlpha(80),
                            blurRadius: 6,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    tx(
                      'Teralokasi ${numFmt(al)} dari ${numFmt(c.qty)} unit (${(p * 100).round()}%)',
                      12,
                      c: col,
                      w: FontWeight.w600,
                    ),
                    if (al < c.qty)
                      tx('Sisa kekurangan: ${numFmt(c.qty - al)} unit', 11, c: Colors.white38),
                  ],
                ),
              ),
              if (al > 0)
                btn('Kirim ${numFmt(al)} Unit', () {
                  final sent = st.ship(i);
                  snack(context, 'Pengiriman ${numFmt(sent)} unit ke ${c.name} telah dicatat!');
                }, tonal: true, icon: Icons.local_shipping_outlined),
            ],
          ),
        ],
      ),
    );
  }
}

