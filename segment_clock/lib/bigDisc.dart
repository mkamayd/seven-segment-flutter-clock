import 'package:flutter/material.dart';

class BigDisc extends AnimatedWidget {
  final Size size;
  const BigDisc({Key key, Animation<double> animation, @required this.size})
      : super(key: key, listenable: animation);

  Widget build(BuildContext context) {
    final Animation<double> animation = listenable;
    return CustomPaint(
      painter: BigDiscPainter(value: animation.value),
      size: this.size,
    );
  }
}

class BigDiscPainter extends CustomPainter {
  final double value;
  const BigDiscPainter({this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final rectFull = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Color(0x11FFFFFF)
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    canvas.drawRRect(RRect.fromRectXY(rectFull, value, value), paint);
  }

  @override
  bool shouldRepaint(BigDiscPainter oldDelegate) => oldDelegate.value != value;
  @override
  bool shouldRebuildSemantics(BigDiscPainter oldDelegate) => false;
}
