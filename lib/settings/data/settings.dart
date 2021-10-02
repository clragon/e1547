import 'dart:async' show Future;

import 'package:collection/collection.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/data/grid.dart';
import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;

final Persistence settings = Persistence();

typedef Serializer<T> = Future<bool> Function(String key, T value);
typedef Deserializer<T> = T? Function(String key);

typedef GetSetting<T> = T? Function(SharedPreferences prefs, String key);
typedef SetSetting<T> = void Function(
    SharedPreferences prefs, String key, T? value);

class Persistence {
  late final ValueNotifier<String> host;
  late final ValueNotifier<String?> customHost;
  late final ValueNotifier<String> homeTags;
  late final ValueNotifier<Credentials?> credentials;
  late final ValueNotifier<AppTheme> theme;
  late final ValueNotifier<List<String>> denylist;
  late final ValueNotifier<List<Follow>> follows;
  late final ValueNotifier<bool> followsSplit;
  late final ValueNotifier<int> tileSize;
  late final ValueNotifier<GridState> stagger;
  late final ValueNotifier<bool> postInfo;
  late final ValueNotifier<bool> beta;

  late final SharedPreferences prefs;
  late final Future<void> initialized;

  Persistence() {
    initialized = initialize();
  }

  Future<void> initialize() async {
    prefs = await SharedPreferences.getInstance();
    host = createSetting(key: 'currentHost', initial: 'e926.net');
    customHost = createSetting(key: 'customHost', initial: null);
    homeTags = createSetting(key: 'homeTags', initial: '');
    credentials = createSetting(
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
    theme = createStringSetting(
        key: 'theme',
        initial: appThemeMap.keys.elementAt(1),
        values: AppTheme.values);
    denylist = createSetting(key: 'blacklist', initial: []);
    follows = createSetting(
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
        setSetting: (prefs, key, value) async =>
            prefs.setStringList(key, value!.map((e) => e.toJson()).toList()));
    followsSplit = createSetting(key: 'followsSplit', initial: true);
    tileSize = createSetting(key: 'tileSize', initial: 200);
    stagger = createStringSetting(
      key: 'stagger',
      initial: GridState.square,
      values: GridState.values,
    );
    postInfo = createSetting<bool>(key: 'postInfo', initial: false);
    beta = createSetting<bool>(key: 'beta', initial: false);
  }

  Type typeify<T>() => T;

  bool typeMatch<T, E>() {
    return T == E || typeify<T?>() == E;
  }

  Deserializer<T>? getDeserializer<T>(SharedPreferences prefs) {
    if (typeMatch<String, T>()) {
      return prefs.getString as Deserializer<T>;
    }
    if (typeMatch<int, T>()) {
      return prefs.getInt as Deserializer<T>;
    }
    if (typeMatch<bool, T>()) {
      return prefs.getBool as Deserializer<T>;
    }
    if (T == typeify<List<String>>() || T == typeify<List<String>?>()) {
      return prefs.getStringList as Deserializer<T>;
    }
  }

  Serializer<T>? getSerializer<T>(SharedPreferences prefs) {
    if (typeMatch<String, T>()) {
      return (String key, T? value) => prefs.setString(key, value as String);
    }
    if (typeMatch<int, T>()) {
      return (String key, T? value) => prefs.setInt(key, value as int);
    }
    if (typeMatch<bool, T>()) {
      return (String key, T? value) => prefs.setBool(key, value as bool);
    }
    if (T == typeify<List<String>>() || T == typeify<List<String>?>()) {
      return (String key, T? value) =>
          prefs.setStringList(key, value as List<String>);
    }
  }

  ValueNotifier<T> createSetting<T>({
    required String key,
    required T initial,
    GetSetting<T>? getSetting,
    SetSetting<T>? setSetting,
  }) {
    ValueNotifier<T> setting = ValueNotifier<T>(() {
      T? value;
      if (getSetting == null) {
        Deserializer? deserialize = getDeserializer<T>(prefs);
        value = deserialize?.call(key) as T?;
      } else {
        value = getSetting(prefs, key);
      }
      return value ?? initial;
    }());

    setting.addListener(() async {
      T value = setting.value;
      if (setSetting == null) {
        if (value == null) {
          prefs.remove(key);
        } else {
          Serializer<T>? serialize = getSerializer<T>(prefs);
          await serialize?.call(key, value);
        }
      } else {
        setSetting(prefs, key, value);
      }
    });

    return setting;
  }

  ValueNotifier<T> createStringSetting<T>({
    required String key,
    required T initial,
    List<T>? values,
  }) =>
      createSetting(
        key: key,
        initial: initial,
        getSetting: (prefs, key) {
          String? value = prefs.getString(key);
          return values!
              .singleWhereOrNull((element) => element.toString() == value);
        },
        setSetting: (prefs, key, value) =>
            prefs.setString(key, value.toString()),
      );
}
