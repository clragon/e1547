import 'dart:async' show Future;
import 'dart:convert' show json;

import 'package:e1547/comment.dart' show Comment;
import 'package:e1547/http.dart';
import 'package:e1547/pool.dart';
import 'package:e1547/post.dart' show Post;
import 'package:e1547/settings.dart' show db;
import 'package:e1547/tag.dart';
import 'package:e1547/thread.dart';
import 'package:e1547/threads_page.dart';

final Client client = Client();

class Client {
  Future<bool> initialized;

  HttpHelper http = HttpHelper();

  Future<String> host = db.host.value;
  Future<String> username = db.username.value;
  Future<String> apiKey = db.apiKey.value;
  Future<List<String>> denylist = db.denylist.value;
  Future<List<String>> following = db.follows.value;

  String _avatar;

  Future<String> get avatar async {
    if (_avatar == null) {
      int postID = (await client.user(await username))['avatar_id'];
      Post post = await client.post(postID);
      _avatar = post.image.value.sample['url'];
    }
    return _avatar;
  }

  Client() {
    db.host.addListener(() => host = db.host.value);
    db.username.addListener(() => username = db.username.value);
    db.apiKey.addListener(() => apiKey = db.apiKey.value);
    db.denylist.addListener(() => denylist = db.denylist.value);
    db.follows.addListener(() => following = db.follows.value);

    db.username.addListener(() => login());
    db.apiKey.addListener(() => login());
    login();
  }

  Future<bool> login() async {
    initialized = () async {
      String username = await this.username;
      String apiKey = await this.apiKey;
      if (username != null && apiKey != null) {
        if (await tryLogin(username, apiKey)) {
          http = HttpHelper(username: username, apiKey: apiKey);
          return true;
        } else {
          logout();
          return false;
        }
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

  Future<bool> saveLogin(String username, String apiKey) async {
    if (await tryLogin(username, apiKey)) {
      db.username.value = Future.value(username);
      db.apiKey.value = Future.value(apiKey);
      return true;
    } else {
      return false;
    }
  }

  Future<bool> hasLogin() async {
    await initialized;
    return !(await username == null || await apiKey == null);
  }

  Future<void> logout() async {
    db.username.value = Future.value(null);
    db.apiKey.value = Future.value(null);
    _avatar = null;
    http = HttpHelper();
  }

  Future<List<Post>> posts(String tags, int page,
      {bool filter = true, int attempt = 0}) async {
    await initialized;
    try {
      String body = await http.get(await host, '/posts.json', query: {
        'tags': sortTags(tags),
        'page': page,
      }).then((response) => response.body);

      List<Post> posts = [];
      bool loggedIn = await this.hasLogin();
      bool hasPosts = false;
      for (Map rawPost in json.decode(body)['posts']) {
        hasPosts = true;
        Post post = Post.fromRaw(rawPost);
        post.isLoggedIn = loggedIn;
        if (post.image.value.file['url'] == null && !post.isDeleted) {
          continue;
        }
        if (post.image.value.file['ext'] == 'swf') {
          continue;
        }
        if (filter && await isBlacklisted(post)) {
          continue;
        }
        posts.add(post);
      }
      if (hasPosts && posts.length == 0 && attempt < 3) {
        return client.posts(tags, page + 1,
            filter: filter, attempt: attempt + 1);
      }
      return posts;
    } catch (SocketException) {
      return [];
    }
  }

  Future<bool> addFavorite(int post) async {
    if (!await hasLogin()) {
      return false;
    }

    return await http.post(await host, '/favorites.json', query: {
      'post_id': post,
    }).then((response) => response.statusCode == 201);
  }

  Future<bool> removeFavorite(int post) async {
    if (!await hasLogin()) {
      return false;
    }

    return await http
        .delete(await host, '/favorites/${post.toString()}.json')
        .then((response) {
      return response.statusCode == 204;
    });
  }

  Future<bool> votePost(int post, bool upvote, bool replace) async {
    if (!await hasLogin()) {
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

  Future<bool> isBlacklisted(Post post) async {
    List<String> denylist = await this.denylist;
    if (denylist.length > 0) {
      List<String> tags = [];
      post.tags.value.forEach((k, v) {
        tags.addAll(v.cast<String>());
      });

      for (String line in denylist) {
        List<String> deny = [];
        List<String> allow = [];
        line.split(' ').forEach((tag) {
          if (tag.isNotEmpty) {
            if (tag[0] == '-') {
              allow.add(tag.substring(1));
            } else {
              deny.add(tag);
            }
          }
        });

        bool checkTags(List<String> tags, String tag) {
          if (tag.contains(':')) {
            String identifier = tag.split(':')[0];
            String value = tag.split(':')[1];
            switch (identifier) {
              case 'rating':
                if (post.rating.value.toLowerCase() == value.toLowerCase()) {
                  return true;
                }
                break;
              case 'id':
                if (post.id == int.tryParse(value)) {
                  return true;
                }
                break;
              case 'type':
                if (post.image.value.file['ext'] == value) {
                  return true;
                }
                break;
              case 'pool':
                if (post.pools.contains(value)) {
                  return true;
                }
                break;
              case 'user':
                if (post.uploader == value) {
                  return true;
                }
                break;
              case 'score':
                bool greater = value.contains('>');
                bool smaller = value.contains('<');
                bool equal = value.contains('=');
                int score = int.tryParse(value.replaceAll(r'[<>=]', ''));
                if (greater) {
                  if (equal) {
                    if (post.score.value >= score) {
                      return true;
                    }
                  } else {
                    if (post.score.value > score) {
                      return true;
                    }
                  }
                }
                if (smaller) {
                  if (equal) {
                    if (post.score.value <= score) {
                      return true;
                    }
                  } else {
                    if (post.score.value < score) {
                      return true;
                    }
                  }
                }
                if ((!greater && !smaller) && post.score.value == score) {
                  return true;
                }
                break;
            }
          }

          if (tags.contains(tag)) {
            return true;
          } else {
            return false;
          }
        }

        bool denied = true;
        bool allowed = true;

        for (String tag in deny) {
          if (!checkTags(tags, tag)) {
            denied = false;
            break;
          }
        }
        for (String tag in allow) {
          if (!checkTags(tags, tag)) {
            allowed = false;
            break;
          }
        }

        if (deny.length > 0 && allow.length > 0) {
          if (denied) {
            if (!allowed) {
              return true;
            }
          }
        } else {
          if (deny.length > 0) {
            if (denied) {
              return true;
            }
          } else {
            if (!allowed) {
              return true;
            }
          }
        }
      }
    }
    return false;
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
    } catch (SocketException) {
      return [];
    }
  }

  Future<Pool> pool(int poolID) async {
    String body = await http
        .get(await host, '/pools/${poolID.toString()}.json')
        .then((response) => response.body);

    return Pool.fromRaw(json.decode(body));
  }

  Future<List<Post>> follows(int page) async {
    List<List<String>> tags = [];
    List<Post> posts = [];

    int length = (await following).length;
    int max = 40;

    for (int i = 0; i < length; i += max) {
      int end = (length > i + max) ? i + max : length;
      tags.add((await following).sublist(i, end));
    }

    for (List<String> tag in tags) {
      posts.addAll(await client.posts('~${tag.join(' ~')}', page));
    }
    return posts;
  }

  Future<Post> post(int postID, {bool unsafe = false}) async {
    await initialized;
    try {
      String body = await http
          .get((unsafe ? 'e621.net' : await host),
              '/posts/${postID.toString()}.json')
          .then((response) => response.body);

      Post post = Post.fromRaw(json.decode(body)['post']);
      post.isLoggedIn = await hasLogin();
      post.isBlacklisted = await isBlacklisted(post);
      return post;
    } catch (SocketException) {
      return null;
    }
  }

  Future<Map> updatePost(Post update, Post old, {String editReason}) async {
    await initialized;
    if (!await hasLogin()) {
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
        'page': page + 1,
      }).then((response) => response.body);

      return json.decode(body);
    } catch (SocketException) {
      return null;
    }
  }

  Future<Map> user(String name) async {
    await initialized;
    String body = await http
        .get(await host, '/users/$name.json')
        .then((response) => response.body);

    return json.decode(body);
  }

  Future<List> tags(String search, {int category, int page = 0}) async {
    String body = await http.get(await host, '/tags.json', query: {
      'search[name_matches]': search + '*',
      'search[category]': category,
      'search[order]': 'count',
      'page': page + 1,
      'limit': 3,
    }).then((response) => response.body);

    List tags = [];
    var tagList = json.decode(body);
    if (tagList is List) {
      tags = tagList;
    }
    return tags;
  }

  Future<List<Comment>> comments(int postID, int page) async {
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
  }

  Future<Map> postComment(String text, Post post, {Comment comment}) async {
    await initialized;
    if (!await hasLogin()) {
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
      'page': page + 1,
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
