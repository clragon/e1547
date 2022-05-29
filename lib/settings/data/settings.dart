import 'dart:convert';

import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/foundation.dart';

late final Settings settings;

Future<void> initializeSettings() async {
  settings = Settings();
  await settings.initialize();
}

class Settings with SharedPrefsSettings {
  late final ValueNotifier<Credentials?> credentials = createSetting(
    key: 'credentials',
    initialValue: null,
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

  late final ValueNotifier<AppTheme> theme = createEnumSetting(
    key: 'theme',
    initialValue: appThemeMap.keys.elementAt(1),
    values: AppTheme.values,
  );

  late final ValueNotifier<List<String>> denylist =
      createSetting(key: 'blacklist', initialValue: []);
  late final ValueNotifier<List<Follow>> follows = createSetting(
    key: 'follows',
    initialValue: [],
    getSetting: (prefs, key) {
      List<String>? value = prefs.getStringList(key);
      if (value != null) {
        return value.map((e) => Follow.fromJson(json.decode(e))).toList();
      } else {
        return null;
      }
    },
    setSetting: (prefs, key, value) async => prefs.setStringList(
      key,
      value.map((e) => json.encode(e.toJson())).toList(),
    ),
  );

  late final ValueNotifier<Map<String, HistoryCollection>> history =
      createSetting(
    key: 'history',
    initialValue: {},
    getSetting: (prefs, key) {
      String? value = prefs.getString(key);
      if (value != null) {
        return Map<String, HistoryCollection>.from(
          json.decode(value).map(
                (key, value) => MapEntry(key, HistoryCollection.fromMap(value)),
              ),
        );
      } else {
        return null;
      }
    },
    setSetting: (prefs, key, value) async {
      await prefs.setString(
        key,
        json.encode(
          Map<String, dynamic>.from(
            value.map(
              (key, value) => MapEntry(key, value.toMap()),
            ),
          ),
        ),
      );
    },
  );
  late final ValueNotifier<bool> writeHistory =
      createSetting(key: 'writeHistory', initialValue: true);

  late final ValueNotifier<String> host =
      createSetting(key: 'currentHost', initialValue: 'e926.net');
  late final ValueNotifier<String?> customHost =
      createSetting(key: 'customHost', initialValue: null);
  late final ValueNotifier<String> homeTags =
      createSetting(key: 'homeTags', initialValue: 'score:>=20');

  late final ValueNotifier<int> tileSize =
      createSetting(key: 'tileSize', initialValue: 200);
  late final ValueNotifier<GridQuilt> quilt = createEnumSetting(
    key: 'quilt',
    initialValue: GridQuilt.square,
    values: GridQuilt.values,
  );

  late final ValueNotifier<bool> showPostInfo =
      createSetting<bool>(key: 'showPostInfo', initialValue: false);
  late final ValueNotifier<bool> showBeta =
      createSetting<bool>(key: 'showBeta', initialValue: false);
  late final ValueNotifier<bool> upvoteFavs =
      createSetting<bool>(key: 'upvoteFavs', initialValue: false);
  late final ValueNotifier<bool> muteVideos =
      createSetting<bool>(key: 'muteVideos', initialValue: true);

  late final ValueNotifier<String?> appPin =
      createSetting(key: 'appPin', initialValue: null);
  late final ValueNotifier<bool> biometricAuth =
      createSetting<bool>(key: 'biometricAuth', initialValue: false);
}
