import 'package:e1547/follow/follow.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';

extension Updating on Follow {
  String get name => title ?? tagToName(tags);

  bool get isSingle => tagIsSingle(tags);

  Follow withTitle(String title) {
    Follow updated = this;
    if (this.title != title) {
      updated = updated.copyWith(title: title);
    }
    return updated;
  }

  Follow withAlias(String alias) {
    Follow updated = this;
    if (this.alias != alias) {
      updated = updated.copyWith(alias: alias);
    }
    return updated;
  }

  Follow withPool(Pool pool) {
    Follow updated = this;
    updated = updated.withTitle(tagToName(pool.name));
    if (!pool.active) {
      updated = updated.copyWith(
        type: FollowType.bookmark,
      );
    }
    return updated;
  }

  Follow withTimestamp() {
    Follow updated = this;
    if (updated.updated == null ||
        DateTime.now().difference(updated.updated!) >
            const Duration(minutes: 10)) {
      updated = updated.copyWith(updated: DateTime.now());
    }
    return updated;
  }

  Follow withSeen() {
    Follow updated = this;
    if ((updated.unseen ?? 0) > 0) {
      updated = updated.copyWith(unseen: 0);
    }
    return updated;
  }

  Follow withLatest(Post? post, {bool foreground = false}) {
    Follow updated = this;
    if (foreground && updated.unseen != 0) {
      updated = updated.copyWith(unseen: 0);
    }
    if (post != null) {
      if (updated.latest == null || updated.latest! < post.id) {
        updated = updated.copyWith(
          latest: post.id,
          thumbnail: post.sample,
        );
      } else {
        if (updated.thumbnail != post.sample) {
          updated = updated.copyWith(
            thumbnail: post.sample,
          );
        }
      }
    }

    return updated.withTimestamp();
  }

  Follow withUnseen(List<Post> posts) {
    Follow updated = this;
    if (posts.isNotEmpty) {
      posts.sort((a, b) => b.id.compareTo(a.id));
      Post? newest = posts.first;
      if (updated.latest != null) {
        posts = posts.takeWhile((e) => e.id > updated.latest!).toList();
        int length = posts.length;
        if (length > 0) {
          updated = updated.copyWith(unseen: updated.unseen! + length);
        }
      } else {
        updated = updated.copyWith(unseen: 0);
      }
      updated = updated.withLatest(newest);
    }

    return updated.withTimestamp();
  }
}

Duration getFollowRefreshRate(int items) =>
    Duration(minutes: ((items * 0.04).clamp(0.5, 4) * 60).round());
