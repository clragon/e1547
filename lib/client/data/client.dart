import 'dart:async';
import 'dart:io';

import 'package:async/async.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/comment/comment.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/topic/topic.dart';
import 'package:e1547/user/user.dart';
import 'package:e1547/wiki/wiki.dart';
import 'package:flutter/material.dart';

export 'package:dio/dio.dart' show DioError;

final Client client = Client();

class Client extends ChangeNotifier {
  String get host => settings.host.value;
  Credentials? get credentials => settings.credentials.value;

  late Dio dio;
  late DioCacheManager cacheManager;

  late Future<void> initialized;

  Client() {
    settings.host.addListener(initialize);
    settings.credentials.addListener(initialize);
    initialize();
  }

  Future<void> initialize() async {
    Completer completer = Completer();
    initialized = completer.future;
    String host = 'https://${settings.host.value}/';
    Credentials? credentials = settings.credentials.value;
    dio = Dio(
      defaultDioOptions.copyWith(
        baseUrl: host,
        headers: {
          HttpHeaders.userAgentHeader:
              '${appInfo.appName}/${appInfo.version} (${appInfo.developer})',
          if (credentials != null)
            HttpHeaders.authorizationHeader: credentials.toAuth(),
        },
      ),
    );
    currentUser(force: true);
    dio.interceptors.add(CacheKeyInterceptor());
    cacheManager = DioCacheManager(CacheConfig(baseUrl: host));
    dio.interceptors.add(cacheManager.interceptor);
    notifyListeners();
    if (credentials != null && !await tryLogin(credentials)) {
      logout();
    }
    completer.complete();
  }

  bool get hasLogin => credentials != null;

  Future<bool> get isLoggedIn async {
    await initialized;
    return hasLogin;
  }

  Future<bool> tryLogin(Credentials credentials) async {
    return validateCall(
      () async => dio.get(
        'favorites.json',
        options: Options(
          headers: {
            HttpHeaders.authorizationHeader: credentials.toAuth(),
          },
        ),
      ),
    );
  }

  Future<bool> login(Credentials credentials) async {
    if (await tryLogin(credentials)) {
      settings.credentials.value = credentials;
      return true;
    } else {
      return false;
    }
  }

  Future<void> logout() async {
    settings.credentials.value = null;
  }

  bool postIsIgnored(Post post) {
    return (post.file.url == null && !post.flags.deleted) ||
        post.file.ext == 'swf';
  }

  Future<List<Post>> postsFromJson(List<dynamic> json) async {
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

  Future<List<Post>> postsRaw(int page,
      {String? search, int? limit, bool force = false}) async {
    await initialized;
    String? tags = search != null ? sortTags(search) : '';
    Map body = await dio
        .get(
          'posts.json',
          queryParameters: {
            'tags': tags,
            'page': page,
            'limit': limit,
          },
          options: buildKeyCacheOptions(
            keys: {'tags': tags},
            forceRefresh: force,
          ),
        )
        .then((response) => response.data);

    return postsFromJson(body['posts']);
  }

  Future<List<Post>> posts(
    int page, {
    String? search,
    int? limit,
    bool? reversePools,
    bool? orderFavorites,
    bool? force,
  }) async {
    await initialized;
    String? username;

    if (orderFavorites ?? false) {
      username = credentials?.username;
    }

    Map<RegExp, Future<List<Post>> Function(RegExpMatch match)> regexes = {
      poolRegex(): (match) => poolPosts(
            int.parse(match.namedGroup('id')!),
            page,
            reverse: reversePools ?? false,
            force: force,
          ),
      if (username != null)
        favRegex(username): (match) =>
            favorites(page, limit: limit, force: force),
    };

    for (final entry in regexes.entries) {
      RegExpMatch? match = entry.key.firstMatch(search!.trim());
      if (match != null) {
        return entry.value(match);
      }
    }

    return postsRaw(page, search: search, limit: limit, force: force ?? false);
  }

  Future<List<Post>> favorites(int page, {int? limit, bool? force}) async {
    await initialized;
    Map body = await dio
        .get(
          'favorites.json',
          queryParameters: {
            'page': page,
            'limit': limit,
          },
          options: buildKeyCacheOptions(
            forceRefresh: force,
          ),
        )
        .then((response) => response.data);

    return (postsFromJson(body['posts']));
  }

  Future<bool> addFavorite(int postId) async {
    if (!await isLoggedIn) {
      return false;
    }

    await clearCacheKey(
      'posts/$postId.json',
      cacheManager,
      options: dio.options,
    );

    return validateCall(
      () => dio.post('favorites.json', queryParameters: {
        'post_id': postId,
      }),
    );
  }

  Future<bool> removeFavorite(int postId) async {
    if (!await isLoggedIn) {
      return false;
    }

    await clearCacheKey(
      'posts/$postId.json',
      cacheManager,
      options: dio.options,
    );

    return validateCall(
      () => dio.delete('favorites/$postId.json'),
    );
  }

  Future<bool> votePost(int postId, bool upvote, bool replace) async {
    if (!await isLoggedIn) {
      return false;
    }

    await clearCacheKey(
      'posts/$postId.json',
      cacheManager,
      options: dio.options,
    );

    return validateCall(
      () => dio.post('posts/$postId/votes.json', queryParameters: {
        'score': upvote ? 1 : -1,
        'no_unvote': replace,
      }),
    );
  }

  Future<List<Pool>> pools(int page, {String? search, bool? force}) async {
    List<dynamic> body = await dio
        .get(
          'pools.json',
          queryParameters: {
            'search[name_matches]': search,
            'page': page,
          },
          options: buildKeyCacheOptions(
            keys: {
              'search[name_matches]': search,
            },
            forceRefresh: force,
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
    Map<String, dynamic> body = await dio
        .get(
          'pools/$poolId.json',
          options: buildKeyCacheOptions(
            forceRefresh: force,
          ),
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
    Pool pool = await this.pool(poolId);
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
    await initialized;
    Map body = await dio
        .get(
          '${unsafe ? 'https://${settings.customHost.value}/' : ''}posts/$postId.json',
          options: buildKeyCacheOptions(
            forceRefresh: force,
          ),
        )
        .then((response) => response.data);

    Post post = Post.fromJson(body['post']);
    return post;
  }

  Future<void> updatePost(int postId, Map<String, String?> body) async {
    if (!await isLoggedIn) {
      return;
    }

    await clearCacheKey(
      'posts/$postId.json',
      cacheManager,
      options: dio.options,
    );

    await dio.put('posts/$postId.json', data: FormData.fromMap(body));
  }

  Future<void> reportPost(int postId, int reportId, String reason) async {
    await initialized;
    await dio.post('tickets', queryParameters: {
      'ticket[reason]': reason,
      'ticket[report_reason]': reportId,
      'ticket[disp_id]': postId,
      'ticket[qtype]': 'post',
    });
  }

  Future<void> flagPost(int postId, String flag, {int? parent}) async {
    await initialized;
    await dio.post('post_flags', queryParameters: {
      'post_flag[post_id]': postId,
      'post_flag[reason_name]': flag,
      if (flag == 'inferior' && parent != null) 'post_flag[parent_id]': parent,
    });
  }

  Future<List<Wiki>> wikis(int page, {String? search, bool? force}) async {
    await initialized;
    List body = await dio
        .get(
          'wiki_pages.json',
          queryParameters: {
            'search[title]': search,
            'page': page,
          },
          options: buildKeyCacheOptions(
            forceRefresh: force,
            keys: {
              'search[title]': search,
            },
          ),
        )
        .then((response) => response.data);

    return body.map((entry) => Wiki.fromJson(entry)).toList();
  }

  Future<Wiki> wiki(String name, {bool? force}) async {
    await initialized;
    Map<String, dynamic> body = await dio
        .get(
          'wiki_pages/$name.json',
          options: buildKeyCacheOptions(
            forceRefresh: force,
          ),
        )
        .then((response) => response.data);

    return Wiki.fromJson(body);
  }

  Future<User> user(String name, {bool? force}) async {
    await initialized;
    Map<String, dynamic> body = await dio
        .get(
          'users/$name.json',
          options: buildKeyCacheOptions(
            forceRefresh: force,
          ),
        )
        .then((response) => response.data);

    return User.fromJson(body);
  }

  Future<void> reportUser(int userId, String reason) async {
    await initialized;
    await dio.post('tickets', queryParameters: {
      'ticket[reason]': reason,
      'ticket[disp_id]': userId,
      'ticket[qtype]': 'user',
    });
  }

  AsyncMemoizer<CurrentUser?> _currentUser = AsyncMemoizer();

  Future<CurrentUser?> currentUser({bool? force}) async {
    if (force ?? false) {
      _currentUser = AsyncMemoizer();
      _currentUserAvatar = AsyncMemoizer();
    }

    _currentUser.runOnce(
      () async {
        if (!await isLoggedIn) {
          return null;
        }

        return CurrentUser.fromJson(
          await dio
              .get('users/${credentials!.username}.json')
              .then((response) => response.data),
        );
      },
    );

    return _currentUser.future;
  }

  AsyncMemoizer<Post?> _currentUserAvatar = AsyncMemoizer();

  Future<Post?> currentUserAvatar({bool? force}) async {
    if (force ?? false) {
      _currentUserAvatar = AsyncMemoizer();
    }

    _currentUserAvatar.runOnce(() async {
      if (!await isLoggedIn) {
        return null;
      }

      CurrentUser? user = await currentUser();
      if (user != null && user.avatarId != null) {
        return client.post(user.avatarId!);
      }

      return null;
    });

    return _currentUserAvatar.future;
  }

  Future<void> updateBlacklist(List<String> denylist) async {
    if (!await isLoggedIn) {
      return;
    }

    Map<String, String?> body = {
      'user[blacklisted_tags]': denylist.join('\n'),
    };

    await dio.put('users/${credentials!.username}.json',
        data: FormData.fromMap(body));
  }

  Future<List<Tag>> tags(String search, {int? category, bool? force}) async {
    await initialized;
    final body = await dio
        .get(
          'tags.json',
          queryParameters: {
            'search[name_matches]': search,
            'search[category]': category,
            'search[order]': 'count',
            'limit': 3,
          },
          options: buildKeyCacheOptions(
            forceRefresh: force,
          ),
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

  Future<List<TagSuggestion>> autocomplete(String search,
      {int? category, bool? force}) async {
    await initialized;
    if (category == null) {
      if (search.length < 3) {
        return [];
      }
      final body = await dio
          .get(
            'tags/autocomplete.json',
            queryParameters: {
              'search[name_matches]': search,
            },
            options: buildKeyCacheOptions(
              maxAge: const Duration(days: 1),
              forceRefresh: force,
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
    await initialized;
    final body = await dio
        .get(
          'comments.json',
          queryParameters: {
            'group_by': 'comment',
            'search[post_id]': postId,
            'page': page,
          },
          options: buildKeyCacheOptions(
            forceRefresh: force,
            keys: {'search[post_id]': postId},
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
    await initialized;
    Map<String, dynamic> body = await dio
        .get(
          'comments.json/$commentId.json',
          options: buildKeyCacheOptions(
            forceRefresh: force,
          ),
        )
        .then((response) => response.data);

    return Comment.fromJson(body);
  }

  Future<bool> voteComment(int commentId, bool upvote, bool replace) async {
    if (!await isLoggedIn) {
      return false;
    }

    return validateCall(
      () => dio.post(
        'comments/$commentId/votes.json',
        queryParameters: {
          'score': upvote ? 1 : -1,
          'no_unvote': replace,
        },
      ),
    );
  }

  Future<void> postComment(int postId, String text, {Comment? comment}) async {
    if (!await isLoggedIn) {
      return;
    }

    await clearCacheKey(
      'comments.json',
      cacheManager,
      keyExtras: {'search[post_id]': postId},
      options: dio.options,
    );

    Map<String, dynamic> body = {
      'comment[body]': text,
      'comment[post_id]': postId,
      'commit': 'Submit',
    };
    Future request;
    if (comment != null) {
      await clearCacheKey(
        'comments.json/${comment.id}.json',
        cacheManager,
        options: dio.options,
      );

      request = dio.patch('comments/${comment.id}.json',
          data: FormData.fromMap(body));
    } else {
      request = dio.post('comments.json', data: FormData.fromMap(body));
    }
    await request;
  }

  Future<void> reportComment(int commentId, String reason) async {
    await initialized;
    await dio.post('tickets', queryParameters: {
      'ticket[reason]': reason,
      'ticket[disp_id]': commentId,
      'ticket[qtype]': 'comment',
    });
  }

  Future<List<Topic>> topics(
    int page, {
    String? search,
    bool? force,
  }) async {
    String? title = search?.isNotEmpty ?? false ? search : null;
    final body = await dio
        .get(
          'forum_topics.json',
          queryParameters: {
            'page': page,
            'search[title_matches]': title,
          },
          options: buildKeyCacheOptions(
            forceRefresh: force,
            keys: {'search[title_matches]': title},
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
    await initialized;
    Map<String, dynamic> body = await dio
        .get(
          'forum_topics/$topicId.json',
          options: buildKeyCacheOptions(
            forceRefresh: force,
          ),
        )
        .then((response) => response.data);

    return Topic.fromJson(body);
  }

  Future<List<Reply>> replies(int topicId, String page, {bool? force}) async {
    await initialized;
    final body = await dio
        .get(
          'forum_posts.json',
          queryParameters: {
            'commit': 'Search',
            'search[topic_id]': topicId,
            'page': page,
          },
          options: buildKeyCacheOptions(
            forceRefresh: force,
            keys: {'search[topic_id]': topicId},
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
    await initialized;
    Map<String, dynamic> body = await dio
        .get(
          'forum_posts/$replyId.json',
          options: buildKeyCacheOptions(
            forceRefresh: force,
          ),
        )
        .then((response) => response.data);

    return Reply.fromJson(body);
  }
}
