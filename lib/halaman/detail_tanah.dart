import 'package:flutter/material.dart';
import '../model/tanah.dart';
import '../tema.dart';

class HalamanDetailTanah extends StatelessWidget {
  const HalamanDetailTanah({super.key, required this.tanah});

  final Tanah tanah;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tanah.nama)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: WarnaPermo.gradienLatar,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.terrain, size: 56, color: Colors.white.withValues(alpha: 0.9)),
                      const SizedBox(height: 10),
                      Text(
                        tanah.nama,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ],
                  ),
                ),
                _KartuInfo(
                  ikon: Icons.info_outline,
                  judul: 'Karakteristik',
                  isi: tanah.karakteristik,
                ),
                _KartuInfo(
                  ikon: Icons.grass,
                  judul: 'Tumbuhan yang Cocok',
                  isi: tanah.tumbuhan,
                ),
                _KartuInfo(
                  ikon: Icons.public,
                  judul: 'Penyebaran',
                  isi: tanah.penyebaran,
                ),
                _KartuInfo(
                  ikon: Icons.science_outlined,
                  judul: 'Unsur & pH',
                  isi: tanah.unsurPh,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _KartuInfo extends StatelessWidget {
  const _KartuInfo({required this.ikon, required this.judul, required this.isi});

  final IconData ikon;
  final String judul;
  final String isi;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(top: 12),
      color: const Color(0xFFF1F7F4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: WarnaPermo.hijau.withValues(alpha: 0.25),
              child: Icon(ikon, color: WarnaPermo.hijauTua),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(judul, style: tema.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(isi, style: tema.bodyLarge?.copyWith(height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}