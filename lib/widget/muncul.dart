import 'package:flutter/material.dart';

/// Memunculkan anak dengan efek memudar dan naik sedikit.
class Muncul extends StatelessWidget {
  const Muncul({super.key, required this.child, this.ms = 700});

  final Widget child;
  final int ms;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: ms),
      curve: Curves.easeOutCubic,
      builder: (context, v, anak) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, (1 - v) * 24), child: anak),
      ),
      child: child,
    );
  }
}