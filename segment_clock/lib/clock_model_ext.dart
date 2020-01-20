import 'package:flutter_clock_helper/model.dart';

extension StringExtension on ClockModel{
  String get temperatureFormatted => '${this.temperature.toInt()}${this.unitString}';
}