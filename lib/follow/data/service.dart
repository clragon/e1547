import 'dart:async';

import 'package:collection/collection.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';

class FollowsService extends FollowsDatabase {
  FollowsService(super.e);

  StreamFuture<Follow?> follow(String host, String tag) => all(
        host: host,
        tagRegex: r'^' + RegExp.escape(tag) + r'$',
        limit: 1,
      ).stream.map((e) => e.firstOrNull).future;

  StreamFuture<bool> follows(String host, String tag) =>
      follow(host, tag).stream.map((e) => e != null).future;

  Future<void> addTag(String host, String tag, {FollowType? type}) => add(
        host,
        FollowRequest(
          tags: tag,
          type: type ?? FollowType.update,
        ),
      );

  Future<void> removeTag(String host, String tag) => transaction(
        () async => removeAll(
          await all(
            host: host,
            tagRegex: r'^' + RegExp.escape(tag) + r'$',
          ),
        ),
      );

  Future<void> edit(
    String host,
    List<String> notifications,
    List<String> subscriptions,
    List<String> bookmarks,
  ) async {
    List<Follow> allRemoved = [];
    List<FollowRequest> allAdded = [];

    Future<void> process(List<String> updateList, FollowType type) async {
      List<Follow> follows = await all(host: host, types: [type]);
      List<Follow> removed =
          follows.whereNot((e) => updateList.contains(e.tags)).toList();
      List<String> tags = follows.map((e) => e.tags).toList();
      List<FollowRequest> added = updateList
          .whereNot((e) => tags.contains(e))
          .map((e) => FollowRequest(tags: e, type: type))
          .toList();

      allRemoved.addAll(removed);
      allAdded.addAll(added);
    }

    await process(notifications, FollowType.notify);
    await process(subscriptions, FollowType.update);
    await process(bookmarks, FollowType.bookmark);

    await removeAll(allRemoved);
    await addAll(host, allAdded);
  }
}
