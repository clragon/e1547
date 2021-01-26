import 'package:cached_network_image/cached_network_image.dart';
import 'package:e1547/client.dart';
import 'package:e1547/pool.dart';
import 'package:e1547/post.dart';
import 'package:e1547/settings.dart';
import 'package:e1547/thread.dart';
import 'package:flutter/material.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

enum DrawerSelection {
  home,
  hot,
  favorites,
  follows,
  pools,
  forum,
}

DrawerSelection drawerSelection = DrawerSelection.home;

Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
  '/': (context) => () {
        drawerSelection = DrawerSelection.home;
        return HomePage();
      }(),
  '/hot': (context) => () {
        drawerSelection = DrawerSelection.hot;
        return HotPage();
      }(),
  '/search': (context) => SearchPage(),
  '/fav': (context) => () {
        drawerSelection = DrawerSelection.favorites;
        return FavPage();
      }(),
  '/follows': (context) => () {
        drawerSelection = DrawerSelection.follows;
        return FollowsPage();
      }(),
  '/pools': (context) => () {
        drawerSelection = DrawerSelection.pools;
        return PoolsPage();
      }(),
  '/forum': (context) => () {
        drawerSelection = DrawerSelection.forum;
        return ThreadsPage();
      }(),
  '/login': (context) => LoginPage(),
  '/settings': (context) => SettingsPage(),
  '/about': (context) => AboutPage(),
  '/blacklist': (context) => DenyListPage(),
  '/following': (context) => FollowingPage(),
};

ProfileHeader header = ProfileHeader();

class NavigationDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(physics: BouncingScrollPhysics(), children: [
        header,
        ListTile(
            selected: drawerSelection == DrawerSelection.home,
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () => Navigator.of(context)
                .pushNamedAndRemoveUntil('/', (_) => false)),
        ListTile(
            selected: drawerSelection == DrawerSelection.hot,
            leading: Icon(Icons.whatshot),
            title: Text('Hot'),
            onTap: () => Navigator.of(context)
                .pushNamedAndRemoveUntil('/hot', (_) => false)),
        ListTile(
          leading: Icon(Icons.search),
          title: Text("Search"),
          onTap: () => Navigator.popAndPushNamed(context, '/search'),
        ),
        Divider(),
        ListTile(
            selected: drawerSelection == DrawerSelection.favorites,
            leading: Icon(Icons.favorite),
            title: Text('Favorites'),
            onTap: () async {
              if (await client.hasLogin) {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/fav', (_) => false);
              } else {
                Navigator.popAndPushNamed(context, '/login');
              }
            }),
        ListTile(
          selected: drawerSelection == DrawerSelection.follows,
          leading: Icon(Icons.turned_in),
          title: Text('Following'),
          onTap: () => Navigator.of(context)
              .pushNamedAndRemoveUntil('/follows', (_) => false),
        ),
        // Divider(),
        ListTile(
            selected: drawerSelection == DrawerSelection.pools,
            leading: Icon(Icons.collections),
            title: Text('Pools'),
            onTap: () => Navigator.of(context)
                .pushNamedAndRemoveUntil('/pools', (_) => false)),
        /*
        ListTile(
            selected: drawerSelection == DrawerSelection.forum,
            leading: Icon(Icons.group),
            title: Text('Forum'),
            onTap: () => Navigator.of(context)
                .pushNamedAndRemoveUntil('/forum', (_) => false)),
         */
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
            },
            future: getNewVersions(),
          ),
          title: Text('About'),
          onTap: () => Navigator.popAndPushNamed(context, '/about'),
        ),
      ]),
    );
  }
}

class ProfileHeader extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ProfileHeaderState();
  }
}

class _ProfileHeaderState extends State<ProfileHeader> {
  @override
  void initState() {
    super.initState();
    db.credentials.addListener(initUser);
    initUser();
  }

  @override
  void dispose() {
    super.dispose();
    db.credentials.removeListener(initUser);
  }

  @override
  Widget build(BuildContext context) {
    Widget userNameWidget() {
      return ValueListenableBuilder(
        valueListenable: userName,
        builder: (context, value, child) {
          if (value != null) {
            return Row(
              children: <Widget>[
                Expanded(
                    child: Text(
                  value,
                  style: TextStyle(fontSize: 16.0),
                  overflow: TextOverflow.ellipsis,
                )),
                IconButton(
                    icon: Icon(Icons.exit_to_app),
                    onPressed: () {
                      client.logout();
                      String msg = 'Forgot login details';
                      if (value != null) {
                        msg = msg + ' for $value';
                      }

                      Scaffold.of(context).showSnackBar(SnackBar(
                        duration: Duration(seconds: 5),
                        content: Text(msg),
                      ));
                      Navigator.of(context).pop();
                    })
              ],
            );
          } else {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: OutlineButton(
                child: Text('LOGIN'),
                onPressed: () => Navigator.popAndPushNamed(context, '/login'),
              ),
            );
          }
        },
      );
    }

    Widget userAvatarWidget() {
      return ValueListenableBuilder(
        valueListenable: userAvatar,
        builder: (context, value, child) {
          return CircleAvatar(
            backgroundImage: value == null
                ? AssetImage('assets/icon/app/paw.png')
                : CachedNetworkImageProvider(value),
            radius: 36.0,
          );
        },
      );
    }

    return Container(
        height: 140,
        child: DrawerHeader(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            userAvatarWidget(),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: userNameWidget(),
              ),
            ),
          ],
        )));
  }
}

final ValueNotifier<String> userName = ValueNotifier(null);
final ValueNotifier<String> userAvatar = ValueNotifier(null);

void initUser({BuildContext context}) {
  db.credentials.value.then((credentials) {
    userName.value = credentials?.username;
    if (userName.value != null) {
      client.avatar.then((avatar) {
        userAvatar.value = avatar;
        if (avatar != null && context != null) {
          precacheImage(CachedNetworkImageProvider(avatar), context);
        }
      });
    } else {
      userAvatar.value = null;
    }
  });
}
