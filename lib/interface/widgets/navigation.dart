import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/topic/topic.dart';
import 'package:e1547/user/user.dart';
import 'package:flutter/material.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

double defaultDrawerEdge(double screenWidth) => screenWidth * 0.1;

DrawerSelection drawerSelection = DrawerSelection.home;

enum DrawerSelection {
  home,
  hot,
  favorites,
  follows,
  pools,
  topics,
}

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
  '/topics': (context) => () {
        drawerSelection = DrawerSelection.topics;
        return TopicsPage();
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
          onTap: () =>
              Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false),
        ),
        ListTile(
          selected: drawerSelection == DrawerSelection.hot,
          leading: Icon(Icons.whatshot),
          title: Text('Hot'),
          onTap: () => Navigator.of(context)
              .pushNamedAndRemoveUntil('/hot', (_) => false),
        ),
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
          },
        ),
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
              .pushNamedAndRemoveUntil('/pools', (_) => false),
        ),
        if (settings.showBeta.value)
          ListTile(
            selected: drawerSelection == DrawerSelection.topics,
            leading: Icon(Icons.forum),
            title: Text('Topics'),
            onTap: () => Navigator.of(context)
                .pushNamedAndRemoveUntil('/topics', (_) => false),
          ),
        Divider(),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text('Settings'),
          onTap: () => Navigator.popAndPushNamed(context, '/settings'),
        ),
        ListTile(
          leading: DrawerUpdateIcon(),
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

class _ProfileHeaderState extends State<ProfileHeader> with LinkingMixin {
  @override
  Map<ChangeNotifier, VoidCallback> get initLinks => {
        settings.credentials: () {
          if (mounted) {
            initAvatar(context);
          }
        },
      };

  @override
  Widget build(BuildContext context) {
    Widget userNameWidget(String? name) {
      return CrossFade(
        showChild: name != null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                name ?? '...',
                style: Theme.of(context).textTheme.headline6,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        secondChild: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: OutlinedButton(
            child: Text('LOGIN'),
            onPressed: () => Navigator.popAndPushNamed(context, '/login'),
          ),
        ),
      );
    }

    return SizedBox(
      child: ValueListenableBuilder<Credentials?>(
        valueListenable: settings.credentials,
        builder: (context, value, child) => DrawerHeader(
          child: GestureDetector(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 72,
                  width: 72,
                  child: CurrentUserAvatar(),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: userNameWidget(value?.username),
                  ),
                ),
              ],
            ),
            onTap: value?.username != null
                ? () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => UserLoadingPage(value!.username),
                      ),
                    )
                : null,
          ),
        ),
      ),
    );
  }
}

class DrawerUpdateIcon extends StatefulWidget {
  @override
  _DrawerUpdateIconState createState() => _DrawerUpdateIconState();
}

class _DrawerUpdateIconState extends State<DrawerUpdateIcon> {
  Future<List<AppVersion>?> newVersions = getNewVersions();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AppVersion>?>(
      future: newVersions,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return Stack(
            children: [
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
    );
  }
}
