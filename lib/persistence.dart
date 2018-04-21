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

import 'package:flutter/foundation.dart' show ValueNotifier;

import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;

import 'consts.dart' as consts;
import 'tag.dart' show Tagset;

typedef T _SharedPreferencesReceiver<T>(SharedPreferences prefs);

final Persistence db = new Persistence();

class Persistence {
  ValueNotifier<Future<String>> host;
  ValueNotifier<Future<Tagset>> tags;
  ValueNotifier<Future<bool>> hideSwf;
  ValueNotifier<Future<String>> username;
  ValueNotifier<Future<String>> apiKey;
  ValueNotifier<Future<int>> numColumns;

  Persistence() {
    host = _makeNotifier((p) => p.getString('host') ?? consts.defaultEndpoint);
    host.addListener(_saveString('host', host));

    tags = _makeNotifier((p) => new Tagset.parse(p.getString('tags') ?? ''));
    tags.addListener(_saveString('tags', tags));

    hideSwf = _makeNotifier((p) => p.getBool('hideSwf') ?? false);
    hideSwf.addListener(_saveBool('hideSwf', hideSwf));

    username = _makeNotifier((p) => p.getString('username'));
    username.addListener(_saveString('username', username));

    apiKey = _makeNotifier((p) => p.getString('apiKey'));
    apiKey.addListener(_saveString('apiKey', apiKey));

    numColumns = _makeNotifier((p) => p.getInt('numColumns') ?? 3);
    numColumns.addListener(_saveInt('numColumns', numColumns));
  }

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  ValueNotifier<Future<T>> _makeNotifier<T>(
      _SharedPreferencesReceiver<T> receiver) {
    return new ValueNotifier(_prefs.then(receiver));
  }

  Function() _saveString(String key, ValueNotifier<Future<dynamic>> notifier) {
    return () async {
      var val = await notifier.value;
      (await _prefs).setString(key, val != null ? val.toString() : null);
    };
  }

  Function() _saveBool(String key, ValueNotifier<Future<bool>> notifier) {
    return () async {
      (await _prefs).setBool(key, await notifier.value);
    };
  }

  Function() _saveInt(String key, ValueNotifier<Future<int>> notifier) {
    return () async {
      (await _prefs).setInt(key, await notifier.value);
    };
  }
}
