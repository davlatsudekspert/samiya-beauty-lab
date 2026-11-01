import 'package:flutter/material.dart';

import '../app/theme.dart';

/// SAMIYA monogrammasi: ingichka oltin ravoq (arka) ichida tik serif "S".
class SamiyaMark extends StatelessWidget {
  const SamiyaMark({super.key, this.size = 96, this.color = SamiyaColors.gold, this.letterColor});
  final double size;
  final Color color;
  final Color? letterColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.25,
      child: CustomPaint(
        painter: _ArchPainter(color),
        child: Align(
          alignment: const Alignment(0, 0.18),
          child: Text('S',
              style: TextStyle(
                fontFamily: 'CormorantGaramond',
                fontWeight: FontWeight.w600,
                fontSize: size * 0.72,
                height: 1,
                color: letterColor ?? color,
              )),
        ),
      ),
    );
  }
}

class _ArchPainter extends CustomPainter {
  _ArchPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = s.width * 0.018
      ..isAntiAlias = true;
    Path arch(double inset) {
      final w = s.width - inset * 2, r = w / 2;
      return Path()
        ..moveTo(inset, s.height - inset)
        ..lineTo(inset, r + inset)
        ..arcToPoint(Offset(s.width - inset, r + inset), radius: Radius.circular(r))
        ..lineTo(s.width - inset, s.height - inset);
    }
    canvas.drawPath(arch(s.width * 0.02), p);
    canvas.drawPath(arch(s.width * 0.085), p..strokeWidth = s.width * 0.008);
    // pastki chiziq (poydevor)
    canvas.drawLine(Offset(-s.width * 0.06, s.height - s.width * 0.02), Offset(s.width * 1.06, s.height - s.width * 0.02), p..strokeWidth = s.width * 0.012);
  }

  @override
  bool shouldRepaint(_ArchPainter old) => old.color != color;
}

/// SAMIYA yozuvi (keng harf oralig'i) va BEAUTY LAB.
class SamiyaWordmark extends StatelessWidget {
  const SamiyaWordmark({super.key, this.color = SamiyaColors.heading, this.scale = 1});
  final Color color;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text('SAMIYA',
          textDirection: TextDirection.ltr,
          style: TextStyle(fontFamily: 'CormorantGaramond', fontWeight: FontWeight.w500, fontSize: 44 * scale, letterSpacing: 14 * scale, height: 1, color: color)),
      SizedBox(height: 10 * scale),
      Text('BEAUTY  LAB',
          textDirection: TextDirection.ltr,
          style: TextStyle(fontFamily: 'Jost', fontWeight: FontWeight.w400, fontSize: 11.5 * scale, letterSpacing: 7 * scale, color: color.withValues(alpha: 0.8))),
    ]);
  }
}
