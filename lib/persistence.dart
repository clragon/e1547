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

import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;

import 'consts.dart' as consts;
import 'tag.dart' show Tagset;

const _HOST = 'host';
const _TAGS = 'tags';
const _HIDE_SWF = 'hide swf';

Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

Future<String> getHost() => _prefs.then((p) {
      return p.getString(_HOST) ?? consts.DEFAULT_ENDPOINT;
    });
setHost(String host) => _prefs.then((p) {
      p.setString(_HOST, host);
    });

Future<Tagset> getTags() => _prefs.then((p) {
      return new Tagset.parse(p.getString(_TAGS) ?? '');
    });
setTags(Tagset tags) => _prefs.then((p) {
      p.setString(_TAGS, tags.toString());
    });

Future<bool> getHideSwf() => _prefs.then((p) {
      return p.getBool(_HIDE_SWF) ?? false;
    });
setHideSwf(bool hideSwf) => _prefs.then((p) {
      p.setBool(_HIDE_SWF, hideSwf);
    });
