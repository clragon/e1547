import 'dart:io';
import 'dart:isolate';
import 'package:drift/drift.dart';
import 'package:drift/isolate.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void initializeSql() {
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
}

LazyDatabase openDatabase(String name) => LazyDatabase(
      () async {
        final dir = await getApplicationSupportDirectory();
        final file = File(join(dir.path, name));
        return NativeDatabase(file);
      },
    );

DatabaseConnection connectDatabase(String name) => DatabaseConnection.delayed(
      () async {
        final isolate = await _createDriftIsolate(name);
        return isolate.connect();
      }(),
    );

Future<DriftIsolate> _createDriftIsolate(String name) async {
  final dir = await getApplicationSupportDirectory();
  final path = join(dir.path, name);
  final receivePort = ReceivePort();
  await Isolate.spawn(
    _startBackground,
    _DriftIsolateData(receivePort.sendPort, path),
  );

  return await receivePort.first as DriftIsolate;
}

void _startBackground(_DriftIsolateData data) {
  final executor = NativeDatabase(File(data.path));
  final driftIsolate = DriftIsolate.inCurrent(
    () => DatabaseConnection(executor),
  );
  data.port.send(driftIsolate);
}

class _DriftIsolateData {
  _DriftIsolateData(this.port, this.path);

  final SendPort port;
  final String path;
}
