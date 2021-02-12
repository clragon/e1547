import 'dart:async' show Future;
import 'dart:convert' show json;
import 'dart:io';

import 'package:e1547/comment.dart';
import 'package:e1547/pool.dart';
import 'package:e1547/post.dart';
import 'package:e1547/settings.dart';
import 'package:e1547/thread.dart';

import 'http.dart';

final Client client = Client();

class Client {
  Future<bool> initialized;

  HttpHelper http = HttpHelper();

  Future<String> host = db.host.value;
  Future<List<String>> denylist = db.denylist.value;
  Future<List<String>> following = db.follows.value;
  Future<Credentials> credentials = db.credentials.value;

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

  Client() {
    db.host.addListener(() => host = db.host.value);
    db.credentials.addListener(() => credentials = db.credentials.value);
    db.denylist.addListener(() => denylist = db.denylist.value);
    db.follows.addListener(() => following = db.follows.value);

    db.credentials.addListener(login);
    login();
  }

  Future<bool> login() async {
    initialized = () async {
      Credentials credentials = await db.credentials.value;
      if (credentials != null) {
        http = HttpHelper(credentials: credentials);
        tryLogin(credentials.username, credentials.apikey).then((authed) {
          if (!authed) {
            logout();
          }
        });
        return true;
      } else {
        return false;
      }
    }();
    return await initialized;
  }

  Future<bool> tryLogin(String username, String apiKey) async {
    return await http.get(await host, '/favorites.json', query: {
      'login': username,
      'api_key': apiKey,
    }).then((response) {
      return response.statusCode == 200;
    });
  }

  Future<bool> saveLogin(String username, String apikey) async {
    if (await tryLogin(username, apikey)) {
      db.credentials.value =
          Future.value(Credentials(username: username, apikey: apikey));
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
    _avatar = null;
    http = HttpHelper();
  }

  Future<List<Post>> posts(String tags, int page, {int attempt = 0}) async {
    await initialized;
    try {
      String body = await http.get(await host, '/posts.json', query: {
        'tags': sortTags(tags),
        'page': page,
      }).then((response) => response.body);

      List<Post> posts = [];
      bool loggedIn = await this.hasLogin;
      bool hasPosts = false;
      for (Map raw in json.decode(body)['posts']) {
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
      if (hasPosts && posts.length == 0 && attempt < 3) {
        return client.posts(tags, page + 1, attempt: attempt + 1);
      }
      return posts;
    } on SocketException {
      return [];
    }
  }

  Future<bool> addFavorite(int post) async {
    if (!await hasLogin) {
      return false;
    }

    return await http.post(await host, '/favorites.json', query: {
      'post_id': post,
    }).then((response) => response.statusCode == 201);
  }

  Future<bool> removeFavorite(int post) async {
    if (!await hasLogin) {
      return false;
    }

    return await http
        .delete(await host, '/favorites/${post.toString()}.json')
        .then((response) {
      return response.statusCode == 204;
    });
  }

  Future<bool> votePost(int post, bool upvote, bool replace) async {
    if (!await hasLogin) {
      return false;
    }

    return await http
        .post(await host, '/posts/' + post.toString() + '/votes.json', query: {
      'score': upvote ? 1 : -1,
      'no_unvote': replace,
    }).then((response) {
      return response.statusCode == 200;
    });
  }

  Future<List<Pool>> pools(String title, int page) async {
    try {
      String body = await http.get(await host, '/pools.json', query: {
        'search[name_matches]': title,
        'page': page,
      }).then((response) => response.body);

      List<Pool> pools = [];
      for (Map rawPool in json.decode(body)) {
        Pool pool = Pool.fromRaw(rawPool);
        pools.add(pool);
      }

      return pools;
    } on SocketException {
      return [];
    }
  }

  Future<Pool> pool(int poolID) async {
    try {
      String body = await http
          .get(await host, '/pools/${poolID.toString()}.json')
          .then((response) => response.body);

      return Pool.fromRaw(json.decode(body));
    } on SocketException {
      return null;
    }
  }

  Future<List<Post>> follows(int page) async {
    List<Post> posts = [];
    List<String> tags = List.from(await following);
    // remove pools, they cannot be used with the ~ operator.
    tags.removeWhere((tag) => tag.startsWith('pool:'));
    int length = tags.length;
    int max = 40;
    double approx = length / max;
    if (approx % 1 != 0) {
      approx += 1;
    }
    if (approx != 0) {
      max = length ~/ approx.toInt();
    }
    for (int i = 0; i < length; i += max) {
      int end = (length > i + max) ? i + max : length;
      List<String> tagSet = tags.sublist(i, end);
      posts.addAll(await client.posts('~${tagSet.join(' ~')}', page));
    }
    posts.sort((one, two) => two.id.compareTo(one.id));
    return posts;
  }

  Future<Post> post(int postID, {bool unsafe = false}) async {
    await initialized;
    try {
      String body = await http
          .get((unsafe ? await db.customHost.value : await host),
              '/posts/${postID.toString()}.json')
          .then((response) => response.body);

      Post post = Post.fromMap(json.decode(body)['post']);
      post.isLoggedIn = await hasLogin;
      post.isBlacklisted = await post.isDeniedBy(await db.denylist.value);
      return post;
    } on SocketException {
      return null;
    }
  }

  Future<Map> updatePost(Post update, Post old, {String editReason}) async {
    await initialized;
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

    if (tagDiff.length != 0) {
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

    if (sourceDiff.length != 0) {
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

    if (body.length > 0) {
      if (editReason.trim().isNotEmpty) {
        body.addEntries([
          MapEntry(
            'post[edit_reason]',
            editReason.trim(),
          ),
        ]);
      }

      Map response = await http
          .patch(await host, '/posts/${update.id}.json', body: body)
          .then((response) =>
              {'code': response.statusCode, 'reason': response.reasonPhrase});
      return response;
    }
    return null;
  }

  Future<List> wiki(String search, int page) async {
    try {
      String body = await http.get(await host, 'wiki_pages.json', query: {
        'search[title]': search,
        'page': page,
      }).then((response) => response.body);

      return json.decode(body);
    } on SocketException {
      return null;
    }
  }

  Future<Map> user(String name) async {
    try {
      await initialized;
      String body = await http
          .get(await host, '/users/$name.json')
          .then((response) => response.body);

      return json.decode(body);
    } on SocketException {
      return null;
    }
  }

  Future<List> autocomplete(String search, {int category}) async {
    String body;
    if (category == null) {
      body = await http.get(await host, '/tags/autocomplete.json', query: {
        'search[name_matches]': search,
      }).then((response) => response.body);
    } else {
      body = await http.get(await host, '/tags.json', query: {
        'search[name_matches]': search + '*',
        'search[category]': category,
        'search[order]': 'count',
        'limit': 3,
      }).then((response) => response.body);
    }
    List tags = [];
    var tagList = json.decode(body);
    if (tagList is List) {
      tags = tagList;
    }
    tags = tags.take(3).toList();
    return tags;
  }

  Future<List<Comment>> comments(int postID, String page) async {
    try {
      String body = await http.get(await host, '/comments.json', query: {
        'group_by': 'comment',
        'search[post_id]': '$postID',
        'page': page,
      }).then((response) => response.body);

      List<Comment> comments = [];
      var commentList = json.decode(body);
      if (commentList is List) {
        for (Map rawComment in commentList) {
          comments.add(Comment.fromRaw(rawComment));
        }
      }

      return comments;
    } on SocketException {
      return [];
    }
  }

  Future<Map> postComment(String text, Post post, {Comment comment}) async {
    await initialized;
    if (!await hasLogin) {
      return null;
    }
    Map<String, String> query = {};
    Map<String, String> body = {
      'comment[body]': text,
      'comment[post_id]': post.id.toString(),
      'commit': 'Submit',
    };
    Future request;
    if (comment != null) {
      request = http.patch(await host, '/comments/${comment.id}.json',
          query: query, body: body);
    } else {
      request =
          http.post(await host, '/comments.json', query: query, body: body);
    }
    Map response = await request.then((response) {
      return {'code': response.statusCode, 'reason': response.reasonPhrase};
    });
    return response;
  }

  Future<List<Thread>> threads(int page) async {
    String body = await http.get(await host, '/forum_topics.json', query: {
      'page': page,
    }).then((response) => response.body);

    List<Thread> threads = [];
    var data = json.decode(body);
    if (data is List) {
      for (Map thread in data) {
        threads.add(Thread.fromRaw(thread));
      }
    }

    return threads;
  }

  Future<Thread> thread(int id) async {
    String body = await http
        .get(await host, '/forum_topics/$id.json')
        .then((response) => response.body);

    Thread thread;
    var data = json.decode(body);
    if (data is Map) {
      thread = Thread.fromRaw(data);
    }

    return thread;
  }

  Future<List<Reply>> replies(Thread thread, String page) async {
    String body = await http.get(await host, '/forum_posts.json', query: {
      'commit': 'Search',
      'search[topic_title_matches]': thread.title,
      'page': page,
    }).then((response) => response.body);

    List<Reply> replies = [];
    var data = json.decode(body);
    if (data is List) {
      for (Map reply in data) {
        replies.add(Reply.fromRaw(reply));
      }
    }

    return replies;
  }
}
