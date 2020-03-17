import 'package:e1547/persistence.dart';
import 'package:e1547/settings_page.dart';
import 'package:e1547/tag.dart';
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
        '/': (ctx) => new Navigation(),
        '/login': (ctx) => new LoginPage(),
        '/settings': (ctx) => new SettingsPage(),
      },
    );
  }
}

class Navigation extends StatefulWidget {
  static _NavigationState of(BuildContext context) =>
      context.findAncestorStateOfType();

  @override
  State<StatefulWidget> createState() {
    return new _NavigationState();
  }
}

class _NavigationState extends State<Navigation> {
  Widget body = new PostsPage(
      isHome: true,
      drawer: new _NavigationDrawer());

  @override
  Widget build(BuildContext context) {
    return body;
  }
}

enum _DrawerSelection {
  home,
  hot,
  favorites,
}

_DrawerSelection _drawerSelection = _DrawerSelection.home;

class _NavigationDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) {
    Widget headerWidget() {
      Widget userInfoWidget() {
        return new FutureBuilder<String>(
          future: db.username.value,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                !snapshot.hasError &&
                snapshot.hasData) {
              return new Text(
                snapshot.data,
                style: new TextStyle(fontSize: 16.0),
              );
            }
            return new RaisedButton(
              child: const Text('LOGIN'),
              onPressed: () => Navigator.popAndPushNamed(ctx, '/login'),
            );
          },
        );
      }

      // this could use the avatar post of the user.
      // however, its not reachable by the API.
      // maybe send an email to the site owners.
      // update: sent an email.
      // they'll note it down for after API update.
      return new Container(
          height: 140,
          child: new DrawerHeader(
              child: new Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const CircleAvatar(
                backgroundImage: const AssetImage('assets/icon/paw.png'),
                radius: 36.0,
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: userInfoWidget(),
              ),
            ],
          )));
    }

    return new Drawer(
      child: new ListView(children: [
        headerWidget(),
        new ListTile(
          selected: _drawerSelection == _DrawerSelection.home,
          leading: const Icon(Icons.home),
          title: const Text('Home'),
          onTap: () {
            _drawerSelection = _DrawerSelection.home;
            db.tags.value = db.homeTags.value;
            Navigation.of(ctx).setState(() {
              Navigation.of(ctx).body = new PostsPage(
                  isHome: true, drawer: this);
            });
            Navigator.pop(ctx);
          },
        ),
        new ListTile(
            selected: _drawerSelection == _DrawerSelection.hot,
            leading: const Icon(Icons.show_chart),
            title: const Text('Hot'),
            onTap: () {
              _drawerSelection = _DrawerSelection.hot;
              // appbarTitle = Text('Hot');
              db.tags.value = new Future.value(new Tagset.parse("order:rank"));
              Navigation.of(ctx).setState(() {
                Navigation.of(ctx).body =
                    new PostsPage(appbarTitle: 'Hot', drawer: this);
              });
              Navigator.pop(ctx);
            }),
        new ListTile(
            selected: _drawerSelection == _DrawerSelection.favorites,
            leading: const Icon(Icons.favorite),
            title: const Text('Favorites'),
            onTap: () async {
              _drawerSelection = _DrawerSelection.favorites;
              // appbarTitle = Text('Favorites');
              db.tags.value = new Future.value(
                  new Tagset.parse('fav:' + await db.username.value));
              Navigation.of(ctx).setState(() {
                Navigation.of(ctx).body =
                    new PostsPage(appbarTitle: 'Favorites', drawer: this);
              });
              Navigator.pop(ctx);
            }),
        Divider(),
        new ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Settings'),
          onTap: () => Navigator.popAndPushNamed(ctx, '/settings'),
        ),
        // TODO: get rid of this garbage and make own about screen.
        const AboutListTile(
          child: const Text('About'),
          icon: const Icon(Icons.help),
          applicationName: appInfo.appName,
          applicationVersion: appInfo.appVersion,
          applicationLegalese: appInfo.about,
        ),
      ]),
    );
  }
}
