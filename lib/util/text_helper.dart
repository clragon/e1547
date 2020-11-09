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

String noDash(String s) {
  if (s.isNotEmpty) {
    if (s[0] == '-' || s[0] == '~') {
      return s.substring(1);
    } else {
      return s;
    }
  }
  return '';
}
