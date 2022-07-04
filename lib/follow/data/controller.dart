import 'dart:async';

import 'package:collection/collection.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

final FollowsController followController =
    FollowsController(settings: settings.follows);

class FollowsController extends DataUpdater<List<Follow>> with HostableUpdater {
  late final ValueNotifier<List<Follow>> _source;
  late final SelectedValueNotifier<List<Follow>> _restarter =
      SelectedValueNotifier<List<Follow>>(
    source: _source,
    comparator: _compare,
  );

  List<Follow> get items => _source.value;

  @override
  @protected
  Future<List<Follow>> read() async => List.from(items);

  @override
  @protected
  Future<void> write(List<Follow> value) async => _source.value = value;

  final int refreshAmount = 5;

  FollowsController({required ValueNotifier<List<Follow>> settings})
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
            await Future.delayed(const Duration(milliseconds: 500));
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

  bool follows(String tag) => getFollow(tag) != null;

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
      withData((data) => data..add(follow));

  Future<void> addTag(String tag) async =>
      withData((data) => data..add(Follow(tags: tag)));

  Future<void> remove(Follow follow) async => ((data) => data..remove(follow));

  Future<void> removeTag(String tag) async =>
      withData((data) => data..removeWhere((element) => element.tags == tag));

  Future<void> replace(Follow old, Follow updated) async => withData(
        (data) {
          int index = data.indexOf(old);
          if (index == -1) {
            index = data.indexWhere((element) => element.tags == old.tags);
          }
          if (index == -1) {
            throw UpdaterException(
                message:
                    'FollowUpdater failed to update ${updated.tags} with: Could not find follow to be replaced');
          }
          data[index] = _syncUnseen(updated);
          return data;
        },
      );

  Future<void> replaceAt(int index, Follow follow) async => withData(
        (data) => data..[index] = _syncUnseen(follow),
      );

  Future<Follow> refresh(Follow follow, {bool force = false}) async {
    Follow updated = follow;
    List<Post> posts = await client.postsRaw(1,
        search: updated.tags, limit: refreshAmount, force: force);

    posts
        .removeWhere((element) => element.isDeniedBy(denylistController.items));
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
        (data) {
          List<Follow> edited = [];
          for (String tags in update) {
            Follow? match =
                data.firstWhereOrNull((follow) => follow.tags == tags);
            if (match != null) {
              edited.add(match);
            } else {
              edited.add(Follow(tags: tags));
            }
          }
          return edited;
        },
      );

  Future<void> markAllAsRead() async => withData(
        (data) {
          for (int i = 0; i < data.length; i++) {
            Follow follow = data[i];
            FollowStatus? status = this.status(follow);
            if (status != null) {
              data[i] =
                  follow.withStatus(client.host, status.copyWith(unseen: 0));
            }
          }
          return data;
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
