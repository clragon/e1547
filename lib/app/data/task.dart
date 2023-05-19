import 'dart:io';

import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/logs/logs.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/user/user.dart';
import 'package:workmanager/workmanager.dart';

export 'package:flutter_local_notifications/flutter_local_notifications.dart';

const String followsBackgroundTask = 'net.clynamic.e1547.follows';
final Loggy _loggy = Loggy('BackgroundTask');

/// Prepares controller objects necessary to run various tasks in a background isolate.
Future<ControllerBundle> prepareBackgroundIsolate() async {
  AppInfo appInfo = await initializeAppInfo();
  AppDatabases databases = await initializeAppdatabases(info: appInfo);
  await initializeLogger(databases: databases, postfix: 'background');
  Settings settings = Settings(databases.preferences);
  ClientService clients = ClientService(
    userAgent: appInfo.userAgent,
    host: settings.host.value,
    customHost: settings.host.value,
    credentials: settings.credentials.value,
    allowedHosts: appInfo.allowedHosts,
  );
  Client client = Client(
    host: clients.host,
    credentials: clients.credentials,
    userAgent: clients.userAgent,
    cache: clients.cache,
  );
  DenylistService denylist = DenylistService(
    items: settings.denylist.value,
    pull: () async {
      CurrentUser? user = await client.currentUser(force: true);
      if (user == null) return null;
      return user.blacklistedTags.split('\n');
    },
    push: (value) async {
      settings.denylist.value = value;
      await client.updateBlacklist(value);
    },
  );

  FollowsService follows = FollowsService(databases.followDb);

  return ControllerBundle(
    appInfo: appInfo,
    settings: settings,
    clients: clients,
    denylist: denylist,
    follows: follows,
  );
}

class ControllerBundle {
  /// Stores all controllers needed to run various tasks in the app.
  ///
  /// Useful for isolates or tests.
  const ControllerBundle({
    required this.appInfo,
    required this.settings,
    required this.clients,
    required this.denylist,
    required this.follows,
  });

  /// Application information.
  final AppInfo appInfo;

  /// Application settings.
  final Settings settings;

  /// Service of api clients.
  final ClientService clients;

  /// Service of blacklisted tags.
  final DenylistService denylist;

  /// Service of followed tags.
  final FollowsService follows;
}

/// Registers background tasks for the app.
Future<void> initializeBackgroundTasks() async {
  if (!PlatformCapabilities.hasBackgroundWorker) return;
  await Workmanager().initialize(executeBackgroundTasks);
  _loggy.debug('Initialized background tasks!');
}

Future<void> registerFollowBackgroundTask(List<Follow> follows) async {
  if (!PlatformCapabilities.hasBackgroundWorker) return;
  if (follows.where((e) => e.type == FollowType.notify).isEmpty) {
    _loggy.debug('Cancelled background tasks!');
    return Workmanager().cancelByUniqueName(followsBackgroundTask);
  }
  if (Platform.isIOS) {
    _loggy.debug('Registered iOS one-off task!');
    Workmanager().registerOneOffTask(
      followsBackgroundTask,
      followsBackgroundTask,
      initialDelay: const Duration(hours: 1),
      existingWorkPolicy: ExistingWorkPolicy.replace,
      constraints: Constraints(networkType: NetworkType.connected),
    );
  } else if (Platform.isAndroid) {
    _loggy.debug('Registered Android periodic task!');
    await Workmanager().registerPeriodicTask(
      followsBackgroundTask,
      followsBackgroundTask,
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
