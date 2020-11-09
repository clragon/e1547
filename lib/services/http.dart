import 'dart:async' show Future;

import 'package:e1547/about/app_info.dart';
import 'package:http/http.dart';
import 'package:http_auth/http_auth.dart';

String userAgent = '$appName/$appVersion ($developer)';

class HttpHelper {
  final String username;
  final String apiKey;
  final BaseClient client;

  HttpHelper({this.username, this.apiKey})
      : client = username != null && apiKey != null
            ? BasicAuthClient(username, apiKey)
            : Client();

  Map<String, String> headers = {'User-Agent': userAgent};

  Future<Response> post(String host, String path,
      {Map<String, dynamic> query, Map<String, String> body}) {
    return client.post(_getUri(host, path, query),
        headers: headers, body: body);
  }

  Future<Response> get(String host, String path, {Map<String, dynamic> query}) {
    return client.get(_getUri(host, path, query), headers: headers);
  }

  Future<Response> patch(String host, String path,
      {Map<String, dynamic> query, Map<String, String> body}) {
    return client.patch(_getUri(host, path, query),
        headers: headers, body: body);
  }

  Future<Response> delete(String host, String path,
      {Map<String, dynamic> query}) {
    return client.delete(_getUri(host, path, query), headers: headers);
  }

  Uri _getUri(host, path, query) {
    return Uri(
      scheme: 'https',
      host: host,
      path: path,
      queryParameters: _stringify(query ?? {}),
    );
  }

  Map<String, String> _stringify(Map<String, dynamic> map) {
    Map<String, String> stringMap = {};
    map.forEach((k, v) {
      if (v != null) {
        stringMap[k] = v.toString();
      }
    });
    return stringMap;
  }
}
