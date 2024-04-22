import 'dart:async';
import 'dart:io';

import 'package:e1547/app/app.dart';
import 'package:e1547/follow/data/legacy.dart';
import 'package:e1547/history/data/legacy.dart';
import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub_provider/developer.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

class DatabaseMigrationProvider extends SingleChildStatefulWidget {
  const DatabaseMigrationProvider({super.key, super.child});

  static DatabaseMigrationProviderState? maybeOf(BuildContext context) =>
      context.findAncestorStateOfType<DatabaseMigrationProviderState>();

  static DatabaseMigrationProviderState of(BuildContext context) =>
      maybeOf(context)!;

  @override
  State<DatabaseMigrationProvider> createState() =>
      DatabaseMigrationProviderState();
}

class DatabaseMigrationProviderState
    extends SingleChildState<DatabaseMigrationProvider> {
  late Future<void> migration;
  late LoadingShellController loader = LoadingShell.of(context);
  final int version = 3;

  @override
  void initState() {
    super.initState();
    // ignore: deprecated_member_use_from_same_package
    runMigrations();
  }

  Future<File> _getMigrationSentinel() async {
    return File(join(
      (await getApplicationSupportDirectory()).path,
      'db_migration_done.flag',
    ));
  }

  @Deprecated('Migration will be removed in a future major version')
  Future<void> _runMigrations() async {
    AppStorage storage = context.read<AppStorage>();

    String followDbName = 'follows.sqlite';
    String historyDbName = 'history.sqlite';

    String dbDir = (await getApplicationSupportDirectory()).path;

    File followDb = File(join(dbDir, followDbName));
    File historyDb = File(join(dbDir, historyDbName));

    File sentinel = await _getMigrationSentinel();

    if (sentinel.existsSync()) {
      int? version = int.tryParse(sentinel.readAsStringSync());

      if (version == null || version == this.version) {
        return restartMigration();
      }

      if (version == 2 && this.version == 3) {
        if (followDb.existsSync()) {
          followDb.deleteSync();
        }
        if (historyDb.existsSync()) {
          historyDb.deleteSync();
        }
      } else {
        return restartMigration();
      }
    }

    loader.value = loader.value.copyWith(
      message: 'Migrating follows...',
    );

    try {
      if (followDb.existsSync()) {
        await migrateFollows(connectDatabase(followDb.path), storage);
        followDb.deleteSync();
      }
    } on Object catch (e) {
      loader.value = loader.value.copyWith(
        error: e,
      );
      rethrow;
    }

    loader.value = loader.value.copyWith(
      message: 'Migrating history...',
    );

    try {
      if (historyDb.existsSync()) {
        await migrateHistory(connectDatabase(historyDbName), storage);
        historyDb.deleteSync();
      }
    } on Object catch (e) {
      loader.value = loader.value.copyWith(
        error: e,
      );
    }

    loader.value = const LoadingShellState();
    sentinel.writeAsStringSync(version.toString());
  }

  @Deprecated('Migration will be removed in a future major version')
  Future<void> runMigrations() async {
    setState(() {
      migration = _runMigrations();
    });
    await migration;
  }

  @Deprecated('Migration will be removed in a future major version')
  Future<void> restartMigration() async {
    setState(() {
      // infinite loading
      migration = Completer().future;
    });

    AppStorage storage = context.read<AppStorage>();

    await storage.sqlite.close();

    try {
      await File(join((await getApplicationSupportDirectory()).path, 'app.db'))
          .delete();

      await (await _getMigrationSentinel()).delete();
    } on Object catch (e) {
      loader.value = loader.value.copyWith(
        error: e,
      );
      rethrow;
    }

    loader.value = loader.value.copyWith(
      message: 'Please restart the app',
    );
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return FutureBuilder(
      key: ValueKey(migration),
      future: migration,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Container(
            color: Theme.of(context).colorScheme.background,
          );
        }

        return child!;
      },
    );
  }
}
