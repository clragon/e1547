import 'dart:async';

import 'package:collection/collection.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';

class NotificationHandler extends StatefulWidget {
  const NotificationHandler({
    super.key,
    required this.child,
    required this.navigatorKey,
    required this.routes,
  });

  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;
  final Map<String, bool> routes;

  @override
  State<NotificationHandler> createState() => _NotificationHandlerState();
}

class _NotificationHandlerState extends State<NotificationHandler> {
  late Future<FlutterLocalNotificationsPlugin> notifications =
      initializeNotifications(onDidReceiveNotificationResponse: handle);
  List<Follow>? previousFollows;

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
          ?.requestNotificationsPermission();
      if (!(result ?? true)) return;
    }
    registerFollowBackgroundTask(follows);
  }

  Future<void> sendNotifications(List<Follow> follows) async {
    if (!PlatformCapabilities.hasNotifications) return;
    if (previousFollows != null) {
      await updateFollowNotifications(
        previous: previousFollows!,
        updated: follows,
        notifications: await notifications,
      );
    }
    previousFollows = follows;
  }

  Future<void> handle(NotificationResponse response) async {
    if (!context.mounted) return;
    String? payload = response.payload;
    if (payload == null) return;
    Uri? url = Uri.tryParse(payload);
    if (url == null) return;
    MapEntry<String, bool>? destination =
        widget.routes.entries.firstWhereOrNull((e) => e.key == url.path);
    if (destination != null) {
      if (destination.value) {
        widget.navigatorKey.currentState!
            .pushNamedAndRemoveUntil(destination.key, (_) => false);

        // This is very specific. Find a way to make it more systematic.
        String? tags = url.queryParameters['tags'];
        int? id = int.tryParse(url.queryParameters['id'] ?? '');
        if (url.path == '/subscriptions') {
          if (tags != null) {
            widget.navigatorKey.currentState!.push(
              MaterialPageRoute(
                builder: (context) => PostsSearchPage(
                  query: TagMap({'tags': tags}),
                  orderPoolsByOldest: false,
                  readerMode: poolRegex().hasMatch(tags),
                ),
              ),
            );
          }
          if (id != null) {
            widget.navigatorKey.currentState!.push(
              MaterialPageRoute(
                builder: (context) => PostLoadingPage(id),
              ),
            );
          }
        }
      } else {
        widget.navigatorKey.currentState!.pushNamed(destination.key);
      }
    }
  }

  @override
  Widget build(BuildContext context) => SubStream<List<Follow>>(
        create: () => context
            .watch<FollowsService>()
            .all(types: [FollowType.notify]).stream,
        listener: (event) {
          setupFollowBackground(event);
          sendNotifications(event);
        },
        keys: [context.watch<FollowsService>()],
        builder: (context, stream) => widget.child,
      );
}
