import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../konfigurasi.dart';
import '../sesi.dart';

class ApiGalat implements Exception {
  ApiGalat(this.status, this.pesan);
  final int status;
  final String pesan;

  @override
  String toString() => pesan;
}

class KlienApi {
  // Server gratis yang tidur butuh sekitar satu menit untuk bangun
  static const _batas = Duration(seconds: 90);

  static Future<dynamic> kirim(
    String metode,
    String jalur, {
    Map<String, dynamic>? isi,
    bool pakaiToken = false,
  }) async {
    final uri = Uri.parse('${Konfigurasi.urlApi}$jalur');
    final header = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (pakaiToken && Sesi.token != null) {
      header['Authorization'] = 'Bearer ${Sesi.token}';
    }

    http.Response resp;
    try {
      if (metode == 'GET') {
        resp = await http.get(uri, headers: header).timeout(_batas);
      } else if (metode == 'PATCH') {
        resp = await http
            .patch(uri, headers: header, body: jsonEncode(isi ?? {}))
            .timeout(_batas);
      } else if (metode == 'DELETE') {
        resp = await http
            .delete(uri, headers: header, body: jsonEncode(isi ?? {}))
            .timeout(_batas);
      } else {
        resp = await http
            .post(uri, headers: header, body: jsonEncode(isi ?? {}))
            .timeout(_batas);
      }
    } on TimeoutException {
      throw ApiGalat(0, 'Server tidak merespons. Coba lagi sebentar lagi.');
    } catch (_) {
      throw ApiGalat(0, 'Tidak dapat terhubung ke server. Periksa koneksi internet.');
    }

    dynamic data;
    if (resp.body.isNotEmpty) {
      try {
        data = jsonDecode(utf8.decode(resp.bodyBytes));
      } catch (_) {}
    }

    if (resp.statusCode >= 200 && resp.statusCode < 300) return data;

    final pesan = data is Map && data['message'] is String
        ? data['message'] as String
        : 'Terjadi kesalahan (${resp.statusCode})';
    // 401 pada permintaan bertoken = sesi tidak sah. 403 sengaja tidak menghapus sesi.
    if (resp.statusCode == 401 && pakaiToken) await Sesi.hapus();
    throw ApiGalat(resp.statusCode, pesan);
  }
}