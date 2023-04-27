import 'dart:async';

import 'package:collection/collection.dart';
import 'package:e1547/follow/follow.dart';

class FollowsService extends FollowsDatabase {
  FollowsService(super.e);

  Future<Follow?> getFollow(String host, String tag) =>
      watchFollow(host, tag).first;

  Stream<Follow?> watchFollow(String host, String tag) => watchAll(
        host: host,
        tagRegex: r'^' + RegExp.escape(tag) + r'$',
      ).map((e) => e.firstOrNull);

  Future<bool> follows(String host, String tag) =>
      watchFollows(host, tag).first;

  Stream<bool> watchFollows(String host, String tag) =>
      watchFollow(host, tag).map((e) => e != null);

  Future<void> addTag(String host, String tag, {FollowType? type}) => add(
        host,
        FollowRequest(
          tags: tag,
          type: type ?? FollowType.update,
        ),
      );

  Future<void> removeTag(String host, String tag) => transaction(
        () async => removeAll(
          await getAll(
            host: host,
            tagRegex: r'^' + RegExp.escape(tag) + r'$',
          ),
        ),
      );

  Future<void> edit(String host, List<String> update) async =>
      transaction(() async {
        List<Follow> follows = await getAll(host: host);
        List<Follow> removed =
            follows.whereNot((e) => update.contains(e.tags)).toList();
        List<String> tags = follows.map((e) => e.tags).toList();
        List<FollowRequest> added = update
            .whereNot((e) => tags.contains(e))
            .map((e) => FollowRequest(tags: e))
            .toList();
        await removeAll(removed);
        await addAll(host, added);
      });
}
