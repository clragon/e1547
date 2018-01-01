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

import 'package:flutter/material.dart' show MaterialApp, ThemeData;
import 'package:flutter/widgets.dart' as widgets;
import 'package:logging/logging.dart' show Level, Logger;

import 'consts.dart' as consts;
import 'login_page.dart' show LoginPage;
import 'posts_page.dart' show PostsPage;
import 'settings_page.dart' show SettingsPageScaffold;

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((rec) {
    if (rec.object == null) {
      print('${rec.level.name}: ${rec.time}: ${rec.message}');
    } else {
      print('${rec.level.name}: ${rec.time}: ${rec.message}: ${rec.object}');
    }
  });

  widgets.runApp(new MaterialApp(
      title: consts.appName,
      theme: new ThemeData.dark(),
      routes: <String, widgets.WidgetBuilder>{
        '/': (ctx) => new PostsPage(),
        '/login': (ctx) => new LoginPage(),
        '/settings': (ctx) => new SettingsPageScaffold(),
      }));
}
