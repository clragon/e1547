import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:e1547/logs/logs.dart';
import 'package:flutter/foundation.dart';

export 'package:logging/logging.dart';

abstract class LogPrinter {
  LogPrinter();

  final List<StreamSubscription<LogRecord>> _subscriptions = [];

  /// Called when a log record is added.
  void onLog(LogRecord record);

  /// Called when the printer is no longer needed.
  void close() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
  }

  /// Connects this printer to a stream of log records.
  void connect(Stream<LogRecord> stream) {
    late StreamSubscription<LogRecord> subscription;
    subscription = stream.listen(
      onLog,
      onDone: () => _subscriptions.remove(subscription),
    );
    _subscriptions.add(subscription);
  }
}

/// Holds application logs
class Logs extends LogPrinter {
  Logs([this.printers = const []]);

  /// All log records that have been emitted
  List<LogRecord> get records => List.unmodifiable(_records);

  final List<LogRecord> _records = [];
  final List<LogPrinter> printers;

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

  static const int _maxRecords = 500;

  void _truncate() {
    if (_records.length > _maxRecords) {
      _records.removeRange(0, _records.length - _maxRecords);
    }
  }

  @override
  void onLog(LogRecord record) {
    _records.add(record);
    _stream.add(records);
    _truncate();
  }

  @override
  void connect(Stream<LogRecord> stream) {
    super.connect(stream);
    for (final printer in printers) {
      printer.connect(stream);
    }
  }
}

class FileLogPrinter extends LogPrinter {
  FileLogPrinter(this.file) {
    _write();
  }

  final File file;
  final StreamController<LogRecord> _stream = StreamController();

  void _write() async {
    IOSink sink = file.openWrite(mode: FileMode.append);
    await for (final record in _stream.stream) {
      sink.writeln(record.toFullString());
    }
    sink.close();
  }

  @override
  void onLog(LogRecord record) => _stream.add(record);

  @override
  void close() => _stream.close();
}

class ConsoleLogPrinter extends LogPrinter {
  ConsoleLogPrinter();

  String getColor(Level level) {
    switch (level) {
      case Level.SEVERE:
        return '\x1B[31m';
      case Level.WARNING:
        return '\x1B[33m';
      case Level.INFO:
        return '\x1B[34m';
      case Level.FINE:
        return '\x1B[90m';
      case Level.FINER:
        return '\x1B[90m';
      case Level.FINEST:
        return '\x1B[90m';
      default:
        return '\x1B[0m';
    }
  }

  String wrapWithColor(String message, Level level) =>
      '${getColor(level)}$message\x1B[0m';

  @override
  void onLog(LogRecord record) =>
      debugPrint(wrapWithColor(record.toFullString(), record.level));
}
