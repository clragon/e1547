import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

int notZero(double value) => value < 1 ? 1 : value.round();

class LowercaseTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toLowerCase());
  }
}

void setFocusToEnd(TextEditingController controller) {
  controller.selection = TextSelection(
    baseOffset: controller.text.length,
    extentOffset: controller.text.length,
  );
}

DateFormat getCurrentDateTimeFormat() =>
    DateFormat.yMd(Platform.localeName).add_jm();

DateFormat getCurrentDateFormat() => DateFormat.yMd(Platform.localeName);

DateFormat getCurrentTimeFormat() => DateFormat.jm(Platform.localeName);

extension days on DateTime {
  DateTime stripTime() {
    return DateTime(year, month, day);
  }
}

extension Trimming on List<String> {
  List<String> trim() => map((e) => e.trim()).toList();
}
