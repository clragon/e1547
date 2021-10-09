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

DateFormat getCurrentDateFormat() =>
    DateFormat.yMd(Platform.localeName).add_jm();

extension Trimming on List<String> {
  List<String> trim() => map((e) => e.trim()).toList();
}
