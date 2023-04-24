import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_loggy/flutter_loggy.dart';
import 'package:loggy/loggy.dart';

export 'package:loggy/loggy.dart';

/// Initializes the Logging of the app. Registers the flutter error handler to print to logs.
/// Returns a Logs instance which can be used to access all log records.
Future<Logs> initializeLogger() async {
  MemoryLogs logs = MemoryLogs(child: const ConsolePrinter());
  Loggy.initLoggy(
    logPrinter: logs,
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

/// Holds application logs
abstract class Logs {
  /// All log records that have been emitted
  List<LogRecord> get records;

  /// Stream of all log records.
  /// Will emit all records on first subscription.
  Stream<List<LogRecord>> stream({
    bool Function(LogLevel level, Type type)? filter,
  });
}

class MemoryLogs implements Logs, LoggyPrinter {
  /// Keeps logs in memory. Passes all entries through to [child].
  factory MemoryLogs({LoggyPrinter? child}) {
    if (child != null) {
      MemoryLogs._instance._children.add(child);
    }
    return MemoryLogs._instance;
  }

  MemoryLogs._internal();

  static final MemoryLogs _instance = MemoryLogs._internal();
  final List<LoggyPrinter> _children = [];

  @override
  final List<LogRecord> records = [];

  final StreamController<List<LogRecord>> _stream =
      StreamController.broadcast();

  @override
  Stream<List<LogRecord>> stream({
    bool Function(LogLevel level, Type type)? filter,
  }) {
    late StreamController<List<LogRecord>> controller;
    controller = StreamController(
      onListen: () async {
        controller.add(records);
        controller.addStream(_stream.stream);
      },
      onCancel: () => controller.close(),
    );
    Stream<List<LogRecord>> stream = controller.stream;
    if (filter != null) {
      stream = stream.map(
        (e) => e.where((v) => filter(v.level, v.runtimeType)).toList(),
      );
    }
    return stream
        .distinct((a, b) => !const DeepCollectionEquality().equals(a, b));
  }

  @override
  void onLog(LogRecord record) {
    records.add(record);
    _stream.add(records);
    for (final printer in _children) {
      printer.onLog(record);
    }
  }

  void dispose() {
    _stream.close();
  }
}

const LogLevel logLevelCritical = LogLevel('Critical', 32);

class ConsolePrinter extends PrettyDeveloperPrinter {
  const ConsolePrinter();

  @override
  String? levelPrefix(LogLevel level) {
    if (level.priority == logLevelCritical.priority) {
      return '😱 ';
    }
    return super.levelPrefix(level);
  }
}

/// Provides a logger that identifies its class by its hashCode.
mixin ObjectLoggy implements LoggyType {
  @override
  Loggy<ObjectLoggy> get loggy => Loggy<ObjectLoggy>('$runtimeType#$hashCode');
}

class RouteLoggerObserver extends NavigatorObserver {
  final Loggy loggy = Loggy('Routes');

  void logRoute(Route<dynamic>? route, String action) {
    if (route == null) return;
    String? name = route.settings.name;
    if (name == null) {
      if (route is PageRoute) {
        name = 'A page';
      } else if (route is ModalRoute) {
        name = 'A modal';
      }
    }
    name ??= 'A route';
    loggy.debug('$name $action');
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    logRoute(route, 'was pushed');
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    logRoute(route, 'was removed');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    logRoute(oldRoute, 'was replaced');
    logRoute(newRoute, 'has replaced');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    logRoute(route, 'was popped');
  }
}
