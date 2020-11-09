import 'dart:convert';

import 'package:e1547/about/app_info.dart';
import 'package:flutter/foundation.dart';

import 'http.dart';

List<Map> githubData = [];

Future<List<Map>> getVersions() async {
  if (kReleaseMode) {
    if (githubData.length == 0) {
      await HttpHelper().get('api.github.com', '/repos/$github/releases',
          query: {}).then((response) {
        for (Map release in json.decode(response.body)) {
          githubData.add({
            'version': release['tag_name'],
            'title': release['name'],
            'description': release['body'],
          });
        }
      });
    }
    return Future.value(githubData);
  } else {
    return [];
  }
}
