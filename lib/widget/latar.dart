import 'package:flutter/material.dart';

/// Latar bersama seluruh halaman: gradien hijau lembut dengan hiasan daun dan lingkaran.
class LatarPermo extends StatelessWidget {
  const LatarPermo({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFC9E6D5), Color(0xFFE6F4EC)],
            ),
          ),
        ),
        const _Hiasan(),
        child,
      ],
    );
  }
}

class _Hiasan extends StatelessWidget {
  const _Hiasan();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, c) {
          final besar = (c.maxWidth > c.maxHeight ? c.maxWidth : c.maxHeight) * 0.55;
          return Stack(
            children: [
              Positioned(
                top: -besar * 0.35,
                right: -besar * 0.3,
                child: _Lingkaran(besar, const Color(0x336FB98F)),
              ),
              Positioned(
                bottom: -besar * 0.4,
                left: -besar * 0.35,
                child: _Lingkaran(besar * 0.9, const Color(0x2640A070)),
              ),
              Positioned(
                top: c.maxHeight * 0.18,
                left: -30,
                child: Transform.rotate(
                  angle: -0.5,
                  child: const Icon(Icons.eco, size: 140, color: Color(0x1A2E7D55)),
                ),
              ),
              Positioned(
                bottom: c.maxHeight * 0.12,
                right: -20,
                child: Transform.rotate(
                  angle: 0.6,
                  child: const Icon(Icons.eco, size: 180, color: Color(0x142E7D55)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Lingkaran extends StatelessWidget {
  const _Lingkaran(this.ukuran, this.warna);

  final double ukuran;
  final Color warna;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ukuran,
      height: ukuran,
      decoration: BoxDecoration(shape: BoxShape.circle, color: warna),
    );
  }
}