import 'dart:async' show Future;
import 'dart:convert' show json;

import 'package:e1547/pool.dart';

import 'comment.dart' show Comment;
import 'http.dart';
import 'persistence.dart' show db;
import 'post.dart' show Post;
import 'tag.dart';

final Client client = new Client();

class Client {
  final HttpHelper _http = new HttpHelper();

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

  Future<bool> addAsFavorite(int post) async {
    if (!await hasLogin()) {
      return false;
    }

    return await _http.post(await _host, '/favorites.json', query: {
      'login': await _username,
      'api_key': await _apiKey,
      'post_id': post,
    }).then((response) => response.statusCode == 201);
  }

  Future<bool> removeAsFavorite(int post) async {
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
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
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
    db.username.value = new Future.value(null);
    db.apiKey.value = new Future.value(null);
  }

  Future<bool> hasLogin() async {
    return !(await _username == null || await _apiKey == null);
  }

  Future<bool> isBlacklisted(Post post) async {
    List<String> blacklist = await _blacklist;
    if (0 < blacklist.length) {
      String tags;
      post.tags.forEach((k, v) {
        v.forEach((s) {
          tags = '$tags$s ';
        });
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

        bool bMatch = true;
        bool wMatch = true;

        bool checkTags(String tags, String tag) {
          if (tag.contains(':')) {
            String identifier = tag.split(':')[0];
            String value = tag.split(':')[1];
            switch (identifier) {
              case 'rating':
                if (post.rating == value.toUpperCase()) {
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

        black.forEach((tag) {
          if (!checkTags(tags, tag)) {
            bMatch = false;
          }
        });
        white.forEach((tag) {
          if (!checkTags(tags, tag)) {
            wMatch = false;
          }
        });

        if (black.length != 0 && white.length != 0) {
          if (bMatch) {
            if (!wMatch) {
              return true;
            }
          }
        } else {
          if (black.length != 0) {
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
        Post post = new Post.fromRaw(rawPost);
        post.isLoggedIn = loggedIn;
        if (post.file['url'] == null || post.file['ext'] == 'swf') {
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
        return client.posts(tags, page + 1);
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
        Pool pool = new Pool.fromRaw(rawPool);
        pools.add(pool);
      }

      return pools;
    } catch (SocketException) {
      return [];
    }
  }

  Future<Pool> poolById(int poolID) async {
    String body = await _http
        .get(await _host, '/pools/' + poolID.toString() + '.json', query: {
      'login': await _username,
      'api_key': await _apiKey,
    }).then((response) => response.body);

    return Pool.fromRaw(json.decode(body));
  }

  Future<List<Post>> pool(Pool pool, int page) async {
    return posts(new Tagset.parse('pool:${pool.id} order:id'), page);
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
      posts.addAll(await client.posts(Tagset.parse('~' + tag.join(' ~')), page));
    }
    return posts;
  }

  Future<Post> post(int postID) async {
    try {
      String body = await _http
          .get(await _host, '/posts/' + postID.toString() + '.json', query: {
        'login': await _username,
        'api_key': await _apiKey,
      }).then((response) => response.body);

      Post post = new Post.fromRaw(json.decode(body)['post']);
      post.isLoggedIn = await hasLogin();
      post.isBlacklisted = await isBlacklisted(post);
      return post;
    } catch (SocketException) {
      return null;
    }
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

  Future<List<String>> tags(String search, int page) async {
    String body = await _http.get(await _host, '/tags.json', query: {
      'search[name_matches]': search + '*',
      'search[order]': 'count',
      'page': page + 1,
      'limit': 3,
      'login': await _username,
      'api_key': await _apiKey,
    }).then((response) => response.body);

    List<String> tags = [];
    for (Map rawTag in json.decode(body)) {
      tags.add(rawTag['name']);
    }
    return tags;
  }

  Future<List<Comment>> comments(int postId, int page) async {
    String body = await _http.get(await _host, '/comments.json', query: {
      'group_by': 'comment',
      'search[post_tags_match]': 'id:$postId',
      'page': page + 1,
      'login': await _username,
      'api_key': await _apiKey,
    }).then((response) => response.body);

    List<Comment> comments = [];
    var commentList = json.decode(body);
    if (commentList is List) {
      for (Map rawComment in commentList) {
        comments.add(new Comment.fromRaw(rawComment));
      }
    }

    return comments;
  }
}
