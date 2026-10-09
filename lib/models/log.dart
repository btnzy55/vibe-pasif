class Log {
  String? id;
  DateTime d;
  int good, rej;
  String? note;

  Log(this.d, this.good, this.rej, {this.note, this.id});

  int get total => good + rej;
  double get yieldPct => total == 0 ? 1.0 : (good / total);
  double get rejectPct => total == 0 ? 0.0 : (rej / total);

  Map<String, dynamic> toMap() => {
        'timestamp': d.toIso8601String(),
        'good': good,
        'rej': rej,
        if (note != null) 'note': note,
      };

  factory Log.fromMap(Map<String, dynamic> map, {String? id}) {
    DateTime parsedDate;
    final rawDate = map['timestamp'] ?? map['d'];
    if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }
    return Log(
      parsedDate,
      (map['good'] as num?)?.toInt() ?? 0,
      (map['rej'] as num?)?.toInt() ?? 0,
      note: map['note'] as String?,
      id: id ?? map['id'] as String?,
    );
  }
}
