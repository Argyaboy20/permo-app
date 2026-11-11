import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../tema.dart';

class _Daun {
  const _Daun({
    required this.x,
    required this.y,
    required this.ukuran,
    required this.fase,
    required this.kali,
    required this.ikon,
    required this.putar,
    required this.opasitas,
  });

  final double x;
  final double y;
  final double ukuran;
  final double fase;
  final int kali;
  final IconData ikon;
  final double putar;
  final double opasitas;
}

const _daftarDaun = <_Daun>[
  _Daun(x: 0.06, y: 0.08, ukuran: 54, fase: 0.0, kali: 1, ikon: Icons.eco, putar: -0.5, opasitas: 0.22),
  _Daun(x: 0.80, y: 0.06, ukuran: 40, fase: 1.3, kali: 2, ikon: Icons.spa, putar: 0.4, opasitas: 0.18),
  _Daun(x: 0.45, y: 0.15, ukuran: 30, fase: 2.1, kali: 3, ikon: Icons.energy_savings_leaf, putar: 0.9, opasitas: 0.15),
  _Daun(x: 0.90, y: 0.32, ukuran: 62, fase: 0.7, kali: 1, ikon: Icons.eco, putar: 0.6, opasitas: 0.20),
  _Daun(x: 0.12, y: 0.38, ukuran: 36, fase: 3.0, kali: 2, ikon: Icons.grass, putar: -0.2, opasitas: 0.16),
  _Daun(x: 0.60, y: 0.48, ukuran: 48, fase: 4.2, kali: 1, ikon: Icons.spa, putar: -0.8, opasitas: 0.14),
  _Daun(x: 0.25, y: 0.60, ukuran: 58, fase: 5.0, kali: 2, ikon: Icons.eco, putar: 0.3, opasitas: 0.20),
  _Daun(x: 0.85, y: 0.66, ukuran: 34, fase: 2.6, kali: 3, ikon: Icons.energy_savings_leaf, putar: -0.6, opasitas: 0.16),
  _Daun(x: 0.05, y: 0.82, ukuran: 44, fase: 1.8, kali: 1, ikon: Icons.grass, putar: 0.2, opasitas: 0.18),
  _Daun(x: 0.50, y: 0.88, ukuran: 64, fase: 0.4, kali: 2, ikon: Icons.eco, putar: 0.8, opasitas: 0.15),
  _Daun(x: 0.92, y: 0.90, ukuran: 38, fase: 3.7, kali: 1, ikon: Icons.spa, putar: -0.3, opasitas: 0.18),
];

/// Latar gradien dengan daun yang melayang pelan. Satu putaran gerak = 60 detik.
class LatarDaun extends StatefulWidget {
  const LatarDaun({super.key, required this.child});

  final Widget child;

  @override
  State<LatarDaun> createState() => _LatarDaunState();
}

class _LatarDaunState extends State<LatarDaun> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 60));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(decoration: BoxDecoration(gradient: WarnaPermo.gradienLatar)),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _c,
                builder: (context, _) {
                  final t = _c.value * 2 * math.pi;
                  return LayoutBuilder(
                    builder: (context, box) {
                      return Stack(
                        clipBehavior: Clip.hardEdge,
                        children: [
                          for (final d in _daftarDaun)
                            Positioned(
                              left: d.x * box.maxWidth + math.sin(t * d.kali + d.fase) * 18,
                              top: d.y * box.maxHeight + math.cos(t * d.kali + d.fase) * 22,
                              child: Transform.rotate(
                                angle: d.putar + math.sin(t * d.kali + d.fase) * 0.25,
                                child: Icon(
                                  d.ikon,
                                  size: d.ukuran,
                                  color: Colors.white.withValues(alpha: d.opasitas),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}