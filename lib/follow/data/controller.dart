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

class FollowController extends DataUpdater with HostableUpdater {
  late final ValueNotifier<List<Follow>> _source;
  late SelectedValueNotifier<List<Follow>> _restarter =
      SelectedValueNotifier<List<Follow>>(
    source: _source,
    comparator: _compare,
  );

  set _items(List<Follow> value) => _source.value = List.from(value);
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

  void _sort() {
    List<Follow> updated = List.from(items);
    updated.sortByNew(client.host);
    _items = updated;
  }

  @override
  @protected
  Future<void> run(bool force) async {
    _sort();
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
          } on DioError {
            throw FollowUpdaterException(follow);
          }
        }
      }
      if (step()) {
        if (refreshed != null) {
          data[data.indexOf(follow)] = refreshed;
          _items = List.from(data);
        }
      } else {
        return;
      }
    }
    _sort();
  }

  Follow? getFollow(String tag) =>
      items.singleWhereOrNull((follow) => follow.tags == tag);

  bool followsTag(String tag) => getFollow(tag) != null;

  FollowStatus? status(Follow follow) => follow.resolve(client.host);

  void add(Follow follow) {
    _items = List.from(items)..add(follow);
  }

  void addTag(String tag) {
    _items = List.from(items)..add(Follow.fromString(tag));
  }

  void remove(Follow follow) {
    _items = List.from(items)..remove(follow);
  }

  void removeTag(String tag) {
    items
        .where((element) => element.tags == tag)
        .forEach((element) => remove(element));
  }

  void replace(int index, Follow follow) {
    Follow updated = follow;
    if (status(updated)?.unseen == 0) {
      updated.statuses.forEach((key, value) {
        if (value.latest == status(updated)?.latest && value.unseen != 0) {
          updated = updated.withStatus(key, value.copyWith(unseen: 0));
        }
      });
    }
    _items = List.from(items)..[index] = updated;
  }

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

  void edit(List<String> update) {
    List<Follow> edited = [];
    for (String tags in update) {
      Follow? match = items.firstWhereOrNull((follow) => follow.tags == tags);
      if (match != null) {
        edited.add(match);
      } else {
        edited.add(Follow.fromString(tags));
      }
    }
    _items = edited;
  }

  void markAllAsRead() {
    List<Follow> updated = List.from(items);
    for (int i = 0; i < updated.length; i++) {
      Follow follow = updated[i];
      FollowStatus? status = this.status(follow);
      if (status != null) {
        updated[i] = follow.withStatus(client.host, status.copyWith(unseen: 0));
      }
    }
    _items = updated;
  }
}

class FollowUpdaterException extends UpdaterException {
  final Follow follow;

  FollowUpdaterException(this.follow)
      : super(message: 'Failed to update ${follow.tags}');
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
