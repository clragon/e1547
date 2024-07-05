import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/logs/logs.dart';
import 'package:e1547/settings/settings.dart';
import 'package:workmanager/workmanager.dart';

export 'package:flutter_local_notifications/flutter_local_notifications.dart';

final Logger _logger = Logger('IsolateSetup');

/// Constants for inter-isolate communication.
abstract final class BackgroundCommunication {
  /// Key for background isolate port.
  static const String backgroundKey = 'backgroundTaskPort';

  /// Key for foreground isolate port.
  static const String foregroundKey = 'foregroundTaskPort';

  /// Sent by the foreground isolate to terminate the background isolate.
  static const String terminateMessage = 'terminate';

  /// Sent by the background isolate to the foreground isolate to confirm termination.
  static const String confirmMessage = 'confirm';

  /// Sent by the background isolate to the foreground isolate to notify it has started.
  static const String startupMessage = 'startup';
}

/// Prepares controller objects necessary to run various tasks in a background isolate.
Future<ControllerBundle> setupBackgroundIsolate() async {
  await initializeAppInfo();
  Logs logs = await initializeLogger(
      path: await getTemporaryAppDirectory(), postfix: 'background');
  CancelToken cancelToken = await setupBackgroundCommunication();
  AppStorage storage = await initializeAppStorage();
  Settings settings = Settings(storage.preferences);
  IdentityService identities = IdentityService(database: storage.sqlite);
  await identities.activate(settings.identity.value);

  return ControllerBundle(
    storage: storage,
    settings: settings,
    identities: identities,
    logs: logs,
    cancelToken: cancelToken,
  );
}

Future<void> setupForegroundIsolate() async {
  await setupForegroundCommunication();
  unawaited(initializeBackgroundTasks());
}

class ControllerBundle {
  /// Stores all controllers needed to run various tasks in the app.
  ///
  /// Useful for isolates or tests.
  const ControllerBundle({
    required this.storage,
    required this.settings,
    required this.identities,
    required this.logs,
    required this.cancelToken,
  });

  /// Application databases.
  final AppStorage storage;

  /// Application settings.
  final Settings settings;

  /// Service of identities.
  final IdentityService identities;

  /// Application logs.
  final Logs logs;

  /// Cancel token for the isolate.
  final CancelToken cancelToken;

  /// Disposes all controllers in the bundle.
  Future<void> dispose() async {
    await storage.sqlite.close();
    await storage.httpCache?.close();
    cancelToken.cancel('Bundle was disposed');
    logs.close();
  }
}

Future<CancelToken> setupBackgroundCommunication() async {
  CancelToken cancelToken = CancelToken();
  ReceivePort receivePort = ReceivePort();

  IsolateNameServer.registerPortWithName(
    receivePort.sendPort,
    BackgroundCommunication.backgroundKey,
  );

  receivePort.listen((message) {
    if (message is! String) return;
    if (message == BackgroundCommunication.terminateMessage) {
      _logger.fine('Received termination notice from foreground isolate');
      cancelToken.cancel('Terminated by foreground isolate');
      receivePort.close();
      IsolateNameServer.removePortNameMapping(
          BackgroundCommunication.backgroundKey);
    }
  });

  SendPort? sendPort =
      IsolateNameServer.lookupPortByName(BackgroundCommunication.foregroundKey);

  if (sendPort != null) {
    sendPort.send(BackgroundCommunication.startupMessage);
    _logger.fine('Notified foreground isolate of startup');
  }

  return cancelToken;
}

Future<void> teardownBackgroundIsolate(ControllerBundle bundle) async {
  await bundle.dispose();

  SendPort? sendPort =
      IsolateNameServer.lookupPortByName(BackgroundCommunication.foregroundKey);

  if (sendPort != null) {
    sendPort.send(BackgroundCommunication.confirmMessage);
    _logger.fine('Confirmed shutdown to foreground isolate');
  }
}

Future<void> setupForegroundCommunication() async {
  ReceivePort receivePort = ReceivePort();
  Completer<void> completer = Completer<void>();

  IsolateNameServer.registerPortWithName(
    receivePort.sendPort,
    BackgroundCommunication.foregroundKey,
  );

  SendPort? sendPort =
      IsolateNameServer.lookupPortByName(BackgroundCommunication.backgroundKey);

  if (sendPort != null) {
    sendPort.send(BackgroundCommunication.terminateMessage);
  } else {
    completer.complete();
  }

  receivePort.listen((message) {
    if (message is! String) return;
    if (message == BackgroundCommunication.startupMessage) {
      sendPort = IsolateNameServer.lookupPortByName(
          BackgroundCommunication.backgroundKey);
      sendPort?.send(BackgroundCommunication.terminateMessage);
      _logger.fine('Sent termination notice to background isolate');
    }
    if (message == BackgroundCommunication.confirmMessage) {
      completer.complete();
      _logger.fine('Received confirmation of shutdown from background isolate');
    }
  });

  // Fail-safe to ensure the app doesn't hang.
  Timer(const Duration(seconds: 3), () {
    if (completer.isCompleted) return;
    completer.complete();
    _logger.warning('Failed to receive confirmation from background isolate');
  });

  await completer.future;
}

/// Registers background tasks for the app.
Future<void> initializeBackgroundTasks() async {
  if (!PlatformCapabilities.hasBackgroundWorker) return;
  await Workmanager().initialize(executeBackgroundTasks);
  _logger.fine('Initialized background tasks');
}

Future<void> registerFollowBackgroundTask(List<Follow> follows) async {
  if (!PlatformCapabilities.hasBackgroundWorker) return;
  if (follows.where((e) => e.type == FollowType.notify).isEmpty) {
    _logger.fine('Cancelled background tasks');
    return Workmanager().cancelByUniqueName(followsBackgroundTaskKey);
  }
  if (Platform.isIOS) {
    _logger.fine('Registered iOS one-off task');
    Workmanager().registerOneOffTask(
      followsBackgroundTaskKey,
      followsBackgroundTaskKey,
      initialDelay: const Duration(hours: 1),
      existingWorkPolicy: ExistingWorkPolicy.replace,
      constraints: Constraints(networkType: NetworkType.connected),
    );
  } else if (Platform.isAndroid) {
    _logger.fine('Registered Android periodic task');
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
