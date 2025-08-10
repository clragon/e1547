import 'dart:async';
import 'dart:io';

import 'package:e1547/app/app.dart';
import 'package:e1547/client/data/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/logs/logs.dart';
import 'package:workmanager/workmanager.dart';

export 'package:flutter_local_notifications/flutter_local_notifications.dart';

final Logger _logger = Logger('IsolateSetup');

/// Registers background tasks for the app.
Future<void> initializeBackgroundTasks() async {
  if (!PlatformCapabilities.hasBackgroundWorker) return;
  await Workmanager().initialize(executeBackgroundTasks);
  _logger.fine('Initialized background tasks');
}

CancelToken createBackgroundCancelToken(String task) {
  final cancelToken = CancelToken();

  Timer(
    // Android forces a 10 minute timeout on background tasks.
    // We generally don't want to run for that long, so we'll
    // cancel any task that runs for more than 9 minutes.
    // This gives us enough time to shut down gracefully.
    const Duration(minutes: 9),
    () => cancelToken.cancel('Took too long to complete'),
  );

  return cancelToken;
}

Future<void> registerFollowBackgroundTask(List<Follow> follows) async {
  if (!PlatformCapabilities.hasBackgroundWorker) return;
  if (follows.where((e) => e.type == FollowType.notify).isEmpty) {
    _logger.fine('Unregistering background task');
    return Workmanager().cancelByUniqueName(followsBackgroundTaskKey);
  }
  if (Platform.isIOS) {
    _logger.fine('Registered iOS one-off task');
    Workmanager().registerProcessingTask(
      followsBackgroundTaskKey,
      followsBackgroundTaskKey,
      initialDelay: const Duration(hours: 1),
      constraints: Constraints(networkType: NetworkType.connected),
    );
  } else if (Platform.isAndroid) {
    _logger.fine('Registered Android periodic task');
    await Workmanager().registerPeriodicTask(
      followsBackgroundTaskKey,
      followsBackgroundTaskKey,
      initialDelay: const Duration(hours: 1),
      frequency: const Duration(hours: 1),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
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
