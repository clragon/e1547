import 'package:e1547/settings_page.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'login_page.dart';
import 'posts_page.dart';
import 'appinfo.dart' as appInfo;
import 'package:flutter/material.dart';

void main() => runApp(Main());

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = ThemeData(
      brightness: Brightness.dark,
    );

    // FlutterStatusbarcolor.setStatusBarColor();
    FlutterStatusbarcolor.setNavigationBarColor(theme.canvasColor);
    FlutterStatusbarcolor.setNavigationBarWhiteForeground(
        theme.brightness == Brightness.dark);
    FlutterStatusbarcolor.setStatusBarWhiteForeground(
        theme.brightness == Brightness.dark);

    return MaterialApp(
      title: appInfo.appName,
      theme: theme,
      routes: <String, WidgetBuilder>{
        '/': (ctx) => new HomePage(),
        '/hot': (ctx) => new HotPage(),
        '/fav': (ctx) => new FavPage(),
        '/login': (ctx) => new LoginPage(),
        '/settings': (ctx) => new SettingsPage(),
      },
    );
  }
}

