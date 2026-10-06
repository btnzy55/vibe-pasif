import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/ring.dart';

class ProdPage extends StatefulWidget {
  const ProdPage({super.key});
  @override
  State<ProdPage> createState() => _ProdS();
}

class _ProdS extends State<ProdPage> {
  int mode = 0;
  final g = TextEditingController(), r = TextEditingController();
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: st,
    builder: (_, __) {
      final now = DateTime.now();
      final list = st.logs.reversed
          .where((l) => mode == 1 || same(l.d, now))
          .toList();
      final p = cl(st.today / st.target);
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          tx('Data Produksi', 22, w: FontWeight.w600, al: TextAlign.center),
          Seg(
            const ['Hari ini', 'Semua riwayat'],
            mode,
            (v) => setState(() => mode = v),
          ),
          Center(
            child: Ring(
              [p],
              [mint],
              size: 190,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  tx('${st.today}', 34, w: FontWeight.w600),
                  tx('dari ${st.target} unit', 13, c: Colors.white54),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Box(
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                tx('Target harian', 15),
                Row(
                  children: [
                    IconButton.filledTonal(
                      onPressed: () {
                        st.target = math.max(10, st.target - 10);
                        st.change();
                      },
                      icon: const Icon(Icons.remove),
                    ),
                    SizedBox(
                      width: 60,
                      child: tx('${st.target}', 18, al: TextAlign.center),
                    ),
                    IconButton.filledTonal(
                      onPressed: () {
                        st.target += 10;
                        st.change();
                      },
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Box(
            Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: tx('Input hasil produksi', 16),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: g,
                        keyboardType: TextInputType.number,
                        decoration: dec('Produk jadi (OK)'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: r,
                        keyboardType: TextInputType.number,
                        decoration: dec('Reject'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: btn('Simpan produksi', () {
                    final gv = int.tryParse(g.text) ?? 0,
                        rv = int.tryParse(r.text) ?? 0;
                    if (gv <= 0 && rv <= 0) return;
                    st.produce(gv, rv);
                    g.clear();
                    r.clear();
                    FocusScope.of(context).unfocus();
                    snack(context, '+$gv unit masuk ke stok siap jual');
                  }),
                ),
              ],
            ),
          ),
          for (final l in list)
            Box(
              Row(
                children: [
                  const Icon(Icons.inventory_2_rounded, color: mint),
                  const SizedBox(width: 12),
                  Expanded(
                    child: tx(same(l.d, now) ? 'Hari ini' : fd(l.d), 14),
                  ),
                  tx('${l.good} OK', 14, c: mint),
                  const SizedBox(width: 12),
                  tx('${l.rej} reject', 14, c: org),
                ],
              ),
            ),
          if (list.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: tx(
                'Belum ada data hari ini',
                14,
                c: Colors.white38,
                al: TextAlign.center,
              ),
            ),
        ],
      );
    },
  );
}
