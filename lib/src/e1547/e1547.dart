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
