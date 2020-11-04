import 'dart:async' show Future;
import 'dart:io' show Platform;

import 'package:e1547/client.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/settings.dart' show db;
import 'package:flutter/material.dart';

import 'main.dart';

class SettingsPage extends StatefulWidget {
  @override
  State createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String currentHost;
  String customHost;
  String username;
  String theme;
  bool useCustomHost = false;
  bool hideGallery = false;

  @override
  void initState() {
    super.initState();
    db.host.value.then((a) async {
      currentHost = a;
      useCustomHost = currentHost == await db.customHost.value;
      setState(() {});
    });
    db.host.addListener(() async {
      currentHost = await db.host.value;
      useCustomHost = currentHost == await db.customHost.value;
      setState(() {});
    });
    db.customHost.value.then((a) => setState(() => customHost = a));
    db.customHost.addListener(() async {
      customHost = await db.customHost.value;
      setState(() {});
    });
    db.username.value.then((a) => setState(() => username = a));
    db.theme.value.then((a) => setState(() => theme = a));
    db.theme.addListener(() async {
      theme = await db.theme.value;
      setState(() {});
    });
    db.hideGallery.value.then((a) => setState(() => hideGallery = a));
    db.hideGallery.addListener(() async {
      hideGallery = await db.hideGallery.value;
      setState(() {});
    });
  }

  Function() _onTapSignOut(BuildContext context) {
    return () async {
      String name = await db.username.value;
      db.username.value = Future.value(null);
      db.apiKey.value = Future.value(null);

      String msg = 'Forgot login details';
      if (name != null) {
        msg = msg + ' for $name';
      }

      Scaffold.of(context).showSnackBar(SnackBar(
        duration: Duration(seconds: 2),
        content: Text(msg),
      ));

      setState(() {
        username = null;
      });
    };
  }

  Widget settingsHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 72, bottom: 8, top: 8, right: 16),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).accentColor,
          fontSize: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyWidgetBuilder(BuildContext context) {
      return Container(
        padding: EdgeInsets.all(10.0),
        child: ListView(
          physics: BouncingScrollPhysics(),
          children: [
            settingsHeader('Posts'),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onLongPress: () => setCustomHost(context),
              child: SwitchListTile(
                title: Text('Use custom host'),
                subtitle: Text(currentHost ?? ' '),
                secondary: Icon(Icons.warning),
                value: useCustomHost,
                onChanged: (value) async {
                  if (customHost == null) {
                    await setCustomHost(context);
                  }
                  if (customHost != null) {
                    db.host.value =
                        Future.value(value ? customHost : 'e926.net');
                  }
                },
              ),
            ),
            Platform.isAndroid
                ? SwitchListTile(
                    title: Text('Hide in gallery'),
                    subtitle: hideGallery
                        ? Text('Downloads are hidden')
                        : Text('Downloads are shown'),
                    secondary: Icon(Icons.image),
                    value: hideGallery,
                    onChanged: (hide) {
                      db.hideGallery.value = Future.value(hide);
                      setState(() {});
                    })
                : Container(),
            Divider(),
            settingsHeader('Display'),
            ListTile(
              title: Text('Theme'),
              subtitle: Text(theme ?? ' '),
              leading: Icon(Icons.brightness_6),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return SimpleDialog(
                        title: Text('Theme'),
                        children: <Widget>[
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: () {
                              List<Widget> themeList = [];
                              for (String theme in themeMap.keys) {
                                themeList.add(ListTile(
                                  title: Text(theme),
                                  trailing: Container(
                                    height: 36,
                                    width: 36,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                      color: themeMap[theme].canvasColor,
                                      border: Border.all(
                                        color:
                                            Theme.of(context).iconTheme.color,
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    db.theme.value = Future.value(theme);
                                    Navigator.of(context).pop();
                                  },
                                ));
                              }
                              return themeList;
                            }(),
                          )
                        ],
                      );
                    });
              },
            ),
            Divider(),
            settingsHeader('Listing'),
            ListTile(
              title: Text('Blacklist'),
              leading: Icon(Icons.block),
              onTap: () => Navigator.pushNamed(context, '/blacklist'),
            ),
            ListTile(
              title: Text('Following'),
              leading: Icon(Icons.turned_in),
              onTap: () => Navigator.pushNamed(context, '/following'),
            ),
            Divider(),
            settingsHeader('Account'),
            FutureBuilder(
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data) {
                    return ListTile(
                      title: Text('Sign out'),
                      subtitle: Text(username ?? ' '),
                      leading: Icon(Icons.exit_to_app),
                      onTap: _onTapSignOut(context),
                    );
                  } else {
                    return ListTile(
                      title: Text('Sign in'),
                      leading: Icon(Icons.person_add),
                      onTap: () => Navigator.pushNamed(context, '/login'),
                    );
                  }
                } else {
                  return Container();
                }
              },
              future: client.hasLogin(),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Builder(builder: bodyWidgetBuilder),
    );
  }
}
