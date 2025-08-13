import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart' as intl_dates;
import 'package:intl/intl.dart';

/// Primitive default date formatting.
/// Has no translation support.
abstract final class DateFormatting {
  static Future<void> ensureInitialized() =>
      intl_dates.initializeDateFormatting();

  static String dateTime(DateTime dateTime) =>
      DateFormat.yMd(Platform.localeName).add_jm().format(dateTime);
  static String date(DateTime date) =>
      DateFormat.yMd(Platform.localeName).format(date);
  static String time(DateTime time) =>
      DateFormat.jm(Platform.localeName).format(time);

  static String named(DateTime date) {
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
    return DateFormatting.date(date);
  }
}
