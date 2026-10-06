import 'package:flutter/material.dart';

const bg = Color(0xFF0A0F0B), card = Color(0xFF151B17);
const mint = Color(0xFFA8E6D8), yel = Color(0xFFE8E48C), lil = Color(0xFFE3B8F5), org = Color(0xFFF08A4B);
Color a(Color c, double o) => c.withAlpha((o * 255).round());
double cl(num x) => x.clamp(0, 1).toDouble();
const dn = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
bool same(DateTime x, DateTime y) => x.year == y.year && x.month == y.month && x.day == y.day;
String fd(DateTime d) => '${d.day}/${d.month}/${d.year}';
Text tx(String s, double z, {Color c = Colors.white, FontWeight w = FontWeight.w500, TextAlign? al}) =>
    Text(s, textAlign: al, style: TextStyle(fontSize: z, color: c, fontWeight: w));

// Helper UI umum
Widget btn(String l, VoidCallback f, {bool tonal = false}) => FilledButton(
    onPressed: f,
    style: FilledButton.styleFrom(backgroundColor: tonal ? a(mint, .15) : mint, foregroundColor: tonal ? mint : bg, minimumSize: const Size(0, 46)),
    child: Text(l));
InputDecoration dec(String l) => InputDecoration(labelText: l, filled: true, fillColor: bg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none));
void snack(BuildContext c, String m) => ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(m), behavior: SnackBarBehavior.floating));
