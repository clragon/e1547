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

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart' show Logger;

import 'comment.dart' show Comment;
import 'http.dart';
import 'pagination.dart';
import 'persistence.dart' as persistence;
import 'post.dart' show Post;
import 'tag.dart';

final Client client = new Client();

class Client {
  final Logger _log = new Logger('E1547Client');

  HttpCustom _http = new HttpCustom();

  // For example, 'e926.net'
  String host;

  // From https://www.crossdart.info/p/http/0.11.3+16/http.dart.html#line-164
  Future<T> _withClient<T>(Future<T> fn(http.Client client)) async {
    var client = new http.Client();
    try {
      return await fn(client);
    } finally {
      client.close();
    }
  }

  // TODO: handle alternative status-codes better. Typical "failure" in this
  // case is a 302 redirect to /user/index.html
  //
  // TODO: Put this logic in ./http.dart, where it belongs and take advantage of
  // existing helper methods. Refactor to work with other methods in HttpCustom.
  Future<bool> isValidAuthPair(String username, String apiKey) async {
    _log.info('client.checkAuthPair(username="$username", apiKey="$apiKey")');
    return await _withClient<bool>((client) async {
      var response = await client.send(
        new http.Request(
          'GET',
          new Uri.https(
            host,
            '/user/show.json',
            {'login': username, 'password_hash': apiKey},
          ),
        )..followRedirects = false,
      );

      _log.info('response.statusCode=${response.statusCode}');

      return response.statusCode == 200;
    });
  }

  LinearPagination<Post> posts(Tagset tags) {
    _log.info('Client.posts(tags="$tags")');

    Future<bool> hideSwf = persistence.getHideSwf();

    return new LinearPagination<Post>((page) async {
      String body = await _http.get(host, '/post/index.json', query: {
        'tags': tags,
        'page': page,
        'limit': 75,
      }).then((response) => response.body);

      List<Post> posts = [];
      for (var rp in JSON.decode(body)) {
        Post p = new Post.fromRaw(rp);
        if (await hideSwf && p.fileExt == 'swf') {
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
      String body = await _http.get(host, '/comment/index.json', query: {
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
