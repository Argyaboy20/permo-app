import 'package:flutter/material.dart';
import '../tema.dart';
import '../widget/kerangka_halaman.dart';
import '../widget/merek.dart';

const _versiAplikasi = '1.0.0';

class HalamanTentang extends StatelessWidget {
  const HalamanTentang({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return KerangkaHalaman(
      judul: 'Tentang Sistem',
      isi: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              _Kepala(tema: tema),
              _Bagian(
                ikon: Icons.info_outline,
                judul: 'Tentang Permo',
                anak: [
                  Text(
                    'Pertanian Mobile (Permo) adalah aplikasi pendamping belajar dan bercocok tanam. '
                    'Permo mengumpulkan pengetahuan tentang tumbuhan dan tanah di Indonesia, lalu '
                    'membantu memilih tanaman yang cocok dengan cuaca di lokasimu saat ini.',
                    style: tema.bodyMedium?.copyWith(height: 1.5),
                  ),
                ],
              ),
              const _Bagian(
                ikon: Icons.widgets_outlined,
                judul: 'Fitur',
                anak: [
                  _Butir('Kamus Tumbuhan', 'kebutuhan suhu, tanah, sinar matahari, dan air.'),
                  _Butir('Ilmu Tanah', 'jenis tanah di Indonesia beserta ciri, sebaran, dan pH.'),
                  _Butir('Rekomendasi Tanam',
                      'tanaman yang cocok menurut suhu dan kelembapan udara di lokasimu, diperbarui otomatis.'),
                  _Butir('Pencarian', 'cari kata di seluruh isi Kamus dan Ilmu Tanah.'),
                  _Butir('Permo AI', 'asisten tanya jawab seputar pertanian berbasis AI.'),
                ],
              ),
              const _Bagian(
                ikon: Icons.code,
                judul: 'Teknologi',
                anak: [
                  _Baris('Aplikasi', 'Flutter (web dan Android)'),
                  _Baris('Server', 'Go, REST API di Render'),
                  _Baris('Basis data', 'PostgreSQL di Neon'),
                  _Baris('Keamanan', 'Kata sandi disimpan sebagai hash bcrypt; sesi memakai token JWT'),
                ],
              ),
              const _Bagian(
                ikon: Icons.public,
                judul: 'Sumber Data',
                anak: [
                  _Baris('Cuaca', 'Open-Meteo'),
                  _Baris('Nama daerah', '© kontributor OpenStreetMap'),
                  _Baris('Tumbuhan & tanah',
                      'Disusun dari berbagai referensi pertanian dan ilmu tanah'),
                ],
              ),
              _Bagian(
                ikon: Icons.lock_outline,
                judul: 'Privasi',
                anak: [
                  Text(
                    'Lokasimu hanya dipakai untuk mengambil cuaca dan nama daerah. Koordinat dikirim '
                    'langsung dari perangkatmu ke Open-Meteo dan OpenStreetMap, tidak dikirim ke server '
                    'Permo dan tidak disimpan. Server Permo menyimpan data akunmu (username, email, dan '
                    'kata sandi dalam bentuk hash) serta jumlah pertanyaan Permo AI per hari. Pertanyaan '
                    'yang kamu kirim ke Permo AI diteruskan lewat server Permo ke penyedia layanan AI '
                    '(saat ini Cerebras dan Groq) untuk dijawab. Isi percakapan tidak disimpan di basis '
                    'data Permo, tetapi penyedia AI memiliki kebijakan datanya sendiri, jadi jangan menulis '
                    'data pribadi atau rahasia di percakapan.',
                    style: tema.bodyMedium?.copyWith(height: 1.5),
                  ),
                ],
              ),
              _Bagian(
                ikon: Icons.warning_amber_rounded,
                judul: 'Catatan',
                anak: [
                  Text(
                    'Informasi di Permo bersifat panduan umum untuk belajar. Kondisi lahan dan cuaca '
                    'tiap tempat berbeda, sehingga hasilnya bisa menyimpang. Untuk budidaya skala '
                    'besar, konsultasikan dengan penyuluh pertanian setempat.',
                    style: tema.bodyMedium?.copyWith(height: 1.5),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(child: Text('© 2026 Permo. Semua hak dilindungi.', style: tema.labelMedium)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Kepala extends StatelessWidget {
  const _Kepala({required this.tema});

  final TextTheme tema;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: const Color(0xFFF1F7F4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        child: Column(
          children: [
            const JudulMerek(ukuran: 26),
            const SizedBox(height: 10),
            Text('Permo · Versi $_versiAplikasi', style: tema.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _Bagian extends StatelessWidget {
  const _Bagian({required this.ikon, required this.judul, required this.anak});

  final IconData ikon;
  final String judul;
  final List<Widget> anak;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(top: 12),
      color: const Color(0xFFF1F7F4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: WarnaPermo.hijau.withValues(alpha: 0.25),
                  child: Icon(ikon, size: 20, color: WarnaPermo.hijauTua),
                ),
                const SizedBox(width: 12),
                Text(
                  judul,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < anak.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              anak[i],
            ],
          ],
        ),
      ),
    );
  }
}

class _Butir extends StatelessWidget {
  const _Butir(this.judul, this.isi);

  final String judul;
  final String isi;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(Icons.check_circle, size: 18, color: WarnaPermo.hijauTua),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: '$judul: ', style: const TextStyle(fontWeight: FontWeight.w700)),
                TextSpan(text: isi),
              ],
            ),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4),
          ),
        ),
      ],
    );
  }
}

class _Baris extends StatelessWidget {
  const _Baris(this.label, this.nilai);

  final String label;
  final String nilai;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(label, style: tema.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
        ),
        Expanded(child: Text(nilai, style: tema.bodyMedium)),
      ],
    );
  }
}