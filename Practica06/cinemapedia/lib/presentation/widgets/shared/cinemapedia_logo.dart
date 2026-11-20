import 'package:flutter/material.dart';

/// Popcorn logo used throughout the app.
class CinemapediaLogo extends StatelessWidget {
  final double size;
  final double progress;

  const CinemapediaLogo({
    super.key,
    this.size = 28,
    this.progress = 1,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipRect(
        child: Align(
          alignment: Alignment.centerLeft,
          widthFactor: progress.clamp(0.0, 1.0),
          child: Image.asset(
            'assets/icon/cinemapedia_logo_foreground.png',
            width: size,
            height: size,
            fit: BoxFit.contain,
            semanticLabel: 'Logo de Cinemapedia con palomitas',
          ),
        ),
      ),
    );
  }
}
