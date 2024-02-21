import 'dart:io';

import 'package:e1547/app/app.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/logs/logs.dart';
import 'package:e1547/settings/settings.dart';
import 'package:workmanager/workmanager.dart';

export 'package:flutter_local_notifications/flutter_local_notifications.dart';

final Logger _logger = Logger('BackgroundTask');

/// Prepares controller objects necessary to run various tasks in a background isolate.
Future<ControllerBundle> prepareBackgroundIsolate() async {
  await initializeAppInfo();
  AppStorage storage = await initializeAppStorage();
  await initializeLogger(path: storage.temporaryFiles, postfix: 'background');
  Settings settings = Settings(storage.preferences);

  IdentitiesService identities = IdentitiesService(database: storage.sqlite);
  await identities.activate(settings.identity.value);

  return ControllerBundle(
    storage: storage,
    settings: settings,
    identities: identities,
  );
}

class ControllerBundle {
  /// Stores all controllers needed to run various tasks in the app.
  ///
  /// Useful for isolates or tests.
  const ControllerBundle({
    required this.storage,
    required this.settings,
    required this.identities,
  });

  /// Application databases.
  final AppStorage storage;

  /// Application settings.
  final Settings settings;

  /// Service of identities.
  final IdentitiesService identities;
}

/// Registers background tasks for the app.
Future<void> initializeBackgroundTasks() async {
  if (!PlatformCapabilities.hasBackgroundWorker) return;
  await Workmanager().initialize(executeBackgroundTasks);
  _logger.fine('Initialized background tasks!');
}

Future<void> registerFollowBackgroundTask(List<Follow> follows) async {
  if (!PlatformCapabilities.hasBackgroundWorker) return;
  if (follows.where((e) => e.type == FollowType.notify).isEmpty) {
    _logger.fine('Cancelled background tasks!');
    return Workmanager().cancelByUniqueName(followsBackgroundTaskKey);
  }
  if (Platform.isIOS) {
    _logger.fine('Registered iOS one-off task!');
    Workmanager().registerOneOffTask(
      followsBackgroundTaskKey,
      followsBackgroundTaskKey,
      initialDelay: const Duration(hours: 1),
      existingWorkPolicy: ExistingWorkPolicy.replace,
      constraints: Constraints(networkType: NetworkType.connected),
    );
  } else if (Platform.isAndroid) {
    _logger.fine('Registered Android periodic task!');
    await Workmanager().registerPeriodicTask(
      followsBackgroundTaskKey,
      followsBackgroundTaskKey,
      initialDelay: const Duration(hours: 1),
      frequency: const Duration(hours: 1),
      existingWorkPolicy: ExistingWorkPolicy.update,
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }
}

Future<FlutterLocalNotificationsPlugin> initializeNotifications({
  DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
  DidReceiveBackgroundNotificationResponseCallback?
      onDidReceiveBackgroundNotificationResponse,
}) async {
  FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();
  await notifications.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('splash'),
      iOS: DarwinInitializationSettings(
        requestSoundPermission: false,
        requestBadgePermission: false,
        requestAlertPermission: false,
      ),
    ),
    onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    onDidReceiveBackgroundNotificationResponse:
        onDidReceiveBackgroundNotificationResponse,
  );
  return notifications;
}
