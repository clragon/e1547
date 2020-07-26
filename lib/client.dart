import 'dart:async' show Future;
import 'dart:convert' show json;

import 'package:e1547/comment.dart' show Comment;
import 'package:e1547/http.dart';
import 'package:e1547/persistence.dart' show db;
import 'package:e1547/pool.dart';
import 'package:e1547/post.dart' show Post;
import 'package:e1547/tag.dart';

final Client client = Client();

class Client {
  final HttpHelper _http = HttpHelper();

  Future<String> _host = db.host.value;
  Future<String> _username = db.username.value;
  Future<String> _apiKey = db.apiKey.value;
  Future<List<String>> _blacklist = db.blacklist.value;
  Future<List<String>> _following = db.follows.value;

  Client() {
    db.host.addListener(() => _host = db.host.value);
    db.username.addListener(() => _username = db.username.value);
    db.apiKey.addListener(() => _apiKey = db.apiKey.value);
    db.blacklist.addListener(() => _blacklist = db.blacklist.value);
    db.follows.addListener(() => _following = db.follows.value);
  }

  Future<bool> addFavorite(int post) async {
    if (!await hasLogin()) {
      return false;
    }

    return await _http.post(await _host, '/favorites.json', query: {
      'login': await _username,
      'api_key': await _apiKey,
      'post_id': post,
    }).then((response) => response.statusCode == 201);
  }

  Future<bool> removeFavorite(int post) async {
    if (!await hasLogin()) {
      return false;
    }

    return await _http
        .delete(await _host, '/favorites/' + post.toString() + '.json', query: {
      'login': await _username,
      'api_key': await _apiKey,
    }).then((response) {
      return response.statusCode == 204;
    });
  }

  Future<bool> votePost(int post, bool upvote, bool replace) async {
    if (!await hasLogin()) {
      return false;
    }

    return await _http
        .post(await _host, '/posts/' + post.toString() + '/votes.json', query: {
      'score': upvote ? 1 : -1,
      'no_unvote': replace,
      'login': await _username,
      'api_key': await _apiKey,
    }).then((response) {
      return response.statusCode == 200;
    });
  }

  Future<bool> tryLogin(String username, String apiKey) async {
    return await _http.get(await _host, '/favorites.json', query: {
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

  Future<bool> verifyLogin() async {
    String username = await _username;
    String apiKey = await _apiKey;
    if (username != null && apiKey != null) {
      if (await tryLogin(username, apiKey)) {
        return true;
      } else {
        logout();
        return false;
      }
    } else {
      return false;
    }
  }

  Future<void> logout() async {
    db.username.value = Future.value(null);
    db.apiKey.value = Future.value(null);
  }

  Future<bool> hasLogin() async {
    return !(await _username == null || await _apiKey == null);
  }

  Future<bool> isBlacklisted(Post post) async {
    List<String> blacklist = await _blacklist;
    if (blacklist.length > 0) {
      List<String> tags = [];
      post.tags.value.forEach((k, v) {
        tags.addAll(v.cast<String>());
      });

      for (String line in blacklist) {
        List<String> black = [];
        List<String> white = [];
        line.split(' ').forEach((s) {
          if (s != '') {
            if (s[0] == '-') {
              white.add(s.substring(1));
            } else {
              black.add(s);
            }
          }
        });

        bool checkTags(List<String> tags, String tag) {
          if (tag.contains(':')) {
            String identifier = tag.split(':')[0];
            String value = tag.split(':')[1];
            switch (identifier) {
              case 'rating':
                if (post.rating.value == value.toUpperCase()) {
                  return true;
                }
                break;
              case 'id':
                if (post.id == int.parse(value)) {
                  return true;
                }
                break;
              case 'type':
                if (post.file['ext'] == value) {
                  return true;
                }
                break;
              case 'pool':
                if (post.pools.contains(value)) {
                  return true;
                }
                break;
              case 'user':
                break;
            }
          }

          if (tags.contains(tag)) {
            return true;
          } else {
            return false;
          }
        }

        bool bMatch = true;
        bool wMatch = true;

        for (String tag in black) {
          if (!checkTags(tags, tag)) {
            bMatch = false;
            break;
          }
        }
        for (String tag in white) {
          if (!checkTags(tags, tag)) {
            wMatch = false;
            break;
          }
        }

        if (black.length > 0 && white.length > 0) {
          if (bMatch) {
            if (!wMatch) {
              return true;
            }
          }
        } else {
          if (black.length > 0) {
            if (bMatch) {
              return true;
            }
          } else {
            if (!wMatch) {
              return true;
            }
          }
        }
      }
    }
    return false;
  }

  Future<List<Post>> posts(Tagset tags, int page, {bool filter = true}) async {
    try {
      String body = await _http.get(await _host, '/posts.json', query: {
        'tags': tags,
        'page': page + 1,
        'login': await _username,
        'api_key': await _apiKey,
      }).then((response) => response.body);

      List<Post> posts = [];
      bool loggedIn = await this.hasLogin();
      bool showWebm = await db.showWebm.value;
      bool hasPosts = false;
      for (Map rawPost in json.decode(body)['posts']) {
        hasPosts = true;
        Post post = Post.fromRaw(rawPost);
        post.isLoggedIn = loggedIn;
        if (post.file['ext'] == 'swf') {
          continue;
        }
        if (!showWebm && post.file['ext'] == 'webm') {
          continue;
        }
        if (filter && await isBlacklisted(post)) {
          continue;
        }
        posts.add(post);
      }
      if (hasPosts && posts.length == 0) {
        return client.posts(tags, page + 1, filter: filter);
      }
      return posts;
    } catch (SocketException) {
      return [];
    }
  }

  Future<List<Pool>> pools(String title, int page) async {
    try {
      String body = await _http.get(await _host, '/pools.json', query: {
        'search[name_matches]': title,
        'page': page + 1,
        'login': await _username,
        'api_key': await _apiKey,
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
    String body = await _http
        .get(await _host, '/pools/' + poolID.toString() + '.json', query: {
      'login': await _username,
      'api_key': await _apiKey,
    }).then((response) => response.body);

    return Pool.fromRaw(json.decode(body));
  }

  Future<List<Post>> follows(int page) async {
    List<List<String>> tags = [];
    List<Post> posts = [];

    int length = (await _following).length;
    int max = 40;

    for (int i = 0; i < length; i += max) {
      int end = (length > i + max) ? i + max : length;
      tags.add((await _following).sublist(i, end));
    }

    for (List<String> tag in tags) {
      posts
          .addAll(await client.posts(Tagset.parse('~' + tag.join(' ~')), page));
    }
    return posts;
  }

  Future<Post> post(int postID, {bool unsafe = false}) async {
    try {
      String body = await _http.get((unsafe ? 'e621.net' : await _host),
          '/posts/' + postID.toString() + '.json',
          query: {
            'login': await _username,
            'api_key': await _apiKey,
          }).then((response) => response.body);

      Post post = Post.fromRaw(json.decode(body)['post']);
      post.isLoggedIn = await hasLogin();
      post.isBlacklisted = await isBlacklisted(post);
      return post;
    } catch (SocketException) {
      return null;
    }
  }

  Future<Map> updatePost(Post update, Post old, {String editReason}) async {
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

      Map response = await _http
          .patch(await _host, '/posts/${update.id}.json',
              query: {
                'login': await _username,
                'api_key': await _apiKey,
              },
              body: body)
          .then((response) =>
              {'code': response.statusCode, 'reason': response.reasonPhrase});
      return response;
    }
    return null;
  }

  Future<List> wiki(String search, int page) async {
    String body = await _http.get(await _host, 'wiki_pages.json', query: {
      'search[title]': search,
      'page': page + 1,
      'login': await _username,
      'api_key': await _apiKey,
    }).then((response) => response.body);

    return json.decode(body);
  }

  Future<Map> user(String name) async {
    String body = await _http.get(await _host, '/users/$name.json', query: {
      'login': await _username,
      'api_key': await _apiKey,
    }).then((response) => response.body);

    return json.decode(body);
  }

  Future<List> tags(String search, {int category, int page = 0}) async {
    String body = await _http.get(await _host, '/tags.json', query: {
      'search[name_matches]': search + '*',
      'search[category]': category,
      'search[order]': 'count',
      'page': page + 1,
      'limit': 3,
      'login': await _username,
      'api_key': await _apiKey,
    }).then((response) => response.body);

    List tags = [];
    var tagList = json.decode(body);
    if (tagList is List) {
      tags = tagList;
    }
    return tags;
  }

  Future<List<Comment>> comments(int postId, int page) async {
    String body = await _http.get(await _host, '/comments.json', query: {
      'group_by': 'comment',
      'search[post_id]': '$postId',
      'page': page + 1,
      'login': await _username,
      'api_key': await _apiKey,
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

  Future<Map> postComment(String comment, Post post) async {
    String body = await _http.post(await _host, '/comments.json', query: {
      'login': await _username,
      'api_key': await _apiKey,
    }, body: {
      'comment[body]': comment,
      'comment[post_id]': post.id.toString(),
      'commit': 'Submit',
      'comment[do_not_bump]': '0',
    }).then((response) => response.body);

    return json.decode(body);
  }
}
