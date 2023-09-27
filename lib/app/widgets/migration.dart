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
  late AppLoadingScreenState loader = AppLoadingScreen.of(context);
  final int version = 2;

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

    File sentinel = await _getMigrationSentinel();

    if (sentinel.existsSync()) {
      String version = sentinel.readAsStringSync();
      if (int.tryParse(version) == this.version) {
        return;
      }

      return restartMigration();
    }

    loader.message = 'Migrating follows...';

    String followDbName = 'follows.sqlite';
    if (File(join((await getApplicationSupportDirectory()).path, followDbName))
        .existsSync()) {
      await migrateFollows(connectDatabase(followDbName), storage);
      // TODO: enable deletion once this is tested
      // File(followDbName).deleteSync();
    }

    loader.message = 'Migrating history...';

    String historyDbName = 'history.sqlite';
    if (File(join((await getApplicationSupportDirectory()).path, historyDbName))
        .existsSync()) {
      await migrateHistory(connectDatabase(historyDbName), storage);
      // TODO: enable deletion once this is tested
      // File(historyDbName).deleteSync();
    }

    loader.message = null;
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

    await File(join((await getApplicationSupportDirectory()).path, 'app.db'))
        .delete();

    await (await _getMigrationSentinel()).delete();

    loader.message = 'Please restart the app';
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
