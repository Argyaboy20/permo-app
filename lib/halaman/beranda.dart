import 'package:flutter/material.dart';
import '../model/pengguna.dart';
import '../tema.dart';
import '../widget/kerangka_halaman.dart';
import 'ilmu_tanah.dart';
import 'kamus.dart';
import 'rekomendasi.dart';

class HalamanBeranda extends StatelessWidget {
  const HalamanBeranda({super.key, required this.pengguna});

  /// Null selama data akun belum selesai dimuat.
  final Pengguna? pengguna;

  static const _hari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
  static const _bulan = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  String _sapaan() {
    final jam = DateTime.now().hour;
    if (jam < 11) return 'Selamat pagi';
    if (jam < 15) return 'Selamat siang';
    if (jam < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  String _tanggal() {
    final n = DateTime.now();
    return '${_hari[n.weekday - 1]}, ${n.day} ${_bulan[n.month - 1]} ${n.year}';
  }

  void _buka(BuildContext context, String judul, Widget isi) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => KerangkaHalaman(judul: judul, isi: isi)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    final kartu = <_DataKartu>[
      _DataKartu(
        judul: 'Kamus Tumbuhan',
        keterangan: 'Suhu, tanah, sinar matahari, dan kebutuhan air berbagai tanaman.',
        ikon: Icons.menu_book_rounded,
        warna: const [Color(0xFF5BB98B), Color(0xFF2F8F63)],
        onTap: () => _buka(context, 'Kamus Tumbuhan', const HalamanKamus()),
      ),
      _DataKartu(
        judul: 'Ilmu Tanah',
        keterangan: 'Kenali jenis tanah di Indonesia beserta ciri, sebaran, dan pH-nya.',
        ikon: Icons.terrain,
        warna: const [Color(0xFFB98A5E), Color(0xFF7A5634)],
        onTap: () => _buka(context, 'Ilmu Tanah', const HalamanIlmuTanah()),
      ),
      _DataKartu(
        judul: 'Rekomendasi Tanam',
        keterangan: 'Tanaman yang cocok untuk cuaca di lokasimu saat ini.',
        ikon: Icons.wb_sunny_outlined,
        warna: const [Color(0xFF3FA9C0), Color(0xFF237F9B)],
        onTap: () => _buka(context, 'Rekomendasi Tanam', const HalamanRekomendasi()),
      ),
    ];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          children: [
            _Sambutan(
              sapaan: _sapaan(),
              nama: pengguna?.username ?? 'Teman Tani',
              tanggal: _tanggal(),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'Jelajahi Permo',
                style: tema.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: WarnaPermo.hijauTua,
                ),
              ),
            ),
            LayoutBuilder(
              builder: (context, c) {
                if (c.maxWidth >= 720) {
                  // Layar lebar: tiga kartu sejajar dengan ukuran sama
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < kartu.length; i++) ...[
                        if (i > 0) const SizedBox(width: 16),
                        Expanded(child: _KartuMenu(data: kartu[i], tinggi: 230)),
                      ],
                    ],
                  );
                }
                // Layar ponsel: tiga kartu bertumpuk dengan tinggi sama
                return Column(
                  children: [
                    for (var i = 0; i < kartu.length; i++) ...[
                      if (i > 0) const SizedBox(height: 14),
                      _KartuMenu(data: kartu[i], tinggi: 172),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DataKartu {
  _DataKartu({
    required this.judul,
    required this.keterangan,
    required this.ikon,
    required this.warna,
    required this.onTap,
  });

  final String judul;
  final String keterangan;
  final IconData ikon;
  final List<Color> warna;
  final VoidCallback onTap;
}

class _Sambutan extends StatelessWidget {
  const _Sambutan({required this.sapaan, required this.nama, required this.tanggal});

  final String sapaan;
  final String nama;
  final String tanggal;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: WarnaPermo.gradienLatar),
        child: Stack(
          children: [
            Positioned(
              right: -16,
              bottom: -28,
              child: Icon(Icons.eco, size: 170, color: Colors.white.withValues(alpha: 0.14)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today, size: 14, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          tanggal,
                          style: tema.labelMedium?.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '$sapaan,',
                    style: tema.titleMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.95),
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: Text(
                      nama,
                      key: ValueKey(nama),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tema.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Selamat datang di Permo, teman belajar bertani dan bercocok tanam.',
                    style: tema.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.95),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KartuMenu extends StatelessWidget {
  const _KartuMenu({required this.data, required this.tinggi});

  final _DataKartu data;
  final double tinggi;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return SizedBox(
      height: tinggi,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: data.warna,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: data.warna.last.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: data.onTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Stack(
                children: [
                  Positioned(
                    right: -18,
                    bottom: -22,
                    child: Icon(
                      data.ikon,
                      size: 130,
                      color: Colors.white.withValues(alpha: 0.16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.22),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(data.ikon, color: Colors.white),
                            ),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.judul,
                              style: tema.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data.keterangan,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: tema.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.95),
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}