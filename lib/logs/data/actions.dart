import 'dart:io';
import 'package:e1547/app/app.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/logs/logs.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';

/// Initializes the Logging of the app. Registers the flutter error handler to print to logs.
/// Returns a Logs instance which can be used to access all log records.
Future<Logs> initializeLogger({
  required AppDatabases databases,
  String? postfix,
  List<LoggyPrinter>? printers,
}) async {
  MemoryLogs logs = MemoryLogs();
  File logFile = File(join(databases.temporaryFiles,
      '${logFileDateFormat.format(DateTime.now())}${postfix != null ? '.$postfix' : ''}.log'));
  Loggy.initLoggy(
    logPrinter: MultiLoggyPrinter([
      logs,
      const ConsoleLoggyPrinter(),
      FilePrinter(logFile),
      if (printers != null) ...printers,
    ]),
  );
  registerFlutterErrorHandler(
    (error, trace) => Loggy('Flutter').log(logLevelCritical, error, trace),
  );
  return logs;
}

/// Registers a callback for exceptions and flutter errors.
void registerFlutterErrorHandler(
    void Function(Object error, StackTrace? trace) handler) {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
    handler(error, stack);
    return false;
  };
  FlutterError.onError = (details) => handler(details.exception, details.stack);
}

final DateFormat logFileDateFormat = DateFormat('yyyy-MM-dd-HH-mm-ss-SSS');

class LogFileInfo {
  LogFileInfo({
    required this.path,
    required this.date,
    required this.type,
  });

  factory LogFileInfo.parse(String path) {
    String raw = basenameWithoutExtension(path);
    String? type = extension(raw);
    if (type.isNotEmpty) {
      type = type.substring(1);
      raw = basenameWithoutExtension(raw);
    } else {
      type = null;
    }
    DateTime date = logFileDateFormat.parse(raw);
    return LogFileInfo(path: path, date: date, type: type);
  }

  final String path;
  final DateTime date;
  final String? type;

  @override
  String toString() =>
      '${formatDateTime(date)} ${type != null ? ' ($type)' : ''}';
}
