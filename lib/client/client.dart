import 'dart:async' show Future;
import 'dart:convert' show base64Encode, json, utf8;
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e1547/comment.dart';
import 'package:e1547/follow.dart';
import 'package:e1547/pool.dart';
import 'package:e1547/post.dart';
import 'package:e1547/settings.dart';
import 'package:e1547/tag.dart';
import 'package:e1547/wiki.dart';

export 'package:dio/dio.dart' show DioError;

final Client client = Client();

class Client {
  late Dio dio;

  Future<bool>? initialized;

  Future<String> host = settings.host.value;
  Future<List<String>> denylist = settings.denylist.value;
  Future<List<Follow>> following = settings.follows.value;
  Future<Credentials?> credentials = settings.credentials.value;

  Client() {
    settings.host.addListener(() => host = settings.host.value);
    settings.credentials
        .addListener(() => credentials = settings.credentials.value);
    settings.denylist.addListener(() => denylist = settings.denylist.value);
    settings.follows.addListener(() => following = settings.follows.value);

    settings.host.addListener(initialize);
    settings.credentials.addListener(initialize);
    initialize();
  }

  Future<bool> get isSafe async =>
      (await settings.host.value) != (await settings.customHost.value);

  Future<bool> initialize() async {
    Future<bool> init() async {
      Credentials? credentials = await settings.credentials.value;
      dio = Dio(
        BaseOptions(
          baseUrl: 'https://${await host}/',
          sendTimeout: 30000,
          connectTimeout: 30000,
          headers: {
            HttpHeaders.userAgentHeader: '$appName/$appVersion ($developer)',
          },
        ),
      );
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
        _avatar = null;
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
          Future.value(Credentials(username: username, password: password));
      return true;
    } else {
      return false;
    }
  }

  Future<bool> get hasLogin async {
    await initialized;
    return (await credentials != null);
  }

  Future<void> logout() async {
    settings.credentials.value = Future.value(null);
  }

  String? _avatar;

  Future<String?> get avatar async {
    if (_avatar == null) {
      int? postId =
          (await client.user((await credentials)!.username))['avatar_id'];
      if (postId != null) {
        Post post = await client.post(postId);
        _avatar = post.sample.url;
      }
    }
    return _avatar;
  }

  Future<List<Post>?> postsFromJson(List json) async {
    List<Post> posts = [];
    bool loggedIn = await this.hasLogin;
    bool hasPosts = false;
    for (Map raw in json) {
      hasPosts = true;
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
    if (hasPosts && posts.isEmpty) {
      return null;
    }
    return posts;
  }

  Future<List<Post>> posts(String? tags, int page,
      {int? limit, bool faithful = false, int attempt = 0}) async {
    await initialized;

    Future<List<Post>> getPosts() async {
      Map body = await dio.get(
        'posts.json',
        queryParameters: {
          'tags': sortTags(tags!),
          'page': page,
          'limit': limit,
        },
      ).then((response) => response.data);

      List<Post>? posts = await postsFromJson(body['posts']);

      if (posts == null) {
        if (attempt < 3) {
          return client.posts(tags, page + 1,
              faithful: faithful, attempt: attempt + 1);
        } else {
          posts = [];
        }
      }
      return posts;
    }

    if (faithful) {
      return getPosts();
    } else {
      // String username = (await credentials).username;

      Map<RegExp,
              Future<List<Post>> Function(RegExpMatch match, String? result)>
          regexes = {
        RegExp(r'^pool:(?<id>\d+)$'): (match, result) =>
            poolPosts(int.tryParse(match.namedGroup('id')!)!, page),
        /*
        if (username != null)
          RegExp(r'^fav:' + username + r'$'): (match, result) =>
              favorites(page, limit: limit),
         */
      };

      for (MapEntry<RegExp, Function(RegExpMatch match, String? result)> entry
          in regexes.entries) {
        RegExpMatch? match = entry.key.firstMatch(tags!.trim());
        if (match != null) {
          return entry.value(match, tags);
        }
      }

      return getPosts();
    }
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

    return (await (postsFromJson(body['posts']))) ?? [];
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

  Future<List<Pool>> pools(String title, int page) async {
    List body = await dio.get('pools.json', queryParameters: {
      'search[name_matches]': title,
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

  Future<List<Post>> poolPosts(int poolId, int page) async {
    Pool pool = await client.pool(poolId);
    int limit = 80;
    int lower = ((page - 1) * limit);
    int upper = lower + limit;

    if (pool.postIds.length < lower) {
      return [];
    }
    if (pool.postIds.length < upper) {
      upper = pool.postIds.length;
    }

    List<int> ids = pool.postIds.sublist(lower, upper);
    String filter = 'id:${ids.join(',')}';

    List<Post> posts = await client.posts(filter, 1);
    Map<int, Post> table =
        Map.fromIterable(posts, key: (e) => e.id, value: (e) => e);
    posts = (ids.map((e) => table[e]).toList()..removeWhere((e) => e == null))
        .cast<Post>();
    return posts;
  }

  Future<List<Post>> follows(int page, {int attempt = 0}) async {
    List<Post> posts = [];
    List<String> tags =
        List<Follow>.from(await following).map<String>((e) => e.tags).toList();
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
      posts.addAll(await client.posts('~${tagSet.join(' ~')}', getSitePage(i)));
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
            'https://${(unsafe ? await settings.customHost.value : await host)}/posts/${postId.toString()}.json',
            options: Options())
        .then((response) => response.data);

    Post post = Post.fromMap(body['post']);
    post.isLoggedIn = await hasLogin;
    post.isBlacklisted = await post.isDeniedBy(await settings.denylist.value);
    return post;
  }

  Future<void> updatePost(Post update, Post old, {String? editReason}) async {
    if (!await hasLogin) {
      return null;
    }
    Map<String, String?> body = {};

    List<String> tags(Post post) {
      List<String> tags = [];
      post.tagMap.forEach((key, value) {
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

  Future<List<Wiki>> wiki(String search, int page) async {
    List body = await dio.get('wiki_pages.json', queryParameters: {
      'search[title]': search,
      'page': page,
    }).then((response) => response.data);

    return body.map((entry) => Wiki.fromMap(entry)).toList();
  }

  Future<Map> user(String name) async {
    await initialized;
    Map body =
        await dio.get('users/$name.json').then((response) => response.data);

    return body;
  }

  Future<List> tag(String search, {int? category}) async {
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

  Future<void> postComment(String text, Post post, {Comment? comment}) async {
    if (!await hasLogin) {
      return null;
    }
    Map<String, String> body = {
      'comment[body]': text,
      'comment[post_id]': post.id.toString(),
      'commit': 'Submit',
    };
    Future request;
    if (comment != null) {
      request = dio.patch('comments/${comment.id}.json', data: body);
    } else {
      request = dio.post('comments.json', data: body);
    }
    await request;
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

Future<bool> validateCall(Future<dynamic> Function() call) async {
  try {
    await call();
    return true;
  } on DioError {
    return false;
  }
}
