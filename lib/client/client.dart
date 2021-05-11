import 'dart:async' show Future;
import 'dart:convert' show base64Encode, json, utf8;
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e1547/comment.dart';
import 'package:e1547/follow.dart';
import 'package:e1547/pool.dart';
import 'package:e1547/post.dart';
import 'package:e1547/settings.dart';
import 'package:e1547/thread.dart';
import 'package:e1547/wiki.dart';
import 'package:meta/meta.dart';

export 'package:dio/dio.dart' show DioError;

final Client client = Client();

class Client {
  Dio dio;

  Future<bool> initialized;

  Future<String> host = db.host.value;
  Future<List<String>> denylist = db.denylist.value;
  Future<FollowList> following = db.follows.value;
  Future<Credentials> credentials = db.credentials.value;

  Client() {
    db.host.addListener(() => host = db.host.value);
    db.credentials.addListener(() => credentials = db.credentials.value);
    db.denylist.addListener(() => denylist = db.denylist.value);
    db.follows.addListener(() => following = db.follows.value);

    db.host.addListener(initialize);
    db.credentials.addListener(initialize);
    initialize();
  }

  Future<bool> initialize() async {
    Future<bool> init() async {
      Credentials credentials = await db.credentials.value;
      dio = Dio(
        BaseOptions(
          baseUrl: 'https://${await host}/',
          sendTimeout: 30000,
          connectTimeout: 30000,
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
    return await initialized;
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
      db.credentials.value =
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
    db.credentials.value = Future.value(null);
  }

  String _avatar;

  Future<String> get avatar async {
    if (_avatar == null) {
      int postID =
          (await client.user((await credentials).username))['avatar_id'];
      Post post = await client.post(postID);
      _avatar = post.sample.value.url;
    }
    return _avatar;
  }

  Future<List<Post>> posts(String tags, int page,
      {int limit, bool faithful = false, int attempt = 0}) async {
    await initialized;

    Future<List<Post>> getPosts() async {
      Map body = await dio.get(
        'posts.json',
        queryParameters: {
          'tags': sortTags(tags),
          'page': page,
          'limit': limit,
        },
      ).then((response) => response.data);

      List<Post> posts = [];
      bool loggedIn = await this.hasLogin;
      bool hasPosts = false;
      for (Map raw in body['posts']) {
        hasPosts = true;
        Post post = Post.fromMap(raw);
        post.isLoggedIn = loggedIn;
        if (post.file.value.url == null && !post.isDeleted) {
          continue;
        }
        if (post.file.value.ext == 'swf') {
          continue;
        }
        posts.add(post);
      }
      if (hasPosts && posts.isEmpty && attempt < 3) {
        return client.posts(tags, page + 1,
            faithful: faithful, attempt: attempt + 1);
      }
      return posts;
    }

    if (faithful) {
      return getPosts();
    } else {
      RegExpMatch match = RegExp(r'^pool:(?<id>\d+)$').firstMatch(tags);
      if (match != null) {
        return poolPosts(int.tryParse(match.namedGroup('id')), page);
      }
      return getPosts();
    }
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
    for (Map rawPool in body) {
      Pool pool = Pool.fromRaw(rawPool);
      pools.add(pool);
    }

    return pools;
  }

  Future<Pool> pool(int poolId) async {
    Map body =
        await dio.get('pools/$poolId.json').then((response) => response.data);

    return Pool.fromRaw(body);
  }

  Future<List<Post>> poolPosts(int poolId, int page) async {
    return client.posts('pool:$poolId order:id', page, faithful: true);
  }

  Future<List<Post>> follows(int page, {int attempt = 0}) async {
    List<Post> posts = [];
    List<String> tags = List.from(await following);
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
      List<String> tagSet = tags.sublist((tagPage - 1) * max, end);
      posts.addAll(await client.posts('~${tagSet.join(' ~')}', getSitePage(i)));
    }
    posts.sort((one, two) => two.id.compareTo(one.id));
    if (posts.isEmpty && attempt < (approx / batches) - 1) {
      posts.addAll(await follows(page + 1, attempt: attempt + 1));
    }
    return posts;
  }

  Future<Post> post(int postID, {bool unsafe = false}) async {
    await initialized;
    Map body = await dio
        .get(
            'https://${(unsafe ? await db.customHost.value : await host)}/posts/${postID.toString()}.json',
            options: Options())
        .then((response) => response.data);

    Post post = Post.fromMap(body['post']);
    post.isLoggedIn = await hasLogin;
    post.isBlacklisted = await post.isDeniedBy(await db.denylist.value);
    return post;
  }

  Future<void> updatePost(Post update, Post old, {String editReason}) async {
    if (!await hasLogin) {
      return null;
    }
    Map<String, String> body = {};

    List<String> tags(Post post) {
      List<String> _tags = [];
      post.tags.value.forEach((key, value) {
        _tags.addAll(List<String>.from(value));
      });
      return _tags;
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

    List<String> removedSource = old.sources.value
        .where((element) => !update.sources.value.contains(element))
        .toList();
    removedSource = removedSource.map((s) => '-$s').toList();
    List<String> addedSource = update.sources.value
        .where((element) => !old.sources.value.contains(element))
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

    if (old.parent.value != update.parent.value) {
      body.addEntries([
        MapEntry(
          'post[parent_id]',
          update.parent.value?.toString() ?? '',
        ),
      ]);
    }

    if (old.description.value != update.description.value) {
      body.addEntries([
        MapEntry(
          'post[description]',
          update.description.value,
        ),
      ]);
    }

    if (old.rating.value != update.rating.value) {
      body.addEntries([
        MapEntry(
          'post[rating]',
          update.rating.value.toLowerCase(),
        ),
      ]);
    }

    if (body.isNotEmpty) {
      if (editReason.trim().isNotEmpty) {
        body.addEntries([
          MapEntry(
            'post[edit_reason]',
            editReason.trim(),
          ),
        ]);
      }

      await dio.patch('posts/${update.id}.json', data: body);
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

  Future<List> autocomplete(String search, {int category}) async {
    var body;
    if (category == null) {
      body = await dio.get('tags/autocomplete.json', queryParameters: {
        'search[name_matches]': search,
      }).then((response) => response.data);
    } else {
      body = await dio.get('tags.json', queryParameters: {
        'search[name_matches]': search + '*',
        'search[category]': category,
        'search[order]': 'count',
        'limit': 3,
      }).then((response) => response.data);
    }
    List tags = [];
    if (body is List) {
      tags = body;
    }
    tags = tags.take(3).toList();
    return tags;
  }

  Future<List<Comment>> comments(int postID, String page) async {
    var body = await dio.get('comments.json', queryParameters: {
      'group_by': 'comment',
      'search[post_id]': '$postID',
      'page': page,
    }).then((response) => response.data);

    List<Comment> comments = [];
    if (body is List) {
      for (Map rawComment in body) {
        comments.add(Comment.fromRaw(rawComment));
      }
    }

    return comments;
  }

  Future<Map> postComment(String text, Post post, {Comment comment}) async {
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
    Map response = await request.then((response) {
      return {'code': response.statusCode, 'reason': response.reasonPhrase};
    });
    return response;
  }

  Future<List<Thread>> threads(int page) async {
    var body = await dio.get('forum_topics.json', queryParameters: {
      'page': page,
    }).then((response) => response.data);

    List<Thread> threads = [];
    if (body is List) {
      for (Map thread in body) {
        threads.add(Thread.fromRaw(thread));
      }
    }

    return threads;
  }

  Future<Thread> thread(int id) async {
    var body = await dio
        .get('forum_topics/$id.json')
        .then((response) => response.data);

    Thread thread;
    if (body is Map) {
      thread = Thread.fromRaw(body);
    }

    return thread;
  }

  Future<List<Reply>> replies(Thread thread, String page) async {
    var body = await dio.get('forum_posts.json', queryParameters: {
      'commit': 'Search',
      'search[topic_title_matches]': thread.title,
      'page': page,
    }).then((response) => response.data);

    List<Reply> replies = [];
    if (body is List) {
      for (Map reply in body) {
        replies.add(Reply.fromRaw(reply));
      }
    }

    return replies;
  }
}

class Credentials {
  Credentials({
    @required this.username,
    @required this.password,
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

Future<bool> validateCall(Future Function() call) async {
  try {
    await call();
    return true;
  } on DioError {
    return false;
  }
}
