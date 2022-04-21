import 'dart:async';

import 'package:collection/collection.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/data/settings.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

late final FollowController followController =
    FollowController(settings: settings.follows);

class FollowController extends DataUpdater<List<Follow>> with HostableUpdater {
  late final ValueNotifier<List<Follow>> _source;
  late SelectedValueNotifier<List<Follow>> _restarter =
      SelectedValueNotifier<List<Follow>>(
    source: _source,
    comparator: _compare,
  );

  @override
  Future<List<Follow>> read() async => items;

  @override
  Future<void> write(List<Follow> value) async =>
      _source.value = List.from(value);

  List<Follow> get items => _source.value;

  final int refreshAmount = 5;

  FollowController({required ValueNotifier<List<Follow>> settings})
      : _source = settings {
    _source.addListener(notifyListeners);
    client.addListener(notifyListeners);
  }

  @override
  void dispose() {
    _source.removeListener(notifyListeners);
    client.removeListener(notifyListeners);
    super.dispose();
  }

  @override
  List<Listenable> getRefreshListeners() =>
      super.getRefreshListeners()..add(_restarter);

  bool _compare(List<Follow> old, List<Follow> value) {
    return old.length == value.length &&
        old.every((a) => value.any((b) => a.tags == b.tags));
  }

  Future<void> _sort() => withData((items) => items..sortByNew(client.host));

  @override
  @protected
  Future<void> run(bool force) async {
    await _sort();
    List<Follow> data = List.from(items);
    DateTime now = DateTime.now();
    for (Follow follow in data) {
      Follow? refreshed;
      if (follow.type != FollowType.bookmark) {
        DateTime? updated = follow.statuses[client.host]?.updated;
        if (force ||
            updated == null ||
            now.difference(updated) > getFollowRefreshRate(data.length)) {
          try {
            refreshed = await refresh(follow, force: force);
            await Future.delayed(Duration(milliseconds: 500));
          } on DioError catch (e) {
            throw UpdaterException(
                message:
                    'FollowUpdater failed to update ${follow.tags} with: $e');
          }
        }
      }
      if (step()) {
        if (refreshed != null) {
          await replace(follow, refreshed);
        }
      } else {
        return;
      }
    }
    await _sort();
  }

  Follow? getFollow(String tag) =>
      items.singleWhereOrNull((follow) => follow.tags == tag);

  bool followsTag(String tag) => getFollow(tag) != null;

  FollowStatus? status(Follow follow) => follow.resolve(client.host);

  Follow _syncUnseen(Follow follow) {
    Follow updated = follow;
    if (status(updated)?.unseen == 0) {
      updated.statuses.forEach((key, value) {
        if (value.latest == status(updated)?.latest && value.unseen != 0) {
          updated = updated.withStatus(key, value.copyWith(unseen: 0));
        }
      });
    }
    return updated;
  }

  Future<void> add(Follow follow) async =>
      withData((items) => items..add(follow));

  Future<void> addTag(String tag) async =>
      withData((items) => items..add(Follow.fromString(tag)));

  Future<void> remove(Follow follow) async =>
      ((items) => items..remove(follow));

  Future<void> removeTag(String tag) async =>
      withData((items) => items..removeWhere((element) => element.tags == tag));

  Future<void> replace(Follow old, Follow updated) async => withData(
        (items) {
          int index = items.indexOf(old);
          if (index == -1) {
            index = items.indexWhere((element) => element.tags == old.tags);
          }
          if (index == -1) {
            throw UpdaterException(
                message:
                    'FollowUpdater failed to update ${updated.tags} with: Could not find follow to be replaced');
          }
          items[index] = _syncUnseen(updated);
          return items;
        },
      );

  Future<void> replaceAt(int index, Follow follow) async => withData(
        (items) => items..[index] = _syncUnseen(follow),
      );

  Future<Follow> refresh(Follow follow, {bool force = false}) async {
    Follow updated = follow;
    List<Post> posts = await client.postsRaw(1,
        search: updated.tags, limit: refreshAmount, force: force);

    List<String> denylist = settings.denylist.value;

    posts.removeWhere((element) => element.isDeniedBy(denylist));
    updated = updated.withUnseen(client.host, posts);

    if (!updated.tags.contains(' ') && updated.alias == null) {
      RegExpMatch? match = poolRegex().firstMatch(updated.tags);
      if (match != null) {
        updated = updated.withPool(
          await client.pool(
            int.parse(match.namedGroup('id')!),
          ),
        );
      }
    }

    return updated;
  }

  Future<void> edit(List<String> update) async => withData(
        (items) {
          List<Follow> edited = [];
          for (String tags in update) {
            Follow? match =
                items.firstWhereOrNull((follow) => follow.tags == tags);
            if (match != null) {
              edited.add(match);
            } else {
              edited.add(Follow.fromString(tags));
            }
          }
          return edited;
        },
      );

  Future<void> markAllAsRead() async => withData(
        (items) {
          for (int i = 0; i < items.length; i++) {
            Follow follow = items[i];
            FollowStatus? status = this.status(follow);
            if (status != null) {
              items[i] =
                  follow.withStatus(client.host, status.copyWith(unseen: 0));
            }
          }
          return items;
        },
      );
}

class SelectedValueNotifier<T> extends ValueNotifier<T> {
  final ValueNotifier<T> source;
  final bool Function(T old, T value) comparator;

  SelectedValueNotifier({required this.source, required this.comparator})
      : super(source.value) {
    source.addListener(_compare);
  }

  void _compare() {
    if (!comparator(value, source.value)) {
      value = source.value;
    }
  }

  @override
  void dispose() {
    source.removeListener(_compare);
    super.dispose();
  }
}
