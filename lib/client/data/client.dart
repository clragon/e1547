import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_db_store/dio_cache_interceptor_db_store.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/comment/comment.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/reply/reply.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/topic/topic.dart';
import 'package:e1547/user/user.dart';
import 'package:e1547/wiki/wiki.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

export 'package:dio/dio.dart' show DioError;

class Client extends ChangeNotifier {
  Client({required AppInfo appInfo, required Settings settings})
      : _appInfo = appInfo,
        _settings = settings {
    _settings.host.addListener(_initialize);
    _settings.credentials.addListener(_initialize);
    _initialize();
  }

  final AppInfo _appInfo;
  final Settings _settings;

  String get host => _settings.host.value;

  Credentials? get credentials => _settings.credentials.value;

  late Dio _dio;
  late final Future<CacheStore> _cache = _getDefaultCache();
  final CacheStore _memoryCache = MemCacheStore();

  Future<CacheStore> _getDefaultCache() async => DbCacheStore(
        databasePath: join(
          (await getTemporaryDirectory()).path,
          _appInfo.appName,
        ),
      );

  final CacheConfig _defaultCacheOptions = CacheConfig(
    maxAge: const Duration(minutes: 5),
  );

  Options _options({
    bool? force,
    Duration? maxAge,
    Map<String, String?>? params,
    CacheStore? store,
  }) =>
      _defaultCacheOptions
          .copyWith(
        maxAge: maxAge != null ? Nullable(maxAge) : null,
            params: Nullable(params),
            policy: (force ?? false) ? CachePolicy.refresh : null,
            store: store,
          )
          .toOptions();

  late Future<void> _initialized;

  Future<void> _initialize() async {
    Completer completer = Completer();
    _initialized = completer.future;
    String host = 'https://${_settings.host.value}/';
    Credentials? credentials = _settings.credentials.value;
    _dio = Dio(
      defaultDioOptions.copyWith(
        baseUrl: host,
        headers: {
          HttpHeaders.userAgentHeader:
              '${_appInfo.appName}/${_appInfo.version} (${_appInfo.developer})',
          if (credentials != null)
            HttpHeaders.authorizationHeader: credentials.basicAuth,
        },
      ),
    );
    currentUser(force: true);

    _dio.interceptors.add(
      CacheInterceptor(
        options: _defaultCacheOptions.copyWith(
          store: await _cache,
        ),
      ),
    );
    _dio.interceptors.add(
      AuthFailureInterceptor(
        onAuthFailure: (credentials) {
          if (credentials == this.credentials) {
            logout();
          }
        },
      ),
    );
    notifyListeners();
    completer.complete();
  }

  bool get hasLogin => credentials != null;

  Future<bool> get isLoggedIn async {
    await _initialized;
    return hasLogin;
  }

  Future<bool> tryLogin(Credentials credentials) async {
    return validateCall(
      () async => _dio.get(
        'favorites.json',
        options: Options(
          headers: {
            HttpHeaders.authorizationHeader: credentials.basicAuth,
          },
        ),
      ),
    );
  }

  Future<bool> login(Credentials credentials) async {
    if (await tryLogin(credentials)) {
      _settings.credentials.value = credentials;
      return true;
    } else {
      return false;
    }
  }

  Future<void> logout() async => _settings.credentials.value = null;

  Future<void> ensureLogin() async {
    if (!await isLoggedIn) {
      throw StateError('User is not logged in!');
    }
  }

  String withHost(String path) =>
      Uri(scheme: 'https', host: host, path: path).toString();

  bool postIsIgnored(Post post) {
    return (post.file.url == null && !post.flags.deleted) ||
        post.file.ext == 'swf';
  }

  Future<List<Post>> _postsFromJson(List<dynamic> json) async {
    List<Post> posts = [];
    for (Map<String, dynamic> raw in json) {
      Post post = Post.fromJson(raw);
      if (postIsIgnored(post)) {
        continue;
      }
      posts.add(post);
    }
    return posts;
  }

  Future<List<Post>> postsRaw(
    int page, {
    int? limit,
    String? search,
    bool? force,
  }) async {
    await _initialized;
    String? tags = search != null ? sortTags(search) : '';
    Map body = await _dio
        .get(
          'posts.json',
          queryParameters: {
            'tags': tags,
            'page': page,
            'limit': limit,
          },
          options: _options(
            params: {'tags': tags},
            force: force,
          ),
        )
        .then((response) => response.data);

    return _postsFromJson(body['posts']);
  }

  Future<List<Post>> posts(
    int page, {
    int? limit,
    String? search,
    bool? reversePools,
    bool? orderFavorites,
    bool? force,
  }) async {
    await _initialized;
    Map<RegExp, Future<List<Post>> Function(RegExpMatch match)> redirects = {
      poolRegex(): (match) => poolPosts(
            int.parse(match.namedGroup('id')!),
            page,
            reverse: reversePools ?? false,
            force: force,
          ),
      if ((orderFavorites ?? false) && credentials?.username != null)
        favRegex(credentials!.username): (match) =>
            favorites(page, limit: limit, force: force),
    };

    for (final entry in redirects.entries) {
      RegExpMatch? match = entry.key.firstMatch(search!.trim());
      if (match != null) {
        return entry.value(match);
      }
    }

    return postsRaw(page, search: search, limit: limit, force: force);
  }

  Future<List<Post>> favorites(int page, {int? limit, bool? force}) async {
    await _initialized;
    Map body = await _dio
        .get(
          'favorites.json',
          queryParameters: {
            'page': page,
            'limit': limit,
          },
          options: _options(force: force),
        )
        .then((response) => response.data);

    return (_postsFromJson(body['posts']));
  }

  Future<void> addFavorite(int postId) async {
    await (await _cache)
        .deleteFromPath(RegExp(RegExp.escape('posts/$postId.json')));

    await _dio.post('favorites.json', queryParameters: {'post_id': postId});
  }

  Future<void> removeFavorite(int postId) async {
    await ensureLogin();

    await (await _cache)
        .deleteFromPath(RegExp(RegExp.escape('posts/$postId.json')));

    await _dio.delete('favorites/$postId.json');
  }

  Future<void> votePost(int postId, bool upvote, bool replace) async {
    await ensureLogin();

    await (await _cache)
        .deleteFromPath(RegExp(RegExp.escape('posts/$postId.json')));

    await _dio.post('posts/$postId/votes.json', queryParameters: {
      'score': upvote ? 1 : -1,
      'no_unvote': replace,
    });
  }

  Future<List<Pool>> pools(int page, {String? search, bool? force}) async {
    List<dynamic> body = await _dio
        .get(
          'pools.json',
          queryParameters: {
            'search[name_matches]': search,
            'page': page,
          },
          options: _options(
            force: force,
            params: {'search[name_matches]': search},
          ),
        )
        .then((response) => response.data);

    List<Pool> pools = [];
    for (Map<String, dynamic> raw in body) {
      Pool pool = Pool.fromJson(raw);
      pools.add(pool);
    }

    return pools;
  }

  Future<Pool> pool(int poolId, {bool? force}) async {
    Map<String, dynamic> body = await _dio
        .get(
          'pools/$poolId.json',
          options: _options(force: force),
        )
        .then((response) => response.data);

    return Pool.fromJson(body);
  }

  Future<List<Post>> poolPosts(
    int poolId,
    int page, {
    bool reverse = false,
    bool? force,
  }) async {
    Pool pool = await this.pool(poolId, force: true);
    List<int> ids = reverse ? pool.postIds.reversed.toList() : pool.postIds;
    int limit = 80;
    int lower = ((page - 1) * limit);
    int upper = lower + limit;

    if (ids.length < lower) {
      return [];
    }
    if (ids.length < upper) {
      upper = ids.length;
    }

    List<int> pageIds = ids.sublist(lower, upper);
    String filter = 'id:${pageIds.join(',')}';

    List<Post> posts = await this.posts(1, search: filter, force: force);
    Map<int, Post> table = {for (Post e in posts) e.id: e};
    posts = (pageIds.map((e) => table[e]).toList()
          ..removeWhere((e) => e == null))
        .cast<Post>();
    return posts;
  }

  Future<Post> post(int postId, {bool unsafe = false, bool? force}) async {
    await _initialized;
    Map<String, dynamic> body = await _dio
        .get(
          '${unsafe ? 'https://${_settings.customHost.value}/' : ''}posts/$postId.json',
          options: _options(force: force),
        )
        .then((response) => response.data);

    return Post.fromJson(body['post']);
  }

  Future<void> updatePost(int postId, Map<String, String?> body) async {
    await (await _cache).deleteFromPath(
      RegExp(RegExp.escape('posts/$postId.json')),
    );

    await _dio.put('posts/$postId.json', data: FormData.fromMap(body));
  }

  Future<void> reportPost(int postId, int reportId, String reason) async {
    await _initialized;
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
    await _initialized;
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

  Future<List<Wiki>> wikis(int page, {String? search, bool? force}) async {
    await _initialized;
    List<dynamic> body = await _dio
        .get(
          'wiki_pages.json',
          queryParameters: {
            'search[title]': search,
            'page': page,
          },
          options: _options(
            force: force,
            params: {'search[title]': search},
          ),
        )
        .then((response) => response.data);

    return body.map((entry) => Wiki.fromJson(entry)).toList();
  }

  Future<Wiki> wiki(String name, {bool? force}) async {
    await _initialized;
    Map<String, dynamic> body = await _dio
        .get(
          'wiki_pages/$name.json',
          options: _options(force: force),
        )
        .then((response) => response.data);

    return Wiki.fromJson(body);
  }

  Future<User> user(String name, {bool? force}) async {
    await _initialized;
    Map<String, dynamic> body = await _dio
        .get(
          'users/$name.json',
          options: _options(force: force),
        )
        .then((response) => response.data);

    return User.fromJson(body);
  }

  Future<void> reportUser(int userId, String reason) async {
    await _initialized;
    await _dio.post(
      'tickets',
      queryParameters: {
        'ticket[reason]': reason,
        'ticket[disp_id]': userId,
        'ticket[qtype]': 'user',
      },
    );
  }

  Future<CurrentUser?> currentUser({bool? force}) async {
    if (!await isLoggedIn) {
      return null;
    }

    Map<String, dynamic> body = await _dio
        .get(
          'users/${credentials!.username}.json',
          options: _options(
            force: force,
            store: _memoryCache,
          ),
        )
        .then((response) => response.data);

    return CurrentUser.fromJson(body);
  }

  Future<Post?> currentUserAvatar({bool? force}) async {
    int? avatarId = (await currentUser(force: force))?.avatarId;
    if (avatarId == null) return null;
    Map body = await _dio
        .get(
          'posts/$avatarId.json',
          options: _options(
            force: force,
            store: _memoryCache,
          ),
        )
        .then((response) => response.data);

    return Post.fromJson(body['post']);
  }

  Future<void> updateBlacklist(List<String> denylist) async {
    Map<String, String?> body = {
      'user[blacklisted_tags]': denylist.join('\n'),
    };

    await _dio.put('users/${credentials!.username}.json',
        data: FormData.fromMap(body));
  }

  Future<List<Tag>> tags(String search, {int? category, bool? force}) async {
    await _initialized;
    final body = await _dio
        .get(
          'tags.json',
          queryParameters: {
            'search[name_matches]': search,
            'search[category]': category,
            'search[order]': 'count',
            'limit': 3,
          },
          options: _options(force: force),
        )
        .then((response) => response.data);
    List<Tag> tags = [];
    if (body is List) {
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
  }) async {
    await _initialized;
    if (category == null) {
      if (search.length < 3) {
        return [];
      }
      final body = await _dio
          .get(
            'tags/autocomplete.json',
            queryParameters: {
              'search[name_matches]': search,
            },
            options: _options(
              force: force,
              maxAge: const Duration(days: 1),
            ),
          )
          .then((response) => response.data);
      List<TagSuggestion> tags = [];
      if (body is List) {
        for (final tag in body) {
          tags.add(TagSuggestion.fromJson(tag));
        }
      }
      tags = tags.take(3).toList();
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

  Future<List<Comment>> comments(int postId, String page, {bool? force}) async {
    await _initialized;
    final body = await _dio
        .get(
          'comments.json',
          queryParameters: {
            'group_by': 'comment',
            'search[post_id]': postId,
            'page': page,
          },
          options: _options(
            force: force,
            params: {'search[post_id]': postId.toString()},
          ),
        )
        .then((response) => response.data);

    List<Comment> comments = [];
    if (body is List) {
      for (Map<String, dynamic> rawComment in body) {
        comments.add(Comment.fromJson(rawComment));
      }
    }

    return comments;
  }

  Future<Comment> comment(int commentId, {bool? force}) async {
    await _initialized;
    Map<String, dynamic> body = await _dio
        .get(
          'comments.json/$commentId.json',
          options: _options(force: force),
        )
        .then((response) => response.data);

    return Comment.fromJson(body);
  }

  Future<void> voteComment(int commentId, bool upvote, bool replace) async {
    await ensureLogin();

    await _dio.post(
      'comments/$commentId/votes.json',
      queryParameters: {
        'score': upvote ? 1 : -1,
        'no_unvote': replace,
      },
    );
  }

  Future<void> postComment(int postId, String text, {Comment? comment}) async {
    await ensureLogin();
    await (await _cache).deleteFromPath(
      RegExp(RegExp.escape('comments.json')),
      queryParams: {'search[post_id]': postId.toString()},
    );

    Map<String, dynamic> body = {
      'comment[body]': text,
      'comment[post_id]': postId,
      'commit': 'Submit',
    };
    Future<Response> request;
    if (comment != null) {
      await (await _cache).deleteFromPath(
        RegExp(RegExp.escape('comments/${comment.id}.json')),
      );

      request = _dio.patch('comments/${comment.id}.json',
          data: FormData.fromMap(body));
    } else {
      request = _dio.post('comments.json', data: FormData.fromMap(body));
    }
    await request;
  }

  Future<void> reportComment(int commentId, String reason) async {
    await ensureLogin();
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
  }) async {
    String? title = search?.isNotEmpty ?? false ? search : null;
    final body = await _dio
        .get(
          'forum_topics.json',
          queryParameters: {
            'page': page,
            'search[title_matches]': title,
          },
          options: _options(
            force: force,
            params: {'search[title_matches]': title},
          ),
        )
        .then((response) => response.data);

    List<Topic> threads = [];
    if (body is List) {
      for (Map<String, dynamic> raw in body) {
        threads.add(Topic.fromJson(raw));
      }
    }

    return threads;
  }

  Future<Topic> topic(int topicId, {bool? force}) async {
    await _initialized;
    Map<String, dynamic> body = await _dio
        .get(
          'forum_topics/$topicId.json',
          options: _options(force: force),
        )
        .then((response) => response.data);

    return Topic.fromJson(body);
  }

  Future<List<Reply>> replies(int topicId, String page, {bool? force}) async {
    await _initialized;
    final body = await _dio
        .get(
          'forum_posts.json',
          queryParameters: {
            'commit': 'Search',
            'search[topic_id]': topicId,
            'page': page,
          },
          options: _options(
            force: force,
            params: {'search[topic_id]': topicId.toString()},
          ),
        )
        .then((response) => response.data);

    List<Reply> replies = [];
    if (body is List) {
      for (Map<String, dynamic> raw in body) {
        replies.add(Reply.fromJson(raw));
      }
    }

    return replies;
  }

  Future<Reply> reply(int replyId, {bool? force}) async {
    await _initialized;
    Map<String, dynamic> body = await _dio
        .get(
          'forum_posts/$replyId.json',
          options: _options(force: force),
        )
        .then((response) => response.data);

    return Reply.fromJson(body);
  }
}

class ClientProvider
    extends SubChangeNotifierProvider2<AppInfo, Settings, Client> {
  ClientProvider()
      : super(
          create: (context, appInfo, settings) =>
              Client(appInfo: appInfo, settings: settings),
        );
}
