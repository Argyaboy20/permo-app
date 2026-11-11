import 'package:flutter/material.dart';
import '../tema.dart';
import '../widget/kartu_form.dart';
import '../widget/latar_daun.dart';
import '../widget/logo_permo.dart';
import '../widget/muncul.dart';

class HalamanLanding extends StatelessWidget {
  const HalamanLanding({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LatarDaun(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 920),
                child: const Column(
                  children: [
                    Muncul(ms: 600, child: _Hero()),
                    SizedBox(height: 32),
                    Muncul(ms: 800, child: _Pengantar()),
                    SizedBox(height: 20),
                    Muncul(ms: 1000, child: _DaftarFitur()),
                    SizedBox(height: 20),
                    Muncul(ms: 1200, child: _CaraKerja()),
                    SizedBox(height: 32),
                    _Penutup(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TombolDaftar extends StatelessWidget {
  const _TombolDaftar();

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () => Navigator.pushNamed(context, '/daftar'),
      icon: const Icon(Icons.eco),
      label: const Text('Daftar Akun'),
      style: FilledButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: WarnaPermo.hijauTua,
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const LogoPermo(ukuran: 140),
        ),
        const SizedBox(height: 24),
        Text(
          'Pertanian Mobile',
          textAlign: TextAlign.center,
          style: tema.displaySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Text(
            'Teman bertani di genggamanmu: kenali tumbuhan, pahami tanah, '
            'dan temukan tanaman yang cocok untuk lahanmu.',
            textAlign: TextAlign.center,
            style: tema.titleMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.92),
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 28),
        const _TombolDaftar(),
      ],
    );
  }
}

class _Pengantar extends StatelessWidget {
  const _Pengantar();

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return KartuForm(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Apa itu Permo?',
            style: tema.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: WarnaPermo.hijauTua,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Permo (Pertanian Mobile) adalah aplikasi pendamping bertani. '
            'Pelajari kebutuhan berbagai tumbuhan, kenali jenis-jenis tanah, '
            'dan dapatkan saran tanaman berdasarkan suhu dan kelembapan udara di tempatmu.',
            style: tema.bodyLarge?.copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }
}

class _DaftarFitur extends StatelessWidget {
  const _DaftarFitur();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: [
        _KartuFitur(
          ikon: Icons.menu_book,
          judul: 'Kamus Tumbuhan',
          isi: '18 tumbuhan lengkap dengan suhu ideal, jenis tanah, '
              'kebutuhan sinar matahari, dan air.',
        ),
        _KartuFitur(
          ikon: Icons.terrain,
          judul: 'Ilmu Tanah',
          isi: '15 jenis tanah Indonesia: ciri-ciri, tumbuhan yang cocok, '
              'daerah penyebaran, dan kisaran pH.',
        ),
        _KartuFitur(
          ikon: Icons.eco,
          judul: 'Rekomendasi Tanam',
          isi: 'Masukkan suhu dan kelembapan udara, lalu dapatkan hingga '
              '10 tanaman yang paling cocok dari 48 pilihan.',
        ),
        _KartuFitur(
          ikon: Icons.verified_user,
          judul: 'Akun Lebih Aman',
          isi: 'Password disimpan dalam bentuk hash, dan lupa akun memakai '
              'kode sekali pakai lewat email, bukan mengirim password.',
        ),
      ],
    );
  }
}

class _KartuFitur extends StatelessWidget {
  const _KartuFitur({required this.ikon, required this.judul, required this.isi});

  final IconData ikon;
  final String judul;
  final String isi;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return SizedBox(
      width: 280,
      child: KartuForm(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: WarnaPermo.hijau.withValues(alpha: 0.18),
              child: Icon(ikon, color: WarnaPermo.hijauTua, size: 28),
            ),
            const SizedBox(height: 14),
            Text(judul, style: tema.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(isi, style: tema.bodyMedium?.copyWith(height: 1.5)),
          ],
        ),
      ),
    );
  }
}

class _CaraKerja extends StatelessWidget {
  const _CaraKerja();

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return KartuForm(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mulai dalam tiga langkah',
            style: tema.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: WarnaPermo.hijauTua,
            ),
          ),
          const SizedBox(height: 12),
          const _Langkah(nomor: 1, teks: 'Daftar akun dengan username dan email'),
          const _Langkah(nomor: 2, teks: 'Masuk ke akunmu'),
          const _Langkah(
            nomor: 3,
            teks: 'Jelajahi kamus, ilmu tanah, dan rekomendasi tanam',
          ),
        ],
      ),
    );
  }
}

class _Langkah extends StatelessWidget {
  const _Langkah({required this.nomor, required this.teks});

  final int nomor;
  final String teks;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: WarnaPermo.hijauTua,
            child: Text(
              '$nomor',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(teks, style: Theme.of(context).textTheme.bodyLarge)),
        ],
      ),
    );
  }
}

class _Penutup extends StatelessWidget {
  const _Penutup();

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return Column(
      children: [
        Text(
          'Siap mulai bertani lebih cerdas?',
          textAlign: TextAlign.center,
          style: tema.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        const _TombolDaftar(),
        const SizedBox(height: 28),
        Text(
          '© 2026 Pertanian Mobile',
          style: tema.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.7)),
        ),
      ],
    );
  }
}