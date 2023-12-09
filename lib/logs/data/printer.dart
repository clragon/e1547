import 'dart:async';
import 'dart:io';

import 'package:e1547/logs/logs.dart';

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
  const ConsoleLogPrinter();

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

  String wrapWithColor(String message, Level level) {
    if (Platform.isWindows) {
      return message;
    }
    return '${getColor(level)}$message\x1B[0m';
  }

  @override
  void onLog(LogRecord record) {
    if (record.level >= Level.SEVERE) {
      stderr.writeln(wrapWithColor(record.toFullString(), record.level));
    } else {
      stdout.writeln(wrapWithColor(record.toFullString(), record.level));
    }
  }
}
