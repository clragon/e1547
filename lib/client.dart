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

  Future<List<Post>> posts(Tagset tags, int page, {int limit = 200}) async {

    String body = await _http.get(await _host, '/posts.json', query: {
      'tags': tags,
      'page': page + 1,
      'login': await _username,
      'api_key': await _apiKey,
      'limit': limit,
    }).then((response) => response.body);

    List<Post> posts = [];
    bool loggedIn = await this.isLoggedIn();
    bool showWebm = await db.showWebm.value;
    for (Map rp in json.decode(body)['posts']) {
      Post p = new Post.fromRaw(rp);
      p.isLoggedIn = loggedIn;
      if (p.file['url'] == null || p.file['ext'] == 'swf') { continue; }
      if (!showWebm && p.file['ext'] == 'webm') { continue; }
      posts.add(p);
    }

    return posts;
  }

  Future<List<Pool>> pools(String title, int page) async {
    String body = await _http.get(await _host, '/pools.json', query: {
      'search[name_matches]': title,
      'page': page + 1,
      'login': await _username,
      'api_key': await _apiKey,
    }).then((response) => response.body);

    List<Pool> pools = [];
    for (Map rp in json.decode(body)) {
      Pool p = new Pool.fromRaw(rp);
      pools.add(p);
    }

    return pools;
  }

  Future<Pool> poolById(int poolID) async {

    String body = await _http.get(await _host, '/pools/' + poolID.toString() + '.json', query: {
      'login': await _username,
      'api_key': await _apiKey,
    }).then((response) => response.body);

    return Pool.fromRaw(json.decode(body));
  }


  Future<List<Post>> pool(Pool pool, int page) async {
    String filter = "id:";
    for (int index = 0; index < pool.postIDs.length && index < ((page + 1) * 100); index++) {
        filter = filter + pool.postIDs[index].toString() + ',';
    }
    filter = filter + ' ' + 'order:id';
    return await posts(new Tagset.parse(filter), page, limit: 100);
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
