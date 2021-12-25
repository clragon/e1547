import 'dart:convert';

import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/foundation.dart' show ValueNotifier;

final Persistence settings = Persistence();

class Persistence extends SharedPrefsSerializer {
  late final ValueNotifier<Credentials?> credentials = createSetting(
    key: 'credentials',
    initial: null,
    getSetting: (prefs, key) {
      String? value = prefs.getString(key);
      if (value != null) {
        return Credentials.fromJson(value);
      } else {
        return null;
      }
    },
    setSetting: (prefs, key, value) async {
      if (value == null) {
        prefs.remove(key);
      } else {
        prefs.setString(key, value.toJson());
      }
    },
  );

  late final ValueNotifier<AppTheme> theme = createStringSetting(
      key: 'theme',
      initial: appThemeMap.keys.elementAt(1),
      values: AppTheme.values);

  late final ValueNotifier<List<String>> denylist =
  createSetting(key: 'blacklist', initial: []);
  late final ValueNotifier<List<Follow>> follows = createSetting(
    key: 'follows',
    initial: [],
    getSetting: (prefs, key) {
      try {
        List<String>? value = prefs.getStringList(key);
        if (value != null) {
          return value.map((e) => Follow.fromJson(e)).toList();
        } else {
          return null;
        }
      } on FormatException {
        return prefs
            .getStringList(key)!
            .map((e) => Follow.fromString(e))
            .toList();
      }
    },
    setSetting: (prefs, key, value) async => prefs.setStringList(
      key,
      value!.map((e) => e.toJson()).toList(),
    ),
  );

  late final ValueNotifier<Map<String, List<HistoryEntry>>> history =
      createSetting(
    key: 'history',
    initial: {},
    getSetting: (prefs, key) {
      String? value = prefs.getString(key);
      if (value != null) {
        Map<String, List<HistoryEntry>> result = {};
        for (MapEntry<String, dynamic> entry in json.decode(value).entries) {
          result[entry.key] = entry.value
              .map((e) => HistoryEntry.fromJson(e))
              .toList()
              .cast<HistoryEntry>();
        }
        return result;
      } else {
        return null;
      }
    },
    setSetting: (prefs, key, value) async {
      Map<String, dynamic> raw = {};
      for (MapEntry<String, List<HistoryEntry>> entry in value!.entries) {
        raw[entry.key] = entry.value.map((e) => e.toJson()).toList();
      }
      await prefs.setString(
        key,
        json.encode(raw),
      );
    },
  );
  late final ValueNotifier<bool> writeHistory =
      createSetting(key: 'writeHistory', initial: true);

  late final ValueNotifier<String> host =
      createSetting(key: 'currentHost', initial: 'e926.net');
  late final ValueNotifier<String?> customHost =
      createSetting(key: 'customHost', initial: null);
  late final ValueNotifier<String> homeTags =
      createSetting(key: 'homeTags', initial: 'score:>=20');

  late final ValueNotifier<int> tileSize =
      createSetting(key: 'tileSize', initial: 200);
  late final ValueNotifier<GridQuilt> quilt = createStringSetting(
    key: 'quilt',
    initial: GridQuilt.square,
    values: GridQuilt.values,
  );

  late final ValueNotifier<bool> splitFollows =
  createSetting(key: 'splitFollows', initial: true);
  late final ValueNotifier<bool> showPostInfo =
  createSetting<bool>(key: 'showPostInfo', initial: false);
  late final ValueNotifier<bool> showBeta =
  createSetting<bool>(key: 'showBeta', initial: false);
  late final ValueNotifier<bool> hideSystemUI =
  createSetting<bool>(key: 'hideSystemUI', initial: true);
  late final ValueNotifier<bool> upvoteFavs =
  createSetting<bool>(key: 'upvoteFavs', initial: false);
  late final ValueNotifier<bool> muteVideos =
  createSetting<bool>(key: 'muteVideos', initial: true);
}
