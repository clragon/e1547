import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/comment/comment.dart';
import 'package:e1547/follow/follow.dart';
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

late final Client client = Client();

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
    initializeCurrentUser(reset: true);
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

  CurrentUser? _currentUser;
  Completer _currentUserRequest = Completer()..complete();

  Future<void> initializeCurrentUser({bool reset = false}) async {
    if (_currentUserRequest.isCompleted) {
      _currentUserRequest = Completer();
    } else {
      return _currentUserRequest.future;
    }
    if (reset) {
      _currentUser = null;
      _currentAvatar = null;
    }
    if (!await isLoggedIn) {
      _currentUserRequest.complete();
      return;
    }
    if (_currentUser == null) {
      _currentUser = await authedUser();
      List<String> updated = _currentUser!.blacklistedTags.split('\n');
      updated = updated.trim();
      updated.removeWhere((element) => element.isEmpty);
      settings.denylist.value = updated;
    }
    if (_currentAvatar == null) {
      int? avatarId = _currentUser?.avatarId;
      if (avatarId != null) {
        Post post = await this.post(avatarId);
        _currentAvatar = post;
      }
    }
    _currentUserRequest.complete();
  }

  Future<CurrentUser?> get currentUser async {
    await initializeCurrentUser();
    return _currentUser;
  }

  Post? _currentAvatar;

  Future<Post?> get currentAvatar async {
    await initializeCurrentUser();
    return _currentAvatar;
  }

  bool postIsIgnored(Post post) {
    return (post.file.url == null && !post.flags.deleted) ||
        post.file.ext == 'swf';
  }

  Future<List<Post>> postsFromJson(List<dynamic> json) async {
    List<Post> posts = [];
    for (Map<String, dynamic> raw in json) {
      Post post = Post.fromMap(raw);
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
        .getWithCache(
          'posts.json',
          cacheManager,
          queryParameters: {
            'tags': tags,
            'page': page,
            'limit': limit,
          },
          keyExtras: {
            'tags': tags,
          },
          forceRefresh: force,
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

    Map<RegExp, Future<List<Post>> Function(RegExpMatch match, String? result)>
        regexes = {
      poolRegex(): (match, result) => poolPosts(
            int.parse(match.namedGroup('id')!),
            page,
            reverse: reversePools ?? false,
            force: force,
          ),
      if (username != null)
        favRegex(username): (match, result) =>
            favorites(page, limit: limit, force: force),
    };

    for (final entry in regexes.entries) {
      RegExpMatch? match = entry.key.firstMatch(search!.trim());
      if (match != null) {
        return entry.value(match, search);
      }
    }

    return postsRaw(page, search: search, limit: limit, force: force ?? false);
  }

  Future<List<Post>> favorites(int page, {int? limit, bool? force}) async {
    await initialized;
    Map body = await dio
        .getWithCache(
          'favorites.json',
          cacheManager,
          queryParameters: {
            'page': page,
            'limit': limit,
          },
          forceRefresh: force,
        )
        .then((response) => response.data);

    return (postsFromJson(body['posts']));
  }

  Future<bool> addFavorite(int postId) async {
    if (!await isLoggedIn) {
      return false;
    }

    await dio.clearCacheKey(
      'posts/$postId.json',
      cacheManager,
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

    await dio.clearCacheKey(
      'posts/$postId.json',
      cacheManager,
    );

    return validateCall(
      () => dio.delete('favorites/$postId.json'),
    );
  }

  Future<bool> votePost(int postId, bool upvote, bool replace) async {
    if (!await isLoggedIn) {
      return false;
    }

    await dio.clearCacheKey(
      'posts/$postId.json',
      cacheManager,
    );

    return validateCall(
      () => dio.post('posts/$postId/votes.json', queryParameters: {
        'score': upvote ? 1 : -1,
        'no_unvote': replace,
      }),
    );
  }

  Future<List<Pool>> pools(int page, {String? search, bool? force}) async {
    List body = await dio
        .getWithCache(
          'pools.json',
          cacheManager,
          queryParameters: {
            'search[name_matches]': search,
            'page': page,
          },
          keyExtras: {
            'search[name_matches]': search,
          },
          forceRefresh: force,
        )
        .then((response) => response.data);

    List<Pool> pools = [];
    for (Map<String, dynamic> rawPool in body) {
      Pool pool = Pool.fromMap(rawPool);
      pools.add(pool);
    }

    return pools;
  }

  Future<Pool> pool(int poolId, {bool? force}) async {
    Map<String, dynamic> body = await dio
        .getWithCache(
          'pools/$poolId.json',
          cacheManager,
          forceRefresh: force,
        )
        .then((response) => response.data);

    return Pool.fromMap(body);
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

  Future<List<Post>> follows(int page, {int attempt = 0, bool? force}) async {
    List<Post> posts = [];
    List<String> tags = List<Follow>.from(followController.items)
        .map<String>((e) => e.tags)
        .toList();
    // ignore meta tags
    tags.removeWhere((tag) => tag.contains(':'));
    // ignore multitag searches
    tags.removeWhere((tag) => tag.contains(' '));
    // how many requests per requested page.
    int batches = 2;
    // distribute tags over requests evenly.
    int max = 40;
    int length = tags.length;
    int approx = (length / max).ceil();
    if (batches > approx) {
      batches = approx;
    }
    if (approx > batches) {
      int counter = 1;
      while (true) {
        counter++;
        if (approx < batches * counter) {
          approx = batches * counter;
          break;
        }
      }
    }
    if (approx != 0) {
      max = (length / approx).ceil();
    }

    int getTagPage(int page) {
      if (page % approx == 0) {
        return approx;
      } else {
        return page % approx;
      }
    }

    int getSitePage(int page) => (page / approx).ceil();

    int position = (page * batches) + 1;
    for (int i = position - batches; i < position; i++) {
      int tagPage = getTagPage(i);
      int end = (length > tagPage * max) ? tagPage * max : length;
      List<String?> tagSet = tags.sublist((tagPage - 1) * max, end);
      posts.addAll(await this.posts(getSitePage(i),
          search: '~${tagSet.join(' ~')}', force: force));
    }
    posts.sort((one, two) => two.id.compareTo(one.id));
    if (posts.isEmpty && attempt < (approx / batches) - 1) {
      posts.addAll(await follows(page + 1, attempt: attempt + 1));
    }
    return posts;
  }

  Future<List<Post>> follow(
    String tag, {
    bool? force,
    Duration age = const Duration(hours: 1),
    int limit = 5,
  }) async {
    await initialized;
    Map body = await dio
        .getWithCache(
          'posts.json',
          cacheManager,
          queryParameters: {
            'tags': tag,
            'page': 1,
            'limit': limit,
          },
          forceRefresh: force,
          maxAge: age,
          maxStale: Duration(hours: 4),
        )
        .then(
          (response) => response.data,
        );

    return postsFromJson(body['posts']);
  }

  Future<Post> post(int postId, {bool unsafe = false, bool? force}) async {
    await initialized;
    Map body = await dio
        .getWithCache(
          (unsafe ? 'https://${settings.customHost.value}/' : '') +
              'posts/$postId.json',
          cacheManager,
          forceRefresh: force,
        )
        .then((response) => response.data);

    Post post = Post.fromMap(body['post']);
    return post;
  }

  Future<void> updatePost(int postId, Map<String, String?> body) async {
    if (!await isLoggedIn) {
      return;
    }
    await dio.clearCacheKey(
      'posts/$postId.json',
      cacheManager,
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
        .getWithCache(
          'wiki_pages.json',
          cacheManager,
          queryParameters: {
            'search[title]': search,
            'page': page,
          },
          forceRefresh: force,
          keyExtras: {
            'search[title]': search,
          },
        )
        .then((response) => response.data);

    return body.map((entry) => Wiki.fromMap(entry)).toList();
  }

  Future<User> user(String name, {bool? force}) async {
    await initialized;
    Map<String, dynamic> body = await dio
        .getWithCache(
          'users/$name.json',
          cacheManager,
          forceRefresh: force,
        )
        .then((response) => response.data);

    return User.fromMap(body);
  }

  Future<void> reportUser(int userId, String reason) async {
    await initialized;
    await dio.post('tickets', queryParameters: {
      'ticket[reason]': reason,
      'ticket[disp_id]': userId,
      'ticket[qtype]': 'user',
    });
  }

  Future<CurrentUser?> authedUser() async {
    if (!await isLoggedIn) {
      return null;
    }

    Map<String, dynamic> body = await dio
        .get('users/${credentials!.username}.json')
        .then((response) => response.data);

    return CurrentUser.fromMap(body);
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

    initializeCurrentUser(reset: true);
  }

  Future<List<Tag>> tags(String search, {int? category, bool? force}) async {
    await initialized;
    final body = await dio
        .getWithCache(
          'tags.json',
          cacheManager,
          queryParameters: {
            'search[name_matches]': search,
            'search[category]': category,
            'search[order]': 'count',
            'limit': 3,
          },
          forceRefresh: force,
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

  Future<List<AutocompleteTag>> autocomplete(String search,
      {int? category, bool? force}) async {
    await initialized;
    if (category == null) {
      if (search.length < 3) {
        return [];
      }
      final body = await dio
          .getWithCache(
            'tags/autocomplete.json',
            cacheManager,
            queryParameters: {
              'search[name_matches]': search,
            },
            maxAge: Duration(days: 1),
            forceRefresh: force,
          )
          .then((response) => response.data);
      List<AutocompleteTag> tags = [];
      if (body is List) {
        for (final tag in body) {
          tags.add(AutocompleteTag.fromJson(tag));
        }
      }
      tags = tags.take(3).toList();
      return tags;
    } else {
      List<AutocompleteTag> tags = [];
      for (final tag in await this.tags(
        search + '*',
        category: category,
        force: force,
      )) {
        tags.add(
          AutocompleteTag(
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
        .getWithCache(
          'comments.json',
          cacheManager,
          queryParameters: {
            'group_by': 'comment',
            'search[post_id]': postId,
            'page': page,
          },
          forceRefresh: force,
          keyExtras: {
            'search[post_id]': postId,
          },
        )
        .then((response) => response.data);

    List<Comment> comments = [];
    if (body is List) {
      for (Map<String, dynamic> rawComment in body) {
        comments.add(Comment.fromMap(rawComment));
      }
    }

    return comments;
  }

  Future<Comment> comment(int commentId, {bool? force}) async {
    await initialized;
    Map<String, dynamic> body = await dio
        .getWithCache(
          'comments.json/$commentId.json',
          cacheManager,
          forceRefresh: force,
        )
        .then((response) => response.data);

    return Comment.fromMap(body);
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

    await dio.clearCacheKey(
      'comments.json',
      cacheManager,
      keyExtras: {
        'search[post_id]': postId,
      },
    );

    Map<String, dynamic> body = {
      'comment[body]': text,
      'comment[post_id]': postId,
      'commit': 'Submit',
    };
    Future request;
    if (comment != null) {
      await dio.clearCacheKey('comments.json/${comment.id}.json', cacheManager);

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
        .getWithCache(
          'forum_topics.json',
          cacheManager,
          queryParameters: {
            'page': page,
            'search[title_matches]': title,
          },
          forceRefresh: force,
          keyExtras: {
            'search[title_matches]': title,
          },
        )
        .then((response) => response.data);

    List<Topic> threads = [];
    if (body is List) {
      for (Map<String, dynamic> raw in body) {
        threads.add(Topic.fromMap(raw));
      }
    }

    return threads;
  }

  Future<Topic> topic(int topicId, {bool? force}) async {
    await initialized;
    Map<String, dynamic> body = await dio
        .getWithCache(
          'forum_topics/$topicId.json',
          cacheManager,
          forceRefresh: force,
        )
        .then((response) => response.data);

    return Topic.fromMap(body);
  }

  Future<List<Reply>> replies(int topicId, String page, {bool? force}) async {
    await initialized;
    final body = await dio
        .getWithCache(
          'forum_posts.json',
          cacheManager,
          queryParameters: {
            'commit': 'Search',
            'search[topic_id]': topicId,
            'page': page,
          },
          forceRefresh: force,
          keyExtras: {
            'search[topic_id]': topicId,
          },
        )
        .then((response) => response.data);

    List<Reply> replies = [];
    if (body is List) {
      for (Map<String, dynamic> raw in body) {
        replies.add(Reply.fromMap(raw));
      }
    }

    return replies;
  }

  Future<Reply> reply(int replyId, {bool? force}) async {
    await initialized;
    Map<String, dynamic> body = await dio
        .getWithCache(
          'forum_posts/$replyId.json',
          cacheManager,
          forceRefresh: force,
        )
        .then((response) => response.data);

    return Reply.fromMap(body);
  }
}
