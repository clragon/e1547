import 'dart:async';
import 'dart:io';
import 'dart:isolate';

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
    _initialize();
  }

  final File file;
  final StreamController<LogRecord> _stream = StreamController();

  Future<void> _initialize() async {
    ReceivePort receivePort = ReceivePort();
    Isolate isolate = await Isolate.spawn(
      _write,
      _FilePrinterConfig(port: receivePort.sendPort, file: file),
    );
    SendPort sendPort = await receivePort.first;
    receivePort.close();
    _stream.stream.listen(
      (event) => sendPort.send(event.toFullString()),
      onDone: () {
        isolate.kill();
      },
    );
  }

  static void _write(_FilePrinterConfig config) async {
    ReceivePort port = ReceivePort();
    config.port.send(port.sendPort);
    IOSink sink = config.file.openWrite(mode: FileMode.append);
    await for (final message in port) {
      sink.writeln(message);
    }
    await sink.flush();
    await sink.close();
    port.close();
  }

  @override
  void onLog(LogRecord record) => _stream.add(record);

  void close() => _stream.close();
}

class _FilePrinterConfig {
  _FilePrinterConfig({
    required this.port,
    required this.file,
  });

  final SendPort port;
  final File file;
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
