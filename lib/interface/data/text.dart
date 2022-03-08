import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

Color dimTextColor(BuildContext context, [double opacity = 0.35]) =>
    Theme.of(context).textTheme.bodyText2!.color!.withOpacity(opacity);

int notZero(double value) => value < 1 ? 1 : value.round();

Key joinKeys(List<dynamic> keys) => Key(keys.join('_'));

class LowercaseTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toLowerCase());
  }
}

extension Selection on TextEditingController {
  void setFocusToEnd() {
    selection = TextSelection(
      baseOffset: text.length,
      extentOffset: text.length,
    );
  }
}

DateFormat getCurrentDateTimeFormat() =>
    DateFormat.yMd(Platform.localeName).add_jm();

DateFormat getCurrentDateFormat() => DateFormat.yMd(Platform.localeName);

DateFormat getCurrentTimeFormat() => DateFormat.jm(Platform.localeName);

String dateOrName(DateTime date) {
  String title = getCurrentDateFormat().format(date);
  DateTime today = DateTime.now().stripTime();
  if (today.isAtSameMomentAs(date.stripTime())) {
    title = 'Today';
  }
  if (today.subtract(Duration(days: 1)).isAtSameMomentAs(date.stripTime())) {
    title = 'Yesterday';
  }
  return title;
}

extension days on DateTime {
  DateTime stripTime() {
    return DateTime(year, month, day);
  }
}

extension Trimming on List<String> {
  List<String> trim() =>
      map((e) => e.trim()).toList()..removeWhere((element) => element.isEmpty);
}
