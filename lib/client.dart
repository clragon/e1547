// e1547: A mobile app for browsing e926.net and friends.
// Copyright (C) 2017 perlatus <perlatus@e1547.email.vczf.io>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.

import 'dart:async' show Future;
import 'dart:convert' show json;
import 'dart:convert';
import 'package:logging/logging.dart' show Logger;

import 'comment.dart' show Comment;
import 'http.dart';
import 'persistence.dart' show db;
import 'post.dart' show Post;
import 'tag.dart';

final Client client = new Client();

class Client {
  final Logger _log = new Logger('E1547Client');

  final HttpCustom _http = new HttpCustom();

  Future<String> _host = db.host.value;
  Future<String> _username = db.username.value;
  Future<String> _apiKey = db.apiKey.value;
  List<int> favourites;

  Client() {
    db.host.addListener(() => _host = db.host.value);
    db.username.addListener(() => _username = db.username.value);
    db.apiKey.addListener(() => _apiKey = db.apiKey.value);
  }

  Future<bool> isUserFavourite(int post) async {
    if (!await isLoggedIn()) {
      return false;
    }

    return await _http.post(await _host, '/favorite/list_users.json', query: {
      'id': post,
    }).then((response) async => response.body.toString().contains(await _username));
  }

  Future<List<int>> getFavourites() async {
    String body = await _http.get(await _host, '/post/index.json', query: {
      'tags': 'fav:' + await _username,
    }).then((response) => response.body);

    List<int> ids = [];
    for (Map rp in json.decode(body)) {
      Post p = new Post.fromRaw(rp);
      ids.add(p.id);
    }

    return ids;
  }

  Future<bool> addAsFavorite(int post) async {
    if (!await isLoggedIn()) {
      return false;
    }

    return await _http.post(await _host, '/favorite/create.json', query: {
      'login': await _username,
      'password_hash': await _apiKey,
      'id': post,
    }).then((response) => response.statusCode == 200);
  }

  Future<bool> removeAsFavorite(int post) async {
    if (!await isLoggedIn()) {
      return false;
    }

    return await _http
        .post(await db.host.value, '/favorite/destroy.json', query: {
      'login': await _username,
      'password_hash': await _apiKey,
      'id': post,
    }).then((response) {
      return response.statusCode == 200;
    });
  }

  Future<bool> isLoggedIn() async {
    return !(await _username == null || await _apiKey == null);
  }

  Future<bool> isValidAuthPair(String username, String apiKey) async {
    return await _http.get(await _host, '/dmail/inbox.json', query: {
      'login': username,
      'password_hash': apiKey,
    }).then((response) {
      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode != 403) {
        _log.warning('Unexpected status code: ${response.statusCode}');
      }

      return false;
    });
  }

  Future<List<Post>> posts(Tagset tags, int page) async {
    favourites ??= await getFavourites();

    String body = await _http.get(await _host, '/post/index.json', query: {
      'tags': tags,
      'page': page + 1,
      'limit': 75,
    }).then((response) => response.body);

    List<Post> posts = [];
    for (Map rp in json.decode(body)) {
      Post p = new Post.fromRaw(rp);
      if (favourites.contains(p.id)) {
        p.isFavourite = true;
      }
      if (await db.hideSwf.value && p.fileExt == 'swf') {
        _log.fine('Hiding swf post #${p.id}');
        continue;
      }
      posts.add(p);
    }

    return posts;
  }

  Future<List<Comment>> comments(int postId, int page) async {
    String body = await _http.get(await _host, '/comment/index.json', query: {
      'post_id': postId,
      'page': page + 1,
    }).then((response) => response.body);

    List<Comment> comments = [];
    for (Map rc in json.decode(body)) {
      comments.add(new Comment.fromRaw(rc));
    }

    return comments;
  }
}
