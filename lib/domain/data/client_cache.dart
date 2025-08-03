import 'package:e1547/comment/comment.dart';
import 'package:e1547/flag/flag.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/reply/reply.dart';
import 'package:e1547/stream/stream.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/topic/topic.dart';
import 'package:e1547/wiki/wiki.dart';

class ClientCache {
  ClientCache()
    : posts = PagedValueCache(
        toId: (Post post) => post.id,
        size: null,
        maxAge: const Duration(minutes: 5),
      ),
      comments = PagedValueCache(
        toId: (Comment comment) => comment.id,
        size: null,
        maxAge: const Duration(minutes: 5),
      ),
      tags = PagedValueCache(
        toId: (Tag tag) => tag.id,
        size: null,
        maxAge: const Duration(minutes: 5),
      ),
      flags = PagedValueCache(
        toId: (PostFlag flag) => flag.id,
        size: null,
        maxAge: const Duration(minutes: 5),
      ),
      topics = PagedValueCache(
        toId: (Topic topic) => topic.id,
        size: null,
        maxAge: const Duration(minutes: 5),
      ),
      wikis = PagedValueCache(
        toId: (Wiki wiki) => wiki.id,
        size: null,
        maxAge: const Duration(minutes: 5),
      ),
      replies = PagedValueCache(
        toId: (Reply reply) => reply.id,
        size: null,
        maxAge: const Duration(minutes: 5),
      );

  final PagedValueCache<QueryKey, int, Post> posts;
  final PagedValueCache<QueryKey, int, Comment> comments;
  final PagedValueCache<QueryKey, int, Tag> tags;
  final PagedValueCache<QueryKey, int, PostFlag> flags;
  final PagedValueCache<QueryKey, int, Topic> topics;
  final PagedValueCache<QueryKey, int, Wiki> wikis;
  final PagedValueCache<QueryKey, int, Reply> replies;

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
