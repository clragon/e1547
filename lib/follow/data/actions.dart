import 'dart:async';

import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/tag/tag.dart';

extension Utility on List<Follow> {
  List<String> get tags => map((e) => e.tags).toList();

  void sortByNew(String host) {
    sort(
      (a, b) {
        int result = 0;

        int unseenA = a.statuses[host]?.unseen ?? -1;
        int unseenB = b.statuses[host]?.unseen ?? -1;

        result = unseenB.compareTo(unseenA);

        if (result == 0) {
          int latestA = a.statuses[host]?.latest ?? -1;
          int latestB = b.statuses[host]?.latest ?? -1;

          result = latestB.compareTo(latestA);
        }

        if (result == 0) {
          result = a.name.toLowerCase().compareTo(b.name.toLowerCase());
        }
        return result;
      },
    );
  }
}

extension Refreshing on Follow {
  int get checkAmount => 5;

  Future<bool> refresh() async {
    return validateCall(
      () async {
        List<Post> posts =
            await client.postsRaw(1, search: tags, limit: checkAmount);

        List<String> denylist = settings.denylist.value;

        posts.removeWhere((element) => element.isDeniedBy(denylist));
        await updateUnseen(client.host, posts);

        if (!tags.contains(' ') && alias == null) {
          RegExpMatch? match = poolRegex().firstMatch(tags);
          if (match != null) {
            client
                .pool(int.parse(match.namedGroup('id')!))
                .then((value) => updatePool(value));
          }
        }
      },
    );
  }
}

Duration getFollowRefreshRate(int items) =>
    Duration(hours: (items * 0.04).clamp(0.5, 4).toInt());
