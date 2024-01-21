import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/comment/comment.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/logs/logs.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/reply/reply.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/ticket/ticket.dart';
import 'package:e1547/topic/topic.dart';
import 'package:e1547/traits/traits.dart';
import 'package:e1547/user/user.dart';
import 'package:e1547/wiki/wiki.dart';
import 'package:flutter/foundation.dart';

export 'package:dio/dio.dart' show CancelToken;

class Client {
  Client({
    required this.identity,
    required this.traits,
    this.cache,
  }) : status = ValueNotifier(const ClientSyncStatus()) {
    _dio = Dio(
      BaseOptions(
        baseUrl: _host,
        headers: {
          HttpHeaders.userAgentHeader: AppInfo.instance.userAgent,
          ...?identity.headers,
        },
        sendTimeout: const Duration(seconds: 30),
        connectTimeout: const Duration(seconds: 30),
      ),
    );
    _dio.interceptors.add(NewlineReplaceInterceptor());
    _dio.interceptors.add(LoggingDioInterceptor());
    if (cache != null) {
      _dio.interceptors.add(
        ClientCacheInterceptor(
          options: ClientCacheConfig(
            store: cache,
            maxAge: const Duration(minutes: 5),
            pageParam: 'page',
          ),
        ),
      );
    }
  }

  void dispose() {
    _dio.close();
  }

  /// The user identity of this client.
  final Identity identity;

  /// The settings for this identity.
  final ValueNotifier<Traits> traits;

  /// The sync status of this client.
  final ValueNotifier<ClientSyncStatus> status;

  /// The cache to use for this client.
  final CacheStore? cache;

  late Dio _dio;

  late final String _host = normalizeHostUrl(identity.host);

  String get host => identity.host;

  bool get hasLogin => identity.username != null;

  /// Appends [value] to [host] and returns the result.
  String withHost(String value) {
    Uri uri = Uri.parse(_host);
    Uri other = Uri.parse(value);

    String path = other.path;
    if (!path.startsWith('/')) path = '/$path';
    path = '${uri.path}$path';

    Map<String, dynamic>? queryParameters = other.queryParameters;
    if (queryParameters.isEmpty) queryParameters = null;

    String? fragment = other.fragment;
    if (fragment.isEmpty) fragment = null;

    return uri
        .replace(
          path: path,
          queryParameters: queryParameters,
          fragment: fragment,
        )
        .toString();
  }

  Future<void> availability() async {
    String body = await _dio.get('').then((response) => response.data);
    String? favicon = findFavicon(body);
    if (favicon != null) {
      traits.value = traits.value.copyWith(
        favicon: withHost(favicon),
      );
    }
  }

  Future<List<Post>> posts({
    int? page,
    int? limit,
    QueryMap? query,
    bool? ordered,
    bool? orderPoolsByOldest,
    bool? orderFavoritesByAdded,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    ordered ??= true;
    String? tags = query?['tags'];
    if (ordered && tags != null) {
      Map<RegExp, Future<List<Post>> Function(RegExpMatch match)> redirects = {
        poolRegex(): (match) => postsByPool(
              id: int.parse(match.namedGroup('id')!),
              page: page,
              orderByOldest: orderPoolsByOldest ?? true,
              force: force,
              cancelToken: cancelToken,
            ),
        if ((orderFavoritesByAdded ?? false) && identity.username != null)
          favRegex(identity.username!): (match) =>
              favorites(page: page, limit: limit, force: force),
      };

      for (final entry in redirects.entries) {
        RegExpMatch? match = entry.key.firstMatch(tags);
        if (match != null) {
          return entry.value(match);
        }
      }
    }

    Map<String, dynamic> body = await _dio
        .get(
          '/posts.json',
          queryParameters: {
            'page': page,
            'limit': limit,
            ...?query,
          },
          options: forceOptions(force),
          cancelToken: cancelToken,
        )
        .then((response) => response.data);

    List<Post> posts =
        List<Post>.from(body['posts'].map((e) => E621Post.fromJson(e)));

    posts.removeWhere(
      (e) => (e.file == null && !e.isDeleted) || e.ext == 'swf',
    );

    return posts;
  }

  Future<List<Post>> postsByIds({
    required List<int> ids,
    int? limit,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    limit = max(0, min(limit ?? 75, 100));

    List<List<int>> chunks = [];
    for (int i = 0; i < ids.length; i += limit) {
      chunks.add(ids.sublist(i, min(i + limit, ids.length)));
    }

    List<Post> result = [];
    for (final chunk in chunks) {
      if (chunk.isEmpty) continue;
      String filter = 'id:${chunk.join(',')}';
      List<Post> part = await posts(
        query: {'tags': filter},
        limit: limit,
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
    tags.removeWhere((e) => e.contains(' ') || e.contains(':'));
    if (tags.isEmpty) return [];
    int max = 40;
    int pages = (tags.length / max).ceil();
    int chunkSize = (tags.length / pages).ceil();

    int tagPage = page % pages != 0 ? page % pages : pages;
    int sitePage = (page / pages).ceil();

    List<String> chunk =
        tags.sublist((tagPage - 1) * chunkSize).take(chunkSize).toList();
    String filter = chunk.map((e) => '~$e').join(' ');
    return posts(
      page: sitePage,
      query: QueryMap()..['tags'] = filter,
      limit: limit,
      ordered: false,
      force: force,
      cancelToken: cancelToken,
    );
  }

  Future<List<Post>> postsByFavoriter({
    required String username,
    int? page,
    int? limit,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    return posts(
      page: page,
      query: QueryMap()..['tags'] = 'fav:$username',
      limit: limit,
      ordered: false,
      force: force,
      cancelToken: cancelToken,
    );
  }

  Future<List<Post>> postsByUploader({
    required String username,
    int? page,
    int? limit,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    return posts(
      page: page,
      query: QueryMap()..['tags'] = 'user:$username',
      limit: limit,
      ordered: false,
      force: force,
      cancelToken: cancelToken,
    );
  }

  Future<Post> post(int postId, {bool? force, CancelToken? cancelToken}) async {
    Map<String, dynamic> body = await _dio
        .get(
          '/posts/$postId.json',
          options: forceOptions(force),
          cancelToken: cancelToken,
        )
        .then((response) => response.data);

    return E621Post.fromJson(body['post']);
  }

  Future<void> updatePost(int postId, Map<String, String?> body) async {
    await cache?.deleteFromPath(
      RegExp(RegExp.escape('/posts/$postId.json')),
    );

    await _dio.put('/posts/$postId.json', data: FormData.fromMap(body));
  }

  Future<void> votePost(int postId, bool upvote, bool replace) async {
    await cache?.deleteFromPath(RegExp(RegExp.escape('/posts/$postId.json')));
    await _dio.post('/posts/$postId/votes.json', queryParameters: {
      'score': upvote ? 1 : -1,
      'no_unvote': replace,
    });
  }

  Future<void> reportPost(int postId, int reportId, String reason) async {
    await _dio.post(
      '/tickets',
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
      '/post_flags.json',
      queryParameters: {
        'post_flag[post_id]': postId,
        'post_flag[reason_name]': flag,
        if (flag == 'inferior' && parent != null)
          'post_flag[parent_id]': parent,
      },
    );
  }

  Future<List<Post>> favorites({
    int? page,
    int? limit,
    QueryMap? query,
    bool? orderByAdded,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    if (identity.username == null) {
      throw NoUserLoginException();
    }
    orderByAdded ??= true;
    String tags = query?['tags'] ?? '';
    if (tags.isEmpty && orderByAdded) {
      Map<String, dynamic> body = await _dio
          .get(
            '/favorites.json',
            queryParameters: {
              'page': page,
              'limit': limit,
              ...?query,
            },
            options: forceOptions(force),
            cancelToken: cancelToken,
          )
          .then((response) => response.data);

      List<Post> result = List.from(body['posts'].map(E621Post.fromJson));
      result.removeWhere((e) => e.isDeleted || e.file == null);
      return result;
    } else {
      return posts(
        page: page,
        query: {
          ...?query,
          'tags': (TagMap.parse(tags)..['fav'] = identity.username).toString(),
        },
        ordered: false,
        force: force,
        cancelToken: cancelToken,
      );
    }
  }

  Future<void> addFavorite(int postId) async {
    await cache?.deleteFromPath(RegExp(RegExp.escape('/posts/$postId.json')));
    await _dio.post('/favorites.json', queryParameters: {'post_id': postId});
  }

  Future<void> removeFavorite(int postId) async {
    await cache?.deleteFromPath(RegExp(RegExp.escape('/posts/$postId.json')));
    await _dio.delete('/favorites/$postId.json');
  }

  Future<List<PostFlag>> flags({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    List<dynamic> body = await _dio
        .get(
          '/post_flags.json',
          queryParameters: {
            'page': page,
            'limit': limit,
            ...?query,
          },
          options: forceOptions(force),
          cancelToken: cancelToken,
        )
        .then((response) => response.data);

    return body.map((e) => PostFlag.fromJson(e)).toList();
  }

  Future<List<Pool>> pools({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    List<dynamic> body = await _dio
        .get(
          '/pools.json',
          queryParameters: {
            'page': page,
            'limit': limit,
            ...?query,
          },
          options: forceOptions(force),
          cancelToken: cancelToken,
        )
        .then((response) => response.data);

    List<Pool> pools = [];
    for (Map<String, dynamic> raw in body) {
      Pool pool = E621Pool.fromJson(raw);
      pools.add(pool);
    }

    return pools;
  }

  Future<Pool> pool({
    required int id,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    Map<String, dynamic> body = await _dio
        .get(
          '/pools/$id.json',
          options: forceOptions(force),
          cancelToken: cancelToken,
        )
        .then((response) => response.data);

    return E621Pool.fromJson(body);
  }

  Future<List<Post>> postsByPool({
    required int id,
    int? page,
    int? limit,
    bool orderByOldest = true,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    page ??= 1;
    Account? user = await account(cancelToken: cancelToken);
    int limit = user?.perPage ?? 75;
    Pool pool = await this.pool(id: id, force: force, cancelToken: cancelToken);
    List<int> ids = pool.postIds;
    if (!orderByOldest) ids = ids.reversed.toList();
    int lower = (page - 1) * limit;
    if (lower > ids.length) return [];
    ids = ids.sublist(lower).take(limit).toList();
    return postsByIds(
      ids: ids,
      limit: limit,
      force: force,
      cancelToken: cancelToken,
    );
  }

  Future<List<Wiki>> wikis({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    List<dynamic> body = await _dio
        .get(
          '/wiki_pages.json',
          queryParameters: {
            'page': page,
            'limit': limit,
            ...?query,
          },
          options: forceOptions(force),
          cancelToken: cancelToken,
        )
        .then((response) => response.data);

    return body.map((entry) => E621Wiki.fromJson(entry)).toList();
  }

  Future<Wiki> wiki({
    required String id,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    Map<String, dynamic> body = await _dio
        .get(
          '/wiki_pages/$id.json',
          options: forceOptions(force),
          cancelToken: cancelToken,
        )
        .then((response) => response.data);

    return E621Wiki.fromJson(body);
  }

  Future<User> user({
    required String id,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    Map<String, dynamic> body = await _dio
        .get(
          '/users/$id.json',
          options: forceOptions(force),
          cancelToken: cancelToken,
        )
        .then((response) => response.data);

    return E621User.fromJson(body);
  }

  Future<void> reportUser({
    required int id,
    required String reason,
  }) async {
    await _dio.post(
      '/tickets',
      queryParameters: {
        'ticket[reason]': reason,
        'ticket[disp_id]': id,
        'ticket[qtype]': 'user',
      },
    );
  }

  final CacheStore _userMemoryCache = MemCacheStore();

  Future<Account?> account({
    bool? force,
    CancelToken? cancelToken,
  }) async {
    if (!hasLogin) return null;

    Map<String, dynamic> body = await _dio
        .get(
          '/users/${identity.username}.json',
          options: ClientCacheConfig(
            store: BackupCacheStore(
              primary: _userMemoryCache,
              secondary: cache ?? _userMemoryCache,
            ),
            policy:
                (force ?? false) ? CachePolicy.refresh : CachePolicy.request,
          ).toOptions(),
          cancelToken: cancelToken,
        )
        .then((response) => response.data);

    Account result = E621Account.fromJson(body);

    Post? avatar;

    if (result.avatarId != null) {
      avatar = await post(
        result.avatarId!,
        force: force,
        cancelToken: cancelToken,
      );
    }

    traits.value = traits.value.copyWith(
      denylist: result.blacklistedTags?.split('\n').trim() ?? [],
      avatar: avatar?.file,
    );

    return result;
  }

  Future<void> updateTraits({
    required Traits traits,
    CancelToken? cancelToken,
  }) async {
    if (!hasLogin) {
      this.traits.value = traits;
      return;
    }
    Traits previous = this.traits.value;
    try {
      if (!listEquals(traits.denylist, this.traits.value.denylist)) {
        this.traits.value = traits;

        Map<String, dynamic> body = {
          'user[blacklisted_tags]': traits.denylist.join('\n'),
        };

        await _dio.put(
          '/users/${identity.username}.json',
          data: FormData.fromMap(body),
          cancelToken: cancelToken,
        );
      }
    } on DioException {
      this.traits.value = previous;
      rethrow;
    }
  }

  Future<void> syncTraits({bool? force, CancelToken? cancelToken}) async {
    await account(
      force: force,
      cancelToken: cancelToken,
    );
  }

  Future<List<Tag>> tags({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    Object body = await _dio
        .get(
          '/tags.json',
          queryParameters: {
            'page': page,
            'limit': limit,
            ...?query,
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

  Future<List<TagSuggestion>> autocomplete({
    required String search,
    int? category,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    if (search.contains(':')) return [];
    if (category == null) {
      if (search.length < 3) return [];
      Object body = await _dio
          .get(
            '/tags/autocomplete.json',
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
        limit: 3,
        query: {
          'search[name_matches]': '$search*',
          'search[category]': category,
          'search[order]': 'count',
        }.toQuery(),
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

  Future<String?> tagAliases({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    Object body = await _dio
        .get(
          '/tag_aliases.json',
          queryParameters: {
            'page': page,
            'limit': limit,
            ...?query,
          },
          options: forceOptions(force),
          cancelToken: cancelToken,
        )
        .then((value) => value.data);

    if (body is List<dynamic>) {
      body.removeWhere((e) => e['status'] == 'deleted');
      if (body.isEmpty) return null;
      return body.first['consequent_name'];
    }

    return null;
  }

  Future<List<Comment>> comments({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    Object body = await _dio
        .get(
          '/comments.json',
          queryParameters: {
            'page': page,
            'limit': limit,
            ...?query,
          },
          options: forceOptions(force),
          cancelToken: cancelToken,
        )
        .then((response) => response.data);

    List<Comment> comments = [];
    if (body is List<dynamic>) {
      for (Map<String, dynamic> rawComment in body) {
        comments.add(E621Comment.fromJson(rawComment));
      }
    }

    return comments;
  }

  Future<List<Comment>> commentsByPost({
    required int id,
    int? page,
    int? limit,
    bool? ascending,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    return comments(
      page: page,
      limit: limit,
      query: {
        'group_by': 'comment',
        'search[post_id]': id,
        'search[order]': ascending ?? false ? 'id_asc' : 'id_desc',
      }.toQuery(),
      force: force,
      cancelToken: cancelToken,
    );
  }

  Future<Comment> comment({
    required int id,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    Map<String, dynamic> body = await _dio
        .get(
          '/comments.json/$id.json',
          options: forceOptions(force),
          cancelToken: cancelToken,
        )
        .then((response) => response.data);

    return E621Comment.fromJson(body);
  }

  Future<void> postComment({
    required int postId,
    required String content,
  }) async {
    await cache?.deleteFromPath(
      RegExp(RegExp.escape('/comments.json')),
      queryParams: {'search[post_id]': postId.toString()},
    );

    Map<String, dynamic> body = {
      'comment[body]': content,
      'comment[post_id]': postId,
      'commit': 'Submit',
    };

    await _dio.post('/comments.json', data: FormData.fromMap(body));
  }

  Future<void> updateComment({
    required int id,
    required int postId,
    required String content,
  }) async {
    await cache?.deleteFromPath(
      RegExp(RegExp.escape('/comments.json')),
      queryParams: {'search[post_id]': postId.toString()},
    );

    await cache?.deleteFromPath(
      RegExp(RegExp.escape('/comments/$id.json')),
    );

    Map<String, dynamic> body = {
      'comment[body]': content,
      'commit': 'Submit',
    };

    await _dio.patch('/comments/$id.json', data: FormData.fromMap(body));
  }

  Future<void> voteComment({
    required int id,
    required bool upvote,
    required bool replace,
  }) async {
    await _dio.post(
      '/comments/$id/votes.json',
      queryParameters: {
        'score': upvote ? 1 : -1,
        'no_unvote': replace,
      },
    );
  }

  Future<void> reportComment({
    required int id,
    required String reason,
  }) async {
    await _dio.post(
      '/tickets',
      queryParameters: {
        'ticket[reason]': reason,
        'ticket[disp_id]': id,
        'ticket[qtype]': 'comment',
      },
      options: Options(
        validateStatus: (status) => status == 302,
      ),
    );
  }

  Future<List<Topic>> topics({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    Object body = await _dio
        .get(
          '/forum_topics.json',
          queryParameters: {
            'page': page,
            'limit': limit,
            ...?query,
          },
          options: forceOptions(force),
          cancelToken: cancelToken,
        )
        .then((response) => response.data);

    List<Topic> threads = [];
    if (body is List<dynamic>) {
      for (Map<String, dynamic> raw in body) {
        threads.add(E621Topic.fromJson(raw));
      }
    }

    return threads;
  }

  Future<Topic> topic({
    required int id,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    Map<String, dynamic> body = await _dio
        .get(
          '/forum_topics/$id.json',
          options: forceOptions(force),
          cancelToken: cancelToken,
        )
        .then((response) => response.data);

    return E621Topic.fromJson(body);
  }

  Future<List<Reply>> replies({
    required int id,
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    Object body = await _dio
        .get(
          '/forum_posts.json',
          queryParameters: {
            'page': page,
            'limit': limit,
            ...?query,
          },
          options: forceOptions(force),
          cancelToken: cancelToken,
        )
        .then((response) => response.data);

    List<Reply> replies = [];
    if (body is List<dynamic>) {
      for (Map<String, dynamic> raw in body) {
        replies.add(E621Reply.fromJson(raw));
      }
    }

    return replies;
  }

  Future<List<Reply>> repliesByTopic({
    required int id,
    int? page,
    int? limit,
    bool? ascending,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    return replies(
      id: id,
      page: page,
      limit: limit,
      query: {
        'search[topic_id]': id,
        'search[order]': ascending ?? false ? 'id_asc' : 'id_desc',
      }.toQuery(),
      force: force,
      cancelToken: cancelToken,
    );
  }

  Future<Reply> reply({
    required int id,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    Map<String, dynamic> body = await _dio
        .get(
          '/forum_posts/$id.json',
          options: forceOptions(force),
          cancelToken: cancelToken,
        )
        .then((response) => response.data);

    return E621Reply.fromJson(body);
  }
}
