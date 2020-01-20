import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

class DiscData {
  static final _rng = Random();

  double size;
  Color color;
  Alignment alignment;

  DiscData() {
    color = Color.fromARGB(
      _rng.nextInt(100),
      200,
      100,
      _rng.nextInt(255),
    );
    size = _rng.nextDouble() * 100 + 10;
    alignment = Alignment(
      _rng.nextDouble() * 2 - 1,
      _rng.nextDouble() * 2 - 1,
    );
  }
}

class VariousDiscs extends StatefulWidget {
  final int numberOfDiscs;

  VariousDiscs(this.numberOfDiscs);

  @override
  _VariousDiscsState createState() => _VariousDiscsState();
}

class _VariousDiscsState extends State<VariousDiscs> {
  final _discs = <DiscData>[];
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer(Duration(seconds: 0), _updateTime);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateTime() {
    _makeDiscs();
    _timer = Timer(Duration(seconds: 30), _updateTime);
  }

  void _makeDiscs() {
    setState(() {
      _discs.clear();
      final diskCount = widget.numberOfDiscs;
      for (int i = 0; i < diskCount; i++) {
        _discs.add(DiscData());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Stack(
      children: [
        for (final disc in _discs)
          Positioned.fill(
            child: AnimatedAlign(
              duration: Duration(seconds: 30),
              curve: Curves.easeInOut,
              alignment: disc.alignment,
              child: AnimatedContainer(
                duration: Duration(seconds: 30),
                decoration: BoxDecoration(
                  color: disc.color,
                  shape: BoxShape.circle,
                ),
                height: disc.size,
                width: disc.size,
              ),
            ),
          ),
      ],
    ));
  }
}
