import 'package:path_provider/path_provider.dart';

Future<EnvironmentPaths> initializeEnvironmentPaths() async => EnvironmentPaths(
      temporaryDirectory: (await getTemporaryDirectory()).path,
      applicationSupportDirectory:
          (await getApplicationSupportDirectory()).path,
      applicationDocumentsDirectory:
          (await getApplicationDocumentsDirectory()).path,
    );

class EnvironmentPaths {
  EnvironmentPaths({
    required this.temporaryDirectory,
    required this.applicationSupportDirectory,
    required this.applicationDocumentsDirectory,
  });

  /// Path to the temporary directory on the device that is not backed up and is
  /// suitable for storing caches of downloaded files.
  ///
  /// Files in this directory may be cleared at any time. This does *not* return
  /// a new temporary directory. Instead, the caller is responsible for creating
  /// (and cleaning up) files or directories within this directory. This
  /// directory is scoped to the calling application.
  ///
  /// On iOS, this uses the `NSCachesDirectory` API.
  ///
  /// On Android, this uses the `getCacheDir` API on the context.
  String temporaryDirectory;

  /// Path to a directory where the application may place application support
  /// files.
  ///
  /// Use this for files you don’t want exposed to the user. Your app should not
  /// use this directory for user data files.
  ///
  /// On iOS, this uses the `NSApplicationSupportDirectory` API.
  /// If this directory does not exist, it is created automatically.
  ///
  /// On Android, this function uses the `getFilesDir` API on the context.
  String applicationSupportDirectory;

  /// Path to the directory where application can store files that are persistent,
  /// backed up, and not visible to the user, such as sqlite.db.
  ///
  /// On Android, this function throws an [UnsupportedError] as no equivalent
  /// path exists.
  String applicationDocumentsDirectory;
}
