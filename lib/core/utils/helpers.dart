import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

String formatRupiah(num amount) {
  final formatter = NumberFormat('#,###', 'id_ID');
  return 'Rp ${formatter.format(amount)}';
}

String getInitials(String name) {
  final words = name.trim().split(RegExp(r'\s+'));
  if (words.length == 1) return words[0].substring(0, 2).toUpperCase();
  return '${words[0][0]}${words[1][0]}'.toUpperCase();
}

Color getColorFromString(String text) {
  int hash = 0;
  for (var char in text.codeUnits) {
    hash = char + ((hash << 5) - hash);
  }
  final hue = (hash.abs() % 360).toDouble();
  return HSLColor.fromAHSL(1.0, hue, 0.7, 0.9).toColor();
}

Color getTextColorFromString(String text) {
  int hash = 0;
  for (var char in text.codeUnits) {
    hash = char + ((hash << 5) - hash);
  }
  final hue = (hash.abs() % 360).toDouble();
  return HSLColor.fromAHSL(1.0, hue, 0.8, 0.3).toColor();
}

String formatDateId(DateTime date) =>
    DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);

String formatDateShort(DateTime date) =>
    DateFormat('d MMM yyyy', 'id_ID').format(date);

String formatTime(DateTime date) => DateFormat('HH:mm').format(date);

