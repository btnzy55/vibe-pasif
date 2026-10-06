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
      colorScheme: const ColorScheme.dark(primary: mint),
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
    return Scaffold(
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: KeyedSubtree(key: ValueKey(i), child: pages[i]),
        ),
      ),
      floatingActionButton: i == 2
          ? FloatingActionButton(
              backgroundColor: mint,
              foregroundColor: bg,
              onPressed: () => addClient(context),
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: Material(
        color: Colors.transparent,
        elevation: 0,
        child: SafeArea(
          child: Container(
            height: 52,
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 18),
            padding: const EdgeInsets.all(4),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: a(mint, .28)),
            ),
            child: LayoutBuilder(
              builder: (_, box) {
                final slot = box.maxWidth / 4;
                const size = 40.0;
                return Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 380),
                      curve: Curves.easeOutBack,
                      left: i * slot + (slot - size) / 2,
                      top: 2,
                      child: Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: a(mint, .18),
                          border: Border.all(color: mint),
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
                              child: Center(
                                child: AnimatedScale(
                                  duration: const Duration(milliseconds: 280),
                                  curve: Curves.easeOutBack,
                                  scale: i == k ? 1.12 : 1,
                                  child: Icon(
                                    ic[k],
                                    size: 22,
                                    color: i == k ? mint : Colors.white38,
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
