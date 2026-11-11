import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../api/klien_api.dart';
import '../tema.dart';
import '../widget/isian.dart';
import '../widget/kotak_pesan.dart';

enum _Langkah { email, kode, selesai }

class HalamanLupaAkun extends StatefulWidget {
  const HalamanLupaAkun({super.key});

  @override
  State<HalamanLupaAkun> createState() => _HalamanLupaAkunState();
}

class _HalamanLupaAkunState extends State<HalamanLupaAkun> {
  static final _polaEmail = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final _polaKode = RegExp(r'^[0-9]{6}$');
  static const _jedaKirimUlang = 60;

  final _email = TextEditingController();
  final _kode = TextEditingController();
  final _pass = TextEditingController();
  final _pass2 = TextEditingController();

  _Langkah _langkah = _Langkah.email;
  bool _bekerja = false;
  bool _lihat = false;
  String? _galat;
  String? _info;
  int _sisaDetik = 0;
  Timer? _pewaktu;

  @override
  void dispose() {
    _pewaktu?.cancel();
    _email.dispose();
    _kode.dispose();
    _pass.dispose();
    _pass2.dispose();
    super.dispose();
  }

  String _emailBersih() => _email.text.trim().toLowerCase();

  void _mulaiHitung() {
    _pewaktu?.cancel();
    setState(() => _sisaDetik = _jedaKirimUlang);
    _pewaktu = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _sisaDetik = _sisaDetik - 1);
      if (_sisaDetik <= 0) t.cancel();
    });
  }

  Future<void> _kirimKode() async {
    final email = _emailBersih();
    if (!_polaEmail.hasMatch(email) || email.length > 254) {
      setState(() => _galat = 'Format email tidak valid.');
      return;
    }
    setState(() {
      _bekerja = true;
      _galat = null;
    });
    try {
      final data = await KlienApi.kirim('POST', '/api/lupa-akun', isi: {'email': email});
      if (!mounted) return;
      final pesan = data is Map && data['message'] is String
          ? data['message'] as String
          : 'Jika email terdaftar, kode reset telah dikirim. Cek inbox atau folder spam.';
      setState(() {
        _langkah = _Langkah.kode;
        _info = pesan;
        _kode.clear();
      });
      _mulaiHitung();
    } on ApiGalat catch (e) {
      if (mounted) setState(() => _galat = e.pesan);
    } catch (_) {
      if (mounted) setState(() => _galat = 'Data tidak dapat dibaca dari server.');
    } finally {
      if (mounted) setState(() => _bekerja = false);
    }
  }

  Future<void> _reset() async {
    final kode = _kode.text.trim();
    final baru = _pass.text;

    String? salah;
    if (!_polaKode.hasMatch(kode)) {
      salah = 'Kode terdiri dari 6 angka.';
    } else if (baru.length < 8 || baru.length > 72) {
      salah = 'Password baru 8–72 karakter.';
    } else if (baru != _pass2.text) {
      salah = 'Ulangi password tidak sama dengan password baru.';
    }
    if (salah != null) {
      setState(() => _galat = salah);
      return;
    }

    setState(() {
      _bekerja = true;
      _galat = null;
    });
    try {
      await KlienApi.kirim(
        'POST',
        '/api/reset-password',
        isi: {'email': _emailBersih(), 'kode': kode, 'passwordBaru': baru},
      );
      if (!mounted) return;
      _pewaktu?.cancel();
      _kode.clear();
      _pass.clear();
      _pass2.clear();
      setState(() {
        _langkah = _Langkah.selesai;
        _info = null;
        _galat = null;
      });
    } on ApiGalat catch (e) {
      if (mounted) setState(() => _galat = e.pesan);
    } catch (_) {
      if (mounted) setState(() => _galat = 'Data tidak dapat dibaca dari server.');
    } finally {
      if (mounted) setState(() => _bekerja = false);
    }
  }

  void _gantiEmail() {
    _pewaktu?.cancel();
    setState(() {
      _langkah = _Langkah.email;
      _galat = null;
      _info = null;
      _sisaDetik = 0;
    });
  }

  void _keMasuk() {
    Navigator.of(context).pushNamedAndRemoveUntil('/masuk', (r) => r.settings.name == '/');
  }

  Widget _mata() {
    return IconButton(
      icon: Icon(_lihat ? Icons.visibility_off : Icons.visibility),
      onPressed: () => setState(() => _lihat = !_lihat),
    );
  }

  Widget _tombolUtama(String label, VoidCallback aksi, {IconData? ikon}) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _bekerja ? null : aksi,
        icon: _bekerja
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
              )
            : Icon(ikon ?? Icons.arrow_forward),
        label: Text(label),
      ),
    );
  }

  Widget _isiEmail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _email,
          enabled: !_bekerja,
          autofocus: true,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.send,
          onSubmitted: (_) => _kirimKode(),
          decoration: dekorasiIsian('Email akun', Icons.mail_outline),
        ),
        if (_galat != null) ...[
          const SizedBox(height: 14),
          KotakPesan(teks: _galat!),
        ],
        const SizedBox(height: 16),
        _tombolUtama('Kirim Kode', _kirimKode, ikon: Icons.send_outlined),
      ],
    );
  }

  Widget _isiKode() {
    final tema = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_info != null) ...[
          KotakPesan(teks: _info!, galat: false),
          const SizedBox(height: 14),
        ],
        TextField(
          controller: _kode,
          enabled: !_bekerja,
          autofocus: true,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.w700),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          decoration: dekorasiIsian('Kode 6 digit', Icons.pin_outlined),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _pass,
          enabled: !_bekerja,
          obscureText: !_lihat,
          decoration: dekorasiIsian('Password baru', Icons.lock_outline, akhir: _mata()),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _pass2,
          enabled: !_bekerja,
          obscureText: !_lihat,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _reset(),
          decoration: dekorasiIsian('Ulangi password baru', Icons.lock_reset),
        ),
        const SizedBox(height: 6),
        Text('Password 8–72 karakter.', style: tema.bodySmall),
        if (_galat != null) ...[
          const SizedBox(height: 14),
          KotakPesan(teks: _galat!),
        ],
        const SizedBox(height: 16),
        _tombolUtama('Reset Password', _reset, ikon: Icons.check),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: _bekerja ? null : _gantiEmail,
              child: const Text('Ganti email'),
            ),
            TextButton(
              onPressed: (_bekerja || _sisaDetik > 0) ? null : _kirimKode,
              child: Text(
                _sisaDetik > 0 ? 'Kirim ulang dalam $_sisaDetik dtk' : 'Kirim ulang kode',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _isiSelesai() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const KotakPesan(
          teks: 'Password berhasil direset. Masuk memakai username dan password barumu.',
          galat: false,
        ),
        const SizedBox(height: 16),
        _tombolUtama('Masuk', _keMasuk, ikon: Icons.login),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    final selesai = _langkah == _Langkah.selesai;
    final judul = switch (_langkah) {
      _Langkah.email => 'Lupa password?',
      _Langkah.kode => 'Cek emailmu',
      _Langkah.selesai => 'Password diperbarui',
    };
    final keterangan = switch (_langkah) {
      _Langkah.email =>
        'Masukkan email akunmu. Kami akan mengirim kode 6 digit untuk membuat password baru.',
      _Langkah.kode =>
        'Masukkan kode 6 digit yang dikirim ke ${_emailBersih()} (berlaku 15 menit), lalu buat '
            'password baru. Tidak ada email? Periksa folder spam.',
      _Langkah.selesai => 'Akunmu sudah bisa dipakai lagi.',
    };

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: const Text(
          'Lupa Akun',
          style: TextStyle(fontWeight: FontWeight.w800, color: WarnaPermo.hijauTua),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: WarnaPermo.gradienLatar,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        selesai ? Icons.check_circle_outline : Icons.lock_reset,
                        size: 38,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      judul,
                      textAlign: TextAlign.center,
                      style: tema.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: WarnaPermo.hijauTua,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      keterangan,
                      textAlign: TextAlign.center,
                      style: tema.bodyMedium?.copyWith(height: 1.45),
                    ),
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
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: KeyedSubtree(
                        key: ValueKey(_langkah),
                        child: switch (_langkah) {
                          _Langkah.email => _isiEmail(),
                          _Langkah.kode => _isiKode(),
                          _Langkah.selesai => _isiSelesai(),
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}