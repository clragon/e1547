import 'dart:async';

import 'package:collection/collection.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/data/stream.dart';

class FollowsService extends FollowsDao {
  FollowsService({
    required super.database,
    required super.identity,
  });

  StreamFuture<Follow?> follow(String tag) => page(
        page: 1,
        limit: 1,
        tagRegex: r'^' + RegExp.escape(tag) + r'$',
      ).stream.map((e) => e.firstOrNull).future;

  StreamFuture<bool> follows(String tag) =>
      follow(tag).stream.map((e) => e != null).future;

  Future<void> addTag(String tag, {FollowType? type, int? identity}) => add(
        FollowRequest(
          tags: tag,
          type: type ?? FollowType.update,
        ),
        identity: identity,
      );

  Future<void> removeTag(String tag) => transaction(
        () async {
          int? id = (await follow(tag))?.id;
          if (id == null) return;
          return remove(id);
        },
      );

  Future<void> edit({
    List<String>? notifications,
    List<String>? subscriptions,
    List<String>? bookmarks,
  }) async {
    List<Follow> allRemoved = [];
    List<FollowRequest> allAdded = [];

    Future<void> process(List<String> updateList, FollowType type) async {
      List<Follow> follows = await all(types: [type]);
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

    if (notifications != null) {
      await process(notifications, FollowType.notify);
    }
    if (subscriptions != null) {
      await process(subscriptions, FollowType.update);
    }
    if (bookmarks != null) {
      await process(bookmarks, FollowType.bookmark);
    }

    for (final follow in allRemoved) {
      await remove(follow.id);
    }
    for (final follow in allAdded) {
      await add(follow);
    }
  }
}
