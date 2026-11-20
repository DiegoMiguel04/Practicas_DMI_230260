import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Bandera sencilla dibujada en código.
///
/// Se dibuja así porque los emojis de bandera no se ven en Windows
/// (aparecen como letras "MX", "US"...).
class FlagIcon extends StatelessWidget {
  final String country; // MX, US, DE, CN, EG
  final double width;

  const FlagIcon({super.key, required this.country, this.width = 40});

  @override
  Widget build(BuildContext context) {
    final height = width * 2 / 3;

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white24, width: 0.5),
          borderRadius: BorderRadius.circular(4),
        ),
        child: CustomPaint(
          size: Size(width, height),
          painter: _FlagPainter(country),
        ),
      ),
    );
  }
}

class _FlagPainter extends CustomPainter {
  final String country;

  _FlagPainter(this.country);

  @override
  void paint(Canvas canvas, Size size) {
    switch (country) {
      case 'MX':
        _mexico(canvas, size);
        break;
      case 'US':
        _usa(canvas, size);
        break;
      case 'DE':
        _germany(canvas, size);
        break;
      case 'CN':
        _china(canvas, size);
        break;
      case 'EG':
        _egypt(canvas, size);
        break;
      default:
        canvas.drawRect(Offset.zero & size, Paint()..color = Colors.grey);
    }
  }

  void _fill(Canvas c, Rect r, Color color) => c.drawRect(r, Paint()..color = color);

  void _mexico(Canvas c, Size s) {
    final w = s.width / 3;
    _fill(c, Rect.fromLTWH(0, 0, w, s.height), const Color(0xFF006847));
    _fill(c, Rect.fromLTWH(w, 0, w, s.height), Colors.white);
    _fill(c, Rect.fromLTWH(w * 2, 0, w + 1, s.height), const Color(0xFFCE1126));
    c.drawCircle(
      Offset(s.width / 2, s.height / 2),
      s.height * 0.16,
      Paint()..color = const Color(0xFF8C6B3F),
    );
  }

  void _usa(Canvas c, Size s) {
    final stripe = s.height / 13;
    for (var i = 0; i < 13; i++) {
      _fill(
        c,
        Rect.fromLTWH(0, i * stripe, s.width, stripe + 0.5),
        i.isEven ? const Color(0xFFB22234) : Colors.white,
      );
    }
    final canton = Rect.fromLTWH(0, 0, s.width * 0.4, stripe * 7);
    _fill(c, canton, const Color(0xFF3C3B6E));

    // "Estrellas" como puntos blancos
    final dot = Paint()..color = Colors.white;
    for (var row = 0; row < 4; row++) {
      for (var col = 0; col < 5; col++) {
        c.drawCircle(
          Offset(
            canton.width * (col + 0.7) / 5.4,
            canton.height * (row + 0.7) / 4.4,
          ),
          s.height * 0.035,
          dot,
        );
      }
    }
  }

  void _germany(Canvas c, Size s) {
    final h = s.height / 3;
    _fill(c, Rect.fromLTWH(0, 0, s.width, h), Colors.black);
    _fill(c, Rect.fromLTWH(0, h, s.width, h), const Color(0xFFDD0000));
    _fill(c, Rect.fromLTWH(0, h * 2, s.width, h + 1), const Color(0xFFFFCE00));
  }

  void _china(Canvas c, Size s) {
    _fill(c, Offset.zero & s, const Color(0xFFDE2910));
    final yellow = Paint()..color = const Color(0xFFFFDE00);

    c.drawPath(_star(Offset(s.width * 0.22, s.height * 0.28), s.height * 0.2, -math.pi / 2), yellow);

    // Cuatro estrellas pequeñas
    final small = <Offset>[
      Offset(s.width * 0.42, s.height * 0.12),
      Offset(s.width * 0.50, s.height * 0.24),
      Offset(s.width * 0.50, s.height * 0.40),
      Offset(s.width * 0.42, s.height * 0.52),
    ];
    for (final p in small) {
      c.drawPath(_star(p, s.height * 0.07, -math.pi / 2), yellow);
    }
  }

  void _egypt(Canvas c, Size s) {
    final h = s.height / 3;
    _fill(c, Rect.fromLTWH(0, 0, s.width, h), const Color(0xFFCE1126));
    _fill(c, Rect.fromLTWH(0, h, s.width, h), Colors.white);
    _fill(c, Rect.fromLTWH(0, h * 2, s.width, h + 1), Colors.black);
    c.drawCircle(
      Offset(s.width / 2, s.height / 2),
      s.height * 0.1,
      Paint()..color = const Color(0xFFC09300),
    );
  }

  Path _star(Offset center, double radius, double rotation) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final r = i.isEven ? radius : radius * 0.4;
      final angle = rotation + i * math.pi / 5;
      final p = Offset(center.dx + r * math.cos(angle), center.dy + r * math.sin(angle));
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    return path..close();
  }

  @override
  bool shouldRepaint(_FlagPainter old) => old.country != country;
}
