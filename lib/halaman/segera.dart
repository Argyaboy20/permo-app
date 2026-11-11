import 'package:flutter/material.dart';
import '../tema.dart';
import '../widget/kerangka_halaman.dart';

class HalamanSegera extends StatelessWidget {
  const HalamanSegera({
    super.key,
    required this.judul,
    required this.ikon,
    required this.keterangan,
  });

  final String judul;
  final IconData ikon;
  final String keterangan;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return KerangkaHalaman(
      judul: judul,
      isi: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: WarnaPermo.hijau.withValues(alpha: 0.25),
                child: Icon(ikon, size: 40, color: WarnaPermo.hijauTua),
              ),
              const SizedBox(height: 16),
              Text('Segera hadir', style: tema.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(keterangan, textAlign: TextAlign.center, style: tema.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}