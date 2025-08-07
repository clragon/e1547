import 'dart:io';

import 'package:drift_flutter/drift_flutter.dart';
import 'package:e1547/about/about.dart';
import 'package:e1547/app/data/storage.dart';
import 'package:e1547/domain/domain.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:notified_preferences/notified_preferences.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

typedef AppInitBundle = ({SettingsService settings, AppStorage storage});

Future<AppInitBundle> initApp() async {
  final (_, settings, storage) = await (
    initializeAppInfo(),
    SettingsService.init(),
    initializeAppStorage(),
  ).wait;

  return (settings: settings, storage: storage);
}

Future<void> initializeAppInfo() => About.initializePlatform(
  developer: 'binaryfloof',
  github: 'clragon/e1547',
  discord: 'MRwKGqfmUz',
  website: 'e1547.clynamic.net',
  kofi: 'binaryfloof',
  email: 'support@clynamic.net',
);

Future<AppStorage> initializeAppStorage() async {
  final String temporaryFiles = await getTemporaryAppDirectory();
  await cleanupImageCache();
  return AppStorage(
    preferences: await SharedPreferences.getInstance(),
    temporaryFiles: temporaryFiles,
    clientCache: ClientCache(),
    sqlite: AppDatabase(
      driftDatabase(
        name: 'app',
        native: DriftNativeOptions(
          shareAcrossIsolates: true,
          databasePath: () => getApplicationSupportDirectory().then(
            (dir) => join(dir.path, 'app.db'),
          ),
        ),
      ),
    ),
  );
}

Future<String> getTemporaryAppDirectory() =>
    getTemporaryDirectory().then((dir) => join(dir.path, 'e1547'));

/// Workaround for flutter_cache_manager not evicting files properly.
/// See: https://github.com/Baseflow/flutter_cache_manager/issues/476
Future<void> cleanupImageCache({
  Duration stalePeriod = const Duration(days: 1),
}) async {
  final base = await getTemporaryDirectory();
  final cacheDir = Directory(join(base.path, DefaultCacheManager.key));
  if (!cacheDir.existsSync()) return;

  final staleBefore = DateTime.now().subtract(stalePeriod);

  await for (final entity in cacheDir.list()) {
    if (entity is! File) continue;

    try {
      final stat = entity.statSync();
      if (stat.modified.isBefore(staleBefore)) {
        await entity.delete();
      }
    } on FileSystemException {
      // ignore
    }
  }
}
