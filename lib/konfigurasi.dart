class Konfigurasi {
  // Bisa diganti saat menjalankan: --dart-define=URL_API=http://localhost:3000
  static const urlApi = String.fromEnvironment(
    'URL_API',
    defaultValue: 'https://permo-api.onrender.com',
  );
}