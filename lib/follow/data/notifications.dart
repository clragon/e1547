import 'dart:io';

import 'package:collection/collection.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/logs/logs.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const String followsBackgroundTaskKey = 'net.clynamic.e1547.follows';

Future<bool> backgroundUpdateFollows({
  required FollowsService service,
  required Client client,
  required FlutterLocalNotificationsPlugin notifications,
}) async {
  final Loggy loggy = Loggy('BackgroundFollows');

  loggy.info('Starting follow update');

  List<Follow> previous = await service.all(
    types: [FollowType.notify],
  );

  await FollowUpdate(
    service: service,
    client: client,
    force: true,
  ).run();

  List<Follow> updated = await service.all(
    types: [FollowType.notify],
  );

  loggy.info('Completed follow update');

  await updateFollowNotifications(
    previous: previous,
    updated: updated,
    notifications: notifications,
  );

  return true;
}

Future<void> updateFollowNotifications({
  required List<Follow> previous,
  required List<Follow> updated,
  required FlutterLocalNotificationsPlugin notifications,
}) async {
  final Loggy loggy = Loggy('Notifications');

  Map<Follow, int> updates = {};
  List<Follow> seen = [];

  for (final update in updated) {
    Follow? old = previous.firstWhereOrNull((e) => e.tags == update.tags);
    if (old == null) continue;
    int previousUnseen = old.unseen ?? 0;
    int nextUnseen = update.unseen ?? 0;
    if (previousUnseen < nextUnseen) {
      updates[update] = nextUnseen - previousUnseen;
    } else if (previousUnseen > 0 && nextUnseen <= 0) {
      seen.add(update);
    }
  }

  for (final MapEntry(key: follow, value: unseen) in updates.entries) {
    String? thumbnail = follow.thumbnail;
    String? picture;
    if (thumbnail != null) {
      picture = (await DefaultCacheManager().getSingleFile(thumbnail)).path;
    }

    loggy.debug('${follow.tags} has $unseen new posts!');

    NotificationDetails notificationDetails =
        _createNotificationDetails(thumbnailPath: picture);

    String title = follow.name;
    String description = 'has $unseen new posts!';
    if (unseen == 1) {
      description = 'has a new post!';
    }

    await notifications.show(
      follow.id,
      title,
      description,
      notificationDetails,
      payload: Uri(path: '/subscriptions', queryParameters: {
        'tags': follow.tags,
        if (unseen == 1) 'id': follow.latest.toString(),
      }).toString(),
    );

    if (Platform.isAndroid) {
      List<ActiveNotification> active =
          await notifications.getActiveNotifications();

      List<ActiveNotification> grouped =
          active.where((e) => e.groupKey == followsBackgroundTaskKey).toList();

      if (grouped.length > 3) {
        NotificationDetails notificationDetails =
            _createNotificationDetails(summary: true);
        await notifications.show(
          followsBackgroundTaskKey.hashCode,
          'New posts!',
          null,
          notificationDetails,
          payload: Uri(path: '/subscriptions').toString(),
        );
      } else {
        notifications.cancel(followsBackgroundTaskKey.hashCode);
      }
    }

    loggy.info('Sent notification, title: $title\nbody: $description');
  }

  for (final follow in seen) {
    notifications.cancel(follow.id);
  }
}

NotificationDetails _createNotificationDetails({
  String? thumbnailPath,
  bool? summary,
}) {
  return NotificationDetails(
    android: AndroidNotificationDetails(
      'follows',
      'Followed Tags',
      channelDescription: 'Notifications for tags you are following',
      largeIcon:
          thumbnailPath != null ? FilePathAndroidBitmap(thumbnailPath) : null,
      styleInformation: thumbnailPath != null
          ? BigPictureStyleInformation(
              FilePathAndroidBitmap(thumbnailPath),
              hideExpandedLargeIcon: true,
            )
          : null,
      groupKey: followsBackgroundTaskKey,
      setAsGroupSummary: summary ?? false,
    ),
    iOS: DarwinNotificationDetails(
      threadIdentifier: followsBackgroundTaskKey,
      attachments: [
        if (thumbnailPath != null) DarwinNotificationAttachment(thumbnailPath),
      ],
    ),
  );
}
