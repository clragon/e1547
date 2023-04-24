import 'package:e1547/logs/logs.dart';

export 'package:flutter_loggy_dio/flutter_loggy_dio.dart';
export 'package:loggy/loggy.dart';

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

/// Provides a logger that identifies its class by its hashCode.
mixin ObjectLoggy implements LoggyType {
  @override
  Loggy<ObjectLoggy> get loggy => Loggy<ObjectLoggy>('$runtimeType#$hashCode');
}
