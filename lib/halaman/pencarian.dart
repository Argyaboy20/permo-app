import 'package:flutter/material.dart';
import '../api/klien_api.dart';
import '../model/tanah.dart';
import '../model/tumbuhan.dart';
import '../tema.dart';
import '../widget/pemuat_data.dart';
import 'detail_tanah.dart';
import 'detail_tumbuhan.dart';

class _DataCari {
  const _DataCari(this.tumbuhan, this.tanah);

  final List<Tumbuhan> tumbuhan;
  final List<Tanah> tanah;
}

// Disimpan selama aplikasi terbuka agar pencarian berikutnya tidak memuat ulang
_DataCari? _simpanan;

Future<_DataCari> _ambilSemua() async {
  final ada = _simpanan;
  if (ada != null) return ada;
  final hasil = await Future.wait<dynamic>([
    KlienApi.kirim('GET', '/api/kamus', pakaiToken: true),
    KlienApi.kirim('GET', '/api/tanah', pakaiToken: true),
  ]);
  final data = _DataCari(
    (hasil[0] as List).map((e) => Tumbuhan.dariJson(e as Map<String, dynamic>)).toList(),
    (hasil[1] as List).map((e) => Tanah.dariJson(e as Map<String, dynamic>)).toList(),
  );
  _simpanan = data;
  return data;
}

class _Bidang {
  const _Bidang(this.label, this.teks);

  final String label;
  final String teks;
}

class _Hasil {
  const _Hasil({
    required this.jenis,
    required this.nama,
    required this.skor,
    required this.label,
    required this.teks,
    required this.halaman,
  });

  final String jenis;
  final String nama;
  final int skor;
  final String label;
  final String teks;
  final Widget Function() halaman;
}

/// saring: 0 = semua, 1 = hanya Kamus, 2 = hanya Ilmu Tanah
List<_Hasil> _cari(_DataCari d, List<String> kunci, int saring) {
  final hasil = <_Hasil>[];

  void periksa(String jenis, String nama, List<_Bidang> bidang, Widget Function() halaman) {
    final namaKecil = nama.toLowerCase();
    final gabung = '$namaKecil ${bidang.map((b) => b.teks.toLowerCase()).join(' ')}';
    if (!kunci.every((k) => gabung.contains(k))) return;

    var skor = 0;
    for (final k in kunci) {
      if (namaKecil.startsWith(k)) {
        skor += 100;
      } else if (namaKecil.contains(k)) {
        skor += 60;
      } else {
        skor += 10;
      }
    }

    var pilih = bidang.first;
    for (final b in bidang) {
      if (kunci.any((k) => b.teks.toLowerCase().contains(k))) {
        pilih = b;
        break;
      }
    }
    hasil.add(_Hasil(
      jenis: jenis,
      nama: nama,
      skor: skor,
      label: pilih.label,
      teks: pilih.teks,
      halaman: halaman,
    ));
  }

  if (saring != 2) {
    for (final t in d.tumbuhan) {
      periksa(
        'Kamus',
        t.nama,
        [
          _Bidang('Suhu', t.suhu),
          _Bidang('Tanah', t.tanah),
          _Bidang('Sinar matahari', t.sinarMatahari),
          _Bidang('Air', t.air),
        ],
        () => HalamanDetailTumbuhan(tumbuhan: t),
      );
    }
  }
  if (saring != 1) {
    for (final t in d.tanah) {
      periksa(
        'Ilmu Tanah',
        t.nama,
        [
          _Bidang('Karakteristik', t.karakteristik),
          _Bidang('Tumbuhan', t.tumbuhan),
          _Bidang('Penyebaran', t.penyebaran),
          _Bidang('pH', t.unsurPh),
        ],
        () => HalamanDetailTanah(tanah: t),
      );
    }
  }

  hasil.sort((a, b) => b.skor != a.skor ? b.skor.compareTo(a.skor) : a.nama.compareTo(b.nama));
  return hasil.length > 80 ? hasil.sublist(0, 80) : hasil;
}

/// Memotong teks di sekitar kecocokan pertama dan menebalkan kata yang dicari.
List<TextSpan> _sorot(String teks, List<String> kunci, TextStyle tebal) {
  final kecil = teks.toLowerCase();
  if (kecil.length != teks.length) {
    return [TextSpan(text: teks.length > 110 ? '${teks.substring(0, 110)}…' : teks)];
  }

  var pos = -1;
  var panjang = 0;
  for (final k in kunci) {
    final i = kecil.indexOf(k);
    if (i >= 0 && (pos < 0 || i < pos)) {
      pos = i;
      panjang = k.length;
    }
  }

  var awal = 0;
  var akhir = teks.length > 110 ? 110 : teks.length;
  if (pos >= 0) {
    awal = pos - 35 < 0 ? 0 : pos - 35;
    akhir = pos + panjang + 70 > teks.length ? teks.length : pos + panjang + 70;
  }

  final seg = teks.substring(awal, akhir);
  final segKecil = kecil.substring(awal, akhir);
  final spans = <TextSpan>[];
  if (awal > 0) spans.add(const TextSpan(text: '…'));

  var kursor = 0;
  while (kursor < seg.length) {
    var ketemu = -1;
    var pj = 0;
    for (final k in kunci) {
      final i = segKecil.indexOf(k, kursor);
      if (i >= 0 && (ketemu < 0 || i < ketemu)) {
        ketemu = i;
        pj = k.length;
      }
    }
    if (ketemu < 0) {
      spans.add(TextSpan(text: seg.substring(kursor)));
      break;
    }
    if (ketemu > kursor) spans.add(TextSpan(text: seg.substring(kursor, ketemu)));
    spans.add(TextSpan(text: seg.substring(ketemu, ketemu + pj), style: tebal));
    kursor = ketemu + pj;
  }

  if (akhir < teks.length) spans.add(const TextSpan(text: '…'));
  return spans;
}

class HalamanPencarian extends StatefulWidget {
  const HalamanPencarian({super.key});

  @override
  State<HalamanPencarian> createState() => _HalamanPencarianState();
}

class _HalamanPencarianState extends State<HalamanPencarian> {
  final _isian = TextEditingController();
  String _kata = '';
  int _saring = 0;

  @override
  void dispose() {
    _isian.dispose();
    super.dispose();
  }

  Widget _chip(String label, int nilai) {
    return ChoiceChip(
      label: Text(label),
      selected: _saring == nilai,
      onSelected: (_) => setState(() => _saring = nilai),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        title: TextField(
          controller: _isian,
          autofocus: true,
          textInputAction: TextInputAction.search,
          style: const TextStyle(fontSize: 18),
          onChanged: (v) => setState(() => _kata = v),
          decoration: const InputDecoration(
            hintText: 'Cari di Kamus dan Ilmu Tanah…',
            border: InputBorder.none,
          ),
        ),
        actions: [
          if (_kata.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _isian.clear();
                setState(() => _kata = '');
              },
            ),
        ],
      ),
      body: PemuatData<_DataCari>(
        ambil: _ambilSemua,
        bangun: (context, data) {
          final kunci = _kata
              .trim()
              .toLowerCase()
              .split(RegExp(r'\s+'))
              .where((k) => k.isNotEmpty)
              .toList();
          final hasil = kunci.isEmpty ? <_Hasil>[] : _cari(data, kunci, _saring);

          Widget isi;
          if (kunci.isEmpty) {
            isi = Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search, size: 56, color: WarnaPermo.hijau.withValues(alpha: 0.8)),
                    const SizedBox(height: 12),
                    Text(
                      'Ketik kata kunci untuk mencari di Kamus dan Ilmu Tanah',
                      textAlign: TextAlign.center,
                      style: tema.titleSmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Contoh: padi, gembur, pH 6, pantai',
                      textAlign: TextAlign.center,
                      style: tema.bodyMedium,
                    ),
                  ],
                ),
              ),
            );
          } else if (hasil.isEmpty) {
            isi = Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'Tidak ada hasil untuk "${_kata.trim()}".',
                  textAlign: TextAlign.center,
                  style: tema.titleSmall,
                ),
              ),
            );
          } else {
            isi = ListView.builder(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: hasil.length + 1,
              itemBuilder: (context, i) {
                if (i == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 2),
                    child: Text('${hasil.length} hasil', style: tema.labelLarge),
                  );
                }
                final h = hasil[i - 1];
                return Card(
                  elevation: 0,
                  clipBehavior: Clip.antiAlias,
                  margin: const EdgeInsets.only(top: 8),
                  color: const Color(0xFFF1F7F4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => h.halaman()),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: WarnaPermo.hijau.withValues(alpha: 0.25),
                            child: Icon(
                              h.jenis == 'Kamus' ? Icons.eco : Icons.terrain,
                              color: WarnaPermo.hijauTua,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        h.nama,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    _Lencana(h.jenis),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text.rich(
                                  TextSpan(
                                    style: tema.bodyMedium,
                                    children: [
                                      TextSpan(
                                        text: '${h.label}: ',
                                        style: const TextStyle(fontWeight: FontWeight.w700),
                                      ),
                                      ..._sorot(
                                        h.teks,
                                        kunci,
                                        const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          backgroundColor: Color(0x556FB98F),
                                        ),
                                      ),
                                    ],
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8,
                        children: [
                          _chip('Semua', 0),
                          _chip('Kamus', 1),
                          _chip('Ilmu Tanah', 2),
                        ],
                      ),
                    ),
                  ),
                  Expanded(child: isi),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Lencana extends StatelessWidget {
  const _Lencana(this.jenis);

  final String jenis;

  @override
  Widget build(BuildContext context) {
    final warna = jenis == 'Kamus' ? const Color(0xFF2F8F63) : const Color(0xFF7A5634);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: warna.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        jenis,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: warna),
      ),
    );
  }
}