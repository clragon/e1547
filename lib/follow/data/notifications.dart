import 'package:collection/collection.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/logs/logs.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<bool> backgroundUpdateFollows({
  required FollowsService service,
  required Client client,
  required DenylistService denylist,
  required FlutterLocalNotificationsPlugin notifications,
}) async {
  final Loggy loggy = Loggy('BackgroundFollows');

  loggy.info('Starting follow update');

  List<Follow> previous = await service.getAll(
    host: client.host,
    types: [FollowType.notify],
  );

  await FollowUpdate(
    service: service,
    client: client,
    force: true,
    denylist: denylist.items,
  ).run();

  List<Follow> updated = await service.getAll(
    host: client.host,
    types: [FollowType.notify],
  );

  loggy.info('Completed follow update');

  await sendFollowNotifications(
    previous: previous,
    updated: updated,
    notifications: notifications,
  );

  return true;
}

Future<void> sendFollowNotifications({
  required List<Follow> previous,
  required List<Follow> updated,
  required FlutterLocalNotificationsPlugin notifications,
}) async {
  final Loggy loggy = Loggy('Notifications');

  Map<Follow, int> updates = {};

  for (final update in updated) {
    Follow? old = previous.firstWhereOrNull((e) => e.tags == update.tags);
    if (old == null) continue;
    int previousUnseen = old.unseen ?? 0;
    int nextUnseen = update.unseen ?? 0;
    if (previousUnseen < nextUnseen) {
      updates[update] = nextUnseen - previousUnseen;
    }
  }

  for (final MapEntry(key: follow, value: unseen) in updates.entries) {
    String? thumbnail = follow.thumbnail;
    String? picture;
    if (thumbnail != null) {
      picture = (await DefaultCacheManager().getSingleFile(thumbnail)).path;
    }

    loggy.debug('${follow.tags} has $unseen new posts!');

    NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'follows',
        'Followed Tags',
        channelDescription: 'Notifications for tags you are following',
        largeIcon: picture != null ? FilePathAndroidBitmap(picture) : null,
        styleInformation: picture != null
            ? BigPictureStyleInformation(
                FilePathAndroidBitmap(picture),
                hideExpandedLargeIcon: true,
              )
            : null,
      ),
      iOS: DarwinNotificationDetails(
        attachments: [
          if (picture != null) DarwinNotificationAttachment(picture),
        ],
      ),
    );

    String title = '$unseen new posts!';
    if (unseen == 1) {
      title = 'A new post!';
    }

    String description = 'from these tags: ${follow.tags}';
    if (follow.isSingle) {
      description = 'from ${follow.tags}';
    }

    await notifications.show(
      follow.id,
      title,
      description,
      notificationDetails,
      payload: Uri(path: '/follows', queryParameters: {
        'tags': follow.tags,
      }).toString(),
    );

    loggy.info('Sent notification, title: $title\nbody: $description');
  }
}
