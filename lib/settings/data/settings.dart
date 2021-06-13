import 'dart:async' show Future;
import 'dart:io' show File, Platform;

import 'package:e1547/client.dart';
import 'package:e1547/follow.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/settings/data/grid.dart';
import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;

import 'app_info.dart';

final Persistence db = Persistence();

class Persistence {
  ValueNotifier<Future<String>> host;
  ValueNotifier<Future<String>> customHost;
  ValueNotifier<Future<String>> homeTags;
  ValueNotifier<Future<bool>> hideGallery;
  ValueNotifier<Future<Credentials>> credentials;
  ValueNotifier<Future<AppTheme>> theme;
  ValueNotifier<Future<List<String>>> denylist;
  ValueNotifier<Future<List<Follow>>> follows;
  ValueNotifier<Future<bool>> followsSplit;
  ValueNotifier<Future<int>> tileSize;
  ValueNotifier<Future<GridState>> stagger;

  Persistence() {
    host = createSetting<String>('currentHost', initial: 'e926.net');
    customHost = createSetting<String>('customHost');
    homeTags = createSetting<String>('homeTags', initial: '');
    File nomedia = File(
        '${Platform.environment['EXTERNAL_STORAGE']}/Pictures/$appName/.nomedia');
    hideGallery = createSetting<bool>('hideGallery',
        getSetting: (prefs, key) => Platform.isAndroid
            ? Future.value(nomedia.existsSync())
            : Future.value(false),
        setSetting: (prefs, key, value) => Platform.isAndroid
            ? value
                ? nomedia.writeAsString('')
                : nomedia.delete()
            : () {});
    credentials = createSetting('credentials', getSetting: (prefs, key) async {
      String value = prefs.getString(key);
      if (value != null) {
        return Credentials.fromJson(value);
      } else {
        return null;
      }
    }, setSetting: (prefs, key, value) {
      if (value == null) {
        prefs.remove(key);
      } else {
        prefs.setString(key, value.toJson());
      }
    });
    theme = createStringSetting<AppTheme>('theme',
        initial: appThemeMap.keys.elementAt(1), values: AppTheme.values);
    denylist = createSetting<List<String>>('blacklist', initial: []);
    follows = createSetting<List<Follow>>('follows', initial: [],
        getSetting: (prefs, key) async {
      try {
        List<String> value = prefs.getStringList(key);
        if (value != null) {
          return value.map((e) => Follow.fromJson(e)).toList();
        } else {
          return null;
        }
      } on TypeError {
        return prefs
            .getStringList(key)
            .map((e) => Follow.fromString(e))
            .toList();
      }
    }, setSetting: (prefs, key, value) async {
      await prefs.setStringList(key, value.map((e) => e.toJson()).toList());
    });
    followsSplit = createSetting<bool>('followsSplit', initial: true);
    tileSize = createSetting('tileSize', initial: 200);
    stagger = createStringSetting(
      'stagger',
      initial: GridState.square,
      values: GridState.values,
    );
  }

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Type _typeify<T>() => T;

  ValueNotifier<Future<T>> createSetting<T>(
    String key, {
    T initial,
    Future<T> Function(SharedPreferences prefs, String key) getSetting,
    Function(SharedPreferences prefs, String key, T value) setSetting,
  }) {
    ValueNotifier<Future<T>> setting = ValueNotifier<Future<T>>(() async {
      SharedPreferences prefs = await _prefs;
      T value;
      if (getSetting == null) {
        switch (T) {
          case String:
            value = prefs.getString(key) as T;
            break;
          case bool:
            value = prefs.getBool(key) as T;
            break;
          case int:
            value = prefs.getInt(key) as T;
            break;
          default:
            if (T == _typeify<List<String>>()) {
              value = prefs.getStringList(key) as T;
            }
        }
      } else {
        value = await getSetting(prefs, key);
      }
      return value ?? initial;
    }());

    setting.addListener(() async {
      SharedPreferences prefs = await _prefs;
      T value = await setting.value;
      if (setSetting == null) {
        switch (T) {
          case String:
            prefs.setString(key, value as String);
            break;
          case bool:
            prefs.setBool(key, value as bool);
            break;
          case int:
            prefs.setInt(key, value as int);
            break;
          default:
            if (T == _typeify<List<String>>()) {
              prefs.setStringList(key, value as List);
            }
        }
      } else {
        setSetting(prefs, key, value);
      }
    });

    return setting;
  }

  ValueNotifier<Future<T>> createStringSetting<T>(
    String key, {
    T initial,
    List<T> values,
  }) =>
      createSetting(
        key,
        initial: initial,
        getSetting: (prefs, key) async {
          String value = prefs.getString(key);
          return values.singleWhere((element) => element.toString() == value,
              orElse: () => null);
        },
        setSetting: (prefs, key, value) {
          prefs.setString(key, value.toString());
        },
      );
}
