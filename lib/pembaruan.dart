import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class Pembaruan {
  static const _repo = 'Argyaboy20/permo-app';

  /// Alamat halaman rilis bila ada versi lebih baru; null bila sudah terbaru atau gagal dicek.
  static Future<String?> cek() async {
    try {
      final resp = await http.get(
        Uri.parse('https://api.github.com/repos/$_repo/releases/latest'),
        headers: {'Accept': 'application/vnd.github+json'},
      ).timeout(const Duration(seconds: 10));
      if (resp.statusCode != 200) return null;
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final baru = (data['tag_name'] as String).replaceFirst(RegExp(r'^[vV]'), '');
      final sekarang = (await PackageInfo.fromPlatform()).version;
      return _lebihBaru(baru, sekarang) ? data['html_url'] as String : null;
    } catch (_) {
      return null; // gagal cek = tombol tidak muncul, tanpa pesan galat
    }
  }

  static bool _lebihBaru(String a, String b) {
    final x = a.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final y = b.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    for (var i = 0; i < 3; i++) {
      final p = i < x.length ? x[i] : 0;
      final q = i < y.length ? y[i] : 0;
      if (p != q) return p > q;
    }
    return false;
  }
}