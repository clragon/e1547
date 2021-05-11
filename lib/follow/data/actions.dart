import 'package:e1547/client.dart';
import 'package:e1547/follow/data.dart';
import 'package:e1547/post.dart';
import 'package:e1547/settings.dart';

extension Updating on FollowList {
  int get checkAmount => 5;

  Future<void> update({
    Function(int progress, int max) onProgress,
    bool force = false,
  }) async {
    bool sort = false;
    int progress = 0;
    for (Follow follow in follows) {
      progress++;
      onProgress(progress, follows.length);

      Future<void> refresh() async {
        List<Post> posts = await client.posts(follow.tags, 1,
            limit: checkAmount, faithful: true);
        posts.removeWhere((element) => element.isBlacklisted);
        if (await updateUnseen(follows.indexOf(follow), posts)) {
          sort = true;
        }
        if (!follow.tags.contains(' ') && follow.alias == null) {
          RegExpMatch match =
              RegExp(r'^pool:(?<id>\d+)$').firstMatch(follow.tags);
          if (match != null) {
            client
                .pool(int.tryParse(match.namedGroup('id')))
                .then((value) => follow.updatePoolName(value));
          }
        }
        // api cooldown
        await Future.delayed(Duration(milliseconds: 500));
      }

      DateTime updated = await follow.updated;
      if (force ||
          updated == null ||
          DateTime.now().difference(updated).inHours > 4) {
        await refresh();
      }
    }

    if (sort) {
      bool isSafe = (await db.host.value) != (await db.customHost.value);
      follows.sort((a, b) {
        int first;
        int second;
        if (isSafe) {
          first = b.safe.unseen;
          second = a.safe.unseen;
        } else {
          first = b.unsafe.unseen;
          second = a.unsafe.unseen;
        }
        if (first == null && second == null) {
          return 0;
        } else {
          if (first == null) {
            return -1;
          }
          if (second == null) {
            return 1;
          }
        }
        return first.compareTo(second);
      });
      write();
    }
  }
}
