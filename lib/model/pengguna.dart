class Pengguna {
  const Pengguna({required this.id, required this.username, required this.email});

  final int id;
  final String username;
  final String email;

  factory Pengguna.dariJson(Map<String, dynamic> j) => Pengguna(
        id: (j['id'] as num).toInt(),
        username: j['username'] as String,
        email: j['email'] as String,
      );
}