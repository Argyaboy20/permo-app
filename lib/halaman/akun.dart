import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../api/klien_api.dart';
import '../model/pengguna.dart';
import '../tema.dart';
import '../widget/isian.dart';
import '../widget/kerangka_halaman.dart';
import '../widget/kotak_pesan.dart';
import '../widget/pemuat_data.dart';
import '../sesi.dart';
import 'permo_ai.dart';

class HalamanAkun extends StatelessWidget {
  const HalamanAkun({super.key, required this.onDiubah});

  /// Dipanggil setelah data berhasil disimpan, agar sapaan dan menu ikut diperbarui.
  final void Function(Pengguna) onDiubah;

  Future<Pengguna> _ambil() async {
    final data = await KlienApi.kirim('GET', '/api/saya', pakaiToken: true);
    return Pengguna.dariJson(data as Map<String, dynamic>);
  }

  @override
  Widget build(BuildContext context) {
    return KerangkaHalaman(
      judul: 'Akun',
      isi: PemuatData<Pengguna>(
        ambil: _ambil,
        bangun: (context, p) => _FormAkun(awal: p, onDiubah: onDiubah),
      ),
    );
  }
}

class _FormAkun extends StatefulWidget {
  const _FormAkun({required this.awal, required this.onDiubah});

  final Pengguna awal;
  final void Function(Pengguna) onDiubah;

  @override
  State<_FormAkun> createState() => _FormAkunState();
}

class _FormAkunState extends State<_FormAkun> {
  static final _polaUsername = RegExp(r'^[a-zA-Z0-9]{7,35}$');
  static final _polaEmail = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  final _username = TextEditingController();
  final _email = TextEditingController();
  final _passBaru = TextEditingController();
  final _passSekarang = TextEditingController();
  final _passTampil = TextEditingController(text: '••••••••');

  late Pengguna _saat;
  bool _edit = false;
  bool _menyimpan = false;
  bool _lihatBaru = false;
  bool _lihatSekarang = false;
  String? _galat;
  String? _sukses;

  @override
  void initState() {
    super.initState();
    _saat = widget.awal;
    _isiDariSaat();
  }

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _passBaru.dispose();
    _passSekarang.dispose();
    _passTampil.dispose();
    super.dispose();
  }

  void _isiDariSaat() {
    _username.text = _saat.username;
    _email.text = _saat.email;
    _passBaru.clear();
    _passSekarang.clear();
  }

  void _tombolEdit() {
    setState(() {
      if (_edit) {
        // Batal: buang perubahan
        _edit = false;
        _isiDariSaat();
      } else {
        _edit = true;
        _sukses = null;
      }
      _galat = null;
      _lihatBaru = false;
      _lihatSekarang = false;
    });
  }

  Future<void> _simpan() async {
    final username = _username.text.trim();
    final email = _email.text.trim().toLowerCase();
    final baru = _passBaru.text;
    final sekarang = _passSekarang.text;

    String? salah;
    if (!_polaUsername.hasMatch(username)) {
      salah = 'Username 7–35 karakter, hanya huruf dan angka.';
    } else if (!_polaEmail.hasMatch(email) || email.length > 254) {
      salah = 'Format email tidak valid.';
    } else if (baru.isNotEmpty && (baru.length < 8 || baru.length > 72)) {
      salah = 'Password baru 8–72 karakter.';
    } else if (username == _saat.username && email == _saat.email && baru.isEmpty) {
      salah = 'Belum ada yang diubah.';
    } else if (sekarang.isEmpty) {
      salah = 'Isi password saat ini untuk menyimpan perubahan.';
    }
    if (salah != null) {
      setState(() {
        _galat = salah;
        _sukses = null;
      });
      return;
    }

    setState(() {
      _menyimpan = true;
      _galat = null;
      _sukses = null;
    });
    try {
      final data = await KlienApi.kirim(
        'PATCH',
        '/api/saya',
        pakaiToken: true,
        isi: {
          'username': username,
          'email': email,
          'passwordSaatIni': sekarang,
          if (baru.isNotEmpty) 'passwordBaru': baru,
        },
      );
      final p = Pengguna.dariJson(data as Map<String, dynamic>);
      if (!mounted) return;
      setState(() {
        _saat = p;
        _edit = false;
        _lihatBaru = false;
        _lihatSekarang = false;
        _isiDariSaat();
        _sukses = 'Data akun berhasil disimpan.';
      });
      widget.onDiubah(p);
    } on ApiGalat catch (e) {
      if (e.status == 401 && mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/masuk', (_) => false);
        return;
      }
      if (mounted) setState(() => _galat = e.pesan);
    } catch (_) {
      if (mounted) setState(() => _galat = 'Data tidak dapat dibaca dari server.');
    } finally {
      if (mounted) setState(() => _menyimpan = false);
    }
  }

  Future<void> _hapusAkun() async {
    final hasil = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _DialogHapusAkun(),
    );
    if (!mounted || hasil == null) return;
    if (hasil == 'habis') {
      RuangChat.ini.hapus();
      Navigator.of(context).pushNamedAndRemoveUntil('/masuk', (_) => false);
      return;
    }
    await Sesi.hapus();
    RuangChat.ini.hapus();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
  }

  Widget _mata(bool terlihat, VoidCallback ketuk) {
    return IconButton(
      icon: Icon(terlihat ? Icons.visibility_off : Icons.visibility),
      onPressed: ketuk,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    final inisial = _saat.username.isEmpty ? 'P' : _saat.username[0].toUpperCase();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: WarnaPermo.hijauTua,
                  child: Text(
                    inisial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _saat.username,
                  style: tema.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                Text(_saat.email, style: tema.bodyMedium),
              ],
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 0,
              margin: EdgeInsets.zero,
              color: const Color(0xFFF1F7F4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  alignment: Alignment.topCenter,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _username,
                        readOnly: !_edit,
                        enabled: !_menyimpan,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                          LengthLimitingTextInputFormatter(35),
                        ],
                        decoration: dekorasiIsian('Username', Icons.person_outline),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _email,
                        readOnly: !_edit,
                        enabled: !_menyimpan,
                        keyboardType: TextInputType.emailAddress,
                        decoration: dekorasiIsian('Email', Icons.mail_outline),
                      ),
                      const SizedBox(height: 14),
                      if (!_edit)
                        TextField(
                          controller: _passTampil,
                          readOnly: true,
                          decoration: dekorasiIsian('Password', Icons.lock_outline),
                        )
                      else ...[
                        TextField(
                          controller: _passBaru,
                          enabled: !_menyimpan,
                          obscureText: !_lihatBaru,
                          decoration: dekorasiIsian(
                            'Password baru (kosongkan jika tidak diubah)',
                            Icons.lock_reset,
                            akhir: _mata(_lihatBaru, () => setState(() => _lihatBaru = !_lihatBaru)),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _passSekarang,
                          enabled: !_menyimpan,
                          obscureText: !_lihatSekarang,
                          decoration: dekorasiIsian(
                            'Password saat ini (wajib untuk menyimpan)',
                            Icons.lock_outline,
                            akhir: _mata(
                              _lihatSekarang,
                              () => setState(() => _lihatSekarang = !_lihatSekarang),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Password saat ini diminta demi keamanan akunmu.',
                          style: tema.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            if (_galat != null) ...[
              const SizedBox(height: 14),
              KotakPesan(teks: _galat!),
            ],
            if (_sukses != null) ...[
              const SizedBox(height: 14),
              KotakPesan(teks: _sukses!, galat: false),
            ],
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _menyimpan ? null : _tombolEdit,
                    icon: Icon(_edit ? Icons.close : Icons.edit_outlined),
                    label: Text(_edit ? 'Batal' : 'Edit Profil'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: (_edit && !_menyimpan) ? _simpan : null,
                    icon: _menyimpan
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                          )
                        : const Icon(Icons.save_outlined),
                    label: const Text('Simpan Data'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            const Divider(),
            const SizedBox(height: 12),
            Center(
              child: OutlinedButton.icon(
                onPressed: (_menyimpan || _edit) ? null : _hapusAkun,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFC62828),
                  side: const BorderSide(color: Color(0xFFE57373)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                icon: const Icon(Icons.delete_forever_outlined, size: 20),
                label: const Text('Hapus Akun'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogHapusAkun extends StatefulWidget {
  const _DialogHapusAkun();

  @override
  State<_DialogHapusAkun> createState() => _DialogHapusAkunState();
}

class _DialogHapusAkunState extends State<_DialogHapusAkun> {
  final _pass = TextEditingController();
  bool _lihat = false;
  bool _bekerja = false;
  String? _galat;

  @override
  void dispose() {
    _pass.dispose();
    super.dispose();
  }

  Future<void> _hapus() async {
    setState(() {
      _bekerja = true;
      _galat = null;
    });
    try {
      await KlienApi.kirim(
        'DELETE',
        '/api/saya',
        pakaiToken: true,
        isi: {'password': _pass.text},
      );
      if (mounted) Navigator.pop(context, 'hapus');
    } on ApiGalat catch (e) {
      if (!mounted) return;
      if (e.status == 401) {
        Navigator.pop(context, 'habis');
        return;
      }
      setState(() {
        _galat = e.pesan;
        _bekerja = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _galat = 'Data tidak dapat dibaca dari server.';
          _bekerja = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Hapus akun permanen?'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Akun dan datamu akan dihapus permanen dan tidak bisa dikembalikan. '
              'Ketik password untuk memastikan ini memang kamu.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pass,
              enabled: !_bekerja,
              autofocus: true,
              obscureText: !_lihat,
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) {
                if (_pass.text.isNotEmpty && !_bekerja) _hapus();
              },
              decoration: dekorasiIsian(
                'Password',
                Icons.lock_outline,
                akhir: IconButton(
                  icon: Icon(_lihat ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _lihat = !_lihat),
                ),
              ),
            ),
            if (_galat != null) ...[
              const SizedBox(height: 12),
              KotakPesan(teks: _galat!),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _bekerja ? null : () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: const Color(0xFFC62828)),
          onPressed: (_pass.text.isEmpty || _bekerja) ? null : _hapus,
          child: _bekerja
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                )
              : const Text('Hapus Permanen'),
        ),
      ],
    );
  }
}