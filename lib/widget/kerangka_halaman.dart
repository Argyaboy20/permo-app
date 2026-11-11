import 'package:flutter/material.dart';
import '../tema.dart';

/// Bungkus halaman isi (Kamus, Ilmu Tanah, Rekomendasi) dengan bilah atas dan tombol kembali.
class KerangkaHalaman extends StatelessWidget {
  const KerangkaHalaman({super.key, required this.judul, required this.isi});

  final String judul;
  final Widget isi;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: Text(
          judul,
          style: const TextStyle(fontWeight: FontWeight.w800, color: WarnaPermo.hijauTua),
        ),
      ),
      body: SafeArea(top: false, child: isi),
    );
  }
}