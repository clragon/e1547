import 'dart:async' show Future;

import 'package:flutter/foundation.dart' show ValueNotifier;

import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;

import 'package:e1547/tag.dart' show Tagset;

typedef T _SharedPreferencesReceiver<T>(SharedPreferences prefs);

final Persistence db = Persistence();

class Persistence {
  ValueNotifier<Future<String>> host;
  ValueNotifier<Future<Tagset>> homeTags;
  ValueNotifier<Future<String>> username;
  ValueNotifier<Future<String>> apiKey;
  ValueNotifier<Future<String>> theme;
  ValueNotifier<Future<bool>> showWebm;
  ValueNotifier<Future<bool>> hasConsent;
  ValueNotifier<Future<List<String>>> blacklist;
  ValueNotifier<Future<List<String>>> follows;

  Persistence() {
    host = _makeNotifier((p) => p.getString('host') ?? 'e926.net');
    host.addListener(_saveString('host', host));

    homeTags =
        _makeNotifier((p) => Tagset.parse(p.getString('homeTags') ?? ''));
    homeTags.addListener(_saveString('homeTags', homeTags));

    username = _makeNotifier((p) => p.getString('username'));
    username.addListener(_saveString('username', username));

    apiKey = _makeNotifier((p) => p.getString('apiKey'));
    apiKey.addListener(_saveString('apiKey', apiKey));

    theme = _makeNotifier((p) => p.getString('theme') ?? 'dark');
    theme.addListener(_saveString('theme', theme));

    showWebm = _makeNotifier((p) => p.getBool('showWebm') ?? false);
    showWebm.addListener(_saveBool('showWebm', showWebm));

    hasConsent = _makeNotifier((p) => p.getBool('hasConsent') ?? false);
    hasConsent.addListener(_saveBool('hasConsent', hasConsent));

    blacklist = _makeNotifier((p) => p.getStringList('blacklist') ?? []);
    blacklist.addListener(_saveList('blacklist', blacklist));

    follows = _makeNotifier((p) => p.getStringList('follows') ?? []);
    follows.addListener(_saveList('follows', follows));
  }

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  ValueNotifier<Future<T>> _makeNotifier<T>(
      _SharedPreferencesReceiver<T> receiver) {
    return ValueNotifier(_prefs.then(receiver));
  }

  Function() _saveString(String key, ValueNotifier<Future<dynamic>> notifier) {
    return () async {
      var val = await notifier.value;
      (await _prefs).setString(key, val != null ? val.toString() : null);
    };
  }

  Function() _saveList(
      String key, ValueNotifier<Future<List<String>>> notifier) {
    return () async {
      (await _prefs).setStringList(key, await notifier.value);
    };
  }

  Function() _saveBool(String key, ValueNotifier<Future<bool>> notifier) {
    return () async {
      (await _prefs).setBool(key, await notifier.value);
    };
  }

  // ignore: unused_element
  Function() _saveInt(String key, ValueNotifier<Future<int>> notifier) {
    return () async {
      (await _prefs).setInt(key, await notifier.value);
    };
  }
}
