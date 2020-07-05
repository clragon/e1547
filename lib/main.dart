import 'package:e1547/about_page.dart';
import 'package:e1547/blacklist_page.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/persistence.dart';
import 'package:e1547/pools_page.dart';
import 'package:e1547/settings_page.dart';
import 'package:flutter/services.dart';
import 'package:e1547/client.dart';
import 'package:e1547/follow_page.dart';
import 'package:e1547/login_page.dart';
import 'package:e1547/posts_page.dart';
import 'package:e1547/appinfo.dart' as appInfo;
import 'package:flutter/material.dart';
import 'package:e1547/appinfo.dart';

ValueNotifier<ThemeData> _theme = ValueNotifier(themeMap['dark']);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.renderView.automaticSystemUiAdjustment = false;
  _theme.value = themeMap[await db.theme.value];
  db.theme
      .addListener(() async => _theme.value = themeMap[await db.theme.value]);
  runApp(Main());
}

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _theme,
      builder: (context, value, child) {
        setUIColors(value);
        return MaterialApp(
          title: appInfo.appName,
          theme: value,
          routes: <String, WidgetBuilder>{
            '/': (context) => () {
                  _drawerSelection = _DrawerSelection.home;
                  return new HomePage();
                }(),
            '/hot': (context) => () {
                  _drawerSelection = _DrawerSelection.hot;
                  return new HotPage();
                }(),
            '/search': (context) => new SearchPage(),
            '/fav': (context) => () {
                  _drawerSelection = _DrawerSelection.favorites;
                  return new FavPage();
                }(),
            '/pools': (context) => () {
                  _drawerSelection = _DrawerSelection.pools;
                  return new PoolsPage();
                }(),
            '/follows': (context) => () {
                  _drawerSelection = _DrawerSelection.follows;
                  return new FollowsPage();
                }(),
            '/login': (context) => new LoginPage(),
            '/settings': (context) => new SettingsPage(),
            '/about': (context) => new AboutPage(),
            '/blacklist': (context) => new BlacklistPage(),
            '/following': (context) => new FollowingPage(),
          },
        );
      },
    );
  }
}

Map<String, ThemeData> themeMap = {
  'light': ThemeData(
    canvasColor: Colors.white,
    appBarTheme: AppBarTheme(
      color: Colors.white,
    ),
    cardColor: Colors.white,
    dialogBackgroundColor: Colors.white,
    primaryColorBrightness: Brightness.light,
    brightness: Brightness.light,
  ),
  'dark': ThemeData(
    primaryColorBrightness: Brightness.dark,
    brightness: Brightness.dark,
    primaryColor: Colors.grey[900],
    primaryColorLight: Colors.grey[900],
    primaryColorDark: Colors.grey[900],
    indicatorColor: Colors.grey[900],
    canvasColor: Colors.grey[900],
    cardColor: Colors.grey[850],
    dialogBackgroundColor: Colors.grey[850],
  ),
  'amoled': ThemeData(
    primaryColorBrightness: Brightness.dark,
    brightness: Brightness.dark,
    primaryColor: Colors.black,
    primaryColorLight: Colors.black,
    primaryColorDark: Colors.black,
    indicatorColor: Colors.black,
    canvasColor: Colors.black,
    dialogBackgroundColor: Colors.black,
    cardColor: Color.fromARGB(255, 20, 20, 20),
    accentColor: Colors.deepPurple,
  ),
  'blue': () {
    Color blueBG = Color.fromARGB(255, 2, 15, 35);
    Color blueFG = Color.fromARGB(255, 21, 47, 86);
    return ThemeData(
      primaryColorBrightness: Brightness.dark,
      brightness: Brightness.dark,
      primaryColor: blueBG,
      primaryColorLight: blueBG,
      primaryColorDark: blueBG,
      indicatorColor: blueBG,
      canvasColor: blueBG,
      cardColor: blueFG,
      dialogBackgroundColor: blueFG,
      accentColor: Colors.blue[900],
    );
  }(),
};

enum _DrawerSelection {
  home,
  hot,
  favorites,
  pools,
  follows,
}

_DrawerSelection _drawerSelection = _DrawerSelection.home;

void refreshPage(BuildContext context) {
  Map<_DrawerSelection, String> routes = {
    _DrawerSelection.home: '/',
    _DrawerSelection.hot: '/hot',
    _DrawerSelection.favorites: '/fav',
    _DrawerSelection.pools: '/pools',
    _DrawerSelection.follows: '/follows',
  };

  Navigator.of(context).pushNamedAndRemoveUntil(
      routes[_drawerSelection], (Route<dynamic> route) => false);
}

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
                          client.logout();
                          Scaffold.of(context).showSnackBar(new SnackBar(
                            duration: const Duration(seconds: 5),
                            content: new Text('Forgot login details'),
                          ));
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              '/', (Route<dynamic> route) => false);
                        })
                  ],
                );
              }
            }
            return new Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: new OutlineButton(
                child: const Text('LOGIN'),
                onPressed: () => Navigator.popAndPushNamed(context, '/login'),
              ),
            );
          },
        );
      }

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
              new Expanded(
                child: Padding(
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
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
          },
        ),
        new ListTile(
            selected: _drawerSelection == _DrawerSelection.hot,
            leading: const Icon(Icons.show_chart),
            title: const Text('Hot'),
            onTap: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/hot', (Route<dynamic> route) => false);
            }),
        new ListTile(
          leading: const Icon(Icons.search),
          title: const Text("Search"),
          onTap: () => Navigator.popAndPushNamed(context, '/search'),
        ),
        Divider(),
        new ListTile(
            selected: _drawerSelection == _DrawerSelection.favorites,
            leading: const Icon(Icons.favorite),
            title: const Text('Favorites'),
            onTap: () async {
              if (await client.hasLogin()) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/fav', (Route<dynamic> route) => false);
              } else {
                Navigator.popAndPushNamed(context, '/login');
              }
            }),
        new ListTile(
          selected: _drawerSelection == _DrawerSelection.follows,
          leading: const Icon(Icons.turned_in),
          title: const Text('Following'),
          onTap: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
                '/follows', (Route<dynamic> route) => false);
          },
        ),
        new ListTile(
          selected: _drawerSelection == _DrawerSelection.pools,
          leading: const Icon(Icons.group),
          title: const Text('Pools'),
          onTap: () {
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
          leading: FutureBuilder(
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data.length != 0) {
                int latest = int.tryParse(
                    snapshot.data[0]['version'].replaceAll('.', '') ?? 0);
                if (int.parse(appVersion.replaceAll('.', '')) < latest) {
                  return Stack(
                    children: <Widget>[
                      Icon(Icons.update),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: Container(
                          height: 10,
                          width: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return Icon(Icons.info);
                }
              } else {
                return Icon(Icons.info);
              }
            },
            future: getVersions(),
          ),
          title: const Text('About'),
          onTap: () => Navigator.popAndPushNamed(context, '/about'),
        ),
      ]),
    );
  }
}
