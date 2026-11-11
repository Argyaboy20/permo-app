import 'package:flutter/material.dart';

/// Logo Permo dari assets/logo.png dalam bingkai bulat penuh, tanpa pinggiran putih.
class LogoBulat extends StatelessWidget {
  const LogoBulat({super.key, this.ukuran = 44});

  final double ukuran;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ukuran,
      height: ukuran,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF2F6F55),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: Transform.scale(
          scale: 1.18,
          child: Image.asset(
            'assets/logo.png',
            width: ukuran,
            height: ukuran,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}