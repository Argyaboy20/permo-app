import 'package:flutter/material.dart';
import '../model/tumbuhan.dart';
import '../tema.dart';

class HalamanDetailTumbuhan extends StatelessWidget {
  const HalamanDetailTumbuhan({super.key, required this.tumbuhan});

  final Tumbuhan tumbuhan;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tumbuhan.nama)),
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
                      Icon(Icons.eco, size: 56, color: Colors.white.withValues(alpha: 0.9)),
                      const SizedBox(height: 10),
                      Text(
                        tumbuhan.nama,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ],
                  ),
                ),
                _KartuInfo(ikon: Icons.thermostat, judul: 'Suhu', isi: tumbuhan.suhu),
                _KartuInfo(ikon: Icons.terrain, judul: 'Tanah', isi: tumbuhan.tanah),
                _KartuInfo(
                  ikon: Icons.wb_sunny_outlined,
                  judul: 'Sinar Matahari',
                  isi: tumbuhan.sinarMatahari,
                ),
                _KartuInfo(ikon: Icons.water_drop_outlined, judul: 'Air', isi: tumbuhan.air),
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