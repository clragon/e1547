import 'dart:async';

import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/data/settings.dart';
import 'package:flutter/material.dart';

late final FollowUpdater followUpdater = FollowUpdater(settings.follows);

class FollowUpdater extends DataUpdater<List<Follow>>
    with HostableUpdater, EditableUpdater {
  @override
  Duration get stale => getFollowRefreshRate(source.value.length);

  @override
  ValueNotifier<List<Follow>> source;

  FollowUpdater(this.source);

  @override
  Future<List<Follow>> read() async => source.value;

  @override
  Future<void> write(List<Follow>? data) async {
    if (data != null) {
      source.value = data;
    }
  }

  Future<void> sort(List<Follow> data) async {
    data.sortByNew(client.host);
    await write(List.from(data));
  }

  @override
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
        return null;
      }
    }
    await sort(data);
    return data;
  }
}
