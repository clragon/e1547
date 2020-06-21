import 'dart:async' show Future;

import 'package:e1547/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'client.dart';
import 'persistence.dart' show db;

class SettingsPage extends StatefulWidget {
  @override
  State createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _host;
  String _username;
  bool _showUnsafe = false;
  bool _showWebm = false;
  bool _refresh = false;

  @override
  void initState() {
    super.initState();
    db.host.value.then((a) async => setState(() {
          _host = a;
          _showUnsafe = _host == 'e621.net' ? true : false;
        }));
    db.username.value.then((a) async => setState(() => _username = a));
    db.showWebm.value.then((a) async => setState(() => _showWebm = a));
  }

  Function() _onTapSignOut(BuildContext context) {
    return () async {
      _refresh = true;

      String username = await db.username.value;
      db.username.value = Future.value(null);
      db.apiKey.value = Future.value(null);

      String msg = 'Forgot login details';
      if (username != null) {
        msg = msg + ' for $username';
      }

      Scaffold.of(context).showSnackBar(new SnackBar(
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
      return new Container(
        padding: const EdgeInsets.all(10.0),
        child: new ListView(
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
              onChanged: (show) {
                _refresh = true;
                setState(() {
                  _showUnsafe = show;
                  if (show) {
                    _host = 'e621.net';
                    db.host.value = Future.value(_host);
                  } else {
                    _host = 'e926.net';
                    db.host.value = Future.value(_host);
                  }
                });
              },
            ),
            SwitchListTile(
                title: Text('Show webm'),
                subtitle:
                    Text(_showWebm ? 'Webm are shown' : 'Webm are hidden'),
                secondary: Icon(Icons.play_circle_outline),
                value: _showWebm,
                onChanged: (show) {
                  _refresh = true;
                  setState(() {
                    _showWebm = show;
                    db.showWebm.value = Future.value(show);
                  });
                }),
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

    return WillPopScope(
      onWillPop: () async {
        if (_refresh) {
          refreshPage(context);
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                if (_refresh) {
                  refreshPage(context);
                } else {
                  Navigator.pop(context);
                }
              }),
        ),
        body: Builder(builder: bodyWidgetBuilder),
      ),
    );
  }
}
