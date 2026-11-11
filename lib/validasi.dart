class Validasi {
  static final _username = RegExp(r'^[a-zA-Z0-9]{7,35}$');
  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? username(String? v) {
    if (v == null || !_username.hasMatch(v.trim())) {
      return 'Username 7–35 karakter, hanya huruf dan angka';
    }
    return null;
  }

  static String? email(String? v) {
    final e = (v ?? '').trim();
    if (e.length > 254 || !_email.hasMatch(e)) return 'Format email tidak valid';
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.length < 8 || v.length > 72) return 'Password 8–72 karakter';
    return null;
  }

  static String? wajibIsi(String? v, String nama) {
    if (v == null || v.trim().isEmpty) return '$nama wajib diisi';
    return null;
  }
}