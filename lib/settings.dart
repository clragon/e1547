import 'dart:async' show Future;

import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;

final Persistence db = Persistence();

class Persistence {
  ValueNotifier<Future<String>> host;
  ValueNotifier<Future<String>> homeTags;
  ValueNotifier<Future<String>> username;
  ValueNotifier<Future<String>> apiKey;
  ValueNotifier<Future<String>> theme;
  ValueNotifier<Future<bool>> hasConsent;
  ValueNotifier<Future<List<String>>> denylist;
  ValueNotifier<Future<List<String>>> follows;

  Persistence() {
    host = createSetting<String>('host', initial: 'e926.net');
    homeTags = createSetting<String>('homeTags', initial: '');
    username = createSetting<String>('username');
    apiKey = createSetting<String>('apiKey');
    theme = createSetting<String>('theme', initial: 'dark');
    hasConsent = createSetting<bool>('hasConsent', initial: false);
    denylist = createSetting<List<String>>('blacklist', initial: []);
    follows = createSetting<List<String>>('follows', initial: []);
  }

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Type _typeify<T>() => T;

  ValueNotifier<Future<T>> createSetting<T>(
    String key, {
    T initial,
    Future<T> Function(SharedPreferences prefs) getSetting,
    Function(SharedPreferences prefs) setSetting,
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
        value = await getSetting(prefs);
      }
      return value ?? initial;
    }());

    setting.addListener(() async {
      SharedPreferences prefs = await _prefs;
      if (setSetting == null) {
        T value = await setting.value;
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
        setSetting(prefs);
      }
    });

    return setting;
  }
}
