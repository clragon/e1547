import 'package:collection/collection.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/logs/logs.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final Loggy _loggy = Loggy('BackgroundFollows');

Future<bool> backgroundUpdateFollows({
  required FollowsUpdater updater,
  required Client client,
  required List<String> denylist,
  required FlutterLocalNotificationsPlugin notifications,
}) async {
  _loggy.info('Starting follow update');

  FollowsService service = updater.service;
  List<Follow> previous = await service.getAll(
    host: client.host,
    type: FollowType.notify,
  );

  await updater.update(
    client: client,
    force: true,
    denylist: denylist,
  );

  List<Follow> next = await service.getAll(
    host: client.host,
    type: FollowType.notify,
  );

  Map<Follow, int> updated = {};

  for (Follow next in next) {
    Follow? old = previous.firstWhereOrNull((e) => e.tags == next.tags);
    if (old == null) continue;
    int previousUnseen = old.unseen ?? 0;
    int nextUnseen = next.unseen ?? 0;
    if (previousUnseen < nextUnseen) {
      updated[next] = nextUnseen - previousUnseen;
    }
  }

  if (updated.isEmpty) {
    _loggy.info('No updates, exiting.');
    return true;
  }

  int total = updated.values.reduce((value, element) => value + element);
  Follow presenter = updated.entries
      .reduce((value, element) => value.value > element.value ? value : element)
      .key;
  String? thumbnail = presenter.thumbnail;
  String? picture;
  if (thumbnail != null) {
    picture = (await DefaultCacheManager().getSingleFile(thumbnail)).path;
  }

  Set<String> tags = updated.keys.map((e) => e.tags).toSet();

  _loggy.info('Received $total updated posts!');
  _loggy.info('Updated followed tags:\n$tags');

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
      attachments: [if (picture != null) DarwinNotificationAttachment(picture)],
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

  _loggy.info('Sent notification, title: $title\nbody: $description');

  return true;
}
