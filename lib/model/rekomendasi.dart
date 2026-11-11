import 'tumbuhan.dart';

class Rekomendasi {
  const Rekomendasi({
    required this.id,
    required this.nama,
    required this.suhuMin,
    required this.suhuMax,
    required this.udaraMin,
    required this.udaraMax,
    required this.lembabTanahMin,
    required this.lembabTanahMax,
    required this.suhu,
    required this.tanah,
    required this.sinarMatahari,
    required this.air,
  });

  final int id;
  final String nama;
  final double suhuMin;
  final double suhuMax;
  final double udaraMin;
  final double udaraMax;
  final double lembabTanahMin;
  final double lembabTanahMax;
  final String suhu;
  final String tanah;
  final String sinarMatahari;
  final String air;

  /// Data Kamus lengkap untuk halaman detail (id sama dengan id di Kamus).
  Tumbuhan get tumbuhan => Tumbuhan(
        id: id,
        nama: nama,
        suhu: suhu,
        tanah: tanah,
        sinarMatahari: sinarMatahari,
        air: air,
      );

  factory Rekomendasi.dariJson(Map<String, dynamic> j) => Rekomendasi(
        id: (j['id'] as num).toInt(),
        nama: j['tumbuhan'] as String,
        suhuMin: (j['suhu_min'] as num).toDouble(),
        suhuMax: (j['suhu_max'] as num).toDouble(),
        udaraMin: (j['udara_min'] as num).toDouble(),
        udaraMax: (j['udara_max'] as num).toDouble(),
        lembabTanahMin: (j['lembab_tanah_min'] as num).toDouble(),
        lembabTanahMax: (j['lembab_tanah_max'] as num).toDouble(),
        suhu: j['suhu'] as String,
        tanah: j['tanah'] as String,
        sinarMatahari: j['sinar_matahari'] as String,
        air: j['air'] as String,
      );
}