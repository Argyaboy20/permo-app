class Tumbuhan {
  const Tumbuhan({
    required this.id,
    required this.nama,
    required this.suhu,
    required this.tanah,
    required this.sinarMatahari,
    required this.air,
  });

  final int id;
  final String nama;
  final String suhu;
  final String tanah;
  final String sinarMatahari;
  final String air;

  factory Tumbuhan.dariJson(Map<String, dynamic> j) => Tumbuhan(
        id: (j['id'] as num).toInt(),
        nama: j['tumbuhan'] as String,
        suhu: j['suhu'] as String,
        tanah: j['tanah'] as String,
        sinarMatahari: j['sinar_matahari'] as String,
        air: j['air'] as String,
      );
}