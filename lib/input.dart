// TODO: why do we need this?


import 'package:flutter/services.dart'
    show TextInputFormatter, TextEditingValue;

class LowercaseTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue prev, TextEditingValue current) {
    return current.copyWith(text: current.text.toLowerCase());
  }
}
