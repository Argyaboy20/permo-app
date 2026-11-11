import 'package:flutter/material.dart';
import '../api/klien_api.dart';
import '../model/pengguna.dart';
import '../sesi.dart';
import '../tema.dart';
import '../widget/merek.dart';
import 'beranda.dart';
import 'pencarian.dart';
import 'segera.dart';
import 'tentang.dart';
import 'akun.dart';
import 'permo_ai.dart';
import 'package:flutter/services.dart';

class KerangkaUtama extends StatefulWidget {
  const KerangkaUtama({super.key});

  @override
  State<KerangkaUtama> createState() => _KerangkaUtamaState();
}

class _KerangkaUtamaState extends State<KerangkaUtama> {
  final _kunci = GlobalKey<ScaffoldState>();
  Pengguna? _pengguna;
  bool _menuTerbuka = false;
  DateTime? _terakhirKembali;

  @override
  void initState() {
    super.initState();
    _muatPengguna();
  }

  Future<void> _muatPengguna() async {
    try {
      final data = await KlienApi.kirim('GET', '/api/saya', pakaiToken: true);
      if (mounted) {
        setState(() => _pengguna = Pengguna.dariJson(data as Map<String, dynamic>));
      }
    } on ApiGalat catch (e) {
      if (e.status == 401 && mounted) {
        RuangChat.ini.hapus();
        Navigator.of(context).pushNamedAndRemoveUntil('/masuk', (_) => false);
      }
    } catch (_) {
      // Gagal sementara: sapaan tetap tampil tanpa nama, dicoba lagi saat menu dibuka
    }
  }

  void _bukaDariMenu(Widget halaman) {
    _kunci.currentState?.closeEndDrawer();
    Navigator.push(context, MaterialPageRoute(builder: (_) => halaman));
  }

  Future<void> _keluar() async {
    _kunci.currentState?.closeEndDrawer();
    final ya = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        content: const Text('Kamu perlu masuk lagi untuk memakai Permo.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Keluar')),
        ],
      ),
    );
    if (ya != true) return;
    await Sesi.hapus();
    RuangChat.ini.hapus();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/masuk', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    // Tombol kembali sistem dan browser diblokir di beranda, kecuali saat menu terbuka
    // (agar tombol kembali tetap bisa menutup menu).
    return PopScope(
      canPop: _menuTerbuka,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        final sekarang = DateTime.now();
        final ulang = _terakhirKembali;
        if (ulang != null && sekarang.difference(ulang) < const Duration(seconds: 2)) {
          SystemNavigator.pop();
          return;
        }
        _terakhirKembali = sekarang;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(
            content: Text('Tekan tombol sekali lagi untuk keluar'),
            duration: Duration(seconds: 2),
          ));
      },
      child: Scaffold(
        key: _kunci,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleSpacing: 16,
          title: const JudulMerek(),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: IconButton.filledTonal(
                tooltip: 'Menu',
                onPressed: () => _kunci.currentState?.openEndDrawer(),
                icon: const Icon(Icons.menu_rounded),
              ),
            ),
          ],
        ),
        onEndDrawerChanged: (terbuka) {
          setState(() => _menuTerbuka = terbuka);
          if (terbuka && _pengguna == null) _muatPengguna();
        },
        endDrawer: _MenuSamping(
          username: _pengguna?.username,
          email: _pengguna?.email,
          onAkun: () => _bukaDariMenu(HalamanAkun(
            onDiubah: (p) => setState(() => _pengguna = p),
          )),
          onAi: () => _bukaDariMenu(HalamanPermoAI(penggunaId: _pengguna?.id)),
          onTentang: () => _bukaDariMenu(const HalamanTentang()),
          onKeluar: _keluar,
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(child: HalamanBeranda(pengguna: _pengguna)),
              Positioned(
                right: 20,
                bottom: 32,
                child: FloatingActionButton(
                  heroTag: 'cari',
                  tooltip: 'Cari di Kamus dan Ilmu Tanah',
                  backgroundColor: WarnaPermo.hijauTua,
                  foregroundColor: Colors.white,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HalamanPencarian()),
                  ),
                  child: const Icon(Icons.search_rounded),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuSamping extends StatelessWidget {
  const _MenuSamping({
    required this.username,
    required this.email,
    required this.onAkun,
    required this.onAi,
    required this.onTentang,
    required this.onKeluar,
  });

  final String? username;
  final String? email;
  final VoidCallback onAkun;
  final VoidCallback onAi;
  final VoidCallback onTentang;
  final VoidCallback onKeluar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    final nama = username ?? 'Memuat akun…';
    final inisial = (username == null || username!.isEmpty) ? 'P' : username![0].toUpperCase();

    return Drawer(
      width: 310,
      backgroundColor: const Color(0xFFF4FAF6),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 24, 20, 24),
            decoration: BoxDecoration(gradient: WarnaPermo.gradienLatar),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                  child: Text(
                    inisial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nama,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tema.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (email != null)
                        Text(
                          email!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: tema.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.95),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _ItemMenu(ikon: Icons.person_outline, teks: 'Akun', onTap: onAkun),
          _ItemMenu(ikon: Icons.auto_awesome, teks: 'Permo AI', onTap: onAi),
          _ItemMenu(ikon: Icons.info_outline, teks: 'Tentang Sistem', onTap: onTentang),
          const Spacer(),
          const Divider(indent: 16, endIndent: 16),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ItemMenu(
                ikon: Icons.logout,
                teks: 'Keluar',
                warna: const Color(0xFFC62828),
                onTap: onKeluar,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemMenu extends StatelessWidget {
  const _ItemMenu({required this.ikon, required this.teks, required this.onTap, this.warna});

  final IconData ikon;
  final String teks;
  final VoidCallback onTap;
  final Color? warna;

  @override
  Widget build(BuildContext context) {
    final w = warna ?? WarnaPermo.hijauTua;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Icon(ikon, color: w),
        title: Text(teks, style: TextStyle(fontWeight: FontWeight.w600, color: warna)),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
      ),
    );
  }
}