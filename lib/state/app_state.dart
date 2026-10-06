import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';
import '../models/client.dart';
import '../models/log.dart';
import '../models/machine.dart';

class AppState extends ChangeNotifier {
  int stock = 620, target = 300;
  final logs = <Log>[];
  final clients = [Client('Pemesan 1', 1000), Client('Pemesan 2', 500)];
  final machines = [
    Machine(
      'Mesin Solder A',
      1180,
      6200,
      DateTime.now().subtract(const Duration(days: 98)),
    ),
    Machine(
      'Mesin Pick & Place',
      360,
      2100,
      DateTime.now().subtract(const Duration(days: 30)),
    ),
    Machine(
      'Mesin Reflow',
      1430,
      8100,
      DateTime.now().subtract(const Duration(days: 119)),
    ),
  ];
  AppState() {
    final n = DateTime.now(), v = [280, 310, 260, 295, 330, 240];
    for (var i = 0; i < 6; i++) {
      logs.add(Log(n.subtract(Duration(days: 6 - i)), v[i], v[i] ~/ 25));
    }
    logs.add(Log(n, 150, 5));
  }
  int made(DateTime d) =>
      logs.where((l) => same(l.d, d)).fold(0, (s, l) => s + l.good);
  int get today => made(DateTime.now());
  int get demand => clients.fold(0, (s, c) => s + c.qty);
  // stok dialokasikan berurutan ke tiap pemesan
  int alloc(int i) {
    var left = stock;
    for (var k = 0; k < i; k++) {
      left -= math.min(left, clients[k].qty);
    }
    return math.min(left, clients[i].qty);
  }

  void produce(int g, int r) {
    logs.add(Log(DateTime.now(), g, r));
    stock += g;
    notifyListeners();
  }

  void ship(int i) {
    final x = alloc(i);
    stock -= x;
    clients[i].qty -= x;
    if (clients[i].qty <= 0) clients.removeAt(i);
    notifyListeners();
  }

  void change() => notifyListeners();
}

final st = AppState();
