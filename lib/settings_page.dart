import 'dart:async' show Future;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'persistence.dart' show db;

class SettingsPage extends StatefulWidget {
  @override
  State createState() => new _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _host;
  String _username;
  bool _showUnsafe;

  @override
  void initState() {
    super.initState();
    _showUnsafe = false;
    db.host.value.then((a) async => setState(() {
      _host = a;
      _showUnsafe = _host == 'e621.net' ? true : false;
    }));
    db.username.value.then((a) async => setState(() => _username = a));
  }

  Function() _onTapSignOut(BuildContext context) {
    return () async {
      String username = await db.username.value;
      db.username.value = new Future.value(null);
      db.apiKey.value = new Future.value(null);

      String msg = 'Forgot login details';
      if (username != null) {
        msg = msg + ' for $username';
      }

      Scaffold.of(context).showSnackBar(new SnackBar(
        duration: const Duration(seconds: 5),
        content: new Text(msg),
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
          children: [
            new SwitchListTile(
              title: const Text('Show NSFW posts'),
              subtitle: new Text(_host ?? ' '),
              value: _showUnsafe,
              onChanged: (show) {
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

            new ListTile(
              title: const Text('Sign out'),
              subtitle: new Text(_username ?? ' '),
              onTap: _onTapSignOut(context),
            ),
          ],
        ),
      );
    }

    return new Scaffold(
      appBar: new AppBar(title: const Text('Settings')),
      body: new Builder(builder: bodyWidgetBuilder),
    );
  }
}

