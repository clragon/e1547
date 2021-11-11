import 'dart:async' show Future;
import 'dart:convert' show base64Encode, json, utf8;
import 'dart:io';

import 'package:dio/dio.dart';
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

  Future<bool>? initialized;

  Client() {
    settings.host.addListener(initialize);
    settings.credentials.addListener(initialize);
    initialize();
  }

  bool get isSafe => settings.host.value != settings.customHost.value;

  Future<bool> initialize() async {
    Future<bool> init() async {
      Credentials? credentials = settings.credentials.value;
      dio = Dio(
        defaultDioOptions.copyWith(
          baseUrl: 'https://${settings.host.value}/',
          headers: {
            HttpHeaders.userAgentHeader:
                '${appInfo.appName}/${appInfo.version} (${appInfo.developer})',
          },
        ),
      );
      initializeCurrentUser(reset: true);
      if (credentials != null &&
          !dio.options.headers.containsKey(HttpHeaders.authorizationHeader)) {
        dio.options.headers.addEntries(
            [MapEntry(HttpHeaders.authorizationHeader, credentials.toAuth())]);
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

  Future<bool> get hasLogin async {
    await initialized;
    return (settings.credentials.value != null);
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
    if (!await hasLogin) {
      userInitLock.release();
      return;
    }
    if (_currentUser == null) {
      _currentUser = await client.authedUser();
      List<String> updated = _currentUser!.blacklistedTags.split('\n');
      updated = updated.trim();
      updated.removeWhere((element) => element.isEmpty);
      settings.denylist.value = updated;
    }
    if (_currentAvatar == null) {
      int? avatarId = _currentUser?.avatarId;
      if (avatarId != null) {
        Post post = await client.post(avatarId);
        _currentAvatar = post.sample.url;
      }
    }
    userInitLock.release();
  }

  CurrentUser? _currentUser;

  Future<CurrentUser?> get currentUser async {
    await initializeCurrentUser();
    return _currentUser;
  }

  String? _currentAvatar;

  Future<String?> get currentAvatar async {
    await initializeCurrentUser();
    return _currentAvatar;
  }

  Future<List<Post>> postsFromJson(List json) async {
    List<Post> posts = [];
    bool loggedIn = await hasLogin;
    for (Map raw in json) {
      Post post = Post.fromMap(raw);
      post.isLoggedIn = loggedIn;
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

  Future<List<Post>> postsRaw(int page, {String? search, int? limit}) async {
    await initialized;
    Map body = await dio.get(
      'posts.json',
      queryParameters: {
        'tags': sortTags(search!),
        'page': page,
        'limit': limit,
      },
    ).then((response) => response.data);

    return postsFromJson(body['posts']);
  }

  Future<List<Post>> posts(
    int page, {
    String? search,
    int? limit,
    bool? reversePools,
    bool? orderFavorites,
  }) async {
    await initialized;
    String? username;

    if (orderFavorites ?? false) {
      username = settings.credentials.value?.username;
    }

    Map<RegExp, Future<List<Post>> Function(RegExpMatch match, String? result)>
        regexes = {
      poolRegex(): (match, result) => poolPosts(
          int.parse(match.namedGroup('id')!), page,
          reverse: reversePools),
      if (username != null)
        favRegex(username): (match, result) => favorites(page, limit: limit),
    };

    for (MapEntry<
        RegExp,
        Future<List<Post>> Function(
            RegExpMatch match, String? result)> entry in regexes.entries) {
      RegExpMatch? match = entry.key.firstMatch(search!.trim());
      if (match != null) {
        return entry.value(match, search);
      }
    }

    return postsRaw(page, search: search, limit: limit);
  }

  Future<List<Post>> favorites(int page, {int? limit}) async {
    await initialized;

    Map body = await dio.get(
      'favorites.json',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    ).then((response) => response.data);

    return (postsFromJson(body['posts']));
  }

  Future<bool> addFavorite(int post) async {
    if (!await hasLogin) {
      return false;
    }
    return validateCall(
      () => dio.post('favorites.json', queryParameters: {
        'post_id': post,
      }),
    );
  }

  Future<bool> removeFavorite(int post) async {
    if (!await hasLogin) {
      return false;
    }

    return validateCall(
      () => dio.delete('favorites/${post.toString()}.json'),
    );
  }

  Future<bool> votePost(int post, bool upvote, bool replace) async {
    if (!await hasLogin) {
      return false;
    }

    return validateCall(
      () => dio.post('posts/${post.toString()}/votes.json', queryParameters: {
        'score': upvote ? 1 : -1,
        'no_unvote': replace,
      }),
    );
  }

  Future<List<Pool>> pools(int page, {String? search}) async {
    List body = await dio.get('pools.json', queryParameters: {
      'search[name_matches]': search,
      'page': page,
    }).then((response) => response.data);

    List<Pool> pools = [];
    for (Map<String, dynamic> rawPool in body) {
      Pool pool = Pool.fromMap(rawPool);
      pools.add(pool);
    }

    return pools;
  }

  Future<Pool> pool(int poolId) async {
    Map<String, dynamic> body =
        await dio.get('pools/$poolId.json').then((response) => response.data);

    return Pool.fromMap(body);
  }

  Future<List<Post>> poolPosts(int poolId, int page, {bool? reverse}) async {
    Pool pool = await client.pool(poolId);
    List<int> ids =
        reverse ?? false ? pool.postIds.reversed.toList() : pool.postIds;
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

    List<Post> posts = await client.posts(1, search: filter);
    Map<int, Post> table = {for (Post e in posts) e.id: e};
    posts = (pageIds.map((e) => table[e]).toList()
          ..removeWhere((e) => e == null))
        .cast<Post>();
    return posts;
  }

  Future<List<Post>> follows(int page, {int attempt = 0}) async {
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
      posts.addAll(
          await client.posts(getSitePage(i), search: '~${tagSet.join(' ~')}'));
    }
    posts.sort((one, two) => two.id.compareTo(one.id));
    if (posts.isEmpty && attempt < (approx / batches) - 1) {
      posts.addAll(await follows(page + 1, attempt: attempt + 1));
    }
    return posts;
  }

  Future<Post> post(int postId, {bool unsafe = false}) async {
    await initialized;
    Map body = await dio
        .get(
            'https://${(unsafe ? settings.customHost.value : settings.host.value)}/posts/${postId.toString()}.json',
            options: Options())
        .then((response) => response.data);

    Post post = Post.fromMap(body['post']);
    post.isLoggedIn = await hasLogin;
    post.isBlacklisted = post.isDeniedBy(settings.denylist.value);
    return post;
  }

  Future<void> updatePost(Post update, Post old, {String? editReason}) async {
    if (!await hasLogin) {
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

      await dio.put('posts/${update.id}.json', data: FormData.fromMap(body));
    }
  }

  Future<void> reportPost(int postId, int reportReason, String reason) async {
    await initialized;
    await dio.post('tickets', queryParameters: {
      'ticket[reason]': reason,
      'ticket[report_reason]': reportReason,
      'ticket[disp_id]': postId,
      'ticket[qtype]': 'post',
    });
  }

  Future<List<Wiki>> wiki(int page, {String? search}) async {
    await initialized;
    List body = await dio.get('wiki_pages.json', queryParameters: {
      'search[title]': search,
      'page': page,
    }).then((response) => response.data);

    return body.map((entry) => Wiki.fromMap(entry)).toList();
  }

  Future<User> user(String name) async {
    await initialized;
    Map<String, dynamic> body =
        await dio.get('users/$name.json').then((response) => response.data);

    return User.fromMap(body);
  }

  Future<CurrentUser?> authedUser() async {
    if (!await hasLogin) {
      return null;
    }

    Map<String, dynamic> body = await dio
        .get('users/${settings.credentials.value!.username}.json')
        .then((response) => response.data);

    return CurrentUser.fromMap(body);
  }

  Future<void> updateBlacklist(List<String> denylist) async {
    if (!await hasLogin) {
      return;
    }

    Map<String, String?> body = {
      'user[blacklisted_tags]': denylist.join('\n'),
    };

    await dio.put('users/${settings.credentials.value!.username}.json',
        data: FormData.fromMap(body));

    initializeCurrentUser(reset: true);
  }

  Future<List> tag(String search, {int? category}) async {
    await initialized;
    var body = await dio.get('tags.json', queryParameters: {
      'search[name_matches]': search,
      'search[category]': category,
      'search[order]': 'count',
      'limit': 3,
    }).then((response) => response.data);
    List tags = [];
    if (body is List) {
      tags = body;
    }
    tags = tags.take(3).toList();
    return tags;
  }

  Future<List> autocomplete(String search, {int? category}) async {
    await initialized;
    if (category == null) {
      var body = await dio.get('tags/autocomplete.json', queryParameters: {
        'search[name_matches]': search,
      }).then((response) => response.data);
      List tags = [];
      if (body is List) {
        tags = body;
      }
      tags = tags.take(3).toList();
      return tags;
    } else {
      return tag(search + '*', category: category);
    }
  }

  Future<List<Comment>> comments(int postId, String page) async {
    await initialized;
    var body = await dio.get('comments.json', queryParameters: {
      'group_by': 'comment',
      'search[post_id]': '$postId',
      'page': page,
    }).then((response) => response.data);

    List<Comment> comments = [];
    if (body is List) {
      for (Map<String, dynamic> rawComment in body) {
        comments.add(Comment.fromMap(rawComment));
      }
    }

    return comments;
  }

  Future<Comment> comment(int id) async {
    Map<String, dynamic> body = await dio
        .get('comments.json/$id.json')
        .then((response) => response.data);

    return Comment.fromMap(body);
  }

  Future<bool> voteComment(int comment, bool upvote, bool replace) async {
    if (!await hasLogin) {
      return false;
    }

    return validateCall(
      () => dio
          .post('comments/${comment.toString()}/votes.json', queryParameters: {
        'score': upvote ? 1 : -1,
        'no_unvote': replace,
      }),
    );
  }

  Future<void> postComment(Post post, String text, {Comment? comment}) async {
    if (!await hasLogin) {
      return;
    }
    Map<String, String> body = {
      'comment[body]': text,
      'comment[post_id]': post.id.toString(),
      'commit': 'Submit',
    };
    Future request;
    if (comment != null) {
      request = dio.patch('comments/${comment.id}.json',
          data: FormData.fromMap(body));
    } else {
      request = dio.post('comments.json', data: FormData.fromMap(body));
    }
    await request;
  }

  Future<List<Topic>> topics(int page, {String? search}) async {
    var body = await dio.get('forum_topics.json', queryParameters: {
      'page': page,
      'search[title_matches]': search?.isNotEmpty ?? false ? search : null,
    }).then((response) => response.data);

    List<Topic> threads = [];
    if (body is List) {
      for (Map<String, dynamic> raw in body) {
        threads.add(Topic.fromMap(raw));
      }
    }

    return threads;
  }

  Future<Topic> topic(int id) async {
    Map<String, dynamic> body = await dio
        .get('forum_topics/$id.json')
        .then((response) => response.data);

    return Topic.fromMap(body);
  }

  Future<List<Reply>> replies(int id, String page) async {
    var body = await dio.get('forum_posts.json', queryParameters: {
      'commit': 'Search',
      'search[topic_id]': id,
      'page': page,
    }).then((response) => response.data);

    List<Reply> replies = [];
    if (body is List) {
      for (Map<String, dynamic> raw in body) {
        replies.add(Reply.fromMap(raw));
      }
    }

    return replies;
  }

  Future<Reply> reply(int id) async {
    Map<String, dynamic> body =
        await dio.get('forum_posts/$id.json').then((response) => response.data);

    return Reply.fromMap(body);
  }
}

class Credentials {
  Credentials({
    required this.username,
    required this.password,
  });

  final String username;
  final String password;

  factory Credentials.fromJson(String str) =>
      Credentials.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Credentials.fromMap(Map<String, dynamic> json) => Credentials(
        username: json["username"],
        password: json["apikey"],
      );

  Map<String, dynamic> toMap() => {
        "username": username,
        "apikey": password,
      };

  String toAuth() {
    String auth = base64Encode(utf8.encode('$username:$password'));
    return 'Basic $auth';
  }
}

Future<bool> validateCall(Future<void> Function() call) async {
  try {
    await call();
    return true;
  } on DioError {
    return false;
  }
}
