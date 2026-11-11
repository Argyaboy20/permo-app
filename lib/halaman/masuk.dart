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
import '../sesi.dart';
import '../widget/kotak_pesan.dart';

class HalamanMasuk extends StatefulWidget {
  const HalamanMasuk({super.key});

  @override
  State<HalamanMasuk> createState() => _HalamanMasukState();
}

class _HalamanMasukState extends State<HalamanMasuk> {
  final _kunci = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _sembunyi = true;
  bool _memproses = false;
  bool _lambat = false;
  String? _galat;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _masuk() async {
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
      final data = await KlienApi.kirim('POST', '/api/login', isi: {
        'username': _username.text.trim(),
        'password': _password.text,
      }) as Map<String, dynamic>;
      final pengguna = data['pengguna'] as Map<String, dynamic>;
      await Sesi.simpan(
        tokenBaru: data['token'] as String,
        detik: data['expiresInSeconds'] as int,
        user: pengguna['username'] as String,
        surel: pengguna['email'] as String,
      );
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/app', (rute) => false);
    } on ApiGalat catch (e) {
      if (mounted) setState(() => _galat = e.pesan);
    } catch (_) {
      if (mounted) setState(() => _galat = 'Respons server tidak dikenali.');
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
                        'Selamat Datang',
                        style: tema.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Masuk untuk melanjutkan ke Permo',
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
                                validator: (v) => Validasi.wajibIsi(v, 'Username'),
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
                                validator: (v) => Validasi.wajibIsi(v, 'Password'),
                                onFieldSubmitted: (_) => _masuk(),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => Navigator.pushNamed(context, '/lupa'),
                                  child: const Text('Lupa Akun?'),
                                ),
                              ),
                              if (_lambat) ...[
                                const SizedBox(height: 16),
                                const KotakPesan(
                                  teks: 'Mohon tunggu…',
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
                                  onPressed: _memproses ? null : _masuk,
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
                                      : const Text('Masuk'),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pushReplacementNamed(context, '/daftar'),
                                style: TextButton.styleFrom(
                                  foregroundColor: WarnaPermo.hijauTua,
                                ),
                                child: const Text('Belum punya akun? Daftar Akun'),
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