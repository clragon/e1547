import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

DatabaseConnection openDatabase(String name) =>
    DatabaseConnection.delayed(Future(
      () async => DatabaseConnection(
        NativeDatabase(
          File(
            join((await getApplicationSupportDirectory()).path, name),
          ),
        ),
      ),
    ));

DatabaseConnection connectDatabase(String name) =>
    DatabaseConnection.delayed(Future(
      () async => NativeDatabase.createBackgroundConnection(
        File(
          join((await getApplicationSupportDirectory()).path, name),
        ),
      ),
    ));
