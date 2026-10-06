import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';
import '../models/client.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/ring.dart';

// Form tambah pemesan (bottom sheet)
void addClient(BuildContext c) {
  final n = TextEditingController(), q = TextEditingController();
  showModalBottomSheet(
    context: c,
    isScrollControlled: true,
    backgroundColor: card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.of(c).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          tx('Pemesan baru', 18),
          const SizedBox(height: 16),
          TextField(controller: n, decoration: dec('Nama pemesan')),
          const SizedBox(height: 12),
          TextField(
            controller: q,
            keyboardType: TextInputType.number,
            decoration: dec('Jumlah pesanan (unit)'),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: btn('Simpan', () {
              final v = int.tryParse(q.text) ?? 0;
              if (n.text.trim().isEmpty || v <= 0) return;
              st.clients.add(Client(n.text.trim(), v));
              st.change();
              Navigator.pop(c);
            }),
          ),
        ],
      ),
    ),
  );
}

class OrderPage extends StatelessWidget {
  const OrderPage({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: st,
    builder: (_, __) {
      final short = math.max(0, st.demand - st.stock);
      final cover = st.demand == 0 ? 1.0 : cl(st.stock / st.demand);
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 90),
        children: [
          tx('Permintaan Pasar', 22, w: FontWeight.w600, al: TextAlign.center),
          const SizedBox(height: 16),
          Box(
            Row(
              children: [
                Ring(
                  [cover],
                  [yel],
                  size: 100,
                  child: tx('${(cover * 100).round()}%', 18),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      tx('Stok siap jual: ${st.stock}', 15),
                      tx('Total pesanan: ${st.demand}', 15, c: Colors.white70),
                      const SizedBox(height: 6),
                      tx(
                        short == 0
                            ? 'Stok mencukupi semua pesanan'
                            : 'Kurang $short unit ≈ ${(short / st.target).ceil()} hari produksi',
                        13,
                        c: short == 0 ? mint : yel,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          for (var i = 0; i < st.clients.length; i++) clientCard(context, i),
          if (st.clients.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: tx(
                'Belum ada pemesan. Tekan + untuk menambah.',
                14,
                c: Colors.white38,
                al: TextAlign.center,
              ),
            ),
        ],
      );
    },
  );

  Widget clientCard(BuildContext context, int i) {
    final c = st.clients[i], al = st.alloc(i), p = cl(al / c.qty);
    final col = p >= 1
        ? mint
        : p > 0
        ? yel
        : org;
    return Box(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: tx(c.name, 17)),
              tx('${c.qty} unit', 15, c: Colors.white70),
              IconButton(
                onPressed: () {
                  st.clients.removeAt(i);
                  st.change();
                },
                icon: const Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: Colors.white38,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TweenAnimationBuilder<double>(
            tween: Tween(end: p),
            duration: const Duration(milliseconds: 600),
            builder: (_, v, __) => ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: v,
                minHeight: 10,
                color: col,
                backgroundColor: a(Colors.white, .08),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: tx('Stok teralokasi $al dari ${c.qty}', 13, c: col),
              ),
              if (al > 0)
                btn('Kirim $al', () {
                  st.ship(i);
                  snack(context, 'Pengiriman $al unit dicatat');
                }, tonal: true),
            ],
          ),
        ],
      ),
    );
  }
}
