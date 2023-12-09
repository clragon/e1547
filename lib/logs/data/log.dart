import 'dart:async';

import 'package:collection/collection.dart';
import 'package:logging/logging.dart';

export 'package:logging/logging.dart';

abstract class LogPrinter {
  const LogPrinter();

  /// Called when a log record is added.
  void onLog(LogRecord record);

  /// Called when the printer is no longer needed.
  void close() {}

  /// Connects this printer to a stream of log records.
  void connect(Stream<LogRecord> stream) => stream.listen(onLog, onDone: close);
}

/// Holds application logs
class Logs extends LogPrinter {
  /// All log records that have been emitted
  List<LogRecord> get records => List.unmodifiable(_records);

  final List<LogRecord> _records = [];

  final StreamController<List<LogRecord>> _stream =
      StreamController.broadcast();

  /// Stream of all log records.
  /// Will emit all records on first subscription.
  Stream<List<LogRecord>> stream({
    bool Function(Level level, Type type)? filter,
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
    return stream.distinct(const DeepCollectionEquality().equals);
  }

  @override
  void onLog(LogRecord record) {
    _records.add(record);
    _stream.add(records);
  }

  @override
  void close() {
    _stream.close();
  }
}
