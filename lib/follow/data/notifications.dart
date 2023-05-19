import 'package:collection/collection.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/logs/logs.dart';
import 'package:e1547/tag/tag.dart';
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

  for (Follow update in updated) {
    Follow? old = previous.firstWhereOrNull((e) => e.tags == update.tags);
    if (old == null) continue;
    int previousUnseen = old.unseen ?? 0;
    int nextUnseen = update.unseen ?? 0;
    if (previousUnseen < nextUnseen) {
      updates[update] = nextUnseen - previousUnseen;
    }
  }

  if (updates.isEmpty) {
    loggy.debug('No changes in follows, done.');
    return;
  }

  int total = updates.values.reduce((value, element) => value + element);
  Follow presenter = updates.entries
      .reduce((value, element) => value.value > element.value ? value : element)
      .key;
  String? thumbnail = presenter.thumbnail;
  String? picture;
  if (thumbnail != null) {
    picture = (await DefaultCacheManager().getSingleFile(thumbnail)).path;
  }

  Set<String> tags = updates.keys.map((e) => e.tags).toSet();

  loggy.debug('Received $total updated posts,\nfrom these tags: $tags!');

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

  String displayTags =
      '${tagToTitle(tags.take(5).join(' '))}${tags.length > 5 ? ' + ${tags.length - 5}' : ''}';

  String title = '$total new posts!';
  if (total == 1) {
    title = 'A new post!';
  }

  String description = 'from these tags: $displayTags';
  if (tags.length == 1) {
    description = 'from ${tags.first}';
  }

  await notifications.show(
    0,
    title,
    description,
    notificationDetails,
    payload: Uri(path: '/follows', queryParameters: {
      'tags': tags.join(' '),
    }).toString(),
  );

  loggy.info('Sent notification, title: $title\nbody: $description');
}
