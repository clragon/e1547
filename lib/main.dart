import 'package:e1547/settings_page.dart';

import 'login_page.dart';
import 'posts_page.dart';
import 'appinfo.dart' as appInfo;
import 'package:flutter/material.dart';

// TODO: support playing mp4
// TODO: own about screen?

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appInfo.appName,
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      routes: <String, WidgetBuilder> {
        '/': (ctx) => new PostsPage(),
        '/login': (ctx) => new LoginPage(),
        '/settings': (ctx) => new SettingsPage(),
      },
    );
  }
}
