import 'dart:io';

import 'package:drift_flutter/drift_flutter.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/logs/logs.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http_cache_drift_store/http_cache_drift_store.dart';
import 'package:notified_preferences/notified_preferences.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

export 'package:e1547/logs/logs.dart' show Logs;
export 'package:e1547/settings/settings.dart' show AppInfo;
export 'package:window_manager/window_manager.dart' show WindowManager;

/// Initializes an AppInfo with default production values.
Future<void> initializeAppInfo() => AppInfo.initializePlatform(
  developer: 'binaryfloof',
  github: 'clragon/e1547',
  discord: 'MRwKGqfmUz',
  website: 'e1547.clynamic.net',
  kofi: 'binaryfloof',
  email: 'support@clynamic.net',
);

Future<String> getTemporaryAppDirectory() => getTemporaryDirectory().then(
  (dir) => join(dir.path, AppInfo.instance.appName),
);

Future<String> getAppDatabasePath() =>
    getApplicationSupportDirectory().then((dir) => join(dir.path, 'app.db'));

/// Initializes the logger used by the app with default production values.
Future<Logs> initializeLogger({
  String? path,
  String? postfix,
  List<LogPrinter>? printers,
}) async {
  Logger.root.level = Level.ALL;
  path ??= await getTemporaryAppDirectory();

  final logFile = createLogFile(path, postfix);
  final logs = Logs([
    ...?printers,
    FileLogPrinter(logFile),
    ConsoleLogPrinter(),
  ]);

  logs.connect(Logger.root.onRecord);

  registerFlutterErrorHandler(
    (error, trace) => Logger('Flutter').log(Level.SHOUT, error, error, trace),
  );
  return logs;
}

File createLogFile(String directoryPath, String? postfix) {
  File logFile = File(
    join(
      directoryPath,
      '${logFileDateFormat.format(DateTime.now())}${postfix != null ? '.$postfix' : ''}.log',
    ),
  );

  Directory dir = Directory(directoryPath);
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }
  List<File> logFiles = dir
      .listSync()
      .whereType<File>()
      .where((entity) => entity.path.endsWith('.log'))
      .toList();

  DateTime getFileDate(String fileName) {
    var name = basenameWithoutExtension(fileName);
    return logFileDateFormat.parse(name);
  }

  logFiles.sort((a, b) => getFileDate(b.path).compareTo(getFileDate(a.path)));

  if (logFiles.length > 50) {
    for (final oldFile in logFiles.sublist(10)) {
      oldFile.deleteSync();
    }
  }

  return logFile;
}

/// Registers an error callback for uncaught exceptions and flutter errors.
void registerFlutterErrorHandler(
  void Function(Object error, StackTrace? trace) handler,
) {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
    handler(error, stack);
    return false;
  };
  FlutterError.onError = (details) => handler(details.exception, details.stack);
}

/// Initializes the storages used by the app with default production values.
Future<AppStorage> initializeAppStorage({bool cache = true}) async {
  final String temporaryFiles = await getTemporaryAppDirectory();
  cleanupImageCache();
  await completeDbImport();
  return AppStorage(
    preferences: await SharedPreferences.getInstance(),
    temporaryFiles: temporaryFiles,
    httpCache: cache ? DriftCacheStore(databasePath: temporaryFiles) : null,
    sqlite: AppDatabase(
      driftDatabase(
        name: 'app',
        native: const DriftNativeOptions(
          shareAcrossIsolates: true,
          databasePath: getAppDatabasePath,
        ),
      ),
    ),
  );
}

Future<void> completeDbImport() async {
  final dbPath = await getAppDatabasePath();
  final newDbPath = '$dbPath.new';
  final newDbFile = File(newDbPath);

  if (newDbFile.existsSync()) {
    final oldDbFile = File(dbPath);
    try {
      if (oldDbFile.existsSync()) {
        await oldDbFile.delete();
      }
      await newDbFile.rename(dbPath);
    } on Exception {
      await newDbFile.copy(dbPath);
      await newDbFile.delete();
    }
  }
}

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

/// Returns an initialized WindowManager or null the current Platform is unsupported.
Future<WindowManager?> initializeWindowManager() async {
  if ([Platform.isWindows, Platform.isLinux, Platform.isMacOS].any((e) => e)) {
    WindowManager manager = WindowManager.instance;
    await manager.ensureInitialized();
    return manager;
  }
  return null;
}
