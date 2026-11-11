import 'package:flutter/material.dart';
import '../api/klien_api.dart';
import '../model/tumbuhan.dart';
import '../tema.dart';
import '../widget/isian.dart';
import '../widget/pemuat_data.dart';
import 'detail_tumbuhan.dart';

class HalamanKamus extends StatefulWidget {
  const HalamanKamus({super.key});

  @override
  State<HalamanKamus> createState() => _HalamanKamusState();
}

class _HalamanKamusState extends State<HalamanKamus> {
  final _cari = TextEditingController();
  String _kata = '';

  @override
  void dispose() {
    _cari.dispose();
    super.dispose();
  }

  Future<List<Tumbuhan>> _ambil() async {
    final data = await KlienApi.kirim('GET', '/api/kamus', pakaiToken: true) as List;
    return data.map((e) => Tumbuhan.dariJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return PemuatData<List<Tumbuhan>>(
      ambil: _ambil,
      bangun: (context, daftar) {
        final kata = _kata.trim().toLowerCase();
        final tampil = kata.isEmpty
            ? daftar
            : daftar.where((t) => t.nama.toLowerCase().contains(kata)).toList();

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: TextField(
                    controller: _cari,
                    onChanged: (v) => setState(() => _kata = v),
                    decoration: dekorasiIsian(
                      'Cari tumbuhan',
                      Icons.search,
                      akhir: _kata.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _cari.clear();
                                setState(() => _kata = '');
                              },
                            ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${tampil.length} tumbuhan',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                ),
                Expanded(
                  child: tampil.isEmpty
                      ? const Center(child: Text('Tidak ada tumbuhan yang cocok.'))
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                          itemCount: tampil.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, i) {
                            final t = tampil[i];
                            return Card(
                              elevation: 0,
                              margin: EdgeInsets.zero,
                              color: const Color(0xFFF1F7F4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                leading: CircleAvatar(
                                  backgroundColor:
                                      WarnaPermo.hijau.withValues(alpha: 0.25),
                                  child: const Icon(Icons.eco, color: WarnaPermo.hijauTua),
                                ),
                                title: Text(
                                  t.nama,
                                  style: const TextStyle(fontWeight: FontWeight.w700),
                                ),
                                subtitle: Text(
                                  t.suhu,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => HalamanDetailTumbuhan(tumbuhan: t),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}