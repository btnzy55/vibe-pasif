class Log {
  DateTime d;
  int good, rej;
  String? note;
  Log(this.d, this.good, this.rej, {this.note});

  int get total => good + rej;
  double get yieldPct => total == 0 ? 1.0 : (good / total);
  double get rejectPct => total == 0 ? 0.0 : (rej / total);
}

