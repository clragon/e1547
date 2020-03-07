import 'dart:async' show Future;
import 'dart:convert' show json;

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

  Client() {
    db.host.addListener(() => _host = db.host.value);
    db.username.addListener(() => _username = db.username.value);
    db.apiKey.addListener(() => _apiKey = db.apiKey.value);
  }

  Future<bool> addAsFavorite(int post) async {
    if (!await isLoggedIn()) {
      return false;
    }

    return await _http.post(await _host, '/favorites.json', query: {
      'login': await _username,
      'api_key': await _apiKey,
      'post_id': post,
    }).then((response) => response.statusCode == 201);
  }

  Future<bool> removeAsFavorite(int post) async {
    if (!await isLoggedIn()) {
      return false;
    }

    return await _http.delete(await _host, '/favorites/' + post.toString() + 'json', query: {
      'login': await _username,
      'api_key': await _apiKey,
    }).then((response) {
      return response.statusCode == 302;
    });
  }

  Future<bool> isLoggedIn() async {
    return !(await _username == null || await _apiKey == null);
  }

  Future<bool> isValidAuthPair(String username, String apiKey) async {
    return await _http.get(await _host, '/favorites.json', query: {
      'login': username,
      'api_key': apiKey,
    }).then((response) {
      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode != 403) {
      }

      return false;
    });
  }

  Future<List<Post>> posts(Tagset tags, int page) async {

    String body = await _http.get(await _host, '/posts.json', query: {
      'tags': tags,
      'page': page + 1,
      'limit': 75,
      'login': await _username,
      'api_key': await _apiKey,
    }).then((response) => response.body);

    List<Post> posts = [];
    for (Map rp in json.decode(body)['posts']) {
      Post p = new Post.fromRaw(rp);
      if (p.file['url'] == null || p.file['ext'] == 'swf') { continue; }
      p.isLoggedIn = await this.isLoggedIn();
      posts.add(p);
    }

    return posts;
  }

  Future<List<Comment>> comments(int postId, int page) async {
    // THIS DOES NOT WORK YET; API BROKEN.
    String body = await _http.get(await _host, '/comments.json', query: {
      'post_id': postId,
      'page': page + 1,
      'login': await _username,
      'api_key': await _apiKey,
    }).then((response) => response.body);

    List<Comment> comments = [];
    for (Map rc in json.decode(body)) {
      comments.add(new Comment.fromRaw(rc));
    }

    return comments;
  }
}
