import 'package:flutter/material.dart';
import '../api/klien_api.dart';
import '../layanan/cuaca.dart';
import '../model/rekomendasi.dart';
import '../tema.dart';
import '../widget/isian.dart';
import '../widget/kotak_pesan.dart';
import 'dart:async';
import 'detail_tumbuhan.dart';

String _f(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toString();

double? _angka(String s) => double.tryParse(s.trim().replaceAll(',', '.'));

class HalamanRekomendasi extends StatefulWidget {
  const HalamanRekomendasi({super.key});

  @override
  State<HalamanRekomendasi> createState() => _HalamanRekomendasiState();
}

class _HalamanRekomendasiState extends State<HalamanRekomendasi> {
    final _suhu = TextEditingController();
  final _lembab = TextEditingController();

  bool _bekerja = false;
  bool _otomatis = false; // true = mengikuti lokasi dan diperbarui berkala
  String _langkah = '';
  String? _galat;
  String? _info;
  String? _daerah; // mis. "Kecamatan X, Kabupaten Y, Provinsi, Indonesia"
  String? _kunciDaerah; // koordinat terakhir yang namanya sudah dicari
  String? _kondisi;
  List<Rekomendasi>? _hasil;
  Timer? _pewaktu;

  @override
  void initState() {
    super.initState();
    _mulaiOtomatis();
  }

  @override
  void dispose() {
    _pewaktu?.cancel();
    _suhu.dispose();
    _lembab.dispose();
    super.dispose();
  }

  // Bila izin lokasi sudah pernah diberikan, langsung jalan tanpa menekan tombol
  Future<void> _mulaiOtomatis() async {
    if (await LayananCuaca.sudahDiizinkan() && mounted) {
      _pakaiLokasi();
    }
  }

  Future<void> _jalankan(Future<void> Function() kerja, {bool senyap = false}) async {
    if (!senyap) {
      setState(() {
        _bekerja = true;
        _galat = null;
      });
    }
    try {
      await kerja();
    } on ApiGalat catch (e) {
      if (e.status == 401 && mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/masuk', (_) => false);
        return;
      }
      if (!senyap && mounted) setState(() => _galat = e.pesan);
    } catch (_) {
      if (!senyap && mounted) setState(() => _galat = 'Terjadi kesalahan. Coba lagi.');
    } finally {
      if (!senyap && mounted) setState(() => _bekerja = false);
    }
  }

  Future<void> _ambilRekomendasi(double s, double l) async {
    if (mounted) setState(() => _langkah = 'Mencari tanaman yang cocok…');
    final data = await KlienApi.kirim(
      'GET',
      '/api/rekomendasi?suhu=$s&kelembapan=$l',
      pakaiToken: true,
    ) as List;
    final hasil = data.map((e) => Rekomendasi.dariJson(e as Map<String, dynamic>)).toList();
    if (mounted) {
      setState(() {
        _hasil = hasil;
        _kondisi = 'suhu ${_f(s)} °C dan kelembapan ${_f(l)} %';
      });
    }
  }

  void _pakaiLokasi({bool senyap = false}) {
    if (!senyap) _otomatis = true;
    _jalankan(() async {
      if (!senyap) setState(() => _langkah = 'Mengambil lokasi…');
      final pos = await LayananCuaca.lokasi();
      if (!mounted || (senyap && !_otomatis)) return;
      if (!senyap) setState(() => _langkah = 'Mengambil data cuaca…');
      final c = await LayananCuaca.ambil(pos.latitude, pos.longitude);
      // Pengguna beralih ke isian manual saat pembaruan senyap berjalan: jangan menimpa
      if (!mounted || (senyap && !_otomatis)) return;
      final s = double.parse(c.suhu.toStringAsFixed(1));
      final l = c.kelembapan.roundToDouble();
      _suhu.text = _f(s);
      _lembab.text = _f(l);
      setState(() => _info =
          'Cuaca saat ini: ${_f(s)} °C, kelembapan udara ${_f(l)} %. '
          'Diperbarui otomatis tiap 15 menit.');
      unawaited(_cariDaerah(pos.latitude, pos.longitude)); // tidak menghambat rekomendasi
      await _ambilRekomendasi(s, l);
      // Berhasil sekali: jadwalkan pembaruan berkala
      _pewaktu ??= Timer.periodic(const Duration(minutes: 15), (_) {
        if (mounted && _otomatis && !_bekerja) _pakaiLokasi(senyap: true);
      });
    }, senyap: senyap);
  }

  Future<void> _cariDaerah(double lat, double lon) async {
    final kunci = '${lat.toStringAsFixed(3)},${lon.toStringAsFixed(3)}';
    if (kunci == _kunciDaerah) return; // lokasi sama, nama sudah ada
    if (mounted) setState(() => _daerah = null); // lokasi berubah: jangan tampilkan nama lama
    final nama = await LayananCuaca.namaDaerah(lat, lon);
    if (!mounted || !_otomatis) return;
    if (nama != null) {
      _kunciDaerah = kunci;
      setState(() => _daerah = nama);
    }
  }

  void _cariManual() {
    final s = _angka(_suhu.text);
    final l = _angka(_lembab.text);
    if (s == null || l == null) {
      setState(() => _galat = 'Isi suhu dan kelembapan dengan angka.');
      return;
    }
    if (s < -10 || s > 60) {
      setState(() => _galat = 'Suhu harus antara -10 dan 60 °C.');
      return;
    }
    if (l < 0 || l > 100) {
      setState(() => _galat = 'Kelembapan harus antara 0 dan 100 %.');
      return;
    }
    _otomatis = false; // isian manual: hentikan pembaruan otomatis
    setState(() {
      _info = null;
      _daerah = null;
      _kunciDaerah = null;
    });
    _jalankan(() => _ambilRekomendasi(s, l));
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    final hasil = _hasil;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: WarnaPermo.gradienLatar,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rekomendasi Tanam',
                    style: tema.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tanaman yang cocok menurut suhu dan kelembapan udara saat ini di lokasimu.',
                    style: tema.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.95)),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _bekerja ? null : _pakaiLokasi,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: WarnaPermo.hijauTua,
                    ),
                    icon: const Icon(Icons.my_location),
                    label: const Text('Gunakan Lokasi Saya'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_info != null) ...[
              _KartuCuaca(daerah: _daerah, info: _info!),
              const SizedBox(height: 16),
            ],
            Text('Atau isi sendiri', style: tema.labelLarge),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _suhu,
                    enabled: !_bekerja,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    decoration: dekorasiIsian('Suhu (°C)', Icons.thermostat),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _lembab,
                    enabled: !_bekerja,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: dekorasiIsian('Kelembapan (%)', Icons.water_drop_outlined),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: _bekerja ? null : _cariManual,
              icon: const Icon(Icons.search),
              label: const Text('Cari Rekomendasi'),
            ),
            if (_bekerja) ...[
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                  const SizedBox(width: 12),
                  Flexible(child: Text(_langkah)),
                ],
              ),
            ],
            if (_galat != null) ...[
              const SizedBox(height: 16),
              KotakPesan(teks: _galat!),
            ],
            if (hasil != null) ...[
              const SizedBox(height: 20),
              Text(
                hasil.isEmpty
                    ? 'Tidak ada tanaman yang cocok untuk $_kondisi.'
                    : '${hasil.length} tanaman cocok untuk $_kondisi',
                style: tema.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              for (final r in hasil) _KartuRekomendasi(r),
            ],
          ],
        ),
      ),
    );
  }
}

class _KartuRekomendasi extends StatelessWidget {
  const _KartuRekomendasi(this.r);

  final Rekomendasi r;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(top: 8),
      color: const Color(0xFFF1F7F4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => HalamanDetailTumbuhan(tumbuhan: r.tumbuhan)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: WarnaPermo.hijau.withValues(alpha: 0.25),
                    child: const Icon(Icons.eco, color: WarnaPermo.hijauTua),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      r.nama,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _Label(Icons.thermostat, 'Suhu ${_f(r.suhuMin)}–${_f(r.suhuMax)} °C'),
                  _Label(Icons.cloud_outlined, 'Udara ${_f(r.udaraMin)}–${_f(r.udaraMax)} %'),
                  _Label(Icons.grass,
                      'Lembap tanah ${_f(r.lembabTanahMin)}–${_f(r.lembabTanahMax)} %'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.ikon, this.teks);

  final IconData ikon;
  final String teks;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(ikon, size: 18, color: WarnaPermo.hijauTua),
      label: Text(teks),
      backgroundColor: Colors.white,
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _KartuCuaca extends StatelessWidget {
  const _KartuCuaca({required this.daerah, required this.info});

  final String? daerah;
  final String info;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: WarnaPermo.hijau.withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.place, color: WarnaPermo.hijauTua),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (daerah != null) ...[
                    Text(
                      daerah!,
                      style: tema.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(info, style: tema.bodyMedium),
                  const SizedBox(height: 6),
                  Text(
                    'Cuaca: Open-Meteo · Nama daerah: © kontributor OpenStreetMap',
                    style: tema.labelSmall,
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