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
  bool _hideSwf;
  String _username;

  @override
  void initState() {
    super.initState();
    db.host.value.then((a) async => setState(() => _host = a));
    db.username.value.then((a) async => setState(() => _username = a));
  }

  Function() _onTapSiteBackend(BuildContext ctx) {
    return () async {
      String newHost = await showDialog<String>(
          context: ctx,
          builder: (ctx) {
            return new _SiteBackendDialog(_host);
          });

      if (newHost != null) {
        db.host.value = new Future.value(newHost);
        setState(() {
          _host = newHost;
        });
      }
    };
  }

  Function() _onTapSignOut(BuildContext ctx) {
    return () async {
      String username = await db.username.value;
      db.username.value = new Future.value(null);
      db.apiKey.value = new Future.value(null);

      String msg = 'Forgot login details';
      if (username != null) {
        msg = msg + ' for $username';
      }

      Scaffold.of(ctx).showSnackBar(new SnackBar(
        duration: const Duration(seconds: 5),
        content: new Text(msg),
      ));

      setState(() {
        _username = null;
      });
    };
  }

  @override
  Widget build(BuildContext ctx) {
    Widget bodyWidgetBuilder(BuildContext ctx) {
      return new Container(
        padding: const EdgeInsets.all(10.0),
        child: new ListView(
          children: [
            new ListTile(
              title: const Text('Site backend'),
              subtitle: new Text(_host ?? ' '),
              onTap: _onTapSiteBackend(ctx),
            ),
            new ListTile(
              title: const Text('Sign out'),
              subtitle: new Text(_username ?? ' '),
              onTap: _onTapSignOut(ctx),
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

class _SiteBackendDialog extends StatelessWidget {
  const _SiteBackendDialog(this.host);

  final String host;

  @override
  Widget build(BuildContext ctx) {
    return new SimpleDialog(
      title: const Text('Site backend'),
      children: [
        new RadioListTile<String>(
          value: 'e926.net',
          title: const Text('e926.net'),
          groupValue: host,
          onChanged: Navigator.of(ctx).pop,
        ),
        new RadioListTile<String>(
          value: 'e621.net',
          title: const Text('e621.net'),
          groupValue: host,
          onChanged: Navigator.of(ctx).pop,
        ),
      ],
    );
  }
}
