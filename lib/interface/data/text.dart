import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart' as intl_dates;
import 'package:intl/intl.dart';

Future<void> initializeDateFormatting() async =>
    intl_dates.initializeDateFormatting();

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

String formatDateTime(DateTime dateTime) =>
    DateFormat.yMd(Platform.localeName).add_jm().format(dateTime);
String formatDate(DateTime date) =>
    DateFormat.yMd(Platform.localeName).format(date);
String formatTime(DateTime time) =>
    DateFormat.jm(Platform.localeName).format(time);

String dateOrName(DateTime date) {
  DateTime today = DateUtils.dateOnly(DateTime.now());
  if (today.isAtSameMomentAs(DateUtils.dateOnly(date))) {
    return 'Today';
  }
  if (today
      .subtract(const Duration(days: 1))
      .isAtSameMomentAs(DateUtils.dateOnly(date))) {
    return 'Yesterday';
  }
  if (today.subtract(const Duration(days: 7)).isBefore(date)) {
    return DateFormat.EEEE().format(date);
  }
  return formatDate(date);
}

extension Ellipse on String {
  String ellipse(int limit) {
    if (length > limit) {
      return '${split('').take(limit).join()}...';
    } else {
      return this;
    }
  }
}

extension Nullifying on String {
  String? get nullWhenEmpty {
    if (isEmpty) {
      return null;
    }
    return this;
  }
}

extension Trimming on List<String> {
  /// Trims all strings in the list and removes empty strings.
  List<String> trim() =>
      map((e) => e.trim()).toList()..removeWhere((element) => element.isEmpty);
}

String linkToDisplay(String link) {
  Uri url = Uri.parse(link.trim());
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
