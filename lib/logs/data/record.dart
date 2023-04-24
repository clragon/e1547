import 'dart:convert';

import 'package:e1547/logs/logs.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension LogRecordMessages on LogRecord {
  String get title => '$level | ${DateFormat('HH:mm:ss.SSS').format(time)}';

  String get body {
    StringBuffer buffer = StringBuffer();
    buffer.writeln('$loggerName: $message');
    if (error != null) {
      buffer.write(_prettyPrintObject(error!, header: 'Error'));
    }
    if (error != null && stackTrace != null) {
      buffer.write(_prettyPrintObject(stackTrace!, header: 'Stacktrace'));
    }
    return buffer.toString().trim();
  }

  String toFullString() => '$title | $body';

  String _prettyPrintObject(Object data, {String? header}) {
    StringBuffer buffer = StringBuffer();
    String value;

    try {
      final Object object = const JsonDecoder().convert(data.toString());
      const JsonEncoder json = JsonEncoder.withIndent('  ');
      value = '║  ${json.convert(object).replaceAll('\n', '\n║  ')}';
    } on Exception {
      value = '║  ${data.toString().replaceAll('\n', '\n║  ')}';
    }

    String fullHeader = header != null ? ' $header ' : '';
    buffer.writeln('╔$fullHeader${'═' * (90 - fullHeader.length)}╗');
    buffer.writeln('║');
    if (value.isNotEmpty) {
      buffer.writeln(value);
    }
    buffer.writeln('║');
    buffer.writeln('╚${'═' * 90}╝');
    return buffer.toString();
  }
}

extension LogLevelColor on LogLevel? {
  Color get color {
    switch (this) {
      case LogLevel.error:
        return Colors.red[400]!;
      case logLevelCritical:
        return Colors.red[800]!;
      case LogLevel.warning:
        return Colors.orange[400]!;
      case LogLevel.info:
        return Colors.green[400]!;
      case LogLevel.debug:
      default:
        return Colors.blue[400]!;
    }
  }
}
