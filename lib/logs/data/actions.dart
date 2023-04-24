import 'package:e1547/logs/logs.dart';
import 'package:flutter/widgets.dart';



/// Initializes the Logging of the app. Registers the flutter error handler to print to logs.
/// Returns a Logs instance which can be used to access all log records.
Future<Logs> initializeLogger({List<LoggyPrinter>? printers}) async {
  MemoryLogs logs = MemoryLogs();

  Loggy.initLoggy(
    logPrinter: MultiLoggyPrinter([
      logs,
      const ConsoleLoggyPrinter(),
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
