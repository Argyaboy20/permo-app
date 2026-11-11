import 'package:shared_preferences/shared_preferences.dart';

class Sesi {
  static String? token;
  static DateTime? kedaluwarsa;
  static String? username;
  static String? email;

  static bool get masihBerlaku =>
      token != null && kedaluwarsa != null && DateTime.now().isBefore(kedaluwarsa!);

  static Future<void> muat() async {
    final p = await SharedPreferences.getInstance();
    token = p.getString('token');
    final ms = p.getInt('kedaluwarsa');
    kedaluwarsa = ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
    username = p.getString('username');
    email = p.getString('email');
    if (!masihBerlaku) await hapus();
  }

  static Future<void> simpan({
    required String tokenBaru,
    required int detik,
    required String user,
    required String surel,
  }) async {
    token = tokenBaru;
    kedaluwarsa = DateTime.now().add(Duration(seconds: detik));
    username = user;
    email = surel;
    final p = await SharedPreferences.getInstance();
    await p.setString('token', tokenBaru);
    await p.setInt('kedaluwarsa', kedaluwarsa!.millisecondsSinceEpoch);
    await p.setString('username', user);
    await p.setString('email', surel);
  }

  static Future<void> hapus() async {
    token = null;
    kedaluwarsa = null;
    username = null;
    email = null;
    final p = await SharedPreferences.getInstance();
    for (final k in ['token', 'kedaluwarsa', 'username', 'email']) {
      await p.remove(k);
    }
  }
}