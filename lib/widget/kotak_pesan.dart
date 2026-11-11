import 'package:flutter/material.dart';

class KotakPesan extends StatelessWidget {
  const KotakPesan({super.key, required this.teks, this.galat = true});

  final String teks;
  final bool galat;

  @override
  Widget build(BuildContext context) {
    final warna = galat ? Colors.red : Colors.green;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: warna.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: warna.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            galat ? Icons.error_outline : Icons.hourglass_top,
            size: 20,
            color: warna.shade700,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(teks, style: TextStyle(color: warna.shade900))),
        ],
      ),
    );
  }
}