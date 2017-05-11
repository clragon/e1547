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

class E1547Client {
  final Logger _log = new Logger("E1547Client");

  HttpClient _http = new HttpClient()
    ..userAgent = "$APP_NAME/$APP_VERSION (perlatus)";

  // For example, "e926.net"
  String host;

  Future<List<Map>> posts(String tags) async {
    _log.info("Requesting posts with tags: '$tags'");

    Uri url = new Uri(
      scheme: 'https',
      host: host,
      path: '/post/index.json',
      queryParameters: {'tags': tags, 'limit': "100"},
    );

    _log.fine("url: $url");

    HttpClientRequest request = await _http.getUrl(url);

    HttpClientResponse response = await request.close();
    _log.info("response.statusCode: ${response.statusCode} (${response.reasonPhrase})");

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
  }
}
