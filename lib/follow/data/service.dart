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

  Future<void> edit(String host, List<String> update) async =>
      transaction(() async {
        List<Follow> follows = await all(host: host);
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
