import 'package:e1547/follow/follow.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';

extension Updating on Follow {
  FollowStatus? resolve(String host) => statuses[host];

  String get name => alias ?? tagToTitle(tags);

  Follow withAlias(String alias) {
    Follow updated = this;
    if (this.alias != alias) {
      updated = updated.copyWith(alias: alias);
    }
    return updated;
  }

  Follow withStatus(String host, FollowStatus status) {
    Follow updated = this;
    FollowStatus? old = updated.statuses[host];
    if (old?.latest != status.latest ||
        old?.unseen != status.unseen ||
        old?.thumbnail != status.thumbnail ||
        old?.updated != status.updated) {
      updated = updated.copyWith(
        statuses: Map.from(statuses)..[host] = status,
      );
    }
    return updated;
  }

  Follow withPool(Pool pool) {
    Follow updated = this;
    updated = updated.withAlias(tagToTitle(pool.name));
    if (!pool.isActive && type != FollowType.bookmark) {
      updated = updated.copyWith(type: FollowType.bookmark);
    }
    return updated;
  }

  Follow withTimestamp(String host) {
    Follow updated = this;
    FollowStatus status = updated.resolve(host) ?? const FollowStatus();
    if (status.updated == null ||
        DateTime.now().difference(status.updated!) > const Duration(hours: 1)) {
      updated = updated.withStatus(
        host,
        status.copyWith(updated: DateTime.now()),
      );
    }
    return updated;
  }

  Follow withLatest(String host, Post? post, {bool foreground = false}) {
    Follow updated = this;
    FollowStatus status = statuses[host] ?? const FollowStatus();

    int? latest;
    int? unseen;
    String? thumbnail;

    if (foreground && unseen != 0) {
      unseen = 0;
    }
    if (post != null) {
      if (status.latest == null || status.latest! < post.id) {
        latest = post.id;
        thumbnail = post.sample.url;
      } else {
        if (status.thumbnail != post.sample.url) {
          thumbnail = post.sample.url;
        }
      }
    }

    updated = updated.withStatus(
      host,
      status.copyWith(
        latest: latest,
        unseen: unseen,
        thumbnail: thumbnail,
      ),
    );
    updated = updated.withTimestamp(host);
    return updated;
  }

  Follow withUnseen(String host, List<Post> posts) {
    Follow updated = this;
    FollowStatus status = updated.resolve(host) ?? const FollowStatus();
    if (posts.isNotEmpty) {
      posts.sort((a, b) => b.id.compareTo(a.id));
      if (status.latest != null) {
        posts = posts.takeWhile((value) => value.id > status.latest!).toList();
      }
      if (posts.isNotEmpty) {
        updated = updated.withLatest(host, posts.first);
        status = updated.resolve(host)!;
      }
      int length = posts.length;
      if (status.unseen == null ||
          (statuses.entries.any((e) =>
              e.value != status &&
              status.latest == e.value.latest &&
              e.value.unseen == 0))) {
        updated = updated.withStatus(host, status.copyWith(unseen: 0));
      } else if (length > status.unseen!) {
        updated = updated.withStatus(host, status.copyWith(unseen: length));
      }
      status = updated.resolve(host)!;
    }
    updated = updated.withTimestamp(host);
    return updated;
  }
}

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

Duration getFollowRefreshRate(int items) =>
    Duration(minutes: ((items * 0.04).clamp(0.5, 4) * 60).round());
