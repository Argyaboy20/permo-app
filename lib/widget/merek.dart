import 'package:flutter/material.dart';
import '../tema.dart';
import 'logo_bulat.dart';

/// Penulisan merek "Pertanian Mobile": ciri khas aplikasi.
class JudulMerek extends StatelessWidget {
  const JudulMerek({super.key, this.ukuran = 21});

  final double ukuran;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        LogoBulat(ukuran: ukuran * 1.8),
        SizedBox(width: ukuran * 0.45),
        Flexible(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Pertanian',
                  style: TextStyle(
                    fontFamily: 'Pacifico',
                    fontSize: ukuran,
                    color: WarnaPermo.hijauTua,
                  ),
                ),
                TextSpan(
                  text: ' Mobile',
                  style: TextStyle(
                    fontFamily: 'Pacifico',
                    fontSize: ukuran,
                    color: const Color(0xFF3E8E64),
                  ),
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}