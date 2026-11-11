import 'dart:async';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../api/klien_api.dart';

class Cuaca {
  const Cuaca({required this.suhu, required this.kelembapan});
  final double suhu;
  final double kelembapan;
}

class LayananCuaca {
    /// Memeriksa izin lokasi TANPA memunculkan permintaan izin.
  static Future<bool> sudahDiizinkan() async {
    try {
      final izin = await Geolocator.checkPermission();
      return izin == LocationPermission.whileInUse || izin == LocationPermission.always;
    } catch (_) {
      return false;
    }
  }

  /// Meminta izin lalu mengambil lokasi perkiraan perangkat.
  static Future<Position> lokasi() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw ApiGalat(0, 'Layanan lokasi di perangkat mati. Nyalakan, atau isi manual di bawah.');
      }
      var izin = await Geolocator.checkPermission();
      if (izin == LocationPermission.denied) {
        izin = await Geolocator.requestPermission();
      }
      if (izin == LocationPermission.denied || izin == LocationPermission.deniedForever) {
        throw ApiGalat(0, 'Izin lokasi ditolak. Izinkan lewat pengaturan browser, atau isi manual di bawah.');
      }
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 20),
        ),
      );
    } on ApiGalat {
      rethrow;
    } on TimeoutException {
      throw ApiGalat(0, 'Lokasi tidak berhasil didapat tepat waktu. Coba lagi, atau isi manual.');
    } catch (_) {
      throw ApiGalat(0, 'Lokasi tidak dapat dibaca. Coba lagi, atau isi manual.');
    }
  }

  /// Cuaca saat ini dari Open-Meteo (gratis, tanpa kunci API).
  static Future<Cuaca> ambil(double lat, double lon) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': lat.toStringAsFixed(2),
      'longitude': lon.toStringAsFixed(2),
      'current': 'temperature_2m,relative_humidity_2m',
    });

    http.Response resp;
    try {
      resp = await http.get(uri).timeout(const Duration(seconds: 15));
    } catch (_) {
      throw ApiGalat(0, 'Tidak dapat mengambil data cuaca. Periksa koneksi internet.');
    }
    if (resp.statusCode != 200) {
      throw ApiGalat(0, 'Layanan cuaca sedang bermasalah. Coba lagi nanti, atau isi manual.');
    }

    try {
      final j = jsonDecode(resp.body) as Map<String, dynamic>;
      final c = j['current'] as Map<String, dynamic>;
      return Cuaca(
        suhu: (c['temperature_2m'] as num).toDouble(),
        kelembapan: (c['relative_humidity_2m'] as num).toDouble(),
      );
    } catch (_) {
      throw ApiGalat(0, 'Data cuaca tidak dapat dibaca. Coba lagi, atau isi manual.');
    }
  }

  /// Nama daerah dari OpenStreetMap Nominatim: Kecamatan, Kabupaten, Provinsi, Negara.
  /// Tidak pernah melempar galat: bila gagal, hasilnya null.
  static Future<String?> namaDaerah(double lat, double lon) async {
    final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
      'format': 'jsonv2',
      'lat': lat.toStringAsFixed(3),
      'lon': lon.toStringAsFixed(3),
      'zoom': '14',
      'addressdetails': '1',
      'accept-language': 'id',
    });
    try {
      final resp = await http.get(uri).timeout(const Duration(seconds: 10));
      if (resp.statusCode != 200) return null;
      final j = jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;
      final a = j['address'] as Map<String, dynamic>?;
      if (a == null) return null;

      String? ambil(List<String> kunci) {
        for (final k in kunci) {
          final v = a[k];
          if (v is String && v.trim().isNotEmpty) return v.trim();
        }
        return null;
      }

      final bagian = <String>[];
      void tambah(String? v) {
        if (v != null && !bagian.contains(v)) bagian.add(v);
      }

      tambah(ambil(['municipality', 'city_district']));        // kecamatan
      tambah(ambil(['county', 'city', 'regency', 'state_district'])); // kabupaten/kota
      tambah(ambil(['state']));                                // provinsi
      if (bagian.isEmpty) return null;
      tambah(ambil(['country']));
      return bagian.join(', ');
    } catch (_) {
      return null;
    }
  }
}