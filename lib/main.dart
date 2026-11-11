import 'package:flutter/material.dart';
import 'halaman/daftar.dart';
import 'halaman/kerangka_utama.dart';
import 'halaman/landing.dart';
import 'halaman/masuk.dart';
import 'sesi.dart';
import 'widget/latar.dart';
import 'halaman/lupa_akun.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Sesi.muat();
  runApp(const PermoApp());
}

class PermoApp extends StatelessWidget {
  const PermoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pertanian Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6FB98F)),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.transparent,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
      ),
      builder: (context, child) => LatarPermo(child: child ?? const SizedBox.shrink()),
      initialRoute: Sesi.masihBerlaku ? '/app' : '/',
      routes: {
        '/': (context) => const HalamanLanding(),
        '/daftar': (context) => const HalamanDaftar(),
        '/masuk': (context) => const HalamanMasuk(),
        '/app': (context) => const KerangkaUtama(),
        '/lupa': (context) => const HalamanLupaAkun(),
      },
    );
  }
}