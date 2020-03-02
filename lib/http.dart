// TODO: check how much of this is necessary.

import 'dart:async' show Future;
import 'appinfo.dart' as appInfo;
import 'package:http/http.dart' as http;

const String userAgent = '${appInfo.appName}/${appInfo.appVersion} (perlatus)';

class HttpCustom {

  Future<http.Response> post(String host, String path,
      {Map<String, Object> query}) {
    return postUrl(new Uri(
      scheme: 'https',
      host: host,
      path: path,
      queryParameters: _stringify(query),
    ));
  }

  Future<http.Response> get(String host, String path,
      {Map<String, Object> query}) {
    return getUrl(new Uri(
      scheme: 'https',
      host: host,
      path: path,
      queryParameters: _stringify(query),
    ));
  }

  Future<http.Response> getUrl(Uri url) {
    return http.get(url, headers: {'User-Agent': userAgent});
  }

  Future<http.Response> postUrl(Uri url) {
    return http.post(url, headers: {'User-Agent': userAgent});
  }
}

Map<String, String> _stringify(Map<String, Object> map) {
  Map<String, String> stringMap = {};
  map.forEach((k, v) {
    if (v != null) {
      stringMap[k] = v.toString();
    }
  });
  return stringMap;
}
