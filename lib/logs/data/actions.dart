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

final DateFormat logFileDateFormat = DateFormat('yyyy-MM-dd-hh-mm-ss-SSS');

String getLogFileName(String path) {
  String raw = basenameWithoutExtension(path);
  String type = extension(raw);
  if (type.isNotEmpty) {
    raw = basenameWithoutExtension(raw);
  }
  DateTime date = logFileDateFormat.parse(raw);
  return '${formatDateTime(date)} ${type.isNotEmpty ? ' ($type)' : ''}';
}
