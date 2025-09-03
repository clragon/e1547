import 'package:e1547/history/history.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/reply/reply.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/topic/topic.dart';
import 'package:e1547/user/user.dart';
import 'package:e1547/wiki/wiki.dart';

List<String> getPostHistoryThumbnails(List<Post>? posts) =>
    posts?.map((e) => e.sample ?? e.preview).nonNulls.take(4).toList() ?? [];

String getHistorySubtitle(Map<String, String> items) => items.entries
    .take(5)
    .map((e) => '* "${e.value.replaceAll(r'"', '\'')}":${e.key}')
    .join('\n');

abstract final class PostHistoryRequest {
  static HistoryRequest item({required Post post}) => HistoryRequest(
    visitedAt: DateTime.now(),
    link: post.link,
    category: HistoryCategory.items,
    type: HistoryType.posts,
    subtitle: post.description.nullWhenEmpty,
    thumbnails: getPostHistoryThumbnails([post]),
  );

  static HistoryRequest search({required QueryMap query, List<Post>? posts}) =>
      HistoryRequest(
        visitedAt: DateTime.now(),
        link: Uri(path: '/posts', queryParameters: query).toString(),
        category: HistoryCategory.searches,
        type: HistoryType.posts,
        thumbnails: getPostHistoryThumbnails(posts),
      );
}

abstract final class PoolHistoryRequest {
  static HistoryRequest item({required Pool pool, List<Post>? posts}) =>
      HistoryRequest(
        visitedAt: DateTime.now(),
        link: pool.link,
        category: HistoryCategory.items,
        type: HistoryType.pools,
        title: pool.name,
        subtitle: pool.description.nullWhenEmpty,
        thumbnails: getPostHistoryThumbnails(posts),
      );

  static HistoryRequest search({
    required QueryMap query,
    List<Pool>? pools,
    List<Post>? posts,
  }) => HistoryRequest(
    visitedAt: DateTime.now(),
    link: Uri(path: '/pools', queryParameters: query).toString(),
    category: HistoryCategory.searches,
    type: HistoryType.pools,
    subtitle: pools?.isNotEmpty ?? false
        ? getHistorySubtitle({
            for (final value in pools!)
              value.link: value.name.replaceAll('_', ' '),
          })
        : null,
    thumbnails: [
      if (pools != null)
        ...getPostHistoryThumbnails(
          posts
              ?.where(
                (a) => pools
                    .where((e) => e.postIds.isNotEmpty)
                    .any((b) => b.postIds.first == a.id),
              )
              .toList(),
        ),
    ],
  );
}

abstract final class TopicHistoryRequest {
  static HistoryRequest item({required Topic topic, List<Reply>? replies}) =>
      HistoryRequest(
        visitedAt: DateTime.now(),
        link: '/forum_topics/${topic.id}',
        category: HistoryCategory.items,
        type: HistoryType.topics,
        title: topic.title,
        subtitle: replies?.first.body,
      );

  static HistoryRequest search({
    required QueryMap query,
    List<Topic>? topics,
  }) => HistoryRequest(
    visitedAt: DateTime.now(),
    link: Uri(path: '/forum_topics', queryParameters: query).toString(),
    category: HistoryCategory.searches,
    type: HistoryType.topics,
    subtitle: topics?.isNotEmpty ?? false
        ? getHistorySubtitle({
            for (final value in topics!) value.link: value.title,
          })
        : null,
  );
}

abstract final class UserHistoryRequest {
  static HistoryRequest item({required User user, Post? avatar}) =>
      HistoryRequest(
        visitedAt: DateTime.now(),
        link: '/users/${user.name}',
        category: HistoryCategory.items,
        type: HistoryType.users,
        thumbnails: [if (avatar?.sample != null) avatar!.sample!],
      );
}

abstract final class WikiHistoryRequest {
  static HistoryRequest item({required Wiki wiki}) => HistoryRequest(
    visitedAt: DateTime.now(),
    link: '/wiki_pages/${wiki.title}',
    category: HistoryCategory.items,
    type: HistoryType.wikis,
    subtitle: wiki.body.nullWhenEmpty,
  );

  static HistoryRequest search({required QueryMap query, List<Wiki>? wikis}) =>
      HistoryRequest(
        visitedAt: DateTime.now(),
        link: Uri(path: '/wiki_pages', queryParameters: query).toString(),
        category: HistoryCategory.searches,
        type: HistoryType.wikis,
        subtitle: wikis?.isNotEmpty ?? false
            ? getHistorySubtitle({
                for (final value in wikis!) value.link: value.title,
              })
            : null,
      );
}
