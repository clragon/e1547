import 'dart:io';
import 'dart:isolate';
import 'package:drift/drift.dart';
import 'package:drift/isolate.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

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
  final SendPort port;
  final String path;

  _DriftIsolateData(this.port, this.path);
}
