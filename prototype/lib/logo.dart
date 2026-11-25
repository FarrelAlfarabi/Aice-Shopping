import 'package:flutter/material.dart' hide Text;
import 'i18n.dart';
import 'ui.dart';

/// Placeholder brand logo, drawn in code. It is NOT the real Aice logo.
/// This is the one place to swap: replace the body of [BrandLogo] with
/// `Image.asset('assets/brand/logo.png')` when the real logo is allowed.
class BrandLogo extends StatelessWidget {
  final double size;
  final bool showWordmark;
  const BrandLogo({super.key, this.size = 120, this.showWordmark = true});

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CustomPaint(painter: _MarkPainter()),
          ),
          if (showWordmark) ...[
            SizedBox(height: size * 0.16),
            Text('aice',
                style: TextStyle(
                    fontSize: size * 0.42,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                    color: C.pri)),
            Text('SHOPPING',
                style: TextStyle(
                    fontSize: size * 0.1,
                    fontWeight: FontWeight.w800,
                    letterSpacing: size * 0.04,
                    color: C.muted)),
          ],
        ],
      );
}

class _MarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width;
    // Rounded tile.
    final tile = RRect.fromRectAndRadius(
        Offset.zero & s, Radius.circular(w * 0.26));
    canvas.drawRRect(
        tile,
        Paint()
          ..shader = const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [C.pri, C.priDark])
              .createShader(Offset.zero & s));
    final white = Paint()..color = Colors.white;
    // Cone.
    final cone = Path()
      ..moveTo(w * 0.34, w * 0.52)
      ..lineTo(w * 0.66, w * 0.52)
      ..lineTo(w * 0.5, w * 0.86)
      ..close();
    canvas.drawPath(cone, white);
    // Two scoops.
    canvas.drawCircle(Offset(w * 0.5, w * 0.42), w * 0.17, white);
    canvas.drawCircle(Offset(w * 0.5, w * 0.27), w * 0.11, white);
    // Yellow cherry on top.
    canvas.drawCircle(Offset(w * 0.5, w * 0.14), w * 0.05, Paint()..color = C.acc);
    // Cone grid lines.
    final line = Paint()
      ..color = C.pri.withValues(alpha: 0.35)
      ..strokeWidth = w * 0.015;
    canvas.drawLine(Offset(w * 0.42, w * 0.52), Offset(w * 0.54, w * 0.74), line);
    canvas.drawLine(Offset(w * 0.58, w * 0.52), Offset(w * 0.46, w * 0.74), line);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
