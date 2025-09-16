import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/logs/logs.dart';
import 'package:e1547/traits/traits.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

const String followsBackgroundTaskKey = 'net.clynamic.e1547.follows';

Future<void> runFollowUpdates({
  required AppStorage storage,
  required FlutterLocalNotificationsPlugin notifications,
  CancelToken? cancelToken,
}) async {
  // this ensures continued scheduling on iOS.
  FollowRepository allFollows = FollowRepository(database: storage.sqlite);
  registerFollowBackgroundTask(
    await allFollows.all(types: [FollowType.notify]),
  );

  List<Identity> identities = await IdentityClient(
    database: storage.sqlite,
  ).all();

  final clientFactory = ClientFactory();

  for (final identity in identities) {
    TraitsClient traits = TraitsClient(database: storage.sqlite);
    await traits.activate(identity.id);

    final client = clientFactory.create(
      ClientConfig(
        identity: identity,
        traits: traits.notifier,
        storage: storage,
      ),
    );

    await runClientFollowUpdate(
      client: client,
      notifications: notifications,
      cancelToken: cancelToken,
    );
  }

  registerFollowBackgroundTask(
    await allFollows.all(types: [FollowType.notify]),
  );
}

Future<void> runClientFollowUpdate({
  required Client client,
  required FlutterLocalNotificationsPlugin notifications,
  CancelToken? cancelToken,
}) async {
  List<Follow> previous = await client.follows.all(
    query: FollowsQuery(types: [FollowType.notify]),
  );

  cancelToken?.whenCancel.then((_) => client.follows.currentSync?.cancel());

  await client.follows.sync();

  List<Follow> updated = await client.follows.all(
    query: FollowsQuery(types: [FollowType.notify]),
  );

  await updateFollowNotifications(
    identity: client.identity.id,
    previous: previous,
    updated: updated,
    notifications: notifications,
  );
}

Future<void> updateFollowNotifications({
  required int identity,
  required List<Follow> previous,
  required List<Follow> updated,
  required FlutterLocalNotificationsPlugin notifications,
}) async {
  final Logger logger = Logger('Notifications');

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

    logger.fine('${follow.tags} has $unseen new posts!');

    NotificationDetails notificationDetails = _createNotificationDetails(
      thumbnailPath: picture,
    );

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
      payload: json.encode(
        NotificationPayload(
          identity: identity,
          type: 'follow',
          query: {'tags': follow.tags},
          id: unseen == 1 ? follow.latest : null,
        ),
      ),
    );

    if (Platform.isAndroid) {
      List<ActiveNotification> active = await notifications
          .getActiveNotifications();

      List<ActiveNotification> grouped = active
          .where((e) => e.groupKey == followsBackgroundTaskKey)
          .toList();

      if (grouped.length > 3) {
        NotificationDetails notificationDetails = _createNotificationDetails(
          summary: true,
        );
        await notifications.show(
          followsBackgroundTaskKey.hashCode,
          'New posts!',
          null,
          notificationDetails,
          payload: json.encode(
            NotificationPayload(identity: identity, type: 'follow'),
          ),
        );
      } else {
        notifications.cancel(followsBackgroundTaskKey.hashCode);
      }
    }

    logger.info('Sent notification, title: $title\nbody: $description');
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
      largeIcon: thumbnailPath != null
          ? FilePathAndroidBitmap(thumbnailPath)
          : null,
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
