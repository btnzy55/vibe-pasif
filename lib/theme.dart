import 'package:flutter/material.dart';

const bg = Color(0xFF0A0F0B), card = Color(0xFF151B17);
const cardSurface = Color(0xFF1B241F), cardBorder = Color(0xFF233027);
const mint = Color(0xFFA8E6D8), yel = Color(0xFFE8E48C), lil = Color(0xFFE3B8F5), org = Color(0xFFF08A4B);
const redAlert = Color(0xFFFF6B6B);

Color a(Color c, double o) => c.withAlpha((o * 255).round());
double cl(num x) => x.clamp(0.0, 1.0).toDouble();

const dn = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
const bulan = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
];

bool same(DateTime x, DateTime y) => x.year == y.year && x.month == y.month && x.day == y.day;
String fd(DateTime d) => '${d.day} ${bulan[d.month - 1]} ${d.year}';
String ft(DateTime d) => '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
String fdt(DateTime d) => '${fd(d)}, ${ft(d)}';

String numFmt(num n) {
  final s = n.toInt().toString();
  final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  return s.replaceAllMapped(reg, (Match m) => '${m[1]}.');
}

Text tx(String s, double z, {Color c = Colors.white, FontWeight w = FontWeight.w500, TextAlign? al, int? maxLines, TextOverflow? overflow}) =>
    Text(
      s,
      textAlign: al,
      maxLines: maxLines,
      overflow: overflow,
      style: TextStyle(
        fontSize: z,
        color: c,
        fontWeight: w,
        letterSpacing: -0.2,
      ),
    );

// Helper UI umum
Widget btn(String l, VoidCallback f, {bool tonal = false, IconData? icon}) => FilledButton.icon(
      onPressed: f,
      icon: icon != null ? Icon(icon, size: 18) : const SizedBox.shrink(),
      label: Text(l, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      style: FilledButton.styleFrom(
        backgroundColor: tonal ? a(mint, .15) : mint,
        foregroundColor: tonal ? mint : bg,
        minimumSize: const Size(0, 46),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
    );

InputDecoration dec(String l, {Widget? prefix, Widget? suffix}) => InputDecoration(
      labelText: l,
      labelStyle: const TextStyle(color: Colors.white54, fontSize: 14),
      prefixIcon: prefix,
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFF0E1410),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: a(mint, 0.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: mint, width: 1.5),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );

void snack(BuildContext c, String m, {bool isError = false}) {
  ScaffoldMessenger.of(c).hideCurrentSnackBar();
  ScaffoldMessenger.of(c).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(
            isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
            color: isError ? org : mint,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(m, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: cardSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: isError ? a(org, 0.4) : a(mint, 0.3)),
      ),
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
    ),
  );
}

