import 'package:e1547/client.dart';
import 'package:e1547/follow/data.dart';
import 'package:e1547/post.dart';

extension Updating on FollowList {
  int get checkAmount => 5;

  Future<void> update({
    Function(int progress, int max) onProgress,
    bool force = false,
  }) async {
    int progress = 0;
    for (Follow follow in follows) {
      progress++;
      onProgress(progress, follows.length);

      Future<void> refresh() async {
        List<Post> posts = [];
        try {
          posts = await client.posts(follow.tags, 1,
              limit: checkAmount, faithful: true);
        } on DioError {}
        posts.removeWhere((element) => element.isBlacklisted);
        await updateUnseen(follows.indexOf(follow), posts);
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

    bool isSafe = await client.isSafe;
    follows.sort((a, b) {
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
        result = a.title.compareTo(b.title);
      }
      return result;
    });
    write();
  }
}
