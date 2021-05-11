import 'package:e1547/client.dart';
import 'package:e1547/follow/data.dart';
import 'package:e1547/post.dart';

extension Updating on FollowList {
  Duration get stale => Duration(hours: 4);

  Future<void> update([bool force = false]) async {
    DateTime now = DateTime.now();
    for (Follow follow in data) {
      DateTime updated = await follow.updated;
      if (force || updated == null || now.difference(updated) > stale) {
        await follow.refresh();
        await Future.delayed(Duration(milliseconds: 500));
      }
    }
    sort();
  }

  Future<void> sort() async {
    bool isSafe = await client.isSafe;
    data.sort(
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
}

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
