import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../api/klien_api.dart';
import '../tema.dart';

class PesanChat {
  PesanChat({
    required this.dariAi,
    required this.teks,
    DateTime? waktu,
    this.galat = false,
    this.bisaUlang = false,
  }) : waktu = waktu ?? DateTime.now();

  final bool dariAi;
  final String teks;
  final DateTime waktu;
  final bool galat;
  final bool bisaUlang;
}

/// Menyimpan percakapan dan mengurus permintaan ke server, terlepas dari halamannya,
/// sehingga obrolan tidak hilang saat halaman ditutup dan dibuka lagi.
class RuangChat extends ChangeNotifier {
  RuangChat._();
  static final RuangChat ini = RuangChat._();

  final List<PesanChat> pesan = [];
  bool menunggu = false;
  bool lambat = false;
  bool sesiHabis = false;
  int? sisa;
  String? _hariSisa;
  int? pemilik;
  Timer? _pewaktu;
  int _generasi = 0;

  static String _hariIni() {
    final n = DateTime.now();
    return '${n.year}-${n.month}-${n.day}';
  }

  /// Sisa pertanyaan hari ini; kembali tidak diketahui bila harinya sudah berganti.
  int? sisaSekarang() {
    if (sisa != null && _hariSisa != _hariIni()) {
      sisa = null;
    }
    return sisa;
  }

  void _catatSisa(int nilai) {
    sisa = nilai;
    _hariSisa = _hariIni();
  }

  void _bersihkanPercakapan() {
    _generasi++;
    _pewaktu?.cancel();
    pesan.clear();
    menunggu = false;
    lambat = false;
  }

  /// Menghapus semuanya (dipakai saat keluar akun).
  void hapus() {
    _bersihkanPercakapan();
    sisa = null;
    _hariSisa = null;
    pemilik = null;
    sesiHabis = false;
    notifyListeners();
  }

  void mulaiBaru() {
    _bersihkanPercakapan();
    notifyListeners();
  }

  /// Percakapan milik akun lain dibuang.
  void pastikanPemilik(int? id) {
    if (id != null && pemilik != id) {
      hapus();
      pemilik = id;
    }
  }

  void kirim(String teks) {
    if (menunggu || sisaSekarang() == 0) return;
    pesan.add(PesanChat(dariAi: false, teks: teks));
    notifyListeners();
    _minta();
  }

  void ulangi() {
    if (menunggu || pesan.isEmpty || !pesan.last.galat) return;
    pesan.removeLast();
    notifyListeners();
    _minta();
  }

  Future<void> _minta() async {
    final gen = _generasi;
    final terakhir = pesan.last;
    final sebelum = pesan.sublist(0, pesan.length - 1).where((p) => !p.galat).toList();
    final mulai = sebelum.length > 10 ? sebelum.length - 10 : 0;
    final riwayat = <Map<String, String>>[
      for (final p in sebelum.sublist(mulai))
        {'peran': p.dariAi ? 'ai' : 'user', 'teks': p.teks},
    ];

    menunggu = true;
    lambat = false;
    notifyListeners();
    _pewaktu?.cancel();
    _pewaktu = Timer(const Duration(seconds: 6), () {
      if (menunggu && gen == _generasi) {
        lambat = true;
        notifyListeners();
      }
    });

    try {
      final data = await KlienApi.kirim(
        'POST',
        '/api/ai',
        pakaiToken: true,
        isi: {'pesan': terakhir.teks, 'riwayat': riwayat},
      ) as Map<String, dynamic>;
      if (gen != _generasi) return;
      final jawaban = (data['jawaban'] as String?)?.trim() ?? '';
      if (data['sisa'] is num) _catatSisa((data['sisa'] as num).toInt());
      pesan.add(PesanChat(
        dariAi: true,
        teks: jawaban.isEmpty
            ? 'Permo AI tidak memberi jawaban. Coba ajukan pertanyaan dengan cara lain.'
            : jawaban,
      ));
    } on ApiGalat catch (e) {
      if (gen != _generasi) return;
      if (e.status == 401) {
        sesiHabis = true;
      } else {
        final habis = e.status == 429 && e.pesan.contains('sudah habis');
        if (habis) _catatSisa(0);
        pesan.add(PesanChat(dariAi: true, teks: e.pesan, galat: true, bisaUlang: !habis));
      }
    } catch (_) {
      if (gen != _generasi) return;
      pesan.add(PesanChat(
        dariAi: true,
        teks: 'Jawaban tidak dapat dibaca dari server.',
        galat: true,
        bisaUlang: true,
      ));
    } finally {
      if (gen == _generasi) {
        _pewaktu?.cancel();
        menunggu = false;
        lambat = false;
        notifyListeners();
      }
    }
  }
}

String _jam(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

class HalamanPermoAI extends StatefulWidget {
  const HalamanPermoAI({super.key, this.penggunaId});

  /// Dipakai untuk membuang percakapan milik akun lain di perangkat yang sama.
  final int? penggunaId;

  @override
  State<HalamanPermoAI> createState() => _HalamanPermoAIState();
}

class _HalamanPermoAIState extends State<HalamanPermoAI> {
  final _isian = TextEditingController();
  final _fokus = FocusNode();
  final _gulir = ScrollController();

  @override
  void initState() {
    super.initState();
    RuangChat.ini.pastikanPemilik(widget.penggunaId);
    RuangChat.ini.addListener(_berubah);
    _gulirKeBawah(langsung: true);
  }

  @override
  void dispose() {
    RuangChat.ini.removeListener(_berubah);
    _isian.dispose();
    _fokus.dispose();
    _gulir.dispose();
    super.dispose();
  }

  void _berubah() {
    if (!mounted) return;
    if (RuangChat.ini.sesiHabis) {
      RuangChat.ini.hapus();
      Navigator.of(context).pushNamedAndRemoveUntil('/masuk', (_) => false);
      return;
    }
    setState(() {});
    _gulirKeBawah();
  }

  void _gulirKeBawah({bool langsung = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_gulir.hasClients) return;
      final akhir = _gulir.position.maxScrollExtent;
      if (langsung) {
        _gulir.jumpTo(akhir);
      } else {
        _gulir.animateTo(
          akhir,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _kirimDariIsian() {
    final teks = _isian.text.trim();
    final ruang = RuangChat.ini;
    if (teks.isEmpty || ruang.menunggu || ruang.sisaSekarang() == 0) return;
    _isian.clear();
    ruang.kirim(teks);
    _fokus.requestFocus();
    setState(() {});
  }

  Future<void> _baru() async {
    if (RuangChat.ini.pesan.isEmpty) return;
    final ya = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mulai percakapan baru?'),
        content: const Text('Percakapan yang sekarang akan dihapus.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Mulai baru')),
        ],
      ),
    );
    if (ya == true) RuangChat.ini.mulaiBaru();
  }

  Widget _daftarPesan() {
    final ruang = RuangChat.ini;
    final jumlah = ruang.pesan.length + (ruang.menunggu ? 1 : 0);
    return ListView.builder(
      controller: _gulir,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      itemCount: jumlah,
      itemBuilder: (context, i) {
        if (i >= ruang.pesan.length) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _GelembungMengetik(lambat: ruang.lambat),
          );
        }
        final p = ruang.pesan[i];
        final galatTerakhir = p.galat && i == ruang.pesan.length - 1 && !ruang.menunggu;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _Gelembung(
            pesan: p,
            bisaUlang: galatTerakhir && p.bisaUlang,
            onUlang: ruang.ulangi,
          ),
        );
      },
    );
  }

  Widget _tombolKirim(bool aktif) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFB9CFC3),
          gradient: aktif ? WarnaPermo.gradienLatar : null,
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: aktif ? _kirimDariIsian : null,
          child: const Icon(Icons.arrow_upward_rounded, color: Colors.white),
        ),
      ),
    );
  }

  Widget _barisKetik(int? sisa) {
    final tema = Theme.of(context).textTheme;
    final aktif = _isian.text.trim().isNotEmpty && !RuangChat.ini.menunggu && sisa != 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _isian,
                      focusNode: _fokus,
                      enabled: sisa != 0,
                      minLines: 1,
                      maxLines: 5,
                      maxLength: 1000,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.send,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (_) => _kirimDariIsian(),
                      buildCounter: (context,
                              {required currentLength, required isFocused, required maxLength}) =>
                          currentLength >= 800 ? Text('$currentLength/$maxLength') : null,
                      decoration: InputDecoration(
                        hintText: sisa == 0
                            ? 'Batas pertanyaan hari ini tercapai'
                            : 'Tanya seputar pertanian…',
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.95),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(26),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: _tombolKirim(aktif),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Permo AI bisa keliru. Periksa kembali informasi penting.',
                textAlign: TextAlign.center,
                style: tema.labelSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ruang = RuangChat.ini;
    final sisa = ruang.sisaSekarang();
    final kosong = ruang.pesan.isEmpty && !ruang.menunggu;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            const _AvatarAi(ukuran: 36),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Permo AI',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                    color: WarnaPermo.hijauTua,
                  ),
                ),
                Text(
                  sisa == null ? 'Asisten pertanian' : 'Sisa $sisa pertanyaan hari ini',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF4A6B58)),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Percakapan baru',
            icon: const Icon(Icons.add_comment_outlined),
            onPressed: _baru,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: kosong
                  ? _Sambutan(onPilih: ruang.kirim)
                  : Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: _daftarPesan(),
                      ),
                    ),
            ),
            _barisKetik(sisa),
          ],
        ),
      ),
    );
  }
}

class _AvatarAi extends StatelessWidget {
  const _AvatarAi({this.ukuran = 28});

  final double ukuran;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ukuran,
      height: ukuran,
      decoration: BoxDecoration(gradient: WarnaPermo.gradienLatar, shape: BoxShape.circle),
      child: Icon(Icons.auto_awesome, size: ukuran * 0.55, color: Colors.white),
    );
  }
}

class _Sambutan extends StatelessWidget {
  const _Sambutan({required this.onPilih});

  final void Function(String) onPilih;

  static const _contoh = [
    'Tanaman apa yang cocok ditanam di dataran rendah yang panas?',
    'Bagaimana cara mengenali tanah yang terlalu masam?',
    'Kapan waktu terbaik menanam cabai?',
    'Apa bedanya tanah aluvial dan andosol?',
    'Bagaimana cara membuat pupuk kompos sendiri?',
  ];

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _AvatarAi(ukuran: 72),
              const SizedBox(height: 16),
              Text(
                'Halo, aku Permo AI',
                style: tema.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: WarnaPermo.hijauTua,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tanyakan apa saja seputar pertanian: tanaman, tanah, hama dan penyakit, '
                'pupuk, irigasi, sampai waktu tanam.',
                textAlign: TextAlign.center,
                style: tema.bodyMedium?.copyWith(height: 1.45),
              ),
              const SizedBox(height: 22),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Coba tanyakan', style: tema.labelLarge),
              ),
              const SizedBox(height: 8),
              for (final c in _contoh)
                Card(
                  elevation: 0,
                  clipBehavior: Clip.antiAlias,
                  margin: const EdgeInsets.only(bottom: 8),
                  color: Colors.white.withValues(alpha: 0.85),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  child: ListTile(
                    dense: true,
                    leading: const Icon(Icons.lightbulb_outline, color: WarnaPermo.hijauTua),
                    title: Text(c, maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: const Icon(Icons.arrow_upward_rounded, size: 18),
                    onTap: () => onPilih(c),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Gelembung extends StatelessWidget {
  const _Gelembung({required this.pesan, required this.bisaUlang, required this.onUlang});

  final PesanChat pesan;
  final bool bisaUlang;
  final VoidCallback onUlang;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    final lebar = MediaQuery.sizeOf(context).width;
    final maks = (lebar > 760 ? 760.0 : lebar) * 0.82;

    if (!pesan.dariAi) {
      return Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maks),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: WarnaPermo.gradienLatar,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(6),
                  ),
                ),
                child: Text(
                  pesan.teks,
                  style: tema.bodyLarge?.copyWith(color: Colors.white, height: 1.4),
                ),
              ),
              const SizedBox(height: 4),
              Text(_jam(pesan.waktu), style: tema.labelSmall),
            ],
          ),
        ),
      );
    }

    final galat = pesan.galat;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _AvatarAi(),
        const SizedBox(width: 8),
        Flexible(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maks),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: galat ? const Color(0xFFFDECEA) : Colors.white.withValues(alpha: 0.92),
                    border: Border.all(
                      color: galat ? const Color(0xFFE57373) : const Color(0x1F2E7D55),
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: galat
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.error_outline, size: 20, color: Color(0xFFC62828)),
                            const SizedBox(width: 8),
                            Expanded(child: Text(pesan.teks, style: tema.bodyMedium)),
                          ],
                        )
                      : SelectableText(
                          pesan.teks,
                          style: tema.bodyLarge?.copyWith(height: 1.5),
                        ),
                ),
                if (galat && bisaUlang)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: FilledButton.tonalIcon(
                      onPressed: onUlang,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba lagi'),
                    ),
                  )
                else if (!galat)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _TombolSalin(pesan.teks),
                        const SizedBox(width: 10),
                        Text(_jam(pesan.waktu), style: tema.labelSmall),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _GelembungMengetik extends StatefulWidget {
  const _GelembungMengetik({required this.lambat});

  final bool lambat;

  @override
  State<_GelembungMengetik> createState() => _GelembungMengetikState();
}

class _GelembungMengetikState extends State<_GelembungMengetik>
    with SingleTickerProviderStateMixin {
  late final AnimationController _kontrol =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();

  @override
  void dispose() {
    _kontrol.dispose();
    super.dispose();
  }

  Widget _titik(int i) {
    final t = ((_kontrol.value - i * 0.18) % 1.0 + 1.0) % 1.0;
    final naik = t < 0.5 ? t * 2 : (1 - t) * 2;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Transform.translate(
        offset: Offset(0, -4 * naik),
        child: Opacity(
          opacity: 0.35 + 0.65 * naik,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: WarnaPermo.hijauTua,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _AvatarAi(),
        const SizedBox(width: 8),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              border: Border.all(color: const Color(0x1F2E7D55)),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedBuilder(
                  animation: _kontrol,
                  builder: (context, _) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [for (var i = 0; i < 3; i++) _titik(i)],
                  ),
                ),
                if (widget.lambat)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Mohon tunggu…',
                      style: tema.labelMedium,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TombolSalin extends StatefulWidget {
  const _TombolSalin(this.teks);

  final String teks;

  @override
  State<_TombolSalin> createState() => _TombolSalinState();
}

class _TombolSalinState extends State<_TombolSalin> {
  bool _sudah = false;

  Future<void> _salin() async {
    await Clipboard.setData(ClipboardData(text: widget.teks));
    if (!mounted) return;
    setState(() => _sudah = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) setState(() => _sudah = false);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: _salin,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_sudah ? Icons.check : Icons.copy_rounded, size: 16, color: WarnaPermo.hijauTua),
            const SizedBox(width: 4),
            Text(
              _sudah ? 'Disalin' : 'Salin',
              style: const TextStyle(fontSize: 12, color: WarnaPermo.hijauTua),
            ),
          ],
        ),
      ),
    );
  }
}