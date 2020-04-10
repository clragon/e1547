import 'package:e1547/about_page.dart';
import 'package:e1547/persistence.dart';
import 'package:e1547/pools_page.dart';
import 'package:e1547/settings_page.dart';
import 'package:flutter/services.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'client.dart';
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
        '/': (context) => new HomePage(),
        '/hot': (context) => new HotPage(),
        '/fav': (context) => new FavPage(),
        '/pools': (context) => new PoolsPage(),
        '/login': (context) => new LoginPage(),
        '/settings': (context) => new SettingsPage(),
        '/about': (context) => new AboutPage(),
      },
    );
  }
}

enum _DrawerSelection {
  home,
  hot,
  favorites,
  pools,
}

_DrawerSelection _drawerSelection = _DrawerSelection.home;

class NavigationDrawer extends StatelessWidget {
  const NavigationDrawer();

  @override
  Widget build(BuildContext context) {
    Widget headerWidget() {
      Widget userInfoWidget() {
        return new FutureBuilder<String>(
          future: db.username.value,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                !snapshot.hasError &&
                snapshot.hasData) {
              if (snapshot.data != null) {
                return new Row(
                  children: <Widget>[
                    new Expanded(
                        child: new Text(
                          snapshot.data,
                          style: new TextStyle(fontSize: 16.0),
                          overflow: TextOverflow.ellipsis,
                        )),
                    new IconButton(
                        icon: new Icon(Icons.exit_to_app),
                        onPressed: () {
                            db.username.value = new Future.value(null);
                            db.apiKey.value = new Future.value(null);

                            String msg = 'Forgot login details';

                            Scaffold.of(context).showSnackBar(new SnackBar(
                              duration: const Duration(seconds: 5),
                              content: new Text(msg),
                            ));
                            _drawerSelection = _DrawerSelection.home;
                            Navigator.of(context)
                                .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
                          }
                    )
                  ],
                );
              }
            }
            return new Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: new RaisedButton(
                  child: const Text('LOGIN'),
                  onPressed: () => Navigator.popAndPushNamed(context, '/login'),
                ),
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
              new Expanded(child: Padding(
                padding: EdgeInsets.all(20),
                child: userInfoWidget(),
              ),
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
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
          },
        ),
        new ListTile(
            selected: _drawerSelection == _DrawerSelection.hot,
            leading: const Icon(Icons.show_chart),
            title: const Text('Hot'),
            onTap: () {
              _drawerSelection = _DrawerSelection.hot;
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/hot', (Route<dynamic> route) => false);
            }),
        new ListTile(
            selected: _drawerSelection == _DrawerSelection.favorites,
            leading: const Icon(Icons.favorite),
            title: const Text('Favorites'),
            onTap: () async {
              if (await client.isLoggedIn()) {
                _drawerSelection = _DrawerSelection.favorites;
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/fav', (Route<dynamic> route) => false);
              } else {
                Navigator.popAndPushNamed(context, '/login');
              }
            }),
        Divider(),
        new ListTile(
          selected: _drawerSelection == _DrawerSelection.pools,
          leading: const Icon(Icons.group),
          title: const Text('Pools'),
          onTap: () {
            _drawerSelection = _DrawerSelection.pools;
            Navigator.of(context).pushNamedAndRemoveUntil(
                '/pools', (Route<dynamic> route) => false);
          },
        ),
        Divider(),
        new ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Settings'),
          onTap: () => Navigator.popAndPushNamed(context, '/settings'),
        ),
        new ListTile(
          leading: const Icon(Icons.info),
          title: const Text('About'),
          onTap: () => Navigator.popAndPushNamed(context, '/about'),
        ),
      ]),
    );
  }
}
