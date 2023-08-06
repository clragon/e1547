import 'dart:io';

/// Provides information about what features are available on this Platform.
abstract final class PlatformCapabilities {
  /// Whether this platform supports background workers.
  /// This returns false on iOS < 13 because the old API is unsupported.
  static bool get hasBackgroundWorker {
    if (Platform.isIOS) {
      final version = Platform.operatingSystemVersion.split(' ')[1];
      final majorVersion = int.parse(version.split('.')[0]);
      return majorVersion >= 13;
    }
    return [Platform.isAndroid].any((e) => e);
  }

  /// Whether this platform supports sending notifications.
  /// Note that this only returns true if the platform also returns true for [hasBackgroundWorker]
  /// because we usually send notifications from background workers.
  static bool get hasNotifications =>
      hasBackgroundWorker && [Platform.isAndroid, Platform.isIOS].any((e) => e);

  /// Whether this platform supports playing videos.
  /// Platform views are not supported on desktop right now.
  static bool get hasVideos => true;
}
