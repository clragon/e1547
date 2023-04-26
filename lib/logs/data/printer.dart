import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:e1547/logs/logs.dart';
import 'package:flutter_loggy/flutter_loggy.dart';

class MultiLoggyPrinter implements LoggyPrinter {
  const MultiLoggyPrinter(this.children);

  final List<LoggyPrinter> children;

  @override
  void onLog(LogRecord record) {
    for (final printer in children) {
      printer.onLog(record);
    }
  }
}

class MemoryLogs implements Logs, LoggyPrinter {
  /// Keeps logs in memory.
  MemoryLogs();

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
    return stream.distinct(const DeepCollectionEquality().equals);
  }

  @override
  void onLog(LogRecord record) {
    records.add(record);
    _stream.add(records);
  }

  void dispose() {
    _stream.close();
  }
}

class FilePrinter implements LoggyPrinter {
  FilePrinter(this.file) {
    _write();
  }

  final File file;
  final StreamController<LogRecord> _stream = StreamController();

  void _write() async {
    await for (final record in _stream.stream) {
      await file.writeAsString(
        '${record.toFullString()}\n',
        mode: FileMode.append,
      );
    }
  }

  @override
  void onLog(LogRecord record) => _stream.add(record);
}

const LogLevel logLevelCritical = LogLevel('Critical', 32);

class ConsoleLoggyPrinter extends PrettyDeveloperPrinter {
  const ConsoleLoggyPrinter();

  @override
  String? levelPrefix(LogLevel level) {
    if (level.priority == logLevelCritical.priority) {
      return '😱 ';
    }
    return super.levelPrefix(level);
  }
}
