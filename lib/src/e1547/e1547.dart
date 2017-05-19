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
import 'dart:convert' show JSON, UTF8;
import 'dart:io' show HttpClient, HttpClientRequest, HttpClientResponse;

import 'package:logging/logging.dart' show Logger;

import '../../vars.dart' as vars;

class Client {
  final Logger _log = new Logger("E1547Client");

  HttpClient _http = new HttpClient()
    ..userAgent = "${vars.APP_NAME}/${vars.APP_VERSION} (perlatus)";

  // For example, "e926.net"
  String host;

  Future<List<Post>> posts(String tags, int page) async {
    _log.info("Requesting posts with tags: '$tags'");

    Uri url = new Uri(
      scheme: 'https',
      host: host,
      path: '/post/index.json',
      queryParameters: {'tags': tags, 'page': page.toString()},
    );

    _log.fine("url: $url");

    HttpClientRequest request = await _http.getUrl(url);
    HttpClientResponse response = await request.close();
    _log.info(
        "response.statusCode: ${response.statusCode} (${response.reasonPhrase})");

    var body = new StringBuffer();
    await response.transform(UTF8.decoder).forEach((s) => body.write(s));
    _log.fine("response body: $body");
    var rawPosts = JSON.decode(body.toString());

    // Remove webm/video and swf/flash posts because we can't display them.
    rawPosts.removeWhere((p) {
      String ext = p['file_ext'];
      return ext == "webm" || ext == "swf";
    });

    List<Post> posts = [];
    for (var rp in rawPosts) {
      posts.add(new Post.fromRaw(rp, host));
    }

    return posts;
  }
}

class Post {
  Map raw;
  String _host;

  // Get the URL for the HTML version of the desired post.
  Uri get url => new Uri(scheme: 'https', host: _host, path: '/post/show/$id');

  int id;
  int score;
  int fav_count;
  String file_url;
  String file_ext;
  String sample_url;
  int sample_width;
  int sample_height;
  String rating;
  List<String> artist;

  Post.fromRaw(Map raw, String host) {
    this.raw = raw;
    this._host = host;

    id = raw['id'];
    score = raw['score'];
    fav_count = raw['fav_count'];
    file_url = raw['file_url'];
    file_ext = raw['file_ext'];
    sample_url = raw['sample_url'];
    sample_width = raw['sample_width'];
    sample_height = raw['sample_height'];

    rating = raw['rating'].toUpperCase();

    artist = raw['artist'];
  }
}
