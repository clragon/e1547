import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LowercaseTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => newValue.copyWith(text: newValue.text.toLowerCase());
}

extension TextEditingSelectionMovement on TextEditingController {
  void setFocusToStart() =>
      selection = const TextSelection(baseOffset: 0, extentOffset: 0);

  void setFocusToEnd() => selection = TextSelection(
    baseOffset: text.length,
    extentOffset: text.length,
  );
}

extension StringEllipsing on String {
  String ellipse(int limit) {
    if (length > limit) {
      return '${split('').take(limit).join()}...';
    } else {
      return this;
    }
  }
}

extension StringNullifying on String {
  String? get nullWhenEmpty {
    if (trim().isEmpty) return null;
    return this;
  }
}

extension StringListTrimming on List<String> {
  /// Trims all strings in the list and removes empty strings.
  List<String> trim() =>
      map((e) => e.trim()).toList()..removeWhere((element) => element.isEmpty);
}

extension StringInfixRegexing on String {
  String get infixRegex => '.*${RegExp.escape(this)}.*';
}

String linkToDisplay(String link) {
  Uri? url = Uri.tryParse(link.trim());
  if (url == null) return link;
  List<String> allowed = ['v'];
  Map<String, dynamic> parameters = Map.of(url.queryParameters);
  parameters.removeWhere((key, value) => !allowed.contains(key));
  Uri newUrl = Uri(
    host: url.host,
    port: switch (url.port) {
      0 || 80 || 443 => null,
      _ => url.port,
    },
    path: url.path,
    queryParameters: parameters.isNotEmpty ? parameters : null,
  );
  String display = newUrl.toString();
  List<String> removed = [r'^///?', r'^www.', r'/$'];
  for (String pattern in removed) {
    display = display.replaceFirst(RegExp(pattern), '');
  }
  return display;
}
