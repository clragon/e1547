import 'dart:async';

import 'package:e1547/client.dart';
import 'package:e1547/follow/data.dart';
import 'package:e1547/post.dart';
import 'package:e1547/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mutex/mutex.dart';

final FollowUpdater followUpdater = FollowUpdater(db.follows);

class FollowUpdater {
  Future finish;
  List<String> tags;
  bool restart = false;
  Completer completer;
  Mutex lock = Mutex();
  ValueNotifier<Future<List<Follow>>> source;
  ValueNotifier<int> progress = ValueNotifier(0);
  Duration get stale => Duration(hours: 4);

  Future<void> run({bool force = false}) async {
    if (lock.isLocked) {
      return;
    }
    await lock.acquire();
    if (completer?.isCompleted ?? true) {
      completer = Completer();
      finish = completer.future;
    }
    progress.value = 0;
    restart = false;

    Future<void> update(List<Follow> follows) async {
      DateTime now = DateTime.now();

      follows.sortByNew();

      for (Follow follow in follows) {
        DateTime updated = await follow.updated;
        if (force || updated == null || now.difference(updated) > stale) {
          await follow.refresh();
          await Future.delayed(Duration(milliseconds: 500));
          if (restart) {
            lock.release();
            run(force: force);
            return;
          }
          source.value = Future.value(follows);
        }
        progress.value = progress.value + 1;
      }

      follows.sortByNew();
      source.value = Future.value(follows);

      lock.release();
      completer.complete();
    }

    source.value.then((value) => update(List.from(value)));
    return completer.future;
  }

  FollowUpdater(this.source) {
    source.addListener(() async {
      List<String> update = (await source.value).tags;
      if (tags == null) {
        tags = update;
      } else {
        if (!listEquals(tags, update) && !completer.isCompleted) {
          tags = update;
          restart = true;
        }
      }
    });
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
        if (first != null && second != null) {
          if (result == 0) {
            result = first.compareTo(second);
          }
        } else {
          if (first == null && second == null) {
            result = 0;
          } else {
            if (first == null) {
              result = -1;
            }
            if (second == null) {
              result = 1;
            }
          }
        }
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
