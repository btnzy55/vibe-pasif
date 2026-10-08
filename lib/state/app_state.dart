import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';
import '../models/client.dart';
import '../models/log.dart';
import '../models/machine.dart';

class AppState extends ChangeNotifier {
  int stock = 620, target = 300;
  final logs = <Log>[];
  final clients = [Client('PT Mitra Elektrindo', 1000), Client('CV Indo Komponen', 500)];
  final machines = [
    Machine(
      'Mesin Solder A',
      1180,
      6200,
      DateTime.now().subtract(const Duration(days: 98)),
      maintenanceNotes: ['Servis nozel solder', 'Ganti thermocouple'],
    ),
    Machine(
      'Mesin Pick & Place',
      360,
      2100,
      DateTime.now().subtract(const Duration(days: 30)),
      maintenanceNotes: ['Kalibrasi feeder vision'],
    ),
    Machine(
      'Mesin Reflow Oven',
      1430,
      8100,
      DateTime.now().subtract(const Duration(days: 119)),
      maintenanceNotes: ['Pembersihan konveyor', 'Penggantian elemen pemanas zona 3'],
    ),
  ];

  AppState() {
    final n = DateTime.now();
    final v = [280, 310, 260, 295, 330, 240];
    final rejects = [11, 14, 8, 12, 15, 9];
    for (var i = 0; i < 6; i++) {
      final pastDate = n.subtract(Duration(days: 6 - i));
      logs.add(
        Log(
          DateTime(pastDate.year, pastDate.month, pastDate.day, 16, 30),
          v[i],
          rejects[i],
          note: 'Shift 1 & 2 reguler',
        ),
      );
    }
    // Log hari ini awal
    logs.add(
      Log(
        DateTime(n.year, n.month, n.day, 11, 45),
        150,
        5,
        note: 'Batch pagi lini A',
      ),
    );
  }

  int made(DateTime d) =>
      logs.where((l) => same(l.d, d)).fold(0, (s, l) => s + l.good);

  int rejected(DateTime d) =>
      logs.where((l) => same(l.d, d)).fold(0, (s, l) => s + l.rej);

  double yieldRate(DateTime d) {
    final g = made(d);
    final r = rejected(d);
    final total = g + r;
    return total == 0 ? 1.0 : g / total;
  }

  int get today => made(DateTime.now());
  int get todayRej => rejected(DateTime.now());
  double get todayYield => yieldRate(DateTime.now());

  int get demand => clients.fold(0, (s, c) => s + c.qty);

  // Stok dialokasikan berurutan secara transparan ke tiap pemesan
  int alloc(int i) {
    if (i < 0 || i >= clients.length) return 0;
    var left = stock;
    for (var k = 0; k < i; k++) {
      left -= math.min(left, clients[k].qty);
    }
    return math.max(0, math.min(left, clients[i].qty));
  }

  void produce(int g, int r, {String? note}) {
    if (g < 0) g = 0;
    if (r < 0) r = 0;
    if (g == 0 && r == 0) return;
    logs.add(Log(DateTime.now(), g, r, note: note));
    stock += g;
    notifyListeners();
  }

  int ship(int i) {
    if (i < 0 || i >= clients.length) return 0;
    final x = alloc(i);
    if (x <= 0) return 0;
    stock -= x;
    clients[i].qty -= x;
    if (clients[i].qty <= 0) {
      clients.removeAt(i);
    }
    notifyListeners();
    return x;
  }

  void deleteLog(Log item) {
    if (logs.remove(item)) {
      // Menyesuaikan stok jika log hari ini dihapus
      stock = math.max(0, stock - item.good);
      notifyListeners();
    }
  }

  void addClient(String name, int qty) {
    if (name.trim().isEmpty || qty <= 0) return;
    clients.add(Client(name.trim(), qty));
    notifyListeners();
  }

  void removeClient(int index) {
    if (index >= 0 && index < clients.length) {
      clients.removeAt(index);
      notifyListeners();
    }
  }

  void recordMachineMaintenance(int index, {String? note}) {
    if (index >= 0 && index < machines.length) {
      final m = machines[index];
      m.since = 0;
      m.last = DateTime.now();
      if (note != null && note.trim().isNotEmpty) {
        m.maintenanceNotes.insert(0, note.trim());
      } else {
        m.maintenanceNotes.insert(0, 'Servis berkala (reset jam siklus)');
      }
      notifyListeners();
    }
  }

  void addMachineHours(int index, double hours) {
    if (index >= 0 && index < machines.length) {
      machines[index].since += hours;
      machines[index].total += hours;
      notifyListeners();
    }
  }

  void addMachine(String name) {
    if (name.trim().isEmpty) return;
    machines.add(Machine(name.trim(), 0, 0, DateTime.now()));
    notifyListeners();
  }

  Machine? get worstMachine {
    if (machines.isEmpty) return null;
    return machines.reduce((x, y) => x.left < y.left ? x : y);
  }

  double get avgHealth {
    if (machines.isEmpty) return 1.0;
    return machines.fold(0.0, (s, m) => s + m.health) / machines.length;
  }

  List<String> get criticalAlerts {
    final list = <String>[];
    for (final m in machines) {
      if (m.left <= 0) {
        list.add('${m.name} telah melewati batas siklus servis!');
      } else if (m.repairDays <= 7) {
        list.add('${m.name} perlu diservis dalam ${m.repairDays} hari');
      } else if (m.lifePct >= 0.85) {
        list.add('${m.name} mendekati batas usia pakai total');
      }
    }
    final short = demand - stock;
    if (short > 0) {
      list.add('Kekurangan stok sebesar ${numFmt(short)} unit untuk memenuhi semua pesanan');
    }
    if (today >= target) {
      list.add('Target produksi harian ($target unit) telah tercapai hari ini! 🎉');
    }
    return list;
  }

  void change() => notifyListeners();
}

final st = AppState();

