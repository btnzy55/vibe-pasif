import 'package:flutter/material.dart';

import '../theme.dart';

class Machine {
  String name;
  double since, total;
  DateTime last;
  Machine(this.name, this.since, this.total, this.last);
  // Repair tiap 4 bulan x 30 hari x 12 jam = 1440 jam; batas risiko rusak 2 tahun x 365 hari x 12 jam = 8760 jam
  static const cycle = 1440.0, life = 8760.0, perDay = 12.0;
  double get left => cycle - since;
  double get repairPct => cl(since / cycle);
  double get lifePct => cl(total / life);
  int get repairDays => (left / perDay).ceil();
  int get lifeDays => ((life - total) / perDay).ceil();
  double get health => cl(1 - (repairPct * .5 + lifePct * .5));
  String get status => left <= 0
      ? 'Perlu repair sekarang'
      : lifePct >= .85
      ? 'Risiko rusak tinggi'
      : repairDays <= 14
      ? 'Segera jadwalkan repair'
      : 'Kondisi baik';
  Color get color => left <= 0 || lifePct >= .85
      ? org
      : repairDays <= 14
      ? yel
      : mint;
}
