import 'dart:io';

import 'package:dio_cache_interceptor_db_store/dio_cache_interceptor_db_store.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/logs/logs.dart';
import 'package:flutter/widgets.dart';
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

Future<String> getTemporaryAppDirectory() => getTemporaryDirectory()
    .then((dir) => join(dir.path, AppInfo.instance.appName));

/// Initializes the logger used by the app with default production values.
Future<Logs> initializeLogger({
  required String path,
  String? postfix,
  List<LogPrinter>? printers,
}) async {
  Logger.root.level = Level.ALL;

  Logs logs = Logs();
  File logFile = createLogFile(path, postfix);

  printers ??= [];
  printers.add(logs);
  printers.add(FileLogPrinter(logFile));
  printers.add(const ConsoleLogPrinter());

  for (final printer in printers) {
    printer.connect(Logger.root.onRecord);
  }

  registerFlutterErrorHandler(
    (error, trace) => Logger('Flutter').log(
      Level.SHOUT,
      error,
      error,
      trace,
    ),
  );
  return logs;
}

File createLogFile(String directoryPath, String? postfix) {
  File logFile = File(join(directoryPath,
      '${logFileDateFormat.format(DateTime.now())}${postfix != null ? '.$postfix' : ''}.log'));

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
  return AppStorage(
    preferences: await SharedPreferences.getInstance(),
    temporaryFiles: temporaryFiles,
    httpCache: cache ? DbCacheStore(databasePath: temporaryFiles) : null,
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

/// Returns an initialized WindowManager or null the current Platform is unsupported.
Future<WindowManager?> initializeWindowManager() async {
  if ([Platform.isWindows, Platform.isLinux, Platform.isMacOS].any((e) => e)) {
    WindowManager manager = WindowManager.instance;
    await manager.ensureInitialized();
    return manager;
  }
  return null;
}
