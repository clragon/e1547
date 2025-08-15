import 'package:e1547/comment/comment.dart';
import 'package:e1547/flag/flag.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/reply/reply.dart';
import 'package:e1547/stream/stream.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/topic/topic.dart';
import 'package:e1547/wiki/wiki.dart';

class ClientCache {
  static const Duration defaultMaxAge = Duration(minutes: 5);

  final PagedValueCache<QueryKey, int, Post> posts =
      PagedValueCache<QueryKey, int, Post>(
        toId: (post) => post.id,
        size: null,
        maxAge: defaultMaxAge,
      );

  final PagedValueCache<QueryKey, int, Comment> comments =
      PagedValueCache<QueryKey, int, Comment>(
        toId: (comment) => comment.id,
        size: null,
        maxAge: defaultMaxAge,
      );

  final PagedValueCache<QueryKey, int, Tag> tags =
      PagedValueCache<QueryKey, int, Tag>(
        toId: (tag) => tag.id,
        size: null,
        maxAge: defaultMaxAge,
      );

  final PagedValueCache<QueryKey, int, PostFlag> flags =
      PagedValueCache<QueryKey, int, PostFlag>(
        toId: (flag) => flag.id,
        size: null,
        maxAge: defaultMaxAge,
      );

  final PagedValueCache<QueryKey, int, Topic> topics =
      PagedValueCache<QueryKey, int, Topic>(
        toId: (topic) => topic.id,
        size: null,
        maxAge: defaultMaxAge,
      );

  final PagedValueCache<QueryKey, int, Wiki> wikis =
      PagedValueCache<QueryKey, int, Wiki>(
        toId: (wiki) => wiki.id,
        size: null,
        maxAge: defaultMaxAge,
      );

  final PagedValueCache<QueryKey, int, Reply> replies =
      PagedValueCache<QueryKey, int, Reply>(
        toId: (reply) => reply.id,
        size: null,
        maxAge: defaultMaxAge,
      );

  void dispose() {
    for (final cache in [
      posts,
      comments,
      tags,
      flags,
      topics,
      wikis,
      replies,
    ]) {
      cache.dispose();
    }
  }
}
