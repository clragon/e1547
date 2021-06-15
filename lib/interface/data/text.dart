import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LowercaseTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue prev, TextEditingValue current) {
    return current.copyWith(text: current.text.toLowerCase());
  }
}

void setFocusToEnd(TextEditingController controller) {
  controller.selection = TextSelection(
    baseOffset: controller.text.length,
    extentOffset: controller.text.length,
  );
}

String formatBytes(int bytes, int decimals) {
  if (bytes <= 0) return "0 B";
  List<String> suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
  int i = (log(bytes) / log(1024)).floor();
  return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + ' ' + suffixes[i];
}

String getAge(String date) {
  Duration duration = DateTime.now().difference(DateTime.parse(date).toLocal());

  List<int> periods = [
    1,
    60,
    3600,
    86400,
    604800,
    2419200,
    29030400,
  ];

  int ago;
  String measurement;
  for (int period = 0; period <= periods.length; period++) {
    if (period == periods.length || duration.inSeconds < periods[period]) {
      if (period != 0) {
        ago = (duration.inSeconds / periods[period - 1]).round();
      } else {
        ago = duration.inSeconds;
      }
      bool single = (ago == 1);
      switch (periods[period - 1] ?? 1) {
        case 1:
          measurement = single ? 'second' : 'seconds';
          break;
        case 60:
          measurement = single ? 'minute' : 'minutes';
          break;
        case 3600:
          measurement = single ? 'hour' : 'hours';
          break;
        case 86400:
          measurement = single ? 'day' : 'days';
          break;
        case 604800:
          measurement = single ? 'week' : 'weeks';
          break;
        case 2419200:
          measurement = single ? 'month' : 'months';
          break;
        case 29030400:
          measurement = single ? 'year' : 'years';
          break;
      }
      break;
    }
  }
  return '$ago $measurement ago';
}
