import 'package:flutter/material.dart';
import 'package:komodo_dex/widgets/theme_data.dart';

class CandlesIcon extends StatelessWidget {
  const CandlesIcon({
    this.size = 12,
    this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      child: CustomPaint(painter: _IconPainter(color ?? cexColor)),
    );
  }
}

class _IconPainter extends CustomPainter {
  _IconPainter(
    this.color,
  );

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(size.width / 3, size.height / 6),
        Offset(size.width / 3, size.height / 3), paint);
    canvas.drawRect(
        Rect.fromLTRB(size.width / 6 + (size.width / 12), size.height / 3,
            size.width / 2 - size.width / 12, 5 * size.height / 6),
        paint);
    canvas.drawLine(Offset(size.width / 3, 5 * size.height / 6),
        Offset(size.width / 3, size.height), paint);

    paint.style = PaintingStyle.stroke;

    canvas.drawRect(
        Rect.fromLTRB(size.width / 6 + (size.width / 12), size.height / 3,
            size.width / 2 - size.width / 12, 5 * size.height / 6),
        paint);

    canvas.drawLine(Offset(2 * size.width / 3, 0),
        Offset(2 * size.width / 3, size.height / 6), paint);
    canvas.drawRect(
        Rect.fromLTRB(size.width / 2 + (size.width / 12), size.height / 6,
            2 * size.width / 3 + size.width / 12, 2 * size.height / 3),
        paint);
    canvas.drawLine(Offset(2 * size.width / 3, 2 * size.height / 3),
        Offset(2 * size.width / 3, 5 * size.height / 6), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
