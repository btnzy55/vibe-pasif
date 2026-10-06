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
      body: SafeArea(
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
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (var k = 0; k < 4; k++)
                GestureDetector(
                  onTap: () => setState(() => i = k),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == k ? a(mint, .18) : Colors.transparent,
                      border: Border.all(
                        color: i == k ? mint : Colors.transparent,
                      ),
                    ),
                    child: Icon(ic[k], color: i == k ? mint : Colors.white38),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
