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
import 'package:mutex/mutex.dart';

export 'package:dio/dio.dart' show DioError;

late final Client client = Client();

class Client {
  late Dio dio;
  late DioCacheManager cacheManager;

  Future<bool>? initialized;

  Client() {
    settings.host.addListener(initialize);
    settings.credentials.addListener(initialize);
    initialize();
  }

  bool get isSafe => settings.host.value != settings.customHost.value;

  String get host => settings.host.value;

  Future<bool> initialize() async {
    Future<bool> init() async {
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
      if (credentials != null) {
        try {
          await tryLogin(credentials.username, credentials.password);
        } on DioError catch (e) {
          if (e.type != DioErrorType.other) {
            logout();
          }
        }
        return true;
      } else {
        return false;
      }
    }

    initialized = init();
    return await initialized!;
  }

  Future<void> tryLogin(String username, String password) async {
    await dio.get(
      'favorites.json',
      options: Options(headers: {
        HttpHeaders.authorizationHeader:
            Credentials(username: username, password: password).toAuth(),
      }),
    );
  }

  Future<bool> saveLogin(String username, String password) async {
    if (await validateCall(() => tryLogin(username, password))) {
      settings.credentials.value =
          Credentials(username: username, password: password);
      return true;
    } else {
      return false;
    }
  }

  bool get hasLogin => (settings.credentials.value != null);

  Future<bool> get isLoggedIn async {
    await initialized;
    return hasLogin;
  }

  Future<void> logout() async {
    settings.credentials.value = null;
  }

  Mutex userInitLock = Mutex();

  Future<void> initializeCurrentUser({bool reset = false}) async {
    await userInitLock.acquire();
    if (reset) {
      _currentUser = null;
      _currentAvatar = null;
    }
    if (!await isLoggedIn) {
      userInitLock.release();
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
    userInitLock.release();
  }

  CurrentUser? _currentUser;

  Future<CurrentUser?> get currentUser async {
    await initializeCurrentUser();
    return _currentUser;
  }

  Post? _currentAvatar;

  Future<Post?> get currentAvatar async {
    await initializeCurrentUser();
    return _currentAvatar;
  }

  Future<List<Post>> postsFromJson(List<dynamic> json) async {
    List<Post> posts = [];
    for (Map<String, dynamic> raw in json) {
      Post post = Post.fromMap(raw);
      if (post.file.url == null && !post.flags.deleted) {
        continue;
      }
      if (post.file.ext == 'swf') {
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
      username = settings.credentials.value?.username;
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
    List<String> tags = List<Follow>.from(settings.follows.value)
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
    post.isBlacklisted = post.isDeniedBy(settings.denylist.value);
    return post;
  }

  Future<void> updatePost(Post update, Post old, {String? editReason}) async {
    if (!await isLoggedIn) {
      return;
    }
    Map<String, String?> body = {};

    List<String> tags(Post post) {
      List<String> tags = [];
      post.tags.forEach((key, value) {
        tags.addAll(List<String>.from(value));
      });
      return tags;
    }

    List<String> oldTags = tags(old);
    List<String> newTags = tags(update);
    List<String> removedTags =
        oldTags.where((element) => !newTags.contains(element)).toList();
    removedTags = removedTags.map((t) => '-$t').toList();
    List<String> addedTags =
        newTags.where((element) => !oldTags.contains(element)).toList();
    List<String> tagDiff = [];
    tagDiff.addAll(removedTags);
    tagDiff.addAll(addedTags);

    if (tagDiff.isNotEmpty) {
      body.addEntries([
        MapEntry(
          'post[tag_string_diff]',
          tagDiff.join(' '),
        ),
      ]);
    }

    List<String> removedSource = old.sources
        .where((element) => !update.sources.contains(element))
        .toList();
    removedSource = removedSource.map((s) => '-$s').toList();
    List<String> addedSource = update.sources
        .where((element) => !old.sources.contains(element))
        .toList();
    List<String> sourceDiff = [];
    sourceDiff.addAll(removedSource);
    sourceDiff.addAll(addedSource);

    if (sourceDiff.isNotEmpty) {
      body.addEntries([
        MapEntry(
          'post[source_diff]',
          sourceDiff.join(' '),
        ),
      ]);
    }

    if (old.relationships.parentId != update.relationships.parentId) {
      body.addEntries([
        MapEntry(
          'post[parent_id]',
          update.relationships.parentId?.toString() ?? '',
        ),
      ]);
    }

    if (old.description != update.description) {
      body.addEntries([
        MapEntry(
          'post[description]',
          update.description,
        ),
      ]);
    }

    if (old.rating != update.rating) {
      body.addEntries([
        MapEntry(
          'post[rating]',
          ratingValues.reverse![update.rating],
        ),
      ]);
    }

    if (body.isNotEmpty) {
      if (editReason!.trim().isNotEmpty) {
        body.addEntries([
          MapEntry(
            'post[edit_reason]',
            editReason.trim(),
          ),
        ]);
      }

      await dio.clearCacheKey(
        'posts/${update.id}.json',
        cacheManager,
      );

      await dio.put('posts/${update.id}.json', data: FormData.fromMap(body));
    }
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
        .get('users/${settings.credentials.value!.username}.json')
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

    await dio.put('users/${settings.credentials.value!.username}.json',
        data: FormData.fromMap(body));

    initializeCurrentUser(reset: true);
  }

  Future<List> tag(String search, {int? category, bool? force}) async {
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
    List tags = [];
    if (body is List) {
      tags = body;
    }
    return tags;
  }

  Future<List> autocomplete(String search, {int? category, bool? force}) async {
    await initialized;
    if (category == null) {
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
      List tags = [];
      if (body is List) {
        tags = body;
      }
      tags = tags.take(3).toList();
      return tags;
    } else {
      return tag(search + '*', category: category, force: force);
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
