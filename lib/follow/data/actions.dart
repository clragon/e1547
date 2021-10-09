import 'dart:async';

import 'package:collection/collection.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/tag/tag.dart';

extension Utility on List<Follow> {
  List<String> get tags => map((e) => e.tags).toList();

  void sortByNew() {
    bool isSafe = client.isSafe;
    sort(
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

  List<Follow> editWith(List<String> update) {
    List<Follow> edited = [];
    for (String tags in update) {
      Follow? match = firstWhereOrNull((follow) => follow.tags == tags);
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

      List<String> denylist = settings.denylist.value;

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
              .pool(int.parse(match.namedGroup('id')!))
              .then((value) => updatePool(value));
        }
      }
      return true;
    } on DioError {
      return false;
    }
  }
}
