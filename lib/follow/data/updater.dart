import 'dart:async';

import 'package:collection/collection.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

class FollowsUpdater extends ChangeNotifier {
  FollowsUpdater({required this.service});

  final int refreshAmount = 5;
  final Duration refreshRate = const Duration(hours: 1);
  final FollowsService service;

  Completer<void> _runCompleter = Completer()..complete();

  Future<void> get finish => _runCompleter.future;

  bool _canceling = false;
  int _remaining = 0;

  int get remaining => _remaining;
  Exception? _error;

  Exception? get error => _error;

  @override
  void dispose() {
    _canceling = true;
    _runCompleter.complete();
    super.dispose();
  }

  void _fail(Exception exception) {
    _remaining = 0;
    _error = exception;
    _runCompleter.completeError(exception);
    notifyListeners();
  }

  void _reset() {
    _remaining = 0;
    _canceling = false;
    _error = null;
    _runCompleter = Completer();
    notifyListeners();
  }

  void _complete() {
    _remaining = 0;
    _runCompleter.complete();
    notifyListeners();
  }

  void _progress(int value) {
    _remaining = value;
    notifyListeners();
  }

  List<dynamic> _dependencies = [];

  Future<void> update({
    required Client client,
    required List<String> denylist,
    bool? force,
  }) async {
    List<dynamic> dependencies = [client, denylist, force];
    if (_runCompleter.isCompleted ||
        !const DeepCollectionEquality().equals(_dependencies, dependencies)) {
      _dependencies = dependencies;
      _canceling = true;
      await finish;
      _reset();
      try {
        await _updateFollows(
          client: client,
          denylist: denylist,
          force: force,
        );
        _complete();
      } on DioError catch (e) {
        _fail(e);
      }
    }
    return finish;
  }

  Future<void> _updateFollows({
    required Client client,
    required List<String> denylist,
    bool? force,
  }) async {
    if (force ?? false) {
      await service.transaction(() async {
        List<Follow> follows = await service.getAll(host: client.host);
        for (final follow in follows) {
          await service.replace(follow.copyWith(
            updated: null,
          ));
        }
      });
    }

    List<Follow> previous = [];
    while (!_canceling) {
      List<Follow> follows = await service.getOutdated(
        host: client.host,
        minAge: refreshRate,
      );
      follows = follows.whereNot((e) => e.type == FollowType.bookmark).toList();
      _progress(follows.length);
      List<Follow> singles = follows
          .whereNot((e) => e.tags.contains(' ') || e.tags.contains(':'))
          .toList();
      if (singles.isNotEmpty) {
        List<Follow> chunk = singles.take(40).toList();
        assert(
          !const DeepCollectionEquality().equals(previous, chunk),
          'Updater tried refreshing same follow chunk twice!',
        );
        previous = chunk;
        int limit = chunk.length * refreshAmount;
        List<Post> posts = await rateLimit(client.tagPosts(
          chunk.map((e) => e.tags).toList(),
          1,
          limit: limit,
          force: force,
        ));
        bool isDepleted = posts.length < limit;
        posts.removeWhere((e) => e.isIgnored() || e.isDeniedBy(denylist));
        Map<Follow, List<Post>> updates = await _assignFollowUpdates(
            follows: chunk, posts: posts, client: client);
        await service.transaction(() async {
          if (isDepleted) {
            for (final follow in chunk) {
              await service.replace(follow.withTimestamp());
            }
          }
          for (final entry in updates.entries) {
            Follow follow = entry.key;
            List<Post> posts = entry.value;
            if (posts.length >= 5 ||
                posts.any((e) => e.id == follow.latest) ||
                (posts.isNotEmpty && follow.latest == null) ||
                isDepleted) {
              await service.replace(follow.withUnseen(posts));
            }
          }
        });
        continue;
      }
      List<Follow> multiples = follows.whereNot(singles.contains).toList();
      if (multiples.isNotEmpty) {
        Follow follow = multiples.first;
        List<Post> posts = await rateLimit(client.postsRaw(
          1,
          search: follow.tags,
          limit: refreshAmount,
          force: force,
        ));
        posts.removeWhere((element) => element.isDeniedBy(denylist));
        follow = follow.withUnseen(posts);
        if (!follow.tags.contains(' ') && follow.title == null) {
          RegExpMatch? match = poolRegex().firstMatch(follow.tags);
          if (match != null) {
            follow = follow.withPool(
              await client.pool(int.parse(match.namedGroup('id')!),
                  force: force),
            );
          }
        }
        await service.replace(follow);
        continue;
      }
      break;
    }
  }

  Future<Map<Follow, List<Post>>> _assignFollowUpdates({
    required List<Follow> follows,
    required List<Post> posts,
    required Client client,
  }) async {
    Map<Follow, List<Post>> assign(List<Follow> follows, List<Post> posts) {
      Map<Follow, List<Post>> result = {};
      for (final follow in follows) {
        for (final post in posts) {
          if (post.hasTag(follow.alias ?? follow.tags)) {
            result.update(
              follow,
              (value) => value..add(post),
              ifAbsent: () => [post],
            );
          }
        }
      }
      return result;
    }

    Map<Follow, List<Post>> updates = {};
    updates.addAll(assign(follows, posts));
    List<Post> picked = updates.values.flattened.toList();
    List<Post> leftovers = posts.whereNot(picked.contains).toList();
    if (leftovers.isNotEmpty) {
      List<Follow> offenders =
          follows.where((e) => updates[e] == null).toList();
      offenders = await _fixFollowAliases(
        follows: offenders,
        client: client,
      );
      updates.addAll(assign(offenders, leftovers));
    }
    return updates;
  }

  Future<List<Follow>> _fixFollowAliases({
    required List<Follow> follows,
    required Client client,
  }) async {
    List<Follow> result = [];
    for (final follow in follows) {
      if (follow.tags.contains(' ') || follow.tags.contains(':')) {
        result.add(follow);
        continue;
      }
      String? alias = await client.getTagAlias(follow.tags);
      if (alias != follow.alias) {
        Follow updated = follow.copyWith(alias: alias);
        result.add(updated);
      }
    }
    return result;
  }
}
