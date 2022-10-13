import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

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

String formatDateTime(DateTime dateTime) =>
    DateFormat.yMd(Platform.localeName).add_jm().format(dateTime);
String formatDate(DateTime date) =>
    DateFormat.yMd(Platform.localeName).format(date);
String formatTime(DateTime time) =>
    DateFormat.jm(Platform.localeName).format(time);

String dateOrName(DateTime date) {
  String title = formatDate(date);
  DateTime today = DateUtils.dateOnly(DateTime.now());
  if (today.isAtSameMomentAs(DateUtils.dateOnly(date))) {
    title = 'Today';
  }
  if (today
      .subtract(const Duration(days: 1))
      .isAtSameMomentAs(DateUtils.dateOnly(date))) {
    title = 'Yesterday';
  }
  return title;
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
  List<String> trim() =>
      map((e) => e.trim()).toList()..removeWhere((element) => element.isEmpty);
}
