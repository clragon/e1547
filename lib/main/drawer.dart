import 'package:e1547/about/app_info.dart';
import 'package:e1547/services/client.dart';
import 'package:e1547/services/github.dart';
import 'package:flutter/material.dart';

import 'components/header.dart';

enum DrawerSelection {
  home,
  hot,
  favorites,
  follows,
  pools,
  forum,
}

DrawerSelection drawerSelection = DrawerSelection.home;

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
          onTap: () {
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
          },
        ),
        ListTile(
            selected: drawerSelection == DrawerSelection.hot,
            leading: Icon(Icons.whatshot),
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
            selected: drawerSelection == DrawerSelection.favorites,
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
          selected: drawerSelection == DrawerSelection.follows,
          leading: Icon(Icons.turned_in),
          title: Text('Following'),
          onTap: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
                '/follows', (Route<dynamic> route) => false);
          },
        ),
        // Divider(),
        ListTile(
          selected: drawerSelection == DrawerSelection.pools,
          leading: Icon(Icons.collections),
          title: Text('Pools'),
          onTap: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
                '/pools', (Route<dynamic> route) => false);
          },
        ),
        /*
        ListTile(
          selected: _drawerSelection == _DrawerSelection.forum,
          leading: Icon(Icons.group),
          title: Text('Forum'),
          onTap: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
                '/forum', (Route<dynamic> route) => false);
          },
        ),
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
