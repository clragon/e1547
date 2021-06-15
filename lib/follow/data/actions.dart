import 'dart:async';

import 'package:e1547/client.dart';
import 'package:e1547/follow/data.dart';
import 'package:e1547/post.dart';
import 'package:e1547/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mutex/mutex.dart';

final FollowUpdater followUpdater = FollowUpdater(db.follows);

class FollowUpdater extends ChangeNotifier {
  Future finish;
  List<String> tags;
  bool restart = false;
  Completer completer;
  Mutex updateLock = Mutex();
  ValueNotifier<Future<List<Follow>>> source;
  ValueNotifier<int> progress = ValueNotifier(0);
  Duration get stale => Duration(hours: 4);

  Future<void> run({bool force = false}) async {
    if (updateLock.isLocked) {
      return;
    }
    await updateLock.acquire();
    if (completer?.isCompleted ?? true) {
      completer = Completer();
      finish = completer.future;
    }
    progress.value = 0;
    restart = false;

    notifyListeners();

    Future<void> update(List<Follow> follows) async {
      DateTime now = DateTime.now();
      await follows.sortByNew();
      source.value = Future.value(follows);

      for (Follow follow in follows) {
        DateTime updated = await follow.updated;
        if (force || updated == null || now.difference(updated) > stale) {
          await follow.refresh();
          await Future.delayed(Duration(milliseconds: 500));
          if (restart) {
            updateLock.release();
            run(force: force);
            return;
          }
          source.value = Future.value(follows);
        }
        progress.value = progress.value + 1;
        notifyListeners();
      }

      await follows.sortByNew();
      source.value = Future.value(follows);
      updateLock.release();
      completer.complete();
      notifyListeners();
    }

    source.value.then((value) => update(List.from(value)));
    return completer.future;
  }

  Future<void> updateLoop() async {
    List<String> update = (await source.value).tags;
    if (tags == null) {
      tags = update;
    } else {
      if (!listEquals(tags, update) && !completer.isCompleted) {
        tags = update;
        restart = true;
      }
    }
  }

  Future<void> updateHost() async {
    restart = true;
    run();
  }

  FollowUpdater(this.source) {
    source.addListener(updateLoop);
    db.host.addListener(updateHost);
  }

  @override
  void dispose() {
    super.dispose();
    source.removeListener(updateLoop);
    db.host.removeListener(updateHost);
  }
}

extension utility on List<Follow> {
  List<String> get tags => this.map((e) => e.tags).toList();

  Future<void> sortByNew() async {
    bool isSafe = await client.isSafe;
    this.sort(
      (a, b) {
        int first;
        int second;
        int result = 0;
        if (isSafe) {
          first = b.safe.unseen;
          second = a.safe.unseen;
        } else {
          first = b.unsafe.unseen;
          second = a.unsafe.unseen;
        }
        first ??= -1;
        second ??= -1;
        result = first.compareTo(second);
        if (result == 0) {
          result = a.title.toLowerCase().compareTo(b.title.toLowerCase());
        }
        return result;
      },
    );
  }

  Future<List<Follow>> editWith(List<String> update) async {
    List<Follow> edited = [];
    for (String tags in update) {
      Follow match =
          this.firstWhere((follow) => follow.tags == tags, orElse: () => null);
      if (match != null) {
        edited.add(match);
      } else {
        edited.add(Follow.fromString(tags));
      }
    }
    return edited;
  }
}

extension Refreshing on Follow {
  int get checkAmount => 5;

  Future<bool> refresh() async {
    try {
      List<Post> posts =
          await client.posts(tags, 1, limit: checkAmount, faithful: true);

      List<String> denylist = await db.denylist.value;

      await Future.forEach(
        posts,
        (Post element) async =>
            element.isBlacklisted = await element.isDeniedBy(denylist),
      );

      posts.removeWhere((element) => element.isBlacklisted);
      await updateUnseen(posts);

      if (!tags.contains(' ') && alias == null) {
        RegExpMatch match = RegExp(r'^pool:(?<id>\d+)$').firstMatch(tags);
        if (match != null) {
          client
              .pool(int.tryParse(match.namedGroup('id')))
              .then((value) => updatePoolName(value));
        }
      }
      return true;
    } on DioError {
      return false;
    }
  }
}
