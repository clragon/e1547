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

      lock.release();
      completer.complete();
    }

    source.value.then((value) => update(List.from(value)));
    return completer.future;
  }

  FollowUpdater(this.source) {
    source.addListener(() async {
      List<String> update = getFollowTags(await source.value);
      if (!listEquals(tags, update) && !completer.isCompleted) {
        tags = update;
        restart = true;
      }
    });
  }
}

Future<List<Follow>> editFollows(
    List<Follow> follows, List<String> update) async {
  List<Follow> edited = [];
  for (String tags in update) {
    Follow match =
        follows.firstWhere((follow) => follow.tags == tags, orElse: () => null);
    if (match != null) {
      edited.add(match);
    } else {
      edited.add(Follow.fromString(tags));
    }
  }
  return edited;
}

Future<void> sortFollows(List<Follow> follows) async {
  bool isSafe = await client.isSafe;
  follows.sort(
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

List<String> getFollowTags(List<Follow> follows) =>
    follows.map((e) => e.tags).toList();

extension Refreshing on Follow {
  int get checkAmount => 5;

  Future<bool> refresh() async {
    try {
      List<Post> posts =
          await client.posts(tags, 1, limit: checkAmount, faithful: true);

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
