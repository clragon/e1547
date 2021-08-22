import 'dart:async';

import 'package:collection/collection.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/follow/data.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mutex/mutex.dart';

final FollowUpdater followUpdater = FollowUpdater(settings.follows);

class FollowUpdater extends ChangeNotifier {
  Future? finish;
  List<String>? tags;
  Completer? completer;
  bool error = false;
  bool restart = false;
  Mutex updateLock = Mutex();
  ValueNotifier<Future<List<Follow>>> source;
  ValueNotifier<int> progress = ValueNotifier(0);
  Duration get stale => Duration(hours: 4);

  Future<void> refresh() async {
    if (!completer!.isCompleted) {
      restart = true;
    } else {
      update();
    }
    return completer!.future;
  }

  Future<void> updateSource() async {
    List<String> update = (await source.value).tags as List<String>;
    if (tags == null) {
      tags = update;
    } else {
      if (!UnorderedIterableEquality().equals(tags, update)) {
        tags = update;
        refresh();
      }
    }
  }

  Future<void> updateHost() async => refresh();

  FollowUpdater(this.source) {
    source.addListener(updateSource);
    settings.host.addListener(updateHost);
  }

  Future<void> update({bool force = false}) async {
    if (updateLock.isLocked) {
      return;
    }
    await updateLock.acquire();
    if (completer?.isCompleted ?? true) {
      completer = Completer();
      finish = completer!.future;
    }
    progress.value = 0;
    restart = false;
    error = false;

    notifyListeners();

    Future<void> run(List<Follow> follows) async {
      DateTime now = DateTime.now();
      await follows.sortByNew();
      source.value = Future.value(follows);

      for (Follow follow in follows) {
        if (follow.type != FollowType.bookmark) {
          DateTime? updated = await follow.updated;
          if (force || updated == null || now.difference(updated) > stale) {
            if (!await follow.refresh()) {
              error = true;
              updateLock.release();
              completer!.complete();
              return;
            }
            if (restart) {
              // prevent thumbnails from wrong host
              if (await client.isSafe) {
                follow.safe = FollowStatus();
              } else {
                follow.unsafe = FollowStatus();
              }
              updateLock.release();
              update(force: force);
              return;
            }
            source.value = Future.value(follows);
            await Future.delayed(Duration(milliseconds: 500));
          }
        }
        progress.value = progress.value + 1;
        notifyListeners();
      }

      await follows.sortByNew();
      source.value = Future.value(follows);
      updateLock.release();
      completer!.complete();
      notifyListeners();
    }

    source.value.then((value) => run(List.from(value)));
    return completer!.future;
  }

  @override
  void dispose() {
    super.dispose();
    source.removeListener(updateSource);
    settings.host.removeListener(updateHost);
  }
}

extension utility on List<Follow> {
  List<String?> get tags => this.map((e) => e.tags).toList();

  Future<void> sortByNew() async {
    bool isSafe = await client.isSafe;
    this.sort(
      (a, b) {
        int result = 0;

        int? unseenA;
        int? unseenB;
        if (isSafe) {
          unseenB = b.safe.unseen;
          unseenA = a.safe.unseen;
        } else {
          unseenB = b.unsafe.unseen;
          unseenA = a.unsafe.unseen;
        }
        unseenB ??= -1;
        unseenA ??= -1;
        result = unseenB.compareTo(unseenA);

        if (result == 0) {
          int? latestA;
          int? latestB;

          if (isSafe) {
            latestB = b.safe.latest;
            latestA = a.safe.latest;
          } else {
            latestB = b.unsafe.latest;
            latestA = a.unsafe.latest;
          }

          latestB ??= -1;
          latestA ??= -1;

          result = latestB.compareTo(latestA);
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
      Follow? match = this.firstWhereOrNull((follow) => follow.tags == tags);
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
      List<Post> posts = await client.postsRaw(tags, 1, limit: checkAmount);

      List<String> denylist = await settings.denylist.value;

      await Future.forEach(
        posts,
        (Post element) async =>
            element.isBlacklisted = await element.isDeniedBy(denylist),
      );

      posts.removeWhere((element) => element.isBlacklisted);
      await updateUnseen(posts);

      if (!tags.contains(' ') && alias == null) {
        RegExpMatch? match = poolRegex().firstMatch(tags);
        if (match != null) {
          client
              .pool(int.tryParse(match.namedGroup('id')!)!)
              .then((value) => updatePool(value));
        }
      }
      return true;
    } on DioError {
      return false;
    }
  }
}
