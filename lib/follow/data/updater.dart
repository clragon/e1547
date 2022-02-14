import 'dart:async';

import 'package:collection/collection.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/data/settings.dart';
import 'package:flutter/material.dart';

late final FollowController followController =
    FollowController(settings: settings.follows);

class FollowController extends DataUpdater<List<Follow>> with HostableUpdater {
  @override
  @protected
  Duration get stale => getFollowRefreshRate(_source.value.length);

  late final ValueNotifier<List<Follow>> _source;
  late List<Follow> items;

  void _updateItems() {
    if (!UnorderedIterableEquality().equals(items, _source.value)) {
      refresh();
    }
    items = _source.value;
    notifyListeners();
  }

  FollowController({required ValueNotifier<List<Follow>> settings}) {
    _source = settings;
    _source.addListener(_updateItems);
    items = _source.value;
  }

  @override
  void dispose() {
    _source.removeListener(_updateItems);
    super.dispose();
  }

  @override
  @protected
  Future<List<Follow>> read() async => _source.value;

  @override
  @protected
  Future<void> write(List<Follow>? data) async {
    if (data != null) {
      _source.value = data;
    }
  }

  @protected
  Future<void> sort(List<Follow> data) async {
    data.sortByNew(client.host);
    await write(List.from(data));
  }

  @override
  @protected
  Future<List<Follow>?> run(
    List<Follow> data,
    bool force,
  ) async {
    await sort(data);
    DateTime now = DateTime.now();
    for (Follow follow in data) {
      if (follow.type != FollowType.bookmark) {
        DateTime? updated = follow.statuses[client.host]?.updated;
        if (force || updated == null || now.difference(updated) > stale) {
          if (await follow.refresh()) {
            await write(data);
            await Future.delayed(Duration(milliseconds: 500));
          } else {
            fail();
          }
        }
      }
      if (!step()) {
        // interrupted status updates get corrupted, so we clear them
        follow.statuses[client.host] = FollowStatus();
        return null;
      }
    }
    await sort(data);
    return data;
  }
}
