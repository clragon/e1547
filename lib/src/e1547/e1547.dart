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

import '../../vars.dart';

typedef Future<List<E>> PageGenerator<E>(int pageIndex);

class Pagination<E> {
  Pagination(this.pageSize, this.pageGenerator);

  final int pageSize;
  final PageGenerator<E> pageGenerator;

  Map<int, E> _map = {};

  Future<E> operator [](int elementIndex) async {
    print(_map);
    if (_map.containsKey(elementIndex)) {
      return _map[elementIndex];
    }

    // We don't have the element yet, so we need to load in a new page.
    int requiredPage = elementIndex ~/ pageSize;
    int firstIndex = requiredPage * pageSize;
    List<E> newPage = await pageGenerator(requiredPage);

    for (int i = 0; i < newPage.length; i++) {
      int mapIndex = firstIndex + i;
      assert(!_map.containsKey(mapIndex));
      _map[mapIndex] = newPage[i];
    }

    return _map[elementIndex];
  }
}

const int _PAGE_SIZE = 75;

class E1547Client {
  final Logger _log = new Logger("E1547Client");

  HttpClient _http = new HttpClient()
    ..userAgent = "$APP_NAME/$APP_VERSION (perlatus)";

  // For example, "e926.net"
  String host;

  // Get the URL for the HTML version of the desired post.
  Uri postUrl(int postId) {
    return new Uri(
      scheme: 'https',
      host: host,
      path: '/post/show/$postId',
    );
  }

  Pagination<Map> posts(String tags) {
    _log.info("Requesting posts with tags: '$tags'");

    return new Pagination<Map>(_PAGE_SIZE, (int p) async {
      Uri url = new Uri(
        scheme: 'https',
        host: host,
        path: '/post/index.json',
        queryParameters: {'tags': tags, 'limit': _PAGE_SIZE, 'page': p},
      );

      _log.fine("url: $url");

      HttpClientRequest request = await _http.getUrl(url);

      HttpClientResponse response = await request.close();
      _log.info(
          "response.statusCode: ${response.statusCode} (${response.reasonPhrase})");

      var body = new StringBuffer();
      await response.transform(UTF8.decoder).forEach((s) => body.write(s));
      _log.fine("response body: $body");
      var posts = JSON.decode(body.toString());

      // Remove webm/video and swf/flash posts because we can't display them.
      posts.removeWhere((p) {
        String ext = p['file_ext'];
        return ext == "webm" || ext == "swf";
      });

      return posts;
    });
  }
}
