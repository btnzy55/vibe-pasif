import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../theme.dart';

class Machine {
  String? id;
  String name;
  double since, total;
  DateTime last;
  List<String> maintenanceNotes;

  Machine(
    this.name,
    this.since,
    this.total,
    this.last, {
    List<String>? maintenanceNotes,
    this.id,
  }) : maintenanceNotes = maintenanceNotes ?? [];

  // Siklus: Repair tiap 4 bulan x 30 hari x 12 jam = 1.440 jam; Batas usia pakai 2 thn x 365 hari x 12 jam = 8.760 jam
  static const cycle = 1440.0, life = 8760.0, perDay = 12.0;

  double get left => cycle - since;
  double get repairPct => cl(since / cycle);
  double get lifePct => cl(total / life);

  int get repairDays => (left / perDay).ceil();
  int get overdueDays => left <= 0 ? ((-left) / perDay).ceil() : 0;
  int get remainingDays => math.max(0, (left / perDay).ceil());
  int get lifeDays => math.max(0, ((life - total) / perDay).ceil());

  // Indikator kesehatan gabungan antara keausan siklus servis dan masa pakai total
  double get health => cl(1.0 - (repairPct * 0.55 + lifePct * 0.45));

  String get status {
    if (left < 0) {
      return overdueDays > 0 ? 'Terlambat $overdueDays hari' : 'Lewat batas siklus';
    } else if (left == 0) {
      return 'Perlu repair hari ini';
    } else if (lifePct >= 0.85) {
      return 'Risiko aus tinggi';
    } else if (repairDays <= 14) {
      return 'Segera jadwalkan repair';
    } else {
      return 'Kondisi prima';
    }
  }

  Color get color {
    if (left <= 0 || lifePct >= 0.85) {
      return org;
    } else if (repairDays <= 14) {
      return yel;
    } else {
      return mint;
    }
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'since': since,
        'total': total,
        'last': last.toIso8601String(),
        'maintenanceNotes': maintenanceNotes,
      };

  factory Machine.fromMap(Map<String, dynamic> map, {String? id}) {
    DateTime parsedDate;
    final rawDate = map['last'];
    if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }
    final rawNotes = map['maintenanceNotes'];
    List<String> notes = [];
    if (rawNotes is List) {
      notes = rawNotes.map((e) => e.toString()).toList();
    }

    return Machine(
      map['name'] as String? ?? 'Mesin',
      (map['since'] as num?)?.toDouble() ?? 0.0,
      (map['total'] as num?)?.toDouble() ?? 0.0,
      parsedDate,
      maintenanceNotes: notes,
      id: id ?? map['id'] as String?,
    );
  }
}
