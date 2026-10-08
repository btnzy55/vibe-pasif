import 'package:flutter/material.dart';

import './theme.dart';
import './pages/home_page.dart';
import './pages/prod_page.dart';
import './pages/order_page.dart';
import './pages/mach_page.dart';

void main() => runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ProdTrack',
        theme: ThemeData(
          brightness: Brightness.dark,
          useMaterial3: true,
          scaffoldBackgroundColor: bg,
          colorScheme: const ColorScheme.dark(
            primary: mint,
            surface: card,
          ),
          bottomAppBarTheme: const BottomAppBarThemeData(
            color: Colors.transparent,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
          ),
        ),
        home: const Shell(),
      ),
    );

class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellS();
}

class _ShellS extends State<Shell> {
  int i = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      Home(go: (x) => setState(() => i = x)),
      const ProdPage(),
      const OrderPage(),
      const MachPage(),
    ];

    const ic = [
      Icons.home_rounded,
      Icons.precision_manufacturing_rounded,
      Icons.people_alt_rounded,
      Icons.monitor_heart_rounded,
    ];

    const labels = [
      'Beranda',
      'Produksi',
      'Pesanan',
      'Kondisi Mesin',
    ];

    return Scaffold(
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 320),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.02),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: KeyedSubtree(key: ValueKey(i), child: pages[i]),
        ),
      ),
      floatingActionButton: i == 2
          ? Padding(
              padding: const EdgeInsets.only(bottom: 72),
              child: FloatingActionButton.extended(
                elevation: 4,
                backgroundColor: mint,
                foregroundColor: bg,
                onPressed: () => addClient(context),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Klien Baru', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            )
          : null,
      bottomNavigationBar: Material(
        color: Colors.transparent,
        elevation: 0,
        child: SafeArea(
          child: Container(
            height: 56,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.all(5),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xFF131915),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: a(mint, 0.22), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(120),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: mint.withAlpha(15),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, box) {
                final slot = box.maxWidth / 4;
                const size = 44.0;
                return Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // Animated sliding indicator
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 340),
                      curve: Curves.easeOutCubic,
                      left: i * slot + (slot - size) / 2,
                      top: 1,
                      child: Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: a(mint, 0.16),
                          border: Border.all(color: mint, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: mint.withAlpha(50),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        for (var k = 0; k < 4; k++)
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => setState(() => i = k),
                              child: Tooltip(
                                message: labels[k],
                                child: Center(
                                  child: AnimatedScale(
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeOutCubic,
                                    scale: i == k ? 1.15 : 1.0,
                                    child: Icon(
                                      ic[k],
                                      size: 22,
                                      color: i == k ? mint : Colors.white38,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

