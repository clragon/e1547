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

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart' show Logger;

import 'consts.dart' as consts;

const String userAgent = '${consts.appName}/${consts.appVersion} (perlatus)';

class HttpCustom {
  final Logger _log = new Logger('HttpCustom');

  // TODO PLZ STOP COPY PASTING
  Future<http.Response> post(String host, String path, {Map query}) {
    return postUrl(new Uri(
      scheme: 'https',
      host: host,
      path: path,
      queryParameters: stringify(query),
    ));
  }

  Future<http.Response> get(String host, String path, {Map query}) {
    return getUrl(new Uri(
      scheme: 'https',
      host: host,
      path: path,
      queryParameters: stringify(query),
    ));
  }

  Future<http.Response> getUrl(Uri url) {
    _log.fine('getUrl(url="$url")');
    return http.get(url, headers: {'User-Agent': userAgent});
  }

  Future<http.Response> postUrl(Uri url) {
    _log.fine('postUrl(url="$url")');
    return http.post(url, headers: {'User-Agent': userAgent});
  }
}

Map<String, String> stringify(Map<String, Object> map) {
  Map<String, String> stringMap = {};
  map.forEach((k, v) {
    stringMap[k] = v.toString();
  });
  return stringMap;
}
