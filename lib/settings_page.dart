import 'dart:async' show Future;
import 'dart:io' show File, Platform;

import 'package:e1547/appInfo.dart';
import 'package:e1547/client.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/main.dart';
import 'package:e1547/settings.dart' show db;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SettingsPage extends StatefulWidget {
  @override
  State createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _host;
  String _username;
  String _theme;
  bool _showUnsafe = false;

  @override
  void initState() {
    super.initState();
    db.host.value.then((a) async => setState(() {
          _host = a;
          _showUnsafe = _host == 'e621.net' ? true : false;
        }));
    db.username.value.then((a) async => setState(() => _username = a));
    db.theme.value.then((a) async => setState(() => _theme = a));
  }

  Function() _onTapSignOut(BuildContext context) {
    return () async {
      String username = await db.username.value;
      db.username.value = Future.value(null);
      db.apiKey.value = Future.value(null);

      String msg = 'Forgot login details';
      if (username != null) {
        msg = msg + ' for $username';
      }

      Scaffold.of(context).showSnackBar(SnackBar(
        duration: Duration(seconds: 5),
        content: Text(msg),
      ));

      setState(() {
        _username = null;
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyWidgetBuilder(BuildContext context) {
      return Container(
        padding: EdgeInsets.all(10.0),
        child: ListView(
          physics: BouncingScrollPhysics(),
          children: [
            Padding(
              padding: EdgeInsets.only(left: 72, bottom: 8, top: 8, right: 16),
              child: Text(
                'Posts',
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                  fontSize: 16,
                ),
              ),
            ),
            SwitchListTile(
              title: Text('Show NSFW posts'),
              subtitle: Text(_host ?? ' '),
              secondary: Icon(Icons.warning),
              value: _showUnsafe,
              onChanged: (show) async {
                bool consent = _showUnsafe || await getConsent(context);
                setState(() {
                  if (consent) {
                    _showUnsafe = show;
                    if (show) {
                      _host = 'e621.net';
                      db.host.value = Future.value(_host);
                    } else {
                      _host = 'e926.net';
                      db.host.value = Future.value(_host);
                    }
                  }
                });
              },
            ),
            () {
              File nomedia = File(
                  '${Platform.environment['EXTERNAL_STORAGE']}/Pictures/$appName/.nomedia');
              if (Platform.isAndroid) {
                return SwitchListTile(
                    title: Text('Hide in gallery'),
                    subtitle: nomedia.existsSync()
                        ? Text('Downloads are hidden')
                        : Text('Downloads are shown'),
                    secondary: Icon(Icons.image),
                    value: nomedia.existsSync(),
                    onChanged: (hide) {
                      if (hide) {
                        nomedia.writeAsString('');
                      } else {
                        nomedia.delete();
                      }
                      setState(() {});
                    });
              } else {
                return Container();
              }
            }(),
            Divider(),
            Padding(
              padding: EdgeInsets.only(left: 72, bottom: 8, top: 8, right: 16),
              child: Text(
                'Display',
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                  fontSize: 16,
                ),
              ),
            ),
            ListTile(
              title: Text('Theme'),
              subtitle: Text(_theme ?? ' '),
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
                                  trailing: () {
                                    return Container(
                                      height: 36,
                                      width: 36,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5)),
                                        color: themeMap[theme].canvasColor,
                                        border: Border.all(
                                          color:
                                              Theme.of(context).iconTheme.color,
                                        ),
                                      ),
                                    );
                                  }(),
                                  onTap: () {
                                    setState(() {
                                      _theme = theme;
                                      db.theme.value = Future.value(theme);
                                    });
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
            Padding(
              padding: EdgeInsets.only(left: 72, bottom: 8, top: 8, right: 16),
              child: Text(
                'Listing',
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                  fontSize: 16,
                ),
              ),
            ),
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
            Padding(
              padding: EdgeInsets.only(left: 72, bottom: 8, top: 8, right: 16),
              child: Text(
                'Account',
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                  fontSize: 16,
                ),
              ),
            ),
            FutureBuilder(
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data) {
                    return ListTile(
                      title: Text('Sign out'),
                      subtitle: Text(_username ?? ' '),
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
