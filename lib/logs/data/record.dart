import 'dart:convert';

import 'package:e1547/logs/logs.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LogString {
  LogString({
    required this.time,
    required this.level,
    required this.loggerName,
    required this.body,
  });

  factory LogString.fromRecord(LogRecord record) {
    return LogString(
      time: record.time,
      level: record.level,
      loggerName: record.loggerName,
      body: _buildRecordMessage(record),
    );
  }

  static String _buildRecordMessage(LogRecord record) {
    StringBuffer buffer = StringBuffer();
    buffer.writeln('${record.loggerName}: ${record.message}');
    if (record.error != null) {
      buffer.write(prettyLogObject(record.error!, header: 'Error'));
    }
    if (record.error != null && record.stackTrace != null) {
      buffer.write(prettyLogObject(record.stackTrace!, header: 'Stacktrace'));
    }
    return buffer.toString().trim();
  }

  static List<LogString> parse(String value) {
    List<LogString> logs = [];
    RegExp fullRegex = RegExp(
      r'^\s*(?<level>'
      '(${logLevels.map((e) => e.name).join('|')})'
      r')\s*\|\s*(?<time>'
      r'\d{2}:\d{2}:\d{2}\.\d{3}'
      r')\s*\|\s*(?<loggerName>[^:\n]+?):',
      multiLine: true,
    );
    List<RegExpMatch> matches = fullRegex.allMatches(value).toList();
    for (int i = 0; i < matches.length; i++) {
      RegExpMatch match = matches[i];
      DateTime time =
          logStringDateFormat.parse(match.namedGroup('time')!.trim());
      LogLevel level = logLevels
          .singleWhere((e) => e.name == match.namedGroup('level')!.trim());
      String loggerName = match.namedGroup('loggerName')!.trim();
      RegExpMatch? next;
      if (i + 1 < matches.length) {
        next = matches[i + 1];
      }
      String body = value.substring(match.end, next?.start).trim();
      logs.add(LogString(
        time: time,
        level: level,
        loggerName: loggerName,
        body: body,
      ));
    }
    return logs;
  }

  final DateTime time;
  final LogLevel level;
  final String loggerName;
  final String body;

  String get title => '$level | ${logStringDateFormat.format(time)}';

  @override
  String toString() => '$title | $loggerName: $body';
}

final DateFormat logStringDateFormat = DateFormat('HH:mm:ss.SSS');

extension LogStringRecord on LogRecord {
  String toFullString() => LogString.fromRecord(this).toString();
}

String prettyLogObject(Object data, {String? header}) {
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

final List<LogLevel> logLevels = List.unmodifiable([
  LogLevel.debug,
  LogLevel.info,
  LogLevel.warning,
  LogLevel.error,
  logLevelCritical,
]);

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
