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
import 'dart:convert' show JSON;

import 'package:logging/logging.dart' show Logger;

import 'comment.dart' show Comment;
import 'http.dart';
import 'pagination.dart';
import 'persistence.dart' show db;
import 'post.dart' show Post;
import 'tag.dart';

final Client client = new Client();

class Client {
  final Logger _log = new Logger('E1547Client');

  final HttpCustom _http = new HttpCustom();

  Future<bool> addAsFavorite(int post) async {
    String username = await db.username.value;
    String apiKey = await db.apiKey.value;
    if (username == null || apiKey == null) {
      return false;
    }

    return await _http
        .post(await db.host.value, '/favorite/create.json', query: {
      'login': username,
      'password_hash': apiKey,
      'id': post,
    }).then((response) {
      return response.statusCode == 200;
    });
  }

  Future<bool> removeAsFavorite(int post) async {
    String username = await db.username.value;
    String apiKey = await db.apiKey.value;
    if (username == null || apiKey == null) {
      return false;
    }

    return await _http
        .post(await db.host.value, '/favorite/destroy.json', query: {
      'login': username,
      'password_hash': apiKey,
      'id': post,
    }).then((response) {
      return response.statusCode == 200;
    });
  }

  Future<bool> isValidAuthPair(String username, String apiKey) async {
    _log.info('client.isValidAuthPair(username="$username", apiKey="$apiKey")');
    return await _http.get(await db.host.value, '/dmail/inbox.json', query: {
      'login': username,
      'password_hash': apiKey,
    }).then((response) {
      if (response.statusCode == 200) {
        return true;
      }

      if (response.statusCode != 403) {
        _log.warning('Unexpected status code: ${response.statusCode}');
      }

      return false;
    });
  }

  LinearPagination<Post> posts(Tagset tags) {
    _log.info('Client.posts(tags="$tags")');

    return new LinearPagination<Post>((page) async {
      String body =
          await _http.get(await db.host.value, '/post/index.json', query: {
        'tags': tags,
        'page': page,
        'limit': 75,
      }).then((response) => response.body);

      List<Post> posts = [];
      for (var rp in JSON.decode(body)) {
        Post p = new Post.fromRaw(rp);
        if (await db.hideSwf.value && p.fileExt == 'swf') {
          _log.fine('Hiding swf post #${p.id}');
          continue;
        }
        posts.add(p);
      }
      return posts;
    });
  }

  LinearPagination<Comment> comments(int postId) {
    _log.info('Client.comments(postId="$postId")');

    return new LinearPagination<Comment>((page) async {
      String body =
          await _http.get(await db.host.value, '/comment/index.json', query: {
        'post_id': postId,
        'page': page,
      }).then((response) => response.body);

      List<Comment> comments = [];
      for (var rc in JSON.decode(body)) {
        comments.add(new Comment.fromRaw(rc));
      }

      return comments;
    });
  }
}
