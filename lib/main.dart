import 'package:e1547/about_page.dart';
import 'package:e1547/appInfo.dart';
import 'package:e1547/blacklist_page.dart';
import 'package:e1547/client.dart';
import 'package:e1547/follow_page.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/login_page.dart';
import 'package:e1547/persistence.dart';
import 'package:e1547/pools_page.dart';
import 'package:e1547/posts_page.dart';
import 'package:e1547/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
          title: appName,
          theme: value,
          routes: <String, WidgetBuilder>{
            '/': (context) => () {
                  _drawerSelection = _DrawerSelection.home;
                  return HomePage();
                }(),
            '/hot': (context) => () {
                  _drawerSelection = _DrawerSelection.hot;
                  return HotPage();
                }(),
            '/search': (context) => SearchPage(),
            '/fav': (context) => () {
                  _drawerSelection = _DrawerSelection.favorites;
                  return FavPage();
                }(),
            '/pools': (context) => () {
                  _drawerSelection = _DrawerSelection.pools;
                  return PoolsPage();
                }(),
            '/follows': (context) => () {
                  _drawerSelection = _DrawerSelection.follows;
                  return FollowsPage();
                }(),
            '/login': (context) => LoginPage(),
            '/settings': (context) => SettingsPage(),
            '/about': (context) => AboutPage(),
            '/blacklist': (context) => BlacklistPage(),
            '/following': (context) => FollowingPage(),
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
    primaryColor: Colors.grey[900],
    primaryColorLight: Colors.grey[900],
    primaryColorDark: Colors.grey[900],
    indicatorColor: Colors.grey[900],
    canvasColor: Colors.grey[900],
    cardColor: Colors.grey[850],
    dialogBackgroundColor: Colors.grey[850],
    primaryColorBrightness: Brightness.dark,
    brightness: Brightness.dark,
  ),
  'amoled': ThemeData(
    primaryColor: Colors.black,
    primaryColorLight: Colors.black,
    primaryColorDark: Colors.black,
    indicatorColor: Colors.black,
    canvasColor: Colors.black,
    dialogBackgroundColor: Colors.black,
    cardColor: Color.fromARGB(255, 20, 20, 20),
    accentColor: Colors.deepPurple,
    primaryColorBrightness: Brightness.dark,
    brightness: Brightness.dark,
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
  @override
  Widget build(BuildContext context) {
    Widget headerWidget() {
      Widget userInfoWidget() {
        return FutureBuilder<String>(
          future: db.username.value,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                !snapshot.hasError &&
                snapshot.hasData) {
              if (snapshot.data != null) {
                return Row(
                  children: <Widget>[
                    Expanded(
                        child: Text(
                      snapshot.data,
                      style: TextStyle(fontSize: 16.0),
                      overflow: TextOverflow.ellipsis,
                    )),
                    IconButton(
                        icon: Icon(Icons.exit_to_app),
                        onPressed: () {
                          client.logout();
                          Scaffold.of(context).showSnackBar(SnackBar(
                            duration: Duration(seconds: 5),
                            content: Text('Forgot login details'),
                          ));
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              '/', (Route<dynamic> route) => false);
                        })
                  ],
                );
              }
            }
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: OutlineButton(
                child: Text('LOGIN'),
                onPressed: () => Navigator.popAndPushNamed(context, '/login'),
              ),
            );
          },
        );
      }

      // TODO: add user profile picture
      return Container(
          height: 140,
          child: DrawerHeader(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundImage: AssetImage('assets/icon/app/paw.png'),
                radius: 36.0,
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: userInfoWidget(),
                ),
              ),
            ],
          )));
    }

    return Drawer(
      child: ListView(children: [
        headerWidget(),
        ListTile(
          selected: _drawerSelection == _DrawerSelection.home,
          leading: Icon(Icons.home),
          title: Text('Home'),
          onTap: () {
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
          },
        ),
        ListTile(
            selected: _drawerSelection == _DrawerSelection.hot,
            leading: Icon(Icons.show_chart),
            title: Text('Hot'),
            onTap: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/hot', (Route<dynamic> route) => false);
            }),
        ListTile(
          leading: Icon(Icons.search),
          title: Text("Search"),
          onTap: () => Navigator.popAndPushNamed(context, '/search'),
        ),
        Divider(),
        ListTile(
            selected: _drawerSelection == _DrawerSelection.favorites,
            leading: Icon(Icons.favorite),
            title: Text('Favorites'),
            onTap: () async {
              if (await client.hasLogin()) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/fav', (Route<dynamic> route) => false);
              } else {
                Navigator.popAndPushNamed(context, '/login');
              }
            }),
        ListTile(
          selected: _drawerSelection == _DrawerSelection.follows,
          leading: Icon(Icons.turned_in),
          title: Text('Following'),
          onTap: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
                '/follows', (Route<dynamic> route) => false);
          },
        ),
        ListTile(
          selected: _drawerSelection == _DrawerSelection.pools,
          leading: Icon(Icons.group),
          title: Text('Pools'),
          onTap: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
                '/pools', (Route<dynamic> route) => false);
          },
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text('Settings'),
          onTap: () => Navigator.popAndPushNamed(context, '/settings'),
        ),
        ListTile(
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
          title: Text('About'),
          onTap: () => Navigator.popAndPushNamed(context, '/about'),
        ),
      ]),
    );
  }
}
