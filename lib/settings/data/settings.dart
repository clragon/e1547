import 'dart:async' show Future;
import 'dart:io' show File, Platform;

import 'package:e1547/client.dart';
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
  ValueNotifier<Future<String>> theme;
  ValueNotifier<Future<List<String>>> denylist;
  ValueNotifier<Future<List<String>>> follows;
  ValueNotifier<Future<int>> tileSize;
  ValueNotifier<Future<bool>> staggered;

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
      String value = await prefs.get(key);
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
    theme = createSetting<String>('theme', initial: 'dark');
    denylist = createSetting<List<String>>('blacklist', initial: []);
    follows = createSetting<List<String>>('follows', initial: []);
    tileSize = createSetting('tileSize', initial: 200);
    staggered = createSetting('staggered', initial: false);
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
}
