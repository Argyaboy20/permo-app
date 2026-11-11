import 'dart:async';
import 'package:flutter/material.dart';
import '../api/klien_api.dart';
import 'kotak_pesan.dart';

/// Memuat data dari server lalu menampilkan: memuat, galat (+ Coba Lagi), atau isi.
class PemuatData<T> extends StatefulWidget {
  const PemuatData({super.key, required this.ambil, required this.bangun});

  final Future<T> Function() ambil;
  final Widget Function(BuildContext context, T data) bangun;

  @override
  State<PemuatData<T>> createState() => _PemuatDataState<T>();
}

class _PemuatDataState<T> extends State<PemuatData<T>> {
  T? _data;
  bool _memuat = true;
  bool _lambat = false;
  String? _galat;
  Timer? _pewaktu;

  @override
  void initState() {
    super.initState();
    _jalankan();
  }

  @override
  void dispose() {
    _pewaktu?.cancel();
    super.dispose();
  }

  void _ulang() {
    setState(() {
      _memuat = true;
      _lambat = false;
      _galat = null;
    });
    _jalankan();
  }

  Future<void> _jalankan() async {
    _pewaktu?.cancel();
    _pewaktu = Timer(const Duration(seconds: 4), () {
      if (mounted && _memuat) setState(() => _lambat = true);
    });
    try {
      final hasil = await widget.ambil();
      if (mounted) setState(() => _data = hasil);
    } on ApiGalat catch (e) {
      if (e.status == 401 && mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/masuk', (_) => false);
        return;
      }
      if (mounted) setState(() => _galat = e.pesan);
    } catch (_) {
      if (mounted) setState(() => _galat = 'Data tidak dapat dibaca dari server.');
    } finally {
      _pewaktu?.cancel();
      if (mounted) {
        setState(() {
          _memuat = false;
          _lambat = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_memuat) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              if (_lambat) ...[
                const SizedBox(height: 20),
                ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: const KotakPesan(
                        teks: 'Mohon tunggu…',
                        galat: false,
                    ),
                ),
              ],
            ],
          ),
        ),
      );
    }
    if (_galat != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: KotakPesan(teks: _galat!),
              ),
              const SizedBox(height: 16),
              FilledButton.tonalIcon(
                onPressed: _ulang,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }
    return widget.bangun(context, _data as T);
  }
}