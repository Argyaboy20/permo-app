import 'package:flutter/material.dart';

class LogoPermo extends StatelessWidget {
  const LogoPermo({super.key, this.ukuran = 120});

  final double ukuran;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(ukuran * 0.2),
      child: Image.asset(
        'assets/logo.png',
        width: ukuran,
        height: ukuran,
        fit: BoxFit.cover,
      ),
    );
  }
}