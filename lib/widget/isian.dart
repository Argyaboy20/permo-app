import 'package:flutter/material.dart';
import '../tema.dart';

InputDecoration dekorasiIsian(String label, IconData ikon, {Widget? akhir}) {
  OutlineInputBorder garis(Color warna, double lebar) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: warna, width: lebar),
      );

  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(ikon),
    suffixIcon: akhir,
    filled: true,
    fillColor: const Color(0xFFF1F7F4),
    border: garis(Colors.transparent, 0),
    enabledBorder: garis(Colors.transparent, 0),
    focusedBorder: garis(WarnaPermo.hijau, 2),
    errorBorder: garis(Colors.red.shade300, 1.5),
    focusedErrorBorder: garis(Colors.red.shade400, 2),
  );
}