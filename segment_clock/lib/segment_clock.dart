import 'dart:async';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'discs.dart';
import 'disc.dart';
import 'bigDisc.dart';
import 'clock_model_ext.dart';

import 'dart:math';

enum _Element {
  background,
  activeText,
  offText,
  strokeText,
}

final _lightTheme = {
  _Element.background: Color(0XFF0CB8E8),
  _Element.activeText: Color(0XFFFFFBEC),
  _Element.offText: Color(0XFFE8DFCC),
  _Element.strokeText: Color(0XFF003FF5),
};

final _darkTheme = {
  _Element.background: Colors.black,
  _Element.activeText: Color(0XFF1FF518),
  _Element.offText: Color(0XFF47DC42),
  _Element.strokeText: Color(0XFF30592D),
};

class SegmentClock extends StatefulWidget {
  const SegmentClock(this.model);

  final ClockModel model;

  @override
  _SegmentClockState createState() => _SegmentClockState();
}

class _SegmentClockState extends State<SegmentClock>
    with TickerProviderStateMixin {
  DateTime _dateTime = DateTime.now();
  Timer _timer;
  Animation<double> animationCircle;
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _controller =
        AnimationController(duration: Duration(seconds: 5), vsync: this);

    final curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
      reverseCurve: Curves.easeOut,
    );

    animationCircle =
        Tween<double>(begin: 10, end: 500).animate(curvedAnimation)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _controller.reverse();
            } else if (status == AnimationStatus.dismissed) {
              _controller.forward();
            }
          });

    _controller.forward();
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(SegmentClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    _controller?.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {});
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
    });
  }

  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;
    Theme.of(context);
    final hourFormat = widget.model.is24HourFormat ? 'HH' : 'hh';
    var time = DateFormat('$hourFormat:mm').format(_dateTime);
    if (!widget.model.is24HourFormat && time[0] == '0') {
      time = time.substring(1);
    }
    final temperature = this.widget.model.temperatureFormatted;
    final secondsPercentage = _dateTime.second / 59;
    //Show pride colors at special times of the day.
    final showPride = [
          '1:11',
          '2:22',
          '3:33',
          '4:44',
          '5:55',
          '11:11',
          '22:22',
        ].contains(time) ||
        _dateTime.minute == 0;

    return LayoutBuilder(builder: (context, constraints) {
      final timeWidth = constraints.biggest.width / time.length;
      final timeSize =
          Size(timeWidth, min(constraints.biggest.height, timeWidth * 1.7));
      final temperatureWidth =
          constraints.biggest.width / 6 / temperature.length;
      final temperatureSize = Size(temperatureWidth, temperatureWidth * 1.7);
      return Container(
        color: colors[_Element.background],
        child: Stack(
          children: [
            BigDisc(size: constraints.biggest, animation: animationCircle),
            SizedBox.expand(
              child: CentralDiscs(3),
            ),
            SizedBox.expand(
              child: VariousDiscs(50),
            ),
            Positioned(
              top: temperatureSize.height / 2,
              left: constraints.biggest.width / 2 -
                  (temperatureSize.width * (temperature.length - 2) +
                      temperatureSize.width / 2),
              child: DigitText(
                value: temperature,
                secondsPercentage: 1,
                size: temperatureSize,
                showPride: showPride,
                colors: colors,
              ),
            ),
            Center(
              child: DigitText(
                value: time,
                secondsPercentage: secondsPercentage,
                size: timeSize,
                showPride: showPride,
                colors: colors,
              ),
            ),
            SizedBox.expand(
              child: VariousDiscs(10),
            ),
          ],
        ),
      );
    });
  }
}

class DigitText extends StatelessWidget {
  const DigitText({
    Key key,
    @required this.value,
    @required this.secondsPercentage,
    @required this.size,
    @required this.showPride,
    @required this.colors,
  }) : super(key: key);

  final String value;
  final double secondsPercentage;
  final Size size;
  final bool showPride;
  final Map<_Element, Color> colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: value
          .split('')
          .map((d) => Digit(
                value: d,
                percentage: secondsPercentage,
                size: size,
                pride: showPride,
                activeText: colors[_Element.activeText],
                offText: colors[_Element.offText],
                strokeText: colors[_Element.strokeText],
              ))
          .toList(),
    );
  }
}

class Digit extends StatefulWidget {
  final String value;
  final Size size;
  final bool pride;
  final double percentage;
  final Color activeText;
  final Color offText;
  final Color strokeText;
  Digit(
      {@required this.value,
      @required this.size,
      this.pride = false,
      this.percentage = 1,
      this.activeText = Colors.white,
      this.offText = Colors.grey,
      this.strokeText = Colors.black12});

  @override
  _DigitState createState() => _DigitState();
}

class _DigitState extends State<Digit> {
  Segments segments(String d) {
    switch (d) {
      case '0':
        return Segments(a: true, b: true, c: true, d: true, e: true, f: true);
      case '1':
        return Segments(b: true, c: true);
      case '2':
        return Segments(a: true, b: true, d: true, e: true, g: true);
      case '3':
        return Segments(a: true, b: true, c: true, d: true, g: true);
      case '4':
        return Segments(b: true, c: true, f: true, g: true);
      case '5':
        return Segments(a: true, c: true, d: true, f: true, g: true);
      case '6':
        return Segments(a: true, c: true, d: true, e: true, f: true, g: true);
      case '7':
        return Segments(a: true, b: true, c: true);
      case '8':
        return Segments(
            a: true, b: true, c: true, d: true, e: true, f: true, g: true);
      case '9':
        return Segments(a: true, b: true, c: true, f: true, g: true);
      case '°':
        return Segments(dot: true);
      case 'c':
      case 'C':
        return Segments(a: true, d: true, e: true, f: true);
      case 'f':
      case 'F':
        return Segments(a: true, e: true, f: true, g: true);
      case '-':
        return Segments(g: true);
      case '0':
        return Segments(
          a: true,
          b: true,
          c: true,
          d: true,
          e: true,
          f: true,
        );
      case ':':
        return Segments(dots: true);
      default:
        return Segments();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DigitPainter(
        segments: segments(widget.value),
        prideColors: widget.pride,
        percentage: widget.percentage,
        activeText: widget.activeText,
        offText: widget.offText,
        strokeText: widget.strokeText,
      ),
      size: widget.size,
    );
  }
}

class Segments {
  final bool a;
  final bool b;
  final bool c;
  final bool d;
  final bool e;
  final bool f;
  final bool g;
  final bool dots;
  final bool dot;
  Segments(
      {this.a = false,
      this.b = false,
      this.c = false,
      this.d = false,
      this.e = false,
      this.f = false,
      this.g = false,
      this.dots = false,
      this.dot = false});
}

class DigitPainter extends CustomPainter {
  final Segments segments;
  final bool prideColors;
  final double percentage;
  final Color activeText;
  final Color offText;
  final Color strokeText;
  final double strokeFraction;
  DigitPainter(
      {this.segments,
      this.activeText = Colors.white,
      this.offText = Colors.grey,
      this.strokeText = Colors.black12,
      this.strokeFraction = 5,
      this.prideColors = false,
      this.percentage = 1});

  void drawSegment(Canvas canvas, double strokeWith, Offset p1, Offset p2,
      Paint paint, Paint strokePaint) {
    bool horizontal = p1.dy == p2.dy;
    List<Offset> points = [p1];

    if (horizontal) {
      Offset u1 = p1.translate(strokeWith / 2, -strokeWith / 2);
      points.add(u1);
      Offset u2 = p2.translate(-strokeWith / 2, -strokeWith / 2);
      points.add(u2);
      points.add(p2);
      Offset d2 = p2.translate(-strokeWith / 2, strokeWith / 2);
      points.add(d2);
      Offset d1 = p1.translate(strokeWith / 2, strokeWith / 2);
      points.add(d1);
    } else {
      Offset r1 = p1.translate(-strokeWith / 2, strokeWith / 2);
      points.add(r1);
      Offset r2 = p2.translate(-strokeWith / 2, -strokeWith / 2);
      points.add(r2);
      points.add(p2);
      Offset l2 = p2.translate(strokeWith / 2, -strokeWith / 2);
      points.add(l2);
      Offset l1 = p1.translate(strokeWith / 2, strokeWith / 2);
      points.add(l1);
    }

    Path path = Path();
    path.addPolygon(points, true);
    canvas.drawPath(path, paint);
    canvas.drawPath(path, strokePaint);
  }

  List<Color> getRainbowColors(int i) {
    const colors = [
      Color(0xFFE700005),
      Color(0xFFFF8C00),
      Color(0xFFFFEF00),
      Color(0xFF00811F),
      Color(0xFF0044FF),
      Color(0xFF760089)
    ];
    i = i % colors.length;
    return colors.sublist(i)..addAll(colors.sublist(0, i));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = min(size.width, size.height) / strokeFraction;
    final rectFull = Offset.zero & size;
    final rectDigit = rectFull.deflate(strokeWidth / 2);
    final rect = rectFull.deflate(strokeWidth);

    final segmentPaint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final strokePaint = Paint()
      ..strokeWidth = strokeWidth / 6
      ..color = this.strokeText
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    if (this.prideColors) {
      strokePaint.color = Colors.pink;
      segmentPaint.shader = LinearGradient(
              begin: Alignment(1, this.percentage),
              end: Alignment(this.percentage, -1),
              colors: getRainbowColors((60 * this.percentage).round()))
          .createShader(rectDigit);
    } else {
      final percentage = 1 - this.percentage;
      segmentPaint.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [this.offText, this.activeText],
        stops: [percentage, percentage],
        tileMode: TileMode.clamp,
      ).createShader(rectDigit);
    }

    if (segments.dots) {
      Offset dotsUp =
          Offset.lerp(rectDigit.topCenter, rectDigit.bottomCenter, 1 / 3);
      canvas.drawCircle(dotsUp, strokeWidth / 2, segmentPaint);
      canvas.drawCircle(dotsUp, strokeWidth / 2, strokePaint);
      Offset dotsDown =
          Offset.lerp(rectDigit.topCenter, rectDigit.bottomCenter, 2 / 3);
      canvas.drawCircle(dotsDown, strokeWidth / 2, segmentPaint);
      canvas.drawCircle(dotsDown, strokeWidth / 2, strokePaint);
    }
    if (segments.dot) {
      Offset dotsUp =
          Offset.lerp(rectDigit.topCenter, rectDigit.bottomCenter, 1 / 8);
      canvas.drawCircle(dotsUp, strokeWidth, segmentPaint);
      canvas.drawCircle(dotsUp, strokeWidth, strokePaint);
    }
    if (segments.a) {
      drawSegment(canvas, strokeWidth, rect.topLeft, rect.topRight,
          segmentPaint, strokePaint);
    }
    if (segments.b) {
      drawSegment(canvas, strokeWidth, rect.topRight, rect.centerRight,
          segmentPaint, strokePaint);
    }
    if (segments.c) {
      drawSegment(canvas, strokeWidth, rect.centerRight, rect.bottomRight,
          segmentPaint, strokePaint);
    }
    if (segments.d) {
      drawSegment(canvas, strokeWidth, rect.bottomLeft, rect.bottomRight,
          segmentPaint, strokePaint);
    }
    if (segments.e) {
      drawSegment(canvas, strokeWidth, rect.centerLeft, rect.bottomLeft,
          segmentPaint, strokePaint);
    }
    if (segments.f) {
      drawSegment(canvas, strokeWidth, rect.topLeft, rect.centerLeft,
          segmentPaint, strokePaint);
    }
    if (segments.g) {
      drawSegment(canvas, strokeWidth, rect.centerLeft, rect.centerRight,
          segmentPaint, strokePaint);
    }
  }

  @override
  bool shouldRepaint(DigitPainter oldDelegate) => false;
  @override
  bool shouldRebuildSemantics(DigitPainter oldDelegate) => false;
}
