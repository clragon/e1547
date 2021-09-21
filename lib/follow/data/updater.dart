import 'dart:async';

import 'package:collection/collection.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/data/settings.dart';
import 'package:flutter/material.dart';

late final FollowUpdater followUpdater = FollowUpdater(settings.follows);

class FollowUpdater extends DataUpdater<List<Follow>> with HostableUpdater {
  Duration get stale => Duration(hours: 4);

  ValueNotifier<List<Follow>> source;
  List<String>? tags;

  FollowUpdater(this.source) {
    source.addListener(updateSource);
  }

  @override
  void dispose() {
    source.removeListener(updateSource);
    super.dispose();
  }

  void updateSource() {
    List<String> update = source.value.tags;
    if (tags == null) {
      tags = update;
    } else {
      if (!UnorderedIterableEquality().equals(tags, update)) {
        tags = update;
        refresh();
      }
    }
  }

  @override
  Future<List<Follow>> read() async => source.value;

  @override
  Future<void> write(List<Follow>? data) async {
    if (data != null) {
      source.value = data;
    }
  }

  Future<void> sort(List<Follow> data) async {
    data.sortByNew();
    await write(List.from(data));
  }

  @override
  Future<List<Follow>?> run(
    List<Follow> data,
    StepCallback step,
    bool force,
  ) async {
    await sort(data);

    DateTime now = DateTime.now();

    for (Follow follow in data) {
      if (follow.type != FollowType.bookmark) {
        DateTime? updated = follow.updated;
        if (force || updated == null || now.difference(updated) > stale) {
          if (!await follow.refresh()) {
            fail();
            return null;
          }
          await write(data);
          await Future.delayed(Duration(milliseconds: 500));
        }
      }
      if (!step()) {
        if (client.isSafe) {
          follow.safe = FollowStatus();
        } else {
          follow.unsafe = FollowStatus();
        }
        return null;
      }
    }
    await sort(data);
    return data;
  }
}
