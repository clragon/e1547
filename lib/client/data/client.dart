import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/comment/comment.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/reply/reply.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/topic/topic.dart';
import 'package:e1547/user/user.dart';
import 'package:e1547/wiki/wiki.dart';

export 'package:dio/dio.dart' show CancelToken;

class Client {
  Client({
    required this.host,
    required this.userAgent,
    this.cache,
    this.credentials,
    this.cookies,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: Uri.https(host, '/').toString(),
        headers: {
          HttpHeaders.userAgentHeader: userAgent,
          HttpHeaders.cookieHeader: cookies
              ?.map((cookie) => '${cookie.name}=${cookie.value}')
              .join('; '),
          if (credentials != null)
            HttpHeaders.authorizationHeader: credentials!.basicAuth,
        },
        sendTimeout: const Duration(seconds: 30),
        connectTimeout: const Duration(seconds: 30),
      ),
    );
    if (cache != null) {
      _dio.interceptors.add(
        CacheInterceptor(
          options: CacheConfig(
            store: cache,
            maxAge: const Duration(minutes: 5),
            pageParam: 'page',
          ),
        ),
      );
    }
  }

  final String host;
  final String userAgent;
  final CacheStore? cache;
  final CacheStore _memoryCache = MemCacheStore();
  final Credentials? credentials;
  final List<Cookie>? cookies;

  late Dio _dio;

  void close({bool force = false}) {
    _dio.close(force: force);
  }

  bool get hasLogin => credentials != null;

  String withHost(String path) => Uri.parse(path)
      .replace(
        scheme: 'https',
        host: host,
      )
      .toString();

  Future<void> availability() async => _dio.get('');

  Future<List<Post>> posts(
    int page, {
    int? limit,
    String? search,
    bool? ordered,
    bool? orderPoolsByOldest,
    bool? orderFavoritesByAdded,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    ordered ??= true;
    if (ordered) {
      Map<RegExp, Future<List<Post>> Function(RegExpMatch match)> redirects = {
        poolRegex(): (match) => poolPosts(
              int.parse(match.namedGroup('id')!),
              page,
              orderByOldest: orderPoolsByOldest ?? true,
              force: force,
              cancelToken: cancelToken,
            ),
        if ((orderFavoritesByAdded ?? false) && credentials?.username != null)
          favRegex(credentials!.username): (match) =>
              favorites(page, limit: limit, force: force),
      };

      for (final entry in redirects.entries) {
        RegExpMatch? match = entry.key.firstMatch(search!.trim());
        if (match != null) {
          return entry.value(match);
        }
      }
    }

    String? tags = search != null ? sortTags(search) : '';
    Map<String, dynamic> body = await _dio
        .get(
          'posts.json',
          queryParameters: {
            'tags': tags,
            'page': page,
            'limit': limit,
          },
          options: forceOptions(force),
          cancelToken: cancelToken,
        )
        .then((response) => response.data);

    List<Post> posts =
        List<Post>.from(body['posts'].map((e) => Post.fromJson(e)));

    if (ordered) {
      posts.removeWhere((e) => e.isIgnored());
    }

    return posts;
  }

  Future<List<Post>> postsByIds(
    List<int> ids, {
    int? limit,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    limit = max(0, min(limit ?? 80, 100));

    List<List<int>> chunks = [];
    while (true) {
      chunks.add(ids.sublist(chunks.length * limit).take(limit).toList());
      if (chunks.last.length < limit) break;
    }

    List<Post> result = [];
    for (final chunk in chunks) {
      if (chunk.isEmpty) continue;
      String filter = 'id:${chunk.join(',')}';
      List<Post> part = await posts(
        1,
        search: filter,
        ordered: false,
        force: force,
        cancelToken: cancelToken,
      );
      Map<int, Post> table = {for (Post e in part) e.id: e};
      part = (chunk.map((e) => table[e]).toList()
            ..removeWhere((e) => e == null))
          .cast<Post>();
      result.addAll(part);
    }
    return result;
  }

  Future<List<Post>> postsByTags(
    List<String> tags,
    int page, {
    int? limit,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    if (tags.isEmpty) return [];
    tags.removeWhere((e) => e.contains(' ') || e.contains(':'));
    int max = 40;
    int pages = (tags.length / max).ceil();
    int chunkSize = (tags.length / pages).ceil();

    int tagPage = page % pages != 0 ? page % pages : pages;
    int sitePage = (page / pages).ceil();

    List<String> chunk =
        tags.sublist((tagPage - 1) * chunkSize).take(chunkSize).toList();
    String filter = chunk.map((e) => '~$e').join(' ');
    return posts(
      sitePage,
      search: filter,
      limit: limit,
      ordered: false,
      force: force,
      cancelToken: cancelToken,
    );
  }

  Future<Post> post(int postId, {bool? force, CancelToken? cancelToken}) async {
    Map<String, dynamic> body = await _dio
        .get(
          'posts/$postId.json',
          options: forceOptions(force),
          cancelToken: cancelToken,
        )
        .then((response) => response.data);

    return Post.fromJson(body['post']);
  }

  Future<void> updatePost(int postId, Map<String, String?> body) async {
    await cache?.deleteFromPath(
      RegExp(RegExp.escape('posts/$postId.json')),
    );

    await _dio.put('posts/$postId.json', data: FormData.fromMap(body));
  }

  Future<void> votePost(int postId, bool upvote, bool replace) async {
    await cache?.deleteFromPath(RegExp(RegExp.escape('posts/$postId.json')));
    await _dio.post('posts/$postId/votes.json', queryParameters: {
      'score': upvote ? 1 : -1,
      'no_unvote': replace,
    });
  }

  Future<void> reportPost(int postId, int reportId, String reason) async {
    await _dio.post(
      'tickets',
      queryParameters: {
        'ticket[reason]': reason,
        'ticket[report_reason]': reportId,
        'ticket[disp_id]': postId,
        'ticket[qtype]': 'post',
      },
      options: Options(
        validateStatus: (status) => status == 302,
      ),
    );
  }

  Future<void> flagPost(int postId, String flag, {int? parent}) async {
    await _dio.post(
      'post_flags.json',
      queryParameters: {
        'post_flag[post_id]': postId,
        'post_flag[reason_name]': flag,
        if (flag == 'inferior' && parent != null)
          'post_flag[parent_id]': parent,
      },
    );
  }

  Future<List<Post>> favorites(
    int page, {
    int? limit,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    Map<String, dynamic> body = await _dio
        .get(
          'favorites.json',
          queryParameters: {
            'page': page,
            'limit': limit,
          },
          options: forceOptions(force),
          cancelToken: cancelToken,
        )
        .then((response) => response.data);

    return List<Post>.from(body['posts'].map((e) => Post.fromJson(e)));
  }

  Future<void> addFavorite(int postId) async {
    await cache?.deleteFromPath(RegExp(RegExp.escape('posts/$postId.json')));
    await _dio.post('favorites.json', queryParameters: {'post_id': postId});
  }

  Future<void> removeFavorite(int postId) async {
    await cache?.deleteFromPath(RegExp(RegExp.escape('posts/$postId.json')));
    await _dio.delete('favorites/$postId.json');
  }

  Future<List<Pool>> pools(
    int page, {
    String? search,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    List<dynamic> body = await _dio
        .get(
          'pools.json',
          queryParameters: {
            'search[name_matches]': search,
            'page': page,
          },
          options: forceOptions(force),
          cancelToken: cancelToken,
        )
        .then((response) => response.data);

    List<Pool> pools = [];
    for (Map<String, dynamic> raw in body) {
      Pool pool = Pool.fromJson(raw);
      pools.add(pool);
    }

    return pools;
  }

  Future<Pool> pool(int poolId, {bool? force, CancelToken? cancelToken}) async {
    Map<String, dynamic> body = await _dio
        .get(
          'pools/$poolId.json',
          options: forceOptions(force),
          cancelToken: cancelToken,
        )
        .then((response) => response.data);

    return Pool.fromJson(body);
  }

  Future<List<Post>> poolPosts(
    int poolId,
    int page, {
    bool orderByOldest = true,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    int limit = 80;
    Pool pool = await this.pool(poolId, force: force, cancelToken: cancelToken);
    List<int> ids =
        orderByOldest ? pool.postIds : pool.postIds.reversed.toList();
    int lower = (page - 1) * limit;
    if (lower > ids.length) return [];
    ids = ids.sublist(lower).take(limit).toList();
    return postsByIds(ids,
        limit: limit, force: force, cancelToken: cancelToken);
  }

  Future<List<Wiki>> wikis(
    int page, {
    String? search,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    List<dynamic> body = await _dio
        .get(
          'wiki_pages.json',
          queryParameters: {
            'search[title]': search,
            'page': page,
          },
          options: forceOptions(force),
          cancelToken: cancelToken,
        )
        .then((response) => response.data);

    return body.map((entry) => Wiki.fromJson(entry)).toList();
  }

  Future<Wiki> wiki(
    String name, {
    bool? force,
    CancelToken? cancelToken,
  }) async {
    Map<String, dynamic> body = await _dio
        .get(
          'wiki_pages/$name.json',
          options: forceOptions(force),
          cancelToken: cancelToken,
        )
        .then((response) => response.data);

    return Wiki.fromJson(body);
  }

  Future<User> user(
    String name, {
    bool? force,
    CancelToken? cancelToken,
  }) async {
    Map<String, dynamic> body = await _dio
        .get(
          'users/$name.json',
          options: forceOptions(force),
          cancelToken: cancelToken,
        )
        .then((response) => response.data);

    return User.fromJson(body);
  }

  Future<void> reportUser(int userId, String reason) async {
    await _dio.post(
      'tickets',
      queryParameters: {
        'ticket[reason]': reason,
        'ticket[disp_id]': userId,
        'ticket[qtype]': 'user',
      },
    );
  }

  Future<CurrentUser?> currentUser({
    bool? force,
    CancelToken? cancelToken,
  }) async {
    if (!hasLogin) {
      return null;
    }

    Map<String, dynamic> body = await _dio
        .get(
          'users/${credentials!.username}.json',
          options: CacheConfig(
            store: _memoryCache,
            policy:
                (force ?? false) ? CachePolicy.refresh : CachePolicy.request,
          ).toOptions(),
          cancelToken: cancelToken,
        )
        .then((response) => response.data);

    return CurrentUser.fromJson(body);
  }

  Future<void> updateBlacklist(List<String> denylist) async {
    Map<String, dynamic> body = {
      'user[blacklisted_tags]': denylist.join('\n'),
    };

    await _dio.put('users/${credentials!.username}.json',
        data: FormData.fromMap(body));
  }

  Future<List<Tag>> tags(
    String search, {
    int? category,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    Object body = await _dio
        .get(
          'tags.json',
          queryParameters: {
            'search[name_matches]': search,
            'search[category]': category,
            'search[order]': 'count',
            'limit': 3,
          },
          options: forceOptions(force),
          cancelToken: cancelToken,
        )
        .then((response) => response.data);

    List<Tag> tags = [];
    if (body is List<dynamic>) {
      for (final tag in body) {
        tags.add(Tag.fromJson(tag));
      }
    }
    return tags;
  }

  Future<List<TagSuggestion>> autocomplete(
    String search, {
    int? category,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    if (category == null) {
      if (search.length < 3) {
        return [];
      }
      Object body = await _dio
          .get(
            'tags/autocomplete.json',
            queryParameters: {
              'search[name_matches]': search,
            },
            options: forceOptions(force),
            cancelToken: cancelToken,
          )
          .then((response) => response.data);
      List<TagSuggestion> tags = [];
      if (body is List<dynamic>) {
        for (final tag in body) {
          tags.add(TagSuggestion.fromJson(tag));
        }
      }
      return tags;
    } else {
      List<TagSuggestion> tags = [];
      for (final tag in await this.tags(
        '$search*',
        category: category,
        force: force,
      )) {
        tags.add(
          TagSuggestion(
            id: tag.id,
            name: tag.name,
            postCount: tag.postCount,
            category: tag.category,
            antecedentName: null,
          ),
        );
      }
      return tags;
    }
  }

  Future<String?> getTagAlias(
    String tag, {
    bool? force,
    CancelToken? cancelToken,
  }) async {
    Object body = await _dio
        .get(
          'tag_aliases.json',
          queryParameters: {
            'search[antecedent_name]': tag,
          },
          options: forceOptions(force),
          cancelToken: cancelToken,
        )
        .then((value) => value.data);

    if (body is List<dynamic> && body.isNotEmpty) {
      return body.first['consequent_name'];
    }

    return null;
  }

  Future<List<Comment>> comments(
    int postId,
    String page, {
    bool? force,
    CancelToken? cancelToken,
  }) async {
    Object body = await _dio
        .get(
          'comments.json',
          queryParameters: {
            'group_by': 'comment',
            'search[post_id]': postId,
            'page': page,
          },
          options: forceOptions(force),
          cancelToken: cancelToken,
        )
        .then((response) => response.data);

    List<Comment> comments = [];
    if (body is List<dynamic>) {
      for (Map<String, dynamic> rawComment in body) {
        comments.add(Comment.fromJson(rawComment));
      }
    }

    return comments;
  }

  Future<Comment> comment(
    int commentId, {
    bool? force,
    CancelToken? cancelToken,
  }) async {
    Map<String, dynamic> body = await _dio
        .get(
          'comments.json/$commentId.json',
          options: forceOptions(force),
          cancelToken: cancelToken,
        )
        .then((response) => response.data);

    return Comment.fromJson(body);
  }

  Future<void> postComment(int postId, String text) async {
    await cache?.deleteFromPath(
      RegExp(RegExp.escape('comments.json')),
      queryParams: {'search[post_id]': postId.toString()},
    );

    Map<String, dynamic> body = {
      'comment[body]': text,
      'comment[post_id]': postId,
      'commit': 'Submit',
    };

    await _dio.post('comments.json', data: FormData.fromMap(body));
  }

  Future<void> updateComment(int commentId, int postId, String text) async {
    await cache?.deleteFromPath(
      RegExp(RegExp.escape('comments.json')),
      queryParams: {'search[post_id]': postId.toString()},
    );

    await cache?.deleteFromPath(
      RegExp(RegExp.escape('comments/$commentId.json')),
    );

    Map<String, dynamic> body = {
      'comment[body]': text,
      'comment[post_id]': postId,
      'commit': 'Submit',
    };

    await _dio.patch('comments/$commentId.json', data: FormData.fromMap(body));
  }

  Future<void> voteComment(int commentId, bool upvote, bool replace) async {
    await _dio.post(
      'comments/$commentId/votes.json',
      queryParameters: {
        'score': upvote ? 1 : -1,
        'no_unvote': replace,
      },
    );
  }

  Future<void> reportComment(int commentId, String reason) async {
    await _dio.post(
      'tickets',
      queryParameters: {
        'ticket[reason]': reason,
        'ticket[disp_id]': commentId,
        'ticket[qtype]': 'comment',
      },
      options: Options(
        validateStatus: (status) => status == 302,
      ),
    );
  }

  Future<List<Topic>> topics(
    int page, {
    String? search,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    String? title = search?.isNotEmpty ?? false ? search : null;
    Object body = await _dio
        .get(
          'forum_topics.json',
          queryParameters: {
            'page': page,
            'search[title_matches]': title,
          },
          options: forceOptions(force),
          cancelToken: cancelToken,
        )
        .then((response) => response.data);

    List<Topic> threads = [];
    if (body is List<dynamic>) {
      for (Map<String, dynamic> raw in body) {
        threads.add(Topic.fromJson(raw));
      }
    }

    return threads;
  }

  Future<Topic> topic(
    int topicId, {
    bool? force,
    CancelToken? cancelToken,
  }) async {
    Map<String, dynamic> body = await _dio
        .get(
          'forum_topics/$topicId.json',
          options: forceOptions(force),
          cancelToken: cancelToken,
        )
        .then((response) => response.data);

    return Topic.fromJson(body);
  }

  Future<List<Reply>> replies(
    int topicId,
    String page, {
    bool? force,
    CancelToken? cancelToken,
  }) async {
    Object body = await _dio
        .get(
          'forum_posts.json',
          queryParameters: {
            'commit': 'Search',
            'search[topic_id]': topicId,
            'page': page,
          },
          options: forceOptions(force),
          cancelToken: cancelToken,
        )
        .then((response) => response.data);

    List<Reply> replies = [];
    if (body is List<dynamic>) {
      for (Map<String, dynamic> raw in body) {
        replies.add(Reply.fromJson(raw));
      }
    }

    return replies;
  }

  Future<Reply> reply(
    int replyId, {
    bool? force,
    CancelToken? cancelToken,
  }) async {
    Map<String, dynamic> body = await _dio
        .get(
          'forum_posts/$replyId.json',
          options: forceOptions(force),
          cancelToken: cancelToken,
        )
        .then((response) => response.data);

    return Reply.fromJson(body);
  }
}
