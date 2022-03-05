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
  late EqualityValueNotifier<List<Follow>> _restarter =
      EqualityValueNotifier(_source);

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
  @protected
  Duration get stale => getFollowRefreshRate(items.length);

  @override
  List<Listenable> getRefreshListeners() =>
      super.getRefreshListeners()..add(_restarter);

  @override
  @protected
  Future<List<Follow>> read() async => items;

  @override
  @protected
  Future<void> write(List<Follow>? data) async {
    if (data != null) {
      _items = data;
    }
  }

  @protected
  Future<void> sort(List<Follow> data) async {
    data.sortByNew(client.host);
    await write(List.from(data));
  }

  @override
  @protected
  Future<List<Follow>?> run(List<Follow> data, bool force) async {
    await sort(data);
    DateTime now = DateTime.now();
    for (Follow follow in data) {
      if (follow.type != FollowType.bookmark) {
        DateTime? updated = follow.statuses[client.host]?.updated;
        if (force || updated == null || now.difference(updated) > stale) {
          if (await refresh(follow)) {
            await write(data);
            await Future.delayed(Duration(milliseconds: 500));
          } else {
            throw FollowUpdaterException(follow);
          }
        }
      }
      if (!step()) {
        // interrupted status updates get wrong host data, this clears them
        follow.statuses[client.host] = FollowStatus();
        return null;
      }
    }
    await sort(data);
    return data;
  }

  bool followsTag(String tag) => items.any((element) => element.tags == tag);

  FollowStatus? status(Follow follow) => follow.statuses[client.host];

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
    _items = List.from(items)..[index] = follow;
  }

  Future<bool> refresh(Follow follow) async {
    return validateCall(
      () async {
        List<Post> posts =
            await client.postsRaw(1, search: follow.tags, limit: refreshAmount);

        List<String> denylist = settings.denylist.value;

        posts.removeWhere((element) => element.isDeniedBy(denylist));
        await follow.updateUnseen(client.host, posts);

        if (!follow.tags.contains(' ') && follow.alias == null) {
          RegExpMatch? match = poolRegex().firstMatch(follow.tags);
          if (match != null) {
            client
                .pool(int.parse(match.namedGroup('id')!))
                .then((value) => follow.updatePool(value));
          }
        }
      },
    );
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
    for (Follow follow in updated) {
      FollowStatus? status = follow.statuses[client.host];
      if (status != null) {
        status.unseen = 0;
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

class EqualityValueNotifier<T extends Iterable> extends ValueNotifier<T> {
  final ValueNotifier<T> source;

  EqualityValueNotifier(this.source) : super(source.value) {
    source.addListener(updateValue);
  }

  void updateValue() {
    if (!UnorderedIterableEquality().equals(value, source.value)) {
      value = source.value;
    }
  }

  @override
  void dispose() {
    source.removeListener(updateValue);
    super.dispose();
  }
}
