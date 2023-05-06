import 'dart:async';

import 'package:collection/collection.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/follow/data/follow.dart';
import 'package:e1547/follow/data/service.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';

class NotificationHandler extends StatefulWidget {
  const NotificationHandler({super.key, required this.child});

  final Widget child;

  @override
  State<NotificationHandler> createState() => _NotificationHandlerState();
}

class _NotificationHandlerState extends State<NotificationHandler> {
  late Future<FlutterLocalNotificationsPlugin> notifications =
      initializeNotifications(onDidReceiveNotificationResponse: handle);

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    if (!PlatformCapabilities.hasNotifications) return;
    NotificationAppLaunchDetails? details =
        await (await notifications).getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp) {
      NotificationResponse? response = details.notificationResponse;
      if (response != null) {
        handle(response);
      }
    }
  }

  Future<void> setupFollowBackground(List<Follow> follows) async {
    if (!PlatformCapabilities.hasNotifications) return;
    if (follows.where((e) => e.type == FollowType.notify).isNotEmpty) {
      bool? result;
      result = await (await notifications)
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      result = await (await notifications)
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestPermission();
      if (!(result ?? true)) return;
    }
    registerFollowBackgroundTask(follows);
  }

  Future<void> handle(NotificationResponse response) async {
    if (!context.mounted) return;
    RouterDrawerController controller = context.read<RouterDrawerController>();
    String? payload = response.payload;
    if (payload == null) return;
    Uri? url = Uri.tryParse(payload);
    if (url == null) return;
    RouterDrawerDestination? destination =
        controller.destinations.firstWhereOrNull((e) => e.path == url.path);
    if (destination != null) {
      if (destination.unique) {
        controller.navigator!
            .pushNamedAndRemoveUntil(destination.path, (_) => false);

        // This is very specific. Find a way to make it more systematic.
        if (url.path == '/follows' &&
            url.queryParameters['tags'] != null &&
            url.queryParameters['tags']!.split(' ').length == 1) {
          controller.navigator!.push(
            MaterialPageRoute(
              builder: (context) => PostsSearchPage(
                tags: url.queryParameters['tags'],
              ),
            ),
          );
        }
      } else {
        controller.navigator!.pushNamed(destination.path);
      }
    }
  }

  @override
  Widget build(BuildContext context) =>
      SubValue<StreamSubscription<List<Follow>>>(
        create: () => context
            .watch<FollowsService>()
            .watchAll(type: FollowType.notify)
            .listen(setupFollowBackground),
        keys: [context.watch<FollowsService>()],
        dispose: (value) => value.cancel(),
        builder: (context, stream) => widget.child,
      );
}
