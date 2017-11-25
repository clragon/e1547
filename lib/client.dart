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
import 'persistence.dart' as persistence;
import 'post.dart' show Post;
import 'tag.dart';

final Client client = new Client();

class Client {
  final Logger _log = new Logger('E1547Client');

  HttpCustom _http = new HttpCustom();

  // For example, 'e926.net'
  String host;

  LinearPagination<Post> posts(Tagset tags) {
    _log.info('Client.posts(tags="$tags")');

    Future<bool> hideSwf = persistence.getHideSwf();

    return new LinearPagination<Post>(75, (page) async {
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

    return new LinearPagination<Comment>(25, (page) async {
      String body = await _http.get(host, '/comment/index.json', query: {
        'post_id': postId,
        'page': page,
        // Don't return hidden comments. If we don't use this, we get back pages less than 25
        // because only admins can see hidden comments.
        'status': 'active',
      }).then((response) => response.body);

      List<Comment> comments = [];
      for (var rc in JSON.decode(body)) {
        comments.add(new Comment.fromRaw(rc));
      }

      return comments;
    });
  }
}
