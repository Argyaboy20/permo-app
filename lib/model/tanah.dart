class Tanah {
  const Tanah({
    required this.id,
    required this.nama,
    required this.karakteristik,
    required this.tumbuhan,
    required this.penyebaran,
    required this.unsurPh,
  });

  final int id;
  final String nama;
  final String karakteristik;
  final String tumbuhan;
  final String penyebaran;
  final String unsurPh;

  factory Tanah.dariJson(Map<String, dynamic> j) => Tanah(
        id: (j['id'] as num).toInt(),
        nama: j['tanah'] as String,
        karakteristik: j['karakteristik'] as String,
        tumbuhan: j['tumbuhan'] as String,
        penyebaran: j['penyebaran'] as String,
        unsurPh: j['unsur_ph'] as String,
      );
}