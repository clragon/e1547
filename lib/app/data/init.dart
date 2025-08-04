import 'dart:io';

import 'package:drift_flutter/drift_flutter.dart';
import 'package:e1547/app/data/storage.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http_cache_drift_store/http_cache_drift_store.dart';
import 'package:notified_preferences/notified_preferences.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

typedef AppInitBundle = ({SettingsService settings, AppStorage storage});

Future<AppInitBundle> initApp() async {
  final settings = await SettingsService.init();
  final storage = await initializeAppStorage();
  return (settings: settings, storage: storage);
}

Future<AppStorage> initializeAppStorage({bool cache = true}) async {
  final String temporaryFiles = await getTemporaryAppDirectory();
  await cleanupImageCache();
  return AppStorage(
    preferences: await SharedPreferences.getInstance(),
    temporaryFiles: temporaryFiles,
    httpCache: cache ? DriftCacheStore(databasePath: temporaryFiles) : null,
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
