import 'dart:async';
import 'package:flutter/material.dart';
import '../tema.dart';
import '../validasi.dart';
import '../widget/isian.dart';
import '../widget/kartu_form.dart';
import '../widget/latar_daun.dart';
import '../widget/logo_permo.dart';
import '../widget/muncul.dart';
import '../api/klien_api.dart';
import '../widget/kotak_pesan.dart';

class HalamanDaftar extends StatefulWidget {
  const HalamanDaftar({super.key});

  @override
  State<HalamanDaftar> createState() => _HalamanDaftarState();
}

class _HalamanDaftarState extends State<HalamanDaftar> {
  final _kunci = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _konfirmasi = TextEditingController();
  bool _sembunyi = true;
  bool _memproses = false;
  bool _lambat = false;
  String? _galat;

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    _konfirmasi.dispose();
    super.dispose();
  }

  Future<void> _kirim() async {
    if (_memproses || !_kunci.currentState!.validate()) return;
    setState(() {
      _memproses = true;
      _lambat = false;
      _galat = null;
    });
    final pewaktu = Timer(const Duration(seconds: 4), () {
      if (mounted && _memproses) setState(() => _lambat = true);
    });
    try {
      await KlienApi.kirim('POST', '/api/daftar', isi: {
        'username': _username.text.trim(),
        'email': _email.text.trim(),
        'password': _password.text,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pendaftaran berhasil. Silakan masuk.')),
      );
      Navigator.pushReplacementNamed(context, '/masuk');
    } on ApiGalat catch (e) {
      if (mounted) setState(() => _galat = e.pesan);
    } finally {
      pewaktu.cancel();
      if (mounted) {
        setState(() {
          _memproses = false;
          _lambat = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    final mata = IconButton(
      icon: Icon(_sembunyi ? Icons.visibility : Icons.visibility_off),
      onPressed: () => setState(() => _sembunyi = !_sembunyi),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: Colors.white,
      ),
      body: LatarDaun(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Muncul(
                  child: Column(
                    children: [
                      const LogoPermo(ukuran: 96),
                      const SizedBox(height: 16),
                      Text(
                        'Buat Akun Baru',
                        style: tema.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Daftar untuk mulai menjelajahi Permo',
                        style: tema.bodyLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(height: 24),
                      KartuForm(
                        child: Form(
                          key: _kunci,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _username,
                                decoration: dekorasiIsian('Username', Icons.person_outline),
                                validator: Validasi.username,
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _email,
                                decoration: dekorasiIsian('Email', Icons.mail_outline),
                                keyboardType: TextInputType.emailAddress,
                                validator: Validasi.email,
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _password,
                                obscureText: _sembunyi,
                                decoration: dekorasiIsian(
                                  'Password',
                                  Icons.lock_outline,
                                  akhir: mata,
                                ),
                                validator: Validasi.password,
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _konfirmasi,
                                obscureText: _sembunyi,
                                decoration: dekorasiIsian(
                                  'Konfirmasi Password',
                                  Icons.verified_user_outlined,
                                ),
                                validator: (v) => v != _password.text
                                    ? 'Konfirmasi password tidak sama'
                                    : null,
                                onFieldSubmitted: (_) => _kirim(),
                              ),
                              if (_lambat) ...[
                                const SizedBox(height: 16),
                                const KotakPesan(
                                  teks: 'Server sedang bangun, bisa sampai satu menit. Mohon tunggu…',
                                  galat: false,
                                ),
                              ],
                              if (_galat != null) ...[
                                const SizedBox(height: 16),
                                KotakPesan(teks: _galat!),
                              ],
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: FilledButton(
                                  onPressed: _memproses ? null : _kirim,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: WarnaPermo.hijauTua,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  child: _memproses
                                      ? const SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text('Daftar'),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pushReplacementNamed(context, '/masuk'),
                                style: TextButton.styleFrom(
                                  foregroundColor: WarnaPermo.hijauTua,
                                ),
                                child: const Text('Sudah punya akun? Masuk Akun'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}