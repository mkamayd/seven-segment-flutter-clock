import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

class CentralDiscData {
  static final _rng = Random();

  double size;
  Color color;
  Alignment alignment;

  CentralDiscData() {
    color = Color.fromARGB(
      _rng.nextInt(40) + 12,
      200,
      100,
      _rng.nextInt(255),
    );
    size = _rng.nextDouble() * 500 + 10;
  }
}

class CentralDiscs extends StatefulWidget {
  final int numberOfDiscs;

  CentralDiscs(this.numberOfDiscs);

  @override
  _CentralDiscsState createState() => _CentralDiscsState();
}

class _CentralDiscsState extends State<CentralDiscs> {
  final _discs = <CentralDiscData>[];
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer(Duration(microseconds: 1), _updateTime);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateTime() {
    _makeDiscs();
    _timer = Timer(Duration(seconds: 10), _updateTime);
  }

  void _makeDiscs() {
    setState(() {
      _discs.clear();
      final diskCount = widget.numberOfDiscs;
      for (int i = 0; i < diskCount; i++) {
        _discs.add(CentralDiscData());
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
            child: Align(
              alignment: Alignment.center,
              child: AnimatedContainer(
                curve: Curves.easeInCirc,
                duration: Duration(seconds: 10),
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
